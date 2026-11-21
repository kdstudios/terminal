import 'dart:math';
import 'combat_system.dart';
import 'event_session.dart';
import 'game_state.dart';
import 'hacking_system.dart';
import 'lockpicking_system.dart';
import 'quests.dart';
import 'story_content.dart';
import 'story_model.dart';

enum StoryStatus { locked, available, active, paused, completed }

/// One parsed line of story text.
class StoryLine {
  final String text;
  final LogKind kind;
  final int? pauseMs;
  const StoryLine(this.text, this.kind, [this.pauseMs]);
}

class _Where {
  final StoryDef def;
  final StoryRun run;
  final Checkpoint cp;
  final Scene scene;
  const _Where(this.def, this.run, this.cp, this.scene);
}

/// Story Expeditions: a persistent objective that rides on the existing
/// "Depart on Expedition" exploration.
///
/// * Distance: [GameState.distanceKm] stays the one live distance. Departing
///   restores it from the active story; returning home stores it back.
/// * Checkpoints: [poll] runs from the exploration tick. When the next
///   checkpoint is reached, walking stops until it is resolved. A checkpoint is
///   completed exactly once (it is recorded, then saved immediately).
/// * Scenes: interactive checkpoints reuse the choice-encounter screen, and
///   hand over to the normal hacking, lockpicking and combat systems.
class StorySystem {
  final GameState state;
  final HackingSystem hacking;
  final LockpickingSystem lockpicking;
  final CombatSystem combat;

  StorySystem(this.state, this.hacking, this.lockpicking, this.combat) {
    state.onEncounterEnd = _onEncounterEnd;
  }

  StoryBook get book => state.story;
  StoryRun? get run => book.activeRun;
  StoryDef? get def {
    final r = run;
    return r == null ? null : storyDefOrNull(r.id);
  }

  /// A story is being walked right now (not paused at home).
  bool get active => def != null && state.mode != GameMode.home;

  StoryCtx ctxFor(StoryRun r) => StoryCtx(
        run: r,
        book: book,
        level: state.level,
        km: state.distanceKm,
        hp: state.hp,
        maxHp: state.maxHp,
        scrap: state.scrap,
        region: state.region,
        skills: Map<String, int>.of(state.skillLevel),
        quests: {for (final q in state.quests) q.id, ...state.questsDone},
      );

  // ------------------------------------------------------------ selection

  StoryStatus statusOf(StoryDef d) {
    if (book.completed.containsKey(d.id)) return StoryStatus.completed;
    if (book.activeId == d.id) {
      return state.mode == GameMode.home ? StoryStatus.paused : StoryStatus.active;
    }
    if (!d.unlock.met(state.level, book)) return StoryStatus.locked;
    return StoryStatus.available;
  }

  /// Accept a story at the safehouse. Only one can be active at a time.
  bool accept(String id) {
    if (state.mode != GameMode.home) return false;
    final d = storyDefOrNull(id);
    if (d == null) return false;
    if (book.activeId != null) {
      state.addLog('> FINISH OR ABANDON YOUR ACTIVE STORY EXPEDITION FIRST.', LogKind.warning);
      return false;
    }
    if (statusOf(d) != StoryStatus.available) return false;
    book.runs[id] = StoryRun(id);
    book.activeId = id;
    state.addLog('> STORY EXPEDITION ACCEPTED: ${d.title}', LogKind.system, notify: false);
    state.addLog(d.intro.last, LogKind.thought, notify: false);
    state.addLog('> USE [DEPART ON EXPEDITION] TO BEGIN. PROGRESS IS KEPT WHEN YOU RETURN HOME.',
        LogKind.system);
    state.commit();
    return true;
  }

  /// Explicitly give up the active story (the UI asks for confirmation first).
  /// Distance, checkpoints, decisions and discoveries of that run are erased.
  /// Things already earned stay, and rewards already paid are never paid again.
  bool abandon() {
    if (state.mode != GameMode.home) return false;
    final r = run;
    final d = def;
    if (r == null) return false;
    book.runs.remove(r.id);
    book.activeId = null;
    state.addLog('> STORY EXPEDITION ABANDONED: ${d?.title ?? r.id}', LogKind.warning,
        notify: false);
    state.addLog('You fold the notes into a drawer and shut it. Some roads are better left unwalked.',
        LogKind.narrative);
    state.commit();
    return true;
  }

  /// Opening narration for [HomeSystem.depart] (empty without an active story).
  List<StoryLine> departLines() {
    final r = run;
    final d = def;
    if (r == null || d == null) return const [];
    return [for (final l in d.depart(ctxFor(r))) _parse(l)];
  }

  String? summaryLine() {
    final r = run;
    final d = def;
    if (r == null || d == null) return null;
    return '${d.title}  ${r.km.toStringAsFixed(1)}/${d.destinationKm} KM';
  }

  // -------------------------------------------------------------- exploring

  /// Called every exploration tick (only while walking). Returns true when the
  /// story is holding exploration: a checkpoint is due or being resolved, so
  /// the caller must neither advance the distance nor roll a random event.
  bool poll({required bool settled}) {
    final r = run;
    final d = def;
    if (r == null || d == null) return false;

    if (r.openCp != null) {
      // A checkpoint was started but is not on screen (reload, fled, died,
      // or the heads-up was lost). Never skip it: offer it again.
      if (r.announced) return true;
      final cp = checkpointOf(d, r.openCp);
      if (cp == null) {
        r.openCp = null;
        r.awaiting = false;
        return false;
      }
      if (r.awaiting) {
        // A minigame was running but its session is gone. Treat as given up.
        r.awaiting = false;
        final sc = cp.sceneMap[r.openScene];
        _afterChain(d, r, cp, sc?.onFail);
        return true;
      }
      if (!settled) return true;
      _announce(d, r, cp);
      return true;
    }

    final cp = _nextDue(d, r);
    if (cp == null) return false;
    if (!settled) return true; // stop here and let the text finish first
    _begin(d, r, cp);
    return true;
  }

  /// The first checkpoint not yet done, if the walker has reached it.
  Checkpoint? _nextDue(StoryDef d, StoryRun r) {
    for (final cp in d.checkpoints) {
      if (r.done.contains(cp.id)) continue;
      return state.distanceKm >= cp.km - 0.0001 ? cp : null;
    }
    return null;
  }

  void _begin(StoryDef d, StoryRun r, Checkpoint cp) {
    r.openCp = cp.id;
    r.openScene = cp.start;
    r.awaiting = false;
    r.announced = false;
    if (cp.interactive) {
      _announce(d, r, cp);
    } else {
      _runAuto(d, r, cp);
    }
  }

  /// The log types a short heads-up; the player presses ENTER to begin.
  void _announce(StoryDef d, StoryRun r, Checkpoint cp) {
    r.announced = true;
    state.addLog('> STORY: ${cp.title}', LogKind.warning, pauseMs: 700, effect: () {
      if (state.mode != GameMode.exploring || book.activeRun != r || r.openCp != cp.id) {
        r.announced = false;
        return;
      }
      state.pending = () => _enter(d, r, cp, r.openScene.isEmpty ? cp.start : r.openScene);
      state.refresh();
    });
  }

  /// A quiet discovery: told in the narrative log, completed on the spot.
  void _runAuto(StoryDef d, StoryRun r, Checkpoint cp) {
    final sc = cp.sceneMap[cp.start];
    state.addLog('> STORY: ${cp.title}', LogKind.warning, notify: false, pauseMs: 600);
    if (sc != null) {
      r.flags.addAll(sc.flags);
      _say(sc.text(ctxFor(r)));
      _pay(r, '${d.id}:${cp.id}:${sc.id}', sc.reward);
    }
    _completeCheckpoint(d, r, cp);
    state.refresh();
  }

  // ---------------------------------------------------------------- scenes

  void _enter(StoryDef d, StoryRun r, Checkpoint cp, String sceneId) {
    final sc = cp.sceneMap[sceneId] ?? cp.sceneMap[cp.start];
    if (sc == null) {
      _completeCheckpoint(d, r, cp);
      return;
    }
    state.resetConsole();
    final s = EventSession(storySessionId(d.id, cp.id));
    s.scene = sc.id;
    state.event = s;
    state.mode = GameMode.event;
    r.openCp = cp.id;
    r.announced = false;
    _play(d, r, cp, sc);
    state.commit();
  }

  void _play(StoryDef d, StoryRun r, Checkpoint cp, Scene sc) {
    r.openScene = sc.id;
    final s = state.event;
    if (s != null) s.scene = sc.id;
    r.flags.addAll(sc.flags);
    final lines = sc.text(ctxFor(r));
    switch (sc.kind) {
      case SceneKind.choice:
        _say(lines);
        _pay(r, '${d.id}:${cp.id}:${sc.id}', sc.reward);
        state.refresh();
        break;
      case SceneKind.end:
        _say(lines);
        _pay(r, '${d.id}:${cp.id}:${sc.id}', sc.reward);
        _completeCheckpoint(d, r, cp);
        if (sc.ending != null) _completeStory(d, r, sc.ending!);
        final e = state.event;
        if (e != null) {
          e.finished = true;
          e.result = lines.isEmpty ? '' : lines.last;
        }
        state.refresh();
        break;
      case SceneKind.hack:
      case SceneKind.lock:
      case SceneKind.fight:
        _chain(d, r, cp, sc, lines);
        break;
    }
  }

  /// Hand over to the normal hacking, lockpicking or combat system. Its result
  /// comes back through [_onEncounterEnd].
  void _chain(StoryDef d, StoryRun r, Checkpoint cp, Scene sc, List<String> lines) {
    if (sc.kind == SceneKind.lock && state.lockpicks <= 0) {
      _say(lines);
      _say(const ['You have no lockpicks. You stand there with your hands full of intent and nothing else.']);
      final next = cp.sceneMap[sc.onFail];
      if (next != null) _play(d, r, cp, next);
      state.refresh();
      return;
    }
    _pay(r, '${d.id}:${cp.id}:${sc.id}', sc.reward);
    r.awaiting = true;
    state.event = null;
    state.mode = GameMode.exploring;
    if (sc.kind == SceneKind.fight) {
      combat.startEncounter(forced: sc.enemy);
      _say(lines); // lands on the fight's own console
    } else {
      // A hack or lock prompt hides its console until engaged, so the scene's
      // text goes in the narrative log, where it can't be missed.
      _say(lines);
      if (sc.kind == SceneKind.hack) {
        hacking.offerTerminal();
      } else {
        lockpicking.offerLock();
      }
    }
    state.refresh();
  }

  void _onEncounterEnd(String kind, String result) {
    final r = run;
    final d = def;
    if (r == null || d == null || !r.awaiting) return;
    final cp = checkpointOf(d, r.openCp);
    final sc = cp?.sceneMap[r.openScene];
    if (cp == null || sc == null) {
      r.awaiting = false;
      return;
    }
    final expect = sc.kind == SceneKind.hack
        ? 'hack'
        : sc.kind == SceneKind.lock
            ? 'lock'
            : sc.kind == SceneKind.fight
                ? 'fight'
                : '';
    if (expect != kind) return;
    r.awaiting = false;
    if (result == 'died') {
      // Death sends you home. The checkpoint stays open and starts over from
      // its first scene next time, so it can't be skipped or stuck.
      r.openScene = cp.start;
      return;
    }
    final next = (result == 'success' || result == 'won') ? sc.onWin : sc.onFail;
    // After the minigame's own wrap-up lines, so they land in the right log.
    Future.microtask(() => _afterChain(d, r, cp, next));
  }

  void _afterChain(StoryDef d, StoryRun r, Checkpoint cp, String? next) {
    if (book.activeRun != r || state.mode != GameMode.exploring) return;
    if (next == null || !cp.sceneMap.containsKey(next)) {
      _completeCheckpoint(d, r, cp);
      return;
    }
    _enter(d, r, cp, next);
  }

  List<Choice> _visible(Scene sc, StoryCtx ctx) =>
      [for (final c in sc.choices) if (c.show == null || c.show!(ctx)) c];

  bool _affordable(Choice c) =>
      state.scrap >= c.needScrap &&
      state.stimpacks >= c.needStim &&
      state.lockpicks >= c.needPick &&
      state.parts >= c.needParts;

  _Where? _where(EventSession s) {
    final ref = parseStorySession(s.id);
    if (ref == null) return null;
    final d = storyDefOrNull(ref.story);
    final r = book.runs[ref.story];
    if (d == null || r == null) return null;
    final cp = checkpointOf(d, ref.cp);
    final sc = cp?.sceneMap[s.scene];
    if (cp == null || sc == null) return null;
    return _Where(d, r, cp, sc);
  }

  List<EventOption> optionsFor(EventSession s) {
    if (s.finished) return const [];
    final w = _where(s);
    if (w == null) return const [];
    final ctx = ctxFor(w.run);
    return [for (final c in _visible(w.scene, ctx)) EventOption(c.label, _affordable(c))];
  }

  void choose(int i) {
    final s = state.event;
    if (s == null || s.finished) return;
    final w = _where(s);
    if (w == null) return;
    final vis = _visible(w.scene, ctxFor(w.run));
    if (i < 0 || i >= vis.length) return;
    final c = vis[i];
    if (!_affordable(c)) return;
    state.scrap -= c.needScrap;
    state.stimpacks -= c.needStim;
    state.lockpicks -= c.needPick;
    state.parts -= c.needParts;
    w.run.flags.addAll(c.flags);
    w.run.choices['${w.cp.id}.${w.scene.id}'] = c.label;
    state.addLog('> ${c.label.replaceAll('[', '').replaceAll(']', '')}', LogKind.system,
        notify: false, silent: true);
    final next = w.cp.sceneMap[c.next];
    if (next == null) {
      _completeCheckpoint(w.def, w.run, w.cp);
      s.finished = true;
      state.refresh();
    } else {
      _play(w.def, w.run, w.cp, next);
    }
    state.commit(); // the decision is saved the moment it is made
  }

  /// [CONTINUE] after a checkpoint scene: back out into the wasteland.
  void leave() {
    final s = state.event;
    if (s == null || !s.finished) return;
    final ref = parseStorySession(s.id);
    final d = ref == null ? null : storyDefOrNull(ref.story);
    final r = ref == null ? null : book.runs[ref.story];
    state.event = null;
    state.mode = GameMode.exploring;
    state.questEvent(QuestKind.events, 1);
    state.endEncounter();
    if (d != null && r != null && book.completed.containsKey(d.id)) {
      final end = d.endings[book.completed[d.id]];
      state.addLog('> STORY EXPEDITION COMPLETE: ${d.title}', LogKind.loot, notify: false);
      if (end != null) {
        state.addLog('> OUTCOME: ${end.title}', LogKind.system, notify: false);
      }
      state.addLog(
          'The job is done. You are still out in the wasteland, with the rest of the day ahead of you. Walk on, or head home.',
          LogKind.narrative);
    } else if (d != null && r != null && ref != null) {
      state.addLog('> CHECKPOINT ${r.done.length}/${d.checkpoints.length}: ${storyEventTitle(s.id)}',
          LogKind.system);
    }
    state.refresh();
    state.commit();
  }

  // ------------------------------------------------------------ completion

  void _completeCheckpoint(StoryDef d, StoryRun r, Checkpoint cp) {
    if (r.done.contains(cp.id)) return; // a checkpoint completes exactly once
    r.done.add(cp.id);
    r.openCp = null;
    r.openScene = '';
    r.awaiting = false;
    r.announced = false;
    final j = cp.journal(ctxFor(r)).join(' ');
    r.journal.add(JournalEntry(cp.id, cp.title, j));
    state.addLog('> CHECKPOINT ${r.done.length}/${d.checkpoints.length}: ${cp.title}',
        LogKind.system,
        notify: false, silent: true);
    _pay(r, '${d.id}:${cp.id}', cp.reward);
    state.commit();
  }

  void _completeStory(StoryDef d, StoryRun r, String endingId) {
    if (book.completed.containsKey(d.id)) return;
    final before = _availableIds();
    final end = d.endings[endingId] ?? d.endings.values.first;
    book.completed[d.id] = end.id;
    book.activeId = null;
    for (final f in r.flags) {
      if (f.startsWith('carry.')) book.world.add(f);
    }
    book.world.addAll(end.world);
    r.journal.add(JournalEntry('end', 'OUTCOME: ${end.title}', end.summary));
    state.addLog('> STORY EXPEDITION COMPLETE: ${d.title}', LogKind.loot, notify: false);
    state.addLog('> OUTCOME: ${end.title}', LogKind.system, notify: false);
    _pay(r, '${d.id}:complete', d.reward);
    _pay(r, '${d.id}:ending:${end.id}', end.bonus);
    for (final id in _availableIds()) {
      if (!before.contains(id)) {
        state.addLog('> NEW STORY EXPEDITION AVAILABLE: ${storyDefOrNull(id)?.title ?? id}',
            LogKind.warning,
            notify: false);
      }
    }
    state.commit();
  }

  Set<String> _availableIds() => {
        for (final s in storyCatalog)
          if (!book.completed.containsKey(s.id) && s.unlock.met(state.level, book)) s.id
      };

  /// Hands out a reward once, ever. Abandoning and restarting can't repay it.
  void _pay(StoryRun r, String key, Reward? rw) {
    if (rw == null || book.paid.contains(key)) return;
    book.paid.add(key);
    if (rw.hp < 0) {
      state.addLog('DAMAGE RECEIVED: ${-rw.hp}', LogKind.danger, notify: false);
      state.damage(-rw.hp);
    }
    if (rw.hp > 0) {
      final before = state.hp;
      state.hp = min(state.maxHp, state.hp + rw.hp);
      if (state.hp > before) {
        state.addLog('> HP +${state.hp - before}', LogKind.loot, notify: false);
      }
    }
    if (rw.scrap > 0) {
      final n = state.withBench(rw.scrap);
      state.addLog('+ $n SCRAP', LogKind.loot, notify: false);
      state.addScrap(n);
    }
    if (rw.stims > 0) {
      state.stimpacks += rw.stims;
      state.addLog('+ ${rw.stims} STIMPACK', LogKind.loot, notify: false);
    }
    if (rw.picks > 0) {
      state.lockpicks += rw.picks;
      state.addLog('+ ${rw.picks} LOCKPICK', LogKind.loot, notify: false);
    }
    if (rw.parts > 0) {
      state.parts += rw.parts;
      state.addLog('+ ${rw.parts} PARTS', LogKind.loot, notify: false);
    }
    final g = rw.gearId;
    if (g != null && !state.owned.contains(g)) {
      state.owned.add(g);
      state.addLog('> UNIQUE ITEM FOUND: $g', LogKind.loot, notify: false);
    }
    if (rw.xp > 0) state.gainXp(rw.xp);
    state.refresh();
  }

  // ----------------------------------------------------------------- text

  void _say(List<String> lines) {
    for (final raw in lines) {
      final l = _parse(raw);
      state.addLog(l.text, l.kind, notify: false, pauseMs: l.pauseMs);
    }
  }

  StoryLine _parse(String raw) {
    var t = raw;
    int? pause;
    if (t.length > 1 && t.endsWith('|')) {
      t = t.substring(0, t.length - 1);
      pause = 1800;
    }
    if (t.length > 1) {
      switch (t[0]) {
        case '~':
          return StoryLine(t.substring(1), LogKind.thought, pause);
        case '#':
          return StoryLine(t.substring(1), LogKind.system, pause);
        case '!':
          return StoryLine(t.substring(1), LogKind.danger, pause);
        case '%':
          return StoryLine(t.substring(1), LogKind.warning, pause);
      }
    }
    return StoryLine(t, LogKind.narrative, pause);
  }

  /// A line of ambient story flavour for the walk, or null. Callers keep a list
  /// of recent lines so nothing repeats.
  StoryLine? ambient(Random rng, List<String> recent) {
    final r = run;
    final d = def;
    if (r == null || d == null) return null;
    final ctx = ctxFor(r);
    final pool = [
      for (final a in d.ambient)
        if (ctx.km >= a.minKm &&
            ctx.km <= a.maxKm &&
            (a.when == null || a.when!(ctx)) &&
            !recent.contains(a.text))
          a
    ];
    if (pool.isEmpty) return null;
    final a = pool[rng.nextInt(pool.length)];
    recent.add(a.text);
    if (recent.length > 30) recent.removeAt(0);
    return _parse(a.text);
  }
}
