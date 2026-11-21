import 'dart:math';
import 'combat_session.dart';
import 'combat_system.dart';
import 'event_data.dart';
import 'event_session.dart';
import 'quests.dart';
import 'game_state.dart';
import 'hacking_system.dart';
import 'items.dart';
import 'lockpicking_system.dart';
import 'story_content.dart';
import 'story_system.dart';

export 'event_session.dart' show EventOption;

/// Choice-based encounters. Their text is typed on the main screen (the
/// encounter console). Some end on their own; others hand you over to the
/// lockpicking, hacking or combat systems.
class EventSystem {
  final GameState state;
  final HackingSystem hacking;
  final LockpickingSystem lockpicking;
  final CombatSystem combat;
  final Random _rng;
  final StorySystem? story; // runs Story Expedition checkpoint scenes

  EventSystem(this.state, this.hacking, this.lockpicking, this.combat,
      {Random? rng, this.story})
      : _rng = rng ?? Random();

  static const _baseWeights = {
    'merchant': 15,
    'survivor': 15,
    'building': 25,
    'signal': 12,
    'camp': 18,
    'cave': 15,
  };

  Map<String, int> get _weights => {
        ..._baseWeights,
        for (final e in dataEvents) e.id: e.weight,
      };

  void offerRandom() {
    final total = _weights.values.fold(0, (a, b) => a + b);
    var roll = _rng.nextInt(total);
    var id = _weights.keys.first;
    for (final e in _weights.entries) {
      if (roll < e.value) {
        id = e.key;
        break;
      }
      roll -= e.value;
    }
    state.resetConsole();
    state.event = EventSession(id);
    state.mode = GameMode.event;
    final thoughts = eventThoughtsOf(id);
    state.addLog(eventDescOf(id), LogKind.narrative, notify: false);
    state.addLog(thoughts[_rng.nextInt(thoughts.length)], LogKind.thought);
  }

  List<EventOption> optionsFor(EventSession s) {
    if (isStorySession(s.id)) return story?.optionsFor(s) ?? const [];
    final def = dataEventById(s.id);
    if (def != null) {
      return [
        for (final o in def.options)
          EventOption(
            o.label,
            state.scrap >= o.needScrap &&
                state.stimpacks >= o.needStim &&
                state.lockpicks >= o.needPick,
          ),
      ];
    }
    switch (s.id) {
      case 'merchant':
        return [
          EventOption('[BUY STIMPACK 25]', state.scrap >= 25),
          EventOption('[BUY LOCKPICK 15]', state.scrap >= 15),
          EventOption('[SALVAGE CRATE 40]', state.scrap >= 40),
          const EventOption('[LEAVE]'),
        ];
      case 'survivor':
        return [
          EventOption('[HELP: USE A STIMPACK]', state.stimpacks > 0),
          const EventOption('[TAKE THEIR SCRAP]'),
          const EventOption('[WALK AWAY]'),
        ];
      case 'building':
        return const [EventOption('[ENTER]'), EventOption('[SKIP]')];
      case 'signal':
        return const [EventOption('[FOLLOW THE SIGNAL]'), EventOption('[IGNORE IT]')];
      case 'camp':
        return const [EventOption('[SEARCH]'), EventOption('[REST]'), EventOption('[LEAVE]')];
      case 'cave':
        return const [EventOption('[EXPLORE]'), EventOption('[LEAVE]')];
    }
    return const [EventOption('[LEAVE]')];
  }

  void choose(int i) {
    final s = state.event;
    if (s == null || s.finished) return;
    if (isStorySession(s.id)) {
      story?.choose(i);
      return;
    }
    final opts = optionsFor(s);
    if (i < 0 || i >= opts.length || !opts[i].enabled) return;
    final def = dataEventById(s.id);
    if (def != null) {
      _runData(s, def.options[i]);
      return;
    }
    switch (s.id) {
      case 'merchant':
        _merchant(s, i);
        break;
      case 'survivor':
        _survivor(s, i);
        break;
      case 'building':
        _building(s, i);
        break;
      case 'signal':
        _signal(s, i);
        break;
      case 'camp':
        _camp(s, i);
        break;
      case 'cave':
        _cave(s, i);
        break;
      default:
        _finish(s, 'You move on.');
    }
  }

  /// Leave the event screen. The narrative log picks up again (with a short
  /// recap of anything gained) once you are back out in the wasteland.
  void leave() {
    final s = state.event;
    if (s == null || !s.finished) return;
    if (isStorySession(s.id)) {
      story?.leave();
      return;
    }
    final title = dataEvents.where((e) => e.id == s.id).map((e) => e.title).firstOrNull ?? 'ENCOUNTER';
    state.event = null;
    state.mode = GameMode.exploring;
    state.questEvent(QuestKind.events, 1);
    state.endEncounter(summary: '> ENCOUNTER: $title RESOLVED');
    state.refresh();
  }

  // ---- helpers

  int _scrap(int lo, int hi) => state.withBench(
      ((lo + _rng.nextInt(hi - lo + 1)) * (1 + 0.1 * state.distanceKm) * state.scavengeMult)
          .round());

  void _finish(EventSession s, String text) {
    s.finished = true;
    s.result = text;
    state.addLog(text, LogKind.narrative);
  }

  /// Let another encounter system take over from this event. Anything said
  /// afterwards lands on that encounter's console.
  void _handOff(void Function() next) {
    state.event = null;
    state.mode = GameMode.exploring;
    next();
    if (state.mode == GameMode.exploring) {
      state.endEncounter(); // nothing took over (e.g. no lockpicks)
    }
  }

  bool _rareFind() {
    final pool = gearCatalog
        .where((g) => g.cost > 0 && !g.craft && !state.owned.contains(g.id))
        .toList();
    if (pool.isEmpty) return false;
    final g = pool[_rng.nextInt(pool.length)];
    state.owned.add(g.id);
    state.addLog('> RARE ITEM FOUND: ${g.name}', LogKind.loot, notify: false);
    state.addLog('(ADDED TO YOUR STASH. EQUIP IT AT THE SAFEHOUSE.)', LogKind.narrative,
        notify: false);
    state.gainXp(30);
    return true;
  }

  /// Plays one option of a data-driven event: pay the cost, roll an outcome by
  /// weight, then tell the story and apply what happens.
  void _runData(EventSession s, OptionDef o) {
    state.scrap -= o.needScrap;
    state.stimpacks -= o.needStim;
    state.lockpicks -= o.needPick;

    final total = o.outcomes.fold(0, (a, b) => a + b.weight);
    var roll = _rng.nextInt(total);
    var out = o.outcomes.first;
    for (final x in o.outcomes) {
      if (roll < x.weight) {
        out = x;
        break;
      }
      roll -= x.weight;
    }

    // Another system takes over: the story lands on its console.
    if (out.chain != null || out.fight != null || out.anyFight) {
      if (out.chain == 'lock') {
        _handOff(lockpicking.offerLock);
      } else if (out.chain == 'hack') {
        _handOff(hacking.offerTerminal);
      } else if (out.fight != null) {
        _handOff(() => combat.startEncounter(forced: out.fight));
      } else {
        _handOff(combat.startEncounter);
      }
      state.addLog(out.text, out.chain != null ? LogKind.narrative : LogKind.danger);
      return;
    }

    state.addLog(out.text, LogKind.narrative, notify: false);
    if (out.scrapMax > 0) {
      final n = _scrap(out.scrapMin, out.scrapMax);
      state.addLog('+ $n SCRAP', LogKind.loot, notify: false);
      state.addScrap(n);
    }
    if (out.stim > 0) {
      state.stimpacks += out.stim;
      state.addLog('+ ${out.stim} STIMPACK', LogKind.loot, notify: false);
    }
    if (out.picks > 0) {
      state.lockpicks += out.picks;
      state.addLog('+ ${out.picks} LOCKPICK', LogKind.loot, notify: false);
    }
    if (out.parts > 0) {
      state.parts += out.parts;
      state.addLog('+ ${out.parts} PARTS', LogKind.loot, notify: false);
    }
    if (out.hp > 0) {
      final before = state.hp;
      state.hp = min(state.maxHp, state.hp + out.hp);
      state.addLog('> HP +${state.hp - before}', LogKind.loot, notify: false);
    }
    if (out.hp < 0) {
      state.addLog('DAMAGE RECEIVED: ${-out.hp}', LogKind.danger, notify: false);
      state.damage(-out.hp);
    }
    if (out.xp > 0) state.gainXp(out.xp);
    if (out.rare) _rareFind();
    s.finished = true;
    s.result = out.text;
    state.refresh();
  }

  // ---- events

  void _merchant(EventSession s, int i) {
    switch (i) {
      case 0:
        state.scrap -= 25;
        state.stimpacks++;
        state.addLog('> BOUGHT: STIMPACK (-25 SCRAP)', LogKind.loot);
        break;
      case 1:
        state.scrap -= 15;
        state.lockpicks++;
        state.addLog('> BOUGHT: LOCKPICK (-15 SCRAP)', LogKind.loot);
        break;
      case 2:
        state.scrap -= 40;
        final n = 15 + _rng.nextInt(66); // a gamble: 15 to 80
        state.addLog('> THE CRATE POPS OPEN: +$n SCRAP', LogKind.loot, notify: false);
        state.addScrap(n);
        break;
      default:
        _finish(s, "You part ways. The trader's cart rattles off into the haze.");
    }
  }

  void _survivor(EventSession s, int i) {
    switch (i) {
      case 0:
        state.stimpacks--;
        state.gainXp(20);
        final n = _scrap(15, 35);
        state.addLog('+ $n SCRAP', LogKind.loot, notify: false);
        state.acceptQuest('caravan', force: true);
        state.addScrap(n);
        _finish(s,
            'Colour returns to their face. They press some scrap into your hand. "My caravan went down the highway, past the seven kilometre marker. If you pass it... tell them I made it this far."');
        break;
      case 1:
        final n = _scrap(20, 45);
        state.addLog('+ $n SCRAP', LogKind.loot, notify: false);
        state.addScrap(n);
        _finish(s, 'They do not fight back. You tell yourself they would have done the same.');
        break;
      default:
        _finish(s, 'You keep walking. You do not look back. It is easier that way.');
    }
  }

  void _building(EventSession s, int i) {
    if (i != 0) {
      _finish(s, 'You leave it be. Some doors are better left open.');
      return;
    }
    final r = _rng.nextDouble();
    if (r < 0.35) {
      final n = _scrap(15, 45);
      state.addLog('+ $n SCRAP', LogKind.loot, notify: false);
      if (_rng.nextDouble() < 0.25) {
        state.stimpacks++;
        state.addLog('+ 1 STIMPACK', LogKind.loot, notify: false);
      }
      state.gainXp(8);
      state.addScrap(n);
      _finish(s, 'Inside, dust and silence, and a cupboard nobody thought to check. Lucky.');
    } else if (r < 0.55) {
      _handOff(lockpicking.offerLock);
      state.addLog('Inside, a locked strongbox sits under the dust.', LogKind.narrative);
    } else if (r < 0.70) {
      _handOff(hacking.offerTerminal);
      state.addLog('A dusty terminal flickers to life in the gloom.', LogKind.narrative);
    } else if (r < 0.90) {
      _handOff(combat.startEncounter);
      state.addLog('Something shifts in the dark. It was waiting for you.', LogKind.danger);
    } else {
      final dmg = 5 + _rng.nextInt(7);
      state.addLog('The floor gives way! DAMAGE RECEIVED: $dmg', LogKind.danger,
          notify: false);
      state.damage(dmg);
      _finish(s, 'You haul yourself out, bruised and sworn off dark buildings. For now.');
    }
  }

  void _signal(EventSession s, int i) {
    if (i != 0) {
      _finish(s, 'You turn away from the crackle. Whatever it wants, it can want it quietly.');
      return;
    }
    final r = _rng.nextDouble();
    if (r < 0.15 && _rareFind()) {
      _finish(s, 'Under a collapsed antenna you find a sealed case. The signal was a beacon, and somebody left a prize.');
    } else if (r < 0.55) {
      final n = _scrap(25, 60);
      state.addLog('+ $n SCRAP', LogKind.loot, notify: false);
      state.gainXp(10);
      state.addScrap(n);
      _finish(s, 'The signal leads to a buried supply cache. Somebody never came back for it.');
    } else if (r < 0.80) {
      _handOff(combat.startEncounter);
      state.addLog('The signal was bait. Something steps out of the static.', LogKind.danger);
    } else {
      _finish(s, 'You find the radio: a corroded box, looping a message nobody will ever hear.');
    }
  }

  void _camp(EventSession s, int i) {
    if (i == 0) {
      final n = _scrap(10, 30);
      state.addLog('+ $n SCRAP', LogKind.loot, notify: false);
      if (_rng.nextDouble() < 0.3) {
        state.stimpacks++;
        state.addLog('+ 1 STIMPACK', LogKind.loot, notify: false);
      }
      if (_rng.nextDouble() < 0.15) {
        state.lockpicks++;
        state.addLog('+ 1 LOCKPICK', LogKind.loot, notify: false);
      }
      if (_rng.nextDouble() < 0.4) {
        state.parts++;
        state.addLog('+ 1 PARTS', LogKind.loot, notify: false);
      }
      state.gainXp(5);
      state.addScrap(n);
      _finish(s, 'You sift through what they left behind. People leave strange things when they run.');
    } else if (i == 1) {
      if (_rng.nextDouble() < 0.2) {
        _handOff(combat.startEncounter);
        state.addLog('You doze off. Something finds you.', LogKind.danger);
      } else {
        final before = state.hp;
        state.hp = min(state.maxHp, state.hp + 15);
        state.addLog('> RESTED. +${state.hp - before} HP', LogKind.loot, notify: false);
        state.gainSkill('SURVIVAL');
        _finish(s, 'You sit by the dead fire for a while. For a few minutes, nothing wants you dead.');
      }
    } else {
      _finish(s, 'You leave the camp as you found it.');
    }
  }

  void _cave(EventSession s, int i) {
    if (i != 0) {
      _finish(s, 'You let the dark keep its secrets.');
      return;
    }
    final chance = min(0.85, 0.4 + 0.05 * state.stat('PER'));
    if (_rng.nextDouble() < chance) {
      final n = _scrap(30, 80);
      state.addLog('You spot the danger signs in time and pick your way through.',
          LogKind.system, notify: false);
      state.addLog('+ $n SCRAP', LogKind.loot, notify: false);
      state.gainXp(12);
      state.addScrap(n);
      if (_rng.nextDouble() < 0.1) _rareFind();
      _finish(s, "Deep inside, a hollow in the rock holds somebody's hidden stash.");
    } else {
      _handOff(() => combat.startEncounter(forced: EnemyType.lurker));
      state.addLog('Too late, you notice the claw marks. It was a nest.', LogKind.danger);
    }
  }
}
