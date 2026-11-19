import 'dart:async';
import 'dart:math';
import 'combat_system.dart';
import 'event_system.dart';
import 'flavor.dart';
import 'flavor_gen.dart';
import 'game_state.dart';
import 'hacking_system.dart';
import 'lockpicking_system.dart';
import 'quests.dart';
import 'story_system.dart';
import 'typewriter.dart';
import 'world.dart';

/// Drives automated exploration. Pauses whenever the mode isn't `exploring`
/// so encounters (combat, hacking, lockpicking, events) can take over cleanly.
class ExplorationSystem {
  final GameState state;
  final HackingSystem hacking;
  final LockpickingSystem lockpicking;
  final CombatSystem combat;
  final EventSystem events;
  final TypewriterController typer;
  final StorySystem? story; // Story Expedition checkpoints and flavour
  final Random _rng;
  Timer? _timer;
  int _ticks = 0;
  int _lastKm = 0;
  bool _eventDue = false;
  final List<String> _recent = []; // avoids repeating flavour lines

  ExplorationSystem(this.state, this.hacking, this.lockpicking, this.combat, this.events, this.typer,
      {Random? rng, this.story})
      : _rng = rng ?? Random();

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
  }

  void dispose() => _timer?.cancel();

  void _tick() {
    if (!state.exploring || state.walkingPaused || state.pending != null) {
      _eventDue = false;
      return;
    }
    _ticks++;
    // Placeholder healing: +1 HP every 5 seconds.
    if (_ticks % max(4, 10 - state.skill('SURVIVAL') ~/ 2) == 0 && state.hp < state.maxHp) {
      state.hp++; // Survival skill speeds up natural healing
    }
    final km = state.distanceKm.floor();
    if (km != _lastKm) {
      _lastKm = km;
      state.questEvent(QuestKind.distance, km, absolute: true);
    }
    // A Story Expedition checkpoint stops the walk right where it is: no more
    // distance, no random events, until the player has dealt with it.
    final st = story;
    if (st != null && st.poll(settled: typer.settled)) {
      _eventDue = false;
      return;
    }
    state.advance(0.01);
    _checkRegion();
    if (_ticks % 8 == 0) _eventDue = true;
    if (_eventDue && typer.settled) {
      _eventDue = false;
      _rollEvent();
    }
  }

  void _checkRegion() {
    final r = regionAt(state.distanceKm);
    if (r.name == state.region) return;
    state.setRegion(r.name);
    state.gainXp(10);
    state.addLog('> ENTERING REGION: ${r.name}', LogKind.system, notify: false);
    state.addLog('> DANGER LEVEL: ${r.danger}', LogKind.warning, notify: false);
    state.addLog(r.arrival, LogKind.narrative);
  }

  /// Roughly: 28% scavenge, 9% lock, 8% terminal, 11% fight, 12% choice
  /// encounter, 5% hazard, the rest flavour. Perception shifts weight to finds.
  void _rollEvent() {
    final r = _rng.nextDouble();
    var edge = 0.28 + state.discoveryBonus;
    if (r < edge) {
      _scavenge();
      return;
    }
    edge += 0.09;
    if (r < edge) {
      if (state.lockpicks > 0) {
        _announce('> ENCOUNTER: LOCKED CONTAINER!', lockpicking.offerLock);
      } else {
        lockpicking.offerLock(); // explains that you have no picks
      }
      return;
    }
    edge += 0.08;
    if (r < edge) {
      _announce('> ENCOUNTER: TERMINAL!', hacking.offerTerminal);
      return;
    }
    edge += 0.11;
    if (r < edge) {
      _announce('> ENCOUNTER: HOSTILE!', combat.startEncounter);
      return;
    }
    edge += 0.12;
    if (r < edge) {
      _announce('> ENCOUNTER!', events.offerRandom);
      return;
    }
    edge += 0.05;
    if (r < edge) {
      _hazard();
      return;
    }
    _flavor();
  }

  /// The log types a short heads-up, and only when it has finished does the
  /// encounter itself appear on the main screen.
  void _announce(String text, void Function() start) {
    state.addLog(text, LogKind.warning, pauseMs: 500, effect: () {
      state.pending = start; // the player presses ENTER to begin
      state.refresh();
    });
  }

  static const _failLines = [
    'Just rust, splinters and disappointment.',
    'Someone got here first. The shelves are bare.',
    'Nothing but dust and the smell of old rain.',
  ];

  /// "..." builds suspense: the check line types out, pauses, and only then do
  /// the result and rewards appear (the HUD updates as the reward line lands).
  void _scavenge() {
    final success = min(0.98,
        0.82 + 0.02 * (state.stat('PER') - 1) + 0.01 * state.skill('SCAVENGING'));
    state.addLog('> SCAVENGE CHECK...', LogKind.system, notify: false, pauseMs: 1400);
    if (_rng.nextDouble() >= success) {
      state.addLog('> RESULT: NOTHING USEFUL', LogKind.warning, notify: false);
      final fails = [..._failLines, ...extraFailLines];
      state.addLog(
          _rng.nextDouble() < 0.8 ? ExploreGen.fail(_rng, _region()) : fails[_rng.nextInt(fails.length)],
          LogKind.narrative);
      return;
    }
    final n = state.withBench(
        ((3 + _rng.nextInt(10) + (state.distanceKm * 2).floor()) * state.scavengeMult)
            .round());
    final pick = _rng.nextDouble() < 0.1;
    final stim = _rng.nextDouble() < 0.08;
    state.addLog('> RESULT: SUCCESS', LogKind.system, notify: false);
    final finds = [...scavengeLines, ...extraScavengeLines];
    state.addLog(
        _rng.nextDouble() < 0.8 ? ExploreGen.find(_rng, _region()) : finds[_rng.nextInt(finds.length)],
        LogKind.narrative,
        notify: false);
    state.addLog('+ $n SCRAP', LogKind.loot, notify: false, effect: () {
      state.addScrap(n);
      state.gainXp(3);
      state.gainSkill('SCAVENGING');
      state.refresh();
    });
    final parts = _rng.nextDouble() < 0.45 ? 1 + (state.distanceKm >= 6 ? 1 : 0) : 0;
    if (parts > 0) {
      state.addLog('+ $parts PARTS', LogKind.loot, notify: false, effect: () {
        state.parts += parts;
        state.refresh();
      });
    }
    if (pick) {
      state.addLog('+ 1 LOCKPICK', LogKind.loot, notify: false, effect: () {
        state.lockpicks++;
        state.refresh();
      });
    }
    if (stim) {
      state.addLog('+ 1 STIMPACK', LogKind.loot, notify: false, effect: () {
        state.stimpacks++;
        state.refresh();
      });
    }
    state.refresh();
  }

  void _hazard() {
    final allHazards = [...hazards, ...extraHazards];
    final h = allHazards[_rng.nextInt(allHazards.length)];
    state.addLog('> HAZARD: ${h.name}', LogKind.warning, notify: false);
    state.addLog(h.text, LogKind.narrative, notify: false, pauseMs: 900);
    state.addLog('> REACTION CHECK...', LogKind.system, notify: false, pauseMs: 1200);
    final chance = min(0.9, 0.35 + 0.07 * state.stat(h.stat));
    if (_rng.nextDouble() < chance) {
      state.addLog('You react in time and slip past unharmed.', LogKind.system,
          notify: false, effect: () {
        state.gainXp(6);
        state.gainSkill('SURVIVAL');
        state.refresh();
      });
    } else {
      final base = h.dmgMin + _rng.nextInt(h.dmgMax - h.dmgMin + 1);
      final dmg = max(
          1,
          (base * (1 + 0.05 * state.distanceKm) * (1 - 0.04 * state.skill('SURVIVAL')))
                  .round() -
              state.armorValue ~/ 2);
      state.addLog('DAMAGE RECEIVED: $dmg', LogKind.danger, notify: false,
          effect: () {
        state.damage(dmg); // never drops you below 1 HP
        state.gainSkill('SURVIVAL');
      });
    }
    state.refresh();
  }

  int _region() => regions.indexOf(regionAt(state.distanceKm));

  /// What you see, hear and think. Lines are drawn from big pools (region
  /// sights and thoughts, sounds, weather, scrawled notes, radio, memories),
  /// and thoughts react to how you're doing. Recent lines are not repeated.
  void _flavor() {
    final r = regionAt(state.distanceKm);
    final sights = [...r.sights, ...?extraSights[r.name]];
    final thoughts = [...r.thoughts, ...?extraThoughts[r.name], ...memoryLines];
    final situational = <String>[
      if (state.hp < state.maxHp * 0.3) ...[...lowHpThoughts, ...extraLowHpThoughts],
      if (state.scrap >= 150) ...[...richThoughts, ...extraRichThoughts],
      if (state.distanceKm >= 8) ...[...farThoughts, ...extraFarThoughts],
    ];

    String pick(List<String> pool) {
      for (int i = 0; i < 8; i++) {
        final line = pool[_rng.nextInt(pool.length)];
        if (!_recent.contains(line)) return line;
      }
      return pool[_rng.nextInt(pool.length)];
    }

    // Mostly freshly generated sentences (see flavor_gen.dart), seasoned with the
    // hand-written pools; recently shown lines are not repeated.
    final reg = regions.indexOf(r);
    String gen(String Function(Random, int) g, List<String> pool) {
      if (_rng.nextDouble() < 0.78) {
        for (int i = 0; i < 4; i++) {
          final line = g(_rng, reg);
          if (!_recent.contains(line)) return line;
        }
      }
      return pick(pool);
    }

    // While a Story Expedition is active, part of the walk is its own flavour:
    // lines that know which checkpoints and decisions came before.
    final st = story;
    if (st != null && st.active && _rng.nextDouble() < 0.4) {
      final amb = st.ambient(_rng, _recent);
      if (amb != null) {
        state.addLog(amb.text, amb.kind, pauseMs: amb.pauseMs);
        return;
      }
    }

    final String line;
    var kind = LogKind.narrative;
    final roll = _rng.nextDouble();
    if (roll < 0.26) {
      line = gen(ExploreGen.sight, sights);
    } else if (roll < 0.46) {
      final useSituational = situational.isNotEmpty && _rng.nextDouble() < 0.4;
      line = useSituational ? pick(situational) : gen(ExploreGen.thought, thoughts);
      kind = LogKind.thought;
    } else if (roll < 0.58) {
      line = gen(ExploreGen.sound, soundLines);
    } else if (roll < 0.66) {
      line = gen(ExploreGen.smell, weatherLines);
    } else if (roll < 0.76) {
      line = gen(ExploreGen.weather, weatherLines);
    } else if (roll < 0.89) {
      line = gen(ExploreGen.note, noteLines);
    } else {
      line = gen(ExploreGen.radio, radioLines);
    }
    _recent.add(line);
    if (_recent.length > 30) _recent.removeAt(0);
    state.addLog(line, kind);
  }
}
