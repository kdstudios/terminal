import '../../story_model.dart';
import '../characters/gary.dart';

// GARY’S OTHER PROBLEM
// Follow-up to Gary’s Problem. Gary’s troubles become progressively more
// ridiculous; how he treats you depends on whether you helped, lied to,
// teased or ignored him (Gary.mood). Not the bunker Garys.
// Endings: solved, worse, together.

final StoryDef shoesReturnStory = StoryDef(
  id: 'shoes_return',
  title: 'GARY’S OTHER PROBLEM',
  tagline: 'THE SHOES ARE FINE NOW. THE HAT IS HAVING A DIFFICULT WEEK.',
  difficulty: 'LOW',
  destinationKm: 1.3,
  recommendedLevel: 2,
  scale: StoryScale.short,
  unlock: const Unlock(anyDone: ['shoes'], hint: 'FINISH GARY’S PROBLEM FIRST.'),
  intro: ['A man in two matching boots, a bowler hat and an expression of grave concern is standing in the middle of the road. When he sees you he waves with both arms and shouts, “GARY! IT’S GARY! I’VE GOT A NEW ONE!”'],
  reward: const Reward(scrap: 50, xp: 40),
  endings: {
    'solved': const Ending('solved', 'THE HAT MYSTERY, SOLVED',
        'It was a crow. It had been wearing the hat on Tuesdays. You returned the hat, and agreed to a timetable, and Gary and the crow, in an unexpected development, are friends. The crow gets the hat on Tuesdays. Gary gets it the rest of the week.',
        bonus: Reward(xp: 25), world: ['gary.ridiculous', 'gary.helped']),
    'worse': const Ending('worse', 'IT’S GETTING WORSE',
        'You did not solve it. Gary’s problem has grown. It is now, as of this morning, “the whole outfit.” He has been seen conversing with his trousers. He is, to be fair, in excellent spirits.',
        bonus: Reward(scrap: 20), world: ['gary.ridiculous']),
    'together': const Ending('together', 'ONE SHOE EACH',
        'You and Gary agreed to swap one shoe each. It was the nicest thing anyone’s ever offered him. You walk, now, with one boot and one slipper. It’s very comfortable. It’s, you have to admit, rather freeing.',
        bonus: Reward(xp: 30, stims: 1), world: ['gary.ridiculous', 'gary.helped', 'favour.gary']),
  },
  depart: (c) => [...Gary.greeting(c)],
  ambient: [
    Ambient('A bowler hat sits in the road with a note: NOT ME. (THIS IS A HAT.)', maxKm: 0.8),
    Ambient('A crow on a post is wearing something that looks suspiciously like a tiny top hat.', maxKm: 1),
    Ambient('~Every problem has a cause. It’s only occasionally one you’d have guessed.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'road',
      title: 'GARY, AGAIN',
      km: 0.6,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => ['Gary’s new problem: his hat keeps moving. Only on Tuesdays.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...Gary.greeting(c),
            '“It’s the hat,” he says, with enormous, trembling solemnity. “It moves. Every Tuesday. I put it on the peg. It goes. I find it in a tree, or on a rock. I’ve checked the peg. I’ve checked the tree. I’ve asked the rock. I think,” he whispers, “it’s alive.”',
          ],
          [
            Choice('[HEAR HIM OUT]', 'out'),
            Choice('[SUGGEST A STAKEOUT]', 'stake'),
            Choice('[SAY IT’S THE WIND]', 'wind'),
          ],
        ),
        Scene.talk('out', say(['Gary tells you everything: the dates, the places, the exact angle of each landing. He’s kept a diary. It’s eleven pages. It’s beautifully drawn. “Look,” he says. “Each Tuesday, it’s a little further east.”']), [Choice('[CONTINUE]', 'end_r')], flags: ['heard_diary']),
        Scene.talk('stake', say(['“A stakeout,” says Gary, breathless. “I’ve always wanted one.” He produces a flask, a tent and eleven sandwiches. “I’ll be the bait. You be the, er, surveillance.” He puts the hat on a rock and sits beside it. He is already, visibly, thrilled.']), [Choice('[CONTINUE]', 'end_r')], flags: ['stakeout']),
        Scene.talk('wind', say(['“It’s only the wind,” you say. Gary stares. “It’s not the wind,” he whispers. “It’s a Tuesday.” He puts a hand on his hat. “It knows.”']), [Choice('[CONTINUE]', 'end_r')], flags: ['wind']),
        Scene.end('end_r', say(['Gary pulls his hat down firmly over his ears. “It’s Tuesday,” he says. “It’s now or never.” He sets off down the road, in two matching boots, like a man going to war.'])),
      ],
    ),
    Checkpoint(
      id: 'tuesday',
      title: 'TUESDAY',
      km: 1.3,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['The hat is taken by a crow. A very polite crow.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'At noon exactly, a large crow drops out of a tree, plucks the hat from Gary’s head with a delicate, practised beak and flaps off. Gary shouts. He gives chase. You follow. You find the crow in a hawthorn, with a tiny nest of hats: bowlers, trilbies, one cap, a very small fez.',
            'The crow regards you. “Caw,” it says, politely. It sets the hat down, carefully, in the middle of the nest.',
          ]),
          [
            Choice('[NEGOTIATE WITH THE CROW]', 'neg'),
            Choice('[OFFER ONE SHOE EACH]', 'together', show: (c) => c.flag('heard_diary') || c.flag('stakeout')),
            Choice('[LEAVE GARY TO IT]', 'worse'),
          ],
        ),
        Scene.talk('neg', say(['You hold out a hand, palm up. The crow considers. “We’ll share it,” you say. “Tuesdays for you. The rest for Gary.” The crow looks at you for a long time. It takes the hat, puts it on, and gives you the most solemn nod a bird has ever given anyone.']), [Choice('[CONTINUE]', 'end_solved')]),
        Scene.talk('together', say(['Gary looks at your boots, then at his own. “One each?” he says. “Really?” He takes off his left boot. You take off your right. You swap, solemnly. He puts on your boot and weeps. “I’ve never had a friend,” he says, “who’d swap a shoe.”']), [Choice('[CONTINUE]', 'end_together')]),
        Scene.talk('worse', say(['You leave. Gary, behind you, turns to the crow. “Right,” he says. “Man to man.” The crow, you gather, is not impressed. The last you see of them they are both facing each other in silence, in the late afternoon sun, with a hat between them.']), [Choice('[CONTINUE]', 'end_worse')]),
        Scene.end('end_solved', say(['Gary is beaming. The crow, with the hat on its head, looks like a very small, very dignified bishop. “Tuesdays,” says Gary. “It’s Tuesday. Of course it is.” He pats the crow, which allows it. It’s the first time his problem has solved itself.']), ending: 'solved'),
        Scene.end('end_worse', say(['It’s a clean, sad ending. Gary stands in the road, with no hat, and one boot. “Well,” he says, with immense, patient dignity. “It’s a start.” He is already making notes.']), ending: 'worse'),
        Scene.end('end_together', say(['You walk away, side by side, each in one boot and one borrowed boot. Gary, humming. You, deeply, strangely content. A very long way off, a crow settles in a tree and puts on a hat. Nobody sees.']), ending: 'together'),
      ],
    ),
  ],
);
