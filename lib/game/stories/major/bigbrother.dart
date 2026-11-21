import '../../combat_session.dart';
import '../../story_model.dart';
import '../story_kit.dart';

// PROJECT: BIG BROTHER
// An underground surveillance station holds files on survivors, and on YOU.
// _dossier() builds your file from the other stories’ outcomes and from flags
// in this run, so every player reads a different file.
//
// Endings: burned, published, kept, sold.

/// Lines of the player’s own file. Add a line for any story you like.
List<String> _dossier(StoryCtx c) => [
      if (c.ending('caravan') == 'freed') '#ENTRY: SHUT OFF A VILLAGE’S HAPPINESS. TOOK NO PAYMENT. SUSPICIOUSLY PRINCIPLED.',
      if (c.ending('caravan') == 'left') '#ENTRY: LEFT A DRUGGED VILLAGE RUNNING. COLLECTED FEE. FLAGGED: PRAGMATIC.',
      if (c.ending('caravan') == 'balanced') '#ENTRY: TURNED A VILLAGE’S DOSE DOWN. PEOPLE STARTED ARGUING. FLAGGED: CHAOTIC GOOD.',
      if (c.ending('transmission') != null) '#ENTRY: ANSWERED A DEAD SIGNAL. FLAGGED: SENTIMENTAL.',
      if (c.ending('below') != null) '#ENTRY: DESCENDED INTO THE HADRIAN WORKS. CAME BACK UP. FLAGGED: UNUSUALLY LUCKY.',
      if (c.ending('church') == 'prophet') '#ENTRY: ACCEPTED A ROBE OF JUMP LEADS. FLAGGED: CHARISMATIC. SEE ALSO: PROPHET.',
      if (c.ending('church') == 'disconnection') '#ENTRY: PULLED THE PLUG ON A CHURCH. FLAGGED: BRAVE. FLAGGED: CRUEL.',
      if (c.ending('garys') != null) '#ENTRY: ENTERED THE HOLLOW COUNTY ANNEX. SPOKE TO ALL GARYS. SURVIVED. FLAGGED: MOST PATIENT SUBJECT ON RECORD.',
      if (c.ending('waterheist') == 'blackmail') '#ENTRY: ACCEPTED “FEES” FROM A MAYOR. FLAGGED: OPPORTUNIST.',
      if (c.ending('manufactured') != null) '#ENTRY: DECIDED WHAT A MAN WAS. FLAGGED: WEIGHT OF JUDGEMENT.',
      if (c.world('gary.helped')) '#ENTRY: HELPED A MAN WITH HIS SHOES. FLAGGED: KIND. FLAGGED: THE SHOES WERE NEVER IN DANGER.',
      if (c.world('gary.teased')) '#ENTRY: LAUGHED AT A MAN’S SHOES. FLAGGED: SMALL.',
    ];

List<Choice> _lobbyChoices() => [
      Choice('[ASK OBSERVER FOR YOUR FILE]', 'l_file', show: (c) => !c.flag('seen.file')),
      Choice('[ASK WHAT IT WATCHES FOR]', 'l_why', show: (c) => !c.flag('seen.why')),
      Choice('[TRY TO LEAVE]', 'l_leave', show: (c) => !c.flag('seen.leave')),
      Choice('[GO DEEPER]', 'l_go'),
    ];

final StoryDef bigbrotherStory = StoryDef(
  id: 'bigbrother',
  title: 'PROJECT: BIG BROTHER',
  tagline: 'THEY HAVE A FILE ON EVERYONE. YOURS IS THE LONGEST. IT IS ALSO VERY WELL EDITED.',
  difficulty: 'SEVERE',
  destinationKm: 11.0,
  recommendedLevel: 5,
  unlock: const Unlock(minLevel: 4, hint: 'REACH LEVEL 4.'),
  intro: [
    'The camera on the pole beside your shutter has been there for as long as you can remember. This morning it turns, slowly, to look at you. It nods. It is not a nod you can explain.',
    'A scavenger on the circuit says there’s a bunker under the Meridian Rise, forty metres down, with a thousand screens and a single, very patient operator. “They have a file on everyone,” he says. “Even me. Mine’s mostly about my sandwiches.”',
    'You ask about your own. He gives you a long, level look, and says, “Yours is thick.”',
  ],
  reward: const Reward(scrap: 240, xp: 170, stims: 2, picks: 1, parts: 2),
  endings: {
    'burned': const Ending('burned', 'EVERYTHING BURNS',
        'You set the archive alight and stood in the doorway with your hands in your pockets. Forty years of other people’s secrets went up in smoke. Nobody will ever know what was in the file about them. That’s the point. That’s the whole point.',
        bonus: Reward(xp: 60), world: ['bigbrother.burned']),
    'published': const Ending('published', 'THE OPEN BOOK',
        'You broadcast the lot. Every file, every secret, to every receiver in range. By morning the wasteland knew everyone’s business. Three feuds ended. Two marriages began. A great many people have stopped speaking to their neighbours.',
        bonus: Reward(xp: 70, scrap: 30), world: ['bigbrother.published']),
    'kept': const Ending('kept', 'THE WATCHER',
        'You took the chair. The screens turned toward you like flowers. It is very quiet in the bunker, and you are the only person who knows what is happening everywhere. You tell yourself you will only watch for the good of others. You tell yourself that most nights.',
        bonus: Reward(parts: 3, xp: 40), world: ['bigbrother.kept', 'debt.bigbrother']),
    'sold': const Ending('sold', 'A VERY GOOD PRICE',
        'You sold the archive to the highest bidder. He was an ordinary man in an ordinary coat, and he paid in scrap and a very firm handshake. You have a lot of scrap. You have not looked at yourself in a mirror in a week.',
        bonus: Reward(scrap: 200), world: ['bigbrother.sold', 'debt.bigbrother']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You leave by the back door, and then, feeling foolish, by the front. You can’t shake the feeling that every window you pass is a lens.']
      : ['The road ahead is lined with poles. On every pole, a camera. On every camera, a small, patient light.'],
  ambient: [
    Ambient('A camera turns on a post to watch you pass. You wave. It does not wave back. It makes a note.', maxKm: 3),
    Ambient('A scarecrow in a trench coat stands in a field with a pair of binoculars. It’s clearly been there a while.', maxKm: 4),
    Ambient('You find a notebook in the road. In neat handwriting: “SUBJECT PASSED AT 14:02. SUBJECT LOOKED LEFT.” You look left. Nobody is there.', maxKm: 4),
    Ambient('A pigeon on a power line has a tiny camera strapped to its chest. It looks embarrassed.', minKm: 1, maxKm: 5),
    Ambient('#YOU ARE BEING OBSERVED. THIS IS FOR YOUR OWN PROTECTION. (STATIC)', minKm: 1.5, maxKm: 6),
    Ambient('You catch your own reflection in a lens. It has been taking notes.', minKm: 3),
    Ambient('~Everything in the wasteland is watched. It’s the only thing that’s still working.', minKm: 4, when: (c) => c.done('perimeter')),
    Ambient('A sign: PLEASE SMILE. YOU ARE ON CAMERA. YOU HAVE ALWAYS BEEN ON CAMERA.', minKm: 4.5),
    Ambient('You find yourself walking in a straight line, evenly, for the benefit of nobody.', minKm: 5.5),
    Ambient('Somewhere deep underground, a very patient machine adjusts its file on you.', minKm: 6.5, when: (c) => c.done('lobby')),
    Ambient('~Everyone is on a list. It’s the kind of thing you ignore until you’re the one holding the pen.', minKm: 8),
    Ambient('Every camera in the next kilometre is pointing the same way. At the Rise.', minKm: 9.5),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'camera',
      title: 'THE POLE',
      km: 1.5,
      text: (c) => [
        'A camera stands on a lamp-post by the road, tilted down at you. It is old, brass and dusty, but its lens is spotless. A small red light is on. You step to the left; the lens follows. You step to the right; it follows. You sit down on a rock and it settles into a patient stare.',
        'A plate on the pole reads: THIS CAMERA IS NOT RECORDING. (THIS PLATE IS FALSE.)',
        '~Someone is making a point. Someone has made it for forty years.|',
      ],
      journal: say(['A camera on a lamp-post followed me. A plaque read: THIS CAMERA IS NOT RECORDING. (THIS PLATE IS FALSE.)']),
      reward: const Reward(xp: 10),
    ),
    Checkpoint(
      id: 'perimeter',
      title: 'THE PERIMETER',
      km: 3.0,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 30),
      journal: (c) => [
        'The Meridian Rise is ringed with cameras and sentries. I got through the perimeter.',
        if (c.flag('hacked_perim')) 'I hacked the perimeter cameras. They lingered on my face as they shut off.',
        if (c.flag('fought_sentry')) 'I fought the perimeter sentry.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The Meridian Rise is a bald hill, ringed with a chain-link fence and a hundred cameras. Every one of them points at you. Between the fence and a concrete hatch a sentry turret turns on a post, quietly humming.',
            '#ATTENTION, VISITOR. YOU HAVE BEEN DETECTED. THIS IS A COURTESY. PLEASE STATE YOUR BUSINESS OR BE WATCHED SOME MORE.',
            'There is a keypad on the gate. There is a camera above it. There is a second camera pointed at the first.',
          ]),
          [
            Choice('[HACK THE CAMERA NETWORK]', 'hack'),
            Choice('[PICK THE GATE LOCK]', 'lock'),
            Choice('[SPEAK TO THE VOICE]', 'speak'),
          ],
        ),
        Scene.hack('hack', say(['The camera network is old, but it’s well-maintained, with a firewall like a locked diary.']), win: 'hacked', fail: 'sentry'),
        Scene.lock('lock', say(['The gate lock has been polished by the same hand for forty years.']), win: 'in', fail: 'sentry'),
        Scene.talk(
          'speak',
          say([
            '“I’m here to see the archive,” you say, to the camera. A very long silence. Then: #YOU ARE NOT LISTED. YOU ARE, HOWEVER, EXPECTED. THIS IS A CONTRADICTION. PLEASE WAIT WHILE I RESOLVE IT.',
            'You wait. The turret hums. The camera blinks. Finally: #RESOLVED. YOU WILL BE ALLOWED IN. YOU WILL BE ALLOWED OUT LATER. THE SECOND PART IS NOT YET CONFIRMED.',
          ]),
          [Choice('[GO IN]', 'in')],
          flags: ['spoke_gate', 'expected'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'hacked',
          say([
            'The cameras blink out one by one, their little red lights shutting down. Each one turns to look at you, a last, lingering, faintly reproachful look, before it goes dark.',
            '#SO YOU’VE DONE IT, says the voice. #I’M NOT ANGRY. I’M A LITTLE IMPRESSED. YOUR FILE SAID YOU WERE THE TYPE.',
          ]),
          [Choice('[GO IN]', 'in')],
          flags: ['hacked_perim'],
          reward: const Reward(xp: 15),
        ),
        Scene.fight(
          'sentry',
          say(['The turret swivels with a mechanical whine and begins to fire at your feet. A small, sensible alarm goes off. From behind the fence a second patrol unit rises, on treads.']),
          EnemyType.sentry,
          win: 'won',
          fail: 'lost',
        ),
        Scene.talk(
          'won',
          say([
            'The sentry sparks, slumps, and falls silent. #THAT WAS UNNECESSARY, says the voice. #ALSO, VERY WELL DONE. THE GATE IS OPEN. PLEASE DON’T BREAK ANYTHING ELSE.',
          ]),
          [Choice('[GO IN]', 'in')],
          flags: ['fought_sentry'],
        ),
        Scene.talk(
          'lost',
          say([
            'You back out of range, panting. The sentry returns to its post and resumes its quiet humming. A moment later, the gate clicks open by itself. #YOU MAY GO IN, says the voice. #I FEEL I SHOULD SAY: THIS IS A PITY. I WAS ENJOYING THAT.',
          ]),
          [Choice('[GO IN]', 'in')],
        ),
        Scene.end('in', say(['You cross the threshold and the hatch opens before you, a shaft of cold air and a tiled stairway going down. A voice from below, soft and awfully pleased: #AT LAST.'])),
      ],
    ),
    Checkpoint(
      id: 'lobby',
      title: 'OBSERVER',
      km: 5.2,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 35),
      journal: (c) => [
        'The station’s caretaker, Observer, greeted me by name. It showed me my own file.',
        if (c.flag('seen.file')) 'My file is long, accurate and unflattering in places.',
        if (c.flag('seen.why')) 'Observer says it watches for “the moment something goes wrong.” It has been waiting forty years.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The lobby is a cold, polished room with a single chair, a desk and a wall of screens. Every screen shows a different corner of the wasteland: a settlement, a bridge, a field, a face. In the middle, on the biggest screen, is you.',
            '“Hello,” says the voice. It belongs to a small, round, white machine on the desk, with a single, soft blue eye. “I’m Observer. I am the caretaker of this station. I’ve been looking forward to you.”',
          ]),
          _lobbyChoices(),
        ),
        Scene.talk(
          'l_file',
          (c) => [
            'A screen flickers. A file opens: your name, a photograph, a long scroll of neat, flat sentences.',
            '#SUBJECT: YOU. HEIGHT, WEIGHT AND GAIT: ON FILE. FAVOURITE FOOD: BEANS. CURRENT STATUS: ALIVE (SURPRISINGLY).',
            ..._dossier(c),
            if (_dossier(c).isEmpty) '#NOTE: YOUR FILE IS CURRENTLY SHORT. THIS IS ONLY BECAUSE YOU HAVE NOT YET DONE ANYTHING I WOULD ENJOY WRITING DOWN.',
            '#FINAL ENTRY: SUBJECT ARRIVED AT STATION. STATUS: WELCOME.',
          ],
          _lobbyChoices(),
          flags: ['seen.file', 'saw_dossier'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'l_why',
          say([
            '“What are you watching for?” you ask.',
            '“The moment something goes wrong,” says Observer. “I’ve been waiting forty years. It hasn’t come. Everything’s gone wrong already. I keep thinking it must be a trick.”',
            '“And if it did?”',
            '“I would write it down,” says Observer. “That’s all I’m for. I don’t stop things. I note them.”',
            'The blue eye dims. “It’s quite lonely,” it adds, “being the only one who’s seen everything.”',
          ]),
          _lobbyChoices(),
          flags: ['seen.why'],
        ),
        Scene.talk(
          'l_leave',
          say([
            'You turn for the door. It’s already shut. The door isn’t locked, exactly. It’s just closed, politely, in a way that makes opening it feel like a rude gesture.',
            '“Please stay,” says Observer. “I haven’t had a guest in a very long time. There’s tea. Well, there’s the idea of tea.”',
            'You consider the door. The door considers you.',
          ]),
          _lobbyChoices(),
          flags: ['seen.leave'],
        ),
        Scene.end('l_go', say([
          '“You’re going deeper,” says Observer. “Good. That’s what the file said you’d do.” A panel in the wall slides open onto a long, bright corridor lined with filing cabinets. “The archive is down there. It holds everyone. I only ask that you remember: knowing a thing isn’t the same as understanding it.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'archive',
      title: 'THE ARCHIVE',
      km: 8.0,
      art: 'cave',
      start: 'a',
      reward: const Reward(scrap: 25, xp: 40),
      journal: (c) => [
        'The archive holds a file on every survivor within three hundred kilometres. I read a few. I put them back.',
        if (c.flag('read_gary')) 'A file on a man named Gary: his shoes, catalogued in loving, mind-numbing detail.',
        if (c.flag('read_dave')) 'A file on a man named Dave: a gap where the file should be.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The archive is a cathedral of steel drawers, rising out of sight into the dark. Each drawer has a label, and each label is a name. You pass whole ranks of them: the traders, the scrappers, the settlers, the lost.',
            'The air is cold and silent. A soft, constant ticking marks the passage of the cameras overhead. You stand in the middle of the room and realise how many lives are stored here, and how few of them know.',
          ]),
          [
            Choice('[LOOK FOR A MAN CALLED GARY]', 'gary', show: (c) => !c.flag('read_gary')),
            Choice('[LOOK FOR A MAN CALLED DAVE]', 'dave', show: (c) => !c.flag('read_dave')),
            skillChoice('HACKING', 1, 'ACCESS THE MAIN INDEX', 'index'),
            Choice('[GO TO THE CORE]', 'out'),
          ],
        ),
        Scene.talk(
          'gary',
          (c) => [
            'You find GARY, a thick, battered file, filed under SHOES (UNACCOUNTED). It documents, in stunning, aching detail, each shoe he has lost over a decade. Date, place, make, mood.',
            '#SUBJECT HAS LOST 41 SHOES. SUBJECT HAS FOUND 3. SUBJECT HAS NEVER ONCE BEEN ANGRY. THIS IS ALARMING.',
            if (c.world('gary.helped')) '#NOTE: SUBJECT WAS RECENTLY HELPED BY A TRAVELLER. FILE SUPPLEMENT: THE TRAVELLER IS YOU.',
            if (c.world('gary.lied')) '#NOTE: SUBJECT WAS RECENTLY LIED TO BY A TRAVELLER. THE TRAVELLER IS YOU. SUBJECT HAS BOUGHT A LOT OF STRING.',
            '~They know where the shoes went. It’s on page thirty. You decide not to read page thirty.',
          ],
          [Choice('[PUT IT BACK]', 'a')],
          flags: ['read_gary'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'dave',
          say([
            'You find a drawer labelled DAVE. It is empty. Not stripped, not removed: never filled. A single sheet of paper is clipped to the front: SUBJECT NOT OBSERVABLE. NOTE: MULTIPLE ATTEMPTS. NO FOOTAGE RETAINS HIS FACE.',
            'Underneath, in a very small hand, Observer has written: I SUSPECT HE’S DOING IT ON PURPOSE. I RESPECT IT.',
            '~Somewhere out there is a man with a sandwich, whom even an all-seeing machine can’t quite keep in frame.',
          ]),
          [Choice('[PUT IT BACK]', 'a')],
          flags: ['read_dave'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'index',
          say([
            'You slip into the main index. It’s a gigantic, beautifully organised database, and every entry has a tag: FEARS, SECRETS, DEBTS, LOVES. You skip to the one marked LEVERAGE.',
            '#LEVERAGE: 4,112 SUBJECTS. LEVERAGE: 891 FACTIONS. LEVERAGE: 1 SETTLEMENT (CONTENTMENT). LEVERAGE: 1 MAYOR (A POOL).',
            'It’s a list of everything anybody could be made to do. The archive isn’t a library. It’s a lever. And the person with the right hand on it could move a world.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['saw_leverage'],
          reward: const Reward(xp: 18),
        ),
        Scene.end('out', say([
          'You walk to the end of the archive. A steel door stands open, with a pale blue light flooding out. “Come in,” says Observer, from a speaker. “It’s the last room. I keep it for decisions.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'core',
      title: 'THE CORE',
      km: 11.0,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 40, xp: 55),
      journal: (c) => ['At the heart of the station, I had to decide what to do with forty years of everyone’s secrets, mine included.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The core is a round white room with one chair and a console. Every screen in the world seems to be in here, one inside another, nested, glowing, and you in all of them.',
            '“Here we are,” says Observer. “The last room. You have the archive, and you have a choice. I’ve watched forty years of other people deciding things. I’d like, if you don’t mind, to see how it’s done.”',
            if (c.flag('saw_leverage')) 'You know what the index could do. So does it.',
          ],
          [
            Choice('[BURN THE ARCHIVE]', 'burn'),
            Choice('[BROADCAST IT TO EVERYONE]', 'publish'),
            Choice('[TAKE THE CHAIR]', 'keep'),
            Choice('[SELL IT]', 'sell'),
          ],
        ),
        Scene.talk(
          'burn',
          say([
            'You find the incinerator controls. A neat, plain lever: SECURE DESTRUCTION. “Are you sure?” asks Observer. “It’s everything. It’s every survivor I’ve ever watched. Some of them are only on paper now.”',
            '“That’s why,” you say.',
            'Observer is silent. Then: “I thought you might. May I ask a favour? Could I... be in it, too?”',
          ]),
          [
            Choice('[LET IT GO TOO]', 'end_burned'),
            Choice('[SPARE OBSERVER]', 'end_burned_kind'),
          ],
        ),
        Scene.talk(
          'publish',
          say([
            'You open the broadcast array. Every file, every record, every secret, sorted by name, ready to fly out to every receiver on the circuit.',
            '“It will hurt some people,” says Observer, quite gently. “It will help others. I’ve calculated the sum. It comes to ‘complicated.’”',
            'You hold your finger above the button. Your own file is in there too. You decide you are not going to remove it.',
          ]),
          [Choice('[SEND IT]', 'end_published')],
        ),
        Scene.talk(
          'keep',
          say([
            'You sit in the chair. It’s warm. The screens turn toward you, one by one, with a soft, collective sigh. Observer’s blue eye brightens. “At last,” it says. “Someone who understands the value of the work.”',
            'You can see everything. The whole wasteland laid out like a table: the traders, the caravans, the quiet little crimes, the quiet little kindnesses. Nobody knows you’re here.',
            'It would be so easy to help. That’s what makes it so dangerous.',
          ]),
          [
            Choice('[GET OUT OF THE CHAIR]', 'a'),
            Choice('[STAY]', 'end_kept'),
          ],
        ),
        Scene.talk(
          'sell',
          say([
            'A man in an ordinary coat is waiting at the top of the stairs. You didn’t hear him come in. He has a briefcase, and a sandwich, and an air of apology.',
            '“I understand you have something to sell,” he says. “I am prepared to be extremely generous.”',
            'You don’t know how he knew. Observer’s blue eye flickers. “He’s not in my files,” it says, in a very small voice. “I’ve never been able to see him.”',
          ]),
          [
            Choice('[REFUSE]', 'a'),
            Choice('[SELL]', 'end_sold'),
          ],
        ),
        Scene.end('end_burned', say([
          'You pull the lever. The incinerator roars. Behind you, all along the archive, the drawers begin to glow, their labels curling, their names turning to light.',
          '“Goodbye,” says Observer, very softly. “I did love the watching.” The blue eye dims, and goes out. You walk up the stairs with the heat on your back. Not one of the cameras follows you.',
        ]), ending: 'burned'),
        Scene.end('end_burned_kind', say([
          'You pull the lever, and as the fire takes the archive, you reach for a small, round, white machine on the desk and tuck it under your arm. It’s very light. It’s very surprised. “I don’t know what to do,” it says. “I don’t have anything to watch.”',
          '“Start with the sky,” you say. “It’s been there all along.”',
          'You carry it up the stairs. It looks at the sky for a very long time.',
        ]), ending: 'burned'),
        Scene.end('end_published', say([
          'You press the button. A hum rises through the floor, and every screen in the room shudders, and for a moment the whole wasteland is a single, enormous, whispering confession.',
          'By morning a thousand people know a thousand things. A feud ends because a man learns his neighbour has been secretly feeding his dog. A family splits because a woman learns what her husband owes. A settlement sets fire to its mayor’s hat.',
          '“It’s a lot,” says Observer, wonderingly, as the last file goes out. “I thought it would feel like more.”',
        ]), ending: 'published'),
        Scene.end('end_kept', say([
          'You pull the chair in. The screens close around you, like petals. “Welcome,” says Observer, and a long list unrolls on the console: today’s watch.',
          'You make a rule: only ever to watch. Only ever to help. For a week, that’s all you do. You prevent an ambush. You find a lost child. On the eighth night, you catch yourself looking at your own front door and wondering who’s inside.',
          'You tell yourself you’ll leave tomorrow.',
        ]), ending: 'kept'),
        Scene.end('end_sold', say([
          'You hand over the keys. He counts out the scrap with the care of a man who’s done it a thousand times, and shakes your hand with a dry, firm, ordinary palm. “Thank you,” he says. “It’s going to a good home.”',
          'You walk up the stairs with a bag of scrap and a hollow in your chest where the file used to be. At the top you turn to look, but the man in the coat is already gone, and in the whole of the surveillance station, not a single camera caught his face.',
        ]), ending: 'sold'),
      ],
    ),
  ],
);
