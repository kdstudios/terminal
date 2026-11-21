import '../../story_model.dart';
import '../characters/frequency_frank.dart';
import '../story_kit.dart';

// FREQUENCY FRANK: A BAD SIGNAL
// Frank, who is usually wrong, has found something genuinely important. He
// can quote what you found in The Last Transmission (see FrequencyFrank).
// Endings: believed, mocked, assisted.

final StoryDef frankStory = StoryDef(
  id: 'frank',
  title: 'FREQUENCY FRANK: A BAD SIGNAL',
  tagline: 'HE’S BEEN WRONG ABOUT EVERYTHING. THIS TIME HE’S ONLY WRONG ABOUT THE DETAILS.',
  difficulty: 'LOW',
  destinationKm: 1.5,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: ['A shed bristling with aerials. A voice from inside, high and urgent: “DON’T COME IN! WAIT! IT’S FINE! IT’S ONLY THE GOVERNMENT!”'],
  reward: const Reward(scrap: 50, xp: 45),
  endings: {
    'believed': const Ending('believed', 'FRANK WAS RIGHT',
        'You believed him. You checked. For the first time in his life, Frank was right about something that mattered: a landslide, three days away, over a village road. You warned them. They moved. Frank has not stopped smiling. He’s wearing a bigger hat.',
        bonus: Reward(xp: 40, stims: 1), world: ['frank.trusted', 'favour.frank']),
    'mocked': const Ending('mocked', 'LAUGHED AT',
        'You laughed. He turned the dial off. It was a very large, very quiet gesture. The landslide, three days later, took the village road. Nobody died. But a goat did, and Frank, for the first time in his career, did not say “I told you so.”',
        bonus: Reward(), world: ['frank.mocked']),
    'assisted': const Ending('assisted', 'CALIBRATED',
        'You helped him fix his antenna. It was an honest repair, and a good one. Frank’s signal, for the first time in a decade, was clear. The first thing he heard was a woman’s voice, very distant, reading the weather. He wept.',
        bonus: Reward(xp: 35, parts: 1), world: ['frank.trusted']),
  },
  depart: (c) => ['You push open the shed door. It’s dark. A thousand tiny lights blink. “Don’t,” says a whisper. “They know.”'],
  ambient: [
    Ambient('A wire runs from the shed to a tree, from the tree to a rock, from the rock to a very small hat. The hat is wearing a hat.', maxKm: 0.8),
    Ambient('A note on the door: IF YOU ARE FROM THE GOVERNMENT, PLEASE USE THE OTHER DOOR. (THERE IS NO OTHER DOOR.)', maxKm: 1.2),
    Ambient('~Somebody’s always listening. Most of the time it’s only the wind. Not all of the time.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'shed',
      title: 'FRANK’S SHED',
      km: 0.8,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => [
        'Frequency Frank has picked up something. He believes it’s a warning. He’s probably wrong about nearly all of it.',
        if (c.flag('saw_chart')) 'His chart shows the ground to the north moving. It could be real.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...FrequencyFrank.greeting(c),
            'His shed is full of dials, colanders and a very big map. “It’s a signal,” he says. “From the ground. I’ve been listening for six days. It’s not human. It’s a rumble. It repeats. It says something. I think it says: MOVE.”',
          ],
          [
            Choice('[LISTEN TO THE RECORDING]', 'listen'),
            skillChoice('HACKING', 1, 'ANALYSE THE SIGNAL', 'analyse'),
            Choice('[LAUGH]', 'laugh'),
            Choice('[BELIEVE HIM]', 'believe'),
          ],
        ),
        Scene.talk('listen', say(['He plays a tape. A low, slow, repeating rumble, like a stomach the size of a hill. It’s hard to say if it’s a signal or just a very large noise. “It’s the Earth,” whispers Frank. “It’s trying to tell us something.” It goes on for eleven minutes. You don’t know what you’ve heard. You’re faintly uncomfortable.']), [Choice('[CONTINUE]', 'end_s')], flags: ['heard_tape']),
        Scene.talk('analyse', say(['You plot the rumble on a chart. It’s not a signal. It’s a tremor, repeating, and, crucially, growing. The line climbs. In a few days, if it continues, something in the hills to the north is going to give. Frank has, by accident or by genius, recorded the opening of a landslide.']), [Choice('[CONTINUE]', 'end_s')], flags: ['saw_chart', 'checked'], reward: const Reward(xp: 15)),
        Scene.talk('laugh', say(['You laugh. You can’t help it. A man in four hats, with a colander, telling you the Earth’s sending messages. Frank’s face stills. “Fine,” he says. “Fine. Everyone does.” He turns the dial off. It’s the smallest sound you’ve ever heard.']), [Choice('[CONTINUE]', 'end_s')], flags: ['mocked_frank']),
        Scene.talk('believe', say(['“I believe you,” you say. Frank stops. “You do?” “I do.” He sits down very slowly in a chair. “Nobody’s said that,” he whispers, “since 2061.”']), [Choice('[CONTINUE]', 'end_s')], flags: ['believed_frank']),
        Scene.end('end_s', say(['“It’s coming from the hills,” says Frank, in a whisper. “Three days. Or four. We’ve got to tell the village on the north road. They’ll never listen to me. They’ll listen to you.”'])),
      ],
    ),
    Checkpoint(
      id: 'village',
      title: 'THE NORTH ROAD',
      km: 1.5,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['I took Frank’s warning to the village on the north road.'],
      scenes: [
        Scene.talk(
          'a',
          say(['The village on the north road is a handful of huts, a well and a very skeptical headwoman. “Frank?” she says, looking past you. “That man’s been predicting the end for years. Last month it was the moon.” She folds her arms. “What is it this time?”']),
          [
            Choice('[VOUCH FOR FRANK]', 'vouch', show: (c) => !c.flag('mocked_frank')),
            Choice('[ASK THEM TO MOVE ANYWAY]', 'move', show: (c) => !c.flag('mocked_frank')),
            Choice('[HELP FRANK FIX HIS ANTENNA]', 'fix', show: (c) => !c.flag('mocked_frank')),
            Choice('[LEAVE THEM TO IT]', 'end_mocked', show: (c) => c.flag('mocked_frank')),
          ],
        ),
        Scene.talk('vouch', say(['“I’ve checked,” you say. “He’s right. This time.” The headwoman glances at Frank, who is standing on a barrel, in a colander, holding a chart. She sighs. “Oh, all right,” she says. “Move the goats.”']), [Choice('[CONTINUE]', 'end_believed')]),
        Scene.talk('move', say(['“Just for a few days,” you say. “Humour me.” The headwoman narrows her eyes. “For you,” she says. “Not for him.” By dusk the village has been shifted, goats and all, a safe distance away. Frank sits on the hillside, with his chart, and looks, for a long time, at the sky.']), [Choice('[CONTINUE]', 'end_believed')]),
        Scene.talk('fix', say(['Frank’s antenna is a heap of coat-hangers. You straighten it, solder a loose wire, replace a spring. By evening it hums, clean and clear. The first thing Frank hears is a woman’s voice, very far away, reading the weather. He doesn’t say anything for a long time.']), [Choice('[CONTINUE]', 'end_assisted')]),
        Scene.end('end_believed', say(['Three days later, the hills let go. A long brown tongue of mud slides across the north road and covers it, for half a kilometre. The village is empty. The goats are fine. Frank watches it from a ridge with a flask of tea. “I told them,” he says, in a very small voice. “For once, I told them.”']), ending: 'believed'),
        Scene.end('end_mocked', say(['You leave him, and the village, and the shed. Three days later you hear the hills. The road is cut. Nobody’s hurt. A goat is missing. You think of Frank, sitting with a switched-off dial, and wonder whether to go back. You don’t.']), ending: 'mocked'),
        Scene.end('end_assisted', say(['Frank listens to the weather for an hour. Then he turns, takes off one of his four hats, and puts it on your head. “It’s a good one,” he says. “It’s the third.” You wear it out of the shed. It’s, to your absolute astonishment, a warm, comfortable hat.']), ending: 'assisted'),
      ],
    ),
  ],
);
