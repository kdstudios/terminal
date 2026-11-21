import '../../story_model.dart';

// THE WEAPON INSPECTOR
// Inspector Gall insists on inspecting your weapons. His standards are
// nonsensical: fists, sticks, anything vaguely threatening. Endings: passed,
// failed, reported.

List<Choice> _inspChoices() => [
      Choice('[SHOW HIM YOUR WEAPON]', 'i_weapon', show: (c) => !c.flag('seen.weapon')),
      Choice('[SHOW HIM YOUR FISTS]', 'i_fists', show: (c) => !c.flag('seen.fists')),
      Choice('[ASK ABOUT THE STANDARDS]', 'i_std', show: (c) => !c.flag('seen.std')),
      Choice('[ASK FOR YOUR RESULT]', 'i_go'),
    ];

final StoryDef inspectorStory = StoryDef(
  id: 'inspector',
  title: 'THE WEAPON INSPECTOR',
  tagline: 'HE INSPECTS ANYTHING THAT COULD BE A WEAPON. THIS INCLUDES YOUR HANDS, YOUR OPINIONS AND YOUR HAT.',
  difficulty: 'LOW',
  destinationKm: 1.0,
  recommendedLevel: 1,
  scale: StoryScale.short,
  intro: ['A man in a stiff grey coat steps in front of you, clipboard raised like a shield. “Inspector Gall,” he says. “Regional Weapons Standards. Stop. Stand still. Hold out whatever you’re carrying.”'],
  reward: const Reward(scrap: 35, xp: 30),
  endings: {
    'passed': const Ending('passed', 'CERTIFIED WEAPON-ADEQUATE',
        'You passed. You have a certificate. It says your weapon is “suitably menacing, if slightly shy.” You are issued a sticker. It’s the most official thing that’s ever happened to you.',
        bonus: Reward(xp: 15), world: ['gall.passed']),
    'failed': const Ending('failed', 'CONDEMNED',
        'You failed the inspection. Inspector Gall confiscated your left sock, your hat and a fork. He gave you a receipt. He seemed relieved.',
        bonus: Reward(), world: ['gall.failed']),
    'reported': const Ending('reported', 'A COUNTER-INSPECTION',
        'You inspected the Inspector. He had four weapons concealed on his person, none of them within regulation. He fined himself, confiscated them, and went home to have a lie-down.',
        bonus: Reward(scrap: 50, xp: 20), world: ['gall.reported']),
  },
  depart: (c) => ['A very polite voice calls from a roadside hut: “Please remain still. Please do not carry anything threatening. Please do not be threatening.”'],
  ambient: [
    Ambient('A sign: ALL WEAPONS MUST BE REGISTERED. ALL OPINIONS MUST BE LICENSED.', maxKm: 0.7),
    Ambient('A man in the distance hands a stick to a man in a coat. The man in the coat shakes his head and hands it back.', maxKm: 0.9),
    Ambient('~There is, you reflect, nothing more threatening than a person with a form.', minKm: 0.5),
  ],
  checkpoints: [
    Checkpoint(
      id: 'inspect',
      title: 'THE INSPECTION',
      km: 0.5,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 15),
      journal: (c) => [
        'Inspector Gall inspected my weapons using standards that made no sense.',
        if (c.flag('seen.fists')) 'He called my fists “unregistered.”',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The hut has a hatch, a stamp, and a rack of confiscated weapons: a stick, a very large spoon, a rolled-up newspaper, a hat. Inspector Gall consults his clipboard. It has a list.',
            '“Standards,” he says, “are standards. I will need to check your weapon for: length, weight, menace, politeness, colour and general vibe.”',
          ]),
          _inspChoices(),
        ),
        Scene.talk(
          'i_weapon',
          say([
            'You hand over your weapon. He turns it over with white-gloved hands. He sniffs it. He taps it against a metal plate. He listens to it for a very long time with a stethoscope.',
            '“Hm,” he says. “Length: adequate. Weight: adequate. Menace: moderate. Politeness: poor. It has not said hello to me.” He writes. “It also has the wrong shade of grey.”',
          ]),
          _inspChoices(),
          flags: ['seen.weapon'],
        ),
        Scene.talk(
          'i_fists',
          say([
            '“Your hands,” says Inspector Gall. “Show them.” You hold out your fists. He gasps. “UNREGISTERED. This is a serious matter. Who authorised them?”',
            '“They came with me.”',
            '“They came, in point of fact, without paperwork. I’ll need them measured.” He pulls out a tape. He measures them, carefully, in four directions, and writes down a number. It’s about the size of a cheese.',
          ]),
          _inspChoices(),
          flags: ['seen.fists'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'i_std',
          say([
            '“What are the standards?” you ask. Inspector Gall stiffens. “They’re confidential.” “Can I see them?” “They’re,” he says, rather weakly, “in my head.” He taps his forehead. “They’re very detailed. There’s a section on colours I haven’t finished.”',
          ]),
          _inspChoices(),
          flags: ['seen.std'],
        ),
        Scene.end('i_go', say(['The Inspector stamps the clipboard, firmly, three times. “Right,” he says. “The verdict is ready. Please stand to attention, if you can, and try to look compliant.”'])),
      ],
    ),
    Checkpoint(
      id: 'verdict',
      title: 'THE VERDICT',
      km: 1.0,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 10),
      journal: (c) => ['The verdict of the weapons inspection.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Inspector Gall straightens his coat and clears his throat. “After careful consideration,” he says, “and an unconscionable amount of paperwork, I have reached a decision.”',
          ]),
          [
            Choice('[ACCEPT THE VERDICT]', 'pass'),
            Choice('[ARGUE]', 'fail'),
            Choice('[INSPECT THE INSPECTOR]', 'counter'),
          ],
        ),
        Scene.talk('pass', say(['“Certified,” says Inspector Gall. He stamps a very small card. “Weapon-adequate. Please keep it on your person. If challenged, show it, and, if still challenged, hit them.”']), [Choice('[TAKE THE CARD]', 'end_passed')]),
        Scene.talk('fail', say(['“I would like to dispute,” you say. “That’s a very serious matter,” says Gall. “It will cost you your hat, a sock and a fork.” He holds out a bag. It is already labelled with your name.']), [Choice('[HAND THEM OVER]', 'end_failed')]),
        Scene.talk('counter', say(['“Your turn,” you say. Inspector Gall blinks. “I’m sorry?” “Hold out whatever you’re carrying.” His face drains. “That’s not,” he says, “how it works.” He’s clutching four things inside his coat.']), [Choice('[SEARCH HIM]', 'end_reported')]),
        Scene.end('end_passed', say(['You leave with a laminated card and a sticker. The card reads: WEAPON-ADEQUATE (PROVISIONAL). The sticker is a small smiley face. It’s, oddly, the most reassuring thing you’ve been given in weeks.']), ending: 'passed'),
        Scene.end('end_failed', say(['You walk away without a hat, with one sock and without a fork. Behind you the Inspector holds them up, one by one, to the light, with an expression of enormous, melancholy satisfaction.']), ending: 'failed'),
        Scene.end('end_reported', say(['In his coat you find a knife, a cosh, a very long spanner and a letter opener. “They’re for protection,” he whispers. “The job is terribly frightening.” You fine him on the spot. He pays, trembling, with a cheque and an apology.']), ending: 'reported'),
      ],
    ),
  ],
);
