import '../../story_model.dart';
import '../story_kit.dart';

// THE TIME TRAVELLER
// Mr. Fenwick says he has travelled through time. His evidence is a watch that
// is about five minutes fast. He is absolutely convinced this proves everything.
// Endings: believed, tested, clock.

final StoryDef timetravellerStory = StoryDef(
  id: 'timetraveller',
  title: 'THE TIME TRAVELLER',
  tagline: 'HIS WATCH IS FIVE MINUTES FAST. HE HAS COME FROM THE FUTURE. THIS IS ALL THE PROOF HE NEEDS.',
  difficulty: 'LOW',
  destinationKm: 1.2,
  recommendedLevel: 1,
  scale: StoryScale.short,
  intro: ['A breathless man in a very old hat bursts out of a ditch and seizes your sleeve. “Listen to me,” he hisses. “I’ve come from the future. I’ve come from FIVE MINUTES from now. Look!” He thrusts out his wrist.'],
  reward: const Reward(scrap: 40, xp: 35),
  endings: {
    'believed': const Ending('believed', 'A BELIEVER',
        'You told him you believed him. He wept. He gave you a tip about the future: “Don’t go in the water.” You’ve been careful of water ever since. You have never found out why.',
        bonus: Reward(xp: 15), world: ['fenwick.believed']),
    'tested': const Ending('tested', 'A SCIENTIFIC APPROACH',
        'You tested him thoroughly. He was wrong about nine things and right about one. The one was extremely specific and, to your enormous annoyance, came true at 3:41 that afternoon.',
        bonus: Reward(xp: 30), world: ['fenwick.tested']),
    'clock': const Ending('clock', 'THE CLOCK IS WRONG',
        'You corrected his watch. He stared at it for a long time. Then he sat down, quietly, and took off his hat. “Oh,” he said. “That’s a relief. And a terrible shame.”',
        bonus: Reward(xp: 20, scrap: 20), world: ['fenwick.clock']),
  },
  depart: (c) => ['You come over a rise and a man is already running toward you, shouting something that sounds like “Don’t! Wait! You haven’t yet!”'],
  ambient: [
    Ambient('Somebody has chalked on a wall: I WAS HERE. (I WILL BE.)', maxKm: 0.8),
    Ambient('A pocket watch lies in the road, ticking furiously. It reads a quarter to nothing.', maxKm: 1),
    Ambient('~Anyone can predict the future. The trick is being right at the time.', minKm: 0.5),
  ],
  checkpoints: [
    Checkpoint(
      id: 'proof',
      title: 'THE PROOF',
      km: 1.2,
      art: 'drifter',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 18),
      journal: (c) => [
        'Mr. Fenwick says he is a time traveller. His proof is a watch that is five minutes fast.',
        if (c.flag('tested_him')) 'I tested his predictions. He was entertainingly wrong.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'He is a small, stooped, earnest man with a tin-foil bow-tie. The watch on his wrist is large, brass and very old. It reads 4:17.',
            '“What time do you make it?” he asks, eyes bright. You glance at the sun. “About twelve past.” “EXACTLY,” he cries. “It’s FIVE MINUTES FAST. Don’t you see? It’s ahead of the present. That means I’ve been into the FUTURE.”',
            'You consider the logical gap. The gap considers you.',
          ]),
          [
            Choice('[ASK FOR A PREDICTION]', 'predict'),
            Choice('[SAY IT’S JUST A FAST WATCH]', 'fast'),
            Choice('[BELIEVE HIM]', 'believe'),
            skillChoice('ENGINEERING', 1, 'OPEN THE WATCH', 'open'),
          ],
        ),
        Scene.talk(
          'predict',
          say([
            '“What happens next?” you ask. He closes his eyes. “In two minutes,” he says, “a crow will land on that post. Then a man will fall in a ditch. Then you will say something about me being an idiot.” You wait. A crow lands on the post.',
            'He opens one eye. “Told you.” You say, honestly, that crows land on posts. He looks hurt. A man, a long way off, trips and falls in a ditch.',
            'You have, to your annoyance, nothing to say.',
          ]),
          [
            Choice('[TEST HIM MORE]', 'test'),
            Choice('[BELIEVE HIM]', 'believe'),
          ],
          flags: ['tested_him'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'test',
          say([
            'You ask him fourteen questions. He gets nine wrong. “Who wins the next election?” “A very tall man.” “What will I have for lunch?” “Something soft.” “What’s going to fall from the sky?” “Er. Birds? Or a piano.”',
            'But on the fourteenth, he says, with sudden, rigid certainty: “At 3:41, a woman in a red scarf will give you a gift. You will not want it. You will need it.” You write it down. You will check.',
          ]),
          [Choice('[CONTINUE]', 'end_tested')],
          flags: ['tested_him'],
        ),
        Scene.talk(
          'fast',
          say([
            '“It’s just a fast watch,” you say. He draws himself up. “It’s not fast. It’s PRESCIENT.” He holds it out. The second hand ticks past a tiny, hand-lettered label on the dial: ADJUST ME.',
            '“It says adjust it,” you say. “That’s the TIME TRAVEL setting,” he says, haughtily.',
          ]),
          [
            Choice('[BELIEVE HIM]', 'believe'),
            Choice('[SET THE WATCH RIGHT]', 'end_clock'),
          ],
        ),
        Scene.talk(
          'believe',
          say([
            '“I believe you,” you say, and, to your surprise, mean it, a bit. Mr. Fenwick’s lip trembles. He takes off his hat, and presses it to his chest. “Nobody’s ever said that. They always say it’s a clock.”',
            'He leans in, whispering. “One piece of advice. Don’t go in the water.” “Which water?” “All of it.”',
          ]),
          [Choice('[THANK HIM]', 'end_believed')],
        ),
        Scene.talk(
          'open',
          say([
            'You prise open the case. Inside, a very good, very simple movement, running a perfect five minutes fast. A tiny screw, marked R, has been turned all the way to the end. Someone, long ago, adjusted it, on purpose, so as never to be late.',
            'Under the cover, a tiny inscription: FOR FENWICK. SO YOU’RE NEVER LATE. LOVE, MARGARET. The watch is not a time machine. It’s a present.',
          ]),
          [
            Choice('[TELL HIM]', 'end_clock'),
            Choice('[KEEP QUIET, LET HIM BELIEVE]', 'end_believed'),
          ],
          flags: ['read_inscription'],
          reward: const Reward(xp: 12),
        ),
        Scene.end('end_believed', say(['He shakes your hand, hard, and sets off down the road at a brisk, anxious trot. “Remember!” he calls. “Not the water!” You wave. A very long way off, he trips over nothing and disappears into a ditch. You don’t laugh. It’s very close.']), ending: 'believed'),
        Scene.end('end_tested', say(['At 3:41 that afternoon, a woman in a red scarf comes up the road, with a sack. She hands you a spare bandage. “I’ve no idea why,” she says. “It just seemed right.” You don’t want it. You need it, three hours later. You mark Fenwick’s name, for the first time, down in the column of Things You’re Not Going To Think About.']), ending: 'tested'),
        Scene.end('end_clock', say(['You reach for his wrist and turn the tiny screw back. The hands slip to the right time. Mr. Fenwick stares at them. A very long silence follows. “Is that,” he says, quietly, “what it’s meant to be?”',
          'He takes off his hat. He looks, for a moment, extremely relieved, and very, very sad. “It was a nice idea,” he says. “For a while.”']), ending: 'clock'),
      ],
    ),
  ],
);
