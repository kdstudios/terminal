import '../../combat_session.dart';
import '../../story_model.dart';
import '../story_kit.dart';

// THE GARYS
// An underground bunker full of identical men in blue jumpsuits. The only
// writing on any jumpsuit is the single word  gary  (lowercase, nothing else).
// No numbers, surnames or labels on clothes, ever. Every Gary is told apart
// ONLY by story state and by how the narration describes him:
//
//   KETTLE        friendly, hospitable, original (but not precious about it)
//   CLIPBOARD     believes he is the bunker manager
//   FILING        insists the manager is Gary (a different one, obviously)
//   CLERICAL      insists nobody is called Gary: it is a clerical error
//   SWEATING      begs you to identify him as the original
//   SUSPICIOUS    leads the Primes (the “original Garys”), keeps an evidence board
//   AGGRESSIVE    leads the Authentics (the “real Gary” faction), wants to hit things
//
// THE TRUTH (a joke the whole story is built toward): the Annex was never a
// duplication project. It was a records-backup facility; a night clerk leaned
// on the archive duplicator to fetch a stapler. The machine copied his
// personnel file, handwriting and all, and has produced one more “gary” every
// eleven days since. The real Gary went home at five o’clock. The experiment
// (“Do identical employees form factions?”) has been confirming itself for
// forty years.
//
// World facts left behind: garys.community / leader / war / purpose / escaped /
// shutdown / companion (see endings). Gary bunker ≠ Gary of Gary’s Problem.

List<Choice> _roomChoices() => [
      Choice('[TALK TO THE GARY WITH THE KETTLE]', 'k', show: (c) => !c.flag('seen.k')),
      Choice('[TALK TO THE GARY WITH THE CLIPBOARD]', 'c', show: (c) => !c.flag('seen.c')),
      Choice('[TALK TO THE SWEATING GARY]', 'p', show: (c) => !c.flag('seen.p')),
      Choice('[LEAVE THE ROOM]', 'leave'),
    ];

List<Choice> _factionChoices() => [
      Choice('[TALK TO THE PRIMES]', 'primes', show: (c) => !c.flag('seen.primes')),
      Choice('[TALK TO THE AUTHENTICS]', 'auth', show: (c) => !c.flag('seen.auth')),
      Choice('[TALK TO THE CLERICAL GARY]', 'clerical', show: (c) => !c.flag('seen.clerical')),
      Choice('[BROKER A PEACE]', 'broker'),
    ];

final StoryDef garysStory = StoryDef(
  id: 'garys',
  title: 'THE GARYS',
  tagline: 'THEY ARE ALL THE ORIGINAL. THEY ARE ALL WEARING THE SAME THING. THEY ALL SAY SO.',
  difficulty: 'MODERATE',
  destinationKm: 8.0,
  recommendedLevel: 3,
  intro: [
    'The trader who tells you about the hatch is a very quiet man, and he tells it in a very quiet voice. “It’s past the three dead pylons,” he says. “Round the back of an old rail embankment. A square steel hatch, in the ground, with a sign.”',
    '“What does the sign say?”',
    '“It says: HOLLOW COUNTY CONTINUITY ANNEX. And then someone has written, underneath, in biro: WE ARE ALL VERY SORRY ABOUT THE NOISE.”',
    'You ask about the noise. He looks away. “It’s mostly,” he says, in the voice of a man describing a dream, “shouting. In a very specific, very reasonable-sounding voice. You’ll see.”',
  ],
  reward: const Reward(scrap: 200, xp: 130, stims: 1, picks: 1, parts: 1),
  endings: {
    'community': const Ending('community', 'THE GARY COMMUNITY',
        'The Garys stopped arguing about who was first and started arguing about what to do next, which is the only argument worth having. They built a settlement with thirty-one shifts, thirty-one opinions, and one agreed rule: nobody is the original. It is, against all odds, working.',
        bonus: Reward(xp: 60, scrap: 40), world: ['garys.community']),
    'leader': const Ending('leader', 'SUPERVISOR GARY',
        'You helped one Gary into the manager’s chair and he has not left it since. He wears a tie over his jumpsuit. The other Garys salute with the wrong hand. It is not a good system. It is, somehow, a stable one.',
        bonus: Reward(scrap: 70), world: ['garys.leader']),
    'war': const Ending('war', 'THE GARY CIVIL WAR',
        'It began with a vote and ended with a corridor barricaded with filing cabinets. The Primes hold the east wing and the Authentics hold the west. There are rules of engagement. They are mostly about the kettle. Nobody has been hurt, but it is only a matter of time.',
        bonus: Reward(xp: 40, parts: 1), world: ['garys.war']),
    'purpose': const Ending('purpose', 'THE RESULT',
        'You read the results aloud. For a long moment, thirty-one identical men stared at the floor. Then one of them began to laugh, and then all of them did, and when they stopped, they were somehow a different crowd. Having been told they were an experiment about arguing, they decided to prove it wrong. They have not entirely managed.',
        bonus: Reward(xp: 90, picks: 1), world: ['garys.purpose']),
    'escaped': const Ending('escaped', 'THE GREAT GARY EXODUS',
        'You opened the blast doors and thirty-one Garys went up the stairs into a wasteland none of them had seen. They stood in the daylight, blinking, in perfect, silent, blue-jumpsuited rows. Then one said, “I think the east is original,” and the rest of them followed him, bickering, toward the horizon.',
        bonus: Reward(scrap: 50, xp: 30), world: ['garys.escaped']),
    'shutdown': const Ending('shutdown', 'LIGHTS OUT',
        'The machine whined down and the lights went out. In the dark, thirty-one men said, together and in the same voice, “Well, that’s that, then.” The bunker is quiet. Most of the Garys have gone to live in a nearby ruin. Nobody has ever been sure which of them said it first.',
        bonus: Reward(scrap: 90), world: ['garys.shutdown']),
    'companion': const Ending('companion', 'A VERY CONFUSED GARY',
        'You walked out with one Gary at your shoulder, blinking at the sky and holding your sleeve. He asks about every third thing you pass. He has already named a rock. He has no idea who he is, and he has decided, on the whole, that that’s all right.',
        bonus: Reward(xp: 50, stims: 1), world: ['garys.companion']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? [
          'You find the three dead pylons and count them twice, just in case.',
          '~Thirty-something men. All named the same. This is either the best day of your life or a very long argument.',
        ]
      : [
          'You return to the rail embankment. A faint noise comes up through the ground: many voices, all calm, all certain, all slightly out of time with one another.',
        ],
  ambient: [
    Ambient('A faded sign beside the track: HOLLOW COUNTY — A PLACE TO COME HOME TO. Someone has added, in biro: (IF YOU ARE GARY).', maxKm: 3),
    Ambient('A buried air vent breathes dust at your ankles. Somewhere beneath it, a very reasonable voice says, “I was FIRST.”', maxKm: 3),
    Ambient('A blue jumpsuit lies on a hedge in the wind, empty. Its chest says one word in marker: gary. It says nothing else. You do not touch it.', maxKm: 4),
    Ambient('You find a boot print in the dust. Then another exactly like it. Then a third. They all point at the hatch.', maxKm: 3.5),
    Ambient('You pass a tin of spaghetti hoops with the label scratched off and a single word scratched in: gary.', minKm: 1.5, maxKm: 5),
    Ambient('From the vent, faintly: “...if that were true, Gary, you would be in the OTHER room.” “THERE IS ONLY ONE ROOM.”', minKm: 2),
    Ambient('~Every Gary has the same face. It is a strange thing to look for in a crowd and not find.', minKm: 3, when: (c) => c.done('room')),
    Ambient('You’re beginning to talk in the cadence of a man who’s sure he’s right. You make a point of stopping.', minKm: 4, when: (c) => c.done('factions')),
    Ambient('Distant clanging: somebody, somewhere, is dragging a filing cabinet across a corridor.', minKm: 5, when: (c) => c.flag('chaos')),
    Ambient('The air tastes of toner and old carpet. You didn’t know that was a possible taste for a bunker.', minKm: 5),
    Ambient('~If none of them is the original, they are all equally the original. If all of them are, none is. The sentence has no good ending.', minKm: 6, when: (c) => c.flag('knows_original_left')),
    Ambient('#...ALL STAFF TO THE COMMON ROOM. THIS IS NOT A DRILL. (THIS HAS BEEN SAID BEFORE.)', minKm: 6.5),
    Ambient('You catch yourself checking your own clothes for a name tag. There isn’t one. Obviously. You check again.', minKm: 7),
  ],
  checkpoints: [
    // ---------------------------------------------------------------- 1.4
    Checkpoint.auto(
      id: 'hatch',
      title: 'THE HATCH',
      km: 1.4,
      text: (c) => [
        'The three pylons stand like a row of bad teeth. Behind the rail embankment, half-buried in grass, is a square steel hatch the size of a door. A hand-painted sign is bolted to it: HOLLOW COUNTY CONTINUITY ANNEX. AUTHORISED STAFF ONLY. Under it, a newer sign: STAFF WELCOME. TOURS BY APPOINTMENT. NO APPOINTMENTS HAVE BEEN MADE.',
        'You lean down and put your ear to the steel. Through it comes the sound of a crowd of men, deep underground, shouting at each other in the calm, patient tone of the absolutely certain.',
        '“I am the ORIGINAL Gary.”',
        '“No, I am the original Gary.”',
        '“I am AWARE you think so, Gary.”',
        'You straighten up very slowly. You have the unmistakable feeling of having been at the start of a long afternoon.',
        '~Several men, all named Gary. All claiming to be the original. This is either a very good joke or a very bad bunker.|',
      ],
      journal: say([
        'A bunker beneath the old rail line, marked HOLLOW COUNTY CONTINUITY ANNEX. From inside, a great many men are arguing about which of them is the original Gary.',
      ]),
      reward: const Reward(xp: 10),
    ),
    // ---------------------------------------------------------------- 2.6
    Checkpoint(
      id: 'room',
      title: 'THE COMMON ROOM',
      km: 2.6,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 25),
      journal: (c) => [
        'The Common Room of the Annex holds dozens of near-identical men in blue jumpsuits, each stencilled with one word: gary. They are all the original.',
        if (c.flag('seen.k')) 'The Gary with the kettle offered me tea and admitted he was “probably” the original but was not precious about it.',
        if (c.flag('seen.c')) 'The Gary with the clipboard claims to be the bunker manager, and has a very official clipboard to prove it.',
        if (c.flag('seen.p')) 'A sweating Gary begged me to identify him as the original. They all answered the same question in the same voice.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The hatch opens onto a ladder, the ladder onto a corridor, and the corridor onto a long, low, strip-lit hall with a lino floor and a smell of hot kettle. It is the common room of a bunker built for fifty and occupied by what look like thirty-one very well-organised men.',
            'They are all wearing the same blue jumpsuit. On the chest of each, in black marker, in a careful lowercase hand, is a single word: gary. There is nothing else. No names, no numbers, no ranks. Just gary, thirty-one times, in thirty-one near-identical hands.',
            'They are all the same height. They have the same nose. They have the same slightly worried eyebrows. They are also, all of them, arguing.',
            '“I was here FIRST.” “I was here before you were here.” “That is logically impossible, Gary.” “It is NOT.” A man in the middle of the room has climbed onto a chair to be heard. Nobody is listening to him. They’re all on chairs.',
            'And then, one by one, thirty-one heads turn and look at you.',
            '“Hello,” says the nearest Gary, a man with a kettle in each hand. “I’m the original Gary. These are the impostors. Would you like some tea?”',
          ]),
          _roomChoices(),
        ),
        Scene.talk(
          'k',
          say([
            'The Gary with the kettle gives you a cup of tea so strong that the spoon refuses to fall over. He has kind, apologetic eyes and a little tuft of hair that won’t lie flat.',
            '“I’m the original,” he says, “though I’m not precious about it. I remember it very clearly. I was in the Annex, at the Records Platform, I leaned over to pick up my stapler, and there was a flash. That was the beginning of me.”',
            '“And the others?”',
            '“All say the same thing!” he cries, happily. “To the letter! It’s extraordinary. Of course, they’re wrong. But I don’t mind. It’s nice to have company.”',
            'He pours you a second cup without being asked. It is, you realise, the best tea you have ever had. He appears to have made it for forty years.',
            '~He’s the only one who sounds like he could stand to lose the argument. Which, ironically, makes you want to give it to him.',
          ]),
          _roomChoices(),
          flags: ['seen.k', 'kettle_friend'],
          reward: const Reward(hp: 8),
        ),
        Scene.talk(
          'c',
          say([
            'The Gary with the clipboard marches up and offers you a hand like a salute. His jumpsuit is exactly the same as the others’, with nothing on it but the one lowercase word. The word MANAGER is written on his clipboard instead, in biro, underlined twice.',
            '“Gary,” he says. “Bunker manager. Don’t believe what the others tell you. I’ve held this post since the beginning. I have a clipboard.”',
            '“What’s on it?”',
            'He looks at the clipboard as if for the first time. “Procedures,” he says, with great confidence. “They’re... mostly my own.” He flips a page. The page is blank. He flips another. “Ah. You’ve caught me in a transitional phase.”',
            'Across the room, another Gary calls out, “THE MANAGER IS GARY.” “I AM GARY,” shouts the clipboard Gary. “THE MANAGER IS A DIFFERENT GARY.” “THERE’S ONLY ONE GARY.” “THAT’S MY POINT.”',
          ]),
          _roomChoices(),
          flags: ['seen.c', 'clip_met'],
        ),
        Scene.talk(
          'p',
          say([
            'A sweating Gary has been hovering at your elbow for some time. His jumpsuit is damp. His hands are clasped. He steps in front of you, his chin trembling.',
            '“Please,” he whispers. “Look at me. Look at me carefully. I’m the original. I know I am. But no one believes me, and I can’t prove it, and I thought, you’re a stranger, you’re new, you can’t be biased. Could you just... pick? Say it’s me?”',
            '“Which one are you?”',
            '“I’m this one!” he says, and gestures at himself, and in the same moment, three other Garys step up beside him in perfect lines and say, “I’m this one,” in perfect unison, and point at themselves.',
            'The sweating Gary looks at the others. He looks at you. “It’s getting harder,” he says, in a small voice, “to feel like me.”',
          ]),
          [
            Choice('[PICK HIM, KINDLY]', 'p_pick'),
            Choice('[ASK A QUESTION ONLY THE ORIGINAL KNOWS]', 'p_quiz'),
            skillChoice('SURVIVAL', 1, 'STUDY THEM CLOSELY', 'p_study'),
            Choice('[REFUSE: “I CAN’T TELL.”]', 'p_refuse'),
          ],
          flags: ['seen.p'],
        ),
        Scene.talk(
          'p_pick',
          say([
            '“It’s you,” you say, and put a hand on his shoulder. “You’re the original.”',
            'He bursts into tears. It’s the loveliest sound in the room. A moment later thirty other Garys gasp, with the exact same intake of breath, and the room erupts.',
            '“IMPOSSIBLE.” “HE’S BEEN CRYING SINCE TUESDAY.” “I’VE ALSO BEEN CRYING SINCE TUESDAY, BUT I’M NOT CLAIMING A TITLE.”',
            'Your new friend hugs you very hard. He smells of tea and starch. You’ve picked a side. You’re not sure you’ve picked a side you can leave.',
          ]),
          _roomChoices(),
          flags: ['identified_plea', 'chaos'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'p_quiz',
          say([
            '“What’s your mother’s maiden name?” you ask the sweating Gary.',
            '“ALDERBURY,” he says, instantly.',
            '“ALDERBURY,” say the other thirty, in a perfect, bell-like unison that rattles the cutlery.',
            'There is a long pause.',
            '“I said it first,” says the sweating Gary.',
            '“You did not.” “You were fractionally behind.” “That’s a very serious accusation, Gary.”',
            'You try three more: first pet (a goose), favourite biscuit (a custard cream), the colour of the thing he lost in 1994 (it was a hat, and it was beige). All thirty-one answers are identical to the syllable. They’re all, you realise, telling the truth.',
            '~They don’t just remember being the same man. They remember being him. Every one of them is certain he is the only one who was.',
          ]),
          _roomChoices(),
          flags: ['same_memories', 'chaos'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'p_study',
          say([
            'You don’t look at what they say. You look at what they are. And slowly, the sameness comes apart into details: one has a thin scar through his left eyebrow, one has glasses mended with tape, one is ever so slightly shorter, and one has the faint, thin look of someone who has not been eating.',
            'But the details are tiny. They’re wear and tear, not birth. They’re all, down to the age of the skin, exactly the same age. Same lines at the corners of the eyes. Same grey at the temples. Whatever made them, it made them at the same moment.',
            '~They’re not brothers. They’re not twins. They’re one man, made thirty-one times, the same day. Or something like a day.',
            '“Well?” says the sweating Gary, hopefully.',
            '“You’re all exactly the same age,” you tell him.',
            '“That’s what I’ve been SAYING,” says the sweating Gary, to the room, in great triumph, which doesn’t help him at all.',
          ]),
          _roomChoices(),
          flags: ['same_age', 'seen.study'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'p_refuse',
          say([
            '“I can’t tell,” you admit. “I’m sorry.”',
            'The sweating Gary’s face crumples. “No,” he says. “That’s all right. Nobody can.” He wipes his eyes on his sleeve, and you see the single word on his chest, wet, in black marker: gary. It’s smearing.',
            'Across the room, a hundred and sixty-five eyebrows rise. “Well, that’s fair,” says a voice. “That’s honestly the most honest thing anyone has said all week.”',
          ]),
          _roomChoices(),
          flags: ['refused_plea'],
        ),
        Scene.end(
          'leave',
          say([
            'You edge toward the far door. Behind you, the argument closes over where you were like water. “...and ANOTHER thing, Gary...”',
            'You hear them shouting your name, or something that sounds like it. A moment later you realise: they’ve all started calling you Gary. It’s just easier.',
            '~You’re not Gary. You’re definitely not Gary. But you’ve been called it four times, and you’re starting to reply.',
          ]),
        ),
      ],
    ),
    // ---------------------------------------------------------------- 4.2
    Checkpoint(
      id: 'factions',
      title: 'THE TWO WINGS',
      km: 4.2,
      art: 'gang',
      start: 'a',
      reward: const Reward(scrap: 25, xp: 30),
      journal: (c) => [
        'The Garys have split into rival factions: the Primes, led by a suspicious Gary with an evidence board, and the Authentics, led by a Gary who wants to hit things.',
        if (c.flag('side_primes')) 'I sided with the Primes. They gave me a sticker that said ORIGINAL. It was handwritten.',
        if (c.flag('side_auth')) 'I sided with the Authentics. They gave me a sticker that said REAL. It was also handwritten.',
        if (c.flag('peace_brokered')) 'I brokered a peace. It lasted for a whole afternoon. A record.',
        if (c.flag('label_clue')) 'The Clerical Gary says it is a clerical error. He may be right.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The two long wings of the bunker split at a junction, and the Garys have split with them. The east corridor is lined with benches, a tidy evidence board, and a banner made from a bedsheet reading ORIGINAL GARY. The west corridor has a banner that reads REAL GARY, and a pile of chairs stacked like a barricade.',
            'Between them is a no-man’s land of lino. A single Gary wanders it with a mug of tea, murmuring to himself, in no hurry at all.',
            '“We are the Primes,” a voice calls from the east. “The first Garys. The pure Garys.” “We are the Authentics,” calls another from the west. “The REAL Garys.” “There’s only one kind of Gary,” a third voice says, mildly, from the middle. “It says so on the suits.”',
          ]),
          _factionChoices(),
        ),
        Scene.talk(
          'hub',
          say(['The two wings glare at each other across the lino. The man in the middle sips his tea.']),
          _factionChoices(),
        ),
        Scene.talk(
          'primes',
          say([
            'The suspicious Gary has built an evidence board out of a fire door and about eleven kilometres of string. There are photographs of every other Gary, taken from behind, annotated in tiny handwriting: “SHIFTY.” “KNEW MY MOTHER’S NAME.” “SUSPICIOUSLY SIMILAR TO ME.”',
            '“They’re impostors,” he says, with the calm of a man who has said it more than ten thousand times. “I’ve proof. I’ve compiled it. They all have the same fingerprints.”',
            '“So do you.”',
            '“That’s because I’m the original,” he says, with unshakeable logic. “I’m the one they copied.”',
            'He taps the board. “Join us. Help us expose them. There are rewards. There are stickers.”',
          ]),
          [
            Choice('[JOIN THE PRIMES]', 'side_p'),
            Choice('[TELL HIM THE FINGERPRINT POINT]', 'primes_logic'),
            Choice('[BACK AWAY]', 'hub'),
          ],
          flags: ['seen.primes'],
        ),
        Scene.talk(
          'primes_logic',
          say([
            '“Hold on,” you say. “If you all have the same fingerprints, it doesn’t prove who’s copied. It proves you’re all the same.”',
            'He stares at you. His mouth opens. It closes. He looks at his evidence board, which is a very large evidence board. Something moves behind his eyes like a large animal in deep water.',
            '“...I’m going to need a minute,” he says, hoarsely, and sits down on a bench.',
          ]),
          [
            Choice('[JOIN THE PRIMES ANYWAY]', 'side_p'),
            Choice('[LET HIM THINK]', 'hub'),
          ],
          flags: ['primes_shaken'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'side_p',
          say([
            'He pins a sticker to your chest. It says ORIGINAL, in biro. It is, unmistakably, in the same handwriting as the word gary on his jumpsuit. He pats it flat with enormous ceremony.',
            'In the west corridor, thirty heads swivel, and a deep, furious voice says, “TRAITOR.”',
          ]),
          [Choice('[CONTINUE]', 'hub')],
          flags: ['side_primes', 'chaos'],
        ),
        Scene.talk(
          'auth',
          say([
            'The aggressive Gary doesn’t so much meet you as arrive. He’s the only one with a nick on his chin and a bruise on his knuckle, and he keeps clenching his fist as if testing that it’s still his.',
            '“I’m the REAL Gary,” he says. “The others are copies. Cheap copies. Lighter. I’ve checked.” He pats his chest hard, where the word gary sits. “See how thick the marker is? Thick. Original. Theirs fade.”',
            '“Does yours fade?”',
            '“It does not,” he says, in a quiet, menacing voice, “because I re-do it every morning.”',
            'Behind him, a group of Garys stands in a rough semicircle, arms folded, looking tough. They are also very short on actual muscle.',
          ]),
          [
            Choice('[JOIN THE AUTHENTICS]', 'side_a'),
            Choice('[SQUARE UP TO HIM]', 'auth_fight'),
            skillChoice('COMBAT', 1, 'STARE HIM DOWN', 'auth_stare'),
            Choice('[BACK AWAY]', 'hub'),
          ],
          flags: ['seen.auth'],
        ),
        Scene.talk(
          'side_a',
          say([
            'He slaps a sticker on your jacket. REAL. In biro. It takes two goes, and he apologises to the sticker.',
            'From the east wing, a thin voice calls out, “THEY’VE GOT ONE.” “SO HAVE WE.” “WE HAD ONE FIRST.” “YOU DID NOT.”',
          ]),
          [Choice('[CONTINUE]', 'hub')],
          flags: ['side_auth', 'chaos'],
        ),
        Scene.talk(
          'auth_stare',
          say([
            'You stand very straight and look him in the eyes. You don’t say anything. You let the silence do it.',
            'It takes eleven seconds. The aggressive Gary breaks first. “Ah,” he says, looking at the floor. “You’re... tall. In a way.” He mumbles something about respect, and lowers his fist.',
            'He is a lot less frightening when he is not trying to be. His shoulders drop, just a little. “It’s just,” he says, “I’ve got to be the real one. If I’m not, I’m not anyone.”',
            '~He isn’t a bully. He’s a man who’s very frightened of being a copy.',
          ]),
          [
            Choice('[JOIN THE AUTHENTICS]', 'side_a'),
            Choice('[TELL HIM HE’S ENOUGH]', 'auth_kind'),
          ],
          flags: ['auth_calmed'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'auth_kind',
          say([
            '“You don’t have to be the real one,” you say. “You’re here. You’re yourself. That’s plenty.”',
            'He looks at you with deep suspicion, which in this room is how a Gary looks at a kindness. “Did the Primes put you up to this?” he mutters. Then, quieter: “...Thanks.”',
          ]),
          [Choice('[CONTINUE]', 'hub')],
          flags: ['auth_kind'],
        ),
        Scene.fight(
          'auth_fight',
          say([
            'You step up, and he swings. It’s a wild, enthusiastic, deeply unprofessional punch. He’s plainly never done this before. He’s also clearly been practising on a wall.',
            'Three Authentics rush in behind him with chairs.',
          ]),
          EnemyType.straggler,
          win: 'auth_won',
          fail: 'auth_lost',
        ),
        Scene.talk(
          'auth_won',
          say([
            'The aggressive Gary sits on the lino, holding a bloody lip and looking up at you with a startled kind of respect. “That,” he says, thickly, “was very real.”',
            'The Authentics put down their chairs. For the first time, someone has hit them, and they didn’t come out of it a hero. They look like boys.',
          ]),
          [Choice('[CONTINUE]', 'hub')],
          flags: ['auth_beaten', 'violence'],
        ),
        Scene.talk(
          'auth_lost',
          say([
            'You’re shoved back against the lino. The aggressive Gary, delighted and horrified, helps you up. “Sorry,” he says. “I didn’t think I’d actually hit you. Do you want a sticker?”',
          ]),
          [
            Choice('[TAKE THE STICKER]', 'side_a'),
            Choice('[BACK OFF]', 'hub'),
          ],
        ),
        Scene.talk(
          'clerical',
          say([
            'The Gary in the middle is the only one not shouting. He’s lean, polite, and slightly rumpled, like a man reading from a script he doesn’t quite trust. He raises his mug at you.',
            '“Don’t mind them,” he says. “There’s been a clerical error.”',
            '“What kind of error?”',
            '“Nobody is called Gary,” he says. “Look at us. Lowercase. Written in marker. That isn’t a name. That’s a label. You wouldn’t call a man ‘jumpsuit.’ Someone, somewhere, wrote ‘gary’ on a form, and the form came true.” He sips his tea. “They’ve all taken it personally. I find it’s better not to.”',
            'He smiles at you, like a man at the back of a very long meeting. “So no, I’m not Gary. No one is. We’re just... very efficiently labelled.”',
            '~It’s the most sensible thing you’ve heard all day. It is also, somehow, the most frightening.',
          ]),
          _factionChoices(),
          flags: ['seen.clerical', 'label_clue'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'broker',
          (c) => [
            'You walk into the no-man’s land and raise both hands. Both wings fall quiet in a great, rustling hush.',
            if (c.flag('kettle_friend'))
              '“I’d like to propose a truce,” you say. And, from the middle of the lino, the Gary with the kettle (your Gary, the one who makes the tea) calls out, “I second it! Gary! Gary and Gary! I’m not precious about it. Please come and have some tea.”'
            else
              '“I’d like to propose a truce,” you say. “A short one.” The words go out into the corridor and fall flat. Nobody trusts you. You’re not one of them, and one of them is exactly what they all need.',
            if (c.flag('kettle_friend'))
              'There’s a long, tense silence. Then someone sniffs. Then someone puts down a chair. The aggressive Gary says, “...Is it the good tea?” and the suspicious Gary says, “It’s the good tea,” and by degrees, the whole bunker starts shuffling toward the kettle.'
            else
              'A chair flies across the lino. A hiss of “impostor” goes up from the east and a hum of “copy” from the west. Within moments there is a scuffle by the water cooler and a Gary is wearing a bin.',
          ],
          [
            Choice('[CONTINUE]', 'peace', show: (c) => c.flag('kettle_friend')),
            Choice('[CONTINUE]', 'brawl', show: (c) => !c.flag('kettle_friend')),
          ],
        ),
        Scene.talk(
          'peace',
          say([
            'It lasts the whole afternoon. It is an actual, genuine peace, held over mugs of tea. Thirty-one men sit around a long table and, for once, nobody is the original, and nobody says so.',
            'The aggressive Gary and the suspicious Gary shake hands. They hold on slightly too long, as if checking for a difference. They don’t find one. They look, together, at the same wall, and neither of them speaks.',
            '“It’s odd,” the suspicious Gary says at last. “I thought I’d feel like I lost.”',
            '“So did I,” says the aggressive Gary. “It’s quite nice.”',
          ]),
          [Choice('[LEAVE THEM TO IT]', 'end_f')],
          flags: ['peace_brokered'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'brawl',
          say([
            'You’re barely out of the way before the shouting becomes shoving, and the shoving becomes the sound of thirty men trying to hit someone who looks exactly like them. It’s oddly polite. Everyone keeps apologising.',
            'You leave via the vents. In the distance, you can hear the whole bunker settling into a very long, very organised grudge.',
          ]),
          [Choice('[CONTINUE]', 'end_f')],
          flags: ['chaos', 'brawl'],
        ),
        Scene.end(
          'end_f',
          say([
            'You leave the wings behind you. The argument continues in two directions at once, like a river at a fork.',
            '~There is a door at the end of the corridor with a brass plate: MANAGER. It is, without question, the most contested piece of metal in the building.',
          ]),
        ),
      ],
    ),
    // ---------------------------------------------------------------- 5.8
    Checkpoint(
      id: 'office',
      title: 'THE MANAGER’S OFFICE',
      km: 5.8,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 25, xp: 35),
      journal: (c) => [
        'The manager’s office held the facility’s real records. The Annex was never a duplication project: it was a backup archive, and a clerk named Gary leaned on the wrong machine.',
        if (c.flag('knows_original_left')) 'The original Gary went home at five. He was never in the bunker at all.',
        if (c.flag('knows_purpose')) 'The study has been confirming itself for forty years: identical staff form factions.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The Manager’s Office is a heavy steel door in a corridor of heavy steel doors. Two Garys are fighting over it, in the manner of two people who have fought over it for so long that it has become a kind of marriage.',
            '“I am the manager,” says the Gary with the clipboard. “I have the clipboard.”',
            '“The manager is GARY,” says another Gary, a mild man with a filing cabinet drawer under his arm. “I am not him. I am merely Gary. He is the manager. He is, in fact, Gary.”',
            '“I’m Gary,” says the clipboard Gary. “THEN YOU’RE NOT HIM,” says the filing Gary, delighted. They look at you. “Tell him,” says one. “Tell HIM,” says the other.',
            'The door has a keypad. Beside it is a lock the size of a fist.',
          ]),
          [
            Choice('[HACK THE KEYPAD]', 'ohack'),
            Choice('[PICK THE LOCK]', 'olock'),
            Choice('[LET THEM ARGUE IT OUT]', 'oarg'),
          ],
        ),
        Scene.talk(
          'oarg',
          say([
            'You stand back and let it run. It takes eleven minutes. It involves a pointing hand, a drawer, a stapler thrown at a wall, and a speech about “procedural legitimacy” that makes the room go silent for about a second.',
            'In the end, the two Garys turn to you. “So,” says the clipboard Gary. “Who’s right?”',
            'You look at the door. It is, as far as you can tell, unlocked. It has been unlocked the whole time. Neither of them has ever touched the handle.',
          ]),
          [Choice('[TURN THE HANDLE]', 'inside')],
          flags: ['door_unlocked'],
        ),
        Scene.hack(
          'ohack',
          say(['You lean on the keypad. It looks at you the way an old, patient dog looks at a thief.']),
          win: 'inside',
          fail: 'ofail',
        ),
        Scene.lock(
          'olock',
          say(['The lock is stiff. It has clearly been oiled by someone who didn’t know what oil was for.']),
          win: 'inside',
          fail: 'ofail',
        ),
        Scene.talk(
          'ofail',
          say([
            'The keypad squeals. From a speaker in the ceiling, a calm recorded voice announces: “ALL STAFF TO THE COMMON ROOM. THIS IS NOT A DRILL.”',
            'There is a sound like a very large cupboard being kicked. Down the corridors, thirty-one men, all convinced that the announcement is meant for them, start to run.',
            '“SOMEONE’S BREAKING INTO THE OFFICE!” “IT’S THE IMPOSTORS!” “IT’S THE ORIGINAL!” “IT’S GARY!” The clipboard Gary and the filing Gary look at each other with open horror. Then, together: “Quick. In.”',
          ]),
          [Choice('[DIVE THROUGH THE DOOR]', 'inside')],
          flags: ['chaos', 'alarm'],
        ),
        Scene.talk(
          'inside',
          (c) => [
            'The office is a little room with a green desk, a dead plant and a bank of old equipment. On the wall is a framed poster: A WORKFORCE IS A WORKFORCE IS A WORKFORCE. Beside it is a filing cabinet that hums.',
            'On the desk sits a terminal, a clear glass paperweight, and a small folder labelled: CONTINUITY STUDY — PRIVATE. The folder has a sticky note: DO NOT SHOW THE STAFF. (THEY WILL NOT UNDERSTAND.)',
            if (c.flag('alarm')) 'Outside, a stampede of blue jumpsuits shakes the corridor. You have a minute, maybe two.',
          ],
          [
            Choice('[OPEN THE FOLDER]', 'folder'),
            skillChoice('HACKING', 1, 'READ THE TERMINAL ARCHIVE', 'archive'),
            skillChoice('ENGINEERING', 1, 'EXAMINE THE FILING CABINET', 'cabinet'),
            Choice('[LEAVE IT ALONE]', 'o_out'),
          ],
        ),
        Scene.talk(
          'folder',
          say([
            'The folder holds a single typed page and a photograph. The photograph is of a tired, smiling man in a blue jumpsuit. On his chest, in marker, in a careful hand, is the word gary. He’s holding a stapler.',
            'The page reads: SUBJECT: GARY (CLERK, 3RD CLASS). EMPLOYEE FILE REF. 4471. DUPLICATION EVENT: ACCIDENTAL. CAUSE: SUBJECT LEANED ON RECORDS PLATFORM DURING ARCHIVE BACKUP TO RETRIEVE STAPLER. SUBJECT’S PERSONNEL FILE, INCLUDING HANDWRITING, WAS REPLICATED.',
            'A last line has been added in different ink: SUBJECT WENT HOME AT 17:00. PLEASE DISREGARD ANY SUBJECT PRESENT.',
            '~He wasn’t even there. He was never there. He went home, and the machine made the rest.',
          ]),
          [
            Choice('[KEEP READING]', 'archive', show: (c) => c.skill('HACKING') >= 1),
            Choice('[LEAVE]', 'o_out'),
          ],
          flags: ['knows_original_left', 'seen.folder'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'archive',
          say([
            'The terminal wakes with a long, polite chime. There are forty years of logs. You skip to the summary.',
            '#CONTINUITY STUDY — OBJECTIVE: DETERMINE WHETHER A WORKFORCE OF IDENTICAL EMPLOYEES, EACH CONVINCED OF ITS OWN PRIMACY, WILL FORM FACTIONS.',
            '#STATUS: ONGOING. HYPOTHESIS: CONFIRMED. HYPOTHESIS: CONFIRMED. HYPOTHESIS: CONFIRMED.',
            '#NOTE: THE DUPLICATOR WAS NOT DESIGNED TO PRODUCE STAFF. IT WAS DESIGNED TO BACK UP RECORDS. THE STUDY WAS RETROFITTED TO EXPLAIN THE INVOICE.',
            '#OUTPUT: ONE (1) NEW STAFF MEMBER EVERY ELEVEN DAYS UNTIL TERMINATED. NEXT STAFF MEMBER DUE IN: 00:11:00.',
            'It is simply, perfectly clear. The whole thing was a clerical error. Somebody realised and, instead of fixing it, wrote a study.',
            '~They’ve been a case study for forty years. They’re the best-run experiment in the history of the world, and no one is left to read it.',
          ]),
          [Choice('[CONTINUE]', 'o_out')],
          flags: ['knows_purpose', 'knows_original_left', 'seen.archive'],
          reward: const Reward(xp: 25),
        ),
        Scene.talk(
          'cabinet',
          say([
            'You open the humming cabinet. It isn’t full of files. It is full of small blue lamps, a copper coil and a tiny printed plaque: PERSONNEL FILE REPLICATOR (BACKUP). DO NOT FEED THE MACHINE.',
            'It has a second plaque, smaller, and much newer: OUR APOLOGIES FOR THE GARY SITUATION.',
            'You close the cabinet very gently. It sighs.',
          ]),
          [Choice('[CONTINUE]', 'o_out')],
          flags: ['knows_machine'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'o_out',
          (c) => [
            'You step back into the corridor just as the first of the stampede arrives. The clipboard Gary and the filing Gary rush up, panting, with the tragic expressions of men who have both been cheated out of a moment.',
            '“Well?” says the clipboard Gary. “What did you find?”',
            if (c.flag('knows_original_left'))
              'You could tell them. You could tell them everything: the stapler, the file, the man who went home at five. You could tell either of them anything. Neither of them is the manager. Neither of them is not.',
          ],
          [
            Choice('[TELL THE CLIPBOARD GARY HE’S IN CHARGE]', 'told_clip', flags: ['told_clip']),
            Choice('[TELL THE FILING GARY HE’S RIGHT]', 'told_filing', flags: ['told_filing']),
            Choice('[“NOTHING. IT’S JUST AN OFFICE.”]', 'told_none'),
          ],
        ),
        Scene.end(
          'told_clip',
          say([
            'The clipboard Gary stands very straight. His whole body fills like a tent. “Thank you,” he says, and writes something on the clipboard, a thing that wasn’t there a minute ago. The filing Gary looks at the floor. “Alright,” he says, softly. “But I’m still Gary.”',
            'Somewhere in the building, a kettle whistles. The sound has become a kind of national anthem.',
          ]),
        ),
        Scene.end(
          'told_filing',
          say([
            'The filing Gary beams. “I KNEW IT.” The clipboard Gary makes a sound like a deflating tyre. “That’s not even logical,” he says, but he’s already smiling a little, at the sheer neatness of being wrong.',
            'The two Garys stand together in the corridor for a moment, equal and opposite. Then they go off to argue about something else.',
          ]),
        ),
        Scene.end(
          'told_none',
          say([
            '“Nothing,” you say. “It’s just an office.”',
            'Both of them look suspicious. Both of them peer past you into the room. A silence passes, and then they both say, at once, “I’ll check,” and shoulder each other through the door.',
          ]),
        ),
      ],
    ),
    // ---------------------------------------------------------------- 8.0
    Checkpoint(
      id: 'machine',
      title: 'THE RECORDS PLATFORM',
      km: 8.0,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 35, xp: 50),
      journal: (c) => [
        'At the bottom of the Annex: the duplicator, the Records Platform, and eleven minutes until the next Gary. I had to decide what to do about all of them.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The Records Platform is a clean white room at the lowest level of the Annex. A glass booth stands in the middle, with a bench seat, a console and a steel plate on the floor. The console is lit. A countdown reads: 00:10:48.',
            'A second pod beside it holds something that looks like a jumpsuit with no one in it yet. Across the chest, in neat marker, a machine arm is carefully lettering one word: gary.',
            'You can hear them coming down the stairs. All of them. Thirty-one Garys, still arguing, in a long, noisy, blue-jumpsuited line, in an echo that sounds like the whole building clearing its throat.',
            if (c.flag('knows_purpose')) 'You know what the machine is. You know what the study says. You know that this is the exact moment that the study was designed to wait for.',
          ],
          [
            Choice('[READ THEM THE RESULTS]', 'results', show: (c) => c.flag('knows_purpose')),
            Choice('[CALL THEM TOGETHER]', 'summit'),
            Choice('[SABOTAGE THE MACHINE]', 'sab'),
            Choice('[TAKE ONE GARY AND LEAVE]', 'comp'),
          ],
        ),
        Scene.talk(
          'results',
          say([
            'You step onto the Records Platform and clear your throat. They all go quiet. Not because of you; because of the acoustics. Thirty-one hands go up in a perfect forest of “Excuse me.”',
            'You read aloud. The hypothesis. The study. The word “retrofitted.” The sentence about the invoice. You read the part about the original: He went home at five.',
            'It is very quiet. A drip, somewhere. The humming of the machine.',
            '“Oh,” says the Gary with the kettle, softly. “Oh, I see.”',
            '“It’s a CLERICAL ERROR,” says the Clerical Gary, in a strangled voice, and begins to laugh, and laughs until he has to sit down.',
          ]),
          [
            Choice('[LET THEM LAUGH, THEN SPEAK]', 'end_purpose'),
            Choice('[NO. STOP. TALK TO THEM INSTEAD]', 'summit'),
          ],
          reward: const Reward(xp: 20),
        ),
        Scene.talk(
          'summit',
          (c) => [
            'You raise your hands and they gather. Thirty-one men with one face, filling the room, sweating, expectant, all of them sure that they are the one you will look at.',
            if (c.flag('side_primes') || c.flag('side_auth'))
              'The two wings line up on either side. They’ve spent a long time hating each other, and the lines they’ve drawn are visible on the lino. Everyone’s waiting for you to say something that will make it all worth it.'
            else
              'Without sides to take, they’ve gathered in a messy circle. The suspicious Gary is clutching his evidence board. The aggressive Gary is standing as far from him as the room allows.',
            if (c.flag('told_clip')) 'The clipboard Gary has already written GARY across the top of his clipboard. In biro. In capitals.',
          ],
          [
            Choice('[PROPOSE A VOTE]', 'vote'),
            Choice('[BACK THE CLIPBOARD GARY]', 'end_leader', show: (c) => c.flag('told_clip')),
            Choice('[SHOW THEM THE EXIT]', 'end_escape'),
            Choice('[“THE ORIGINAL ISN’T HERE.”]', 'rumour'),
          ],
        ),
        Scene.talk(
          'vote',
          (c) => [
            'You propose a vote. Thirty-one Garys draw breath. It is, in retrospect, the single most dangerous thing you have ever said in a confined space.',
            if (c.flag('peace_brokered'))
              'But the truce holds. The tea has been drunk. They agree, with a great deal of grumbling, on a single resolution: THAT NO GARY IS THE ORIGINAL, AND ALL GARYS ARE EQUAL, AND THE KETTLE IS COMMUNAL.'
            else
              'The motion is “Who is the original?” It is carried by thirty-one votes to thirty-one, each Gary having voted for himself. A recount is demanded. A second recount reveals that Gary has voted twice.',
          ],
          [
            Choice('[LET THEM WRITE IT DOWN]', 'end_community', show: (c) => c.flag('peace_brokered')),
            Choice('[DUCK]', 'end_war', show: (c) => !c.flag('peace_brokered')),
          ],
        ),
        Scene.talk(
          'rumour',
          say([
            '“The original,” you say, “isn’t here. He went home at five.”',
            'The room goes quiet. Then every Gary turns, very slowly, to look at the Gary next to him. And a voice says, quite softly, “That’s exactly what an impostor would say.”',
            'It’s awful. It’s instant. In seconds, the whole room is accusing everybody else of being the one who knew.',
          ]),
          [
            Choice('[WATCH IT HAPPEN]', 'end_war'),
            Choice('[SHOW THEM THE EXIT]', 'end_escape'),
          ],
          flags: ['rumour'],
        ),
        Scene.talk(
          'sab',
          say([
            'You walk to the console. The countdown reads 00:07:15. The pod is already filling with a low, sweet, vanilla-coloured light.',
            'There’s a master lever on the wall. It’s labelled, in handwriting you recognise: EMERGENCY SHUTDOWN (DO NOT USE: SEE GARY).',
          ]),
          [
            Choice('[HACK THE CONSOLE]', 'sabhack'),
            Choice('[PULL THE LEVER]', 'end_shutdown'),
            Choice('[OPEN THE BLAST DOORS INSTEAD]', 'end_escape'),
          ],
        ),
        Scene.hack(
          'sabhack',
          say(['The console accepts your login with a long, soft, apologetic beep.']),
          win: 'sabwin',
          fail: 'sabfail',
        ),
        Scene.talk(
          'sabwin',
          say([
            '#SHUTDOWN SEQUENCE ACCEPTED. DUPLICATOR WILL CEASE PRODUCTION. THANK YOU FOR YOUR SERVICE. THANK YOU. THANK YOU. THANK YOU.',
            'The pod goes dark. The new jumpsuit unthreads itself and drops, empty, to the floor with the word gary half-finished on the chest. It says: gar',
            'The Garys filing in are quiet, watching the machine die. “Oh,” whispers the Gary with the kettle. “It’s... finished.”',
          ]),
          [Choice('[CONTINUE]', 'end_shutdown')],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'sabfail',
          say([
            'The console squeals. The pod flashes. Three more jumpsuits roll out of the chute in a rush, each lettered gary, each unoccupied, each wrong in a slightly different way.',
            'The countdown reads 00:00:11. Then 00:00:10. A final jumpsuit drops, and it, alone, has been lettered in a hand you recognise as your own.',
          ]),
          [
            Choice('[PULL THE EMERGENCY LEVER]', 'end_shutdown'),
            Choice('[OPEN THE BLAST DOORS]', 'end_escape'),
          ],
          flags: ['chaos'],
          reward: const Reward(hp: -5),
        ),
        Scene.talk(
          'comp',
          (c) => [
            'You turn to leave. And a hand tugs at your sleeve. It’s the sweating Gary, the one who asked you to name him. He’s clutching a small bag, and he looks like a man who has never been asked to go anywhere.',
            '“I don’t want to be the original,” he says. “I just want to see what’s up there. Will you take me?”',
            if (c.flag('identified_plea')) 'You told him he was the original. He remembers. He’s holding on to that, like a hand-rail in a long dark corridor.',
            if (c.flag('refused_plea')) 'You told him you couldn’t tell. He remembers that too. He says it was the kindest thing anyone’s ever said to him.',
          ],
          [
            Choice('[SAY YOU CAN’T]', 'a'),
            Choice('[TAKE HIM WITH YOU]', 'end_companion'),
          ],
        ),
        Scene.end(
          'end_community',
          say([
            'They draw up the resolution on the back of a laundry list and sign it thirty-one times. Each signature says gary. They look at it for a long time.',
            'It is not a happy ending, exactly. It’s a working one. They hold their first meeting that same night. It’s about the kettle. It takes four hours and everyone ends up friends.',
            'They invent shifts, and a rota, and a tradition of saying “I’m not the original, I’m just Gary” at every meal. The bunker, under their care, becomes the strangest, most orderly settlement in the wasteland.',
            '~You came down to solve a mystery. You’re leaving having helped found a country.',
          ]),
          ending: 'community',
        ),
        Scene.end(
          'end_leader',
          say([
            'You put a hand on the clipboard Gary’s shoulder. “This is your manager,” you tell the room. “I think we should let him do it.”',
            'It’s a bad idea. It’s the simplest bad idea there’s ever been. The clipboard Gary takes a long, slow, thankful breath. “I’m going to be so good at this,” he says, and then, for a moment, he looks terrified.',
            'He gives the first order within five minutes: all Garys to start wearing a tie. A few of them do. By the end of the week it’s thirty.',
            '~A stable regime. A tie-based one. You’re choosing to leave before you’re given a lanyard.',
          ]),
          ending: 'leader',
        ),
        Scene.end(
          'end_war',
          (c) => [
            'It’s a very small war. The first casualty is a custard cream. The second is a chair. By midnight there’s a barricade of filing cabinets across the main corridor and a handwritten treaty tacked to a door that nobody has signed.',
            'The Primes hold the east wing. The Authentics hold the west. A single Gary, the clerical one, shuttles between them with a tray of tea, murmuring, “It’s a clerical error. It’s all a clerical error.”',
            'You leave by the ladder with your coat over your head. Behind you, a voice calls: “WHO STARTED IT?” and thirty voices answer, in unison, “THE OTHER GARY.”',
            if (c.flag('rumour')) '~You really should have kept that rumour to yourself.',
          ],
          ending: 'war',
        ),
        Scene.end(
          'end_purpose',
          say([
            'They don’t cheer. They just stay in the room for a long, long time, thirty-one men with one face, looking at the countdown. When it hits zero, the pod opens, and the thirty-second Gary rises out of it, blinking. He looks at them, and they look at him. And the Gary with the kettle steps forward and gives him a cup of tea.',
            '“We’ve been a case study,” the new Gary says, slowly. “That’s why we’ve all been so unhappy. We’ve been an experiment about arguing.”',
            '“Yes,” says the kettle Gary.',
            '“Let’s be bad data,” says the new Gary. And thirty-two Garys raise their mugs.',
            '~You’ve given forty years of results a punchline. It’s the least you could do.',
          ]),
          ending: 'purpose',
        ),
        Scene.end(
          'end_escape',
          say([
            'You throw the blast doors open and daylight comes down the stairs like a rumour. Thirty-one Garys stare at it with their mouths open. One of them whispers, “Is that the sky?”',
            'They go up in a long blue line, like a very quiet parade, shielding their eyes. At the top they stand in the sunlit dust, blinking at the world. It is huge, and brown, and totally unlabelled.',
            'The Gary with the kettle takes your hand. “Thank you,” he says. “Will you tell us where to go?” You point east. “I think east is original,” says the suspicious Gary, firmly. “WEST,” says the aggressive one.',
            'They both set off, together, in a perfect, bickering line.',
          ]),
          ending: 'escaped',
        ),
        Scene.end(
          'end_shutdown',
          say([
            'The lever comes down with a long, final thunk. The pod’s light goes out. The vanilla glow drains away, the hum drops, and the whole bunker falls into a profound and echoing quiet.',
            'Then, down the corridors, thirty-one men say, quite softly and together, “Well. That’s that, then.” It’s the first time in forty years they’ve all said the same thing at the same moment, and none of them is angry.',
            'You leave them the emergency lights and the kettle. When you look back from the hatch, they’re sitting in a circle on the lino, saying nothing, with their hands round their mugs.',
            '~Not a happy ending. Not a sad one. A tidy one. They would’ve liked that.',
          ]),
          ending: 'shutdown',
        ),
        Scene.end(
          'end_companion',
          (c) => [
            'You take him up the ladder one rung at a time. He holds the rungs as if each might be a trick. At the top, he steps out into the afternoon and stands there, mouth open, for a very long time.',
            '“It’s so big,” he whispers. “And there’s no ceiling.”',
            'You walk away across the dust with a blue-jumpsuited man at your shoulder, asking about every third thing you pass. By the time you reach the pylons, he’s named a rock. By the time you reach the road, he has asked, quite seriously, whether you’d mind if he kept the name Gary after all. “It’s all I’ve got,” he says. “It’s lowercase. But it’s mine.”',
            if (c.flag('identified_plea')) '~You told him he was the original. You still don’t know if you were lying.',
          ],
          ending: 'companion',
          flags: ['carry.garys.companion_kind'],
        ),
      ],
    ),
  ],
);
