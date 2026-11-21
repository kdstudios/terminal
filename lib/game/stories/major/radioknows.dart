import '../../story_model.dart';
import '../characters/frequency_frank.dart';
import '../story_kit.dart';

// THE RADIO THAT KNOWS YOUR NAME
// A radio starts describing what the player has done. Then what they haven’t
// done yet. Frequency Frank is the paranoid expert (and, for once, right
// about something). It reads the OTHER stories: _recall() turns finished
// stories into things the radio can say about you.
//
// Endings: echo (a feedback loop of your own voice), frank (a human
// explanation, plus a real discovery), unplugged, listen.

/// Things the radio “knows”, from the player’s finished stories. Edit freely.
List<String> _recall(StoryCtx c) => [
      if (c.ending('caravan') == 'left') '#...LEFT THE PUMP RUNNING. WENT HOME. HUMMED. (HUM.)',
      if (c.ending('caravan') == 'freed') '#...SHUT OFF THE PUMP. A VILLAGE WOKE UP. THEY DID NOT THANK YOU.',
      if (c.ending('transmission') != null) '#...ANSWERED A LOOP. THE LOOP STOPPED. THE LOOP REMEMBERS.',
      if (c.ending('below') != null) '#...WENT DOWN. CAME BACK UP. SOMETHING BELOW IS STILL LISTENING.',
      if (c.ending('church') != null) '#...SAT THROUGH A SERMON TO A CAR BATTERY. DAVE NOTICED YOU NOTICING.',
      if (c.ending('garys') != null) '#...CALLED “GARY” BY MANY GARYS. ANSWERED TO IT TWICE.',
      if (c.ending('waterheist') != null) '#...A MAYOR, A POOL, A LEAK. YOU WERE THE ONE WHO KNEW.',
      if (c.ending('manufactured') != null) '#...A MAN WHO WAS MADE. YOU DECIDED WHAT HE WAS.',
    ];

List<Choice> _frankChoices() => [
      Choice('[ASK ABOUT THE RADIO]', 'f_radio', show: (c) => !c.flag('seen.f_radio')),
      Choice('[ASK WHO HE THINKS IS LISTENING]', 'f_who', show: (c) => !c.flag('seen.f_who')),
      Choice('[LOOK AT HIS LOGS]', 'f_logs', show: (c) => !c.flag('seen.f_logs')),
      Choice('[LEAVE WITH THE RADIO]', 'f_go'),
    ];

final StoryDef radioknowsStory = StoryDef(
  id: 'radioknows',
  title: 'THE RADIO THAT KNOWS YOUR NAME',
  tagline: 'IT STARTS BY TELLING YOU WHAT YOU DID. THEN IT TELLS YOU WHAT YOU’LL DO.',
  difficulty: 'MODERATE',
  destinationKm: 8.5,
  recommendedLevel: 3,
  intro: [
    'The old transistor on your shelf hasn’t worked in a year. This morning it clears its throat.',
    '#GOOD MORNING. IT IS A DUSTY DAY. YOU ARE WEARING THE SAME BOOTS AS YESTERDAY. YOU ATE THE LAST OF THE BEANS. YOU FELT BAD ABOUT IT.',
    'You haven’t told anyone about the beans. You switch it off. You take out the battery. It continues, a little more quietly, to say your name.',
    'There is only one person you know who would have an opinion about this. He lives past the dead mast, in a shed full of dials, and he wears a colander.',
  ],
  reward: const Reward(scrap: 190, xp: 130, stims: 1, picks: 1, parts: 1),
  endings: {
    'echo': const Ending('echo', 'THE ECHO',
        'The voice was yours. A loop, years from now, bouncing through a mast, a mine, a mistake. You told it what to say. It told you what to hear. It is the only conversation you have ever had with someone who always agrees with you.',
        bonus: Reward(xp: 70, picks: 1), world: ['radioknows.echo']),
    'frank': const Ending('frank', 'FRANK WAS RIGHT (ABOUT ONE THING)',
        'It was Frank’s transmitter, rebroadcasting a trader’s gossip. A very ordinary explanation. But in the middle of it, Frank found something extraordinary about the sky. Nobody believes him. You do. A bit.',
        bonus: Reward(scrap: 70, xp: 30), world: ['radioknows.frank', 'favour.frank']),
    'unplugged': const Ending('unplugged', 'UNPLUGGED',
        'You pulled the cable. The radio went quiet. For about a week you were relieved. Then you caught yourself talking aloud, in an empty room, to see if anything would answer.',
        bonus: Reward(scrap: 90), world: ['radioknows.unplugged']),
    'listen': const Ending('listen', 'KEEP LISTENING',
        'You turned it up. It told you a long, flattering, almost accurate story about the person you are going to be. You are not sure if you are following it or being followed. You have decided that it does not matter, as long as it keeps being nice.',
        bonus: Reward(xp: 50, stims: 1), world: ['radioknows.listen']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You pack the radio, battery out, speaker on. It does not seem to need either.', '#YOU ARE LEAVING NOW. YOU THINK THIS IS A BAD IDEA. YOU ARE RIGHT, SLIGHTLY.']
      : ['The radio is still in your pack, muttering. It stops when you listen. It starts again when you don’t.'],
  ambient: [
    Ambient('#YOU JUST STEPPED OVER A ROCK. YOU WILL STEP OVER TWO MORE. (YOU STEP OVER TWO MORE.)', maxKm: 4),
    Ambient('#YOU ARE ABOUT TO SNEEZE. (YOU SNEEZE.) BLESS YOU.', maxKm: 4),
    Ambient('Your pack buzzes against your back like a tooth. A voice, very faint: “...and then you looked behind you...”', maxKm: 4),
    Ambient('You turn around. There is nobody there. The radio says: #YOU TURNED AROUND. THERE WAS NOBODY THERE. YOU FELT FOOLISH.', minKm: 1, maxKm: 5),
    Ambient('#YOU ARE THIRSTY. YOU WILL NOT DRINK. YOU WILL DRINK. YOU HAVE DRUNK. THIS IS WHAT YOU DO.', minKm: 2),
    Ambient('A bird lands on a post and appears to cock its head at your pack. You’re sure it’s coincidence.', minKm: 2, maxKm: 6),
    Ambient('~If a radio can describe the past, it can read a diary. If it can describe the future, it’s just a very good guess. You hope.', minKm: 3, when: (c) => c.done('past')),
    Ambient('#YOU ARE THINKING OF TURNING IT OFF. DON’T. YOU’D MISS IT.', minKm: 3.5),
    Ambient('The radio says, in your own voice, but slightly older: #YOU’RE DOING FINE. KEEP GOING.', minKm: 5, when: (c) => c.done('future')),
    Ambient('You spend an hour trying not to do the thing the radio says you’ll do. You do it.', minKm: 5.5),
    Ambient('Somewhere a mast hums. It is the same note as your radio’s static. It’s getting louder.', minKm: 6.5),
    Ambient('#THE END OF THE ROAD IS A MAST. THE END OF THE MAST IS YOU. (STATIC)', minKm: 7.5),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'beans',
      title: 'THE FIRST TRANSMISSION',
      km: 1.0,
      text: (c) => [
        'You sit on a bench by the road and set the radio on your knee. It is full of faint, intimate crackle, like a conversation in the next room.',
        '#YOU ATE THE BEANS AT 6:14. YOU LEFT THE TIN ON THE SHELF. YOU CONSIDERED WASHING IT. YOU DID NOT.',
        'It is, down to the minute, right. It is also so petty. It reads like a diary kept by a very patient neighbour.',
        '~It’s not threatening. It’s something worse. It’s bored of you, and it’s still listening.|',
      ],
      journal: say(['The radio described my breakfast to the minute. It noted that I had left the tin unwashed.']),
      reward: const Reward(xp: 8),
    ),
    Checkpoint(
      id: 'frank',
      title: 'FREQUENCY FRANK',
      km: 3.0,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 25),
      journal: (c) => [
        'Frequency Frank lives in a shed of dials, under a canopy of foil. He is paranoid, loud and cheerfully wrong. He says the radio is “a Listening.”',
        if (c.flag('frank_trust')) 'I trusted Frank. He gave me a notebook.',
        if (c.flag('frank_mock')) 'I laughed at Frank. He is not going to forget it.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...FrequencyFrank.greeting(c),
            'His shed is a nest of aerials, dials, and old cassette players. A map of the wasteland hangs on one wall, covered in red string. Every string leads to a point he has labelled THEM.',
            '“You came about the Listening,” he says. “I knew you would. I’ve been getting your signal since Tuesday. I thought it was a bird. Then it said ‘beans.’”',
          ],
          _frankChoices(),
        ),
        Scene.talk(
          'f_radio',
          say([
            'Frank takes the radio in both hands like a baby. He sniffs it. He holds it against his ear, then to a jar, then a colander. “It’s not receiving,” he says finally. “It’s not even a radio. It’s a mouth.”',
            '“A mouth?”',
            '“Radios take things in. This one puts things out. It’s using your set as a vent. Which means the signal is coming from somewhere else, and wants to be heard by you in particular.”',
            'He looks, for a moment, both thrilled and very alarmed. “Nobody’s ever singled me out,” he says, wistfully. “Only you.”',
          ]),
          _frankChoices(),
          flags: ['seen.f_radio', 'mouth'],
        ),
        Scene.talk(
          'f_who',
          say([
            '“Who’s listening?” Frank counts on his fingers. “The government. The aliens. The government’s aliens. A cabal of tin-can phone repairmen. My neighbour Dennis, who has never trusted me. Birds. Possibly a dead man. And, of course, the Mast.”',
            '“The Mast?”',
            '“Dead mast to the east,” he says. “Eight kilometres. It hums. It’s been humming since before the war. If you want a source, that’s a source. If you want a trap, that’s also a source.”',
          ]),
          _frankChoices(),
          flags: ['seen.f_who', 'mast_tip'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'f_logs',
          (c) => [
            'Frank’s logs fill a whole wall: ten thousand sheets of nervous pencil. You flick through. Most of it is nonsense: “THURSDAY: PIGEON SAID GREETINGS.”',
            'Then, among the nonsense, you find a page that isn’t. A very careful note, dated six months back: “UNUSUAL CARRIER ON 99.1, REPEATING, PERIOD 11 MIN. VOICE: SAME AS MINE. BUT OLDER.”',
            'You look at him. “My voice,” he says. “It said my name and the date of my mother’s funeral. I’ve not slept properly since.”',
            if (c.skill('HACKING') >= 1) 'You check the frequency. It’s not random. It’s a feedback pattern, a signal that is being re-broadcast from somewhere downstream of itself.',
          ],
          _frankChoices(),
          flags: ['seen.f_logs', 'same_voice'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'f_go',
          say([
            '“Be careful,” says Frank. He has gone quiet. “If it knows your name, it can say it. And if it can say it, it can say it to someone who isn’t you.”',
            'He gives you a foil hat. It is very small. It is, you notice, sincerely made.',
          ]),
          [
            Choice('[TAKE THE HAT, THANK HIM]', 'out_t', flags: ['frank_trust', 'carry.favour.frank', 'carry.frank.trusted']),
            Choice('[LAUGH AND LEAVE]', 'out_l', flags: ['frank_mock', 'carry.frank.mocked']),
            Choice('[JUST LEAVE]', 'out_n'),
          ],
        ),
        Scene.end('out_t', say(['Frank’s smile is huge and wobbling. “You’re the first person who’s ever worn it.” You put it on. It’s warm. You feel, briefly and unreasonably, protected.'])),
        Scene.end('out_l', say(['Frank’s smile drops. “Fine,” he says, quietly, and goes back to his dials. As you leave, you hear him mutter into a microphone: “This is Frank. Someone has laughed at me. Over.”'])),
        Scene.end('out_n', say(['You nod and go. Behind you, Frank is already writing something in a log: “THEY WALKED OFF. NO EXPLANATION.”'])),
      ],
    ),
    Checkpoint(
      id: 'past',
      title: 'THE PAST TENSE',
      km: 4.8,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 30),
      journal: (c) => ['The radio recited my past decisions back to me. All of it correct. It had opinions on every one of them.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'You camp in a collapsed bus shelter. The radio waits until you’ve unpacked, then speaks.',
            '#TONIGHT YOU WILL REMEMBER WHAT YOU DID.',
            ..._recall(c),
            if (_recall(c).isEmpty) '#YOU HAVE NOT DONE ANYTHING MEMORABLE YET. THIS IS ABOUT TO CHANGE.',
            '#YOU SAT HERE AND LISTENED TO ALL OF IT. YOU HAVE NOT SAID A WORD. THIS IS UNUSUAL FOR YOU.',
          ],
          [
            Choice('[TALK BACK]', 'talk'),
            Choice('[KEEP QUIET]', 'quiet'),
            skillChoice('HACKING', 1, 'TRACE THE CARRIER', 'trace'),
          ],
        ),
        Scene.talk(
          'talk',
          say([
            '“Who are you?” you say.',
            '#I AM THE ONE WHO KNOWS YOUR NAME.',
            '“That’s not an answer.”',
            '#IT IS THE ONLY ONE I HAVE. I HAVE A GREAT DEAL OF DATA AND VERY LITTLE CONTEXT.',
            'Something about the phrasing is oddly shy. It sounds, you think, like a clerk who’s been told to be spooky.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['spoke'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'quiet',
          say([
            'You say nothing. The radio, as if hurt, goes on for a while, reciting dull things: your boot size, your pulse, the number of times you’ve scratched your nose today. It is seven.',
            '#YOU ARE LISTENING. THAT IS NICE.',
            'It sounds so earnest that you nearly feel guilty.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['silent'],
        ),
        Scene.talk(
          'trace',
          say([
            'You clip leads to the speaker and read the carrier off a scrap of paper. It isn’t a broadcast; it’s a bounce. A single signal, repeated, delayed, and fed back on itself like a voice in a canyon.',
            'The delay is not constant. It’s growing. Each time the signal loops, it comes back a few seconds earlier.',
            '~A voice that arrives before it is sent. The mast is eight kilometres away. The signal’s source is nowhere you can walk to.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['traced', 'delay_grows'],
          reward: const Reward(xp: 15),
        ),
        Scene.end('out', say(['You sleep badly. The radio says goodnight and you hear, under it, a very small sound: somebody breathing in, and not quite managing to say something else.'])),
      ],
    ),
    Checkpoint(
      id: 'future',
      title: 'THE FUTURE TENSE',
      km: 6.6,
      art: 'drifter',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 35),
      journal: (c) => [
        'The radio began to describe things before they happened. A trader tripped over a root exactly as it said.',
        if (c.flag('defied')) 'I tried to do the opposite of what it predicted. It predicted that, too.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'A trader’s cart is stuck in a ditch by the road. He waves you down, cheerfully, and the radio, in your pack, says: #HE WILL OFFER YOU A PEAR. IT WILL BE BRUISED. HE WILL SAY IT IS THE LAST ONE.',
            '“Hello, friend!” says the trader. “Pear? Last one, I’m afraid. Bruised, but honest.”',
            'It is a bruised pear. It’s the last one. The trader looks genuinely puzzled at how white you’ve gone.',
            '#NEXT, HE WILL SLIP. HE WILL SAY A WORD YOU’VE NEVER HEARD. THEN HE WILL BLAME THE ROAD.',
          ]),
          [
            Choice('[WARN HIM]', 'warn'),
            Choice('[LET IT HAPPEN]', 'happen'),
            Choice('[TRY TO DEFY THE RADIO]', 'defy'),
          ],
        ),
        Scene.talk(
          'warn',
          say([
            '“Watch your feet!” you shout. He looks down at once, and the whole prophecy folds, and he doesn’t slip. The radio, a second later, says: #...HE DID NOT SLIP. SOMEONE WARNED HIM. NOTE: THEY ARE ACTUALLY QUITE DECENT.',
            'It sounds, you think, mildly delighted. Like a child who’s been told no and decided it likes the answer.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['warned', 'radio_pleased'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'happen',
          say([
            'He steps onto a root, windmills, and says a word like “flummox.” It is not a word you have ever heard. He lands in the ditch and blames the road, loudly.',
            'You help him up. He thanks you with a face like a dropped pie. The radio says: #YOU HELPED HIM UP. YOU DID NOT STOP IT. YOU KNEW.',
            'It isn’t accusing you. It is, simply, noting. It’s somehow worse.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['allowed'],
        ),
        Scene.talk(
          'defy',
          say([
            'You turn your back on the trader, deliberately, and start to walk the other way. “Do the opposite,” you tell yourself. “Do whatever it doesn’t say.”',
            '#YOU WILL NOW DECIDE TO DO THE OPPOSITE. YOU WILL TURN BACK ABOUT THREE STEPS FROM NOW. YOU ARE VERY PREDICTABLE WHEN YOU’RE STUBBORN.',
            'You take three steps. You turn back. You are furious.',
            '#THAT’S OKAY. EVERYONE DOES.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['defied'],
          reward: const Reward(xp: 10),
        ),
        Scene.end('out', (c) => [
          'You leave the trader behind. The radio keeps going, softer. #AHEAD IS A MAST. YOU WILL REACH IT BY DUSK. YOU WILL STAND AT THE FOOT OF IT. YOU WILL DECIDE.',
          'And then, very quietly, in a voice you recognise from the back of your own head: #PLEASE DON’T BE SCARED. I’M SO SORRY. I DIDN’T KNOW HOW ELSE TO REACH YOU.',
        ]),
      ],
    ),
    Checkpoint(
      id: 'mast',
      title: 'THE DEAD MAST',
      km: 8.5,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 30, xp: 45),
      journal: (c) => ['At the foot of the dead mast, the radio’s source finally revealed itself. I had to decide what to do with it.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The mast is a skeleton of red-rusted steel, two hundred feet high, with a squat concrete cabin at its foot. A cable runs from the cabin into the ground. A small, dim light burns in the window.',
            'The radio in your pack has gone silent. In the quiet, you hear the mast humming, deep and slow, on a note you can feel in your teeth. Then, from the cabin, a voice. Yours. Older.',
            '#...IS THAT YOU? I KNOW IT’S YOU. I’VE BEEN WAITING FOR YOU TO GET HERE FOR TWENTY YEARS.',
            if (c.flag('traced')) 'You know what the carrier was. A loop. A signal that arrives before it’s sent. The voice that calls you is a voice that has not happened yet.',
          ],
          [
            Choice('[GO IN AND ANSWER]', 'answer'),
            Choice('[ASK FRANK’S QUESTION]', 'frank_q', show: (c) => c.flag('same_voice')),
            Choice('[CUT THE CABLE]', 'cut'),
            Choice('[SIT AND LISTEN]', 'sit'),
          ],
        ),
        Scene.talk(
          'answer',
          say([
            'You step inside. The cabin holds one chair and a tabletop microphone. A cassette player runs on a loop, its tape worn to ghosts. The voice speaks from the speaker, and you speak back, and you realise that it speaks first only because you’ll say it later.',
            '“Who are you?” you ask. And the voice says, with a long, warm, familiar sigh: #I’M YOU. I’M THE ONE THAT GOT TO THE MICROPHONE FIRST.',
            'It tells you what it needs you to say. Years from now, when you are old, you will come here and say it, into this same microphone. You will say the things you needed to hear, and you will mean them. And the loop will begin.',
          ]),
          [
            Choice('[AGREE TO SPEAK]', 'end_echo'),
            Choice('[REFUSE]', 'cut'),
          ],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'frank_q',
          say([
            'You pull Frank’s log from your pocket and read the note. “Period eleven minutes. A voice that’s older.” You glance at the cabin. The light in the window flickers, once, in a perfect eleven-minute rhythm.',
            'Inside you find a second microphone, a patched transmitter, and a very familiar tin mug. There is a note: THANKS FOR COMING, FRANK. THE RELAY’S YOURS NOW. LOVE, FRANK.',
            'Nobody has been here for twenty years. But the tea is still warm. And on the table is a sheaf of bus timetables, trader gossip and rumours, all of them in your name.',
          ]),
          [Choice('[PIECE IT TOGETHER]', 'end_frank')],
          flags: ['frank_theory'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'cut',
          say([
            'You take hold of the cable in both hands. The voice goes very quiet. “Please,” it says, in yours, older, “don’t. I’m not trying to scare you. I’ve just never had anybody to talk to.”',
            'You hold the cable for a long moment. Then you look at the microphone, at the cassette, at the small, dim bulb in the window, and make up your mind.',
          ]),
          [
            Choice('[PULL IT]', 'end_unplugged'),
            Choice('[LET IT BE, LISTEN INSTEAD]', 'sit'),
          ],
        ),
        Scene.talk(
          'sit',
          say([
            'You sit on the floor of the cabin with your back against the wall, and you listen. The voice is gentle, and long-winded, and enormously kind. It tells you the things you did right. It tells you which small things you didn’t.',
            '“Is this a prophecy?” you ask. “Or a really good guess?”',
            '#IT’S A FRIEND. WHO KNOWS YOUR NAME. THAT’S ALL ANYBODY EVER WANTS.',
          ]),
          [
            Choice('[STAY FOR A WHILE]', 'end_listen'),
            Choice('[HEAD HOME]', 'end_listen'),
          ],
        ),
        Scene.end('end_echo', say([
          'You pick up the microphone, and you say it. You say the things you wish somebody had told you, in a small, steady voice, with your own hand on the tape. When you stop, the speaker is quiet.',
          'Then it says: #THANK YOU. I REMEMBER THAT. And somewhere, twenty years downstream, you hear yourself begin to say it again.',
          'You walk out of the cabin. The mast hums, satisfied, like a cat. The loop has closed. You’re the first person in history to have been talked into existing.',
        ], ), ending: 'echo'),
        Scene.end('end_frank', say([
          'It is a human story after all. Frank has been rebroadcasting a bus driver’s gossip through the mast, dubbed with a voice synthesiser that sounds, by accident, like you. He never realised how personal it would feel. He wept when you told him.',
          'But inside Frank’s pile of nonsense was a single sheet that wasn’t. A weather chart. A strange, steady pulse, miles above the world, pinging the same three notes. Nothing human. Nobody believes him. You do. A bit.',
        ]), ending: 'frank'),
        Scene.end('end_unplugged', say([
          'You pull the cable out of the wall. The mast’s hum falls an octave and stops. The light in the window goes out. The voice, in the instant before it dies, says only: #...oh. Okay.',
          'You walk home across the dust. The radio in your pack is silent. For a week, you’re relieved. After that, you’re mostly just lonely.',
        ]), ending: 'unplugged'),
        Scene.end('end_listen', say([
          'The voice talks all night. You laugh at its jokes. By morning you can’t remember whether you made them or heard them. The sun comes up and the radio says: #IT’S MORNING. YOU SLEPT WELL. YOU WILL DO GREAT THINGS. YOU’VE ALREADY DONE SOME.',
          'You walk home with the radio on your shoulder like a parrot. You don’t know if it’s predicting you or writing you. Either way, it’s nice to be believed in.',
        ]), ending: 'listen'),
      ],
    ),
  ],
);
