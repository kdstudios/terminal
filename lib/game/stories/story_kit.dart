import '../story_model.dart';

// Small shared helpers for writing stories. These are NOT a second dialogue
// system: they only build ordinary [Choice] objects, so every story is still
// plain Scene / Choice / Checkpoint data that you can read top to bottom.

const _short = {
  'HACKING': 'HACK',
  'LOCKPICKING': 'LOCK',
  'COMBAT': 'COMBAT',
  'SCAVENGING': 'SCAV',
  'SURVIVAL': 'SURV',
  'ENGINEERING': 'ENG',
};

/// A dialogue option that only appears when [skill] is at least [need].
/// The label shows the requirement, e.g. `[ENG 2: FIX THE RADIO]`.
Choice skillChoice(
  String skill,
  int need,
  String label,
  String next, {
  List<String> flags = const [],
}) =>
    Choice('[${_short[skill] ?? skill} $need: $label]', next,
        show: (c) => c.skill(skill) >= need, flags: flags);

/// A skill check with a real consequence either way. One button is shown
/// (same label); it leads to [pass] when the skill is high enough and to
/// [fail] otherwise, so failing is a different, usually funnier, scene.
List<Choice> skillSplit(
  String skill,
  int need,
  String label,
  String pass,
  String fail, {
  List<String> passFlags = const [],
  List<String> failFlags = const [],
}) =>
    [
      Choice(label, pass, show: (c) => c.skill(skill) >= need, flags: passFlags),
      Choice(label, fail, show: (c) => c.skill(skill) < need, flags: failFlags),
    ];

/// True when the player has any of the given world facts (set by finished stories).
bool anyWorld(StoryCtx c, List<String> facts) => facts.any(c.world);

/// A fact a finished story left behind. Facts set by an ending live in
/// `world`; facts a story marked with a `carry.` flag live under `carry.`.
/// Either way this finds it.
bool known(StoryCtx c, String fact) => c.world(fact) || c.world('carry.$fact');
