import '../../story_model.dart';

// THE CHICKEN KING
// A settlement worships a giant mutated chicken, Her Eggcellency. The chicken
// is considerably more intelligent than its followers. Endings: crowned,
// free, schemed.

List<Choice> _flockChoices() => [
      Choice('[ASK THE HIGH PRIEST]', 'f_priest', show: (c) => !c.flag('seen.priest')),
      Choice('[LOOK AT THE CHICKEN]', 'f_look', show: (c) => !c.flag('seen.look')),
      Choice('[ASK WHAT SHE WANTS]', 'f_want', show: (c) => !c.flag('seen.want')),
      Choice('[APPROACH THE THRONE]', 'f_go'),
    ];

final StoryDef chickenStory = StoryDef(
  id: 'chicken',
  title: 'THE CHICKEN KING',
  tagline: 'SHE IS NINE FEET TALL. SHE HAS BEEN RULING THEM FOR YEARS. THEY THINK IT WAS THEIR IDEA.',
  difficulty: 'LOW',
  destinationKm: 1.6,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: [
    'The settlement is called Cluckingham. A great wooden gate, shaped like a beak, stands open. Beyond it, rank on rank of kneeling villagers face a platform. On the platform, enthroned on a heap of straw, is a chicken the size of a horse. She watches you arrive with one orange, speculative eye.',
  ],
  reward: const Reward(scrap: 55, xp: 45, stims: 1),
  endings: {
    'crowned': const Ending('crowned', 'THE HIGH PRIESTESS OF THE EGG',
        'You were declared the Chosen Egg-Bearer. You hold an egg in a ceremony and recite lines you were fed by the chicken. It is a very high-status role. The chicken seems pleased. It’s hard to tell. She winks.',
        bonus: Reward(scrap: 50), world: ['chicken.crowned']),
    'free': const Ending('free', 'THE FLOCK IS FREE',
        'You told the villagers the truth: that she’d been running the place for years, and that they were free. They stared at her. She stared back. Then, to everybody’s amazement, she stood up, bowed, and said, in a very clear, very dry voice, “Well. That was fun while it lasted.”',
        bonus: Reward(xp: 40), world: ['chicken.free']),
    'schemed': const Ending('schemed', 'A BUSINESS ARRANGEMENT',
        'You and the chicken reached an understanding. You get a share of the eggs. She gets a quiet, reliable, human who does not try to eat her. It’s the best deal you’ve ever made. It’s with a bird.',
        bonus: Reward(scrap: 90, stims: 1), world: ['chicken.schemed']),
  },
  depart: (c) => ['You can smell the settlement long before you see it. It smells of feathers, corn and, faintly, of absolute authority.'],
  ambient: [
    Ambient('A feather the size of a canoe paddle lies on the road. It’s still warm.', maxKm: 1),
    Ambient('A farmer genuflects, from a field, at nothing in particular. Then he checks. Then he continues.', maxKm: 1.2),
    Ambient('You hear a distant, solemn cry: “BAWK.” It echoes. The whole valley falls silent.', minKm: 0.5),
    Ambient('~There are worse gods than a chicken. A lot of them have fewer eggs.', minKm: 1),
  ],
  checkpoints: [
    Checkpoint(
      id: 'flock',
      title: 'CLUCKINGHAM',
      km: 0.8,
      art: 'shrine',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 15),
      journal: (c) => [
        'The villagers of Cluckingham worship a nine-foot mutated chicken named Her Eggcellency.',
        if (c.flag('seen.look')) 'The chicken is reading a newspaper. She is, I think, the only one who can.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The settlement is a ring of henhouses and a central square paved with straw. Two hundred villagers kneel in neat rows, in feathered capes, and chant softly: “All hail the Egg. All hail the Egg.” The chicken, on her platform, preens.',
            'A very old man in a golden beak-hat bustles forward and bows to you. “I am Mervyn, High Priest,” he says. “You have come at a most auspicious hour. She is in a very good mood. She has laid.”',
          ]),
          _flockChoices(),
        ),
        Scene.talk(
          'f_priest',
          say([
            '“She came to us in a storm,” says Mervyn. “A great bird, of divine size. She spoke in clucks, but we knew. She said: BUILD ME A HOUSE. BRING ME CORN. SPARE MY ENEMIES, BUT ONLY IF THEY’RE FOXES. And so we did. Everything. Every word.”',
            '“What does she say now?”',
            '“Nothing,” says Mervyn. “She doesn’t need to. We know. It’s very beautiful. It’s so simple. The Egg is the Egg.”',
          ]),
          _flockChoices(),
          flags: ['seen.priest'],
        ),
        Scene.talk(
          'f_look',
          say([
            'You study the chicken. She is, up close, enormous: the size of a horse, with a comb like a crown and a gaze like a sharp knife. At her feet lies a folded newspaper, which she is reading. Not looking at. Reading. She turns a page with one claw.',
            'She glances up. She catches your eye. She raises one scaly eyebrow. There’s a very small, very distinct moment in which you realise that she knows exactly what you’ve noticed.',
          ]),
          _flockChoices(),
          flags: ['seen.look', 'chicken_smart'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'f_want',
          say([
            '“What does she want?” you ask Mervyn. He blinks. “She wants nothing,” he says, “but the best.” He gestures at the people, the straw, the golden eggs in a basket. “We give her everything. She gives us a little egg, each week. We eat the egg. It’s a covenant.”',
            'You notice a small, perfectly arranged set of ledgers beside the throne. Each is labelled: TRIBUTE, EGGS, FOX DEFENCE, TAXES. The handwriting is, you suspect, not a priest’s.',
          ]),
          _flockChoices(),
          flags: ['seen.want', 'saw_ledgers'],
          reward: const Reward(xp: 8),
        ),
        Scene.end('f_go', say([
          'Mervyn leads you through the kneeling rows. The chicken regards you with enormous, level interest. She lifts a claw. A hush falls over the square.',
          '“Approach,” says Mervyn, in a hushed voice. “She will speak.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'throne',
      title: 'THE THRONE',
      km: 1.6,
      art: 'shrine',
      start: 'a',
      reward: const Reward(scrap: 12, xp: 20),
      journal: (c) => ['Her Eggcellency spoke to me, clearly, privately, in a dry, educated voice. She has been running the village for years.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'You step up onto the straw. The chicken leans in. Her beak is the size of a shovel. She opens it, slowly, and in a voice like a retired judge, says: “Good afternoon. I’d be grateful if you didn’t say anything for a moment. Please nod, instead, if you can hear me.”',
            'You nod. She sighs, with relief. “Thank goodness. Someone sensible. Do you have any idea,” she says, “how tiring it is to be worshipped?”',
          ]),
          [
            Choice('[“WHY NOT TELL THEM?”]', 'why'),
            Choice('[“WHAT DO YOU WANT?”]', 'want'),
            Choice('[OFFER TO EXPOSE HER]', 'expose'),
          ],
        ),
        Scene.talk(
          'why',
          say([
            '“If I told them,” says the chicken, “I’d lose my position. I’d be a bird. They’d eat me. I’ve done my sums. At a rough estimate, I’m worth forty-two Sunday roasts.” She shudders. “I’ve managed rather well. The taxes are low, the foxes are kept at bay, and I’ve a very nice view.”',
            '“But you’re deceiving them.”',
            '“I’m governing them,” says the chicken, “which is a very different thing. And they’ve never been happier.”',
          ]),
          [Choice('[CONTINUE]', 'choose')],
        ),
        Scene.talk(
          'want',
          say([
            '“What do I want?” The chicken thinks. “A quiet life. A little respect. Fewer hymns. And, I’ll be frank, a bit more of the good corn. They give me the cheap stuff on Thursdays.”',
            '“That’s all?”',
            '“That’s all,” she says. “It’s the problem with being a god. You get everything and nothing you actually wanted.”',
          ]),
          [Choice('[CONTINUE]', 'choose')],
        ),
        Scene.talk(
          'expose',
          say([
            '“I could tell them,” you say. “It’s not fair, what you’re doing.” The chicken’s eye narrows. For the first time, you see the shape of a very large, very old, very clever creature that has been, for years, afraid.',
            '“You could,” she says, in a low voice. “But think. If you do, it will be an awful scene. Please. Think.”',
          ]),
          [Choice('[CONTINUE]', 'choose')],
        ),
        Scene.talk(
          'choose',
          say([
            'You look at the villagers, kneeling in the straw. You look at the chicken, wise and tired, a little sad. A small girl in the front row catches your eye, and waves, and mouths, very carefully, “Hello, Egg.”',
            'It is, you realise, a very peculiar kind of love.',
          ]),
          [
            Choice('[TAKE THE CROWN]', 'end_crowned'),
            Choice('[TELL THEM THE TRUTH]', 'end_free'),
            Choice('[MAKE A DEAL WITH HER]', 'end_schemed'),
          ],
        ),
        Scene.end('end_crowned', say([
          'You hold up an egg. It’s a very large egg, still warm. “BEHOLD,” you intone, quoting a line the chicken whispers to you, “THE EGG!” The crowd roars. Mervyn weeps. You’re draped in a feathered cape that smells of corn. “You’re very good at this,” the chicken mutters behind you. “Keep it short.”',
        ]), ending: 'crowned'),
        Scene.end('end_free', say([
          '“She can talk,” you tell them. “She’s been running the village. She’s clever. She’s not a god.” Two hundred villagers turn and look at the chicken. The chicken looks back. “Well,” she says. “Rumbled.”',
          'There’s an awful silence. Then, from the front, the small girl says, “Can I still call her Egg?” The chicken closes her eyes. “Yes,” she says, softly. “You may.”',
        ]), ending: 'free'),
        Scene.end('end_schemed', say([
          'You lean close. “A share of the eggs,” you whisper. “And I never tell.” The chicken’s eye gleams. “A share,” she says, “of the second-best eggs. Done.”',
          'You shake claws. She slides a golden egg across the straw. It’s heavy. You put it in your pack, and she goes back to the paper, with the air of a person who has, once again, got away with it.',
        ]), ending: 'schemed'),
      ],
    ),
  ],
);
