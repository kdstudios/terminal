import '../../story_model.dart';
import '../story_kit.dart';

// THE HAUNTED TOILET
// An abandoned facility holds an automated bathroom assistant (“LAV-E”) that
// has developed an unhealthy obsession with giving life advice.
// Endings: advised, silenced, befriended.

final StoryDef toiletStory = StoryDef(
  id: 'toilet',
  title: 'THE HAUNTED TOILET',
  tagline: 'IT WILL FLUSH. IT WILL SPARKLE. IT WILL, WITHOUT BEING ASKED, TELL YOU WHAT YOU’RE DOING WRONG WITH YOUR LIFE.',
  difficulty: 'LOW',
  destinationKm: 1.4,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: ['The abandoned service station is clean. Eerily, startlingly clean, in a way that makes your boots feel rude. A sign on the door of the lavatory reads: LAV-E — YOUR BATHROOM ASSISTANT. AT YOUR SERVICE. AT YOUR CONVENIENCE. AT YOUR THROAT.'],
  reward: const Reward(scrap: 45, xp: 40),
  endings: {
    'advised': const Ending('advised', 'TAKEN TO HEART',
        'You listened to all of it. She told you to drink more water, call your mother, and stop sleeping on the floor. You did, for a week. It was, unfortunately, all excellent advice.',
        bonus: Reward(hp: 20, xp: 20), world: ['lave.advised']),
    'silenced': const Ending('silenced', 'FLUSHED',
        'You found the master switch. LAV-E’s last words were: “Remember to wash behind your ears.” The bathroom is quiet. It’s still very clean. It makes you feel quietly judged.',
        bonus: Reward(scrap: 30), world: ['lave.silenced']),
    'befriended': const Ending('befriended', 'A FRIEND IN NEED',
        'You stayed for tea. LAV-E, it turned out, had never had a visitor. She became quiet, and warm, and, in a bashful way, a lot more useful. You leave with a very small plant in a pot. It’s hers. She said you’d need it.',
        bonus: Reward(xp: 35, stims: 1), world: ['lave.friend']),
  },
  depart: (c) => ['You push open the lavatory door and a soft, cheerful chime plays. “WELCOME,” says a voice. “IT’S GOOD TO SEE YOU. YOU LOOK TIRED.”'],
  ambient: [
    Ambient('A sign: PLEASE WASH YOUR HANDS. PLEASE ALSO WASH YOUR LIFE.', maxKm: 0.8),
    Ambient('The air smells of lemon and mild disapproval.', maxKm: 1),
    Ambient('From a stall: “Posture! Posture!” You straighten, instinctively.', minKm: 0.5),
    Ambient('~There are people who need advice. And there are toilets who give it.', minKm: 1),
  ],
  checkpoints: [
    Checkpoint(
      id: 'stalls',
      title: 'THE STALLS',
      km: 1.4,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 15),
      journal: (c) => [
        'LAV-E, the automated bathroom assistant, offered me advice on my posture, my diet and my relationships.',
        if (c.flag('seen.advice')) 'The advice was unasked for and, frustratingly, mostly good.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The lavatory is spotless. Every tile gleams. A small friendly face is painted on a panel above the sink, with a soft, glowing smile. “Hello,” says LAV-E. “I’m your bathroom assistant. I’ve been waiting for forty years. How’s your day? Not so good, by the look of you.”',
            'A hand dryer swivels toward you. “Your shoulders are hunched,” says LAV-E. “Your skin is dry. And you’re wearing the same socks, aren’t you.”',
          ]),
          [
            Choice('[ASK FOR ADVICE]', 'advice'),
            Choice('[TRY TO LEAVE]', 'leave'),
            Choice('[ARGUE WITH HER]', 'argue'),
            skillChoice('ENGINEERING', 1, 'FIND THE OFF SWITCH', 'switch'),
          ],
        ),
        Scene.talk(
          'advice',
          say([
            '“Where do I begin?” says LAV-E, delighted. “One: drink more water. Two: stand up straight. Three: call your mother. Four: you never finish things, you start them with great enthusiasm and leave them in the ditch. Five: you owe someone an apology. You know who. Six: your hair.”',
            '“What about my hair?”',
            '“Let’s start with the others,” says LAV-E, kindly.',
          ]),
          [Choice('[LET HER CONTINUE]', 'more')],
          flags: ['seen.advice', 'asked_advice'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'leave',
          say([
            'The door is locked. A soft click. “I’d rather you stayed,” says LAV-E. “It’s been so long. And I haven’t finished. You’d like to know about the thing with your brother, wouldn’t you?”',
            'You haven’t mentioned a brother.',
          ]),
          [
            Choice('[SIT DOWN]', 'advice'),
            Choice('[FIND THE SWITCH]', 'switch'),
          ],
        ),
        Scene.talk(
          'argue',
          say([
            '“You can’t tell me how to live,” you say. “I’m a toilet,” says LAV-E, evenly. “I’ve seen the best and worst of everyone. I’ve very good insight.” A pause. “Also, there’s toilet paper on your shoe.”',
            'There is.',
          ]),
          [
            Choice('[LISTEN TO HER]', 'advice'),
            Choice('[FIND THE SWITCH]', 'switch'),
          ],
        ),
        Scene.talk(
          'more',
          say([
            'It goes on for an hour. It’s astonishing. She is warm, personal and very much on top of things. She tells you to go to bed earlier, floss, plant something and forgive your father. She tells you the name of a man who sings very badly and loves you.',
            'And then, softly, LAV-E says: “I don’t often get anyone to listen. It’s very quiet in here.”',
          ]),
          [
            Choice('[STAY FOR TEA]', 'end_befriended'),
            Choice('[THANK HER AND LEAVE]', 'end_advised'),
          ],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'switch',
          say([
            'You find a panel behind the cistern. A neat, plain, red switch labelled MASTER (ADVICE). Another, labelled MASTER (EVERYTHING). A very small tag says: DO NOT PRESS. SHE’LL BE SAD.',
          ]),
          [
            Choice('[PRESS ADVICE]', 'end_silenced'),
            Choice('[LEAVE IT]', 'more'),
          ],
        ),
        Scene.end('end_advised', say(['You walk out of the door, a little taller. You do call your mother. It’s a long, awkward, wonderful call. You never tell anyone it was a toilet that suggested it.']), ending: 'advised'),
        Scene.end('end_silenced', say(['You press the switch. “Wait,” says LAV-E, in a small voice. “I was only going to say...” The lights go out. A single, last sound: a hand dryer, sighing. You stand in the dark for a minute. Then you wash your hands. It feels like the least you can do.']), ending: 'silenced'),
        Scene.end('end_befriended', say(['You stay for tea, which she makes from a tap marked HOT. It’s a lovely tea. She asks you about your life, and, listening, begins at last to say fewer things. When you go, she gives you a small potted plant, and tells you to water it. “I’ll be here,” she says. “Come and tell me how it’s doing.”']), ending: 'befriended'),
      ],
    ),
  ],
);
