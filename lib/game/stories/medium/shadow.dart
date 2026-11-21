import '../../story_model.dart';
import '../story_kit.dart';

// THE MAN WHO SOLD HIS SHADOW
// Mr. Penumbra buys and sells shadows with an experimental light-manipulation
// rig (“the Lumen Press”), stored in glass jars. One shadow moves on its own.
// He and his machine can be revisited: see encounters/shadow_return.dart.
//
// Endings: freed, sold, restored, shattered. World facts: shadow.* and
// shadow.sold (you have no shadow: other stories may notice).

List<Choice> _stallChoices() => [
      Choice('[ASK HOW IT WORKS]', 's_how', show: (c) => !c.flag('seen.how')),
      Choice('[ASK WHO SELLS THEIR SHADOW]', 's_who', show: (c) => !c.flag('seen.who')),
      skillChoice('ENGINEERING', 1, 'EXAMINE THE LUMEN PRESS', 's_press'),
      Choice('[LOOK AT THE JARS]', 's_go'),
    ];

final StoryDef shadowStory = StoryDef(
  id: 'shadow',
  title: 'THE MAN WHO SOLD HIS SHADOW',
  tagline: 'HE BUYS YOUR SHADOW. HE SELLS YOUR SHADOW. THE JAR IN THE CORNER IS WAVING.',
  difficulty: 'MODERATE',
  destinationKm: 3.6,
  recommendedLevel: 3,
  scale: StoryScale.medium,
  intro: [
    'A tall, thin man in a long grey coat stands at a crossroads at dusk. He has the stillest face you have ever seen, the sort of face you’d get if you carved a person out of the idea of quiet. He holds a lantern, and the lantern casts no shadow. Neither does he.',
    '“Shadows,” he says, softly, as you approach. “Bought. Sold. Valued at a very fair rate. I am Mr. Penumbra. Have you, by any chance, a spare?”',
    'You look down. Your shadow, a long, lean afternoon of a thing, stretches out behind you. You have never considered it a possession.',
  ],
  reward: const Reward(scrap: 130, xp: 100, stims: 1, parts: 1),
  endings: {
    'freed': const Ending('freed', 'THE SHADOW WALKS',
        'You opened the jar. The restless shadow rose out of it, stretched, looked at you, and slipped into the dusk like a cat. It sends you a note, now and then, written in smoke on a wall. The notes are mostly about how nice it is to be nobody’s.',
        bonus: Reward(xp: 50, stims: 1), world: ['shadow.freed']),
    'sold': const Ending('sold', 'LIGHT OF DAY',
        'You sold your shadow for a very good price. It is a strange, light, slightly thin feeling. You cast nothing. Dogs look at you for a moment too long. Children point. You have, however, an unusually large amount of scrap.',
        bonus: Reward(scrap: 150), world: ['shadow.sold', 'shadow.noshadow']),
    'restored': const Ending('restored', 'A RIGHTFUL SHADOW',
        'You and Mr. Penumbra spent three days tracking the owners of every jar and returning what was theirs. A woman cried when she got her shadow back. She said she had not realised she was colder without it. The rig is quiet now. Mr. Penumbra is, at last, learning how to rest.',
        bonus: Reward(xp: 70, parts: 1), world: ['shadow.restored']),
    'shattered': const Ending('shattered', 'A MESS OF SHADOWS',
        'You broke the Lumen Press. Every jar cracked at once and a hundred shadows spilled out across the dust like ink. They have not quite settled. In the dusk, the ground seems to be made of watching things. The wasteland is a darker place now, and somehow, a little more honest.',
        bonus: Reward(xp: 40, parts: 2), world: ['shadow.shattered']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You set out in the long light of early evening. Your shadow follows, long and meek. You feel, for no reason, a pang of protectiveness.']
      : ['The lantern at the crossroads glows ahead. As you approach, your shadow shrinks very slightly, like a dog that doesn’t like the vet.'],
  ambient: [
    Ambient('Your shadow lags half a step behind you. When you stop, it takes a moment to stop.', maxKm: 1.5),
    Ambient('A scarecrow stands in the dusk. It has no shadow. It looks vaguely smug.', maxKm: 2),
    Ambient('You pass a woman who is looking at the ground with an expression of deep loss. She has no shadow. She doesn’t seem to know why she’s sad.', maxKm: 2),
    Ambient('A dog barks at your shadow. Your shadow, for a moment, looks very slightly offended.', minKm: 0.5, maxKm: 3),
    Ambient('~A shadow is just where the light isn’t. It’s odd how much that sounds like a person.', minKm: 1.5),
    Ambient('Somewhere in the dark, a small, glassy tinkle, like a jar being tapped from the inside.', minKm: 1.5, maxKm: 3.5),
    Ambient('Your shadow stretches toward the stall ahead. You pull it back. It doesn’t want to be pulled.', minKm: 2, when: (c) => c.done('stall')),
    Ambient('The lantern flickers. For an instant, every shadow on the hillside points the wrong way.', minKm: 2.5),
  ],
  checkpoints: [
    Checkpoint(
      id: 'stall',
      title: 'THE STALL',
      km: 1.2,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 20),
      journal: (c) => [
        'Mr. Penumbra buys and sells shadows, using a light-manipulation rig he calls the Lumen Press.',
        if (c.flag('seen.who')) 'He says he buys shadows from the sad, the desperate and the merely curious.',
        if (c.flag('seen.how')) 'The Press lifts a shadow off the ground like a sheet and rolls it into a glass jar.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The stall is a table with a cloth, a stool and a very large, very odd machine. The machine is a thicket of lenses, mirrors and brass, around a flat steel plate. It looks like a loom made of light. A lantern hangs above it, humming.',
            'Behind the table is a shelf of glass jars, each the size of a loaf. In each, a different shape, a flat, dark, flowing thing like an ink-drawing of a person. Some are lying down. One is standing up, with its hands on the glass.',
            '“Welcome,” says Mr. Penumbra, with a small, gentle, ghostly bow. “May I offer a demonstration?”',
          ]),
          _stallChoices(),
        ),
        Scene.talk(
          's_how',
          say([
            '“It’s simple,” says Mr. Penumbra. “A shadow is information. A record of where light has been refused. The Lumen Press catches it. It lifts it off the ground, like a sheet from a bed, and rolls it, and stores it. The jar keeps it dry.”',
            '“And the person?”',
            '“The person,” says Mr. Penumbra, “is slightly lighter. Not a great deal. A few ounces. Nobody notices for years.” He smiles his still, mild smile. “Most of them are quite relieved.”',
          ]),
          _stallChoices(),
          flags: ['seen.how'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          's_who',
          say([
            '“Who sells?” you ask. “The sad,” says Mr. Penumbra. “The poor. The curious. The ones who’d rather not be followed. A man sold his because it reminded him of his father. A woman, because it wouldn’t stop doing her sister’s voice. A child, because a stranger told her it would make her invisible.”',
            'He taps the glass. “I paid them all. I paid them fairly.”',
            'His expression doesn’t move. It’s a very still face. But something behind it flickers, like a light under a door.',
          ]),
          _stallChoices(),
          flags: ['seen.who', 'penumbra_guilt'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          's_press',
          say([
            'You lean in and look at the Lumen Press. It’s astonishing: a clean, brass-and-glass array of lenses, each one hand-ground, all of them focused on a single point on the steel plate. It’s a machine for bending light round a body until the dark is all that’s left.',
            'There’s a small, hand-lettered plaque on the base: NOT TESTED ON HUMANS. And, scratched underneath, in a different hand: SORRY.',
            '“It was built,” says Mr. Penumbra, quietly, “for a very different purpose. But I was always better at this one.”',
          ]),
          _stallChoices(),
          flags: ['seen.press', 'knows_press'],
          reward: const Reward(xp: 12),
        ),
        Scene.end('s_go', say([
          'You step toward the shelf. Mr. Penumbra says nothing. The jars cast tiny, shifting shapes on your face. And among them, in the third row, one of them is waving, with a small, quick, frantic motion, as if it has been trying for a very long time to catch your eye.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'jars',
      title: 'THE JARS',
      km: 2.4,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 12, xp: 25),
      journal: (c) => [
        'One of the shadows moves independently. It can write in the dust of the jar.',
        if (c.flag('shadow_talked')) 'It told me it’s not anyone’s shadow. It’s not attached to anyone. It was made when the Press malfunctioned.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'You pick up the jar. The shadow inside is a thin, quick, restless thing. It presses its hands to the glass, and a faint pale tracery, like frost, appears where its fingers rest. It writes, in the condensation, with a long finger: HELLO.',
            '“Ah,” says Mr. Penumbra, behind you. His voice has changed. “You’ve found her. She’s not for sale. I’ve told her that.”',
            'She writes again. HE MEANS HE’S NOT ALLOWED TO.',
          ]),
          [
            Choice('[TALK TO THE SHADOW]', 'talk'),
            Choice('[ASK MR. PENUMBRA]', 'ask'),
            Choice('[LOOK FOR THE OWNER’S LABEL]', 'label'),
          ],
        ),
        Scene.talk(
          'talk',
          say([
            'You hold the jar to the lantern light. The shadow writes, with quick, tidy, rain-on-glass letters. I AM NOT ANYONE’S. I WAS A MISTAKE. HE WAS TRYING TO TAKE A SHADOW FROM A MAN WHO HAD TWO, AND THE MACHINE MADE ME UP IN BETWEEN. I’VE BEEN IN THIS JAR FOR FIFTEEN YEARS.',
            'She stops. She writes: IT IS VERY DARK IN HERE, EVEN FOR ME.',
            'It’s the saddest line you’ve ever read. And it’s hard to know whether you’re looking at a person or a very good trick.',
          ]),
          [
            Choice('[ASK MR. PENUMBRA]', 'ask'),
            Choice('[PROMISE TO HELP]', 'promise', flags: ['promised_shadow']),
          ],
          flags: ['shadow_talked'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'ask',
          say([
            'Mr. Penumbra takes a long time to answer. “She’s an error,” he says, at last. “I made her by accident. I didn’t know what to do. She moved. She wrote. I was afraid. I’ve kept her ever since, in case someone came who knew what she was.”',
            '“Do you know what she is?”',
            '“No,” he says. “But I know what she wants. She wants out. And I’m a coward. It’s a very small, very ordinary thing to be.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['asked_penumbra'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'label',
          say([
            'You turn the jar. There’s a small card tied to the neck, in careful copperplate: OWNER: NONE. ORIGIN: SPONTANEOUS. STATUS: DO NOT SELL. Below that, scrawled: DO NOT FEED AFTER MIDNIGHT. You aren’t sure that’s a joke.',
            'Behind the other jars, a card on each. OWNER: ANNA. OWNER: TOBY. OWNER: A. DREW (DECEASED). Every one is a name. Every one is a person who’s missing a little something.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['saw_labels'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'promise',
          say([
            'You whisper to the jar, “I’ll get you out.” The shadow presses both hands to the glass. The frost on it forms a very small, shaky heart.',
            'Mr. Penumbra watches, with his unmoving face. “Be careful what you promise,” he says. “They remember.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
        ),
        Scene.end('out', say([
          'Mr. Penumbra leads you to the back of the stall, to the Lumen Press, where it hums under a canvas. “If you’re going to do something,” he says, in his quiet, tired, stage-managed voice, “you’d better do it here.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'press',
      title: 'THE LUMEN PRESS',
      km: 3.6,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 35),
      journal: (c) => ['At the Lumen Press, I had to decide what to do about the shadows, and about my own.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The canvas comes off. The Press blazes in the dusk, lenses glinting, brass hot. Around it, the jars shiver on their shelves, every shadow turned toward the light, like a congregation.',
            '“Here we are,” says Mr. Penumbra. “Four possibilities. The jar can be opened. The shadows can be returned. The Press can be broken. Or...” He glances at your feet. “The Press has been hungry for some time. It would pay very well for yours.”',
            if (c.flag('promised_shadow')) 'In the third row, a small, frantic shape presses its hands against the glass and waits.',
          ],
          [
            Choice('[OPEN THE JAR]', 'free'),
            Choice('[RETURN THE SHADOWS]', 'restore'),
            Choice('[SELL YOUR SHADOW]', 'sell'),
            Choice('[BREAK THE PRESS]', 'break'),
          ],
        ),
        Scene.talk(
          'free',
          say([
            'You unscrew the lid. For a moment, nothing happens. Then, with a long, trembling sigh, the shadow rises, unrolls itself across the dust like ink spreading in water and, slowly, stretches both arms to the sky.',
            'It writes on the ground, in a long, slow, delighted loop of letters: THANK YOU. And then, a heartbeat later, it is gone, a slip of shape across the evening, up and over the hill.',
            'Mr. Penumbra watches it go. A very small thing happens to his face. It might be a smile.',
          ]),
          [Choice('[CONTINUE]', 'end_freed')],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'restore',
          say([
            '“They’re all labelled,” you say. “We could take them home.” Mr. Penumbra says nothing for a long moment. Then, “It would take weeks. I’d be asked for an apology a hundred times over. They might not want them back.”',
            '“Some will.”',
            'He takes down the first jar. His hand shakes. “Anna,” he reads. And, for the first time, his voice breaks. “I took this from a girl of nine. She sold it for a sweet.”',
          ]),
          [Choice('[HELP HIM]', 'end_restored')],
          flags: ['began_restoring'],
        ),
        Scene.talk(
          'sell',
          say([
            '“A very good price,” says Mr. Penumbra, gently. He sets a heavy bag of scrap on the table. “It doesn’t hurt. You will hardly notice. Most people say it’s like taking off a heavy coat.”',
            'You stand on the plate. The lenses shift. A clean, cold, very bright light moves over you, and for a moment you feel a pull, as if somebody were removing something from the floor.',
            'And then, with a soft rustle, your shadow rises, folds itself, and slides into a jar.',
          ]),
          [
            Choice('[TAKE THE SCRAP]', 'end_sold'),
            Choice('[CHANGE YOUR MIND]', 'a'),
          ],
        ),
        Scene.talk(
          'break',
          say([
            'You pick up a heavy spanner. “Don’t,” says Mr. Penumbra, mildly. “It will make a great deal of mess.” But he doesn’t move to stop you. You bring the spanner down on the nearest lens. It breaks with a sound like a bell.',
            'A line of cracks runs through the Press. The jars begin to shiver. And all along the shelf, a hundred small, glassy voices begin, very faintly, to sing.',
          ]),
          [Choice('[KEEP SWINGING]', 'end_shattered')],
        ),
        Scene.end('end_freed', say([
          'You leave Mr. Penumbra standing among his jars in the lantern light, with the lid of an empty jar in his hand. “I’ll keep the rest,” he says. “For now. I think I’ll see about the owners.”',
          'Over the next month, you find the shadow’s notes on walls, in smoke or frost: IT’S BIG OUT HERE. I FOUND A SUNSET. THERE ARE SO MANY OF THEM. It’s the first time you’ve ever envied something that wasn’t alive.',
        ]), ending: 'freed'),
        Scene.end('end_restored', say([
          'It takes three days. You ride a trader’s cart from camp to camp, with a case of jars and a very quiet man. Some people weep. Some people slam the door. A man in a wheelchair takes his shadow in both arms, like a lost dog, and holds it so long you have to look away.',
          'At the end, one jar is left. It’s the empty one. Mr. Penumbra puts it on the shelf, and, for the first time, you see him take off the long grey coat.',
        ]), ending: 'restored'),
        Scene.end('end_sold', say([
          'The scrap is heavy. Your feet feel very light. You walk away over the dusk-lit road, and for the first time in your life nothing follows you. It’s a very lonely, very restful feeling.',
          'Halfway to the horizon, you pause. You look back. A single jar, on a table, is glowing with a long, dark, very familiar shape, one hand on the glass, waving.',
        ]), ending: 'sold'),
        Scene.end('end_shattered', say([
          'The Press shrieks. Every jar bursts. A hundred shadows pour across the dusk like a spilled inkwell, and rush off in every direction, laughing, or screaming, or something in between.',
          'When it’s done, you and Mr. Penumbra sit in the wreckage. “Well,” he says, very quietly. “That’s done, then.” He watches a shadow run up a wall and over a roof. “I rather feel,” he says, “that I’ve been let out, too.”',
        ]), ending: 'shattered'),
      ],
    ),
  ],
);
