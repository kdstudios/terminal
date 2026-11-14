# Wasteland Terminal (Phase 1)

## Setup
1. Install Flutter (3.16+): https://docs.flutter.dev/get-started/install
2. In this folder run:
   flutter create --platforms=ios,android --project-name wasteland_terminal .
   (keeps existing lib/ and pubspec.yaml; if it overwrites lib/main.dart, restore ours)
3. flutter pub get && flutter run

Rotate the device/emulator: layout switches stacked <-> side-by-side, state persists.

## Structure
lib/game/game_state.dart         Central observable state (hp, scrap, distance, log, mode)
lib/game/exploration_system.dart Automated exploration + random events (events are MOCKED)
lib/ui/theme.dart                Terminal palette + text styles
lib/ui/terminal_frame.dart       CRT-style bordered panel with scanlines
lib/ui/exploration_terminal.dart Terminal A (animated wasteland, CustomPainter)
lib/ui/narrative_terminal.dart   Terminal B (scrolling log)
lib/ui/status_bar.dart           HP / SCRAP / DISTANCE / MENU
lib/ui/dual_terminal_screen.dart Responsive portrait/landscape layout

## Art pipeline (full-colour sprite sheets + CRT look)

Source art lives in `art_src/`. Generated data lives in `assets/atlas/` and is committed.

    python3 tools/slice_sheets.py [--overlay]   # sheets -> assets/atlas/*.png + *.json (needs numpy, scipy, pillow)
    python3 tools/derive_assets.py              # derived art (mushroom cloud, post-mounted signs) -> derived.*
    python3 tools/contact_sheet.py              # debug: labelled contact sheets in work/

* `tools/slice_sheets.py`  alpha -> connected components, with hand overrides (ZONES / VSPLITS / MERGE / IGNORE)
  for the few places detection cannot solve. Each sprite gets a foot anchor (`ax`) so animation frames stay planted.
* `tools/sprite_names.py`  curated names / animation rows / scenery pools, addressed by POSITION on the
  sheet (not index), so re-slicing never breaks the names.
* `lib/ui/atlas.dart`      loads the sheets; `Atlas.named / frames / pool / resolve`.
* `lib/ui/crt.dart`        `Crt.phosphor()` colour filter (luminance -> theme colour, keeps a little original
  colour), `CrtScreen` (tube gradient + title strip), scanline / vignette overlay.
* `lib/ui/metal_frame.dart` 9-slice frame from `assets/ui/terminal_frame.png`: corners 1:1, edges are a tiled
  central segment with every other copy mirrored (no stretching, invisible seams).
* `lib/ui/wasteland_scene.dart` procedural, endless, seeded scenery per region (`sceneThemes`).

Add a sprite: put it on a sheet, re-run the slicer, add a position to `sprite_names.py`, reference it as
`"sheet:name"` in a `SceneTheme`. Change a region's look: edit its entry in `sceneThemes`.

### Cleaning, derived art, backgrounds
* `slice_sheets.py` now also CLEANS every sprite (drops pixels that belong to a neighbour or are loose specks),
  trims it, and repacks all sprites into fresh atlases; the individual cleaned PNGs are in `art_clean/<sheet>/`.
* `tools/pixlib.py` is the pixel-art toolkit (bulge shading, dithering, outline) used for derived art.
  `tools/creatures.py` (11 enemies: skitter, hound, crawler, lurker, swarm, spitter, colossus, wyrm, sentry,
  warmachine, brute, all facing LEFT) and `tools/backgrounds.py` (seamless `bg.wall`, `bg.steel`).
  Preview: `python3 tools/creatures.py` -> work/creatures.png. Individual PNGs: `art_clean/derived/`.
* Combat: `CombatSystem` appends `CombatFx` events; `combat_view.dart` plays them back on a timeline.
  Buttons live in `combat_actions.dart`, mounted beside the encounter log.
