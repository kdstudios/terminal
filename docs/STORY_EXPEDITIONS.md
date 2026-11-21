# Story Expeditions

Three separate things, deliberately kept apart:

| Concept | What it is | Where |
|---|---|---|
| **Depart on Expedition** | The existing action that walks you into the wasteland | `HomeSystem.depart`, `ExplorationSystem` |
| **Contracts / quests** | Existing objectives and rewards | `quests.dart`, quest board |
| **Story Expeditions** | Persistent, story-driven journeys that ride on the walk | `story_*.dart`, `stories/`, `ui/story_view.dart` |

## How distance works

`GameState.distanceKm` is still the **only** live distance; every system (scaling, rewards, regions,
terminals, locks, contracts, flavour) keeps reading it.

* `beginExpedition()` — with an active story, restores `distanceKm` from the story run instead of
  resetting to 0. Without one it behaves exactly as before.
* `advance()` mirrors the distance into the active `StoryRun.km`.
* `arriveHome()` snapshots it (`StoryBook.pauseAt`). Returning home *pauses*, never abandons.
* `loadJson()` reconciles: out in the wasteland the saved live value wins; at home the story's
  remembered distance is shown.

## Checkpoints

`ExplorationSystem._tick` calls `StorySystem.poll()` before advancing. When the next checkpoint's km is
reached, walking and random events stop until it is resolved.

* **Auto** checkpoints (`Checkpoint.auto`) are told in the narrative log and completed on the spot.
* **Interactive** checkpoints print `> STORY: TITLE`, wait for ENTER, then run a small scene graph on the
  existing choice-encounter screen. Scenes can hand off to the normal hacking, lockpicking and combat
  systems (`Scene.hack/lock/fight`); the result returns through `GameState.onEncounterEnd`.
* A checkpoint completes exactly once (`StoryRun.done`), then the game is saved immediately
  (`GameState.commit`). Unfinished checkpoints are re-offered after a reload, going home or dying.
* Rewards are paid once ever (`StoryBook.paid`), so abandon-and-restart cannot farm them.

## Save format

`GameState.toJson()['story']` (`StoryBook`). It is optional on load, so old saves work unchanged;
a damaged section is ignored without losing the rest of the save. Scene sessions are normal
`EventSession`s with id `story:<story>:<checkpoint>` and a `scene` field.

## Adding a story

1. Write a `StoryDef` in `lib/game/stories/` (see `caravan.dart` for the shortest example).
2. Add it to `storyCatalog` in `story_content.dart`.
3. `flutter test test/story_test.dart` checks structure (reachability, ends, option count, text) and
   plays every story to completion.

Text prefixes: none = narration, `~` thought, `#` radio/terminal, `!` danger, `%` warning,
trailing `|` = long pause. Use curly quotes (`’ “ ”`), never a straight `'`, inside Dart strings.
Keep at most 4 visible choices per scene (the encounter screen shows a 2x2 grid).

## The story library (0.7.0)

Every story is one Dart file; open it and edit the scenes in place.

```text
lib/game/stories/
  transmission.dart caravan.dart below.dart     the original three
  story_kit.dart                                 skillChoice / skillSplit / known (thin Choice helpers)
  major/        14 long expeditions (+ the three above)
  medium/       checkout.dart, shadow.dart       StoryScale.medium (3+ checkpoints)
  encounters/   short stories, recurring-character stories and follow-ups  (StoryScale.short)
  characters/   reusable character helpers that read the world state
```

**Scale.** `scale: StoryScale.short` (default is `major`). Minimums: major 5 checkpoints / 10 ambient lines, medium 3 / 6, short 1 / 3.
The last checkpoint must sit at `destinationKm`; only it may contain `ending:` scenes.

**Continuity.** An ending's `world:` list is remembered forever. A scene or choice flag that starts with `carry.` is also saved
when the story is completed. Read facts with `c.world('x')`, `c.ending('storyId')`, or `known(c, 'x')` (matches `x` and `carry.x`).
Characters in `characters/` turn those facts into dialogue, e.g. `BrotherPositive.greeting(c)`, `Gary.mood(c)`, `Accountant.ledger(c)`.

**Rules of thumb** (the tests enforce most of them):
- At most 4 choices in a scene. A choice grid that can never be empty needs one always-visible option.
- Every cycle (hub loops, "back" options) must contain a choice hidden by a `show:` flag so it is one-shot. The test harness plays the
  first and last option every time and will otherwise loop forever.
- Straight apostrophes are forbidden in text (use the curly one); do not use `$` in text.
- Do not make stories depend on one another. Use `Unlock(anyDone: ['id'])` only for true follow-ups.
