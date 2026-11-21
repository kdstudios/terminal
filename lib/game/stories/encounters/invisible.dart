import '../../story_model.dart';
import '../story_kit.dart';

// THE INVISIBLE MAN
// Mr. Vance wears experimental camouflage that is clearly, magnificently
// broken. He refuses to accept this. Endings: played, honest, fixed.

final StoryDef invisibleStory = StoryDef(
  id: 'invisible',
  title: 'THE INVISIBLE MAN',
  tagline: 'HE IS RIGHT THERE. HE IS STANDING IN THE MIDDLE OF THE ROAD. HE IS SURE YOU CAN’T SEE HIM.',
  difficulty: 'LOW',
  destinationKm: 1.2,
  recommendedLevel: 1,
  scale: StoryScale.short,
  intro: [
    'A man in a suit made of mirrors is standing in the middle of the road, with a very small fan and a very large grin. The suit shimmers like a disco ball. It has a small, flickering sign on the chest that reads, helpfully, INVISIBLE.',
  ],
  reward: const Reward(scrap: 45, xp: 35, parts: 1),
  endings: {
    'played': const Ending('played', 'THE PERFECT CRIME',
        'You pretended not to see him. He took a pair of your gloves, a bandage, a whole loaf and a hat. He has never been so happy. He thinks he’s a genius. The loaf was not worth it. His joy was.',
        bonus: Reward(xp: 15), world: ['vance.played']),
    'honest': const Ending('honest', 'THE TRUTH ABOUT MIRRORS',
        'You told him, as kindly as you could, that you could see him. He sat down in the road. He said nothing for a long time. Then he said, “Is it the sparkle?” It was the sparkle.',
        bonus: Reward(xp: 25), world: ['vance.honest']),
    'fixed': const Ending('fixed', 'MOSTLY INVISIBLE',
        'You fixed the suit. It still isn’t invisible. But it is now merely extremely hard to find, in a very large room, if you’re not looking. He is thrilled. He says it’s the first time anyone has ever lost him.',
        bonus: Reward(xp: 40, parts: 1), world: ['vance.fixed']),
  },
  depart: (c) => ['You stop. The man in the road does not stop. He stands, stiff as a lamppost, trying to look like a lamppost. You’re fairly sure he is trying to look like a lamppost.'],
  ambient: [
    Ambient('Somewhere ahead, a very small sound like a sequin being dropped.', maxKm: 0.8),
    Ambient('A man stands behind a thin post, with his arms raised. He’s using it as cover. He is, plainly, not covered.', maxKm: 1),
    Ambient('~There’s a kind of courage in being sure of something that is, demonstrably, false.', minKm: 0.5),
  ],
  checkpoints: [
    Checkpoint(
      id: 'road',
      title: 'THE MIRROR SUIT',
      km: 1.2,
      art: 'drifter',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 20),
      journal: (c) => [
        'Mr. Vance’s camouflage is a suit of mirrors that glitters, loudly. He believes it makes him invisible.',
        if (c.flag('seen.suit')) 'It is powered by a hamster wheel.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            '“You can’t see me,” says the man in the suit. His voice is a loud whisper. “I’m invisible. I’m the world’s first invisible man. I’ve been invisible for six days. Nobody has noticed.”',
            'He is dressed in a mirror-suit, with a sun hat made of tin foil. A small battery pack on his back whirrs. A hamster is running on a tiny wheel on his shoulder. He winks at you, enormously.',
            '“Pretend you can’t see me,” he whispers. “It’s part of the experiment.”',
          ]),
          [
            Choice('[PLAY ALONG]', 'play'),
            Choice('[TELL HIM THE TRUTH]', 'truth'),
            skillChoice('ENGINEERING', 1, 'EXAMINE THE SUIT', 'suit'),
            Choice('[ASK ABOUT THE HAMSTER]', 'hamster', show: (c) => !c.flag('seen.hamster')),
          ],
        ),
        Scene.talk(
          'hamster',
          say([
            '“That’s Doreen,” says the man, quietly. “She’s the power source. She’s not part of the camouflage. She’s a... consultant.” Doreen stops running and gives you a very long, very weary look. She resumes.',
          ]),
          [
            Choice('[PLAY ALONG]', 'play'),
            Choice('[TELL HIM THE TRUTH]', 'truth'),
          ],
          flags: ['seen.hamster'],
        ),
        Scene.talk(
          'suit',
          say([
            'You look carefully at the suit. It’s a patchwork of broken wing mirrors and shaving mirrors on a canvas boiler suit. The “active camouflage” is a bicycle light on a loop. The “cloaking field” is a small fan blowing at a foil panel.',
            'Nothing about it is hidden. In fact, it makes him five times more visible than he’d be in his underpants. Doreen, on the wheel, appears to be the only part that works.',
          ]),
          [
            Choice('[FIX IT PROPERLY]', 'end_fixed'),
            Choice('[PLAY ALONG]', 'play'),
            Choice('[TELL HIM THE TRUTH]', 'truth'),
          ],
          flags: ['seen.suit'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'play',
          say([
            'You look straight past him. “Hello?” you say, to the empty road. “Is somebody there?” The man freezes. His eyes go wide with joy. He takes a very small step. You say, “I could have sworn I heard a hamster.”',
            'He takes your hat. He takes it so slowly, so carefully, you almost feel guilty. He puts it on his own head. “It’s working,” he whispers. “It’s actually working.” He’s so happy he starts to cry.',
          ]),
          [Choice('[LET HIM TAKE THE REST]', 'end_played')],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'truth',
          say([
            '“I can see you,” you say, as gently as you can. “You’re in a suit made of mirrors. You’re standing in the road. You’re waving.”',
            'There’s a very long silence. “That’s what the others said,” says the man, quietly. “But I thought they were just being kind.”',
            'He sits down heavily. Doreen stops running. “Is it the sparkle?” he asks. It is the sparkle.',
          ]),
          [Choice('[SIT WITH HIM]', 'end_honest')],
        ),
        Scene.end('end_played', say([
          'He sweeps your supplies into his arms like a man cleaning up after a party. A bandage, a loaf, a pair of gloves, your hat. “You’ll never know,” he whispers. “I’ve been here the whole time.” He tiptoes off down the road, with a stride so long and loud you can hear it for a kilometre.',
          'He’s the happiest thief you’ve ever robbed you.',
        ]), ending: 'played'),
        Scene.end('end_honest', say([
          'You sit beside him on the road. After a while he takes the tin hat off. He looks at himself in his own chest. “I look,” he says, “like a very sad disco.” You tell him there’s a lot worse to be. He nods. “Doreen’s been saying so for days.”',
        ]), ending: 'honest'),
        Scene.end('end_fixed', say([
          'You spend an hour with a pair of pliers and a lot of patience. When you’re done, the suit has a matte cloak, a few mirror patches that actually reflect the road, and a small dimmer for the bicycle light. He steps into the dust, and for a very brief, wonderful moment, you lose him.',
          '“Where did he go?” you say, to the road. And Doreen, on the wheel, stops running and points one paw at a rock. “Ah,” you say.',
        ]), ending: 'fixed'),
      ],
    ),
  ],
);
