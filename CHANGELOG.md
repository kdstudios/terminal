# Changelog

VERSIONING RULE: every time anything is changed, bump `kVersion` in `lib/version.dart`
(and `version:` in pubspec.yaml) and add an entry here. The version is shown on the title screen.

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
