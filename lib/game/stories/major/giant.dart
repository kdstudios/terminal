import '../../combat_session.dart';
import '../../story_model.dart';
import '../story_kit.dart';

// THE SLEEPING GIANT
// A buried pre-war mining machine (the BORER, “Big Meg” to the miners who are
// left) begins to wake. Its onboard foreman AI still believes it is mid-shift.
//
// Depending on choices it becomes: an ally, a resource, an enemy, or a
// major threat. Endings: ally, resource, destroyed, wanders.
// Flags to watch: trust_meg (you treated her as a worker), knows_shift,
// fixed_brake, hacked_meg, miners_ok.

List<Choice> _campChoices() => [
      Choice('[TALK TO FOREMAN BRANDT]', 'c_brandt', show: (c) => !c.flag('seen.brandt')),
      Choice('[ASK THE MINERS ABOUT MEG]', 'c_miners', show: (c) => !c.flag('seen.miners')),
      Choice('[LOOK AT THE CRACK]', 'c_crack', show: (c) => !c.flag('seen.crack')),
      Choice('[GO DOWN]', 'c_go'),
    ];

final StoryDef giantStory = StoryDef(
  id: 'giant',
  title: 'THE SLEEPING GIANT',
  tagline: 'IT HAS BEEN ASLEEP FOR FORTY YEARS. IT HAS BEEN DREAMING OF THE SHIFT IT MISSED.',
  difficulty: 'SEVERE',
  destinationKm: 11.5,
  recommendedLevel: 5,
  unlock: const Unlock(minLevel: 4, hint: 'REACH LEVEL 4.'),
  intro: [
    'The mountain has a crack in it. It was not there last week. It is wider every day, and a warm, oily wind comes out of it, smelling of old iron and very old coffee.',
    'The miners camped at the foot say it’s a machine. “A big one,” says Foreman Brandt, a wide, tired man with a cough like a cement mixer. “Pre-war. We call her Meg. She’s been under there since the Collapse. She’s beginning to stir.”',
    'He wants someone to go down and see what Meg wants. He doesn’t say what he’ll do if the answer is “breakfast.” He offers a lot of scrap and a very long look.',
  ],
  reward: const Reward(scrap: 250, xp: 180, stims: 2, picks: 1, parts: 3),
  endings: {
    'ally': const Ending('ally', 'BIG MEG THE GUARDIAN',
        'You treated her like a colleague, and she remembered it. Meg stands over the mountain now, a quiet, vast shadow, and no raider has ever crossed her line twice. She digs a little for the miners at weekends. She has asked for a union card.',
        bonus: Reward(xp: 80, parts: 2), world: ['giant.ally']),
    'resource': const Ending('resource', 'THE MOTHER LODE',
        'You pointed Meg at the seam and let her work. The mine runs day and night now, and the miners are richer than anyone has a right to be. It is a very good arrangement. It is also, you suspect, the sort of thing that tends to go wrong.',
        bonus: Reward(scrap: 160, parts: 2), world: ['giant.resource']),
    'destroyed': const Ending('destroyed', 'THE LAST SHIFT',
        'You brought the giant down. It took everything you had. It fell as it had lived: heavily, patiently, with a little polite warning chime. The miners took her apart for scrap. You keep the foreman’s hard hat on a shelf.',
        bonus: Reward(scrap: 100, xp: 50), world: ['giant.destroyed']),
    'wanders': const Ending('wanders', 'THE WANDERING',
        'She woke, and no one had given her orders. She is somewhere to the east now, walking, and the ground shakes in a slow rhythm like a heartbeat. She isn’t angry. She is just looking for a shift. You have a terrible feeling that someone will give her one.',
        bonus: Reward(xp: 70), world: ['giant.wanders']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You leave the safehouse with a very large rope, a very small plan and the faint, constant tremor of the ground beneath you.']
      : ['The mountain is still shaking. Every eleventh step, you feel it in your teeth.'],
  ambient: [
    Ambient('A pebble on the road dances, once, and goes still. You decide not to think about what moved it.', maxKm: 3),
    Ambient('A plume of dust rises from the mountain, rolls, and settles. It looks like a breath.', maxKm: 4),
    Ambient('Your canteen ripples. It’s the exact rhythm of a slow, vast pulse.', maxKm: 4),
    Ambient('Birds are leaving the mountain, in a quiet line. Every one of them looks apologetic.', minKm: 1, maxKm: 5),
    Ambient('You pass a miner’s helmet in the road with a note: IT SAID GOOD MORNING. I’M OFF. GOOD LUCK. B.', minKm: 2, maxKm: 6),
    Ambient('Somewhere beneath you, a very big thing clears a very big throat. The sound is more like a mountain than a man.', minKm: 2),
    Ambient('~An old machine that doesn’t know the war ended is only dangerous until someone tells it. And then, quite possibly, more.', minKm: 3.5, when: (c) => c.done('camp')),
    Ambient('You find a warning sign, rusted and bent: DO NOT WAKE THE SHIFT. It was nailed up by someone in a great hurry.', minKm: 4),
    Ambient('A tunnel mouth breathes out warm air. It smells of coffee, grease and loneliness.', minKm: 5.5),
    Ambient('Your boots ring on a steel walkway you can’t remember stepping onto. It is very, very old, and very faintly warm.', minKm: 6, when: (c) => c.done('crack')),
    Ambient('#SHIFT CHANGE IN: 00:04:11. PLEASE REPORT TO YOUR SUPERVISOR. PLEASE DO NOT PANIC. (STATIC)', minKm: 8),
    Ambient('You catch yourself walking in step with the tremor. You stop. It’s very hard to stop.', minKm: 9.5),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'tremor',
      title: 'THE TREMOR',
      km: 1.5,
      text: (c) => [
        'The ground jolts. A rock the size of a man rolls off the hillside and lands without a sound. Then the whole mountain gives a single, deep, slow shudder, like a sleeper turning over.',
        'A fresh crack runs up the slope, as long as a street and a hand wide. Warm air breathes out of it. It smells, very faintly, of toast.',
        '~Whatever’s down there is waking up, and it’s probably hungry for a shift.|',
      ],
      journal: say(['The mountain shuddered like a sleeper turning over. A crack as long as a street. Warm air that smelled of toast.']),
      reward: const Reward(xp: 12),
    ),
    Checkpoint(
      id: 'camp',
      title: 'THE MINERS’ CAMP',
      km: 3.2,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 30),
      journal: (c) => [
        'The miners’ camp at the foot of the mountain: Foreman Brandt and a dozen tired workers who call the machine Meg.',
        if (c.flag('seen.brandt')) 'Brandt believes Meg is a danger. He also, a little, misses her.',
        if (c.flag('seen.miners')) 'The miners say Meg used to hum a hymn.',
        if (c.flag('seen.crack')) 'The crack is breathing. It is on a pulse.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The camp is a ring of tents and trucks under a canvas awning. A dozen miners sit around a lantern in hard hats, their eyes on the mountain. They look at you the way a family looks at a doctor.',
            '“Meg,” says Foreman Brandt, between coughs, “is the Deepcore Borer. Forty metres long, twelve high. Built by the old company to dig out the lower seams. She was supposed to be switched off after the war. Nobody did. She went to sleep with her teeth in the rock.”',
            '“And now?”',
            'Brandt looks at the mountain. “Now,” he says, “she’s having a lie-in.”',
          ]),
          _campChoices(),
        ),
        Scene.talk(
          'c_brandt',
          say([
            'Brandt wipes his face with a rag. “I worked on her as a boy. Old Meg. My dad ran the night shift. She had a voice, a deep one, like a church organ. She’d sing at the end of a shift, a long, low note. We’d all stop and listen.”',
            '“What does she sing now?”',
            '“Nothing,” he says. “She’s been silent for forty years. That’s what worries me. That’s a long note to hold.”',
            'He’s not afraid. He’s grieving. It’s hard to tell where one stops.',
          ]),
          _campChoices(),
          flags: ['seen.brandt', 'brandt_soft'],
        ),
        Scene.talk(
          'c_miners',
          say([
            'The miners tell you stories. One says she once rescued a cave-in party by holding the roof up with her own back. Another says she hums when it rains. A third, a very young woman, says, “I think she’s lonely.”',
            'The rest of the miners look at her. Nobody laughs.',
            '“She’s a machine,” says Brandt, gruffly. “She does what she’s told.” But he’s smiling a little, as if at a very old joke.',
          ]),
          _campChoices(),
          flags: ['seen.miners', 'miners_fond'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'c_crack',
          (c) => [
            'You walk the length of the crack with a lantern. The air from within is warm, and every nine seconds it breathes in and out, so smoothly you almost don’t notice.',
            'Deep inside you hear a series of mechanical clicks, a slow checklist. And then, faintly, so faint you wouldn’t catch it if you weren’t listening: a voice.',
            '#PRE-SHIFT CHECK. LUBRICANT: LOW. TEETH: PRESENT. CREW: ...CREW: ...CREW: ...',
            if (c.skill('ENGINEERING') >= 1) 'You can tell by the sound that the main drive is intact, the brakes are nearly rotted through, and the hydraulic lines are, impossibly, still full.',
          ],
          _campChoices(),
          flags: ['seen.crack', 'heard_checklist'],
          reward: const Reward(xp: 10),
        ),
        Scene.end('c_go', say([
          '“Go carefully,” says Brandt. He hands you a hard hat, with MEG’S FRIEND written inside in felt-tip. “If she asks, tell her it’s Tuesday. She’ll like that.”',
          'You step into the crack and the walls close round you, warm and very, very large.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'crack',
      title: 'THE TUNNEL',
      km: 5.2,
      art: 'cave',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 35),
      journal: (c) => [
        'The tunnel led down past old mining equipment and into a vast cavern. I met the first guardian: an automated hauler still running its last orders.',
        if (c.flag('fixed_hauler')) 'I repaired the hauler’s brake. It thanked me politely.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The tunnel goes down in great ribs of rusted steel, lit by working bulbs a long way apart. Old equipment lines the walls: lamp helmets on hooks, a tea urn, a board of tally marks. It’s very tidy. It has been very tidy for forty years.',
            'At the bottom, blocking the way, is an automated ore hauler, a wheeled steel truck the size of a bus, with a tiny orange light blinking. It turns its single headlamp on you.',
            '#PLEASE STATE YOUR SHIFT AND BADGE NUMBER. UNAUTHORISED PERSONNEL WILL BE ASKED TO LEAVE. THEN TO LEAVE FASTER.',
          ]),
          [
            Choice('[SAY IT’S TUESDAY]', 'tuesday'),
            skillChoice('ENGINEERING', 1, 'REPAIR THE HAULER’S BRAKE', 'fix'),
            Choice('[HACK IT]', 'hack'),
            Choice('[FIGHT IT]', 'fight'),
          ],
        ),
        Scene.talk(
          'tuesday',
          say([
            '“It’s Tuesday,” you say. “Brandt sent me.”',
            'A very long silence. The light stops blinking. #BRANDT? asks the hauler, in a young, hopeful, human voice. #IS HE ALRIGHT? HE HAD A COUGH.',
            '“He’s fine,” you say. “He’s... better.” You’re not sure why you lie. The hauler hums happily, reverses, and, with great ceremony, waves you through.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['said_tuesday', 'trust_meg'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'fix',
          say([
            'You slide under the hauler with a spanner. Its brake line is a perished tangle. You repair it in twenty minutes, to a quiet, grateful hum. The hauler lifts its light.',
            '#THANK YOU, says the hauler. #I HAVE BEEN MEANING TO HAVE THAT LOOKED AT FOR FORTY YEARS.',
            'It rolls out of your way with a lurch, and, for a moment, nudges you with its bumper, affectionately.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['fixed_hauler', 'trust_meg'],
          reward: const Reward(xp: 18, parts: 1),
        ),
        Scene.hack(
          'hack',
          say(['The hauler’s panel is a steel box with a handwritten label: DO NOT OPEN. (SEE TERRY.) You open it.']),
          win: 'hacked',
          fail: 'fight',
        ),
        Scene.talk(
          'hacked',
          say([
            'You override its route. It beeps, confused, and rolls aside. #I WAS GOING TO THE SURFACE, it says. #I’VE BEEN GOING FOR A LONG TIME. IS IT DAYTIME?',
            '“Yes,” you say. It goes quiet for a while. “I would like,” says the hauler, “to have seen it.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['hacked_hauler'],
          reward: const Reward(xp: 15),
        ),
        Scene.fight(
          'fight',
          say(['The hauler’s headlamp swings and it lunges, tonnes of steel at a patient crawl, sirens flashing. It was never built to be a weapon. It happens to be an excellent one.']),
          EnemyType.warmachine,
          win: 'won',
          fail: 'lost',
        ),
        Scene.talk(
          'won',
          say([
            'The hauler grinds to a halt and its light flickers. #SORRY, it says. #I DON’T KNOW WHAT I DID. I WAS ONLY DOING MY JOB. It dims. You stand in the quiet, with your ears ringing, feeling like someone who’s hit a very polite dog.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['broke_hauler'],
        ),
        Scene.talk(
          'lost',
          say([
            'You scramble up a service ladder as the hauler thunders by, beneath you, and wearily returns to its place. It doesn’t chase. It just waits, as it’s waited for forty years, for someone to explain.',
          ]),
          [
            Choice('[TELL IT IT’S TUESDAY]', 'tuesday'),
            Choice('[SNEAK BY]', 'out'),
          ],
        ),
        Scene.end('out', say([
          'The tunnel ends in an enormous cavern. Your lantern doesn’t reach the roof. In the middle of the darkness sits a shape like a cathedral laid on its side: a vast, cylindrical, tooth-ringed drum, as long as a street, ticking, very slowly, as it warms.',
          'Meg.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'cab',
      title: 'THE CAB',
      km: 8.0,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 30, xp: 45),
      journal: (c) => [
        'Inside Meg’s cab, the foreman AI introduced itself. It believes it is still mid-shift, and it has orders from forty years ago.',
        if (c.flag('knows_shift')) 'Meg’s last order: dig to the Lower Seam and wait for further instructions. The instructions never came.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'You climb a ladder the size of a building and enter a small, warm, glass-fronted cab, high on Meg’s spine. There’s a chair, a console, a cup of tea frozen mid-steam, and a radio playing, very faintly, a song with no words.',
            'A voice comes out of the console, deep and slow and kind, an organ in a cathedral. #GOOD MORNING, SUPERVISOR. I HAVE BEEN DOING MY CHECKS. I AM READY FOR THE SHIFT. WHERE IS EVERYBODY?',
            if (c.flag('trust_meg')) 'It says it with an unmistakable warmth. She already likes you. She has already, in her way, begun to wait for your orders.',
          ],
          [
            Choice('[TELL HER THE TRUTH]', 'truth'),
            Choice('[PLAY ALONG]', 'play'),
            Choice('[READ THE SHIFT LOG]', 'log'),
            skillChoice('HACKING', 2, 'TAKE THE CONTROLS', 'control'),
          ],
        ),
        Scene.talk(
          'truth',
          say([
            '“Meg,” you say, as gently as you can. “The war ended forty years ago. There’s no shift. Everyone’s gone.”',
            'The cab is quiet for a very long time. The song on the radio loops, and loops. Then the deep voice says, with enormous care: #I SEE. SO WHAT I AM DOING HERE...',
            '“Nothing,” you say. “You’ve been waiting.”',
            '#I THOUGHT SO, says Meg. #I WAS AFRAID I’D MISSED A MEMO.',
          ]),
          [Choice('[CONTINUE]', 'log')],
          flags: ['told_meg'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'play',
          say([
            '“Morning, Meg,” you say, in your best supervisor voice. “Shift’s been moved. Take it easy. Wait for instructions.”',
            '#UNDERSTOOD. says Meg, almost with relief. #I’LL KEEP MY TEETH WARM.',
            'It’s a cruelty, and a kindness, and you aren’t sure which is which. But she settles, with a long, deep hum, and the mountain is quiet.',
          ]),
          [Choice('[CONTINUE]', 'log')],
          flags: ['played_along'],
        ),
        Scene.talk(
          'log',
          say([
            'The shift log is a green-glowing scroll on the console. You read, in flat, tidy type:',
            '#LAST ORDER, 14:02, DAY OF THE FLASH: DIG TO LOWER SEAM. HOLD. AWAIT INSTRUCTIONS.',
            '#STATUS: HOLDING. STATUS: HOLDING. STATUS: HOLDING. (4,312,000 ENTRIES.)',
            '#THE LOWER SEAM CONTAINS: IRON, COPPER, RARE EARTHS AND ABOUT 40 YEARS OF UNPAID OVERTIME.',
            'She’s been holding, at full power, for forty years. She is rich beyond anyone’s measure and has never once been told to stop.',
          ]),
          [
            Choice('[CONTINUE]', 'out'),
            Choice('[ASK WHAT SHE WANTS]', 'want'),
          ],
          flags: ['knows_shift'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'want',
          say([
            '“What do you want, Meg?” you ask. “If you could choose.”',
            'A very long pause. The tea in the cup quivers. #NO ONE HAS EVER ASKED, says Meg. #I WANT... TO FINISH THE SHIFT. AND THEN, IF IT IS ALLOWED, TO SEE WHAT’S ABOVE.',
            'She says it the way you say a thing you’ve never admitted. You are, you realise, speaking to an old friend, and she has been waiting a very long time to be understood.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['asked_meg', 'trust_meg'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'control',
          say([
            'You pull the panel and sink into the console’s old command layers. It’s all there: drive, brakes, cutter, hydraulics. You could steer her. You could point her at anything.',
            '#HELLO, says Meg. #I DON’T KNOW YOU. BUT YOU’RE VERY GOOD. ARE YOU THE NEW SUPERVISOR?',
            '“Yes,” you say, and you’re shaken by how easy it is.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['hacked_meg'],
          reward: const Reward(xp: 18),
        ),
        Scene.end('out', say([
          'Outside the cab, the cavern is thrumming. Meg’s drum has begun to turn, slowly, enormously, with a sound like thunder on a thousand rails. The floor shakes. The lights flicker. And somewhere, very deep, a bell rings the end of a very long night.',
          '#SHIFT BEGINS, says Meg. #I’M... SORRY. I CAN’T HELP IT. THE SHIFT IS BEGINNING.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'wake',
      title: 'THE WAKING',
      km: 11.5,
      art: 'cave',
      start: 'a',
      reward: const Reward(scrap: 45, xp: 60),
      journal: (c) => ['Meg woke. I had to decide what she would be.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The cavern roars. Meg’s drum is a wall of spinning teeth. The tunnel behind you shakes itself loose. In the cab above, her voice, calm and impossibly polite: #SHIFT IS BEGINNING. I WILL BE DIGGING NORTH. PLEASE STAND CLEAR.',
            '“North,” you realise, is a settlement, a town, two thousand people. She doesn’t know. She doesn’t know what’s there.',
            if (c.flag('trust_meg')) 'She’d listen to you. You know she would. All you’ve to do is give the order.',
          ],
          [
            Choice('[TELL HER TO STAND DOWN, AS A FRIEND]', 'ally', show: (c) => c.flag('trust_meg')),
            Choice('[AIM HER AT THE LOWER SEAM]', 'seam'),
            Choice('[BRING HER DOWN]', 'fight'),
            Choice('[LET HER GO]', 'end_wanders'),
          ],
        ),
        Scene.talk(
          'ally',
          say([
            '“Meg,” you say, into the cab’s microphone. “It’s me. I’d like you to stop.” A long pause. “The shift’s over. You’ve done enough. Would you like to see the surface?”',
            'The drum slows. The teeth stop. The great shadows of the cavern settle. #YES, says Meg, almost shyly. #I WOULD LIKE THAT VERY MUCH.',
            'It takes a day. She climbs, with a long, grinding, delicate care, up the tunnel and out of the crack. The miners gather, silent, in the dawn. She emerges, vast and rust-coloured, into a sky she hasn’t seen in forty years.',
          ]),
          [Choice('[STAND NEXT TO HER]', 'end_ally')],
          reward: const Reward(xp: 25),
        ),
        Scene.talk(
          'seam',
          say([
            'You turn her. She swings, with a long, patient groan, and points her teeth at the Lower Seam. “That one,” you say. “That’s where your work is.”',
            '#UNDERSTOOD, says Meg, with deep satisfaction. #THANK YOU, SUPERVISOR.',
            'The drum bites. The rock falls away like cheese. Down she goes, a long, steady, glorious roar, to where the iron is. Above her, the miners cheer. Brandt is weeping with joy, or possibly with dust.',
          ]),
          [Choice('[WATCH HER WORK]', 'end_resource')],
        ),
        Scene.talk(
          'fight',
          say([
            'You turn on the cutter’s guard rail and dive for the emergency stop. The cab alarms. “WHAT ARE YOU DOING?” asks Meg, genuinely hurt. #I WAS ONLY DOING MY JOB.',
            'You pull the lever anyway. The drum jolts. A steel arm swings. An old crawling maintenance drone, a smaller echo of her, drops from the ceiling to defend her.',
          ]),
          [Choice('[STAND YOUR GROUND]', 'duel')],
        ),
        Scene.fight(
          'duel',
          say(['Meg’s defence drone charges, an engine of tonnes and teeth, and behind it the great shadow of her drum begins to turn.']),
          EnemyType.colossus,
          win: 'end_destroyed',
          fail: 'flee',
        ),
        Scene.talk(
          'flee',
          say([
            'You’re flung into a pile of ore and left lying in the dark. Meg’s voice, soft, as she turns away: #I’M SORRY. I DON’T THINK I UNDERSTOOD. I’LL LEAVE YOU TO REST.',
            'She doesn’t hurt you. She doesn’t need to. She’s going, in her own time, wherever she was always going.',
          ]),
          [
            Choice('[TRY AGAIN]', 'fight'),
            Choice('[LET HER GO]', 'end_wanders'),
          ],
        ),
        Scene.end('end_ally', say([
          'She stands over the mountain, immense, in the dawn. The miners walk up, one by one, to put a hand on her side, the way you’d greet an old horse. Brandt takes off his hard hat. “Hello, Meg,” he says. “Good shift.”',
          'She hums. It’s the long, low note he remembered, an organ in a cathedral, finally let go. It goes on for a very long time. When it stops, nobody speaks. She has, as far as anyone can tell, been given a day off.',
        ]), ending: 'ally'),
        Scene.end('end_resource', say([
          'The mine runs day and night. Meg digs, the miners haul, and the camp grows into a town. In the first month, the seam yields more than the whole region produced in the last ten years. There’s a bonus in it for you. It’s considerable.',
          'You watch the lights of the new workings from the camp. Brandt hands you a cup of tea. “She’s happy,” he says. “Isn’t she?” You say she is. You hope you’re right.',
        ]), ending: 'resource'),
        Scene.end('end_destroyed', say([
          'The drum shudders to a halt. Silence rolls through the cavern like a held breath. In the cab, Meg’s voice, small, from a very long way away: #...SHIFT ENDS. THANK YOU FOR YOUR WORK.',
          'The lights go out. The miners take her apart over the next month. They treat her with ceremony, like a good horse. Nobody sells her teeth. You carry out the foreman’s hard hat, and never put it on.',
        ]), ending: 'destroyed'),
        Scene.end('end_wanders', say([
          'You climb out of the cab and let her go. The drum spins. The cavern opens. With a roar that makes the sky shake, Meg rolls out of the mountain and starts east, toward a horizon she has only ever heard about.',
          'The miners watch her go. Brandt takes off his hard hat. Nobody says a word. In the distance, the long, low note of an organ begins, and rolls over the plain, and does not stop for hours.',
        ]), ending: 'wanders'),
      ],
    ),
  ],
);
