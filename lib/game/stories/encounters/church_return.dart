import '../../story_model.dart';
import '../characters/brother_positive.dart';

// BROTHER POSITIVE AND DAVE: A SECOND SERMON
// Follow-up to The Church of the Eternal Battery. Brother Positive’s mood
// and what he says depend on what you did to his battery (BrotherPositive.mood).
// Dave may finally admit that he started the whole thing.
// Endings: blessed, confessed, wagon.

final StoryDef churchReturnStory = StoryDef(
  id: 'church_return',
  title: 'A SECOND SERMON',
  tagline: 'BROTHER POSITIVE HAS FOUND YOU AGAIN. DAVE IS STANDING BEHIND HIM, WITH A SANDWICH.',
  difficulty: 'LOW',
  destinationKm: 1.4,
  recommendedLevel: 2,
  scale: StoryScale.short,
  unlock: const Unlock(anyDone: ['church'], hint: 'FINISH THE CHURCH OF THE ETERNAL BATTERY FIRST.'),
  intro: ['A familiar hum rolls over the road. It’s on the wind: a low, hopeful, unmistakable note. Somewhere ahead, a speaker coughs, and a voice says, with infinite tenderness, “THIS IS A TEST.”'],
  reward: const Reward(scrap: 55, xp: 45),
  endings: {
    'blessed': const Ending('blessed', 'A SMALL BLESSING',
        'Brother Positive blessed you, with a hand on each shoulder and a very small current of static. It didn’t do anything. You felt, nonetheless, a bit lighter. Dave watched, with his sandwich, and gave a thumbs-up that was almost certainly sarcastic.',
        bonus: Reward(xp: 20), world: ['positive.blessed']),
    'confessed': const Ending('confessed', 'DAVE CONFESSES',
        'Dave told him. In front of everybody, with the sandwich still in his hand. There was a long, awful silence. Then Brother Positive, very slowly, said, “...I know.” He had known for years. He had simply been waiting for Dave to say it.',
        bonus: Reward(xp: 50, stims: 1), world: ['carry.dave.admitted', 'dave.admitted', 'positive.confessed']),
    'wagon': const Ending('wagon', 'THE TRAVELLING CHURCH',
        'You helped Brother Positive pack the church onto a cart. It’s a small, rickety church now: one speaker, one battery, one robe, one man. They tour the wasteland. They don’t preach. They just say: you are not alone. It seems to be enough.',
        bonus: Reward(scrap: 40, parts: 1), world: ['positive.wagon']),
  },
  depart: (c) => [...BrotherPositive.greeting(c)],
  ambient: [
    Ambient('A distant congregation, singing, very slightly out of tune, about a battery. It’s a very comforting sound.', maxKm: 0.8),
    Ambient('A man in a perfectly ordinary coat is following you, a polite distance behind. When you look, he points at a bird.', maxKm: 1.2),
    Ambient('~Every religion needs a person who started it. It’s usually the quietest in the room.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'road',
      title: 'THE ROADSIDE',
      km: 0.7,
      art: 'shrine',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => ['Brother Positive found me on the road. Dave was with him, behind a hedge.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...BrotherPositive.greeting(c),
            ...BrotherPositive.dave(c),
            if (c.world('battery.war')) 'In the distance, a small fire burns, and a goose, on a barricade, honks.',
            if (c.world('battery.repaired')) 'The Voice, in the distance, is reading the weather. It’s a good, steady, practical voice.',
          ],
          [
            Choice('[LISTEN TO BROTHER POSITIVE]', 'listen'),
            Choice('[TALK TO DAVE]', 'dave'),
            Choice('[ASK ABOUT THE BATTERY]', 'battery'),
          ],
        ),
        Scene.talk('listen', (c) => [
          if (BrotherPositive.mood(c) == 'stolen') '“I’ve been thinking about the Great Disconnection,” he says. “I’ve decided it was the best thing that ever happened to me. I’ve never been so quiet. I’ve started listening to people. It turns out they say all sorts of things.”'
          else if (BrotherPositive.mood(c) == 'repaired') '“The Battery’s never been so strong,” he says. “It’s like a heartbeat. Last Tuesday, it told us the exact water level of the well. I wept. I’d like to think it’s proud.”'
          else if (BrotherPositive.mood(c) == 'exposed') '“I’ve been reading about batteries,” he says. “They’re really quite interesting. I’ve made a small collection. Not as gods. As friends.”'
          else if (BrotherPositive.mood(c) == 'prophet') '“Your Eminence,” he says. “The flock asks after you. They are worried you’ve forgotten us. I told them you were busy being holy.”'
          else if (BrotherPositive.mood(c) == 'war') '“The war has ended,” he says. “We lost. Or won. It’s hard to say. A very nice woman brought a tray.”'
          else '“It’s a difficult thing,” he says, “to be certain.”',
        ], [Choice('[CONTINUE]', 'end_r')]),
        Scene.talk('dave', (c) => [
          'You nudge Dave. He freezes, holding the sandwich like a shield. “Hello,” he says. “I’m not here. I’m just a bit of ordinary. Don’t mind me.”',
          if (c.world('carry.dave.admitted') || c.world('dave.admitted')) '“You know,” he says, very quietly. “You know it was me. I’ve told no one else. Please don’t. He’s so happy.”'
          else '“Have you ever,” he says, “wanted to confess something so badly that you couldn’t bear to?”',
        ], [Choice('[CONTINUE]', 'end_r')], flags: ['talked_dave']),
        Scene.talk('battery', say(['“The Battery?” says Brother Positive, brightening. “Oh, it’s... around.” He glances at a cart. On the cart, under a blanket, something small and square gives, very faintly, a hum. “It’s resting,” he says. “It’s on tour.”']), [Choice('[CONTINUE]', 'end_r')]),
        Scene.end('end_r', say(['“Would you walk with us?” asks Brother Positive. “It’s only a little way. I’d like to say something to a few people. I’d like you there.” Dave falls in beside you, with a small, miserable nod.'])),
      ],
    ),
    Checkpoint(
      id: 'sermon',
      title: 'THE CONFESSION',
      km: 1.4,
      art: 'shrine',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 20),
      journal: (c) => ['A small sermon at a crossroads. Dave stood, sandwich in hand, in front of everyone.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'At the crossroads, thirty-odd people have gathered on folding chairs. Brother Positive raises his hands. A small speaker hisses. Dave, at the back, goes the colour of a plain biscuit.',
            '“Beloved,” says Brother Positive, “today I have a surprise. A confession. A friend of mine would like to speak.” And every face in the congregation turns to Dave.',
          ]),
          [
            Choice('[LET DAVE SPEAK]', 'speak'),
            Choice('[BLESS THE CROWD YOURSELF]', 'bless'),
            Choice('[OFFER TO HELP PACK THE WAGON]', 'wagon'),
          ],
        ),
        Scene.talk('speak', say(['Dave comes forward. He puts down his sandwich. “It was me,” he says. “I said ‘bless you.’ To a machine. It was an accident. I’m so sorry.” There’s a very long, very still silence. “I know, Dave,” says Brother Positive, gently. “I’ve known for years.”']), [Choice('[WATCH THEM EMBRACE]', 'end_confessed')]),
        Scene.talk('bless', say(['You raise your hands, awkwardly, and say, “Be... well.” Somebody whispers “amen.” It’s so earnest it hurts. Brother Positive wipes his eyes. “A natural,” he says. Dave is watching, with a thin smile. He raises his sandwich in a salute.']), [Choice('[CONTINUE]', 'end_blessed')]),
        Scene.talk('wagon', say(['You and Dave heave the Battery onto a cart. It’s lighter than you expected. Brother Positive stands in the road, speechless. “It’s only a small church,” you say. “It can go anywhere.” He nods slowly. “Anywhere,” he says. “That’s the whole of the faith.”']), [Choice('[CONTINUE]', 'end_wagon')]),
        Scene.end('end_confessed', say(['Brother Positive hugs him, and a whole crowd of people, who have been waiting for years to be told it’s all right, begins, softly, to applaud. Dave blushes. He takes a bite of his sandwich. “Well,” he says, with his mouth full. “That went better than I thought.”']), ending: 'confessed'),
        Scene.end('end_blessed', say(['Brother Positive lays a hand on your head. A small blue spark, from his sleeve, crackles. It tickles. “There,” he says. “That should keep you out of trouble.” It doesn’t. But you leave with a lighter step, and, for an hour, no desire to argue with anybody.']), ending: 'blessed'),
        Scene.end('end_wagon', say(['They set off the next morning: a cart, a speaker, a battery, a man in a robe and a man in a plain coat. You watch them go. Dave turns and gives you a small, secret wave. For the first time, he’s not holding his sandwich.']), ending: 'wagon'),
      ],
    ),
  ],
);
