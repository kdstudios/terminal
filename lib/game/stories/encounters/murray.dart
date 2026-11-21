import '../../story_model.dart';
import '../characters/murray.dart';

// MURRAY THE MAGNIFICENT
// A terrible travelling magician and Professor Nibbles, his mutant rabbit, who
// is cleverer than he is. Characters: see characters/murray.dart.
// Endings: helped, humiliated, rabbit.

final StoryDef murrayStory = StoryDef(
  id: 'murray',
  title: 'MURRAY THE MAGNIFICENT',
  tagline: 'HE PULLS A RABBIT OUT OF A HAT. THE RABBIT PULLS HIM OUT OF TROUBLE.',
  difficulty: 'LOW',
  destinationKm: 1.6,
  recommendedLevel: 1,
  scale: StoryScale.short,
  intro: ['A painted wagon stands at a crossroads, with a banner: MURRAY THE MAGNIFICENT! ILLUSIONS! ESCAPES! OCCASIONALLY, CATS! A very small crowd of three sits on upturned crates, looking resigned.'],
  reward: const Reward(scrap: 45, xp: 40),
  endings: {
    'helped': const Ending('helped', 'THE LUCKY ASSISTANT',
        'You helped Murray finish a trick for the first time in his career. It was a small one, and it went wrong, but it went wrong in the right order. He wept. The Professor, on his shoulder, gave you a very small, very formal nod.',
        bonus: Reward(xp: 20), world: ['murray.helped', 'favour.murray']),
    'humiliated': const Ending('humiliated', 'EXPOSED',
        'You revealed every trick. The crowd, for once, laughed with him instead of at him. Murray took it with a brave smile and a very long walk, and has not forgiven you. The rabbit, as he left, gave you a wink.',
        bonus: Reward(scrap: 20), world: ['murray.humiliated']),
    'rabbit': const Ending('rabbit', 'PROFESSOR NIBBLES, ILLUSIONIST',
        'You asked the rabbit to run the act. It did. It was dazzling. Murray sat in the audience with his mouth open. He is now the assistant, and the rabbit has hired a manager. The show is sold out for a month.',
        bonus: Reward(xp: 40, scrap: 30), world: ['murray.rabbit_trusted', 'murray.helped']),
  },
  depart: (c) => ['You follow the sound of a trumpet that is, by any reasonable measure, only trying its best.'],
  ambient: [
    Ambient('A scattering of playing cards in the road. All of them are the three of clubs.', maxKm: 0.8),
    Ambient('A dove sits on a post, looking very tired. It has a ribbon on one leg and a look of professional resignation.', maxKm: 1.2),
    Ambient('~There’s a very particular quiet that follows a trick that didn’t work.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'show',
      title: 'THE SHOW',
      km: 0.8,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => [
        'Murray’s act: a lot of scarves, one rabbit and a surprisingly intelligent glare from the rabbit.',
        if (c.flag('saw_rabbit')) 'The rabbit, Professor Nibbles, quietly fixed Murray’s trick behind his back.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...Murray.greeting(c),
            '“For my next trick,” says Murray, “I will make this coin... disappear.” He holds up a coin. He closes his hand. He opens it. The coin is still there. He closes it again, harder. “Ah,” he says. “It’s a very advanced disappearance. You’re not seeing it because it’s so good.”',
          ],
          [
            Choice('[APPLAUD POLITELY]', 'clap'),
            Choice('[WATCH THE RABBIT]', 'rabbit'),
            Choice('[VOLUNTEER FROM THE AUDIENCE]', 'vol'),
          ],
        ),
        Scene.talk(
          'clap',
          say(['You clap. The other three audience members, appalled, stop clapping. Murray beams. “Thank you! A true connoisseur!” The rabbit, on his shoulder, closes its eyes, as though it had just been struck by a long-anticipated headache.']),
          [Choice('[CONTINUE]', 'end_s')],
        ),
        Scene.talk(
          'rabbit',
          say([
            'You watch the rabbit. The rabbit watches the coin. As Murray fumbles, the rabbit reaches, with a tiny, steady paw, into the folds of his sleeve and, with the delicacy of a pickpocket, slides the coin out. It drops it into the hat. Murray turns the hat over. The coin falls on the stage.',
            '“Ta-da!” cries Murray, with real astonishment. The rabbit meets your eye. It raises a very small eyebrow. Don’t tell him.',
          ]),
          [Choice('[CONTINUE]', 'end_s')],
          flags: ['saw_rabbit'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'vol',
          say(['“A volunteer!” cries Murray, with an expression of dawning terror. “From the audience! A real one!” He gestures at you, pulls a very long scarf from his sleeve, and says, “Would you mind terribly being sawn in half?”']),
          [Choice('[AGREE]', 'end_s'), Choice('[DECLINE]', 'end_s')],
          flags: ['volunteered'],
        ),
        Scene.end('end_s', say(['The show goes on. It goes on, very slowly, for an hour. By the end the audience has dwindled to you, and Murray is sitting on a crate with a handkerchief over his face. “It’s harder,” he mutters, “than it looks.”'])),
      ],
    ),
    Checkpoint(
      id: 'finale',
      title: 'THE GRAND FINALE',
      km: 1.6,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['Murray’s grand finale. I had to decide what to do.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Murray, in the dusk, makes a very small, brave speech. “My final trick,” he says. “The rabbit in the hat.” He holds up the hat. He reaches in. Nothing happens. He reaches in again. A very small voice from inside says, in a thin, educated tone, “Murray. Stop. Turn it round.”',
            'He stares at the hat. “I did hear that,” he says. “Didn’t I?” The rabbit climbs out, shakes its ears and looks at you. “Right,” it says. “I’m afraid we’ve rather a lot to discuss.”',
          ]),
          [
            Choice('[HELP MURRAY SAVE FACE]', 'help'),
            Choice('[LET THE RABBIT TAKE OVER]', 'rabbit'),
            Choice('[REVEAL THE TRICKS]', 'reveal'),
          ],
        ),
        Scene.talk('help', say(['You step forward and, with a conspiratorial flourish, take the hat. “A rabbit that speaks,” you announce. “Murray’s greatest secret!” The audience gasps. The rabbit, bless it, plays along. Murray’s mouth moves in time. For the first time in his career, the trick works.']), [Choice('[TAKE A BOW]', 'end_helped')]),
        Scene.talk('rabbit', say(['“Professor,” you say, “would you like to run the act?” The rabbit considers. It takes the hat, climbs onto the crate, and delivers, in a ringing voice, the best magic show you’ve ever seen. Murray sits down in the front row. His mouth falls open. By the second card trick he’s weeping with joy.']), [Choice('[WATCH THE SHOW]', 'end_rabbit')]),
        Scene.talk('reveal', say(['You walk up to the crate. “It’s all in the sleeve,” you say. “The coin, the scarf, the rabbit. It’s a very good rabbit.” The crowd erupts in laughter. Murray freezes. Then, very slowly, he laughs too, and bows, and throws a handful of confetti. It’s the first time the audience has clapped.']), [Choice('[CONTINUE]', 'end_humiliated')]),
        Scene.end('end_helped', say(['The crowd cheers. Murray’s hands shake. “It worked,” he whispers. “It actually worked.” He turns, with tears on his cheeks. “I’ll never forget this. Never. I’ll... I’ll write you into the act.” The rabbit, on his shoulder, looks at you, and, very slightly, raises its glass of nothing.']), ending: 'helped'),
        Scene.end('end_rabbit', say(['The Professor takes three bows and a curtain call. Murray stays in the front row with a flask of tea. “I always knew he was the real talent,” he says. “I just didn’t know how to say it.” The rabbit, on stage, says, “Next.”']), ending: 'rabbit'),
        Scene.end('end_humiliated', say(['They laugh, and laugh, and by the end it’s warm, not cruel. But Murray doesn’t see it that way. He packs the wagon in silence, with his head down. As he drives off, the rabbit, on the seat beside him, looks back at you. It’s not clear if it’s sympathy or a note to self.']), ending: 'humiliated'),
      ],
    ),
  ],
);
