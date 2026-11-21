import '../../story_model.dart';
import '../story_kit.dart';

// OPERATION: FREEZER BURN
// Dr. Ada Lindqvist, a cryogenic scientist, wakes from suspension certain it
// is still 2077. The facility holds more pods, and they are running out of power.
//
// Comedy: Ada’s misunderstandings of the modern wasteland. Ethics: who
// (if anyone) to wake. Endings: wakeall, wakeone, sleep, ada.

List<Choice> _wakeChoices() => [
      Choice('[TELL HER WHAT YEAR IT IS]', 'w_year', show: (c) => !c.flag('seen.year')),
      Choice('[ANSWER HER QUESTIONS ABOUT THE WORLD]', 'w_world', show: (c) => !c.flag('seen.world')),
      Choice('[ASK ABOUT THE OTHER PODS]', 'w_pods', show: (c) => !c.flag('seen.pods')),
      Choice('[HELP HER OUT OF THE LAB]', 'w_go'),
    ];

final StoryDef freezerStory = StoryDef(
  id: 'freezer',
  title: 'OPERATION: FREEZER BURN',
  tagline: 'SHE WENT TO SLEEP IN 2077. SHE WOULD LIKE TO KNOW WHY THE FLOOR IS DIFFERENT.',
  difficulty: 'MODERATE',
  destinationKm: 9.0,
  recommendedLevel: 4,
  unlock: const Unlock(minLevel: 3, hint: 'REACH LEVEL 3.'),
  intro: [
    'The cave mouth is frosted white, in the middle of the desert, like a mouth that has had a very cold sandwich. Frost grows on the stones for a hundred metres around it. The air is chilly and tastes of metal.',
    'A trader insists there’s a door in there with a very polite sign: PLEASE KNOCK BEFORE ENTERING. FOR MEDICAL REASONS, PLEASE DO NOT SPEAK LOUDLY. SUBJECTS ARE VERY DEEP SLEEPERS.',
    'You knock. After a moment, from deep inside, comes a faint, clear, impeccably professional voice: “Come in. Please remove your shoes. And close the door, the cold escapes.”',
  ],
  reward: const Reward(scrap: 180, xp: 130, stims: 1, picks: 1, parts: 2),
  endings: {
    'wakeall': const Ending('wakeall', 'THE GREAT THAW',
        'You woke them all. It took a week, a great many blankets and an unreasonable quantity of soup. Thirty-one people from forty years ago stood blinking in the wasteland. They are, as a group, astonishingly polite. They are also, as a group, completely unprepared. You have started a small, very well-dressed settlement.',
        bonus: Reward(xp: 80, parts: 2), world: ['freezer.wakeall']),
    'wakeone': const Ending('wakeone', 'ONE MORE',
        'You woke one more, the one Ada trusted most. He sat up, coughed, and asked the question that all of them ask. He and Ada have started an experimental garden. The rest remain asleep, in a cold, quiet room, with a note: WE’LL BE BACK.',
        bonus: Reward(xp: 60, stims: 1), world: ['freezer.wakeone']),
    'sleep': const Ending('sleep', 'LET THEM SLEEP',
        'You sealed the lab and left the pods running on a new, slow, solar trickle. They may sleep for another hundred years. Ada visits every month with a flask of soup and a book to read aloud. She says it is the right thing. She is nearly sure.',
        bonus: Reward(xp: 50, scrap: 40), world: ['freezer.sleep']),
    'ada': const Ending('ada', 'DOCTOR ADA IN CHARGE',
        'You put Ada in charge of the facility. Within a month she has a clinic, a lab, a school and a very firm opinion on hand-washing. She is the most competent person in the wasteland. She is also, privately, very sad. She keeps a calendar and crosses off the days, even though no one could tell her which year it is.',
        bonus: Reward(parts: 3, xp: 40), world: ['freezer.ada']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You pack a thick coat and a very small amount of dignity. The wasteland is not the sort of place that gives you time to prepare for being thawed.']
      : ['A thin white mist curls round your boots. You have an unmistakable feeling that you are being filed.'],
  ambient: [
    Ambient('Frost on a cactus. The cactus looks furious about it.', maxKm: 3),
    Ambient('A scrawny rabbit shivers at the cave mouth in a little jumper somebody has knitted for it. It is the only thing in the desert that looks well-dressed.', maxKm: 3),
    Ambient('The air tastes of liquid nitrogen. You’re not sure how you know what that tastes like.', maxKm: 4),
    Ambient('A sign on a post: PLEASE DO NOT DISTURB THE SLEEPERS. THIS MEANS YOU, SCAVENGERS. THIS ALSO MEANS YOU, FUTURE.', minKm: 1, maxKm: 4),
    Ambient('From a vent in the rock, a faint, tidy voice: “...Subject Fourteen, temperature stable. Subject Fifteen, temperature stable. Subject Sixteen, who left the door open?”', minKm: 1.5),
    Ambient('~There are a lot of ways to wake up. Very few of them involve being told that the world has ended.', minKm: 3),
    Ambient('You find a little paper flag stuck in the frozen ground: A.L. WAS HERE. YEAR: 2077. It’s dated, very precisely, to the second.', minKm: 2.5, when: (c) => c.done('wake')),
    Ambient('Ada’s voice in memory: “I don’t mean to be rude, but is that your actual skin?”', minKm: 3.5, when: (c) => c.done('wake')),
    Ambient('A dozen small blue lights twinkle along a corridor, like a very cold, very patient airport.', minKm: 5, when: (c) => c.done('wake')),
    Ambient('Cold air breathes out of a vent and stirs the hair on your arms. Somewhere, a pod chimes politely.', minKm: 6),
    Ambient('You catch yourself speaking more quietly. It’s hard to be loud among sleepers.', minKm: 7),
    Ambient('~Everybody in here is a person who said yes to the future. The future has not been kind to the idea.', minKm: 8),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'frost',
      title: 'THE FROZEN DOOR',
      km: 1.4,
      text: (c) => [
        'The door is steel, the size of a garage, rimed with white. A discreet brass plaque reads MERIDIAN CRYOGENIC PRESERVATION INSTITUTE. A smaller plaque says: ASK ABOUT OUR LIFETIME GUARANTEE. A third, newer plaque, in marker, says: SEE ADA.',
        'A speaker crackles. “Hello?” says the voice. “Is that the maintenance crew? You’re forty minutes late. I’ve been waiting at the lobby. There’s no one on reception.”',
        'It’s a woman’s voice, brisk and warm and slightly cross. She sounds as if she’s been interrupted in the middle of a very important telephone call.',
        '~She sounds like someone who has no idea how late it is.|',
      ],
      journal: say(['A steel door under a frozen cave: MERIDIAN CRYOGENIC PRESERVATION INSTITUTE. A woman’s voice said I was forty minutes late.']),
      reward: const Reward(xp: 10),
    ),
    Checkpoint(
      id: 'wake',
      title: 'DOCTOR LINDQVIST',
      km: 2.8,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 25),
      journal: (c) => [
        'Dr. Ada Lindqvist woke from cryogenic suspension and believes it is still 2077. I told her otherwise. She took it with a great deal of professional composure and then asked for a chair.',
        if (c.flag('seen.world')) 'She asked a great many questions about the world. I answered as honestly as I dared.',
        if (c.flag('seen.pods')) 'There are thirty-one other pods. Their power is failing.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The lobby is tiled, immaculate and glacial. A reception desk stands abandoned, with a fern that has become a skeleton of itself. On the far wall is a row of drawers, each with a glass panel. Light from them is pale blue.',
            'In front of the desk stands a woman in a long white coat, with a clipboard and a mug and an expression of mounting irritation. She is small, in her forties, with a fierce grey streak in her hair. She looks at you from boots to hat.',
            '“Doctor Ada Lindqvist,” she says. “Head of Preservation. You’re not the cleaners. You’re not the delivery. You have, if I may say, a very unusual coat. Is it a fashion thing? Have I missed the season?”',
          ]),
          _wakeChoices(),
        ),
        Scene.talk(
          'w_year',
          say([
            '“What year is it?” she asks, brightly, as if checking a pulse.',
            'You tell her. You tell her the number, the real one, and a version of the number in years since the war. She smiles politely. Then she checks her clipboard. Then her watch. Then, with a steady, clinical gentleness, she sits down on the edge of the reception desk.',
            '“No,” she says. “No. I went in on a Tuesday. I was only going to be under for a weekend. A demonstration. A... marketing... Is it, in fact, a joke? Are you from the board?”',
            'She waits. You don’t say anything. After a while, she says, in a very small voice, “Ah.”',
          ]),
          _wakeChoices(),
          flags: ['seen.year', 'ada_knows'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'w_world',
          say([
            '“Are the trains running?” she asks. “I’ve a conference.” “No.” “The internet?” “No.” “The telephone network? Mine’s on contract.” “No.” “Is the president, at least, still...” She stops. “Which president?”',
            'She takes a very long sip of her coffee. It’s forty years old and entirely frozen. She sips it anyway. “And the wifi?” she says. “Was it a regional outage?”',
            '“It’s... a long outage.”',
            'She thinks about that, and, bravely, makes a note. “Right,” she says. “Priorities.”',
          ]),
          _wakeChoices(),
          flags: ['seen.world'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'w_pods',
          say([
            'Ada walks you along the wall of drawers. The blue lights glow on each of them: names, ages, dates. “Thirty-one other subjects,” she says. “All volunteers. Short-term suspension, for a trial. They were supposed to be revived by morning.”',
            'She taps a panel. The numbers on it are red. “Power,” she says. “It’s on a reserve. It’s been on a reserve for a very long time. It’s very nearly gone. I give them, at a guess, a week. Maybe two.”',
            'She turns to you. There’s steel in her voice now, steady and quiet. “So whoever you are. Whatever you’ve got. I need you to help me decide what to do with them.”',
          ]),
          _wakeChoices(),
          flags: ['seen.pods', 'power_low'],
          reward: const Reward(xp: 10),
        ),
        Scene.end('w_go', say([
          'Ada puts on a coat, slowly, and ties a scarf over her hair. She picks up the clipboard. She does not put down the mug. “I’d like to see the facility,” she says. “Before I see anything else. It’s my life’s work. And I think I’m afraid to see what’s left of everything else.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'lab',
      title: 'THE FACILITY',
      km: 4.8,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 30),
      journal: (c) => [
        'Ada and I toured the facility. The power plant is failing, the pods are on borrowed time, and the records list who each sleeper is.',
        if (c.flag('fixed_power')) 'I stabilised the generator. We have weeks, not days.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Ada walks with an odd, tidy, urgent step, through corridors of grey tile. She tuts at dust. She tuts at a toppled bin. She tuts at a ceiling tile that has fallen in. “This would never have been tolerated,” she says. “A fine of two hundred.”',
            'At the heart of the facility is the plant room: a huge, silent chamber with a generator the size of a lorry. It’s coughing. Every few seconds the lights flicker. Ada looks at it with the particular grief of a woman who has seen a beloved instrument go out of tune.',
            '“That’s the heart,” she says. “It’s going. I can’t fix it. I’m a cryobiologist, not a mechanic.”',
          ]),
          [
            skillChoice('ENGINEERING', 1, 'STABILISE THE GENERATOR', 'fix'),
            Choice('[HACK THE POWER MANAGEMENT]', 'hack', show: (c) => !c.flag('fixed_power')),
            Choice('[LOOK AT THE SLEEPERS’ RECORDS]', 'records', show: (c) => !c.flag('read_records')),
            Choice('[MOVE ON]', 'out'),
          ],
        ),
        Scene.talk(
          'fix',
          say([
            'You strip the housing off the generator and lie flat on your back among gaskets. Ada passes you spanners with the precise courtesy of a theatre nurse. It takes two hours. When you are finished, the plant gives a long, shuddering cough, and settles into a steady hum.',
            '“Wonderful,” says Ada, crisply. “Fine work. I take it you’re not on the staff list. Would you like to be?”',
            'The lights stop flickering. A pod gives a little chime. The red numbers on the wall go amber. You’ve bought them weeks, maybe months.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['fixed_power'],
          reward: const Reward(xp: 20, parts: 1),
        ),
        Scene.hack(
          'hack',
          say(['The power management console is a quiet green screen with a very formal log-in prompt.']),
          win: 'hacked',
          fail: 'hackfail',
        ),
        Scene.talk(
          'hacked',
          say([
            'You reroute power from the lights and the heating and the lifts to the pods. The whole facility darkens, and the pods glow brighter. “Oh, clever,” says Ada. “I should have thought of that. It’s the sort of thing you do when you haven’t any manners.”',
            'The pods buy another week. Ada is, you can tell, a little in awe.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['fixed_power', 'rerouted'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'hackfail',
          say([
            'The console flares red. An alarm sounds. “POWER MANAGEMENT LOCKOUT,” says a recorded voice. “PLEASE REMAIN CALM. DO NOT TOUCH THE SUBJECTS.” Ada pulls you away. “It’s fine,” she says, rather bravely. “It’s only an alarm. I once triggered it with a biscuit.”',
            'The alarm stops after a minute. Several pods are now a little colder than they were. One of them chimes mournfully, like a very small, sleepy bell.',
          ]),
          [Choice('[CONTINUE]', 'a')],
        ),
        Scene.talk(
          'records',
          say([
            'The records room is a long white cabinet. Ada opens it. “Subject one,” she reads. “A Mr. Anselm Pryce, 52, retired bus driver. Wanted to see the future. Subject two, Doctor Mei Tan, 34, immunologist. She’d just had a baby. She said she would only be gone for a night.”',
            'She runs a finger down the column. “A teacher. A cellist. A man who wanted to know how a play ends. A girl,” she adds, more quietly, “of eighteen. Her mother signed the forms.”',
            'There are thirty-one names. Each has a photograph. Each, in the photograph, is smiling.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['read_records'],
          reward: const Reward(xp: 12),
        ),
        Scene.end('out', say(['You return to the corridor with Ada beside you. “Thank you,” she says. “For not lying to me.” She looks down the long blue-lit corridor of sleepers. “I think it’s time to decide what to do about them.”'])),
      ],
    ),
    Checkpoint(
      id: 'pods',
      title: 'THE SLEEPERS',
      km: 7.0,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 25, xp: 40),
      journal: (c) => [
        'We examined the sleepers. They’re all volunteers. Each asked, in a message, to be woken only if the future was kind.',
        if (c.flag('heard_note')) 'One pod contained a note for whoever finds them.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The pod bay is a long, low hall, as cold as a church. Thirty-one drawers line the walls, each with a window. Behind each window lies a face, still, serene, dusted lightly with frost.',
            '“They signed a waiver,” says Ada, rubbing her arms. “To be revived at the end of the demonstration. They signed another saying that if I failed, they’d prefer I let them sleep until it was safe. I... didn’t think I’d be the one to decide.”',
            'She stops at a pod. The name plate says: ELSIE MARSH, AGE 8. A small hand presses against the glass from inside. It doesn’t move.',
          ]),
          [
            Choice('[LISTEN TO THE NOTE]', 'note', show: (c) => !c.flag('heard_note')),
            Choice('[ASK ADA WHAT SHE WANTS]', 'want', show: (c) => !c.flag('ada_wants')),
            Choice('[ASK WHAT IT’D TAKE TO WAKE THEM]', 'how', show: (c) => !c.flag('asked_how')),
            Choice('[DECIDE]', 'out'),
          ],
        ),
        Scene.talk(
          'note',
          say([
            'A voice recorder is taped to the first pod. Ada presses play.',
            '#“Whoever’s there. My name’s Anselm. I drove a bus for thirty-one years. I’m not clever and I’m not brave, but I’d like to see what happens next. If it’s bad, just leave me. If it’s good, wake me, and tell me where to catch the number twelve.”',
            'Ada’s hand is over her mouth. “He asked me,” she says, “about the bus routes. Before we started. I told him not to worry.”',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['heard_note'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'want',
          say([
            '“What do you want to do?” you ask.',
            'Ada holds the mug in both hands, though there’s nothing in it. “I want to wake them,” she says. “All of them. I can’t bear to leave them here to die in their sleep. But I don’t know what I’m waking them to. I’m not sure I can give them a world. All I’ve got is a very good set of notes and a deep, bitter sense of responsibility.”',
            'She laughs, shortly. “I trained for the one case where it all goes right.”',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['ada_wants'],
        ),
        Scene.talk(
          'how',
          say([
            'Ada puts a hand on the console. “Waking’s the easy part. Thawing takes a day. A pod, a nurse, a warm blanket and soup. For one, I could do it alone. For thirty-one, it’d take everything the generator has left, and a lot of help. And after that, they’d need a world to wake up into.”',
            '“Which we haven’t got.”',
            '“Which,” says Ada, gently, “we can only build with them. That’s the cruel part. They’re not just cargo. They’re the only thing we’ve got left that remembers how.”',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['asked_how'],
          reward: const Reward(xp: 8),
        ),
        Scene.end('out', say([
          'You take a breath. The cold fills your lungs. Thirty-one pods hum behind you in a long blue line, like a choir waiting for a note. Ada has stopped talking. She’s waiting for you, with the same stillness she must have used on a hundred patients.',
          '“It isn’t fair to ask you,” she says. “But I’d be so grateful if you did.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'thaw',
      title: 'THE DECISION',
      km: 9.0,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 35, xp: 55),
      journal: (c) => ['At the end, I had to choose what to do with thirty-one sleepers.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The control room is small, cold and bright. Thirty-one tiny lights glow on a panel. Under each is a switch: THAW. A big red master lever reads: ALL.',
            'Ada stands at your shoulder, hands clasped, her breath showing. “The generator will hold for a long time now,” she says, if you stabilised it. “But not for ever. And I’ve been thinking. The sleepers volunteered to see the future. They never promised to survive it.”',
            if (c.flag('fixed_power')) 'The amber lights on the pods are steady. You have time. It makes the choice no easier. It makes it, if anything, heavier.',
          ],
          [
            Choice('[WAKE THEM ALL]', 'all'),
            Choice('[WAKE ONE: THE BUS DRIVER]', 'one'),
            Choice('[LET THEM SLEEP]', 'sleep'),
            Choice('[PUT ADA IN CHARGE]', 'ada'),
          ],
        ),
        Scene.talk(
          'all',
          say([
            'You put your hand on the master lever. “Ada,” you say. “Are you sure?” She looks at you. She has tears in her eyes, and a very straight back. “No,” she says. “But I’m sure it’s right.”',
            'The lights flicker. The pods hum. Frost melts, one by one, from thirty-one little windows. And in the dim blue light, a hand twitches, a mouth opens, and an old voice says, from very far off, “Is it morning?”',
          ]),
          [Choice('[HELP THEM UP]', 'end_wakeall')],
          reward: const Reward(xp: 20),
        ),
        Scene.talk(
          'one',
          say([
            'You select a single switch. Ada stares at it. “Why him?” she asks, very softly. “Because he asked,” you say. “And because someone should hear that the buses aren’t running. It might as well be a man who’ll take it well.”',
            'She presses the switch. The pod hisses open. A grey-haired man sits up, blinks, and says, with great dignity, “Excuse me. Which way to the number twelve?”',
          ]),
          [Choice('[TELL HIM GENTLY]', 'end_wakeone')],
          flags: ['woke_anselm'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'sleep',
          say([
            'You step back from the lever. “Let them sleep,” you say. “If the world isn’t ready, they shouldn’t have to see it.”',
            'Ada looks at the panel. A tear runs down her cheek, and she wipes it off crisply with her cuff. “I’ll come and visit,” she says. “I’ll read to them. I’ll tell them what year it is. I’ll... lie.”',
            'She seals the hatch. It closes with a long, low, soothing sigh.',
          ]),
          [Choice('[HELP HER SEAL THE LAB]', 'end_sleep')],
        ),
        Scene.talk(
          'ada',
          say([
            '“Doctor Lindqvist,” you say. “You’re in charge. The facility is yours. The sleepers are yours. The world, if you’ll excuse me, is going to need someone competent, and I’m only a scavenger with a spanner.”',
            'Ada blinks. She straightens. Something in her face reorganises, a thing that’s been folded away for forty years. “Right,” she says. “Then I’ll need a budget. I’ll need a team. I’ll need,” she adds, severely, “a decent mop.”',
          ]),
          [Choice('[HAND HER THE KEYS]', 'end_ada')],
          flags: ['ada_in_charge'],
        ),
        Scene.end('end_wakeall', say([
          'It takes a week. They wake in ones and twos: a cellist who asks for a cup of tea, a schoolteacher who insists on a register, a boy of eight who says nothing, and then says, “Is Mum here?” and has to be told.',
          'They are astonished by all of it. By the sky. By the dust. By you. Ada walks among them with a clipboard and a flask of soup, and tells every one of them the truth, as gently as she can, and holds their hands.',
          'By the end of the month they have a settlement, a school, a rota and a charter. Anselm the bus driver, to everyone’s delight, has started a very small, very irregular, much-loved bus service on a single route. He charges nothing. He insists on a timetable.',
        ]), ending: 'wakeall'),
        Scene.end('end_wakeone', say([
          'You tell him as gently as you can. He takes it very well, for a man who’s been asleep for forty years. He sits on the edge of the pod and looks at the floor. “So,” he says. “I’ve missed a lot of buses.”',
          'Ada makes him soup. He and she sit together in the dim blue light, an old bus driver and a worn cryobiologist, talking quietly, for a very long time. Neither of them mentions the future. Both of them seem to be, in some small way, relieved.',
        ]), ending: 'wakeone'),
        Scene.end('end_sleep', say([
          'The hatch seals with a sigh. The blue lights dim to a gentle glow. The generator hums on, steady as a heartbeat. You and Ada stand together for a while, in the cold, listening to thirty-one people breathing very slowly in the dark.',
          '“Goodnight,” says Ada, quietly, to the room. “I’ll be back on Tuesday.”',
        ]), ending: 'sleep'),
        Scene.end('end_ada', say([
          'You leave her on the steps of the Institute, with the keys in one hand and a clipboard in the other. She is already giving orders to a group of astonished scavengers about the importance of hygiene. By the time you reach the road, there’s a banner over the door: MERIDIAN INSTITUTE — NOW OPEN.',
          '~She’s going to be fine. Somebody has to be.',
        ]), ending: 'ada'),
      ],
    ),
  ],
);
