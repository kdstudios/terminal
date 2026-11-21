import 'combat_session.dart';

/// A stretch of wasteland. Everything about it (look, mood, danger, enemies)
/// lives in data, so adding a region is just adding an entry to [regions].
class Region {
  final String name, danger, arrival;
  final double startKm;
  final List<String> sights; // what you see
  final List<String> thoughts; // what you think
  final Map<EnemyType, int> enemies; // spawn weights
  const Region({
    required this.name,
    required this.danger,
    required this.arrival,
    required this.startKm,
    required this.sights,
    required this.thoughts,
    required this.enemies,
  });
}

const regions = <Region>[
  Region(
    name: 'DUSTY HIGHWAY',
    danger: 'LOW',
    startKm: 0,
    arrival: 'The highway stretches ahead, cracked and sun-bleached, swallowed by dust at the horizon.',
    sights: [
      'Rusted cars line the road, doors hanging open like broken jaws.',
      'A faded billboard promises a brighter tomorrow. Someone has scratched out the second word.',
      'Dust devils spin across the asphalt and fall apart.',
      "A child's shoe sits alone on the road shoulder, bleached white.",
      'Power lines sag between leaning poles, humming with nothing.',
      'The skeleton of a bus lies on its side, windows long gone.',
    ],
    thoughts: [
      'How many people drove this road before the end? Where were they all going?',
      'Keep moving. The dust makes everything look closer than it is.',
      'You adjust your pack straps. Every ounce counts out here.',
      'The silence is almost loud.',
      'Home feels very far away already. It is not far at all.',
    ],
    enemies: {EnemyType.skitter: 5, EnemyType.hound: 2, EnemyType.raider: 1, EnemyType.swarm: 2, EnemyType.straggler: 1},
  ),
  Region(
    name: 'RUSTED OUTSKIRTS',
    danger: 'MODERATE',
    startKm: 3,
    arrival: 'Collapsed warehouses and skeletal cranes crowd the road. The outskirts of something that used to be a city.',
    sights: [
      'A crane leans over the ruins, held up by rust and habit.',
      "Shipping containers lie scattered like a giant's dropped toys.",
      'Chain-link fences ripple in the wind, torn open by something that did not use the gate.',
      'Wind whistles through a gutted factory, a low, tuneless note.',
      'Scorch marks climb the side of a water tower.',
      'Rust has turned a whole row of vehicles the colour of dried blood.',
    ],
    thoughts: [
      'Somebody holed up here once. You can see where they boarded the windows.',
      'Rust everywhere. You wonder if the whole world is slowly turning to powder.',
      'Your boots crunch on broken glass. So much for quiet.',
      'Scavengers must have picked this place over. Still, there might be something left.',
      "You catch yourself listening for footsteps that aren't yours.",
    ],
    enemies: {EnemyType.skitter: 3, EnemyType.hound: 3, EnemyType.raider: 2, EnemyType.crawler: 2, EnemyType.swarm: 1, EnemyType.straggler: 2, EnemyType.captain: 1},
  ),
  Region(
    name: 'GLASSED BASIN',
    danger: 'HIGH',
    startKm: 6,
    arrival: 'The ground turns to dark glass underfoot, a vast bowl fused by some long-ago fire.',
    sights: [
      'The glassy ground throws the sky back in warped, wavering pieces.',
      'Small, clean bones are fused into the glass like insects in amber.',
      'Heat shimmers over the basin. Nothing moves, but something is watching.',
      'A rusted warning sign stands at an angle, its message melted away.',
      'The glass ticks and pops as it cools in the shade.',
      'Your reflection follows you across the ground, thin and distorted.',
    ],
    thoughts: [
      'Whatever happened here happened fast.',
      'You try not to think about what the glass used to be.',
      'There is no cover out here. Anything that sees you will see you coming.',
      'You taste metal at the back of your throat.',
      'Your skin prickles. Probably just the heat. Probably.',
    ],
    enemies: {EnemyType.hound: 3, EnemyType.crawler: 3, EnemyType.sentry: 2, EnemyType.raider: 2, EnemyType.brute: 1, EnemyType.spitter: 2, EnemyType.wyrm: 1, EnemyType.colossus: 1},
  ),
  Region(
    name: 'DROWNED SUBURBS',
    danger: 'HIGH',
    startKm: 9,
    arrival: 'Streets of identical houses sink into black water, their roofs poking out like stepping stones.',
    sights: [
      'A swing set rusts in a flooded yard, one seat still swaying.',
      'Murky water laps at porches where families once sat in the evening.',
      'Something large ripples the surface and sinks without a sound.',
      'Wallpaper peels from a bedroom wall, still printed with faded animals.',
      'A rowboat is tied to a mailbox. Nobody is in it.',
      'Moss has swallowed the street signs. The names are gone.',
    ],
    thoughts: [
      'You wonder who painted that front door yellow, and whether they got out.',
      'The water is too still. You keep your hand near your weapon.',
      "Somebody's whole life is rotting in that living room.",
      'Every dark window feels like an eye.',
      'You think of the safehouse, dry and warm, and walk a little faster.',
    ],
    enemies: {EnemyType.crawler: 3, EnemyType.lurker: 3, EnemyType.hound: 2, EnemyType.raider: 2, EnemyType.brute: 1, EnemyType.spitter: 2, EnemyType.straggler: 2, EnemyType.captain: 1},
  ),
  Region(
    name: 'IRON GRAVEYARD',
    danger: 'SEVERE',
    startKm: 12,
    arrival: 'Mountains of wrecked machines rise on all sides, a graveyard of tanks, trucks and things with no names.',
    sights: [
      'A tank lies on its back, its gun barrel buried in the dirt.',
      'Old robots sit in neat rows, hollow-eyed, waiting for an order that never came.',
      'Cables hang from a gantry like dead vines, swaying though there is no wind.',
      'Armoured hulls groan as they settle.',
      'A red light blinks, faint and patient, somewhere in the wreckage.',
      'The ground is littered with shell casings, thousands upon thousands.',
    ],
    thoughts: [
      'Somebody spent a fortune on all this. It bought them nothing.',
      'Machines are the worst part. They do not know the war is over.',
      'You walk quietly. You are not sure why that feels important.',
      'The red light blinks again. Closer, or are you imagining that?',
      'Everything here was built to kill. Some of it still might.',
    ],
    enemies: {EnemyType.sentry: 4, EnemyType.brute: 2, EnemyType.lurker: 2, EnemyType.raider: 2, EnemyType.warmachine: 1, EnemyType.colossus: 2, EnemyType.captain: 2, EnemyType.spitter: 1},
  ),
  Region(
    name: 'ASHEN HEIGHTS',
    danger: 'EXTREME',
    startKm: 16,
    arrival: 'Grey ash drifts down like snow over broken towers, the tallest ruins you have ever seen.',
    sights: [
      'Ash settles on your shoulders, soft and silent as snow.',
      'A skyscraper has folded in half, its upper floors resting on the street below.',
      'Wind carries a distant, metallic groan through the canyon of towers.',
      'The sky is the colour of an old bruise.',
      'Stairwells open onto nothing, hanging fifty storeys above the ruins.',
      'Footprints in the ash. Fresh, and far too large.',
    ],
    thoughts: [
      'Nobody comes this far. You are not sure why you did.',
      'The air is thin and tastes of old fire.',
      'You wonder if anyone will ever know you walked here.',
      'Turn back, a quiet voice says. Not yet, says another.',
      'This is what the end looked like up close. It is still ending.',
    ],
    enemies: {EnemyType.brute: 3, EnemyType.sentry: 3, EnemyType.lurker: 2, EnemyType.warmachine: 2, EnemyType.raider: 2, EnemyType.wyrm: 2, EnemyType.colossus: 2, EnemyType.captain: 2},
  ),
];

Region regionAt(double km) {
  var r = regions.first;
  for (final x in regions) {
    if (km >= x.startKm) r = x;
  }
  return r;
}

// ---- situational flavour

const startThoughts = [
  'You take a breath, check your gear, and step out into the wasteland.',
  'The door closes behind you. The world waits, vast and indifferent.',
  'One more run. Come back with more than you left with.',
  'You tighten your pack and start walking.',
];

const lowHpThoughts = [
  'Your hands are shaking. You need a stimpack, or a bed.',
  'Every step hurts. You should turn back.',
  'Your vision swims for a second. Not good.',
];

const richThoughts = [
  'Your pack is heavy with scrap. Valuable, too. Someone would kill for this.',
  'You tally it in your head. That is a lot of scrap. Do not lose it.',
];

const farThoughts = [
  'You are a long way from the safehouse now. Nobody is coming to help.',
  'The road home is getting longer with every step.',
];

// ---- hazards (resolved by a stat check)

class Hazard {
  final String name, text, stat;
  final int dmgMin, dmgMax;
  const Hazard(this.name, this.text, this.stat, this.dmgMin, this.dmgMax);
}

const hazards = <Hazard>[
  Hazard('RADIATION POCKET', 'Your skin prickles. A pocket of bad air hangs over the road.', 'END', 4, 9),
  Hazard('COLLAPSING FLOOR', 'The floor groans and gives way beneath you!', 'AGI', 6, 12),
  Hazard('TOXIC FUMES', 'A hiss of pale vapour rolls out of a cracked pipe.', 'END', 4, 8),
  Hazard('LIVE WIRE', 'A severed cable whips out of the dark, spitting sparks.', 'PER', 5, 10),
  Hazard('SINKHOLE', 'The ground ahead is not ground at all.', 'PER', 6, 11),
];

const scavengeLines = [
  'Sifting through the debris, you turn up something worth keeping.',
  'A split suitcase spills a few useful scraps.',
  'Behind a collapsed shelf you spot salvage the last scavenger missed.',
  'You pry open a panel. Good hardware, mostly intact.',
  'Half-buried in dust: a stash of usable scrap.',
];
