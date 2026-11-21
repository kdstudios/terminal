import 'combat_session.dart';
import 'event_session.dart';
import 'story_content.dart';

/// One possible result of choosing an option. Several outcomes can share an
/// option, picked by weight. hp is positive for healing, negative for damage.
class Outcome {
  final int weight;
  final String text;
  final int scrapMin, scrapMax, hp, stim, picks, parts, xp;
  final EnemyType? fight; // start this specific fight
  final bool anyFight; // start a fight suited to the region
  final String? chain; // 'lock' or 'hack': hand over to that minigame
  final bool rare; // a rare weapon or armour
  const Outcome(
    this.text, {
    this.weight = 1,
    this.scrapMin = 0,
    this.scrapMax = 0,
    this.hp = 0,
    this.stim = 0,
    this.picks = 0,
    this.parts = 0,
    this.xp = 0,
    this.fight,
    this.anyFight = false,
    this.chain,
    this.rare = false,
  });
}

class OptionDef {
  final String label;
  final int needScrap, needStim, needPick;
  final List<Outcome> outcomes;
  const OptionDef(this.label, this.outcomes,
      {this.needScrap = 0, this.needStim = 0, this.needPick = 0});
}

class EventDef {
  final String id, title, desc;
  final int weight;
  final List<String> thoughts;
  final List<OptionDef> options;
  const EventDef(this.id, this.title, this.desc, this.weight, this.thoughts, this.options);
}

const dataEvents = <EventDef>[
  EventDef(
    'vault', 'SEALED VAULT DOOR',
    'A circular steel door is set into a hillside, half-buried, sealed tight. A panel beside it blinks a patient amber.',
    6,
    ['Pre-war vaults held either everything or nothing.', 'Doors like this were built to keep something out. Or in.'],
    [
      OptionDef('[HACK THE PANEL]', [Outcome('The panel wakes under your fingers, hungry for a password.', chain: 'hack')]),
      OptionDef('[PRY THE SEAL] (-1 LOCKPICK)', [
        Outcome('Under the grime, the seal has a lock after all.', weight: 3, chain: 'lock'),
        Outcome('You work the edge and something gives. Inside: a few dusty crates and a long silence.', scrapMin: 20, scrapMax: 55, parts: 1, xp: 10),
      ], needPick: 1),
      OptionDef('[LEAVE IT SEALED]', [Outcome('You leave the door sleeping. Some things are better kept.')]),
    ],
  ),
  EventDef(
    'wreck', 'CARAVAN WRECK',
    'A convoy lies where it died: overturned trucks, torn canvas, a long scatter of crates. Vultures lift off as you approach.',
    10,
    ['Someone loaded these trucks with hope. Not much of it survived.', 'You can read a whole last day in the way the wreckage lies.'],
    [
      OptionDef('[SEARCH THE WRECKAGE]', [
        Outcome('Crates, mostly broken, but a few have contents worth the digging.', weight: 4, scrapMin: 30, scrapMax: 70, parts: 1, xp: 8),
        Outcome('The vultures were not alone. A shrieking cloud rises from the wreckage.', weight: 2, fight: EnemyType.swarm),
        Outcome('A strut gives way as you climb. Pain, then bruises.', weight: 1, scrapMin: 5, scrapMax: 20, hp: -8),
      ]),
      OptionDef('[STRIP THE TRUCKS FOR PARTS]', [
        Outcome('You strip what you can: bolts, wire, a good alternator.', weight: 3, parts: 3, xp: 6),
        Outcome('Everything useful is already gone, but you find a half-full toolkit.', weight: 1, parts: 1, scrapMin: 5, scrapMax: 15),
      ]),
      OptionDef('[MOVE ON]', [Outcome('You pay your respects in silence and keep walking.')]),
    ],
  ),
  EventDef(
    'shrine', 'ROADSIDE SHRINE',
    'Someone built this: stacked stones, candles, a crude cross of pipe, offerings of tin cans and faded ribbon. A small doll watches from the top.',
    8,
    ['Hope looks strange out here.', 'Whoever kept the candles lit is not far away.'],
    [
      OptionDef('[LEAVE AN OFFERING] (-10 SCRAP)', [
        Outcome('A strange calm settles over you, and the aches ease.', weight: 3, hp: 20),
        Outcome('Beneath the doll, a small stash. Someone leaves things back for the generous.', weight: 2, stim: 1),
        Outcome('You feel watched, and not unkindly. Something in you straightens.', weight: 2, xp: 15),
      ], needScrap: 10),
      OptionDef('[TAKE THE OFFERINGS]', [
        Outcome('You pocket the offerings. The doll looks disappointed. Or it is the light.', weight: 3, scrapMin: 15, scrapMax: 35),
        Outcome('A cry of rage: the shrine\'s keeper, wild-eyed and hungry.', weight: 2, fight: EnemyType.straggler),
        Outcome('A rusted trap beneath the stones bites your hand.', weight: 1, scrapMin: 5, scrapMax: 15, hp: -8),
      ]),
      OptionDef('[STAND AND PRAY]', [
        Outcome('You stand in silence for a minute. Nothing answers, but it helps.', weight: 2, hp: 10, xp: 5),
        Outcome('You pray for people you cannot name. When you open your eyes, the wind has dropped.', weight: 1, xp: 12),
      ]),
      OptionDef('[LEAVE]', [Outcome('You leave the little shrine as you found it.')]),
    ],
  ),
  EventDef(
    'rival', 'RIVAL SCAVENGERS',
    'Two scavengers hunch over a crate in the road, hands on weapons. They look up as you approach. Nobody speaks.',
    8,
    ['Out here, strangers are a coin toss. Heads, they share. Tails, they shoot.', 'There is always one more scavenger than there is scrap.'],
    [
      OptionDef('[BARGAIN]', [
        Outcome('You haggle, split the crate three ways, and part without bloodshed.', weight: 3, scrapMin: 20, scrapMax: 45, xp: 6),
        Outcome('The haggling sours. Weapons come out.', weight: 2, fight: EnemyType.raider),
      ]),
      OptionDef('[ATTACK THEM]', [
        Outcome('You strike first. They were not fooled.', weight: 3, fight: EnemyType.raider),
        Outcome('One of them panics and bolts, leaving the crate behind.', weight: 2, scrapMin: 30, scrapMax: 60),
      ]),
      OptionDef('[OFFER A STIMPACK] (-1)', [
        Outcome('Gratitude is rare out here. One of them presses scrap into your hand and tells you of a stash.', weight: 3, scrapMin: 40, scrapMax: 80, xp: 12),
        Outcome('They take the stimpack, nod, and say nothing. But a bag appears at your feet as you leave.', weight: 1, scrapMin: 20, scrapMax: 40, parts: 2),
      ], needStim: 1),
      OptionDef('[WALK AWAY]', [Outcome('You back away with your hands where they can see them.')]),
    ],
  ),
  EventDef(
    'tunnel', 'COLLAPSED TUNNEL',
    'A road tunnel has caved in, a mound of rubble spilling out like a swallowed tongue. A thin draught whispers through a gap near the top.',
    8,
    ['A draught means the other side is open. A draught also means something is breathing.', 'Tunnels keep what you put in them.'],
    [
      OptionDef('[DIG THROUGH]', [
        Outcome('Behind the rubble: a sealed maintenance locker, still full.', weight: 3, scrapMin: 30, scrapMax: 70, parts: 2, xp: 8),
        Outcome('The rubble shifts and bites. You come out bruised and bloody.', weight: 2, hp: -10, scrapMin: 5, scrapMax: 20),
        Outcome('Something has made its home on the other side.', weight: 2, fight: EnemyType.lurker),
      ]),
      OptionDef('[CLIMB THE GAP]', [
        Outcome('You squeeze through and find an old stash.', weight: 3, scrapMin: 15, scrapMax: 35, xp: 12),
        Outcome('The rock scrapes you raw as you wriggle through.', weight: 2, hp: -6, xp: 6),
      ]),
      OptionDef('[GO AROUND]', [Outcome('You take the long way and the long way takes the day.')]),
    ],
  ),
  EventDef(
    'nest', 'MUTANT NEST',
    'A heap of bones and shredded cloth, clutching a clutch of leathery eggs. Long claw marks scar the nearby wall. Something is not here. Yet.',
    7,
    ['The thing that lives here is out hunting. That should comfort you more than it does.', 'Every nest is a promise that something will come home.'],
    [
      OptionDef('[RAID THE NEST]', [
        Outcome('You grab what glitters and leave the eggs.', weight: 3, scrapMin: 25, scrapMax: 55, parts: 1),
        Outcome('The parent returns. Early.', weight: 3, fight: EnemyType.crawler),
      ]),
      OptionDef('[BURN IT]', [
        Outcome('You torch the nest. The smoke is black and oily, and it feels like a small victory.', weight: 3, xp: 15, scrapMin: 10, scrapMax: 25),
        Outcome('The fire gets away from you and singes your hands.', weight: 1, hp: -6, xp: 8),
      ]),
      OptionDef('[LEAVE QUIETLY]', [Outcome('You tread softly and put a long distance between you and it.')]),
    ],
  ),
  EventDef(
    'drifter', 'ROADSIDE DRIFTER',
    'A hooded figure sits by a tiny fire, stirring a dented pot. They look up and nod, as if you were expected. "Sit," they say. "Eat. Tell me something true."',
    8,
    ['A shared fire is the oldest kind of peace.', 'They do not look dangerous. That is exactly what danger looks like.'],
    [
      OptionDef('[SIT AND EAT]', [
        Outcome('The stew is thin and salty and the best thing you have eaten in weeks.', weight: 3, hp: 25),
        Outcome('They tell stories of places you may never see. You leave a little wiser.', weight: 2, xp: 20),
        Outcome('They press a small tin into your hands. "For the road."', weight: 1, stim: 1, hp: 10),
      ]),
      OptionDef('[SHARE YOUR STORY]', [
        Outcome('You talk longer than you meant to. They listen. It helps more than food.', weight: 2, xp: 25, hp: 8),
        Outcome('They pay for a good story in the only coin that matters.', weight: 2, scrapMin: 10, scrapMax: 25, xp: 8),
      ]),
      OptionDef('[ROB THEM]', [
        Outcome('You take what you can carry. They do not stop you. That bothers you more than it should.', weight: 2, scrapMin: 25, scrapMax: 50),
        Outcome('Their hood falls back. They were never alone.', weight: 1, fight: EnemyType.raider),
      ]),
      OptionDef('[MOVE ON]', [Outcome('You nod to the drifter. They nod back and return to the stew.')]),
    ],
  ),
  EventDef(
    'drone', 'CRASHED DRONE',
    'A pre-war surveillance drone lies in the dirt, rotors bent, lens cracked, one light still blinking weakly. It has been waiting a long time.',
    7,
    ['It watched the world end. It might remember who did it.', 'Old machines are loyal in a way people never were.'],
    [
      OptionDef('[SALVAGE IT]', [
        Outcome('Fine machinery: clean wire, a good power cell, a lens worth keeping.', weight: 3, parts: 2, scrapMin: 15, scrapMax: 35),
        Outcome('A capacitor discharges into your hand. You swear creatively.', weight: 1, hp: -6, parts: 1),
        Outcome('Its last act is a distress ping. Someone answers it.', weight: 1, fight: EnemyType.raider),
      ]),
      OptionDef('[HACK IT]', [
        Outcome('The drone\'s maintenance port is still live.', weight: 2, chain: 'hack'),
        Outcome('Its data core is corrupt, but its logs make for fascinating reading.', weight: 1, xp: 18),
      ]),
      OptionDef('[LEAVE IT]', [Outcome('You leave it to its blinking light.')]),
    ],
  ),
  EventDef(
    'pond', 'TOXIC POND',
    'A pond lies in a hollow, too still, too green. Pale things drift in it. Something glints at the bottom, just beneath the surface.',
    6,
    ['Nothing that glints is ever free.', 'The water has the colour of a bad idea.'],
    [
      OptionDef('[REACH IN]', [
        Outcome('Your arm comes out slick and stinging, with a handful of old coins.', weight: 3, scrapMin: 30, scrapMax: 70),
        Outcome('The water burns. You drag out a handful of scrap and a chemical rash.', weight: 3, scrapMin: 15, scrapMax: 35, hp: -10),
      ]),
      OptionDef('[FISH WITH A POLE]', [
        Outcome('Patient work, and the pond gives up its glint without a fight.', weight: 3, scrapMin: 15, scrapMax: 35, xp: 10),
        Outcome('Something in the pond objects to being fished.', weight: 1, fight: EnemyType.spitter),
      ]),
      OptionDef('[LEAVE IT]', [Outcome('You walk wide around the water. Your boots thank you.')]),
    ],
  ),
  EventDef(
    'gang', 'ROAD GANG TOLL',
    'A barricade of wrecked cars blocks the road. A skull on a pole grins down. A figure leans on the barrier: "Toll\'s thirty scrap, friend. Or you can try the hard way."',
    8,
    ['A toll is just a robbery with manners.', 'Someone has to run the road. Might as well be someone who laughs.'],
    [
      OptionDef('[PAY THE TOLL] (-30 SCRAP)', [
        Outcome('They wave you through, laughing. Cheap at the price.', weight: 3, xp: 5),
        Outcome('They take the scrap, then, grudgingly, toss you a stimpack. "Rep matters."', weight: 1, stim: 1),
      ], needScrap: 30),
      OptionDef('[FIGHT YOUR WAY THROUGH]', [
        Outcome('You charge. They were hoping you would.', weight: 3, fight: EnemyType.raider),
        Outcome('The boss steps up himself, grinning under a horned helmet.', weight: 1, fight: EnemyType.captain),
      ]),
      OptionDef('[SNEAK AROUND]', [
        Outcome('You slip through a gap in the wrecks while they argue over a card game.', weight: 3, xp: 8),
        Outcome('A scrape on a rusted bumper tears your arm as you duck through.', weight: 2, hp: -6, xp: 4),
        Outcome('A shout. Eyes on you. So much for stealth.', weight: 1, fight: EnemyType.raider),
      ]),
      OptionDef('[TURN BACK]', [Outcome('You take the long way round and keep your scrap.')]),
    ],
  ),
];

EventDef? dataEventById(String id) {
  for (final e in dataEvents) {
    if (e.id == id) return e;
  }
  return null;
}

String eventTitleOf(String id) => isStorySession(id)
    ? storyEventTitle(id)
    : eventTitles[id] ?? dataEventById(id)?.title ?? 'ENCOUNTER';
String eventDescOf(String id) => eventDescriptions[id] ?? dataEventById(id)?.desc ?? '';
List<String> eventThoughtsOf(String id) =>
    eventThoughts[id] ?? dataEventById(id)?.thoughts ?? const ['Something is happening.'];
