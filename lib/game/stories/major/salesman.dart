import '../../story_model.dart';

// THE TRAVELLING SALESMAN
// Mr. Ignatius Plume turns up in the oddest places, with a different cart
// and different stock each time. He remembers every purchase (flags
// bought.*), and every refusal. Prices are paid with Choice(needScrap).
//
// The big secret: his stock is not made. It is LOST. Everything he sells was
// once somebody’s. He is, in his own words, “the wasteland’s lost property
// office, with better hours.”
//
// Edit the shops: each meeting is a checkpoint with its own buy-scenes.
// Endings: regular, swindled, honest, partner. World facts: salesman.* and
// carry.debt.salesman (the Accountant remembers credit).

List<Choice> _shop1() => [
      Choice('[BUY THE MIRACLE TONIC: 10 SCRAP]', 'tonic', needScrap: 10, show: (c) => !c.flag('bought.tonic')),
      Choice('[BUY A JAR OF OLD AIR: 6 SCRAP]', 'jar', needScrap: 6, show: (c) => !c.flag('bought.jar')),
      Choice('[HAGGLE ABOUT THE ROCK]', 'rock', show: (c) => !c.flag('bought.rock')),
      Choice('[LEAVE]', 'leave1'),
    ];

List<Choice> _shop2() => [
      Choice('[BUY A LEFT BOOT: 4 SCRAP]', 'boot', needScrap: 4, show: (c) => !c.flag('bought.boot')),
      Choice('[BUY HANDHELD FOG: 12 SCRAP]', 'fog', needScrap: 12, show: (c) => !c.flag('bought.fog')),
      Choice('[ASK WHERE HE GETS IT ALL]', 'where', show: (c) => !c.flag('asked.where')),
      Choice('[LEAVE]', 'leave2'),
    ];

List<Choice> _shop3() => [
      Choice('[BUY SOMETHING “USEFUL”: 15 SCRAP]', 'useful', needScrap: 15, show: (c) => !c.flag('bought.useful')),
      Choice('[TAKE THE “GOLD MEMBERSHIP” ON CREDIT]', 'member', show: (c) => !c.flag('bought.member')),
      Choice('[ASK ABOUT THE TONIC]', 'tonicq', show: (c) => c.flag('bought.tonic') && !c.flag('asked.tonic')),
      Choice('[LEAVE]', 'leave3'),
    ];

final StoryDef salesmanStory = StoryDef(
  id: 'salesman',
  title: 'THE TRAVELLING SALESMAN',
  tagline: 'HE IS ALWAYS THERE WHEN YOU DON’T EXPECT HIM, AND ALWAYS HAS EXACTLY WHAT YOU DIDN’T KNOW YOU WANTED.',
  difficulty: 'LOW',
  destinationKm: 6.0,
  recommendedLevel: 1,
  intro: [
    'You are halfway through washing a spoon when someone knocks on the roof. Not on the door. The roof.',
    'A cheerful voice calls down, “Mr. Ignatius Plume, merchant! I’ve been told you’d be in the market for something!” You look up. A man in a long coat, with a tall hat and a cart on a rope, is standing on your chimney.',
    'He climbs down. He is beaming. He has the most unconvincingly trustworthy face you have ever seen. “I travel,” he says. “I turn up. You will, I promise, see me again.”',
    'He winks and vanishes down the road. You find a pamphlet in your hand. It says: PLUME’S PRODUCTS: WE HAVE WHAT YOU NEED (EVENTUALLY).',
  ],
  reward: const Reward(scrap: 100, xp: 70, stims: 1),
  endings: {
    'regular': const Ending('regular', 'A REGULAR CUSTOMER',
        'You and Mr. Plume parted as friends. He still turns up at odd moments, always with something you didn’t ask for and, grudgingly, always a little bit of use. You have a discount card. It is a leaf.',
        bonus: Reward(xp: 40, scrap: 20), world: ['salesman.regular']),
    'swindled': const Ending('swindled', 'THE BILL',
        'The bill, when it arrived, was in beautiful handwriting and in a currency you had to look up. You paid it. You will be paying it, in some way, for a long time. At least the boot was nice.',
        bonus: Reward(scrap: 30), world: ['salesman.swindled', 'debt.salesman']),
    'honest': const Ending('honest', 'LOST PROPERTY',
        'You told Mr. Plume you knew what he sold. He took off his hat. He gave you a long, careful look and, without a word, gave you back something you hadn’t realised you’d lost. Then he vanished, and no one has seen him since. Even the cart.',
        bonus: Reward(xp: 70, stims: 1), world: ['salesman.honest']),
    'partner': const Ending('partner', 'PLUME & PARTNER',
        'You bought the cart. You wear his hat now. It was the cheapest thing in the stock, and it fits. You haven’t sold a thing yet, but you have already found two people exactly what they were missing.',
        bonus: Reward(scrap: 90, parts: 1), world: ['salesman.partner']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You leave the safehouse and glance up at the roof. Nobody. You glance behind you. Nobody. You glance, finally, at the road, and there is a handbell on it, ringing.']
      : ['You walk on. Somewhere ahead, you’re certain, someone is about to try to sell you a jar of something.'],
  ambient: [
    Ambient('A handbell rings in the middle of nowhere. When you turn, there is only a coat on a hook.', maxKm: 2),
    Ambient('A chalk arrow on a rock points left. Underneath: SALE. Beneath that, in tiny writing: (NOT REALLY).', maxKm: 3),
    Ambient('You find a leaflet on the road: PLUME’S PRODUCTS: NOW WITH 30% MORE ITEMS. (IT WAS 30% LESS BEFORE.)', maxKm: 3),
    Ambient('A distant voice: “Jars! Jars of fine, mature air!” It fades. You are not sure it was a person.', minKm: 1, maxKm: 4),
    Ambient('A shoe sits upright in the road with a price tag on it: 3 SCRAP. NO REFUNDS. NO RIGHT FOOT.', minKm: 1.5, maxKm: 4),
    Ambient('You look in your pocket and find a very small, very expensive-looking receipt. You haven’t bought anything.', minKm: 2),
    Ambient('~Everything he sells is slightly familiar. You can’t say why.', minKm: 3, when: (c) => c.done('crossroads')),
    Ambient('The wheel marks of a cart appear in the dust, and, after fifty metres, vanish. The cart did not go anywhere. The marks simply stopped.', minKm: 3),
    Ambient('You pat your pocket. The jar of old air is still there. You feel oddly protective of it.', minKm: 3.5, when: (c) => c.flag('bought.jar')),
    Ambient('A tall hat, abandoned in the road, tips itself politely as you pass.', minKm: 4.5),
    Ambient('Your left boot feels warmer than the right. You have the strong impression that it was always the left.', minKm: 4.5, when: (c) => c.flag('bought.boot')),
    Ambient('~He remembers everything you bought. You’re beginning to wonder what he remembers that you didn’t.', minKm: 5),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'bell',
      title: 'THE HANDBELL',
      km: 1.0,
      text: (c) => [
        'A handbell rings from a ditch. You peer in. A very small stall has been set up on a plank. On the stall: a jar of something, a tin of something else, and a rock. A sign: BACK IN FIVE MINUTES. (FIVE MINUTES FROM NOW.)',
        'You wait. Nothing. The bell rings again, though no one is touching it. You take a step back. A hat, on a hook, tips slightly in your direction.',
        '~You’re not sure whether you have just been sold to, or merely noticed.|',
      ],
      journal: say(['A stall in a ditch with a bell that rang itself, and a sign: BACK IN FIVE MINUTES.']),
      reward: const Reward(xp: 5),
    ),
    Checkpoint(
      id: 'crossroads',
      title: 'THE CROSSROADS SHOP',
      km: 2.0,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 5, xp: 15),
      journal: (c) => [
        'Mr. Plume sold goods at a crossroads. I bought:',
        if (c.flag('bought.tonic')) 'a bottle of Miracle Tonic;',
        if (c.flag('bought.jar')) 'a jar of old air;',
        if (c.flag('bought.rock')) 'a very ordinary rock.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The crossroads has a cart. The cart has a man. The man has the face of a person who has never lied to you but wishes to be asked. “Mr. Plume!” he cries, flinging out his arms. “At your service, at your convenience, and, if it comes to it, at a modest mark-up.”',
            'The stock is laid out on a rug: a bottle of something green (MIRACLE TONIC), a jar labelled OLD AIR (AGED), and a perfectly ordinary rock with a tiny ribbon.',
            '“Everything is genuine,” says Mr. Plume. “Most things are useful. The rock is not for anything. I’m honest about the rock.”',
          ]),
          _shop1(),
        ),
        Scene.talk(
          'tonic',
          say([
            'You drink the tonic. It tastes of mint and diesel and, faintly, of grandmothers. You feel a tingling in your fingers, and a very clear idea of where your keys are. Which is a miracle, as you’ve never owned any.',
            '“It does what it says,” says Mr. Plume. “That is a promise I can make only because I haven’t said what it says.”',
          ]),
          _shop1(),
          flags: ['bought.tonic'],
          reward: const Reward(hp: 12),
        ),
        Scene.talk(
          'jar',
          say([
            'You open the jar and sniff. It is, unmistakably, air. But old air: warm, still, smelling of a kitchen you’ve never been in, with a hint of toast. For a moment you remember a morning that isn’t yours.',
            'You close the jar. You’re a bit misty. “Fresh from before,” says Mr. Plume, gently. “Best kept sealed.”',
          ]),
          _shop1(),
          flags: ['bought.jar'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'rock',
          say([
            'You pick up the rock. It is a rock. It weighs what a rock weighs. A tiny tag says: FOUND. “It’s the best rock I’ve got,” says Mr. Plume. “It’s very rock. Nobody has ever complained.”',
            '“How much?”',
            '“For you? Nothing. I couldn’t charge for it. It’s a gift. It will be useful to you in four days.”',
            'You take it. You’re fairly sure that’s how he gets you.',
          ]),
          _shop1(),
          flags: ['bought.rock'],
        ),
        Scene.end('leave1', (c) => [
          'Mr. Plume tips his hat. “A pleasure. I’ll see you again, I’m sure. I travel. I turn up.” He collapses the cart in a single motion and, by the time you look back, there’s only a smell of mint, a chalk arrow and a rock.',
          if (c.flag('bought.tonic') || c.flag('bought.jar')) '~You have the distinct feeling you’ve been very well looked after, and are about to be billed.',
        ]),
      ],
    ),
    Checkpoint(
      id: 'bridge',
      title: 'UNDER THE BRIDGE',
      km: 3.5,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 20),
      journal: (c) => [
        'I found Mr. Plume under a bridge this time, with new stock. He remembered everything I’d bought.',
        if (c.flag('bought.boot')) 'I bought a left boot. There is no right.',
        if (c.flag('bought.fog')) 'I bought a handheld fog. It does not seem to be hot or cold.',
        if (c.flag('asked.where')) 'I asked where he got it all. He changed the subject, expertly.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'You’re crossing a rusted bridge when a voice calls from beneath: “Ahoy! Up here! Well, down here! Mr. Plume, merchant!” He’s hanging from a girder, upside-down, with his cart tied to the rail and the stock arranged on a very long scarf.',
            if (c.flag('bought.tonic')) '“How’s the stomach? Any minty burps? Wonderful. That means it’s working.”',
            if (c.flag('bought.rock')) '“And the rock? Has it been useful yet? Not yet? It will be. It’s very patient.”',
            if (!c.flag('bought.tonic') && !c.flag('bought.jar') && !c.flag('bought.rock')) '“You didn’t buy anything last time. Very restrained. I admire it. I also have a quota.”',
            'Today’s stock: a single left boot, a handheld cloud of fog in a pouch, and, in a locked case, nothing you can see.',
          ],
          _shop2(),
        ),
        Scene.talk(
          'boot',
          say([
            'It’s a left boot. It fits you better than your own. There’s a name inside the tongue, scratched out, and underneath, a single word: SORRY.',
            '“Where’s the right?” you ask. “Oh,” says Mr. Plume, “somebody’s wearing it. Somewhere. I don’t like to pry.”',
          ]),
          _shop2(),
          flags: ['bought.boot'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'fog',
          say([
            'You open the pouch. A small, grey, thoughtful cloud rises out, hangs in the air, and arranges itself, shyly, into the shape of a very small dog. It looks at you for a moment, wags, and drifts back into the pouch.',
            '“It’s very good in a pinch,” says Mr. Plume. “Mostly it just wants company.”',
            'Somewhere deep in your pack, a tiny cloud sighs.',
          ]),
          _shop2(),
          flags: ['bought.fog'],
          reward: const Reward(hp: 8, xp: 6),
        ),
        Scene.talk(
          'where',
          say([
            '“Where do you get it all?” you ask. “The jars, the boots. The fog.”',
            'Mr. Plume pauses. For the first time, his smile has to be put on again. “Oh,” he says. “Here and there. You know. Wherever it’s... available.”',
            '“It’s lost property, isn’t it.”',
            '“It’s,” he says, “a business model.” He swings his legs round the girder and attaches a new, very bright smile. “Now! Care for a fog?”',
          ]),
          _shop2(),
          flags: ['asked.where', 'suspects_lost'],
          reward: const Reward(xp: 10),
        ),
        Scene.end('leave2', say([
          'You step back onto the bridge. When you look down, there’s only a rope and a rock. Then the rock waves.',
          '“See you soon!” it says, in Mr. Plume’s voice. “I’ll be somewhere unexpected!”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'bank',
      title: 'THE VAULT',
      km: 4.8,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 25),
      journal: (c) => [
        'The third time I met Mr. Plume, he was inside a bank vault, selling a “gold membership.” He called me by my first name, which I had not told him.',
        if (c.flag('bought.member')) 'I took out a membership on credit.',
        if (c.flag('bought.useful')) 'I bought something “useful.” It was.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The old bank is a shell of marble and brass. At the back is a huge vault door, open, and from inside it comes a cheerful, echoing: “Come in, come in! Mr. Plume, merchant, and, today, financial adviser!”',
            'He sits behind a desk, in a pinstripe jacket over his coat, with his hat on a stand. The stock has gone, replaced with a stack of forms, a leather-bound ledger and a single bottle.',
            '“Welcome back,” he says. “I’ve prepared you a membership. It’s the Gold. It’s very exclusive. It has two members.”',
            if (c.flag('bought.fog')) 'A very small cloud, in your pack, shrinks as far from the desk as it can go.',
          ],
          _shop3(),
        ),
        Scene.talk(
          'useful',
          say([
            'Mr. Plume lays something on the desk: a compass with a needle that doesn’t point north. “It points,” he says, “where you need to go.” You take it. It settles on a bearing. It is, by absolutely no reasonable standard, a useful thing.',
            'It’s also the only thing he’s sold you that came with instructions.',
          ]),
          _shop3(),
          flags: ['bought.useful'],
          reward: const Reward(scrap: 10, xp: 12),
        ),
        Scene.talk(
          'member',
          say([
            '“Splendid!” says Mr. Plume. He stamps the form with a leaf. “Gold Membership. Entitles you to a discount, a loyalty point and the unwavering regard of a man in a hat. Payment is deferred.”',
            '“Deferred until when?”',
            '“Until it’s convenient,” says Mr. Plume. He smiles, very warmly. “I never forget.”',
          ]),
          _shop3(),
          flags: ['bought.member', 'carry.debt.salesman'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'tonicq',
          say([
            '“What’s in the tonic?” you ask. Mr. Plume’s smile goes distant. “Mint, diesel, a bit of someone’s grandmother. It’s sourced locally. Don’t think about it too hard.”',
            '“What did you really sell me?”',
            '“A feeling,” says Mr. Plume. “It had been left behind. By a woman who was sick for a very long time, and who, at the end, felt, for a minute, better. It’s hers. It’s yours now. Please use it kindly.”',
          ]),
          _shop3(),
          flags: ['asked.tonic'],
          reward: const Reward(xp: 12),
        ),
        Scene.end('leave3', say([
          'You step out of the vault. Behind you, the great door swings shut, slowly. “Next time,” says a muffled voice, “I’ll have something very special.” And then, much more quietly, as if to himself: “I always do.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'last',
      title: 'THE LAST SALE',
      km: 6.0,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 40),
      journal: (c) => ['The last time, Mr. Plume told me where his stock comes from. I had to decide what to do about it.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The last meeting is on a hill at dusk. A cart stands alone on the ridge, lit by a single lantern. Mr. Plume sits on it, hat in his lap, with a trunk open beside him.',
            'The trunk holds everything. Not stock. Everything. Every item he’s ever sold: boots, jars, keys, a child’s mitten, a tooth, a wedding ring, a letter, a good luck charm. It’s the weight of a hundred small losses. It glows, faintly, like embers.',
            '“I’m not a merchant,” says Mr. Plume, quietly. “Not really. I’m the wasteland’s lost property office. Everything lost in the war went somewhere. I find it. I return it, if I can. If I can’t, I sell it to someone who needs it.”',
            if (c.flag('suspects_lost')) '“You guessed,” he says, with a small smile. “You always do, the clever ones.”',
            if (c.flag('bought.member')) '“Now. About the membership...”',
          ],
          [
            Choice('[“I KNEW. THANK YOU.”]', 'honest'),
            Choice('[BUY THE WHOLE CART]', 'cart'),
            Choice('[PAY OFF YOUR CREDIT]', 'pay', show: (c) => c.flag('bought.member')),
            Choice('[SHAKE HIS HAND AND GO]', 'end_regular'),
          ],
        ),
        Scene.talk(
          'honest',
          say([
            'You tell him you know. All of it. The lost things. The kindness under the sales pitch. Mr. Plume listens with his hat clasped to his chest. His eyes are very bright.',
            '“No one’s ever said that,” he says. “Forty years. They only ever asked how much.”',
            'He reaches into the trunk, rummages, and brings out something small and wrapped in cloth. “This is yours,” he says. “I’ve had it a while. I wasn’t sure you’d want it.” You unwrap it. It’s a photograph. It’s of someone you thought you’d never see again.',
          ]),
          [Choice('[HOLD IT]', 'end_honest')],
          flags: ['told_plume'],
          reward: const Reward(xp: 25),
        ),
        Scene.talk(
          'cart',
          say([
            '“The whole cart,” you say. Mr. Plume freezes. “It’s a big commitment,” he says. “It’s not just the stock. It’s the road. It’s the hat. It’s the habit of being somewhere that nobody expects. You’d have to carry a great many people’s losses.”',
            '“I can do that,” you say. “I’ve been doing it for years.”',
            'He gives you a long, tender look. “I thought you might.” Then, with infinite care, he takes off his hat.',
          ]),
          [
            Choice('[TAKE THE HAT]', 'end_partner'),
            Choice('[SAY YOU WERE JOKING]', 'end_regular'),
          ],
        ),
        Scene.talk(
          'pay',
          say([
            'You ask to settle. Mr. Plume produces the ledger. The bill is long, and in a cramped, elegant hand. You read it. It includes the tonic, the membership and, at the bottom, in a single line: ONE (1) HOUR OF YOUR TIME, TO BE SPENT SITTING WITH A STRANGER.',
            '“Was that a joke?” you ask. “No,” says Mr. Plume. “That’s what I charge for everything. It’s what we all owe each other.”',
          ]),
          [
            Choice('[SIT WITH HIM]', 'end_regular'),
            Choice('[REFUSE TO PAY]', 'end_swindled'),
          ],
        ),
        Scene.end('end_regular', (c) => [
          'You shake hands. His palm is warm and a little dusty. “I’ll see you around,” he says. “I turn up.”',
          'He packs the trunk, hums, and walks off down the hill, with the cart bobbing behind him like a happy dog. At the crest, he turns and tips his hat. You tip your own back. You’re not wearing one. It doesn’t matter.',
          if (c.flag('bought.rock')) 'In your pocket, the rock grows slightly warm. It has, apparently, been useful.',
        ], ending: 'regular'),
        Scene.end('end_swindled', say([
          'You decline. Mr. Plume nods, writes something in the ledger, and shuts it with a very final snap. “Of course,” he says, kindly. “I’ll send you the bill.”',
          'It arrives the next morning, in an envelope with a leaf for a stamp. The amount is not in scrap. It’s in a currency you’ll learn the name of, in time. You pay it. It takes a long while.',
          'The boot, you note, remains very comfortable.',
        ]), ending: 'swindled'),
        Scene.end('end_honest', say([
          'You look up from the photograph and the hill is empty. The cart is gone. The lantern is gone. There’s only the faint smell of mint and the sound of a very small bell, ringing from over the next ridge.',
          'Nobody ever sees Mr. Plume again. But every so often, someone finds something they thought they’d lost, on a doorstep, in a pocket, tied to a gate. And there is never a bill.',
        ]), ending: 'honest'),
        Scene.end('end_partner', say([
          'The hat is a little big. It fits anyway. Mr. Plume steps down off the cart like a man laying down a very heavy coat. “It’s all yours,” he says. “The cart, the trunk, the road.”',
          'He walks off into the dusk, lighter than you’ve ever seen him. You sit on the cart for a long time with the trunk glowing at your feet. Then, with great care, you pick up the first thing, a child’s mitten, and set out to find the right hand.',
        ]), ending: 'partner'),
      ],
    ),
  ],
);
