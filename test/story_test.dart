import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wasteland_terminal/game/combat_system.dart';
import 'package:wasteland_terminal/game/game_state.dart';
import 'package:wasteland_terminal/game/hacking_system.dart';
import 'package:wasteland_terminal/game/lockpicking_system.dart';
import 'package:wasteland_terminal/game/quests.dart';
import 'package:wasteland_terminal/game/story_content.dart';
import 'package:wasteland_terminal/game/story_model.dart';
import 'package:wasteland_terminal/game/story_system.dart';

class Rig {
  final GameState state = GameState();
  late final HackingSystem hacking = HackingSystem(state);
  late final LockpickingSystem lock = LockpickingSystem(state);
  late final CombatSystem combat = CombatSystem(state);
  late final StorySystem story = StorySystem(state, hacking, lock, combat);
  int saves = 0;

  Rig() {
    story; // wires the encounter-end hook
    state.onCommit = () => saves++;
  }

  StoryRun get run => state.story.activeRun!;

  /// Walk (as the exploration tick does) until the next checkpoint takes over.
  void walkToNextCheckpoint() {
    var guard = 0;
    while (!story.poll(settled: true)) {
      state.advance(0.01);
      expect(guard++ < 5000, isTrue, reason: 'walked 50 km without meeting a checkpoint');
    }
  }

  /// Finishes a minigame/fight the way the real systems do.
  Future<void> endMinigame(String result) async {
    final kind = state.mode == GameMode.hacking
        ? 'hack'
        : state.mode == GameMode.lockpicking
            ? 'lock'
            : 'fight';
    state.mode = GameMode.exploring;
    state.onEncounterEnd?.call(kind, result);
    await Future<void>.delayed(Duration.zero); // the story continues on a microtask
  }

  /// Plays a whole story. [win]: minigames succeed. [last]: always take the
  /// last enabled option instead of the first.
  Future<void> play(String id, {required bool win, required bool last}) async {
    expect(story.accept(id), isTrue, reason: 'could not accept $id');
    state.beginExpedition();
    var guard = 0;
    while (state.story.activeId == id) {
      expect(guard++ < 8000, isTrue, reason: 'story $id never finished');
      if (state.mode == GameMode.exploring) {
        if (story.poll(settled: true)) {
          if (state.pending != null) state.acknowledgeEncounter();
        } else {
          state.advance(0.05);
        }
      } else if (state.mode == GameMode.event) {
        final ev = state.event!;
        if (ev.finished) {
          story.leave();
        } else {
          final opts = story.optionsFor(ev);
          final ok = [for (var i = 0; i < opts.length; i++) if (opts[i].enabled) i];
          expect(ok, isNotEmpty, reason: 'dead end in $id at ${ev.id}/${ev.scene}');
          story.choose(last ? ok.last : ok.first);
        }
      } else {
        final fight = state.mode == GameMode.combat;
        await endMinigame(win ? (fight ? 'won' : 'success') : (fight ? 'fled' : 'failed'));
      }
    }
    // the final scene waits for [CONTINUE]
    if (state.mode == GameMode.event && state.event?.finished == true) story.leave();
  }
}

StoryCtx _ctx([Set<String> flags = const {}]) {
  final run = StoryRun('t')..flags.addAll(flags);
  return StoryCtx(
    run: run,
    book: StoryBook(),
    level: 1,
    km: 0,
    hp: 100,
    maxHp: 100,
    scrap: 0,
    region: 'DUSTY HIGHWAY',
    skills: const {},
    quests: const {},
  );
}

void main() {
  group('story content', () {
    for (final d in storyCatalog) {
      test('${d.id}: structure is sound', () {
        expect(d.checkpoints.length, greaterThanOrEqualTo(5));
        final ids = d.checkpoints.map((c) => c.id).toSet();
        expect(ids.length, d.checkpoints.length, reason: 'duplicate checkpoint id');
        var last = 0.0;
        for (final cp in d.checkpoints) {
          expect(cp.km, greaterThan(last), reason: '${cp.id} must be further than the one before');
          last = cp.km;
        }
        expect(d.checkpoints.last.km, d.destinationKm);
        expect(d.endings, isNotEmpty);

        final endingsUsed = <String>{};
        for (final cp in d.checkpoints) {
          expect(cp.sceneMap.containsKey(cp.start), isTrue, reason: '${cp.id} start');
          final reach = <String>{};
          final stack = [cp.start];
          while (stack.isNotEmpty) {
            final id = stack.removeLast();
            if (!reach.add(id)) continue;
            final sc = cp.sceneMap[id];
            expect(sc, isNotNull, reason: '${cp.id}: missing scene $id');
            if (sc == null) continue;
            if (sc.ending != null) {
              endingsUsed.add(sc.ending!);
              expect(d.endings.containsKey(sc.ending), isTrue, reason: 'unknown ending ${sc.ending}');
              expect(cp, d.checkpoints.last, reason: 'only the final checkpoint may end the story');
            }
            switch (sc.kind) {
              case SceneKind.choice:
                expect(sc.choices, isNotEmpty, reason: '${cp.id}/$id has no choices');
                for (final c in sc.choices) {
                  stack.add(c.next);
                }
              case SceneKind.end:
                break;
              case SceneKind.hack:
              case SceneKind.lock:
              case SceneKind.fight:
                expect(sc.onWin, isNotNull);
                expect(sc.onFail, isNotNull);
                stack.add(sc.onWin!);
                stack.add(sc.onFail!);
            }
          }
          // every scene can be reached, and every scene can reach an end
          expect(reach.length, cp.sceneMap.length, reason: '${cp.id} has unreachable scenes');
          bool reachesEnd(String from, Set<String> seen) {
            if (!seen.add(from)) return false;
            final sc = cp.sceneMap[from]!;
            if (sc.kind == SceneKind.end) return true;
            final next = sc.kind == SceneKind.choice
                ? sc.choices.map((c) => c.next)
                : [sc.onWin!, sc.onFail!];
            return next.any((n) => reachesEnd(n, seen));
          }

          for (final id in cp.sceneMap.keys) {
            expect(reachesEnd(id, {}), isTrue, reason: '${cp.id}/$id cannot reach an end');
          }
        }
        expect(endingsUsed, d.endings.keys.toSet(), reason: 'every ending must be reachable');
      });

      test('${d.id}: all text builds and is well formed', () {
        final plain = _ctx();
        final busy = _ctx({
          'drank', 'declined', 'violence', 'toldines', 'logbook', 'has_cone', 'knocked',
          'broke_in', 'damaged', 'heard_reply', 'seen.ines', 'seen.why', 'smashed', 'walked',
        });
        for (final ctx in [plain, busy]) {
          void check(List<String> lines) {
            for (final l in lines) {
              expect(l.trim(), isNotEmpty);
              expect(l.contains("'"), isFalse, reason: 'straight apostrophe in: $l');
            }
          }

          check(d.depart(ctx));
          for (final cp in d.checkpoints) {
            check(cp.journal(ctx));
            for (final sc in cp.sceneMap.values) {
              check(sc.text(ctx));
              for (final c in sc.choices) {
                expect(c.label, startsWith('['));
                expect(c.label.length, lessThan(46), reason: 'button too wide: ${c.label}');
              }
              expect(sc.choices.length, lessThanOrEqualTo(4), reason: '${cp.id}/${sc.id}: the choice grid holds 4');
            }
          }
        }
        expect(d.ambient.length, greaterThanOrEqualTo(10));
        for (final a in d.ambient) {
          expect(a.text.trim(), isNotEmpty);
        }
      });
    }

    test('unlock requirements point at real stories', () {
      for (final d in storyCatalog) {
        for (final id in [...d.unlock.allDone, ...d.unlock.anyDone]) {
          expect(storyDefOrNull(id), isNotNull);
        }
      }
      expect(storyCatalog.map((d) => d.id).toSet().length, storyCatalog.length);
    });
  });

  group('persistence', () {
    test('story book survives a JSON round trip', () {
      final b = StoryBook();
      final r = StoryRun('caravan')
        ..km = 3.7
        ..done.add('wheel')
        ..flags.add('drank')
        ..choices['toll.a'] = '[TAKE THE FLASK]'
        ..journal.add(const JournalEntry('wheel', 'THE WHEEL', 'text'))
        ..openCp = 'camp'
        ..openScene = 'ledger'
        ..awaiting = true;
      b.runs['caravan'] = r;
      b.activeId = 'caravan';
      b.completed['transmission'] = 'truth';
      b.world.add('x');
      b.paid.add('caravan:wheel');
      b.farthest = 9.5;
      final copy = StoryBook.fromJson(jsonDecode(jsonEncode(b.toJson())) as Map<String, dynamic>);
      final c = copy.activeRun!;
      expect(c.km, 3.7);
      expect(c.done, {'wheel'});
      expect(c.flags, {'drank'});
      expect(c.choices['toll.a'], '[TAKE THE FLASK]');
      expect(c.journal.single.title, 'THE WHEEL');
      expect(c.openCp, 'camp');
      expect(c.openScene, 'ledger');
      expect(c.awaiting, isTrue);
      expect(copy.completed['transmission'], 'truth');
      expect(copy.world, {'x'});
      expect(copy.paid, {'caravan:wheel'});
      expect(copy.farthest, 9.5);
    });

    test('an old save without a story section loads untouched', () {
      final a = Rig();
      a.state.distanceKm = 0;
      a.state.scrap = 123;
      final json = jsonDecode(jsonEncode(a.state.toJson())) as Map<String, dynamic>;
      expect(json.containsKey('story'), isTrue);
      json.remove('story'); // what a save from before this feature looks like
      final b = Rig();
      b.state.loadJson(json);
      expect(b.state.scrap, 123);
      expect(b.state.story.activeId, isNull);
      expect(b.state.story.runs, isEmpty);
      expect(b.story.statusOf(storyDefOrNull('caravan')!), StoryStatus.available);
    });

    test('a damaged story section never costs the rest of the save', () {
      final a = Rig();
      a.state.scrap = 77;
      final json = jsonDecode(jsonEncode(a.state.toJson())) as Map<String, dynamic>;
      json['story'] = {'runs': 'garbage'};
      final b = Rig();
      b.state.loadJson(json);
      expect(b.state.scrap, 77);
      expect(b.state.story.activeId, isNull);
    });

    test('a story that no longer exists is dropped on load', () {
      final a = Rig();
      a.state.story.runs['ghost'] = StoryRun('ghost');
      a.state.story.activeId = 'ghost';
      final json = jsonDecode(jsonEncode(a.state.toJson())) as Map<String, dynamic>;
      final b = Rig();
      b.state.loadJson(json);
      expect(b.state.story.activeId, isNull);
    });
  });

  group('persistent distance', () {
    test('without a story, a departure starts from 0 km as before', () {
      final r = Rig();
      r.state.distanceKm = 7.4; // left over from a previous outing
      r.state.beginExpedition();
      expect(r.state.distanceKm, 0);
      expect(r.state.region, 'DUSTY HIGHWAY');
    });

    test('returning home pauses; departing resumes at exactly the same distance', () {
      final r = Rig();
      expect(r.story.accept('caravan'), isTrue);
      r.state.beginExpedition();
      expect(r.state.distanceKm, 0);
      r.walkToNextCheckpoint(); // wheel: an automatic discovery
      r.walkToNextCheckpoint(); // camp: waits for ENTER
      final km = r.state.distanceKm;
      expect(km, closeTo(3.1, 0.02));
      r.state.arriveHome();
      expect(r.state.mode, GameMode.home);
      expect(r.run.km, km);
      expect(r.run.done, {'wheel'});
      r.state.scrap += 50; // normal safehouse life carries on
      r.state.beginExpedition();
      expect(r.state.distanceKm, km, reason: 'resume must not reset distance');
      expect(r.state.region, 'DUSTY HIGHWAY');
    });

    test('the saved distance also survives closing the game', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint();
      r.state.advance(0.5);
      final km = r.state.distanceKm;
      final json = jsonDecode(jsonEncode(r.state.toJson())) as Map<String, dynamic>;

      // closed while out in the wasteland
      final out = Rig()..state.loadJson(json);
      expect(out.state.distanceKm, km);
      expect(out.run.km, km);

      // closed while at the safehouse
      r.state.arriveHome();
      final home = jsonDecode(jsonEncode(r.state.toJson())) as Map<String, dynamic>;
      final b = Rig()..state.loadJson(home);
      expect(b.state.mode, GameMode.home);
      expect(b.state.distanceKm, km);
      b.state.beginExpedition();
      expect(b.state.distanceKm, km);
    });

    test('distance-based systems read the same distance while a story is active', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.state.advance(1.0);
      expect(r.run.km, r.state.distanceKm);
      r.state.arriveHome();
      r.state.beginExpedition();
      r.state.advance(0.25);
      expect(r.run.km, r.state.distanceKm);
    });
  });

  group('checkpoints', () {
    test('travel stops at a checkpoint and it can only complete once', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint();
      expect(r.run.done, {'wheel'}); // automatic: told in the log, done on the spot
      expect(r.run.journal.length, 1);
      final km = r.state.distanceKm;
      for (var i = 0; i < 20; i++) {
        expect(r.story.poll(settled: true), isFalse);
      }
      expect(r.run.done, {'wheel'}, reason: 'never triggers twice');
      expect(r.run.journal.length, 1);
      expect(r.state.distanceKm, km);
    });

    test('an interactive checkpoint blocks walking until it is resolved', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint(); // wheel
      r.walkToNextCheckpoint(); // camp announced
      expect(r.state.pending, isNotNull);
      expect(r.run.openCp, 'camp');
      final km = r.state.distanceKm;
      // exploration is held while it is unresolved, and it is not announced twice
      for (var i = 0; i < 10; i++) {
        expect(r.story.poll(settled: true), isTrue);
      }
      expect(r.state.distanceKm, km);
      r.state.acknowledgeEncounter();
      expect(r.state.mode, GameMode.event);
      expect(r.state.event!.id, 'story:caravan:camp');
      expect(r.story.optionsFor(r.state.event!), isNotEmpty);
    });

    test('a checkpoint cannot be skipped by going home and coming back', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint();
      r.walkToNextCheckpoint(); // camp announced, not yet entered
      r.state.arriveHome();
      r.state.beginExpedition();
      expect(r.story.poll(settled: true), isTrue); // offered again
      expect(r.state.pending, isNotNull);
      r.state.acknowledgeEncounter();
      expect(r.state.event!.scene, 'a');
    });

    test('decisions and flags are saved the moment they are made', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint();
      r.walkToNextCheckpoint();
      r.state.acknowledgeEncounter();
      final before = r.saves;
      final opts = r.story.optionsFor(r.state.event!);
      final i = opts.indexWhere((o) => o.label.contains('LEDGER'));
      r.story.choose(i);
      expect(r.saves, greaterThan(before));
      expect(r.run.flags, contains('seen.ledger'));
      expect(r.run.choices['camp.a'], '[CHECK THE LEDGER]');
    });

    test('saving mid-checkpoint and reloading resumes the same scene exactly once', () async {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint();
      r.walkToNextCheckpoint();
      r.state.acknowledgeEncounter();
      r.story.choose(r.story.optionsFor(r.state.event!).indexWhere((o) => o.label.contains('LEDGER')));
      final json = jsonDecode(jsonEncode(r.state.toJson())) as Map<String, dynamic>;

      final b = Rig()..state.loadJson(json);
      expect(b.state.mode, GameMode.event);
      expect(b.state.event!.scene, 'ledger');
      expect(b.run.openCp, 'camp');
      final labels = b.story.optionsFor(b.state.event!).map((o) => o.label).toList();
      expect(labels, contains('[MOVE ON]'));
      b.story.choose(labels.indexOf('[MOVE ON]'));
      expect(b.state.event!.finished, isTrue);
      expect(b.run.done, {'wheel', 'camp'});
      expect(b.run.openCp, isNull);
      b.story.leave();
      expect(b.state.mode, GameMode.exploring);
      expect(b.story.poll(settled: true), isFalse);
      expect(b.run.done.length, 2);
    });

    test('a scene minigame hands its result back to the story', () async {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint();
      r.walkToNextCheckpoint();
      r.state.acknowledgeEncounter();
      int idx(String part) =>
          r.story.optionsFor(r.state.event!).indexWhere((o) => o.label.contains(part));
      r.story.choose(idx('CASH WAGON'));
      r.story.choose(idx('PICK THE PADLOCK'));
      expect(r.state.mode, GameMode.lockpicking);
      expect(r.run.awaiting, isTrue);

      // closed and reopened in the middle of the lock
      final json = jsonDecode(jsonEncode(r.state.toJson())) as Map<String, dynamic>;
      final b = Rig()..state.loadJson(json);
      expect(b.state.mode, GameMode.lockpicking);
      expect(b.run.awaiting, isTrue);
      await b.endMinigame('success');
      expect(b.state.mode, GameMode.event);
      expect(b.state.event!.scene, 'wagon_ok');
      expect(b.run.flags, contains('opened'));
    });

    test('with no lockpicks a lock scene falls through to its failure branch', () {
      final r = Rig();
      r.state.lockpicks = 0;
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint();
      r.walkToNextCheckpoint();
      r.state.acknowledgeEncounter();
      int idx(String part) =>
          r.story.optionsFor(r.state.event!).indexWhere((o) => o.label.contains(part));
      r.story.choose(idx('CASH WAGON'));
      r.story.choose(idx('PICK THE PADLOCK'));
      expect(r.state.mode, GameMode.event);
      expect(r.state.event!.scene, 'wagon_no');
    });

    test('dying in a checkpoint fight pauses the story and restarts that checkpoint', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      for (var i = 0; i < 3; i++) {
        r.walkToNextCheckpoint(); // wheel, camp (waits), toll
        if (r.state.pending != null) {
          r.state.acknowledgeEncounter();
          int idx(String part) =>
              r.story.optionsFor(r.state.event!).indexWhere((o) => o.label.contains(part));
          if (r.run.openCp == 'camp') {
            r.story.choose(idx('MOVE ON'));
            r.story.leave();
          }
        }
      }
      expect(r.run.openCp, 'toll');
      expect(r.state.event!.scene, 'a');
      final km = r.state.distanceKm;
      r.story.choose(r.story.optionsFor(r.state.event!).indexWhere((o) => o.label.contains('SHOVE')));
      expect(r.state.mode, GameMode.combat);
      expect(r.run.awaiting, isTrue);
      // what CombatSystem.leave does on defeat
      r.state.arriveHome();
      r.state.endEncounter();
      r.state.onEncounterEnd?.call('fight', 'died');
      expect(r.state.mode, GameMode.home);
      expect(r.run.km, km);
      expect(r.run.awaiting, isFalse);
      expect(r.run.openCp, 'toll');
      expect(r.run.openScene, 'a');
      expect(r.run.done, isNot(contains('toll')));
      r.state.beginExpedition();
      expect(r.state.distanceKm, km);
      expect(r.story.poll(settled: true), isTrue);
      r.state.acknowledgeEncounter();
      expect(r.state.event!.scene, 'a');
    });
  });

  group('selection, rewards and unlocks', () {
    test('only one story can be active, and the other can only start after', () {
      final r = Rig();
      expect(r.story.accept('caravan'), isTrue);
      expect(r.story.accept('transmission'), isFalse);
      expect(r.state.story.activeId, 'caravan');
    });

    test('can only accept or abandon at the safehouse', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      expect(r.story.abandon(), isFalse);
      expect(r.story.accept('transmission'), isFalse);
    });

    test('abandoning erases the run but never repays rewards', () {
      final r = Rig();
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.walkToNextCheckpoint(); // wheel pays XP once
      expect(r.state.story.paid, contains('caravan:wheel'));
      final lvl = r.state.level, xp = r.state.xp;
      r.state.arriveHome();
      expect(r.story.abandon(), isTrue);
      expect(r.state.story.activeId, isNull);
      expect(r.state.story.runs.containsKey('caravan'), isFalse);
      expect(r.story.accept('caravan'), isTrue);
      expect(r.run.km, 0);
      expect(r.run.done, isEmpty);
      r.state.beginExpedition();
      expect(r.state.distanceKm, 0);
      r.walkToNextCheckpoint();
      expect(r.run.done, {'wheel'});
      expect(r.state.level, lvl);
      expect(r.state.xp, xp, reason: 'the checkpoint XP is paid once only');
    });

    test('the third story is locked until level 4 and another story is done', () {
      final r = Rig();
      final d = storyDefOrNull('below')!;
      expect(r.story.statusOf(d), StoryStatus.locked);
      r.state.level = 4;
      expect(r.story.statusOf(d), StoryStatus.locked);
      r.state.story.completed['caravan'] = 'left';
      expect(r.story.statusOf(d), StoryStatus.available);
      r.state.level = 3;
      expect(r.story.statusOf(d), StoryStatus.locked);
    });

    test('existing contracts keep tracking while a story is active', () {
      final r = Rig();
      r.state.acceptQuest('longroad');
      r.story.accept('caravan');
      r.state.beginExpedition();
      r.state.questEvent(QuestKind.distance, 5, absolute: true);
      expect(r.state.quests.single.ready, isTrue);
      r.state.arriveHome();
      r.state.claimQuest('longroad');
      expect(r.state.quests, isEmpty);
      expect(r.state.story.activeId, 'caravan');
    });
  });

  group('every story can be completed', () {
    for (final d in storyCatalog) {
      for (final win in [true, false]) {
        for (final last in [true, false]) {
          test('${d.id} (minigames ${win ? 'won' : 'lost'}, ${last ? 'last' : 'first'} options)',
              () async {
            // the failing strategy with "first" options retries fights forever by
            // design (you may always try again), so it is not a completion path.
            if (!win && !last) return;
            final r = Rig();
            r.state.level = 6;
            r.state.stimpacks = 20;
            r.state.parts = 20;
            r.state.scrap = 500;
            r.state.story.completed['caravan'] = 'left'; // unlocks the third story
            if (d.id == 'caravan') r.state.story.completed.clear();
            await r.play(d.id, win: win, last: last);
            expect(r.state.story.completed.containsKey(d.id), isTrue);
            expect(r.state.story.activeId, isNull);
            final run = r.state.story.runs[d.id]!;
            expect(run.done.length, d.checkpoints.length);
            expect(run.journal.last.cp, 'end');
            expect(d.endings.containsKey(r.state.story.completed[d.id]), isTrue);
            expect(r.state.story.paid, contains('${d.id}:complete'));
            // a finished story is never active again and cannot be restarted
            expect(r.story.statusOf(d), StoryStatus.completed);
            expect(r.story.accept(d.id), isFalse);
          });
        }
      }
    }

    test('the same story gives different outcomes for different decisions', () async {
      final endings = <String>{};
      for (final last in [true, false]) {
        final r = Rig();
        r.state.level = 6;
        await r.play('caravan', win: true, last: last);
        endings.add(r.state.story.completed['caravan']!);
      }
      expect(endings.length, 2);
    });

    test('finishing a story carries what it learned into later ones', () async {
      final r = Rig();
      r.state.level = 6;
      await r.play('transmission', win: true, last: false);
      expect(r.state.story.world, isNotEmpty);
      expect(r.story.statusOf(storyDefOrNull('below')!), StoryStatus.available);
    });

    test('after completing, free exploring continues from where you are', () async {
      final r = Rig();
      r.state.level = 6;
      await r.play('caravan', win: true, last: true);
      expect(r.state.mode, GameMode.exploring);
      expect(r.story.poll(settled: true), isFalse); // nothing holds the walk
      final km = r.state.distanceKm;
      r.state.arriveHome();
      r.state.beginExpedition(); // ordinary departure: starts from 0 again
      expect(r.state.distanceKm, 0);
      expect(km, greaterThan(7));
    });
  });
}
