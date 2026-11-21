import '../../combat_session.dart';
import '../../story_model.dart';
import '../characters/brother_positive.dart';
import '../story_kit.dart';

// THE CHURCH OF THE ETERNAL BATTERY
// A settlement called The Holy Circuit worships a car battery. Its leader,
// Brother Positive, believes it holds the last spark of humanity. The battery
// is wired to an old emergency broadcast system whose automated announcements
// accidentally became scripture. Dave, who is suspiciously ordinary, started it.
//
// Everything you may want to edit lives in this file:
//   checkpoints: sign (auto) -> gate -> sermon -> reliquary -> altar (finale)
//   flags you can read elsewhere: faith, doubt, dave_talked, dave_admitted
//   endings: enlightened, prophet, disconnection, holywar, eternal
//   world facts left behind: battery.* and carry.dave.admitted (see BrotherPositive)

List<Choice> _gateChoices() => [
      Choice('[ASK ABOUT THE BATTERY]', 'g_battery', show: (c) => !c.flag('seen.g_battery')),
      Choice('[ASK LITTLE FUSE]', 'g_fuse', show: (c) => !c.flag('seen.g_fuse')),
      Choice('[LOOK AT THE MAN CALLED DAVE]', 'g_dave', show: (c) => !c.flag('seen.g_dave')),
      Choice('[GO IN]', 'g_in'),
    ];

List<Choice> _sermonChoices() => [
      Choice('[SPEAK TO REVEREND RESISTANCE]', 's_res', show: (c) => !c.flag('seen.s_res')),
      Choice('[LISTEN TO THE BROADCAST]', 's_cast', show: (c) => !c.flag('seen.s_cast')),
      Choice('[HAVE A WORD WITH BROTHER POSITIVE]', 's_pos', show: (c) => !c.flag('seen.s_pos')),
      Choice('[SLIP AWAY FROM THE SERMON]', 's_leave'),
    ];

final StoryDef churchStory = StoryDef(
  id: 'church',
  title: 'THE CHURCH OF THE ETERNAL BATTERY',
  tagline: 'THEY WORSHIP A CAR BATTERY. IT IS, AS FAR AS ANYONE CAN TELL, EXTREMELY LOYAL.',
  difficulty: 'MODERATE',
  destinationKm: 8.0,
  recommendedLevel: 2,
  intro: [
    'The rumour reaches your safehouse in the form of a leaflet pushed under the shutter. It is printed on the back of a dishwasher manual. It reads: YOU ARE LOVED. YOU ARE CONDUCTIVE. COME TO THE HOLY CIRCUIT. BRING SNACKS.',
    'It is signed Brother Positive, with a little drawing of a battery in a halo. The drawing is better than the rest of the leaflet. The battery looks confident.',
    'Traders say a settlement out past the Scrap Orchard worships a single car battery, and that it has done so peacefully for six years. Others say the battery talks. “Not in words,” one of them clarifies, “in announcements.”',
    'You have met a lot of religions out here. Most want your scrap. Some want your blood. This one wants you to bring snacks. You are, against your better judgement, curious.',
  ],
  reward: const Reward(scrap: 190, xp: 120, stims: 1, parts: 2),
  endings: {
    'enlightened': const Ending('enlightened', 'THE ENLIGHTENED',
        'You told them the truth, gently, and held their hands while they took it in. The Holy Circuit kept the hymns and dropped the lie. Nobody was more surprised than Brother Positive that he could be a good priest with no miracle at all.',
        bonus: Reward(xp: 60, stims: 1), world: ['church.enlightened', 'battery.exposed']),
    'prophet': const Ending('prophet', 'THE NEW PROPHET',
        'You put on the robe of jump leads and let them call you Eminent Voltage. It fits worse than you expected and feels better than you’d like. The congregation hangs on your every word. You try very hard to say only sensible ones.',
        bonus: Reward(scrap: 80, xp: 30), world: ['church.prophet', 'battery.prophet']),
    'disconnection': const Ending('disconnection', 'THE GREAT DISCONNECTION',
        'The battery came out of the wall and the world went quiet. Somewhere a speaker coughed, and the voice of the old world finally stopped. They call it the Great Disconnection. It will be taught to children, with the part about you in it.',
        bonus: Reward(scrap: 120), world: ['church.disconnection', 'battery.stolen']),
    'holywar': const Ending('holywar', 'THE HOLY WAR',
        'There are two churches now, one with a battery and one with a grudge. It is a very small war, fought mostly with sermons and the occasional wheelbarrow. People have been hit with hymnals. A goose has taken a side.',
        bonus: Reward(scrap: 50, xp: 50, parts: 1), world: ['church.holywar', 'battery.war']),
    'eternal': const Ending('eternal', 'THE ETERNAL CIRCUIT',
        'You repaired the relay and the Battery hummed on, properly, for the first time in forty years. The announcements are real again now, and a little urgent. The congregation has started following them. Some of the instructions are surprisingly good advice.',
        bonus: Reward(parts: 3, xp: 40), world: ['church.eternal', 'battery.repaired']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? [
          'You pack snacks. You feel faintly ridiculous about it. You pack more snacks.',
          '~If anyone asks, you are going to the Holy Circuit for strategic reasons. The reasons are bring-and-share.',
        ]
      : [
          'You take the leaflet-lined road toward the Holy Circuit again. Somewhere ahead, a speaker crackles, clears its throat, and says nothing in particular, very reverently.',
        ],
  ambient: [
    Ambient('Another leaflet, nailed to a post: HAVE YOU TRIED TURNING YOURSELF OFF AND ON AGAIN? Beneath it, in different handwriting: YES. DID NOT HELP.', maxKm: 3),
    Ambient('A crow sits on a pylon, completely still, in what you can only describe as a worshipful posture.', maxKm: 4),
    Ambient('You pass a jam jar full of pennies with a note: FOR THE BATTERY. HE GETS COLD.', maxKm: 4),
    Ambient('Hymn fragment, carried on the wind, sung by a very small voice: “...and the Current shall carry us, and the Fuse shall keep us, and nobody shall touch the Terminals...”', minKm: 1, maxKm: 4),
    Ambient('Someone has painted a lightning bolt on a rock. Someone else has carefully painted over it with a smaller, politer lightning bolt.', minKm: 2, maxKm: 5),
    Ambient('#THIS IS A TEST. THIS IS ONLY A TEST. IF THIS HAD BEEN A REAL EMERGENCY, YOU WOULD HAVE BEEN TOLD WHERE TO GO. (STATIC)', minKm: 3),
    Ambient('You catch yourself saying “bless you” to a gust of wind. It seems to take it well.', minKm: 4.5, when: (c) => c.done('gate')),
    Ambient('Behind you, a man with a perfectly normal sandwich is walking exactly as far behind as is polite. Dave. You are sure it was Dave.', minKm: 4.5, maxKm: 7.4, when: (c) => c.done('gate')),
    Ambient('~A battery that’s been charged for forty years is either a miracle or a design flaw.', minKm: 5.5),
    Ambient('You pass a sign: RESIST. It looks recent. The R has been repainted in a fierce, angry red.', minKm: 4.5, when: (c) => c.flag('seen.s_res')),
    Ambient('A distant announcement rolls over the hills like a priest’s sneeze: “PLEASE REMAIN CALM. HELP IS ON ITS WAY. THIS IS NOT A DRILL. THIS IS A DRILL.”', minKm: 6),
    Ambient('~Whatever you do at the altar, the hum is going to follow you home. You can feel it in your fillings.', minKm: 7, when: (c) => c.done('reliquary')),
    Ambient('Brother Positive is, in memory, very sincere. You are starting to suspect that is the hardest thing in the wasteland to argue with.', minKm: 5, when: (c) => c.flag('seen.s_pos')),
  ],
  checkpoints: [
    // ---------------------------------------------------------------- 1.5
    Checkpoint.auto(
      id: 'sign',
      title: 'THE ROADSIDE SERMON',
      km: 1.5,
      text: (c) => [
        'A sign the size of a barn door stands beside the road. It says, in hand-lettered capitals: THE HOLY CIRCUIT — 6 KM. KEEP LEFT. KEEP CHARGED. And below, in smaller paint: PLEASE DO NOT SHORT-CIRCUIT YOURSELF. WE HAVE HAD ENOUGH OF THAT.',
        'A pilgrim is sitting at the base of the sign, quietly eating a sandwich. He has the look of someone who has been waiting for you, or for any customer. He nods, politely, and goes on chewing.',
        'You pass him. There is a faint hum in the air that you hadn’t noticed before, low and steady, like a very large cat pretending not to be.',
        '~You have never in your life been this close to something holy and this far from anything dangerous. It makes you nervous.|',
      ],
      journal: say([
        'A roadside sign promised The Holy Circuit, six kilometres on. A pilgrim eating a sandwich nodded as I passed. A faint hum underlies everything.',
      ]),
      reward: const Reward(xp: 10),
    ),
    // ---------------------------------------------------------------- 3.0
    Checkpoint(
      id: 'gate',
      title: 'THE HOLY CIRCUIT',
      km: 3.0,
      art: 'shrine',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 20),
      journal: (c) => [
        'The Holy Circuit: a ring of caravans around a patched-up substation, a speaker on a pole and a bell made of a fridge door.',
        if (c.flag('seen.g_fuse')) 'Little Fuse told me the Battery “just says BEEP, not anything else.”',
        if (c.flag('seen.g_dave')) 'There is a man called Dave. There is something wrong with how ordinary he is.',
        if (c.flag('socket_pass')) 'Sister Socket scanned me for static. I passed. I think.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The Holy Circuit is a ring of caravans parked around a squat electrical substation, bound together with orange extension cables and what looks like hope. A loudspeaker stands on a pole in the middle. A bell made from a fridge door hangs from a gantry. It is not rung. It is gently, reverently tapped.',
            'A woman in a rubber apron blocks the gate with a clipboard. A hand-embroidered badge on her chest reads SISTER SOCKET — GATEKEEPER. HEALTH & SAFETY OF THE SOUL.',
            '“Stop,” she says, not unkindly. “Hold out your arms. I am going to check you for static.”',
            'You hold out your arms. She waves a wand made of a hairbrush and a coat hanger. It makes a very serious noise.',
          ]),
          [
            Choice('[LET HER FINISH]', 'g_scan'),
            Choice('[JOKE ABOUT THE WAND]', 'g_joke'),
            Choice('[OFFER HER SNACKS]', 'g_snacks'),
          ],
        ),
        Scene.talk(
          'g_scan',
          say([
            'Sister Socket takes her time. She checks your sleeves, your hair, your boots. At one point she says “Hm,” in a way that makes you feel ancient and judged.',
            '“Static: moderate,” she says, finally. “Hope: low. Snacks: unknown.” She writes this down and stamps your hand with a little lightning bolt. “You may enter. Please do not daisy-chain the faithful.”',
          ]),
          _gateChoices(),
          flags: ['socket_pass'],
        ),
        Scene.talk(
          'g_joke',
          say([
            '“Does it work?” you ask. “Or is it just a hairbrush?”',
            'Sister Socket stares at you for a long, flat moment. “It is also a hairbrush,” she says. “That is how you know it is holy. It does two things.”',
            'You have no good answer to that. She stamps your hand anyway. The stamp is a very small, disappointed lightning bolt.',
          ]),
          _gateChoices(),
          flags: ['socket_pass', 'socket_joke'],
        ),
        Scene.talk(
          'g_snacks',
          say([
            'You produce a bag of crackers. Sister Socket looks at them the way a customs officer looks at a small suitcase. Then she smiles, and it changes her whole face.',
            '“A tithe,” she says softly. “Thank you. It’s been a lean season for crackers.” She stamps your hand, then adds a second stamp, a tiny gold star, which you suspect is rare.',
          ]),
          _gateChoices(),
          flags: ['socket_pass', 'socket_snacks'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'g_battery',
          say([
            '“What is the Battery?” you ask. Sister Socket looks like she has been waiting six years for someone to ask.',
            '“It’s a vessel,” she says. “Brother Positive says it holds the last spark of humanity. When everything else went out, the Battery stayed on. It has never once died. It speaks to us in the Voice.” She points at the loudspeaker. “The Voice says: THIS IS A TEST. We have been passing it for six years.”',
            '~The last spark of humanity. In a car battery. A Battery with the badge of a car dealership. You decide to keep your face still.',
          ]),
          _gateChoices(),
          flags: ['seen.g_battery', 'heard_voice'],
        ),
        Scene.talk(
          'g_fuse',
          say([
            'A small child in an oversized helmet is sitting on an upturned bucket with a pamphlet in each hand. She gives you both. “I’m Little Fuse,” she announces. “I blow when I’m excited. It’s fine, it’s just a figure of speech. Mostly.”',
            '“Do you believe in the Battery?” you ask.',
            'Fuse considers the question with great seriousness. “I believe in Brother Positive,” she says. “And the Battery says BEEP. Not anything else. Just BEEP. I like it when it beeps. It means somebody’s there. But,” and here she drops her voice, “it says other things too, and the grown-ups say those are holy. I think they’re just the weather.”',
            'She gives you a third pamphlet. “Don’t tell Dave I said that.”',
          ]),
          _gateChoices(),
          flags: ['seen.g_fuse', 'fuse_doubt'],
          reward: const Reward(xp: 5),
        ),
        Scene.talk(
          'g_dave',
          (c) => [
            ...BrotherPositive.dave(c),
            'You watch Dave for a while. He eats his sandwich. He nods at things. A woman asks him whether the Battery is angry today, and he says, “I wouldn’t worry,” and she is visibly reassured.',
            'Nobody looks twice at him. That’s the thing. In a settlement of people in jump-lead robes, he has no robe, no badge of rank, and no opinion on the Battery. He is not even rude about it. He’s just there, at the edge of every conversation, like a smell of toast.',
            '~Somebody ordinary has been in the room for every holy thing here. That is exactly the kind of person who writes a religion by accident.',
          ],
          _gateChoices(),
          flags: ['seen.g_dave', 'noticed_dave'],
        ),
        Scene.end(
          'g_in',
          (c) => [
            'You step through the gate. A hundred heads turn, then politely turn away. A woman is rhythmically wiping a kettle. A child is tuning a washing machine to a hymn. Over it all, the speaker on its pole gives a long, soft, reassuring crackle.',
            if (c.flag('socket_snacks')) 'Sister Socket tells everyone near the gate that you are “a donor,” in a hush normally reserved for saints.',
            'Somewhere ahead, a clear, warm voice has begun to call people to a sermon. You follow it, like everyone else.',
          ],
        ),
      ],
    ),
    // ---------------------------------------------------------------- 4.8
    Checkpoint(
      id: 'sermon',
      title: 'THE SERMON OF THE SPARK',
      km: 4.8,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 25),
      journal: (c) => [
        'Brother Positive preached to a car battery on a velvet cushion, with a congregation of sixty. He is warm, sincere and completely convinced.',
        if (c.flag('seen.s_res')) 'Reverend Resistance believes the faith is about refusing, not hoping. He told me to Resist. He did not say what.',
        if (c.flag('seen.s_cast')) 'The “scripture” is an old emergency broadcast loop. It names no god. It names a sector.',
        if (c.flag('seen.s_pos')) 'Brother Positive believes. I do not think he has ever been unkind. That is somehow worse.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...BrotherPositive.greeting(c),
            'The sermon is held in what used to be a car park. Sixty people sit in neat rows on folding chairs. At the front, on a velvet cushion on an upturned fridge, sits a scruffy, scratched-up car battery, with a halo of cardboard clipped to its terminals.',
            '“Beloved!” cries Brother Positive. “We are here because the Current has not left us. When all the lights went out, one light remained. The Battery! Who among us has not felt its warmth?” There is an affirming murmur. Someone says “Hum.”',
            'At the edge of the crowd you see a hard-faced old man in a coat of electrical tape, arms folded, looking at the Battery like it owes him money. Behind him, as always, Dave.',
          ],
          _sermonChoices(),
        ),
        Scene.talk(
          'hub',
          say(['The sermon rolls on. You find yourself nodding at things.']),
          _sermonChoices(),
        ),
        Scene.talk(
          's_res',
          (c) => [
            'The man in tape does not look at you. “Don’t ask me about the Battery,” says Reverend Resistance. “Ask me about the Resistance. That’s the only holy thing left. We are not a flock, we are a coil. A coil resists. A coil pushes back against the current. It is the only way we are ever going to stay alive.”',
            '“Resists what?” you ask.',
            '“Everything,” he says, with deep satisfaction. “Look. Brother Positive is a good man. He’s also a fool. He thinks the Battery is a heart. I think it’s a weapon pointed at us all. If it ever goes out, if it ever stops, we should be ready to resist the silence as hard as we’ve resisted the noise.”',
            if (c.skill('SURVIVAL') >= 1)
              'You notice he sleeps armed. The spanner on his belt is more worn than anything else he owns. He has been ready for a war for six years. He is practically begging to be given one.',
          ],
          _sermonChoices(),
          flags: ['seen.s_res'],
        ),
        Scene.talk(
          's_cast',
          (c) => [
            'You stand near the pole speaker and listen. Every few minutes, the Voice repeats. The congregation mouths along, the way people do with prayers they love and don’t quite hear.',
            '#THIS IS THE EMERGENCY BROADCAST SYSTEM. THIS IS A TEST. THIS IS ONLY A TEST.',
            '#IN THE EVENT OF AN EMERGENCY, REMAIN IN YOUR PLACE OF SHELTER. DO NOT ATTEMPT TO LEAVE. HELP IS ON ITS WAY. YOU ARE NOT ALONE.',
            '#SECTOR FOUR REPORTS NORMAL OPERATION. SECTOR FOUR REPORTS NORMAL OPERATION.',
            'They’ve capitalised YOU ARE NOT ALONE on a banner. They’ve named the choir “Sector Four.”',
            if (c.skill('HACKING') >= 1) '#...you recognise the structure. It’s an automated relay loop. It doesn’t speak. It cycles. Something under the substation is still keeping time.',
            '~They’ve been worshipping an answering machine. It’s a very reassuring answering machine.',
          ],
          _sermonChoices(),
          flags: ['seen.s_cast', 'knows_loop'],
        ),
        Scene.talk(
          's_pos',
          (c) => [
            'You catch Brother Positive at the edge of the crowd, polishing the Battery’s halo with his sleeve. Up close he’s younger than you expected, with the lined, sleepless face of someone who has never once been allowed to be tired.',
            '“Do you doubt it?” he asks, before you speak. He smiles gently. “It’s all right. I did. Six years ago, I was a dishwasher repairman in a town without dishes. I found a battery in a drift of wires and it was warm. Warm! Nothing was warm. I put my hand on it and heard a voice that said, YOU ARE NOT ALONE.”',
            '“It still says it?” you ask.',
            '“Every eleven minutes,” he says. “The only thing in this world that has never lied to me.”',
            'He is looking at you with such open, unbearable trust that you feel faintly ill. He believes in this. It’s the only thing holding him up.',
          ],
          [
            Choice('[ENCOURAGE HIM]', 'hub', flags: ['faith']),
            Choice('[PLANT A SEED OF DOUBT]', 'hub', flags: ['doubt']),
            Choice('[SAY NOTHING]', 'hub'),
          ],
          flags: ['seen.s_pos'],
        ),
        Scene.talk(
          's_leave',
          (c) => [
            'You slip away from the folding chairs. Behind you the sermon builds to a call-and-response, “Is it charged?” “IT IS CHARGED!”, and the whole car park shakes with the joy of it.',
            'Dave is leaning on a wall near the vestry door. He hasn’t moved. He has a sandwich again, a different one. He nods at you, as one nods to a man on a bus.',
            '“If you’re looking for the Reliquary,” he says carefully, “it’s round the back. Under the substation. They don’t let people go down. But the door isn’t locked.”',
            'He takes a bite. “I wouldn’t know that. I’m just a man with a sandwich.”',
          ],
          [
            Choice('[ASK HIM HOW HE KNOWS]', 's_dave'),
            Choice('[THANK HIM AND GO]', 's_go'),
          ],
        ),
        Scene.talk(
          's_dave',
          say([
            '“I just know things,” Dave says. “I know where the stairs are, and I know where the spare keys are, and I know what time the sermon ends. It’s not really knowledge. It’s the kind of thing you absorb when you’re always around. You’d be amazed what people say in front of someone who looks like a bus stop.”',
            'He gives you a slow, level look that doesn’t quite match his face. For a moment you can almost see the other man behind it, the one who’s been very tired for a very long time.',
            '“Go down,” he says. “Please. Somebody ought to.”',
          ]),
          [Choice('[GO DOWN]', 's_go')],
          flags: ['dave_talked'],
        ),
        Scene.end(
          's_go',
          say([
            'You go round the back of the substation. A squat steel door stands at the foot of a flight of concrete steps. It has a sign: RELIQUARY — AUTHORISED PERSONS ONLY. UNDER THAT, in a crayon: (EVERYONE IS AUTHORISED. PLEASE DON’T BREAK ANYTHING.)',
            'The door isn’t locked. Of course it isn’t.',
          ]),
        ),
      ],
    ),
    // ---------------------------------------------------------------- 6.4
    Checkpoint(
      id: 'reliquary',
      title: 'THE RELIQUARY',
      km: 6.4,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 30),
      journal: (c) => [
        'Under the substation: the original Emergency Broadcast relay, running on a car battery wired in by a man who did not know what he was doing.',
        if (c.flag('dave_admitted')) 'Dave admitted it. He started the religion. He did it by saying “bless you” to a machine.',
        if (c.flag('knows_relay')) 'The Battery is a patch. The relay is what is really talking.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The stairs go down for longer than the building above could possibly account for. At the bottom is a low concrete room that hums at exactly the pitch of a held breath.',
            'A rack of ancient equipment stands against the far wall: a dozen grey boxes full of dead dials, one lit panel marked E.B.S. RELAY — SECTOR FOUR. A thick cable runs from it across the floor to a dusty plinth where a second car battery sits, identical to the one upstairs.',
            '“The one upstairs is the decoy,” says a voice. Dave is on the stairs behind you, hands in his coat, looking very small and very tired. “The real one is this one. They put a second one up top because the first one ran down, and nobody could tell the difference. I could. I changed it.”',
            if (c.flag('dave_talked')) 'He gives you a look. “Thank you for coming down. I wasn’t sure anyone would.”',
          ],
          [
            Choice('[ASK DAVE WHAT HE DID]', 'r_dave'),
            skillChoice('ENGINEERING', 1, 'INSPECT THE RELAY', 'r_relay'),
            skillChoice('HACKING', 1, 'READ THE BROADCAST LOG', 'r_log'),
            Choice('[TAKE A LOOK AROUND]', 'r_hub'),
          ],
        ),
        Scene.talk(
          'r_hub',
          say(['You walk the room. It is clean, in the way a tomb is clean. Somebody has been dusting.']),
          [
            Choice('[ASK DAVE WHAT HE DID]', 'r_dave', show: (c) => !c.flag('seen.r_dave')),
            skillChoice('ENGINEERING', 1, 'INSPECT THE RELAY', 'r_relay'),
            skillChoice('HACKING', 1, 'READ THE BROADCAST LOG', 'r_log'),
            Choice('[GO BACK UP]', 'r_up'),
          ],
        ),
        Scene.talk(
          'r_dave',
          say([
            '“I was a maintenance technician,” Dave says. “Contractor. Third class. I came down here after the bombs, to see if the relay still worked. It did. The battery was nearly dead. I put a new one in. It was a car battery, there was nothing else.”',
            '“And?”',
            '“And it sneezed,” says Dave, miserably. “Sort of a crackle. And I said, ‘bless you.’ Out loud. Just to be polite. Nobody had spoken to me in a month. Somebody up top heard the relay play the word ‘you’ right after, and decided that was it answering. And then they wanted me to tell them what it meant.”',
            '“And you said...?”',
            'Dave puts his face in his hands. “I said it meant that they weren’t alone. Which is true! It says so. I wasn’t even lying. They were so, so lonely. I just wanted them to be kind to each other. And then Brother Positive found the battery warm and made a whole thing of it, and by the time I realised it was a church I was already the man at the back, with a sandwich.”',
          ]),
          [
            Choice('[“YOU STARTED THE WHOLE RELIGION.”]', 'r_admit'),
            Choice('[“THAT’S... ACTUALLY KIND.”]', 'r_kind'),
            Choice('[“THEY SHOULD KNOW.”]', 'r_know'),
          ],
          flags: ['seen.r_dave'],
        ),
        Scene.talk(
          'r_admit',
          say([
            '“Yes,” says Dave, with the terrible dignity of a man finally saying it. “Yes. I did. Six years ago. A bad day and a good manners reflex.”',
            'He sits down on the bottom step. For the first time since you met him, he looks like a person. He eats nothing at all.',
          ]),
          [Choice('[CONTINUE]', 'r_hub')],
          flags: ['dave_admitted', 'carry.dave.admitted'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'r_kind',
          say([
            '“Is it?” Dave looks up like a man who hasn’t been forgiven for years. “It’s the only thing I’ve ever done that mattered, and I did it by accident. I’d like to say I meant it.”',
            '“You can say it now.”',
            '“...I meant it,” he says, carefully, as if testing a thin floor. “I did. I meant it.”',
          ]),
          [Choice('[CONTINUE]', 'r_hub')],
          flags: ['dave_admitted', 'carry.dave.admitted', 'dave_forgiven'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'r_know',
          say([
            '“They should,” Dave agrees at once. “I’ve been meaning to tell them for six years. But every time I try, Brother Positive starts crying with joy. It’s very hard to puncture. Have you ever tried to puncture joy?”',
            '“Not on purpose.”',
            '“It’s like popping a small, sad balloon.” He sighs. “If you do it, do it kindly. Please. They’re good people. They’ve just got a very good reason to be wrong.”',
          ]),
          [Choice('[CONTINUE]', 'r_hub')],
          flags: ['dave_admitted', 'carry.dave.admitted', 'wants_truth'],
        ),
        Scene.talk(
          'r_relay',
          (c) => [
            'The relay is old but cared for. You open a panel and the wiring reads like a diary written by someone with no real idea what they were doing. There is a jumper cable at the base labelled CAR BATTERY (TEMPORARY). “TEMPORARY” has been underlined six times.',
            'The problem is clear: the battery is feeding the relay a trickle of power, and the relay has been cycling the same three messages, thinning with every year. If nobody does something soon, it will die.',
            if (c.skill('ENGINEERING') >= 2)
              'You also notice a replacement coil in a drawer, perfectly preserved. Someone, years ago, put it there for exactly this. You could fix this properly.',
          ],
          [Choice('[CONTINUE]', 'r_hub')],
          flags: ['knows_relay'],
        ),
        Scene.talk(
          'r_log',
          say([
            'The terminal’s screen glows green. You scroll through six years of identical entries.',
            '#BROADCAST CYCLE COMPLETE. LISTENERS: 61. LISTENERS: 61. LISTENERS: 62. (A NEW BABY.) LISTENERS: 60. (DAVE CRIED.)',
            '#SECTOR FOUR: STATUS NORMAL. SECTOR FOUR: STATUS NORMAL.',
            '#SYSTEM NOTE: BATTERY CHARGE AT 11%. RECOMMEND REPLACEMENT WITHIN SIX YEARS. (THIS NOTE IS SIX YEARS OLD.)',
            'The relay has been counting its congregation all along. It has no idea what a church is. It just keeps noting who is listening.',
          ]),
          [Choice('[CONTINUE]', 'r_hub')],
          flags: ['knows_relay', 'knows_log'],
          reward: const Reward(xp: 8),
        ),
        Scene.end(
          'r_up',
          (c) => [
            'You climb back into daylight. The sermon has ended. The congregation is arranging itself into a long, slow, singing queue at the altar, where Brother Positive will present the Battery for the Blessing of the Day.',
            if (c.flag('dave_admitted')) 'Dave walks up the stairs behind you. He is, for the first time, a little taller. “Whatever you do,” he says, “don’t do it for me.”',
            'Somewhere inside all those voices, you can hear the speaker take a breath.',
          ],
        ),
      ],
    ),
    // ---------------------------------------------------------------- 8.0
    Checkpoint(
      id: 'altar',
      title: 'THE BLESSING OF THE DAY',
      km: 8.0,
      art: 'shrine',
      start: 'a',
      reward: const Reward(scrap: 30, xp: 45),
      journal: (c) => [
        'At the altar I had to decide what to do about the Battery, the relay, and the sixty people who love both.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The whole Holy Circuit is gathered at the altar. Brother Positive stands at the front with his arms raised, the Battery glowing under its cardboard halo. Sister Socket stands guard with her clipboard. Little Fuse sits on someone’s shoulders. Reverend Resistance looks like a coiled spring in a coat.',
            '“Beloved,” says Brother Positive, “today we are blessed with a Traveller. They have come far to see the Light. I would like to ask them to bless us in turn.”',
            'He looks at you. They all do. Sixty faces, expectant, hopeful, devout. The Voice crackles on its pole, waiting.',
            if (c.flag('dave_admitted')) 'At the back, Dave gives you the smallest possible nod. It could mean anything.',
          ],
          [
            Choice('[TELL THEM THE TRUTH]', 'truth'),
            Choice('[REPAIR THE RELAY]', 'repair'),
            Choice('[TAKE THE BATTERY]', 'steal'),
            Choice('[TAKE THE ROBE]', 'robe'),
          ],
        ),
        // ---- tell the truth
        Scene.talk(
          'truth',
          (c) => [
            'You step up beside the Battery. The Voice stops, as if listening. You take a breath.',
            if (c.flag('dave_admitted'))
              'You tell them about the relay below. About the voice that never spoke. About a man called Dave and a manners reflex.',
            if (!c.flag('dave_admitted')) 'You tell them what you found below: the relay, the decoy, the loop that has been cycling long after anyone who made it was dead.',
            'The silence is enormous. Sister Socket’s clipboard hits the ground. Little Fuse, on someone’s shoulders, says, “I knew it,” in a very small, very proud voice, and everyone ignores her.',
            'Brother Positive has gone white. “The Battery,” he says. “It’s... a battery.”',
          ],
          [
            Choice('[SAY IT GENTLY]', 'gentle'),
            Choice('[PRESS HARDER: “IT’S A LIE.”]', 'blunt'),
            Choice('[LET DAVE SPEAK]', 'dave_speaks', show: (c) => c.flag('dave_admitted')),
          ],
          flags: ['told_truth'],
        ),
        Scene.talk(
          'dave_speaks',
          say([
            'Dave walks up the aisle with his sandwich. He puts it down on the altar. Nobody has ever seen him do that.',
            '“It was me,” he says. “I said bless you to a machine. I’m so sorry. I’ve been very lonely, and so have all of you, and I think that’s the only real thing in all this. The machine doesn’t love you. I do. A bit. In a very ordinary way.”',
            'A long pause. Then someone in the front row, an old woman with a kettle, says, “Well. Obviously.”',
            'And somebody laughs, and somebody else sobs, and in a minute sixty people are hugging a man who’s never taken off his coat.',
          ]),
          [Choice('[LET THEM HAVE THIS]', 'end_enlightened')],
          reward: const Reward(xp: 25),
        ),
        Scene.talk(
          'gentle',
          say([
            '“It’s still holy,” you tell them, stepping toward Brother Positive. “It’s what you did with it that’s holy. You took in the lost. You fed them. You kept each other warm. The Battery didn’t do any of that. You did.”',
            'Brother Positive’s lip trembles. “All of that? Me?”',
            '“All of you.”',
            'It takes a long time. There’s weeping. Sister Socket sits down on the floor with her clipboard in her lap. Little Fuse hugs your leg. And at the end, Brother Positive turns to the Battery and says, very quietly, “Thank you for the company,” and sets the halo gently down on the cushion.',
          ]),
          [Choice('[CONTINUE]', 'end_enlightened')],
          reward: const Reward(xp: 20),
        ),
        Scene.talk(
          'blunt',
          say([
            '“It’s a lie,” you say. “Forty years of power cuts, a drowsy relay, and a man with a sandwich. That’s all it is.”',
            'There’s a gasp. Brother Positive stumbles back as if you’d hit him. And a hard, flat voice comes out of the crowd: Reverend Resistance, striding forward, with a spanner in his fist and a light in his eyes you haven’t seen before.',
            '“I KNEW IT,” he roars. “I told you. I said the Battery was a trap. Now the Voice itself has been revealed! Then the Voice must be resisted!”',
            'Half the congregation roars with him. The other half is gripping its hymnals.',
          ]),
          [
            Choice('[SIDE WITH THE REVEREND]', 'end_holywar', flags: ['sided_res']),
            Choice('[SPEAK UP, TRY TO CALM THEM]', 'gentle'),
          ],
        ),
        // ---- repair
        Scene.talk(
          'repair',
          (c) => [
            'You head below. The room hums. Dave follows without a word. He stands by the stairs, hands in his pockets, as you open the relay panel.',
            if (c.flag('knows_relay'))
              'You already know how this works. The coil in the drawer, the patch cable, the thin trickle of a dying battery. You could do it properly, once and for all.'
            else
              'The relay is a mess of ancient wiring. You can see what needs doing. You just don’t know how.',
          ],
          [
            Choice('[HACK THE CONTROLLER]', 'rhack'),
            skillChoice('ENGINEERING', 2, 'REPLACE THE COIL PROPERLY', 'rsolid'),
            Choice('[KICK IT]', 'rkick'),
          ],
        ),
        Scene.hack(
          'rhack',
          say(['The relay’s controller is a green-lit box that has been counting its listeners for six years.']),
          win: 'rsolid',
          fail: 'rfail',
        ),
        Scene.talk(
          'rfail',
          say([
            'The controller crackles, spits, and zaps you in the knuckles with six years’ worth of loneliness. “THIS IS A TEST,” it shouts, angrily. “THIS IS ONLY A TEST.”',
            'Upstairs, sixty people gasp in unison as the speaker screams.',
          ]),
          [
            Choice('[GET UP AND KICK IT]', 'rkick'),
            Choice('[GIVE UP AND LEAVE IT]', 'r_giveup'),
          ],
          reward: const Reward(hp: -6),
        ),
        Scene.talk(
          'r_giveup',
          say([
            'You back away from the panel, rubbing your hand. The relay mutters to itself. The Battery upstairs flickers, once, and holds.',
            'There is nothing more to do down here, and a congregation waiting up there.',
          ]),
          [Choice('[GO BACK UP]', 'a')],
        ),
        Scene.talk(
          'rkick',
          say([
            'You kick the grey box at the exact place a mechanic would call “the sweet spot,” and a technician’s textbook would call “absolutely not.”',
            'It hums. It clicks. And then, with a long, deep, stable note, it comes alive.',
            '#THIS IS THE EMERGENCY BROADCAST SYSTEM. SECTOR FOUR, YOU ARE NOT ALONE. YOU ARE NOT ALONE. YOU ARE NOT ALONE.',
            'Dave breathes out. “That’s,” he says, “nine times louder than it’s ever been.”',
          ]),
          [Choice('[CONTINUE]', 'rsolid_end')],
          flags: ['kicked'],
        ),
        Scene.talk(
          'rsolid',
          say([
            'You work for what feels like an hour. The old coil clicks in. The jumper cable goes in the bin. In its place you run a clean line to a real power source, a little solar rig from Sister Socket’s own roof.',
            'The relay hums up through a dozen pitches and settles on one: low, even, strong.',
            '#THIS IS THE EMERGENCY BROADCAST SYSTEM. THIS IS NOT A TEST. THIS IS NOT A TEST. (CLEARS THROAT.) THIS IS A GREETING.',
            'Dave laughs. It’s the first time you’ve heard it. It sounds a little rusty.',
          ]),
          [Choice('[CONTINUE]', 'rsolid_end')],
        ),
        Scene.talk(
          'rsolid_end',
          (c) => [
            'You come back up into the daylight with the relay singing behind you. The Battery on its cushion glows, and the Voice, new and steady, says something it has never said before: the weather, the time, a polite reminder that it’s a pleasant day for it.',
            'Brother Positive stares at the speaker. “It’s... talking,” he whispers. “Properly. It says the weather.”',
            if (c.flag('kicked')) 'Sister Socket points at you. “They kicked it. It’s the Miracle of the Kick.” Someone begins taking notes.',
          ],
          [Choice('[LET THEM BELIEVE]', 'end_eternal')],
        ),
        // ---- steal
        Scene.talk(
          'steal',
          say([
            'You walk to the altar and put one hand on the Battery. It’s warm. There’s a collective intake of breath, like a congregation falling over a threshold.',
            '“Child,” says Brother Positive, very softly. “Please. Don’t.”',
            'Sister Socket has dropped her clipboard and is reaching for a very large wrench. At the edge of the crowd, Reverend Resistance is smiling grimly. He wants someone to do this. He very much wants someone to have done this.',
          ]),
          [
            Choice('[PICK THE BATTERY’S LOCK]', 'slock'),
            Choice('[GRAB IT AND RUN]', 'sfight'),
            Choice('[LET THE REVEREND HAVE IT]', 'sres'),
          ],
        ),
        Scene.lock(
          'slock',
          say(['The Battery is chained to the cushion by a very small padlock and a very large sense of occasion.']),
          win: 'send',
          fail: 'sfight',
        ),
        Scene.fight(
          'sfight',
          say([
            'You wrench the Battery free. The congregation screams. Sister Socket charges with her wrench, a stout, furious woman built entirely from principles.',
            'A nearby scavenger, hired by Resistance to keep order, lunges at you.',
          ]),
          EnemyType.straggler,
          win: 'send',
          fail: 'sfail',
        ),
        Scene.talk(
          'sfail',
          say([
            'You get thrown against the altar and the Battery rolls free. Sister Socket stands over you with her wrench, breathing hard. “You will leave,” she says, “and you will think about what you’ve done.”',
            'You are going to. For about thirty seconds.',
          ]),
          [
            Choice('[GRAB IT AGAIN]', 'send'),
            Choice('[BACK DOWN, AND TELL THE TRUTH]', 'truth'),
          ],
        ),
        Scene.talk(
          'send',
          say([
            'You have the Battery under your arm. It is heavier than a battery has a right to be. The speaker on the pole is crackling, a long, painful, rising whine, like a person trying to say something and running out of breath.',
            'The whole congregation is on its knees. Little Fuse is crying silently. Brother Positive reaches for you as if for a falling child.',
            '“Please,” he says. “It’s all we have.”',
          ]),
          [
            Choice('[PULL THE PLUG: IT ENDS HERE]', 'end_disconnect'),
            Choice('[HAND IT TO THE REVEREND]', 'sres'),
          ],
        ),
        Scene.talk(
          'sres',
          say([
            'You hold the Battery out to Reverend Resistance. He takes it with trembling hands, and for the first time, you see him smile for real.',
            '“Now,” he says to the crowd, “we are free of the Voice! Now we resist!”',
            'It takes exactly forty seconds before someone calls him a heretic.',
          ]),
          [Choice('[STEP BACK AND WATCH]', 'end_holywar')],
          flags: ['gave_battery'],
        ),
        // ---- the robe
        Scene.talk(
          'robe',
          (c) => [
            'You step up beside Brother Positive and lift your hands, the way you’ve seen him do it. “Beloved,” you hear yourself say.',
            'The congregation goes still. There’s a sound like a very large crowd deciding something.',
            '“The Battery,” you continue, “has sent me with a message.”',
            'Brother Positive is staring at you with trembling joy. “A Prophet,” he breathes. “At last. A Prophet to carry the Light.” Little Fuse is clapping. Sister Socket is nodding briskly, as if you’d filed the right paperwork.',
            if (c.flag('dave_admitted'))
              'At the back, Dave has put his face in his hands. He’s shaking. It takes you a moment to realise he’s laughing.',
          ],
          [
            Choice('[BACK DOWN]', 'a'),
            Choice('[ACCEPT THE ROBE]', 'end_prophet'),
          ],
        ),
        // ---- endings
        Scene.end(
          'end_enlightened',
          (c) => [
            'The Holy Circuit does not fall apart. That’s what you remember afterwards. It wobbles, and weeps, and rebuilds itself into something smaller and kinder. The robes go in a trunk. The hymns stay.',
            'Brother Positive keeps his halo but takes it off the Battery. He puts it on the table at meals, as a centrepiece. “For remembering,” he says. Sister Socket reorganises the whole community into sensible shifts. Little Fuse says she is going to be a scientist. Dave takes off his coat for the first time, and it turns out he is wearing a second, identical coat.',
            'The Battery is retired to a shelf. Every night someone says goodnight to it. It is no longer a god. It is a friend.',
            '~Something true is worth more than something warm. Though you have to admit, the warmth helped.',
          ],
          ending: 'enlightened',
        ),
        Scene.end(
          'end_prophet',
          (c) => [
            'They call you Eminent Voltage. They write it on a banner. A child asks you to bless her bicycle and you do, with great solemnity, and it does not explode, which everyone counts as a miracle.',
            'The robe is itchy and smells like pennies. The congregation brings you tea. Brother Positive becomes your deputy and has never been happier. “You carry the Light better than I,” he tells you, with tears in his eyes.',
            'You are determined to use this for good. You issue three decrees: PLEASE WASH YOUR HANDS, PLEASE SHARE THE SNACKS, and DAVE CAN TAKE A SEAT. It works. Somehow it works.',
            '~You came to this place to find out what the joke was. You are, you suspect, the joke. It’s a very warm joke.',
          ],
          ending: 'prophet',
        ),
        Scene.end(
          'end_disconnect',
          (c) => [
            'You pull the cable. There is a brief, spooling whine. Then the speaker coughs, and the Voice, six years of it, thins into a long, mournful “...thiiiis...”, and stops.',
            'The silence that follows is bigger than anything you have ever heard. The congregation stays on its knees for almost an hour. Nobody speaks. Then Sister Socket stands, picks up her clipboard, and writes, in a very careful hand: THE GREAT DISCONNECTION.',
            'You walk out of the gate with the Battery under your arm. Nobody stops you. Behind you, Little Fuse says, in a voice you will hear for a long time, “It was just beeping.”',
            '~They’ll recover. People do. You can’t say you enjoyed it.',
          ],
          ending: 'disconnection',
        ),
        Scene.end(
          'end_holywar',
          (c) => [
            'It starts with a sermon and ends with a wheelbarrow. By sundown the Holy Circuit has two flags, three barricades, and a disputed goose.',
            'Reverend Resistance’s faction holds the Battery. Brother Positive’s holds the speaker. Sister Socket, who is in neither, has built a first-aid tent in the middle and treats both sides with equal, terrifying efficiency.',
            'Little Fuse blows, in the figurative sense, and goes off to live with the goose. Dave has taken a post in no man’s land with a sandwich. Both sides leave him alone. “He’s harmless,” both sides say. “He’s ordinary.”',
            '~A war with one casualty and a lot of shouting. You hope it stays that way.',
          ],
          ending: 'holywar',
        ),
        Scene.end(
          'end_eternal',
          (c) => [
            'The relay hums steady for the first time in forty years. The Voice, newly confident, begins to say things that are actually useful: the weather, the dust-storm forecast, and, once a day, the exact water level in the Scrap Orchard well.',
            'The congregation listens carefully. Within a week the Holy Circuit is the best-informed settlement on the circuit. Brother Positive is thrilled. “The Battery has gone from prophecy to practicality!” he cries. “It is a blessing and a barometer!”',
            'Dave sits in the back row, finally relaxed. The Voice says goodnight to him by name, as of last Tuesday. He has not said anything about it. But he is smiling at the speaker, very slowly, the way you smile at an old friend.',
            '~An eternal circuit. It’s a pretty good epitaph for a car battery.',
          ],
          ending: 'eternal',
        ),
      ],
    ),
  ],
);
