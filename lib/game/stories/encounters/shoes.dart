import '../../story_model.dart';
import '../characters/gary.dart';

// GARY’S PROBLEM
// Gary (the survivor, not any bunker Gary) believes something keeps stealing
// his shoes. Suspects: mole rats, thieves, ghosts, something stranger. The
// truth: a family of mole rats has been using his shoes as a nursery.
//
// Endings: helped, teased, lied, refused. World: gary.* + favour.gary / debt.gary.
// Follow-up: encounters/shoes_return.dart

List<Choice> _garyChoices() => [
      Choice('[ASK WHAT HAS BEEN TAKEN]', 'm_list', show: (c) => !c.flag('seen.list')),
      Choice('[ASK WHO HE SUSPECTS]', 'm_who', show: (c) => !c.flag('seen.who')),
      Choice('[SIZE UP HIS FEET]', 'm_feet', show: (c) => !c.flag('seen.feet')),
      Choice('[DECIDE WHAT TO DO]', 'm_act'),
    ];

final StoryDef shoesStory = StoryDef(
  id: 'shoes',
  title: 'GARY’S PROBLEM',
  tagline: 'SOMEBODY IS STEALING GARY’S SHOES. ONLY THE LEFT ONES. HE HAS A THEORY. HE HAS SEVERAL.',
  difficulty: 'LOW',
  destinationKm: 1.8,
  recommendedLevel: 1,
  scale: StoryScale.short,
  intro: [
    'A man in odd socks is standing in the middle of the road with his arms spread, as though to stop a train. “Excuse me!” he cries. “I’m Gary! Have you seen my shoe? It’s brown. It’s a bit... shoe-shaped.”',
  ],
  reward: const Reward(scrap: 50, xp: 40),
  endings: {
    'helped': const Ending('helped', 'THE SHOE WHISPERER',
        'You found the real culprit and solved the problem without hurting anyone. Gary hugged you for a long, unembarrassed time. He has since taken up a hobby. It is called “knowing where his shoes are.”',
        bonus: Reward(xp: 20), world: ['gary.helped', 'gary.shoes_solved', 'favour.gary']),
    'teased': const Ending('teased', 'THE LAUGHING ONE',
        'You made fun of Gary for the better part of an hour. He took it with enormous good grace and went away to cry in a ditch. He has not forgotten it. Neither has the ditch.',
        bonus: Reward(), world: ['gary.teased']),
    'lied': const Ending('lied', 'THE MOLE-RAT CARTEL',
        'You told Gary there was a mole-rat cartel and gave him a map. He is now very busy. He has bought string. He has a cork board. It is the most useful, most harmful thing you’ve ever done for a person.',
        bonus: Reward(scrap: 20), world: ['gary.lied', 'debt.gary']),
    'refused': const Ending('refused', 'NOT YOUR PROBLEM',
        'You told Gary it wasn’t your problem. He accepted it with a small, sad nod. “That’s fair,” he said. “It really is mine.” He watched you go, in one boot and one sock.',
        bonus: Reward(), world: ['gary.refused']),
  },
  depart: (c) => [...Gary.greeting(c).take(0), 'You walk toward the sound of a man calling, quite politely, at a distant crow.'],
  ambient: [
    Ambient('A single brown shoe lies in the road, perfectly upright, as though somebody had just stepped out of it.', maxKm: 1),
    Ambient('You pass a hand-lettered sign: IF YOU FIND A LEFT SHOE, PLEASE RETURN TO GARY. NO QUESTIONS. (SEVERAL QUESTIONS.)', maxKm: 1.5),
    Ambient('A mole rat pops out of a hole, takes one look at you, and hurries back with a stolen sock.', minKm: 0.5),
    Ambient('~A man with a lot of bad luck is a man with a lot of stories. This is one of them.', minKm: 1),
  ],
  checkpoints: [
    Checkpoint(
      id: 'meet',
      title: 'GARY’S YARD',
      km: 0.9,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 5, xp: 10),
      journal: (c) => [
        'Gary lives in a lean-to full of odd shoes. He has lost forty-one, found three, and has a theory about every one.',
        if (c.flag('seen.who')) 'His suspects: mole rats, thieves, a ghost called Barry, and “something stranger.”',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...Gary.greeting(c),
            'His yard is a heap of cardboard, a lean-to and a very large number of single shoes, all arranged, with great ceremony, on shelves. There is a plate for each one. A small sign reads: THE MUSEUM OF WHAT I HAVE LOST.',
          ],
          _garyChoices(),
        ),
        Scene.talk(
          'm_list',
          say([
            '“Forty-one,” says Gary, proudly. “All left. The right ones stay. It’s a bit like they’re being picked on. I’ve had six boots, three slippers, a wellington, and a ballet shoe I was never even sure was mine.”',
            '“A ballet shoe?”',
            '“It was a gift,” says Gary, a bit defensively. “From a friend. It was very supportive.”',
          ]),
          _garyChoices(),
          flags: ['seen.list'],
        ),
        Scene.talk(
          'm_who',
          say([
            '“Mole rats,” he says at once. “Or thieves. Or a ghost called Barry. Or...” He lowers his voice. “Something stranger.”',
            '“Stranger than a ghost called Barry?”',
            '“Barry is a very average ghost,” says Gary, with dignity. “It’s the something stranger I’m worried about. I haven’t named it. It might hear.”',
          ]),
          _garyChoices(),
          flags: ['seen.who'],
        ),
        Scene.talk(
          'm_feet',
          say([
            'You look at his feet. He’s wearing one boot, one slipper, and a sock with a hole in the shape of a country. “Do you wear them out?” you ask. “Do you leave them somewhere?”',
            '“I’m very careful,” says Gary. “I put them next to the bed every night. Side by side. I tuck them in.” A pause. “I’ve started reading to them. It doesn’t help.”',
            'Around the edge of his mat, you notice tiny, tidy scratch marks, and a long, dark, round hole.',
          ]),
          _garyChoices(),
          flags: ['seen.feet', 'saw_hole'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'm_act',
          say([
            'Gary looks at you with such open hope that it’s almost alarming. “Will you help?” he says. “I’d do it myself, but every time I try, I lose another shoe.”',
          ]),
          [
            Choice('[“I’LL STAKE OUT YOUR BED.”]', 'help', flags: ['will_help']),
            Choice('[“IT’S MOLE RATS, DEFINITELY.” (LIE)]', 'lie', flags: ['will_lie']),
            Choice('[LAUGH AT HIM]', 'tease', flags: ['will_tease']),
            Choice('[“NOT MY PROBLEM.”]', 'refuse', flags: ['will_refuse']),
          ],
        ),
        Scene.end('help', say(['“Oh, thank you,” says Gary, and, to your alarm, bursts into tears. “Nobody’s ever offered. They always say it’s only shoes.” He wipes his nose on his sleeve. “It’s never only shoes.”'])),
        Scene.end('lie', say(['“A cartel,” you say, solemnly. “Mole rats. Organised. Very well funded.” Gary goes pale. “I knew it,” he says. “I KNEW it.” He starts to draw a map, on his arm, in biro.'])),
        Scene.end('tease', say(['“Forty-one shoes?” you say. “Maybe you’re just bad at shoes.” You do an impression of a man walking out of a shoe. You do it well. Gary stares at you. His lip trembles. “That’s,” he says, “not very nice.”'])),
        Scene.end('refuse', say(['“Not my problem,” you say. Gary nods slowly. “Right,” he says. “No, that’s fair.” He looks at his feet. “It’s just, it’s a very big problem. It’s about eight shoes high.”'])),
      ],
    ),
    Checkpoint(
      id: 'night',
      title: 'THE STAKEOUT',
      km: 1.8,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 20),
      journal: (c) => [
        if (c.flag('will_help')) 'I staked out Gary’s bed. At three in the morning, a very small procession emerged from the floor.',
        if (c.flag('will_lie')) 'I told Gary about a mole-rat cartel. He drew up a battle plan.',
        if (c.flag('will_tease')) 'I teased Gary. He took notes.',
        if (c.flag('will_refuse')) 'I told Gary it was not my problem.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            if (c.flag('will_help'))
              'You lie awake in Gary’s lean-to. At three in the morning there’s a scrabbling under the floor. A neat hole opens. Out come seven tiny mole rats in a line, one behind the other, and with a sort of professional courtesy, they lift Gary’s left slipper and carry it down the hole. You follow with a torch.',
            if (c.flag('will_lie'))
              'Gary spends the night drawing arrows. By morning he has traced a conspiracy involving thirty-one mole rats, a union and a vicar. He is very proud of it. He gives you a copy, signed.',
            if (c.flag('will_tease'))
              'You spend an hour making Gary demonstrate each lost shoe. By the end, he’s sitting in the dust, quiet, with a tiny muddy boot in his lap.',
            if (c.flag('will_refuse'))
              'You walk off. Behind you, a long scrabbling from Gary’s yard, a shout, and a tiny, tragic “Not again.”',
          ],
          [
            Choice('[FOLLOW THE MOLE RATS]', 'follow', show: (c) => c.flag('will_help')),
            Choice('[PUT UP THE MAP]', 'map', show: (c) => c.flag('will_lie')),
            Choice('[GIVE HIM A BIT OF A HUG]', 'tease_end', show: (c) => c.flag('will_tease')),
            Choice('[KEEP WALKING]', 'refuse_end', show: (c) => c.flag('will_refuse')),
          ],
        ),
        Scene.talk(
          'follow',
          say([
            'The hole leads to a warm, shadowy burrow stuffed with leather, felt and slippers. In the middle, in a nest of single shoes, is a mother mole rat with seven pink, squeaking pups. A tiny brown boot is her cradle. A ballet shoe is a bassinet.',
            'She looks up at you. She doesn’t run. She’s too tired. She’s been collecting shoes for the whole of the winter. The pups have grown fat in them.',
            '~It was never a cartel. It was a family.',
          ]),
          [
            Choice('[TELL GARY GENTLY]', 'end_helped'),
            Choice('[LEAVE THEM AND LIE TO GARY]', 'end_lied'),
          ],
          reward: const Reward(xp: 15),
        ),
        Scene.talk('map', say(['You pin the map to the wall. Gary salutes it. You consider, briefly, the shape of a man’s hope and the cost of corking it. Then you consider the string.']), [Choice('[LEAVE HIM TO IT]', 'end_lied')]),
        Scene.talk('tease_end', say(['You pat Gary’s shoulder, awkwardly. He sniffs. “Thanks,” he says. “It’s just, it’s always been like this.” He watches you leave with the face of a man who has been laughed at, and is working out how to forgive it.']), [Choice('[WALK AWAY]', 'end_teased')]),
        Scene.talk('refuse_end', say(['You keep walking. You don’t look back. It’s only a few shoes. It’s only a man. It’s only an afternoon.']), [Choice('[WALK AWAY]', 'end_refused')]),
        Scene.end('end_helped', say([
          'You bring Gary down into the burrow. He crawls in on his stomach with a torch in his mouth. For a long time he says nothing. Then, quietly, “Oh.” He looks at the mother. She looks at him. “They’re very small,” he says. “I thought something was after me.”',
          'He leaves them the shoes. He buys himself a new pair, both feet, and, as a mark of respect, names a pup after each of his missing ones. “I’ve got forty-one nephews,” he says, with a watery smile.',
        ]), ending: 'helped'),
        Scene.end('end_lied', say([
          'You don’t tell him. You say it’s a cartel, and a very organised one, and that he’ll need a lot of string. Gary nods gravely and starts to pace. “Right,” he says. “Right. I’ll write to the council.”',
          'You leave him there, pinning strings to a map of nothing. He has never been happier. It’s the worst thing you’ve ever done for someone.',
        ]), ending: 'lied'),
        Scene.end('end_teased', say(['The last you see of Gary, he’s sitting beside his lean-to with a boot in his lap, humming, very quietly, a hymn to nobody. He doesn’t wave.']), ending: 'teased'),
        Scene.end('end_refused', say(['Over the next ridge, a long way off, you hear a very small cry: “Not that one! That’s my good one!” You keep going.']), ending: 'refused'),
      ],
    ),
  ],
);
