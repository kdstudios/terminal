import '../story_model.dart';

// THE LAST TRANSMISSION
// "We made it to the surface" was a drill tape. It went out early, by accident,
// on the worst day in history. The woman who recorded it has spent forty-one
// years editing it into something she can live with.

List<Choice> _dentistChoices() => [
      Choice('[CHECK THE DENTIST’S CHAIR]', 'chair', show: (c) => !c.flag('seen.chair')),
      Choice('[HACK THE APPOINTMENT TERMINAL]', 'hackt', show: (c) => !c.flag('seen.terminal')),
      Choice('[SEARCH THE RECEPTION DESK]', 'desk', show: (c) => !c.flag('seen.desk')),
      Choice('[LEAVE]', 'leave'),
    ];

List<Choice> _pilgrimChoices() => [
      Choice('[GIVE THE SICK GIRL A STIMPACK] (-1)', 'stim',
          needStim: 1, show: (c) => !c.flag('logbook')),
      Choice('[TELL HIM IT’S A RECORDING]', 'recording', show: (c) => !c.flag('logbook')),
      Choice('[SIT DOWN AND LISTEN WITH THEM]', 'listen', show: (c) => !c.flag('logbook')),
      Choice('[LEAVE THE LISTENERS]', 'leave'),
    ];

List<Choice> _dishChoices() => [
      Choice('[HACK THE SENTRY’S MAINTENANCE PORT]', 'hacks'),
      Choice('[FIGHT THE SENTRY]', 'fights'),
      Choice('[CREEP IN OVER THE BROKEN GLASS]', 'sneak'),
    ];

List<Choice> _meetChoices() => [
      Choice('[KEY THE MIC AND ANSWER HER]', 'end_answered'),
      Choice('[RECORD THE TRUTH]', 'studio'),
      Choice('[HELP KEEP IT RUNNING] (-3 PARTS)', 'end_kept', needParts: 3),
      Choice('[PULL THE PLUG]', 'end_silenced'),
    ];

final StoryDef transmissionStory = StoryDef(
  id: 'transmission',
  title: 'THE LAST TRANSMISSION',
  tagline: 'A VOICE ON THE SAFEHOUSE RADIO KEEPS SAYING THE ONE THING YOU’D NEVER BELIEVE.',
  difficulty: 'MODERATE',
  destinationKm: 10.0,
  recommendedLevel: 3,
  intro: [
    'The safehouse receiver has been muttering to itself for three nights. Static, mostly. Then, around four in the morning, a human voice rises out of it like something surfacing for air.',
    '#...if anyone can hear this... please. Tell them we made it.',
    '#We made it to the surface.',
    'Then the static folds back over it, and the loop starts again. You’ve done the maths on the signal strength. It’s coming from somewhere past the Glassed Basin, ten kilometres out, give or take a crater.',
    'You’re fairly certain nobody has said “made it to the surface” in a reassuring way since the bombs fell. You’re also fairly certain you won’t sleep until you know who’s saying it.',
  ],
  reward: const Reward(scrap: 230, xp: 150, stims: 2, picks: 1, parts: 2),
  endings: {
    'answered': const Ending('answered', 'MESSAGE RECEIVED',
        'You answered her. The loop stopped. She said it was that easy, and then she cried for a while.',
        bonus: Reward(scrap: 40, xp: 30), world: ['transmission.silent']),
    'kept': const Ending('kept', 'KEEP THE LIGHT ON',
        'You repaired the transmitter. The tape runs on, with a new line in it that points to your door.',
        bonus: Reward(parts: 3, stims: 1), world: ['transmission.beacon']),
    'truth': const Ending('truth', 'THE TRUE ACCOUNT',
        'You recorded the truth over the lie. For the first time in forty-one years, the tape ended differently.',
        bonus: Reward(xp: 60, picks: 2), world: ['transmission.truth']),
    'silenced': const Ending('silenced', 'DEAD AIR',
        'You pulled the plug. She said it was the one thing she never tried.',
        bonus: Reward(scrap: 90), world: ['transmission.silent']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? [
          'You pack the receiver at the top of your bag with its speaker turned up and its antenna poking out like a dowsing rod. The signal is south and east. It’s patient. You aren’t.',
        ]
      : [
          'The receiver crackles as you step out, as if it had been waiting. “...tell them...” it says, and you could swear it’s a little closer than before.',
        ],
  ambient: [
    Ambient('#...if anyone can hear this... (static) ...we made it... (static)', maxKm: 3.5),
    Ambient('The receiver in your pack coughs up half a sentence and swallows it again.', maxKm: 6),
    Ambient('You count the gap between repeats. Forty-one seconds, every time. You’ve started breathing in time with it.', minKm: 0.5),
    Ambient('Another repeater, its red light blinking on a pole. Whoever tends these has a ladder, a car battery and a great deal of faith.', minKm: 1.4, maxKm: 9.5, when: (c) => c.done('repeater')),
    Ambient('~The words change. Not much. A word here, a word there. A recording doesn’t decide to say “we” instead of “I”.', minKm: 3.2, when: (c) => c.flag('notes_changes')),
    Ambient('~Relay 9. You turn the name over in your mouth like a coin that might be fake.', minKm: 3.2, when: (c) => c.flag('relay9')),
    Ambient('#...you are... not... (static) ...alone... (static)', minKm: 5.2),
    Ambient('~You hope the girl’s cough has eased. You hope someone is still listening to her breathe.', minKm: 5.2, when: (c) => c.flag('helped_wen')),
    Ambient('The signal thickens in the glass. The ground itself seems to hum with it, faintly, like a wet finger on a glass rim.', minKm: 6.2, maxKm: 9),
    Ambient('~Whoever she is, that voice is a person. A person who has spent forty years editing a lie.', minKm: 7.5, when: (c) => c.done('dish')),
    Ambient('#...three nights now... (static) ...it’s all right... I’m patient... I’ve had the practice...', minKm: 9, when: (c) => c.done('yard')),
    Ambient('You catch yourself reading the static like a terminal screen, hunting for the pattern. There is one. It’s very, very patient.', minKm: 2, when: (c) => c.skill('HACKING') >= 2),
    Ambient('~You wonder if Contentment has a radio, and what the signal would sound like through that water.', minKm: 4, when: (c) => c.ending('caravan') != null),
    Ambient('~If this is the end, you’d like it to at least have decent reception.', when: (c) => c.lowHp),
  ],
  checkpoints: [
    // ---------------------------------------------------------------- 1.2
    Checkpoint.auto(
      id: 'repeater',
      title: 'THE REPEATER',
      km: 1.2,
      text: (c) => [
        'At the foot of a leaning power pole, someone has nailed a radio repeater to the wood. It is a crime against electronics: a car battery, a bicycle bell, a tangle of wire in three different colours and what appears to be a spoon.',
        'The receiver in your pack pops, and the voice comes through louder. Clearer. Whoever built this was not content to let the signal die on the way.',
        'A card is taped to the pole, in neat, careful capitals. KEEP IT WARM. — W.',
        'You look up the road. A second pole stands far off with a small red light on it. And a third beyond that. Somebody has been walking this highway with a ladder and a car battery, building a staircase out of sound.',
        '~Someone is going to a lot of trouble to be heard.|',
        '~Or to be answered.',
      ],
      flags: ['repeaters'],
      journal: say([
        'A chain of crude repeaters leads down the road, built by someone who signs “W.” The signal is being deliberately carried.'
      ]),
      reward: const Reward(xp: 10),
    ),
    // ---------------------------------------------------------------- 3.0
    Checkpoint(
      id: 'dentist',
      title: 'THE WAITING ROOM',
      km: 3.0,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 20),
      journal: (c) => [
        'A dentist’s office with a radio tuned to the signal, two seconds out of step with yours.',
        if (c.flag('notes_changes')) 'A patient waited out the end of the world in the chair, taking notes: the message changes.',
        if (c.flag('relay9')) 'The name on the files: Voss, M. Relay 9.',
        if (c.flag('drill')) 'The appointments show she recorded a drill tape, and asked to change the last line.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The sign over the door reads PAINLESS DENTISTRY. Someone has crossed out “PAINLESS” and written “MOSTLY” above it, in what you sincerely hope is marker.',
            'Inside: a waiting room, a fish tank full of nothing, a rack of magazines about a world that cared about kitchens, and a radio on the reception desk, tuned to your signal.',
            'Same voice. Same message. But it’s two seconds behind the one in your pack. You stand and listen to them overlap. “We made it... we made it... to the surface... to the surface.” It sounds like a choir that doesn’t like each other.',
            'Through the doorway behind the desk, you can see the dentist’s chair. It’s occupied.',
          ]),
          _dentistChoices(),
        ),
        Scene.talk(
          'hub',
          say(['The two radios finish a loop and begin again, out of step, like a long-married couple.']),
          _dentistChoices(),
        ),
        Scene.talk(
          'chair',
          say([
            'The patient is long past needing anaesthetic. Headphones are still on the skull, the cable running to the reception radio. The jaw hangs open the way jaws do in dentists’ chairs. Somebody sat down to wait out a procedure, and the procedure carried on without them.',
            '~Forty years in a waiting room. You’ve been to some bad appointments, but this takes the biscuit.',
            'A notebook is tucked into the armrest, its pages ruled in careful tally marks. The last page reads, in a trembling hand:',
            '#IT REPEATS EVERY 41 SECONDS. IT DOES NOT REPEAT EXACTLY. THE WORDS CHANGE. TODAY IT SAID “WE” INSTEAD OF “I”. I THINK SOMEONE IS EDITING IT.',
            '#I THINK SOMEONE IS STILL THERE.',
          ]),
          [
            Choice('[KEEP LOOKING]', 'hub'),
            Choice('[LEAVE]', 'leave'),
          ],
          flags: ['seen.chair', 'notes_changes'],
          reward: const Reward(parts: 1, xp: 6),
        ),
        Scene.talk(
          'desk',
          say([
            'The reception desk holds: a bowl of mints (no), a stack of appointment cards, and a drawer of identical pens bearing a phone number with seven digits and no dial tone.',
            'Tucked under the blotter is an index card: CIVIL DEFENCE CONTRACTORS, Q3 CLEANINGS, COMPLIMENTARY. Underneath, in smaller type: RELAY 9 — OPERATORS & STAFF.',
            '~A free cleaning for the people who ran the radio. You doubt they used it.',
          ]),
          [
            Choice('[KEEP LOOKING]', 'hub'),
            Choice('[LEAVE]', 'leave'),
          ],
          flags: ['seen.desk', 'relay9'],
          reward: const Reward(scrap: 12),
        ),
        Scene.hack(
          'hackt',
          say(['An old appointment terminal sits beside the till, its cursor still blinking on a screen that never expected company.']),
          win: 'appt',
          fail: 'appt_no',
        ),
        Scene.talk(
          'appt',
          say([
            '#APPOINTMENTS — FINAL WEEK OF OPERATION',
            '#09:00 SMITH, T. — CANCELLED (SIRENS)',
            '#10:30 OKAFOR, B. — CANCELLED (SIRENS)',
            '#11:15 VOSS, M. (RELAY 9) — “BRING HEADSET. ASKED WHETHER SHE CAN CHANGE THE LAST LINE OF THE DRILL TAPE. REFUSED.”',
            '#12:00 CLOSED FOR LUNCH — NEVER REOPENED',
            'You read the Voss line twice. Not a patient. A recording session, fitted in on a lunch break, because that is how the end of the world gets scheduled: between a cleaning and a filling.',
            '~She wanted to change the last line. They said no. You wonder what she wanted it to say.',
          ]),
          [
            Choice('[KEEP LOOKING]', 'hub'),
            Choice('[LEAVE]', 'leave'),
          ],
          flags: ['seen.terminal', 'relay9', 'drill'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'appt_no',
          say([
            'The terminal flashes ACCESS RESTRICTED and a cheerful reminder to floss. You have made no progress against the dental profession.',
          ]),
          [
            Choice('[KEEP LOOKING]', 'hub'),
            Choice('[LEAVE]', 'leave'),
          ],
          flags: ['seen.terminal'],
        ),
        Scene.end(
          'leave',
          say([
            'You step back into the daylight. Behind you, the two radios go on arguing softly about the surface.',
            '~You have a name now, or half of one. It’s more than you came in with.',
          ]),
        ),
      ],
    ),
    // ---------------------------------------------------------------- 5.0
    Checkpoint(
      id: 'pilgrim',
      title: 'THE LISTENERS',
      km: 5.0,
      art: 'drifter',
      start: 'a',
      reward: const Reward(xp: 25, scrap: 15),
      journal: (c) => [
        'A camp of twelve “Listeners” who gather nightly around a battered speaker. Their leader, Brother Alder, writes down every change in the message.',
        if (c.flag('logbook'))
          'His logbook: Year 1, “I made it.” Year 9, “we.” Year 14, a new sentence: “You are not alone.” Year 20: “Keep walking.”',
        if (c.flag('helped_wen')) 'You gave Wen a stimpack. Her breathing eased.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'A ring of salvaged chairs sits around a car-battery speaker in a clearing off the road. Twelve people, from a toothless old man to a child of perhaps nine, sit in total silence with their eyes shut.',
            'The speaker says, “...tell them we made it...” and they all breathe out together, as if they’d been holding it for the last forty seconds.',
            'A tall man in a patched greatcoat rises and opens his arms. “Brother Alder,” he says. “Welcome to the Listening. Do be quiet. It’s about to change.”',
            '“It speaks to us,” he murmurs. “Every night, the same words. But not the same, you see. They shift. A syllable here, a breath there. We keep a book.”',
            '“It’s a god,” says the old man, comfortably. “Obviously.”',
            '“It is a voice,” corrects Alder, with the tired patience of someone who has corrected this a lot. “Which is rarer.”',
            'In the corner, a small girl coughs, a wet, ragged sound. Her mother rubs her back with a hand that has done it too many times.',
            '~Twelve people, sitting in a field, listening to a lie on a loop. You can’t decide whether it’s the saddest thing you’ve ever seen or the most hopeful. It might be both.',
          ]),
          _pilgrimChoices(),
        ),
        Scene.talk(
          'stim',
          say([
            'You kneel and press the stimpack into the girl’s arm. She doesn’t cry. She looks at you with enormous eyes and says, “Are you from the radio?”',
            '“No,” you say.',
            '“That’s okay,” she says. “You’re nice, too.”',
            'Her breathing eases. Her mother weeps without a sound. Alder stands very still, then crosses to a bag and brings out a battered green logbook, holding it in both hands.',
            '“Our Wen,” he says. “Thank you. Read this. I’ve never let anyone read it. It’s every change the voice has ever made.”',
            'You open it. A column of years, in a careful hand:',
            '#YEAR 1: “I MADE IT TO THE SURFACE.”  YEAR 9: “WE MADE IT.”  YEAR 14: “YOU ARE NOT ALONE.” (NEW SENTENCE. NOBODY KNOWS WHY.)  YEAR 20: “KEEP WALKING.”',
            '~“We”. Then “you are not alone”. Then “keep walking”. That tape isn’t looping. It’s learning to talk.',
          ]),
          [
            Choice('[LEAVE THE LISTENERS]', 'leave'),
          ],
          flags: ['logbook', 'helped_wen', 'seen.ask'],
          reward: const Reward(xp: 25),
        ),
        Scene.talk(
          'recording',
          say([
            '“It’s a recording,” you say. “Tape. A loop. Somebody pressed play before you were born.”',
            'A hush. Twelve people open twelve pairs of eyes and look at you the way you look at a man who has insulted your mother.',
            '“Of course it’s a recording,” says Alder, evenly. “Do you think we are fools? But a recording does not change.”',
            'He fetches a green logbook from a canvas bag and thrusts it into your hands. A column of years in a careful hand:',
            '#YEAR 1: “I MADE IT TO THE SURFACE.”  YEAR 9: “WE MADE IT.”  YEAR 14: “YOU ARE NOT ALONE.” (NEW SENTENCE. NOBODY KNOWS WHY.)  YEAR 20: “KEEP WALKING.”',
            '“Explain that,” he says. You can’t. You hand the book back with more care than you took it.',
            '~A recording doesn’t change. That’s the first thing anyone’s said that makes you afraid, and not for the reason you’d expect.',
          ]),
          [
            Choice('[LEAVE THE LISTENERS]', 'leave'),
          ],
          flags: ['logbook', 'argued', 'seen.ask'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'listen',
          say([
            'You sit. Nobody says a word. The speaker crackles, the voice begins, and you listen as if it mattered.',
            'It is astonishing how quickly a person can find themselves holding their breath for forty-one seconds at a time. Around you, twelve people breathe with you.',
            'Afterwards, Alder passes you a battered green logbook without a word. A column of years in a careful hand:',
            '#YEAR 1: “I MADE IT TO THE SURFACE.”  YEAR 9: “WE MADE IT.”  YEAR 14: “YOU ARE NOT ALONE.” (NEW SENTENCE. NOBODY KNOWS WHY.)  YEAR 20: “KEEP WALKING.”',
            '“You listened,” he says, as if that were a rare skill. “Nobody listens, you know. They hear. It isn’t the same.”',
            '~“You are not alone.” You glance at the circle of chairs. You’re not so sure it’s a lie.',
          ]),
          [
            Choice('[LEAVE THE LISTENERS]', 'leave'),
          ],
          flags: ['logbook', 'listened', 'seen.ask'],
          reward: const Reward(xp: 20),
        ),
        Scene.end(
          'leave',
          (c) => [
            'Alder walks you to the edge of the clearing. “Keep walking,” he says. “That’s what it says to us. We stay, because somebody must. But you’re the kind who walks.”',
            'He points down the road. “The Basin crossing. There’s a dish, an old one. It is guarded. I don’t know by what. The voice gets louder there, as if it’s coming up out of the ground.”',
            if (!c.flag('logbook'))
              'You glance back at the green book in his coat pocket. You didn’t ask to read it, and he didn’t offer. Whatever it says, it’s theirs.',
          ],
        ),
      ],
    ),
    // ---------------------------------------------------------------- 7.4
    Checkpoint(
      id: 'dish',
      title: 'THE BASIN DISH',
      km: 7.4,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 35),
      journal: (c) => [
        'A relay dish in the Basin, guarded by a rusted sentry. In a maintenance locker: Marguerite Voss’s personal log, and the truth behind “we made it”.',
        'The all-clear went out at 06:14 by mistake, while the sirens were still going. It was a drill tape in her voice. There is no override.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'A relay dish stands on the glass like a great metal ear, tilted toward the south. The voice on your receiver is nearly loud enough to hear without it.',
            'At the dish’s base: a squat concrete hut, a maintenance locker bolted to its wall, and a rusted sentry, standing perfectly still, its red light blinking at the rhythm of the loop. Forty-one seconds. It’s keeping time.',
            '~It’s not guarding the dish. It’s listening to it.',
            'It doesn’t move. It will, though, when you cross the line of broken glass.',
          ]),
          _dishChoices(),
        ),
        Scene.hack(
          'hacks',
          say(['A maintenance port glows on the sentry’s flank. You edge into range, one slow step at a time.']),
          win: 'tamed',
          fail: 'back',
        ),
        Scene.talk(
          'tamed',
          say([
            'The sentry’s light goes from red to amber to a patient, ashamed green. It folds down onto its haunches like a dog told off for something it can’t remember doing.',
            '“MAINTENANCE MODE,” it says, in a voice like a very tired lift. “HAVE A SAFE DAY.”',
            '~Forty years of standing guard. It’s probably the first time it’s been asked nicely.',
          ]),
          [Choice('[OPEN THE LOCKER]', 'box')],
        ),
        Scene.fight(
          'fights',
          say(['You step over the line of broken glass. The sentry’s head swings around with a sound like a rusty gate.']),
          EnemyType.sentry,
          win: 'box',
          fail: 'back',
        ),
        Scene.talk(
          'sneak',
          say([
            'You go in low over the glass, on your belly, a long way round the sentry’s blind spot. It takes a long time. It takes some skin.',
            'The sentry’s light sweeps the dish above you and doesn’t find you. It’s keeping time with a voice you can hear in your teeth.',
          ]),
          [Choice('[OPEN THE LOCKER]', 'box')],
          reward: const Reward(hp: -6, xp: 10),
        ),
        Scene.talk(
          'back',
          say([
            'You withdraw behind a slab of glass and catch your breath. The sentry settles back into its post and its rhythm, as if nothing had happened.',
          ]),
          _dishChoices(),
        ),
        Scene.lock(
          'box',
          say(['The maintenance locker is bolted shut and the paint on its lock has been scratched by a very small, very old key.']),
          win: 'tape',
          fail: 'tape_pry',
        ),
        Scene.talk(
          'tape_pry',
          say([
            'The lock beats you. You put the pipe through the hinge instead, and the locker screams open, taking a corner off whatever was inside.',
          ]),
          [Choice('[PLAY WHAT SURVIVES]', 'tape', flags: ['damaged'])],
        ),
        Scene.end(
          'tape',
          (c) => [
            'Inside: a dented tape recorder, a spool of ribbon, and a cardboard label in pen. PERSONAL LOG — M. VOSS. DO NOT BROADCAST.',
            if (c.flag('damaged')) 'The tape is scratched and warped, but the ribbon plays, in places.',
            'You press the key. A woman’s voice, much younger, unsteady, intimate.',
            '#DAY ONE. THE ALL-CLEAR WENT OUT AT 06:14. THE SIRENS WERE STILL GOING.',
            '#IT’S MY VOICE ON THE TAPE. IT’S MY VOICE TELLING THEM IT’S SAFE TO COME OUT.|',
            '#I CAN’T STOP IT. THERE’S NO OVERRIDE. THE ENGINEERS DIDN’T WANT ANYONE TO BE ABLE TO STOP AN ALL-CLEAR BY ACCIDENT.',
            'A pause. A dry little laugh, like paper tearing.',
            '#...ENGINEERS.',
            'The tape runs on for a moment: the whisper of a room with nobody in it. Then it stops.',
            '~Forty years she’s been broadcasting that. Listening to it. Living in the middle of it.|',
            '~Nobody should have to hear their own voice say “we made it” for that long.',
          ],
          flags: ['voss_log'],
        ),
      ],
    ),
    // ---------------------------------------------------------------- 9.0
    Checkpoint.auto(
      id: 'yard',
      title: 'THE DROWNED YARD',
      km: 9.0,
      text: (c) => [
        'The transmitter yard lies in a shallow lake of black water. Antennas stand in it like reeds, hundreds of them, in rows, each with a tiny red light on top that blinks in unison.',
        'The water is not still. It shivers, faintly, in a rhythm you recognise. Forty-one seconds. Even the lake is keeping time.',
        'The receiver in your pack goes quiet. A hiss, a click, and then, for the first time, the voice isn’t on the loop.',
        '#...hello? Is someone there?',
        '#You’ve been listening three nights. Three nights, and you’ve never replied. That’s all right. I’m patient. I’ve had the practice.|',
        'Then the loop closes over it, and the old message returns, smooth as a lid.',
        '~It heard you. Not you, exactly. A receiver, whispering at four in the morning. Somebody has been listening to you for three nights.',
        if (c.flag('voss_log')) 'You think of the dry little laugh on the tape, and walk a little faster.',
      ],
      flags: ['addressed'],
      journal: say([
        'A drowned yard of antennas. For the first time the voice stopped looping and spoke to you: “You’ve been listening three nights.”'
      ]),
      reward: const Reward(xp: 20),
    ),
    // --------------------------------------------------------------- 10.0
    Checkpoint(
      id: 'relay',
      title: 'RELAY STATION 9',
      km: 10.0,
      art: 'signal',
      start: 'a',
      reward: const Reward(xp: 40),
      journal: (c) => [
        'Relay Station 9. Marguerite Voss, the last operator, and a very old grey cat named Static.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Relay Station 9 squats on a rise above the flooded yard, a long concrete bunker topped by a mast so tall the clouds have to go around it.',
            'The door is a steel slab. A small panel beside it is lit, and above it somebody has scratched a line of tally marks that goes right round the frame and onto the wall.',
            'On the step: a saucer of milk, long since dry. The saucer has been washed.',
            '~Someone lives here. Someone who washes saucers.',
          ]),
          [
            Choice('[KNOCK]', 'knock'),
            Choice('[PICK THE DOOR LOCK]', 'picklock'),
            Choice('[HACK THE ENTRY PANEL]', 'hackp'),
          ],
        ),
        Scene.talk(
          'knock',
          say([
            'You knock. Three raps, polite, the way someone might who had been raised well and then spent a long time out in the wasteland forgetting it.',
            'A long pause. Then slow, unhurried footsteps. Many bolts, drawn one by one. The door opens a hand’s width.',
          ]),
          [Choice('[STEP INSIDE]', 'meet')],
          flags: ['knocked'],
        ),
        Scene.lock(
          'picklock',
          say(['The lock is old and expensive, and has not been opened by a stranger in a very long time.']),
          win: 'in_lock',
          fail: 'in_open',
        ),
        Scene.hack(
          'hackp',
          say(['The entry panel flickers to life, with a text prompt and a polite blinking cursor.']),
          win: 'in_hack',
          fail: 'in_open',
        ),
        Scene.talk(
          'in_lock',
          say([
            'The lock gives with a heavy clunk, and you push the door open. The corridor smells of dust, tea and warm electronics.',
          ]),
          [Choice('[STEP INSIDE]', 'meet')],
          flags: ['broke_in'],
        ),
        Scene.talk(
          'in_hack',
          say([
            'The panel considers you, thinks better of arguing, and clicks open. A line of green text scrolls past: WELCOME, VISITOR. IT HAS BEEN A WHILE.',
          ]),
          [Choice('[STEP INSIDE]', 'meet')],
          flags: ['broke_in'],
        ),
        Scene.talk(
          'in_open',
          say([
            'The door beats you, and while you are glaring at it, it swings open on its own. A voice from the dark, mild and unimpressed: “You’re making an awful racket, you know.”',
          ]),
          [Choice('[STEP INSIDE]', 'meet')],
        ),
        Scene.talk(
          'meet',
          (c) => [
            'Beyond the door stands a very old woman in a cardigan the colour of dishwater, holding a torch in one hand and a thermos in the other. Her eyes are clouded white. She aims the torch about a metre to the left of your face.',
            if (c.flag('knocked'))
              '“A knock,” she says. “Forty-one years, and the first thing I get is a knock. I’d forgotten manners existed.”'
            else if (c.flag('broke_in'))
              '“Well,” she says. “You got in. I’d have let you, you know. People think I’m paranoid. I’m only lonely.”'
            else
              '“Well,” she says. “That took you long enough.”',
            'A grey cat of enormous age winds around her ankles with no interest in you whatsoever. “That’s Static,” she says. “He’s eleven. He’s the youngest thing here.”',
            'She leads you through a corridor lined with tally marks, past a kitchen the size of a cupboard, into a long room full of humming racks, glowing valves and a single armchair worn to the shape of one person.',
            '“Marguerite Voss. Evening operator. The tape you’ve been hearing is mine.” A small, dry laugh. “It was a drill. Four-C: post-attack reassurance. The committee wrote the script. I read it. They liked the last line best. ‘We made it to the surface.’ I asked if I could change it. They said no.”',
            '“It went out at 06:14 on the day, by accident. One bit flipped, in a cabinet, in a city that isn’t there any more. The sirens were still going, and my voice told every shelter on the continent that it was safe to come out.”',
            '“There’s no override. The engineers didn’t want anyone stopping an all-clear by accident.” The laugh again. “Engineers.”',
            if (c.flag('logbook'))
              '“Alder’s been writing down my changes, hasn’t he? Good man. Terrible theology.”',
            '“So I did the only thing I could. I couldn’t stop it. I could only edit it. A word here, a word there. ‘I’ became ‘we’. I put in directions to the places still standing. In year fourteen, I finally got the line I wanted all along. ‘You are not alone.’”',
            '“The loop’s built to stop when it hears a reply on the return channel. In forty-one years, nobody has answered. Then three nights ago, a receiver somewhere south of the glass began whispering. Receivers do that. A set turned up too loud leaks a little whisper out of the back, and I’ve got ears like a bat and eighty valves. You’d be amazed what you can hear, with nothing else to listen to.”',
            'She turns her clouded eyes toward you, and for a second you feel completely seen.',
            '“Say something to me, then.”',
            '~Forty-one years of waiting for a reply. Whatever you say next, you’re going to have to live with it.',
          ],
          _meetChoices(),
        ),
        Scene.hack(
          'studio',
          say([
            '“Record it, then,” Voss says, and gestures at a console older than you are. “The studio’s through there. The tape runs on a lockout. You’ll have to break it to put something over the top.”',
            '“Say whatever you like. The truth, ideally. I’ve been a bit short of that lately.”',
          ]),
          win: 'end_truth',
          fail: 'studio_fail',
        ),
        Scene.talk(
          'studio_fail',
          say([
            'The console swallows your recording with a long, ugly electronic burp and gives you back static. Voss pats your arm. “It does that. It ate three years of my poetry.”',
          ]),
          [
            Choice('[KEY THE MIC AND ANSWER HER]', 'end_answered'),
            Choice('[HELP KEEP IT RUNNING] (-3 PARTS)', 'end_kept', needParts: 3),
            Choice('[PULL THE PLUG]', 'end_silenced'),
          ],
        ),
        Scene.end(
          'end_answered',
          (c) => [
            'You lean to the microphone. It’s ancient and warm and smells of someone else’s breath. You say, as clearly as you can, “Message received.”',
            'A relay clunks somewhere in the walls. A long, slow sigh goes through the machinery, as if forty-one years of held breath were being let go.',
            'The loop stops.',
            'The silence that follows is of a kind you didn’t know a room could make. The cat looks up. Voss stands very still. “Forty-one years,” she says. “And it was that easy.”',
            'She laughs. Then she isn’t laughing. You make tea. It is terrible tea, and you drink it anyway.',
            'On the walk home, the repeaters go dark behind you one after another, little red lights winking out, like someone counting down.',
            '~Somewhere back there, twelve people are sitting in a circle, waiting for a voice that won’t come. You hope Alder is as sensible as he’s tired.',
          ],
          ending: 'answered',
        ),
        Scene.end(
          'end_kept',
          (c) => [
            'You spend most of an afternoon on your back under a rack, passing her a spanner and swearing at a power cell older than your grandmother. She narrates the faults by sound. She is never wrong.',
            'When the lights steady and the valves glow, she lets out a breath. “That’ll do another decade.”',
            'She sits down at the console, thinks for a while, and records a new line over the old. You’re listening for it when it comes.',
            '#There’s a light on, south of the glass. The door’s not locked. Keep walking.',
            'You open your mouth. She raises a hand. “It’s a good door. Don’t spoil it.”',
            '~Your safehouse is now a lighthouse. You hope the door holds.',
            if (c.flag('helped_wen')) 'You think of the girl with the cough, and wonder if she’ll hear it, and walk, and knock.',
          ],
          ending: 'kept',
        ),
        Scene.end(
          'end_truth',
          (c) => [
            'You sit at the console. Voss sits beside you and tells you nothing: no script, no prompt. The red light comes on.',
            'You tell the truth. It’s bad up here. The water in the Basin is poison, and the water by the highway isn’t. The surface is dangerous, and strange, and occasionally, unexpectedly, kind. People are alive in it, in twos and twelves and forties, and none of them are quite sure how.',
            '#“We didn’t all make it,” you say. “But you’re not alone.”',
            'The tape runs. The machine drinks the words, and the loop that has run for forty-one years ends, on the last word, in a way it never has.',
            'It ends differently.',
            'Voss says nothing for a long time. Then: “That’s the one I wanted. All along.” She wipes her eyes with the back of her cardigan sleeve. “Thank you for making it true.”',
            '~Whoever hears it next will hear it honest. That’s worth more than any “made it” ever was.',
          ],
          ending: 'truth',
        ),
        Scene.end(
          'end_silenced',
          (c) => [
            'You find the main bus in the back of the racks. It’s a big, ugly lever, painted red, with a little brass plate: DO NOT. You put your hand on it and glance back.',
            'Voss has not moved. Her clouded eyes are on the wall, listening.',
            'You pull.',
            'The racks stop humming one at a time, like a choir leaving the stage. The light in the long room goes slowly from amber to grey. The last thing to die is a tiny green valve, in the corner, blinking its patient forty-one seconds, then not.',
            '“Oh,” says Voss, very quietly. “Well. That’s the one thing I never tried.”',
            'She doesn’t beg. She doesn’t curse. She presses a roll of scrap into your hand, without looking, as if handing over a receipt. “It’s all I have,” she says. “Go home. Don’t listen to the radio for a while.”',
            'On the road, you pass the repeaters. Each red light is dark. Back at the safehouse, the receiver will be silent now. It will feel like a held breath.',
            '~You did what she asked you to, in a way. You’re fairly sure it wasn’t what she meant.',
          ],
          ending: 'silenced',
        ),
      ],
    ),
  ],
);
