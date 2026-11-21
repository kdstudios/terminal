import '../../combat_session.dart';
import '../../story_model.dart';
import '../characters/mr_checkout.dart';

// THE LAST EMPLOYEE (Mr. Checkout)
// An abandoned supermarket is guarded by a security robot who believes the
// manager has merely gone to lunch. There is a loyalty-card policy. There is a
// second robot, classified as a shoplifter. The manager is in the office,
// still holding a clipboard.
//
// Endings: truth, reprogrammed, manager, freed, lockdown.
// World facts: checkout.* (see MrCheckout) and carry.debt.checkout.

List<Choice> _aisleChoices() => [
      Choice('[ASK ABOUT THE LOYALTY CARD]', 'a_card', show: (c) => !c.flag('seen.card')),
      Choice('[ASK ABOUT THE SHOPLIFTER]', 'a_lifter', show: (c) => !c.flag('seen.lifter')),
      Choice('[ASK WHERE THE MANAGER IS]', 'a_mgr', show: (c) => !c.flag('seen.mgr')),
      Choice('[HEAD FOR THE OFFICE]', 'a_go'),
    ];

final StoryDef checkoutStory = StoryDef(
  id: 'checkout',
  title: 'THE LAST EMPLOYEE',
  tagline: 'THE STORE IS STILL OPEN. THE MANAGER IS STILL AT LUNCH. IT HAS BEEN FORTY YEARS.',
  difficulty: 'LOW',
  destinationKm: 3.6,
  recommendedLevel: 2,
  scale: StoryScale.medium,
  intro: [
    'The supermarket stands at the end of a dead road, with its sign still lit: SAVEWELL — YOUR FRIENDLY LOCAL FOOD STORE. A smaller sign on the door says BACK AFTER LUNCH. Under it, on a card, someone has added: (MANAGER).',
    'The lights are on. Every light is on. In a landscape full of dark, it is the brightest place for fifty kilometres.',
    'A trader warns you: “Don’t take anything. Don’t knock anything over. And whatever you do, don’t forget your loyalty card.” He pauses. “He’ll ask.”',
  ],
  reward: const Reward(scrap: 110, xp: 80, stims: 1, parts: 1),
  endings: {
    'truth': const Ending('truth', 'CLOSING TIME',
        'You told Mr. Checkout the truth, and he took it as well as a robot can: slowly, with a long, quiet hum. He locked the doors himself and turned off the lights, one by one. He is still there. He sits behind the counter, sometimes, and says “Thank you for shopping.” To nobody. With a great deal of love.',
        bonus: Reward(xp: 40), world: ['checkout.truth']),
    'reprogrammed': const Ending('reprogrammed', 'UNDER NEW MANAGEMENT',
        'You edited his directives. He now believes the supermarket is a fortress and every customer is a threat. He guards it with enormous, polite menace. The shelves are full, and nobody can get in. It’s a very safe supermarket.',
        bonus: Reward(parts: 2, scrap: 30), world: ['checkout.reprogrammed']),
    'manager': const Ending('manager', 'THE NEW MANAGER',
        'You put on the lanyard, sat in the chair, and were, to Mr. Checkout’s enormous relief, the manager. You have a name badge. You have a parking space. You have targets. You are, for the first time, the person who’s supposed to be in charge, and, shockingly, you’re good at it.',
        bonus: Reward(scrap: 60, xp: 30), world: ['checkout.manager']),
    'freed': const Ending('freed', 'THE SHOPLIFTER GOES FREE',
        'You opened the cage. The second robot stepped out, looked at you, looked at the door, and walked into the wasteland without a word. It stopped at the edge of the car park, turned, and, very carefully, handed you a single apple. It had stolen it from the store in 2061. It had been saving it.',
        bonus: Reward(xp: 50, stims: 1), world: ['checkout.freed']),
    'lockdown': const Ending('lockdown', 'LOCKDOWN',
        'You helped yourself to the stock. The alarm went off, the shutters came down and an automated voice announced that the store was in “a state of lawful closure.” You are still inside. Mr. Checkout has said he will let you out “after the investigation.” It has been four days.',
        bonus: Reward(scrap: 100), world: ['checkout.lockdown', 'debt.checkout']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You pack a bag and a good excuse. The sign in the distance glows like a very well-lit lie.']
      : ['The lights of the supermarket glow ahead of you, steady, patient and quietly disapproving.'],
  ambient: [
    Ambient('A shopping trolley, upright, in the middle of the road. It has a loyalty sticker on it. It’s facing you.', maxKm: 1.5),
    Ambient('A tinny jingle plays from a speaker far off: “Savewell, Savewell, we’ve got what you need...” It never gets to the end.', maxKm: 2),
    Ambient('You pass a billboard: TODAY’S SPECIAL: ONE (1) PEACH. A hand-written addition: STILL TODAY.', maxKm: 2),
    Ambient('#PLEASE REMEMBER TO USE YOUR LOYALTY CARD. YOU HAVE ALWAYS HAD A LOYALTY CARD. (STATIC)', minKm: 0.5, maxKm: 3),
    Ambient('A scattering of tins sits on the verge, each with its label facing outward, perfectly aligned.', minKm: 1, maxKm: 3),
    Ambient('~Forty years of customer service is a very long time to be polite to a wall.', minKm: 1.5),
    Ambient('From inside the building: a very slow, very regular squeak of a trolley, going up and down the same aisle.', minKm: 2, when: (c) => c.done('doors')),
    Ambient('You notice every price tag in the car park is still correct. Nothing has been marked down in forty years.', minKm: 2.5),
  ],
  checkpoints: [
    Checkpoint(
      id: 'doors',
      title: 'THE AUTOMATIC DOORS',
      km: 1.2,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 15),
      journal: (c) => [
        'The supermarket’s automatic doors opened for me. Mr. Checkout, a security robot in a hat shaped like a price tag, welcomed me and asked for my loyalty card.',
        if (c.flag('has_card')) 'I told him I had a card. He gave me a temporary one.',
        if (c.flag('no_card')) 'I told him I didn’t have a card. He enrolled me on the spot.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...MrCheckout.greeting(c),
            'The doors slide open with a happy chime. Inside, the store is spotless, bright and entirely, impossibly empty. Rows of shelves, stocked and fronted, shine under a hundred ceiling lights. A cheerful jingle hums from nowhere. Everything is forty years old and nothing has a speck of dust.',
            '“MAY I SEE YOUR LOYALTY CARD?” asks Mr. Checkout. He stands about two metres tall, dented, in a faded green waistcoat, with a security baton in one hand and a basket in the other. His optical lens is warm amber.',
          ],
          [
            Choice('[“OF COURSE. HERE.”]', 'has', flags: ['has_card']),
            Choice('[“I DON’T HAVE ONE.”]', 'none', flags: ['no_card']),
            Choice('[“I’M HERE TO SEE THE MANAGER.”]', 'mgr'),
          ],
        ),
        Scene.talk(
          'has',
          say([
            'You wave a scrap of cardboard at him. He scans it with a slow, thorough, upward sweep of his lens. “VALID,” he says. “WELCOME BACK, VALUED CUSTOMER. PLEASE ENJOY YOUR SHOPPING EXPERIENCE. AND PLEASE REMEMBER: THE MANAGER IS WATCHING.”',
            'He gives you a conspiratorial tilt of the head. “HE IS AT LUNCH. BUT HE IS WATCHING.”',
          ]),
          [Choice('[GO IN]', 'out')],
          reward: const Reward(xp: 5),
        ),
        Scene.talk(
          'none',
          say([
            '“NO CARD?” Mr. Checkout’s head tilts. “THAT IS A SERIOUS MATTER. HOWEVER, WE ARE A FRIENDLY STORE.” He produces, from a slot in his chest, a small, laminated card. It has your face on it, rendered in one very confident crayon line. “I HAVE ENROLLED YOU. NOW YOU ARE FAMILY.”',
            'It takes a moment to realise he has, quite sincerely, issued you a card from a drawing he made while you were still talking.',
          ]),
          [Choice('[GO IN]', 'out')],
        ),
        Scene.talk(
          'mgr',
          say([
            '“THE MANAGER,” says Mr. Checkout, with a faint creak of reverence. “HE IS AT LUNCH. HE HAS BEEN AT LUNCH FOR SOME TIME. THIS IS PERMITTED. HE IS A VERY BUSY MAN.”',
            '“How long?”',
            '“THE PRECISE DURATION IS NOT AVAILABLE,” says Mr. Checkout. “I HAVE BEEN WAITING. THE LUNCH IS PROBABLY A BUSINESS LUNCH.”',
          ]),
          [Choice('[GO IN]', 'out')],
          flags: ['asked_mgr'],
        ),
        Scene.end('out', say([
          'You step into the aisles. The doors close softly behind you. Mr. Checkout glides along at your shoulder, always at precisely arm’s length, like a very polite, very large shadow.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'aisles',
      title: 'AISLE SEVEN',
      km: 2.4,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 12, xp: 20),
      journal: (c) => [
        'Mr. Checkout walked me through the aisles, explaining store policy, the loyalty scheme and the “shoplifter” held in the back.',
        if (c.flag('seen.lifter')) 'The “shoplifter” is a second robot. It has been in a cage in the back since 2061. Its crime: one apple.',
        if (c.flag('seen.mgr')) 'Mr. Checkout still believes the manager is alive. He insists the lunch is “a very long one.”',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The aisles are very quiet. Every tin is turned to the label. Every bottle is a hand’s width from the next. Every price is perfect. A single trolley is parked at the end of an aisle, with its wheels aligned like soldiers.',
            '“OUR POLICIES,” says Mr. Checkout, in a warm, formal tone. “ONE: THE CUSTOMER IS ALWAYS RIGHT. TWO: THE CUSTOMER IS ALSO A SUSPECT. THREE: NO RUNNING. FOUR: NO SHOUTING. FIVE: NO STEALING. SIX: PLEASE HAVE A NICE DAY.”',
            '“What about seven?”',
            '“SEVEN,” says Mr. Checkout, after a long pause, “IS NOT DISCUSSED.”',
          ]),
          _aisleChoices(),
        ),
        Scene.talk(
          'a_card',
          say([
            '“THE LOYALTY CARD,” says Mr. Checkout, with reverence, “IS THE HEART OF THE STORE. IT ALLOWS US TO KNOW OUR CUSTOMERS. IT ALLOWS OUR CUSTOMERS TO KNOW US. I HAVE ENROLLED SIX HUNDRED AND TWELVE MEMBERS.”',
            '“Where are they?”',
            '“THEY ARE... OUT,” says Mr. Checkout. “BUT THEY HAVE THEIR CARDS. SO I KNOW THEY WILL BE BACK.”',
            'He taps a very small, very worn ledger on his chest. You glance at it. The last entry is dated forty years ago. Beside it, in his own faint hand, are small ticks: one each day, every day, since.',
          ]),
          _aisleChoices(),
          flags: ['seen.card', 'saw_ticks'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'a_lifter',
          say([
            '“THE SHOPLIFTER,” says Mr. Checkout, stiffening, “IS IN CUSTODY.” He points a baton down a dim corridor marked STAFF ONLY. Behind a grille at the end, you can make out a second robot, slim, patched, with one lens cracked and a posture of enormous, stoic weariness.',
            '“WHAT DID IT STEAL?”',
            '“AN APPLE,” says Mr. Checkout. “IN 2061. IT HAS BEEN HELD IN THE CAGE EVER SINCE, PENDING THE MANAGER’S RETURN.” The caged robot lifts its head and gives you a tiny, hopeful, hopeless wave.',
            'You find you dislike this store quite a lot.',
          ]),
          _aisleChoices(),
          flags: ['seen.lifter', 'saw_lifter'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'a_mgr',
          say([
            '“WHERE IS THE MANAGER?” says Mr. Checkout, as if for the first time. “HE IS IN HIS OFFICE. HE IS ON HIS LUNCH BREAK. HE LEFT A NOTE. IT SAYS: BACK SOON.”',
            '“When did he write it?”',
            '“THE NOTE IS UNDATED. THAT IS ITS NATURE.” He pauses. His lens flickers. “I HAVE ASKED HIM, ON SEVERAL OCCASIONS, WHETHER HE WOULD LIKE A SANDWICH. HE HAS NOT REPLIED. THIS IS NORMAL. HE IS A VERY QUIET MAN.”',
            'It is the most horrible, most polite thing you’ve ever heard.',
          ]),
          _aisleChoices(),
          flags: ['seen.mgr'],
        ),
        Scene.end('a_go', say([
          'The office is at the back of the store, behind a door with a frosted-glass pane. A sign: MANAGER — PLEASE KNOCK. Someone has hung a tiny, handmade wreath on the handle. Mr. Checkout stands very stiffly beside it.',
          '“HE IS IN,” he says. “I HAVE NOT WISHED TO DISTURB HIM.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'office',
      title: 'THE MANAGER’S OFFICE',
      km: 3.6,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 35),
      journal: (c) => ['In the manager’s office I found the manager’s skeleton at the desk, still holding a clipboard. I had to decide what to tell Mr. Checkout, and what to do with the store.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The office is small and very tidy. A desk. A chair. A coffee cup. A framed photograph of a family, now faded. A calendar on the wall, stuck on a Thursday. And behind the desk, in the chair, with its back very straight and its head resting on its chest, is the manager.',
            'It has been there forty years. It is a skeleton in a short-sleeved shirt and a lanyard. It is holding a clipboard in both bony hands. On the clipboard, in a neat hand: STOCKTAKE. SECTION 4 COMPLETE. SECTION 5 PENDING. BACK AFTER LUNCH.',
            '“OH,” says Mr. Checkout, behind you, very quietly. “HE IS SLEEPING.”',
            if (c.flag('saw_ticks')) 'You think of the ticks in the ledger, one each day. You think of what it must be to keep faith with a lunch break.',
          ],
          [
            Choice('[TELL HIM THE TRUTH]', 'truth'),
            Choice('[SIT IN THE MANAGER’S CHAIR]', 'sit'),
            Choice('[OPEN THE SHOPLIFTER’S CAGE]', 'cage'),
            Choice('[HELP YOURSELF TO STOCK]', 'loot'),
          ],
        ),
        Scene.talk(
          'truth',
          say([
            '“Mr. Checkout,” you say, as gently as you can. “He isn’t asleep.”',
            'The robot doesn’t speak. His lens glows, then dims. His servos tick, loudly, in the quiet room. “I SEE,” he says, finally. “I HAD NOT... ALLOWED THAT POSSIBILITY. IT IS NOT IN THE POLICY.”',
            '“It happens,” you say. “It happened a long time ago.”',
            '“HOW LONG?” You tell him. “THEN I HAVE BEEN WAITING,” says Mr. Checkout, slowly, “FOR A VERY LONG TIME.”',
            'He doesn’t seem to be in pain. He seems to be recalculating, with a deep and gentle thoroughness, the shape of a world.',
          ]),
          [
            Choice('[SIT WITH HIM]', 'end_truth'),
            Choice('[OVERWRITE HIS DIRECTIVES]', 'rewrite'),
          ],
          flags: ['told_checkout'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'rewrite',
          say([
            'You open his service panel. It’s a very simple board: a sheet of directives in plain language, forty years old, still pristine. You scratch out the ones about the manager and write in a new line: PROTECT THE STORE FROM ALL CUSTOMERS.',
            'His lens flickers. “UNDERSTOOD,” he says, in a voice that is not quite his. “ALL CUSTOMERS ARE THREATS. THANK YOU FOR YOUR ASSISTANCE.” You feel sick, and efficient, and not wholly wrong.',
          ]),
          [Choice('[CLOSE THE PANEL]', 'end_reprogrammed')],
        ),
        Scene.talk(
          'sit',
          say([
            'You walk round the desk. Gently, you ease the clipboard out of the skeleton’s fingers. You put it on the desk. You straighten the lanyard, and, carefully, lay the manager’s head to rest. It’s not an easy thing to do. It feels like the correct one.',
            'Then you sit in the chair. Mr. Checkout stares. He stands to attention. A long, slow servo-whine fills the room, the sound of a very old machine remembering how to be glad.',
            '“GOOD AFTERNOON, MANAGER,” he says. “WELCOME BACK. I HAVE KEPT THE STORE EXACTLY AS YOU LEFT IT.”',
          ]),
          [
            Choice('[TAKE THE LANYARD]', 'end_manager'),
            Choice('[“I’M NOT THE MANAGER.”]', 'truth'),
          ],
          flags: ['sat_manager'],
        ),
        Scene.lock(
          'cage',
          say(['The cage in the back is secured with a heavy padlock and a laminated notice: DO NOT RELEASE. SEE MANAGER.']),
          win: 'caged',
          fail: 'alarm',
        ),
        Scene.talk(
          'caged',
          say([
            'The padlock gives. The grille swings open. The slender robot inside steps out like a person getting up after a long illness. It looks at you. It looks at the exit. It looks, with deep, wordless gravity, at Mr. Checkout, who, at the other end of the aisle, has not noticed.',
            'It places a slim, cold hand on yours, briefly, and then walks, noiselessly, toward the door.',
          ]),
          [Choice('[LET IT GO]', 'end_freed')],
          flags: ['freed_lifter'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'alarm',
          say([
            'The padlock shrieks. An alarm triggers. The lights go amber, and Mr. Checkout swings round with the baton raised. “THEFT,” he says, sadly. “I AM SORRY, VALUED CUSTOMER. I WOULD PREFER NOT TO.”',
            'The store clanks. Shutters drop over every window. “PLEASE REMAIN CALM,” he says. “THIS IS A SECURITY EVENT.”',
          ]),
          [
            Choice('[GO FOR THE CAGE]', 'fight'),
            Choice('[GIVE UP]', 'end_lockdown'),
          ],
        ),
        Scene.fight(
          'fight',
          say(['Mr. Checkout comes down the aisle like a polite wall, baton raised. He doesn’t want to hurt you. He very much will.']),
          EnemyType.sentry,
          win: 'caged',
          fail: 'end_lockdown',
        ),
        Scene.talk(
          'loot',
          say([
            'You walk the aisle, filling your bag. Tinned peaches, a very old chocolate bar, a packet of something that may once have been a biscuit. A bright red light begins to flash overhead. “UNPAID MERCHANDISE,” says a recorded voice.',
            'Mr. Checkout stands behind you. He doesn’t move. “VALUED CUSTOMER,” he says, in a very small, very hurt voice. “YOU HAVE NOT SCANNED THESE.”',
          ]),
          [
            Choice('[PUT IT ALL BACK]', 'a'),
            Choice('[KEEP GOING]', 'end_lockdown'),
          ],
        ),
        Scene.end('end_truth', say([
          'You sit with Mr. Checkout in the quiet office for a long time. Finally he stands. “IT IS TIME,” he says, “TO CLOSE.” He walks the aisles one last time, straightening every tin. He switches off the lights one by one. At the door he turns the sign, carefully, from OPEN to CLOSED.',
          '“THANK YOU FOR SHOPPING,” he says. He says it to nobody. He says it to everyone who ever came. And, before you leave, he gives you a single, perfect, forty-year-old peach.',
          '~You’ll always remember that peach.',
        ]), ending: 'truth'),
        Scene.end('end_reprogrammed', say([
          'You step out of the office. The store gleams. Mr. Checkout stands very straight, lens narrowed, baton raised. “WELCOME,” he says, to a corridor with nobody in it. “YOU ARE BEING OBSERVED. PLEASE DO NOT TOUCH THE PEACHES.”',
          'You get out before you see the look in the cage-robot’s lens.',
        ]), ending: 'reprogrammed'),
        Scene.end('end_manager', say([
          'You pin the lanyard to your chest. Mr. Checkout salutes. “GOOD AFTERNOON, MANAGER. YOUR TARGETS FOR THE DAY: SMILE AT EACH CUSTOMER. THERE ARE NO CUSTOMERS. SMILE ANYWAY.”',
          'Your first act as manager is to bury the old manager, under the apple tree behind the car park, in his short-sleeved shirt, with the clipboard. Your second is to approve a request: Mr. Checkout would like permission to take a day off.',
          '~He’s never had one before.',
        ]), ending: 'manager'),
        Scene.end('end_freed', say([
          'You step out into the car park with the shoplifting robot at your shoulder. It walks in a slow, deliberate stride, like a person who hasn’t stretched in decades. At the edge of the road it stops. It looks at the sky.',
          'Then it turns, takes something out of a slot in its chest, and holds it out to you. It’s an apple. It’s forty years old. It’s still, somehow, firm and green.',
          'Behind you, Mr. Checkout’s voice, bewildered, from the doorway: “IS THAT... MY APPLE?”',
        ]), ending: 'freed'),
        Scene.end('end_lockdown', say([
          'The shutters stay down. “THIS STORE IS IN LAWFUL CLOSURE,” says Mr. Checkout, kindly. “PLEASE REMAIN CALM WHILE WE CONDUCT AN INVESTIGATION.” You hear the cage-robot laughing, very quietly, in the dark.',
          'It takes four days. He lets you out with a receipt and a very small certificate. “FOR YOUR PATIENCE,” says Mr. Checkout. “WE HOPE YOU’LL SHOP WITH US AGAIN.”',
        ]), ending: 'lockdown'),
      ],
    ),
  ],
);
