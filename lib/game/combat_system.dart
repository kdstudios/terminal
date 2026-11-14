import 'dart:math';
import 'package:flutter/services.dart';
import 'combat_session.dart';
import 'fx.dart';
import 'game_state.dart';
import 'quests.dart';
import 'world.dart';

enum PlayerAction { attack, heavy, defend, item, escape }

/// Turn-based combat. Each player action resolves immediately, then the enemy
/// answers, with every step written to the narrative log.
class CombatSystem {
  static const _weaponHits = <String, List<String>>{
    'pipe': [
      'Your pipe cracks across its hide with a ringing clang.',
      'You bring the pipe down hard; something gives way.',
      'A swing from the hip, pipe meeting flesh with a dull thud.',
    ],
    'machete': [
      'The machete bites deep, and comes away dark.',
      'You hack, twist and wrench the blade free.',
      'A fast diagonal cut opens it from shoulder to hip.',
    ],
    'rifle': [
      'The pipe rifle roars, and the recoil bruises your shoulder.',
      'A flat crack echoes across the ruins as the shot lands.',
      'You squeeze the trigger and the old gun coughs fire.',
    ],
    'cutter': [
      'The plasma cutter hisses, and the air stinks of seared metal.',
      'A blue-white arc carves a smoking line through it.',
      'You drag the cutter across and everything it touches glows.',
    ],
    'rpipe': [
      'The reinforced pipe lands with a heavy, satisfying clang.',
      'You bring the steel-wrapped length down like a hammer.',
      'Plated pipe meets bone. Something gives.',
    ],
  };
  static const _playerMiss = [
    'You miss. Your swing wastes itself on empty air.',
    'You miss, and stumble as your weight carries you past.',
    'You miss by a hair; it twists away from the blow.',
    'You miss, and your weapon rings off rock instead.',
    'You miss. For a heartbeat you are wide open.',
  ];
  static const _critLines = [
    'A perfect strike, right where it hurts.',
    'You find the gap in its defences.',
    'The blow lands with a wet crack. You feel it in your teeth.',
    'Instinct takes over: a shot you could never have planned.',
  ];
  static const _enemyMiss = [
    'The {n} lunges, but you twist aside.',
    'The {n} misses you by a breath.',
    'You duck the {n} and feel the wind of it.',
    'The {n} overreaches and stumbles.',
    'The {n} strikes where you were a moment ago.',
  ];
  static const _stimLines = [
    'The needle bites, and warmth floods your veins.',
    'You jam the stimpack home. The pain thins, then steps back.',
    'Chemical fire spreads through you. Your hands stop shaking.',
  ];

  final GameState state;
  final Random _rng;
  CombatSystem(this.state, {Random? rng}) : _rng = rng ?? Random();

  /// Which enemy you meet depends on the region (weighted), unless forced.
  EnemyType _pickType() {
    final weights = regionAt(state.distanceKm).enemies;
    final total = weights.values.fold(0, (a, b) => a + b);
    var roll = _rng.nextInt(total);
    for (final e in weights.entries) {
      if (roll < e.value) return e.key;
      roll -= e.value;
    }
    return weights.keys.first;
  }

  /// Called when a hostile is met. Interrupts exploration.
  void startEncounter({EnemyType? forced}) {
    state.resetConsole();
    final s = CombatSession.spawn(forced ?? _pickType(), state.distanceKm);
    state.combat = s;
    state.mode = GameMode.combat;
    state.addLog('> HOSTILE CREATURE DETECTED', LogKind.danger, notify: false);
    state.addLog(s.template.flavor, LogKind.narrative, notify: false);
    state.addLog('> COMBAT INITIATED: ${s.name} (HP ${s.maxHp})', LogKind.danger,
        notify: false);
    Fx.medium();

    if (s.template.ambush && _rng.nextDouble() < 0.6) {
      state.addLog('It strikes from the dark before you can react!', LogKind.danger,
          notify: false);
      _enemyTurn(s); // ends with "YOUR TURN" (or your defeat)
    } else {
      state.addLog('> YOUR TURN.', LogKind.system);
    }
  }

  void act(PlayerAction a) {
    final s = state.combat;
    if (s == null || s.finished) return;

    switch (a) {
      case PlayerAction.attack:
        _strike(s, heavy: false);
        break;
      case PlayerAction.heavy:
        _strike(s, heavy: true);
        break;
      case PlayerAction.defend:
        s.playerDefending = true;
        state.addLog('> YOU BRACE FOR IMPACT.', LogKind.system, notify: false);
        break;
      case PlayerAction.item:
        if (state.stimpacks <= 0) {
          state.addLog('> NO STIMPACKS LEFT.', LogKind.warning); // free action
          return;
        }
        _useStim();
        break;
      case PlayerAction.escape:
        if (_tryEscape(s)) {
          state.refresh();
          return;
        }
        break;
    }
    s.guarding = false; // cover only protects against one action

    if (s.hp <= 0) {
      _victory(s);
    } else {
      _enemyTurn(s);
    }
  }

  void leave() {
    final s = state.combat;
    if (s == null || !s.finished) return;
    final died = s.outcome == CombatOutcome.died;
    state.combat = null;
    if (died) {
      state.arriveHome(); // death sends you home
      state.endEncounter(recap: false);
    } else {
      state.mode = GameMode.exploring;
      state.endEncounter(); // the log resumes with a short recap
      state.refresh();
    }
  }

  // ---- player actions

  void _strike(CombatSession s, {required bool heavy}) {
    state.addLog(
      heavy
          ? '> YOU UNLEASH A HEAVY ATTACK ON THE ${s.template.short.toUpperCase()}.'
          : '> YOU ATTACK THE ${s.template.short.toUpperCase()}.',
      LogKind.system,
      notify: false,
    );
    state.wear(state.weaponId, heavy ? 2 : 1); // swinging wears the weapon
    final hitBonus = min(0.2, 0.02 * state.skill('COMBAT')); // Combat skill
    if (_rng.nextDouble() > (heavy ? 0.7 : 0.9) + hitBonus) {
      state.addLog(_playerMiss[_rng.nextInt(_playerMiss.length)], LogKind.warning,
          notify: false);
      return;
    }
    final w = state.weapon;
    var dmg = w.dmgMin + _rng.nextInt(w.dmgMax - w.dmgMin + 1) + state.strBonus;
    dmg = max(1, (dmg * state.weaponCondition).round()); // worn weapons hit softer
    if (heavy) dmg = (dmg * 1.8).round();
    final crit = _rng.nextDouble() < state.critChance;
    if (crit) dmg = (dmg * 1.75).round();
    final armor = heavy ? s.armor ~/ 2 : s.armor; // heavy hits pierce half
    dmg = max(1, dmg - armor);
    if (s.guarding) {
      dmg = max(1, dmg ~/ 2);
      state.addLog('(THE ${s.template.short.toUpperCase()} IS BEHIND COVER: DAMAGE HALVED)',
          LogKind.narrative, notify: false);
    }
    s.hp = max(0, s.hp - dmg);
    final hitPool = _weaponHits[state.weaponId] ?? _weaponHits['pipe']!;
    state.addLog(hitPool[_rng.nextInt(hitPool.length)], LogKind.narrative, notify: false);
    if (crit) {
      state.addLog(_critLines[_rng.nextInt(_critLines.length)], LogKind.loot, notify: false);
    }
    state.addLog('DAMAGE DEALT: $dmg${crit ? ' (CRITICAL!)' : ''}', LogKind.system,
        notify: false);
    if (armor > 0) {
      state.addLog('(ARMOR ABSORBED $armor)', LogKind.narrative, notify: false);
    }
  }

  void _useStim() {
    state.stimpacks--;
    final before = state.hp;
    state.hp = min(state.maxHp, state.hp + state.stimHeal);
    state.addLog('> YOU USE A STIMPACK. +${state.hp - before} HP', LogKind.loot,
        notify: false);
    state.gainSkill('SURVIVAL');
    state.addLog(_stimLines[_rng.nextInt(_stimLines.length)], LogKind.narrative,
        notify: false);
  }

  /// Returns true if the escape worked (combat over).
  bool _tryEscape(CombatSession s) {
    final chance = min(0.9,
        max(0.1, 0.5 * s.template.escapeMod + 0.03 * (state.stat('AGI') - 1)));
    state.addLog('> YOU ATTEMPT TO ESCAPE.', LogKind.system, notify: false);
    if (_rng.nextDouble() < chance) {
      s.outcome = CombatOutcome.fled;
      state.addLog('> ESCAPE SUCCESSFUL.', LogKind.system);
      return true;
    }
    state.addLog('The ${s.template.short} cuts off your escape!', LogKind.warning,
        notify: false);
    return false;
  }

  // ---- enemy turn

  void _enemyTurn(CombatSession s) {
    final t = s.template;
    state.addLog('> ENEMY TURN.', LogKind.danger, notify: false);

    if (s.charging) {
      // The telegraphed attack lands hard, so defending against it matters.
      s.charging = false;
      state.addLog('The ${t.short} unleashes its charged attack!', LogKind.danger,
          notify: false);
      _hitPlayer(s, mult: 2.0, forceHit: true);
    } else if (t.chargeChance > 0 && _rng.nextDouble() < t.chargeChance) {
      s.charging = true;
      _endTurnWithoutAttack(s,
          'The ${t.short} ${t.chargeText}... BRACE!');
      return;
    } else if (t.coverChance > 0 && _rng.nextDouble() < t.coverChance) {
      s.guarding = true;
      _endTurnWithoutAttack(s, 'The ${t.short} ducks behind cover!');
      return;
    } else {
      for (int i = 0; i < t.strikes; i++) {
        _hitPlayer(s, mult: t.strikes > 1 ? 0.65 : 1.0);
        if (state.hp <= 0) break;
      }
    }
    s.playerDefending = false;

    if (state.hp <= 0) {
      _defeat(s);
      return;
    }
    s.turn++;
    state.addLog('> YOUR TURN.', LogKind.system);
  }

  void _endTurnWithoutAttack(CombatSession s, String text) {
    s.playerDefending = false;
    s.turn++;
    state.addLog(text, LogKind.warning, notify: false);
    state.addLog('> YOUR TURN.', LogKind.system);
  }

  void _hitPlayer(CombatSession s, {required double mult, bool forceHit = false}) {
    final t = s.template;
    var dmg = ((s.atkMin + _rng.nextInt(s.atkMax - s.atkMin + 1)) * mult).round();
    final hitChance = max(0.4, t.hitChance - state.evadeBonus);
    if (!forceHit && _rng.nextDouble() >= hitChance) {
      state.addLog(
          _enemyMiss[_rng.nextInt(_enemyMiss.length)].replaceAll('{n}', t.short),
          LogKind.system,
          notify: false);
      return;
    }
    if (s.playerDefending) {
      dmg = (dmg * 0.5).round();
      state.addLog('You absorb the worst of it.', LogKind.narrative, notify: false);
    }
    final armor = state.armorValue;
    dmg = max(1, dmg - armor);
    if (armor > 0) {
      state.addLog('(YOUR ARMOR ABSORBED $armor)', LogKind.narrative, notify: false);
    }
    state.hp = max(0, state.hp - dmg);
    final worn = state.armorId;
    if (worn != null) state.wear(worn, 1); // every hit wears your armor
    state.addLog(
        t.hitLines.isEmpty
            ? 'The ${t.short} ${t.verb} you.'
            : t.hitLines[_rng.nextInt(t.hitLines.length)],
        LogKind.danger,
        notify: false);
    state.addLog('DAMAGE RECEIVED: $dmg', LogKind.danger, notify: false);
    Fx.medium();
  }

  // ---- endings

  void _victory(CombatSession s) {
    s.outcome = CombatOutcome.won;
    final mult = 1 + state.distanceKm * 0.2;
    final scrap =
        state.withBench(((8 + _rng.nextInt(11)) * s.template.scrapMult * mult).round());
    s.scrapGained = scrap;
    state.addLog('> ${s.name} DEFEATED', LogKind.system, notify: false);
    if (s.template.dieLines.isNotEmpty) {
      state.addLog(s.template.dieLines[_rng.nextInt(s.template.dieLines.length)],
          LogKind.narrative, notify: false);
    }
    state.addLog('+ $scrap SCRAP', LogKind.loot, notify: false);
    if (_rng.nextDouble() < 0.2 + 0.02 * (state.stat('LCK') - 1)) {
      state.stimpacks++;
      state.addLog('+ 1 STIMPACK', LogKind.loot, notify: false);
    }
    if (_rng.nextDouble() < 0.1 + 0.01 * (state.stat('LCK') - 1)) {
      state.lockpicks++;
      state.addLog('+ 1 LOCKPICK', LogKind.loot, notify: false);
    }
    state.gainXp((s.template.xp * (1 + 0.1 * state.distanceKm)).round());
    state.gainSkill('COMBAT');
    final parts = _partsFor(s.type);
    if (parts > 0) {
      state.parts += parts;
      state.addLog('+ $parts PARTS', LogKind.loot, notify: false);
    }
    state.questEvent(QuestKind.kills, 1, tag: s.type.name);
    Fx.heavy();
    state.addScrap(scrap); // notifies
  }

  /// Machines and mutants leave salvage behind.
  int _partsFor(EnemyType t) {
    switch (t) {
      case EnemyType.skitter:
      case EnemyType.crawler:
        return 1 + _rng.nextInt(2);
      case EnemyType.sentry:
        return 2 + _rng.nextInt(2);
      case EnemyType.warmachine:
        return 4 + _rng.nextInt(3);
      case EnemyType.raider:
      case EnemyType.brute:
        return _rng.nextDouble() < 0.5 ? 1 : 0;
      default:
        return 0;
    }
  }

  /// Death sends you home: you lose half your scrap and wake at half health.
  void _defeat(CombatSession s) {
    s.outcome = CombatOutcome.died;
    final lost = state.scrap ~/ 2;
    s.scrapGained = -lost;
    state.scrap -= lost;
    state.hp = state.maxHp ~/ 2;
    state.addLog('> YOU HAVE FALLEN.', LogKind.danger, notify: false);
    state.addLog('You wake in your safehouse, battered. Half your scrap is gone.',
        LogKind.narrative, notify: false);
    if (lost > 0) state.addLog('- $lost SCRAP', LogKind.danger, notify: false);
    Fx.heavy();
    state.refresh();
  }
}
