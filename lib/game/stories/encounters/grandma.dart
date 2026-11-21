import '../../combat_session.dart';
import '../../story_model.dart';
import '../characters/grandma_grim.dart';

// GRANDMA GRIM: A VISIT
// Follow-up to The Retirement Home. Raiders hit Sunset Gables on a quiet
// afternoon. Grandma Grim is far more dangerous than she looks. How she
// greets you depends on how you left things.
// Endings: ally, watched, fled.

final StoryDef grandmaStory = StoryDef(
  id: 'grandma',
  title: 'GRANDMA GRIM: A VISIT',
  tagline: 'SHE’S SIXTY-NINE YEARS OLD, FIVE FOOT NOTHING AND HAS NEVER BEEN BEATEN AT BINGO. OR ANYTHING.',
  difficulty: 'MODERATE',
  destinationKm: 1.4,
  recommendedLevel: 3,
  scale: StoryScale.short,
  unlock: const Unlock(anyDone: ['retirement'], hint: 'FINISH THE RETIREMENT HOME FIRST.'),
  intro: ['A tin whistle shrieks on the wind from Sunset Gables. You know that whistle. It’s the one they blow when somebody is about to learn something about old people.'],
  reward: const Reward(scrap: 70, xp: 55, stims: 1),
  endings: {
    'ally': const Ending('ally', 'SHOULDER TO SHOULDER',
        'You fought with her. The raiders left without their boots. Grandma Grim lowered Dolores and said, “Not bad.” That is, on the scale of the Gables, a knighthood. You’ve been given a key.',
        bonus: Reward(xp: 30, stims: 1), world: ['grim.friend', 'favour.grim']),
    'watched': const Ending('watched', 'THE SPECTATOR',
        'You stayed on the porch with a cup of tea while Grandma Grim saw off a dozen raiders by herself. It took four minutes. She came back, sat down and asked if you’d like a biscuit. You said yes. You have never said yes so fast.',
        bonus: Reward(xp: 20), world: ['grim.respect']),
    'fled': const Ending('fled', 'A WISE RETREAT',
        'You ran. She saw you. She said nothing. Later, in the evening, there was a very small package left on your doorstep: one biscuit, and a note. It said: NEXT TIME, DEAR.',
        bonus: Reward(), world: ['grim.insulted']),
  },
  depart: (c) => ['The whistle shrills again. You hurry. Behind you, a distant explosion, then a very calm voice saying, “Mind the roses, dears.”'],
  ambient: [
    Ambient('A raider’s boot lies in the road, with a note tied to it: RETURN TO OWNER. IF HE CAN WALK.', maxKm: 0.8),
    Ambient('From over the hill, a polite, steely voice: “I did say, young man, wipe your feet.”', maxKm: 1),
    Ambient('~There’s a point in the wasteland past which only the very young or the very old are not afraid.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'porch',
      title: 'THE PORCH',
      km: 0.7,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 15),
      journal: (c) => ['Raiders approached Sunset Gables. Grandma Grim sat on her porch and, calmly, waited.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...GrandmaGrim.greeting(c),
            'A line of raiders is advancing up the drive, a dozen of them, in a ragged line. They look at the Gables. They look at the porch. They look at a small lady with a shotgun and a flask.',
            '“I don’t want to be difficult,” says Grandma Grim, to nobody. “I do hope they’re not going to be difficult.”',
          ],
          [
            Choice('[STAND WITH HER]', 'stand'),
            Choice('[WATCH FROM THE PORCH]', 'watch'),
            Choice('[SLIP AWAY]', 'slip'),
          ],
        ),
        Scene.talk('stand', say(['You move up beside her, checking your weapon. She doesn’t look at you. She’s smiling. “Good,” she says. “I do like a young person who can’t resist.”']), [Choice('[CONTINUE]', 'end_p')], flags: ['stood']),
        Scene.talk('watch', say(['“Sit,” says Grandma Grim, nodding to a chair. “Have a tea.” You sit. A cup is pressed into your hand. She rises. She cocks Dolores. “Now,” she says, “watch.”']), [Choice('[CONTINUE]', 'end_p')], flags: ['watched']),
        Scene.talk('slip', say(['You edge toward the drive. “Where are you going, dear?” says Grandma Grim, without turning. You stop. There’s a very faint click. You are, you suddenly realise, in range of something you’d rather not be in range of.']), [Choice('[STAND WITH HER]', 'stand'), Choice('[RUN]', 'end_p', flags: ['ran'])]),
        Scene.end('end_p', say(['The raiders’ leader, a big man in a leather coat, steps forward. “Give us the Gables,” he says. “And the old folks can go.” Grandma Grim smiles. “Oh, dear,” she says. “You’ve no idea.”'])),
      ],
    ),
    Checkpoint(
      id: 'drive',
      title: 'THE DRIVE',
      km: 1.4,
      art: 'gang',
      start: 'a',
      reward: const Reward(scrap: 12, xp: 25),
      journal: (c) => ['The fight on the drive was short.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The raiders surge. The first rank hits the tripwires. The second hits the roses. The third hits a pressure plate under a cake tin, which detonates. Somewhere in the greenhouse a machine gun in a lilac cosy begins to hum. Grandma Grim, still sitting, raises Dolores.',
          ]),
          [
            Choice('[FIGHT BESIDE HER]', 'fight', show: (c) => c.flag('stood')),
            Choice('[LET HER HANDLE IT]', 'hers', show: (c) => c.flag('watched')),
            Choice('[GET OUT OF THERE]', 'end_fled'),
          ],
        ),
        Scene.fight(
          'fight',
          say(['A raider leaps the trench and swings a pipe. You block. Dolores booms. He’s on his back in a flower bed. Another comes. Grandma Grim’s needle takes him in the shoulder. “Left,” she says, calmly. “Left, dear.”']),
          EnemyType.raider,
          win: 'end_ally',
          fail: 'end_ally',
        ),
        Scene.talk('hers', say(['You sit with your tea. Grandma Grim stands. In four minutes she dispatches twelve raiders without once raising her voice. The thirteenth, a big man, turns and runs. She puts Dolores to her shoulder. Thinks better of it. “Manners,” she says, and lowers it.']), [Choice('[CONTINUE]', 'end_watched')]),
        Scene.end('end_ally', say(['It’s over in minutes. The raiders flee, without their boots. Grandma Grim lowers Dolores, wipes the barrel and gives you a very long, assessing look. “Not bad,” she says. “For a youngster.” It’s the highest praise you’ve ever been given.']), ending: 'ally'),
        Scene.end('end_watched', say(['She comes back to the porch and sits. “Biscuit?” she says. You take one. “Good boy,” she says, and goes back to her knitting. The needle clicks, the sun sets, and not a single person in the Gables says a word about what happened.']), ending: 'watched'),
        Scene.end('end_fled', say(['You’re halfway down the road before you realise nobody’s following. From behind you, the sound of a single, very calm gunshot, then the polite voice again: “And that’s the last of them.” You keep going. You are, in all honesty, extremely glad you’re not on the wrong side of it.']), ending: 'fled'),
      ],
    ),
  ],
);
