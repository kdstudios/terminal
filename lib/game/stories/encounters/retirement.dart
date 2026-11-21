import '../../story_model.dart';
import '../characters/grandma_grim.dart';
import '../story_kit.dart';

// THE RETIREMENT HOME
// Sunset Gables: a fortified settlement of elderly survivors with excellent
// defences, questionable hearing and no patience for nonsense. Grandma Grim
// is in charge. Endings: respected, insulted, joined.
// Follow-up character encounter: encounters/grandma.dart

List<Choice> _gablesChoices() => [
      Choice('[SPEAK TO THE GATEKEEPER]', 'g_gate', show: (c) => !c.flag('seen.gate')),
      Choice('[LOOK AT THE DEFENCES]', 'g_def', show: (c) => !c.flag('seen.def')),
      Choice('[ASK FOR GRANDMA GRIM]', 'g_grim', show: (c) => !c.flag('seen.grim')),
      Choice('[GO IN]', 'g_in'),
    ];

final StoryDef retirementStory = StoryDef(
  id: 'retirement',
  title: 'THE RETIREMENT HOME',
  tagline: 'SUNSET GABLES: THE BEST-DEFENDED SETTLEMENT IN THE WASTELAND, RUN BY THE OLDEST, MEANEST PEOPLE IN IT.',
  difficulty: 'MODERATE',
  destinationKm: 2.0,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: ['The sign says SUNSET GABLES — A GENTLE PLACE. Below it, in much larger letters, hand-painted in red: IF YOU CAN READ THIS, YOU’RE IN RANGE. Beyond the gate, a long, low building stands behind three layers of razor wire, a trench and a very large, very neat flowerbed.'],
  reward: const Reward(scrap: 70, xp: 55, stims: 1),
  endings: {
    'respected': const Ending('respected', 'RESPECT YOUR ELDERS',
        'You were polite, patient, and brought sweets. You were told, with great ceremony, that you had “good manners for a youngster.” It is the highest praise given at Sunset Gables. You may visit whenever you like. You are expected to bring biscuits.',
        bonus: Reward(xp: 20, stims: 1), world: ['grim.respect', 'grim.friend', 'favour.grim']),
    'insulted': const Ending('insulted', 'ASKED TO LEAVE',
        'You were rude. You were told, very calmly, to leave. You left. Something whistled past your ear on the way out. It was a knitting needle. It was, you think, a warning.',
        bonus: Reward(), world: ['grim.insulted']),
    'joined': const Ending('joined', 'AN HONORARY RESIDENT',
        'You were made an honorary resident, with a room, a blanket and a mug. You are expected at bingo on Thursdays. You have never felt so welcome, or so afraid of the cutlery.',
        bonus: Reward(scrap: 50, parts: 1), world: ['grim.joined', 'grim.friend']),
  },
  depart: (c) => ['You walk up the long, flat drive, which is lined with beautifully tended roses. Somewhere above, a very small bolt clicks.'],
  ambient: [
    Ambient('A hand-painted sign: PLEASE SPEAK UP. THE MANAGEMENT IS HARD OF HEARING AND QUICK ON THE TRIGGER.', maxKm: 1),
    Ambient('A small, rusted tripwire runs across the lawn, and, tied to it, a very small bell. Then another. Then eleven.', maxKm: 1.5),
    Ambient('From a window: “WHAT’S THAT, DEAR?” “A VISITOR.” “A WHAT?” “A VISITOR.” “WHO’S RISOTTO?”', minKm: 0.5),
    Ambient('~There are two sorts of old folk: the ones you pass in a corridor and the ones who’ve survived the end of the world. This is the second.', minKm: 1),
  ],
  checkpoints: [
    Checkpoint(
      id: 'gates',
      title: 'THE GATES',
      km: 1.0,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 18),
      journal: (c) => [
        'Sunset Gables is run by the elderly, for the elderly. It has a nest of machine guns in the greenhouse and a cake rota.',
        if (c.flag('seen.def')) 'The defences are staggeringly good. Every one of them has been knitted a small cosy.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The gate is guarded by a stooped man in a flat cap who holds a rifle across his knees with the practised, casual ease of a man who has held one for sixty years. He cups a hand to his ear. “WHAT?”',
            '“I’m a visitor,” you say. “A WHAT?” “A VISITOR.” “A CHEESE?” he says, brightening. “I’d love some. Is it mild?”',
          ]),
          _gablesChoices(),
        ),
        Scene.talk(
          'g_gate',
          say([
            '“I’m Albert,” says the old man, at a volume that startles birds. “I’ve been on the gate since the war. Haven’t let anyone through I didn’t like. Nor, between you and me, anyone I did. It’s safer.” He leans forward. “If you’re here to rob us, go away. If you’re here to sell us something, go away faster.”',
            '“And if I’m here to visit?”',
            '“Then you’d better,” says Albert, “have brought biscuits.”',
          ]),
          _gablesChoices(),
          flags: ['seen.gate'],
        ),
        Scene.talk(
          'g_def',
          say([
            'You walk the perimeter. It’s astonishing. A three-layer trench, filled with sharpened walking sticks. A trip-wire running through the roses. A greenhouse with a machine-gun nest. A cake tin, left open on a wall, with a pressure plate underneath.',
            'Every weapon has a small knitted cosy in a different colour. The machine gun is lilac. The mortar is a gentle green. One of the mines has a doily.',
            '~It’s the most heavily armed place you have ever been, and the best dressed.',
          ]),
          _gablesChoices(),
          flags: ['seen.def'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'g_grim',
          (c) => [
            ...GrandmaGrim.greeting(c),
            '“What’s that, dear?” says Albert. “She’s in the lounge. She’s always in the lounge. She doesn’t care for visitors. She doesn’t care for much, to be honest. But she does enjoy a good Garibaldi.”',
          ],
          _gablesChoices(),
          flags: ['seen.grim'],
        ),
        Scene.end('g_in', say(['Albert opens the gate with a loud clank, and watches you pass, one eye narrowed, one hand on the trigger. “Wipe your feet!” he bellows. You wipe your feet. You have never wiped your feet so thoroughly.'])),
      ],
    ),
    Checkpoint(
      id: 'lounge',
      title: 'THE LOUNGE',
      km: 2.0,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 12, xp: 22),
      journal: (c) => ['Grandma Grim holds court in the lounge with a flask of tea and a shotgun called Dolores.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...GrandmaGrim.greeting(c),
            'The lounge is a long room full of floral armchairs, doilies and the soft, steady click of knitting needles. There are eleven residents, all of whom are watching you with the benevolent, razor-edged calm of a panel of judges.',
            '“Well?” says Grandma Grim. “What’ve you brought me?”',
          ],
          [
            Choice('[OFFER BISCUITS]', 'biscuits'),
            Choice('[MAKE A JOKE ABOUT AGE]', 'rude'),
            skillChoice('SURVIVAL', 1, 'ASK ABOUT THE WAR', 'war'),
            Choice('[SIT QUIETLY]', 'sit'),
          ],
        ),
        Scene.talk(
          'biscuits',
          say([
            'You produce a packet of Garibaldis. A very long silence follows, as eleven pairs of eyes fix on the packet. Grandma Grim opens it with a long, scarlet fingernail. She takes one. She bites it. She closes her eyes.',
            '“Well,” she says. “That’s a good biscuit. Where did you get it?” “A trader.” “Hm.” She gives you a very small, approving nod. “Sit. Albert, fetch the young one a tea.”',
          ]),
          [Choice('[SIT AND TALK]', 'end_respected')],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'rude',
          say([
            '“I’d have thought,” you say, “that someone your age would be a bit slower.” The needles stop. The room goes very still. Grandma Grim looks at you for a long time. “Dolores,” she says, very quietly, “is a very patient gun.”',
            'In the corner, someone says, “WHAT DID HE SAY?” and someone else says, “HE SAID WE’RE OLD.” “WE ARE OLD,” says the first, indignantly, “IT’S NOT AN INSULT!” Dolores clicks.',
          ]),
          [
            Choice('[APOLOGISE]', 'sorry'),
            Choice('[LEAVE QUICKLY]', 'end_insulted'),
          ],
        ),
        Scene.talk(
          'sorry',
          say([
            'You apologise, at length, with your hat in your hands. There is a long, dry, terrible pause. “Hm,” says Grandma Grim. “Not bad. Sit. Tea. Don’t say anything for ten minutes.”',
            'You sit. You say nothing. You drink the tea. The tea is excellent. It’s the most frightening ten minutes of your life.',
          ]),
          [Choice('[CONTINUE]', 'end_respected')],
        ),
        Scene.talk(
          'war',
          say([
            '“What was the war like?” you ask. Grandma Grim sets down her knitting. “I was a girl,” she says. “I was nine. They told us to stay indoors. My mother put me in the cellar with a tin of peaches and a shotgun.”',
            '“A shotgun?” “It was a very small shotgun. My father’s.” She smiles faintly. “I used it. I won’t say how. We all grew up quite fast. That’s why we’re so good at it now.”',
            'The room is silent. Every one of the residents has lowered their needles. One of them, a very old man in a cardigan, takes off his cap.',
          ]),
          [
            Choice('[THANK HER]', 'end_joined'),
            Choice('[OFFER BISCUITS]', 'biscuits'),
          ],
          flags: ['heard_war'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'sit',
          say([
            'You sit in a floral chair and say nothing. You wait. After a long while, someone gives you a blanket, someone else a cushion. A very old man puts a pot of tea at your elbow without a word. Grandma Grim watches over her glasses.',
            '“He knows when to be quiet,” she says, to the room. “That’s rarer than you’d think.”',
          ]),
          [Choice('[CONTINUE]', 'end_respected')],
        ),
        Scene.end('end_respected', say(['You are given a second tea, a biscuit and a small wooden plaque that says GOOD YOUNGSTER. “Come back on Sunday,” says Grandma Grim. “We do a roast. We have a rota for who doesn’t get shot.”']), ending: 'respected'),
        Scene.end('end_insulted', say(['You leave faster than you came. As you pass the roses, something whistles past your ear and lodges in the gatepost. It’s a knitting needle. There’s a small tag attached. It reads: MANNERS.']), ending: 'insulted'),
        Scene.end('end_joined', say(['“There,” says Grandma Grim, patting the arm of the chair next to her. “That’s your seat. We’ve a bed spare. You’ll do a shift on the wall on Wednesdays.” You are given a blanket, a mug and a pair of slippers. You are honorary. You are, you realise, home.']), ending: 'joined'),
      ],
    ),
  ],
);
