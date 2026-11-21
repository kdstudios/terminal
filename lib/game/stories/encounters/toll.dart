import '../../story_model.dart';

// THE TOLL COLLECTOR
// A man named Mr. Brindle insists on a toll to cross a bridge that collapsed
// years ago. The toll is legally required. Endings: paid, fined, bought.

List<Choice> _boothChoices() => [
      Choice('[POINT OUT THE BRIDGE IS GONE]', 'b_gone', show: (c) => !c.flag('seen.gone')),
      Choice('[ASK TO SEE THE LAW]', 'b_law', show: (c) => !c.flag('seen.law')),
      Choice('[ASK WHAT THE TOLL BUYS]', 'b_buys', show: (c) => !c.flag('seen.buys')),
      Choice('[DEAL WITH THE TOLL]', 'b_act'),
    ];

final StoryDef tollStory = StoryDef(
  id: 'toll',
  title: 'THE TOLL COLLECTOR',
  tagline: 'THE BRIDGE FELL DOWN YEARS AGO. THE TOLL DID NOT.',
  difficulty: 'LOW',
  destinationKm: 1.4,
  recommendedLevel: 1,
  scale: StoryScale.short,
  intro: [
    'A little tollbooth stands on the edge of a very large, very empty gorge. A man in a peaked cap sits inside with a ledger. Beyond him, a ravine falls away, and on the far side, a stub of rusted bridge, like a broken finger.',
  ],
  reward: const Reward(scrap: 40, xp: 35),
  endings: {
    'paid': const Ending('paid', 'RECEIPT NO. 4,412',
        'You paid the toll. Mr. Brindle stamped your hand, wished you a safe crossing and watched you walk, with great dignity, along the edge of the gorge until you reached the road. It is the most legitimate transaction of your career.',
        bonus: Reward(xp: 10), world: ['toll.paid']),
    'fined': const Ending('fined', 'A MOST SERIOUS INFRACTION',
        'You cited Mr. Brindle for failure to maintain a bridge, and he gave himself a fine. It was for a considerable sum. He paid it with great, rueful courtesy, out of the till, to you.',
        bonus: Reward(scrap: 60), world: ['toll.fined']),
    'bought': const Ending('bought', 'THE BRIDGE IS YOURS',
        'You bought the bridge. The deed is a handwritten note. You now own a gorge, a stub of metal, and a very small hut. Mr. Brindle has stayed on, as the toll collector, on a generous salary of nothing.',
        bonus: Reward(xp: 30), world: ['toll.bought']),
  },
  depart: (c) => ['You hear the clink of a ledger before you see the booth. Somebody is counting coins that don’t exist.'],
  ambient: [
    Ambient('A sign: TOLL AHEAD. PLEASE HAVE EXACT CHANGE. PLEASE HAVE A BRIDGE.', maxKm: 1),
    Ambient('A tin cup on a post, labelled TOLL (HONESTY). It contains a single, extremely nervous beetle.', maxKm: 1),
    Ambient('~There are laws that have outlived the things they were for. This is a very small example.', minKm: 0.5),
  ],
  checkpoints: [
    Checkpoint(
      id: 'booth',
      title: 'THE BOOTH',
      km: 0.7,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 5, xp: 10),
      journal: (c) => [
        'Mr. Brindle, toll collector, insists that crossing the collapsed bridge still requires a toll.',
        if (c.flag('seen.law')) 'He showed me the statute. It’s a laminated sandwich wrapper.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            '“Toll,” says the man, without looking up. He is thin, stiff, perfectly pressed. “Crossing the bridge requires a toll. It’s two scrap, one way, three scrap return. I’ll give you a receipt.”',
            'You look at the gorge. You look at the bridge. The bridge isn’t there. A single steel rib sticks out of the cliff, like a diving board for ghosts.',
            '“It’s a very fine bridge,” says Mr. Brindle, firmly. “Do you intend to pay?”',
          ]),
          _boothChoices(),
        ),
        Scene.talk(
          'b_gone',
          say([
            '“The bridge is gone,” you say. “It fell down.” Mr. Brindle puts down his pen. “It has been temporarily relocated,” he says. “To the bottom. It may be a question of perspective.”',
            '“It’s in pieces.”',
            '“It’s in an advanced state of decentralisation,” says Mr. Brindle. “The toll remains in force.”',
          ]),
          _boothChoices(),
          flags: ['seen.gone'],
        ),
        Scene.talk(
          'b_law',
          say([
            'He produces a laminated statute. It’s the wrapper of a sandwich. It reads, in biro: BY ORDER OF THE COUNTY: ALL BRIDGES MUST BE PAID FOR, WHETHER OR NOT THEY EXIST. SIGNED, A. BRINDLE.',
            '“Where’s the county?” you ask. “I’m the county,” says Mr. Brindle. “I’m also the bridge. And the toll. And the cap.” He adjusts it, with dignity. “One has to be everything, in a small administration.”',
          ]),
          _boothChoices(),
          flags: ['seen.law'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'b_buys',
          say([
            '“What does the toll buy me?” “A crossing,” says Mr. Brindle. “And the safety of a legitimate transaction. And, if you wish, a very good view of the gorge.” He smiles for the first time. “It’s quite spectacular. Nobody has ever fallen in it who hadn’t paid.”',
          ]),
          _boothChoices(),
          flags: ['seen.buys'],
        ),
        Scene.talk(
          'b_act',
          say(['Mr. Brindle waits, pen poised, with the patience of a man who has outlasted weather. You have, as far as you can tell, three options.']),
          [
            Choice('[PAY THE TOLL]', 'pay'),
            Choice('[FINE HIM FOR NO BRIDGE]', 'fine'),
            Choice('[BUY THE BRIDGE]', 'buy'),
          ],
        ),
        Scene.end('pay', say(['You hand over two scrap. He gives you a receipt, a stamp and a salute. You walk, carefully and with enormous dignity, along the lip of the gorge, to the stub of the bridge on the other side. Nothing is crossed. Everything is in order.'])),
        Scene.end('fine', say(['“Failure to maintain a bridge,” you say, in your most official voice. “That’s a very serious offence. Section nine.” Mr. Brindle goes white. He opens the ledger. He turns to section nine. It is, you realise, a section he wrote.'])),
        Scene.end('buy', say(['“I’ll buy it,” you say. “The bridge. The gorge. All of it.” Mr. Brindle stares. “It’s a very good bridge,” he whispers. “It’s a very fine bridge. It’s never had an offer.”'])),
      ],
    ),
    Checkpoint(
      id: 'gap',
      title: 'THE CROSSING',
      km: 1.4,
      art: 'wreck',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 15),
      journal: (c) => ['The crossing itself, such as it was.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            if (!c.flag('seen.law')) 'You step toward the lip of the gorge.',
            'Mr. Brindle stands beside you. Together you look at the gap. It is forty metres wide. It is a long way down. It is, you have to admit, a very impressive gorge.',
            '“Now,” he says. “The question of how you intend to cross.”',
          ],
          [
            Choice('[PAY AND WALK THE EDGE]', 'end_paid'),
            Choice('[FINE HIM FOR THE BRIDGE]', 'end_fined'),
            Choice('[BUY THE BRIDGE]', 'end_bought'),
          ],
        ),
        Scene.end('end_paid', say([
          'You hand him the scrap. He stamps your hand. You walk the ledge of the gorge, with the toll collector watching, to the far end of the road. A tiny, polite figure on the other side raises its cap. You raise yours back. It’s not clear who’s more satisfied.',
        ]), ending: 'paid'),
        Scene.end('end_fined', say([
          'Mr. Brindle writes a fine. It’s a very good fine, in a very official hand, with a wax seal. He reads it aloud, with a grave, rising voice. Then he signs it, turns to the till, counts out a considerable sum and places it in your palm. “I’ll appeal,” he says. “Of course.”',
        ]), ending: 'fined'),
        Scene.end('end_bought', say([
          'You buy it for fifty scrap and a promise. Mr. Brindle writes the deed on a napkin. The ceremony takes a full hour. He cries, quietly, at the end. “I’ve never had an owner,” he says. “It’s like being adopted.”',
        ]), ending: 'bought'),
      ],
    ),
  ],
);
