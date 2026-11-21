import '../../story_model.dart';
import '../story_kit.dart';

// THE MAN IN THE MOON
// Orville Pike has built an enormous dish and believes the moon is talking
// to him. The messages begin as maintenance reports. Then a status request
// arrives: someone on the moon is asking whether it is safe to come home.
//
// Interpretations on offer: hoax, automation, survivors, Orville’s own
// longing. Endings: safe, stay, silence, friend.

List<Choice> _dishChoices() => [
      Choice('[ASK ORVILLE ABOUT THE DISH]', 'd_dish', show: (c) => !c.flag('seen.dish')),
      Choice('[ASK WHAT THE MOON SAYS]', 'd_moon', show: (c) => !c.flag('seen.moon')),
      skillChoice('ENGINEERING', 1, 'CHECK THE DISH’S ALIGNMENT', 'd_align'),
      Choice('[LISTEN IN]', 'd_go'),
    ];

final StoryDef moonStory = StoryDef(
  id: 'moon',
  title: 'THE MAN IN THE MOON',
  tagline: 'ONE MAN, ONE ENORMOUS DISH, AND SOMETHING UP THERE THAT KEEPS SAYING “STATUS: NOMINAL.”',
  difficulty: 'MODERATE',
  destinationKm: 8.0,
  recommendedLevel: 3,
  intro: [
    'You see it from three kilometres away: a bowl of bent steel the size of a barn, propped on a hillside with scaffolding and optimism, pointing at nothing in particular.',
    'Someone has painted a smiling face on the dish in white house paint. It’s smiling at the sky, and the sky, as far as you can tell, isn’t smiling back.',
    'The man who built it is called Orville Pike. He has told every passing trader the same thing: that the Moon has been talking to him, and that it’s been saying something very ordinary and very strange. “It’s just reports,” he says. “It’s all just reports. But who’s writing them?”',
  ],
  reward: const Reward(scrap: 170, xp: 120, stims: 1, picks: 1, parts: 1),
  endings: {
    'safe': const Ending('safe', 'COME HOME',
        'You told them it was safe. Perhaps that was kind. Perhaps it was a very large mistake. Seven weeks later, a bright, steady light came down out of the sky and landed in a field, and the wasteland discovered it had visitors it was not remotely ready for.',
        bonus: Reward(xp: 80, parts: 2), world: ['moon.safe']),
    'stay': const Ending('stay', 'STAY WHERE YOU ARE',
        'You told them to wait. The moon, in a long careful message, thanked you and said they’d keep the lights on. Orville listens to them every night, and they ask after him. It is, he says, the best long-distance friendship he’s ever had.',
        bonus: Reward(xp: 60), world: ['moon.stay']),
    'silence': const Ending('silence', 'RADIO SILENCE',
        'You switched off the dish. It was heartbreaking, and it was quick, and it was probably wise. Orville sat in the cabin with his head in his hands for a long time. Then he made two cups of tea and asked if you’d like to talk about something else.',
        bonus: Reward(scrap: 90), world: ['moon.silence']),
    'friend': const Ending('friend', 'HELLO, ORVILLE',
        'The moon answered Orville, by name. It said a great many gentle, personal things. They were, you realise, the sort of thing a lonely man needs to hear from the sky. Nobody can say whether they were true. He is the happiest person you have ever seen.',
        bonus: Reward(xp: 70, stims: 1), world: ['moon.friend']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You pack a flask, a notebook and a scientific attitude. You do not pack an umbrella. You really should have.']
      : ['The dish rises on the horizon like a bowl waiting for a very large soup.'],
  ambient: [
    Ambient('A cable runs along the road, pinned with clothes pegs, and disappears over the hill toward the dish. Every peg has a note: THIS WAY TO THE MOON.', maxKm: 3),
    Ambient('Your ears pop. The air hums with a faint, regular tick, like a clock in another room.', maxKm: 3),
    Ambient('Someone has written in huge rock letters on a hillside: HELLO. They have then added, smaller: (UP THERE).', maxKm: 4),
    Ambient('A scrawny dog sits at the foot of the dish and howls, in perfect time, at the dish.', minKm: 1, maxKm: 4),
    Ambient('You glance up. The moon, in the afternoon, is a pale smudge. It looks unwell.', minKm: 1.5, maxKm: 5),
    Ambient('#...MAINTENANCE CYCLE 41,772 COMPLETE. FILTER REPLACEMENT RECOMMENDED. HAVE A LOVELY DAY.', minKm: 2),
    Ambient('~A signal from space, for a very lonely man. It’s either the best joke or the saddest thing in the world.', minKm: 3, when: (c) => c.done('cabin')),
    Ambient('You find yourself looking up at the sky more often than you usually do.', minKm: 4),
    Ambient('Orville’s voice in your memory: “They never say hello. But they say goodnight.”', minKm: 4.5, when: (c) => c.flag('seen.moon')),
    Ambient('A coffee cup sits on a rock. Written on it: FOR THE ONES UP THERE. NO SUGAR. THEY’RE WATCHING THEIR WEIGHT.', minKm: 5.5),
    Ambient('A pulse of static rolls through the air. It’s very regular. It is eleven seconds from the last.', minKm: 6.5),
    Ambient('A hush falls over the hillside. Even the wind stops, as if listening.', minKm: 7.5),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'dish',
      title: 'THE DISH FROM AFAR',
      km: 1.5,
      text: (c) => [
        'From the ridge you can see the whole contraption: the bent steel bowl, the scaffolding, the cabin beneath, the cables snaking across the field like dropped spaghetti. A tiny figure in a woolly hat is on the scaffold, hanging by one hand, adjusting something with a spoon.',
        'The dish tilts a degree. The figure shouts down to someone you can’t see. “IT’S MOVED! IT’S MOVED AGAIN!”',
        '~Either a man has found the universe, or the universe has found a man.|',
      ],
      journal: say(['A huge dish on a hillside. A man in a woolly hat hung from the scaffolding, shouting that something had moved.']),
      reward: const Reward(xp: 8),
    ),
    Checkpoint(
      id: 'cabin',
      title: 'ORVILLE’S CABIN',
      km: 3.0,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 25),
      journal: (c) => [
        'Orville Pike is gentle, lonely and brilliant in a messy way. He built the dish from a farm’s grain silo, a television aerial and a great deal of tape.',
        if (c.flag('seen.moon')) 'He says the moon sends maintenance reports. “They never say hello. But they say goodnight.”',
        if (c.flag('aligned')) 'I corrected the dish’s alignment. It started receiving more clearly at once.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The cabin is warm and cluttered: wires, coffee mugs, an enormous map of the night sky with pins in it. Orville Pike is tall and stooped, with a woolly hat and eyes like a night-shift baker’s. He shakes your hand as if he’s afraid you’re an apparition.',
            '“You’re real,” he says. “Good. I’ve been talking to a lot of things that aren’t. Please, sit. Tea? I only have the one cup, so you’ll have to drink first, and then I’ll wash it.”',
            'A speaker in the corner hisses faintly. “That’s them,” he says. “They’re on now. Listen.”',
          ]),
          _dishChoices(),
        ),
        Scene.talk(
          'd_dish',
          say([
            '“I built it from a grain silo,” says Orville. “And a television aerial. And a hundred and twelve metres of cable and, well, a certain amount of hope. It’s too big. It’s unstable. The wind knocks it out of true, so I climb up and nudge it with a spoon.”',
            '“A spoon.”',
            '“A big spoon.” He pauses. “There’s no one to ask. I taught myself everything from a library book on radio astronomy. It’s a surprisingly slim volume.”',
          ]),
          _dishChoices(),
          flags: ['seen.dish'],
        ),
        Scene.talk(
          'd_moon',
          say([
            '“What does it say?” you ask.',
            'Orville sits down very slowly. “It says: MAINTENANCE CYCLE COMPLETE. FILTER REPLACEMENT RECOMMENDED. STATUS NOMINAL. Over and over. Forty thousand times. It sounds like a person, but it’s not. It’s a machine, I’m sure. But every night, at the end, there’s a line I can’t explain. It says: AWAITING REPLY.”',
            '“To what?”',
            '“To nothing,” he says. “To no one. And that’s the thing. I’ve never answered. I don’t know how. I don’t know if it would be rude. It’s been awaiting a reply for forty years.”',
            'He looks at you with enormous, hopeful, embarrassed eyes. “It’s probably nothing,” he says.',
          ]),
          _dishChoices(),
          flags: ['seen.moon', 'awaiting'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'd_align',
          say([
            'You climb the scaffolding with a wrench. Orville is right: the dish is out of true by half a degree, and the whole thing wobbles like a spoon on a plate. You tighten four bolts, shim a strut with a tin lid and walk the bowl round by hand.',
            'On the ground, the speaker goes from a hiss to a thin, clean, steady tone. The words become clearer. “IT’S CLEARER,” cries Orville. “IT’S SO MUCH CLEARER! You’ve done it! You’ve done what the spoon couldn’t!”',
          ]),
          _dishChoices(),
          flags: ['aligned'],
          reward: const Reward(xp: 15),
        ),
        Scene.end('d_go', say([
          'Orville turns the dial. The speaker brightens. And over a very faint, very regular crackle, a calm, patient, almost kindly voice begins to speak.',
          '#GOOD EVENING. LUNAR RELAY THREE REPORTING. BATTERY AT 82%. FILTER REPLACEMENT RECOMMENDED. STATUS: NOMINAL.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'reports',
      title: 'THE REPORTS',
      km: 4.8,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 30),
      journal: (c) => [
        'We listened to the transmissions all night. They’re automated maintenance reports from a lunar relay. They’re also, subtly, not.',
        if (c.flag('decoded')) 'I decoded the packet headers. They are addressed to a human recipient.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'You sit with Orville through the night, in the cabin, with a notebook and two cups of cold tea. The messages come at regular intervals: BATTERY. FILTER. STATUS. There’s a comfort in their rhythm. It’s like a very patient clock.',
            'Around midnight, the report changes. #LUNAR RELAY THREE REPORTING. BATTERY AT 82%. FILTER REPLACEMENT RECOMMENDED. SURFACE TRAFFIC: NONE. SURFACE TRAFFIC: NONE. SURFACE TRAFFIC: NONE. A pause. #...HELLO?',
            'Orville’s tea cup rattles in its saucer. “That,” he whispers, “is new.”',
          ]),
          [
            Choice('[ANALYSE THE SIGNAL]', 'analyse'),
            Choice('[SUGGEST IT’S A HOAX]', 'hoax'),
            Choice('[SUGGEST IT’S AUTOMATED]', 'auto'),
            Choice('[ANSWER IT]', 'answer'),
          ],
        ),
        Scene.talk(
          'analyse',
          (c) => [
            'You lay out the signal on a sheet of paper. The reports are machine: packets, headers, checksums. But the new line, “HELLO?”, isn’t a template. It’s been typed. It has an unneeded, hopeful question mark.',
            if (c.skill('HACKING') >= 1)
              'You pull a header from the packet. It’s addressed. Not to a general broadcast. To a name: SURFACE CONTACT. PLEASE CONFIRM RECEIPT. A human wrote this. Or, a human wrote the part of the machine that wrote this.',
            if (c.skill('ENGINEERING') >= 1) 'The transmitter is real. It’s a high-gain array, on a power budget of forty years’ solar, and it’s been aimed, with remarkable patience, at this exact hillside.',
            'Orville stares at your notes. “So it’s real,” he says. “Something’s up there. And it said hello.”',
          ],
          [Choice('[CONTINUE]', 'out')],
          flags: ['decoded', 'analysed'],
          reward: const Reward(xp: 18),
        ),
        Scene.talk(
          'hoax',
          say([
            '“It could be a hoax,” you say. “Somebody with a transmitter, some free time.”',
            'Orville’s face falls. Then it rises, bravely. “That’s a perfectly reasonable thing to suggest,” he says. “I’ve suggested it myself. Often. At three in the morning. To the moon. It never says anything back.”',
            'He wipes his eyes with the back of his hat. “It’s just, the hoax would have to be forty years old. And very, very committed.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['said_hoax'],
        ),
        Scene.talk(
          'auto',
          say([
            '“It’s a script,” you say. “A very old, very stubborn one. It sends a status, and then, if it doesn’t get a reply, it asks. That’s all it is.”',
            '“That’s what I thought,” says Orville, softly. “For years. But it’s changed. It’s started asking nicer.”',
            'He doesn’t say it as a point. He says it like someone noticing, with deep sadness, a person who has begun to speak more kindly to them.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['said_auto'],
        ),
        Scene.talk(
          'answer',
          say([
            'Orville’s hand shakes on the microphone. “I couldn’t,” he says. “What would I say?”',
            '“Say hello,” you tell him.',
            'He clears his throat. He holds the microphone with both hands. “Hello,” he says. “This is Orville. I’m... on the surface. I’m... fine.”',
            'The speaker hisses. The two of you hold your breaths. And, after a pause that seems to last a week, the voice says, in a very small voice: #...HELLO. OH. HELLO. WE HAVE BEEN SO LONELY.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['answered'],
          reward: const Reward(xp: 25),
        ),
        Scene.end('out', say([
          'The night wears on. The voice speaks, and Orville listens, and the two of you piece it together. By dawn there’s a message waiting, in clear, formal English, for the first time in forty years.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'message',
      title: 'THE MESSAGE',
      km: 6.4,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 35),
      journal: (c) => [
        'The moon asked a question: IS THE SURFACE SAFE TO RETURN TO? It has been asking for forty years.',
        if (c.flag('knows_who')) 'There are living people on the Moon. Eleven of them. They’ve been waiting.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The message comes through as the sun rises, slowly, line by line, in a voice like a woman reading a bedtime story.',
            '#THIS IS THE LUNAR HABITAT AND RELAY STATION. WE ARE ELEVEN PERSONS. WE ARE WELL. WE HAVE RATIONS FOR THREE MORE YEARS AND A GARDEN OF ABOUT TWO SQUARE METRES. WE HAVE BEEN CALLING FOR FORTY YEARS. IS THE SURFACE SAFE TO RETURN TO? PLEASE REPLY. WE ARE VERY TIRED. WE ARE VERY HOPEFUL.',
            'Orville is crying. He does it quietly, carefully, like a man who’s been told he mustn’t make a fuss. “They’re alive,” he says. “They’re alive. They’ve been up there the whole time. And I said nothing.”',
          ]),
          [
            Choice('[ASK WHO THEY ARE]', 'who', show: (c) => !c.flag('knows_who')),
            Choice('[ASK HOW THEY’VE SURVIVED]', 'how', show: (c) => !c.flag('knows_how')),
            Choice('[CONSIDER WHAT TO SAY]', 'out'),
          ],
        ),
        Scene.talk(
          'who',
          say([
            'You send the question. The reply comes in a few minutes, almost shy: #WE ARE ENGINEERS, A DOCTOR, A GARDENER, A SCHOOLTEACHER AND SIX CHILDREN WHO WERE BORN HERE. THE CHILDREN HAVE NEVER SEEN ANYTHING GREEN. THEY HAVE DRAWN IT.',
            'A grainy image comes through. It is a child’s crayon drawing of a tree, with fruit that looks like planets.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['knows_who'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'how',
          say([
            'You ask. They tell you. Hydroponics. Reclaimed water. A very old reactor. And a long, patient rota of people taking it in turns to be the one who stays awake and listens.',
            '#WE TAKE IT IN TURNS TO SEND THE REPORTS, they add. #IT MAKES US FEEL LIKE SOMEONE IS EXPECTING THEM.',
            'Orville puts his hand over his mouth. “I am,” he says. “I have been. I didn’t know how to say.”',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['knows_how'],
          reward: const Reward(xp: 12),
        ),
        Scene.end('out', say([
          'You sit down beside Orville, with the sun full in the cabin. Eleven people are waiting for your answer. The dish creaks on its scaffolding. Orville holds out the microphone.',
          '“Whatever you say,” he whispers, “I’ll go along with. It’s your call. You’re the one who understands it.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'reply',
      title: 'THE REPLY',
      km: 8.0,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 30, xp: 50),
      journal: (c) => ['I had to decide how to answer a question asked for forty years: is the surface safe?'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The microphone is a warm, scuffed lump of plastic. A long silence fills the cabin. Eleven people are waiting. Six of them are children who have never seen the sky from underneath.',
            '“It’s not safe,” says Orville, miserably. “It’s not, is it? The radiation, the raiders. A lot of the world is a dead field. But it’s also,” he says, helplessly, “the only world there is.”',
            'He looks at you. “I don’t know what to say. I don’t know what’s kind.”',
            if (c.flag('said_hoax')) 'You mention again that it could still be a hoax. Orville gives you a look of gentle, devastated courtesy.',
          ],
          [
            Choice('[“IT’S SAFE. COME HOME.”]', 'safe'),
            Choice('[“STAY. WE’LL KEEP IN TOUCH.”]', 'stay'),
            Choice('[SWITCH IT OFF]', 'off'),
            Choice('[LET ORVILLE TALK]', 'friend'),
          ],
        ),
        Scene.talk(
          'safe',
          say([
            'You take the microphone. “It’s safe,” you say. “It’s not perfect. It’s not easy. But there’s grass, and there’s water, and there’s people. Come home.”',
            'There’s a very long pause. Then, a sound you’ve never heard before: eleven people, forty years apart, crying all at once, through a speaker, in a little cabin on a hill.',
            '#THANK YOU, says the voice. #WE WILL BEGIN PREPARATIONS. WE HAVE A VESSEL. IT HAS NOT BEEN FLOWN IN A LONG TIME.',
          ]),
          [
            Choice('[WAIT FOR THEM]', 'end_safe'),
            Choice('[ADD “BRING SNACKS”]', 'end_safe'),
          ],
          reward: const Reward(xp: 20),
        ),
        Scene.talk(
          'stay',
          say([
            'You take the microphone. “Not yet,” you say. “It’s not ready. But we’re here. We’re listening. We’ll tell you when. And in the meantime, you’ve got a friend. His name’s Orville. He’s very good with a spoon.”',
            'A long hush. Then a small, wet laugh. #WE’D LIKE THAT VERY MUCH, says the voice. #IT’S THE FIRST TIME ANYONE’S HAD A NAME.',
          ]),
          [Choice('[LET THEM TALK]', 'end_stay')],
          reward: const Reward(xp: 20),
        ),
        Scene.talk(
          'off',
          say([
            'You put your hand on the master switch. Orville watches you. He doesn’t stop you. He doesn’t say a word. You can see it in his face: he’d rather the dish be silent and the moon be safe than the moon be hurt.',
            '“It’s not right,” you say. “It’s not right to give them hope we can’t honour.”',
            '“I know,” says Orville. He doesn’t sound angry. He sounds like a man who’s been told his dog is very old.',
          ]),
          [
            Choice('[THINK AGAIN]', 'a'),
            Choice('[SWITCH IT OFF]', 'end_silence'),
          ],
        ),
        Scene.talk(
          'friend',
          say([
            'You hold out the microphone. Orville takes it. His hands are steady for the first time since you met him.',
            '“Hello,” he says. “It’s Orville. I’m... I’m not sure what to tell you. I don’t know if the world’s safe. But I’m here, and I’ve been listening for a long time. I’d like to hear about the garden.”',
            'And they tell him. For an hour. They tell him about the crops and the children and the shape of the Earth from up there, small and blue and unbelievably far away. And at the end, a woman’s voice says, very softly: #GOODNIGHT, ORVILLE. WE’VE BEEN WAITING FOR YOU.',
          ]),
          [Choice('[LET THEM BE]', 'end_friend')],
          flags: ['orville_spoke'],
          reward: const Reward(xp: 25),
        ),
        Scene.end('end_safe', say([
          'It takes seven weeks. On the morning of the forty-ninth day, a bright steady star descends on a column of white fire, over the eastern ridge, and settles in a field, quietly, like a bird. A hatch opens. A small boy steps out, blinking. He looks at the grass. He looks at the sky. He bursts into tears.',
          'Orville is there to meet them with a flask of tea. He has only the one cup. He has been practising how to share it.',
          '~You’ve changed the world. You can’t be sure whether you’ve helped it.',
        ]), ending: 'safe'),
        Scene.end('end_stay', say([
          'Every evening, as the sun sets, Orville adjusts the dish with a spoon and sits down by the speaker with a cup of tea. “Good evening,” he says. “Lunar Relay Three, I presume?” And the moon says, in a warm, tired, familiar voice: #GOOD EVENING, ORVILLE.',
          'They’ve begun to send him pictures. Crayon drawings of trees, mostly. He’s pinned them all to the cabin wall.',
        ]), ending: 'stay'),
        Scene.end('end_silence', say([
          'You flip the switch. The speaker’s hiss falls to nothing. The dish, on its scaffolding, creaks back to a resting position, like a dog lying down. The cabin is very quiet.',
          'Orville sits for a long time. Then he gets up and puts the kettle on. “Do you take sugar?” he asks. “I’ve forgotten. I’ve forgotten how to ask.”',
        ]), ending: 'silence'),
        Scene.end('end_friend', say([
          'You leave him there. Through the cabin window you see Orville in his chair, the microphone in his hands, talking and laughing and, every so often, wiping his eyes.',
          'Later you pass the dish and notice that someone has repainted the smile. It looks, if anything, a little more certain.',
        ]), ending: 'friend'),
      ],
    ),
  ],
);
