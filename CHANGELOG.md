# Changelog

VERSIONING RULE: every time anything is changed, bump `kVersion` in `lib/version.dart`
(and `version:` in pubspec.yaml) and add an entry here. The version is shown on the title screen.

## 0.7.0
- COMPLETE WASTELAND STORY LIBRARY: 39 new playable stories on top of the existing three (42 total), each in its own editable
  Dart file under `lib/game/stories/` (`major/`, `medium/`, `encounters/`, `characters/`), all registered in
  `story_content.dart`. No new dialogue or choice system: everything is ordinary `Scene` / `Choice` / `Checkpoint` data.
  - 14 new MAJOR expeditions: The Church of the Eternal Battery (5 endings), The Manufactured Man (5 endings), The Great Water
    Heist, The Radio That Knows Your Name, The People's Republic of Nowhere, The Perfect Neighbourhood, The Great Wasteland
    Bake-Off, Project: Big Brother, The Travelling Salesman, The Sleeping Giant, The Man in the Moon, Operation: Freezer Burn,
    The Wasteland Wedding, and the original comedy THE GARYS (7 endings).
  - 2 MEDIUM stories: The Last Employee (Mr. Checkout, 5 endings) and The Man Who Sold His Shadow.
  - 13 SHORT encounters: Gary's Problem, The Toll Collector, The Invisible Man, The Chicken King, The World's Worst Doctor,
    The Time Traveller, The Weapon Inspector, The Haunted Toilet, The Retirement Home, The Lottery, The Last Radio DJ,
    The Mushroom Man, The Extremely Dangerous Box.
  - Character encounters: Murray the Magnificent, Grandma Grim, Mr. Huggins (The Grand Meridian), The Accountant, Frequency Frank.
  - Follow-ups that unlock after the original: Brother Positive and Dave, Gary's Other Problem, Mr. Checkout's urgent request,
    A Very Confused Gary, The Lumen Press Revisited.
- RECURRING CHARACTERS (`stories/characters/`): Brother Positive (+ Dave), Gary, Mr. Checkout, Murray, Grandma Grim,
  Mr. Huggins, The Accountant, Frequency Frank, Doctor Bones. Each reads the persistent world state and greets you differently
  depending on what you did. The Accountant builds a ledger from debts, favours and endings left by other stories.
- CROSS-STORY CONTINUITY: endings leave `world` facts; flags starting `carry.` are promoted on completion. `known(c, fact)`
  finds either. Every story still works alone and in any order; only the five follow-ups (and Grandma Grim's visit) unlock after
  another story.
- ENGINE: `StoryDef.scale` (`StoryScale.major / medium / short`). Major expeditions keep the five-checkpoint rule; medium need three,
  short encounters one. The selection screen lists major, then medium, then short, with a scale tag. Small helper file
  `stories/story_kit.dart` (`skillChoice`, `skillSplit`, `known`) only builds ordinary `Choice` objects.
- TESTS: structure tests are scale-aware and unlock-aware; new tests cover the library count, independence, follow-up locking,
  character reactions, the Accountant's ledger, Frequency Frank's reference to The Last Transmission, and the Garys jumpsuit rule.
- Stories at level 3-4 (Manufactured Man, Perfect Neighbourhood, Freezer Burn, Big Brother, Sleeping Giant) have a minimum level.

## 0.6.0
- EXPLORATION SCENERY OVERHAUL. All scenery (skyline, roadside props, ground, clutter) now comes from the new categorised
  sprite folders, packed into one atlas `assets/atlas/scenery.png/json` by `tools/pack_scenery.py` (564 sprites: buildings
  split tan / mossy-green and by kind - blocks, low ruins, spires, landmarks, roadside; trees; rocks; props; vehicles;
  suburban houses; bunkers; ground strips). The old world_a / world_b / derived atlases stay: the dweller rig, combat troopers,
  clouds, ridges and the minigames still use them and are untouched.
- RANDOM FLIP: every scenery sprite has a 50% chance (`WastelandScenePainter.kFlipChance`) of being mirrored. The choice is
  seeded per chunk, so it is stable on every pass. Sprites with lettering (signs, billboards, diner / gas / motel) are marked
  `flip: false` in the atlas and are never mirrored.
- Neighbouring sprites no longer pile on top of each other (per-layer overlap limit); region themes were rewritten around the
  new pools (e.g. Suburbs = houses + forest, Graveyard = bunkers + wrecks, Basin = cacti, bones and bleached ruins).
- The title screen and combat backdrops use the same scene painter, so they pick up the new scenery too.
- scenery.png is stored as a 256-colour PNG (~2 MB instead of ~10 MB) to keep the web build light.

## 0.5.1
- BRIGHTNESS: the status bar and the combat action box were darker than the rest because the CRT vignette was sized by
  the panel's SHORTEST side (so a short wide bar or a tall narrow strip sat in full darkness). The vignette now scales to
  each panel's own shape. Secondary text uses a new brighter `T.label` colour everywhere (T.dim is now for borders only),
  and disabled buttons dim their own colour instead of going dark grey.
- WALK: both legs now use the same source leg (the old pair differed: one was a trailing leg with a different foot, which
  read as a limp). Left and right are now identical, drawn with the far leg slightly dimmer.
- COMBAT SYNC: the animation's impact now lands exactly as the damage number finishes typing in the encounter log.
  Log lines can carry an `onStart` hook + `impactMs`; the typewriter tells the stage when to start (or holds the line back).
  The DAMAGE DEALT / DAMAGE RECEIVED line now comes first, then the flavour text. Every animation is tied to its own line.

## 0.5.0
- Combat sound and feel. 11 new synthesized sound effects (tools/gen_audio.py): whoosh, thud, slash, gunshot, plasma,
  crit, block, heal, death, charge, brace. They are played from the combat stage's animation timeline, so every
  sound lands on its visual: swing whoosh at the wind-up's end, impact at the strike, gunshot with the muzzle flash,
  plasma zap for the cutter, a clang when you block, a rising tone when an enemy charges, a death rumble.
- Hit-stop: heavy and critical hits (yours and theirs) freeze the stage for ~70-90 ms.
- Haptics on impacts (medium; heavy for crits, heavy attacks and kills; light for shots and heals).
- The typewriter no longer plays hit/miss/hurt sounds during fights (the stage does), so nothing doubles.

## 0.4.2
- Feral Straggler now faces the player in combat (its sheet art faces right, so it is flipped like the raider).
- Lockpick and terminal minigames are back on the plain CRT screen (dark tube, scanlines, glow), matching the
  encounter log. The tiled wall backdrop was removed from them. (Event screens keep it.)
- Rival Scavengers event art: the straggler now faces the raider.

## 0.4.1
- Clouds redrawn: full rounded cumulus (no flat cut-off bottoms), single puffs, wide banks, a towering cumulus,
  thin wisps and two-tone layered banks; two cloud layers at different depths.
- Encounter text no longer replays into the narrative log. Leaving an encounter adds ONE result line:
  `> LOCKPICK: SUCCESS`, `> TERMINAL ACCESS: FAILED`, `> COMBAT: VICTORY`, `> ENCOUNTER: <TITLE> RESOLVED`, ...
- 28 new background structures in the same pixel style: 8 ruined blocks (broken windows, collapse damage, exposed floor
  slabs, rebar, vines, rubble), cooling tower, silos, wind turbine, ferris wheel, broken overpass, gas holder, port crane,
  container stack, giant statue head, skeleton ribcage, mesa, rock spire, stadium arc, drive-in screen, airliner tail,
  saucer tower, and 4 forest groves. All six regions now mix them into their skylines.

## 0.4.0
- Title screen: logo over a night camp with the dweller sitting by an animated fire; PLAY loads the latest save
  (or starts a new game). Audio starts on PLAY (browsers need a tap). Version shown under the button.
- Floor: feet planted at the bottom of the floor strip; uniform floor band height.
- Backgrounds: far/mid ground planes so distant buildings stand on something, hills/mountains/treeline ridges,
  drifting clouds, bigger skylines, forest-and-ruin mixes per region.
- Settings: VIDEO / AUDIO sections; new COLOUR BLEED slider (lets the sprites' own colours through the green).
- Combat: weapon-aware attacks. Pipe, reinforced pipe and machete swing (wind-up, strike, slash trail, lunge);
  plasma cutter fires an energy bolt; the pipe rifle keeps the shooting animation. Defend = guard crouch.
- Raider sprite now faces the player.
- Event screens: 16 new illustrations (derived + your sprites).
- Lockpicking: strain is now PICK HP. It never recovers; every opened lock wears the pick a little more.
- Safehouse: DEPART ON EXPEDITION is first.
- Loot chime plays once per reward burst.
- Text: grammar-driven flavour (millions of distinct lines): sights, thoughts, sounds, smells, weather, notes, radio,
  finds, fails; per-weapon / per-creature combat lines; deaths, crits, stims, defend, escape; surreal combat interjections.
  Source of truth: tools/text/*.py -> `python3 tools/gen_flavor.py` -> lib/game/flavor_gen.dart.
- Lifecycle: the app never overwrites the save while on the title screen.
