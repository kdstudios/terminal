import '../../story_model.dart';
import '../story_kit.dart';

// THE MUSHROOM MAN
// Morel believes the mushrooms are communicating with him. Some of his claims
// are more accurate than expected: they warn of a collapse and a tainted well.
// Endings: heeded, ignored, grown.

final StoryDef mushroomStory = StoryDef(
  id: 'mushroom',
  title: 'THE MUSHROOM MAN',
  tagline: 'HE SPEAKS FLUENT FUNGUS. THE FUNGUS IS UNUSUALLY WELL INFORMED.',
  difficulty: 'LOW',
  destinationKm: 1.8,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: ['A man kneels in a cellar full of pale mushrooms, whispering, with his ear pressed to the floor. He raises a finger without looking round. “Shh,” he says. “They’re mid-sentence.”'],
  reward: const Reward(scrap: 55, xp: 50, stims: 1),
  endings: {
    'heeded': const Ending('heeded', 'THE MUSHROOMS WERE RIGHT',
        'You listened. You tested the well. It was tainted. You avoided the collapse by an hour. Morel received an apology from a number of people who had called him mad, and a large basket of apples. He kept the apologies. He ate the apples.',
        bonus: Reward(xp: 40, stims: 1), world: ['morel.heeded']),
    'ignored': const Ending('ignored', 'JUST MUSHROOMS',
        'You told Morel they were only mushrooms. You walked off. At the edge of the road you heard a distant crash and a polite, accusing silence. You do not go back to see. You will not be able to eat a mushroom for a long time.',
        bonus: Reward(), world: ['morel.ignored']),
    'grown': const Ending('grown', 'A CONSULTANT',
        'You became the first human to formally consult the mushrooms. They are, you discover, tremendously good at geology, mostly gloomy, and terribly petty about the topic of rot. You have a small pot of them at home. You ask it about the weather.',
        bonus: Reward(xp: 50, parts: 1), world: ['morel.grown']),
  },
  depart: (c) => ['You descend a staircase that smells of earth and old rain. A long, soft voice murmurs below: “...they’re here. They’re here. Shh.”'],
  ambient: [
    Ambient('A ring of white mushrooms in the road. A tiny hand-lettered sign: DO NOT STEP IN THE CIRCLE. THEY’RE HAVING A MEETING.', maxKm: 0.8),
    Ambient('The cellar walls glow, faintly, a pale blue-green. The glow pulses, in time with your pulse.', maxKm: 1),
    Ambient('A mushroom, quite deliberately, turns to face you as you pass. You are not going to think about it.', minKm: 0.5),
    Ambient('~There are more living things beneath your boots than above them. You’re starting to feel outnumbered.', minKm: 1),
  ],
  checkpoints: [
    Checkpoint(
      id: 'cellar',
      title: 'THE CELLAR',
      km: 0.9,
      art: 'cave',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 14),
      journal: (c) => [
        'Morel the Mushroom Man says the fungus warns him of dangers. He talks to them in a low voice, and they, he says, answer.',
        if (c.flag('heard_warning')) 'They told him the well is tainted and a roof will fall.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The cellar is long, low and thick with fungus: grey shelves, white caps, a fuzz of pale threads. A man named Morel, thin, in a dressing gown covered in spores, rises from his knees. He is carrying a clipboard on which he has been transcribing.',
            '“They’re very well informed,” he says. “Do sit. Not there, that’s Gerald. Not there, that’s a lot of Gerald. Here.”',
          ]),
          [
            Choice('[ASK WHAT THEY SAY]', 'say', show: (c) => !c.flag('heard_warning')),
            skillChoice('SURVIVAL', 1, 'EXAMINE THE FUNGUS', 'exam'),
            Choice('[SCOFF]', 'scoff', show: (c) => !c.flag('scoffed')),
            Choice('[LISTEN WITH HIM]', 'listen'),
          ],
        ),
        Scene.talk(
          'say',
          say([
            '“They’re mostly talking about the soil,” says Morel. “And the rot. They’re terribly keen on rot. But they said something this morning that frightened me.” He consults his clipboard. “The well on the north road is tainted. And the roof of the old mill will come down, soon. They were most insistent.”',
            '“How do you know it’s not nonsense?” “I don’t,” says Morel. “But they were right about the flood.”',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['heard_warning'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'exam',
          say([
            'You crouch beside a shelf. The mushrooms are a single organism: a mat of threads reaching through the soil, linking every cap. Their glow shifts with the weather; they respond to vibrations. You touch the floor and feel, very faintly, a pulse: they’re carrying signals, slowly, like a very old telegraph.',
            'The strange blue patch on the north wall is a map, of a kind: a branching of threads that traces the roads, the wells, the mines. And at one point in the north, the threads have gone dark.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['heard_warning', 'saw_map'],
          reward: const Reward(xp: 14),
        ),
        Scene.talk('scoff', say(['“Talking mushrooms,” you say. “Really.” Morel gives you a soft, patient look. “They said you would say that,” he says. A pale cap, on the shelf behind you, wobbles, as if a very small person had shrugged.']), [Choice('[CONTINUE]', 'a')], flags: ['scoffed']),
        Scene.talk('listen', say(['You kneel and press your ear to the floor. You hear a long, low, rhythmic murmur, like something enormous breathing in its sleep. You can’t tell if it’s the wind. Beside you, Morel nods. “That,” he whispers, “is them. They’ve noticed you. They’re being polite.”']), [Choice('[CONTINUE]', 'end_c')], flags: ['listened']),
        Scene.end('end_c', say(['“We should go,” says Morel, suddenly. “They’re worried. The mill, the well, soon. Will you come?” He is already pulling on a coat.'])),
      ],
    ),
    Checkpoint(
      id: 'mill',
      title: 'THE OLD MILL',
      km: 1.8,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 20),
      journal: (c) => ['At the old mill, the mushrooms’ warning proved to be true.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The old mill stands at the foot of a hill. Under its sagging roof, a family of four has set up camp for the night. A small boy is stirring a pot. A woman sits beside him with a baby.',
            'A long, dry creak runs through the rafters. Morel goes white. “That’s it,” he whispers. “That’s what they said.”',
          ]),
          [
            Choice('[GET THEM OUT]', 'out'),
            Choice('[TEST THE BEAM]', 'beam'),
            Choice('[SAY IT’S NOTHING]', 'nothing'),
          ],
        ),
        Scene.talk(
          'out',
          say([
            '“Everybody out,” you say. “Now.” The family stares. Morel pulls the boy up, and the woman gathers the baby, and the whole group is in the yard within a minute, blinking.',
            'Behind them, with a long, wooden sigh, the roof gives up. It falls in a slow, gentle, almost thoughtful collapse. Dust fills the evening. In the stillness, Morel says, very quietly, “They were right.”',
          ]),
          [
            Choice('[THANK THE MUSHROOMS]', 'end_heeded'),
            Choice('[ASK MOREL TO TEACH YOU]', 'end_grown'),
          ],
          flags: ['saved_family'],
          reward: const Reward(xp: 20),
        ),
        Scene.talk('beam', say(['You tap the beam. It cracks. A hairline of dust drifts from the rafters. You tap it again. The whole roof gives a very small shiver. “Out,” you say. “Now.”']), [Choice('[GET THEM OUT]', 'out')]),
        Scene.talk('nothing', say(['“It’s nothing,” you say. “Old wood.” You turn away. Behind you, Morel makes a very small, wounded sound. You are three paces from the door when the beam, with a groan, breaks.']), [Choice('[RUN BACK]', 'out'), Choice('[KEEP WALKING]', 'end_ignored')]),
        Scene.end('end_heeded', say(['The family, wide-eyed, shares its stew. Morel receives a bow from the small boy. In the cellar that night he tells the mushrooms the whole story. They don’t say much. But a cluster of them, near the door, lights up the brightest blue you’ve ever seen.']), ending: 'heeded'),
        Scene.end('end_ignored', say(['You don’t look back. There’s a noise like a barn clearing its throat. A cry, a rush of dust, a very long silence. You keep walking. It’s a very long road. It’s easy, on a long road, to pretend you can’t hear anything.']), ending: 'ignored'),
        Scene.end('end_grown', say(['Morel takes you back to the cellar and teaches you, patiently, how to put an ear to the earth. It takes a week. By the end you can hear it, a faint, slow, careful murmur, like someone saying your name from a very great depth. You’re given a small pot, with a very small white cap. It has, you realise, already decided it likes you.']), ending: 'grown'),
      ],
    ),
  ],
);
