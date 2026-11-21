import '../../story_model.dart';

// THE LUMEN PRESS, REVISITED
// Follow-up to The Man Who Sold His Shadow. Mr. Penumbra and his technology
// return, shaped by what you did to them (shadow.freed / sold / restored /
// shattered). If you sold your shadow, he can offer it back… for a price.
// Endings: reunion, rental, lights.

String _shade(StoryCtx c) {
  if (c.world('shadow.sold')) return 'sold';
  if (c.world('shadow.freed')) return 'freed';
  if (c.world('shadow.restored')) return 'restored';
  if (c.world('shadow.shattered')) return 'shattered';
  return 'other';
}

final StoryDef shadowReturnStory = StoryDef(
  id: 'shadow_return',
  title: 'THE LUMEN PRESS, REVISITED',
  tagline: 'THE SHADOWS REMEMBER. THE MAN WHO SOLD THEM WOULD LIKE A WORD.',
  difficulty: 'LOW',
  destinationKm: 1.3,
  recommendedLevel: 3,
  scale: StoryScale.short,
  unlock: const Unlock(anyDone: ['shadow'], hint: 'FINISH THE MAN WHO SOLD HIS SHADOW FIRST.'),
  intro: ['The grey-coated man is waiting at the crossroads at dusk, as though he’d never left. His lantern still casts no shadow. But beside him, on the dusty ground, something small and quick is moving.'],
  reward: const Reward(scrap: 55, xp: 45),
  endings: {
    'reunion': const Ending('reunion', 'A SHADOW OF A CHANCE',
        'Whatever you’d lost, or sold, or freed, found its way back. It’s not the same. It’s a little thinner at the edges, a little more thoughtful. It follows you on sunny days and, on cloudy ones, waits.',
        bonus: Reward(xp: 40, stims: 1), world: ['shadow.reunion']),
    'rental': const Ending('rental', 'ON HIRE',
        'You rent your shadow back, by the week. It’s a very fair rate. Mr. Penumbra sends a polite reminder each Friday, signed in ink so black it makes the paper look pale. You are, on the whole, a very well-lit customer.',
        bonus: Reward(scrap: 30), world: ['shadow.rental', 'debt.penumbra']),
    'lights': const Ending('lights', 'LIGHTS OUT',
        'You put out the lantern. For a long moment, the whole crossroads was dark. And in the dark, every shadow, free, kept, borrowed or lost, found its way home. It’s the strangest, gentlest thing you’ve ever seen. When you lit the lantern again, Mr. Penumbra had one.',
        bonus: Reward(xp: 60), world: ['shadow.lights']),
  },
  depart: (c) {
    switch (_shade(c)) {
      case 'sold':
        return ['You walk toward the lantern. Nothing follows you. It’s still a lonely, light feeling. In the distance, a tall figure raises a hat.'];
      case 'freed':
        return ['A thin, quick shape runs across the road ahead of you and waves, once, from a wall. It’s the shadow you freed. It’s still on the loose.'];
      case 'restored':
        return ['The stall is gone. In its place, a neat little office with a sign: LOST & FOUND (SHADOWS). Mr. Penumbra is behind the desk, in shirtsleeves.'];
      case 'shattered':
        return ['The ground at the crossroads is dark in a hundred places. As you step, the shadows part, politely, like a crowd.'];
      default:
        return ['The lantern glows at the crossroads.'];
    }
  },
  ambient: [
    Ambient('Your shadow, if you have one, stretches slightly toward the lantern, as if it’d like a word.', maxKm: 0.8),
    Ambient('A jar sits on a wall. It’s empty. A tiny, hopeful label on the side: RETURN TO OWNER.', maxKm: 1),
    Ambient('~A shadow is the proof that you’re standing in the light. Somebody should say thank you for that.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'cross',
      title: 'THE CROSSROADS',
      km: 0.6,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => ['Mr. Penumbra was waiting for me at the crossroads. The shadows had something to say.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            if (_shade(c) == 'sold') '“I’ve kept it,” says Mr. Penumbra. “Your shadow. It’s been well looked after. I thought you might want it back. For a modest consideration.”',
            if (_shade(c) == 'freed') '“She’s been writing,” says Mr. Penumbra. “Mostly on my walls. She wants to meet you. I told her you’d be busy. She said, ‘He’s not.’”',
            if (_shade(c) == 'restored') '“We’ve returned all but one,” he says. “A boy of nine, who sold his for a sweet. He doesn’t want it. He says it’s too sad. I don’t know what to do.”',
            if (_shade(c) == 'shattered') '“They’re still loose,” he says. “All across the wasteland. They’re causing a bit of trouble. I thought you might help me round them up.”',
            if (_shade(c) == 'other') '“I thought you might return,” he says.',
          ],
          [
            Choice('[LISTEN TO HIM]', 'listen'),
            Choice('[ASK ABOUT THE LANTERN]', 'lantern'),
            Choice('[LOOK AT THE GROUND]', 'ground'),
          ],
        ),
        Scene.talk('listen', say(['He tells you, quietly, in his stillest voice, everything that has happened since. He has the look of a man who has been counting. “I’ve been very lonely,” he says. “It turns out you can’t rent loneliness.”']), [Choice('[CONTINUE]', 'end_c')]),
        Scene.talk('lantern', say(['“The lantern,” he says, “is the light that makes the dark. Every shadow starts here. If I put it out, they’d all be, for a moment, unmade. Or, I rather think, free.” He holds it very still. “I’ve never dared.”']), [Choice('[CONTINUE]', 'end_c')], flags: ['asked_lantern']),
        Scene.talk('ground', say(['You look down. In the last light, the ground ripples faintly. A hundred shadows are present at the edges of the road, at the feet of the grass, along the wall. They’re waiting. Not menacing. Waiting, like a congregation before a hymn.']), [Choice('[CONTINUE]', 'end_c')]),
        Scene.end('end_c', say(['“Come,” says Mr. Penumbra. “It is time for an arrangement.” He turns toward the stall. For a moment, you notice that his hand, as it reaches for the latch, trembles.'])),
      ],
    ),
    Checkpoint(
      id: 'dusk',
      title: 'THE ARRANGEMENT',
      km: 1.3,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['At the stall, the arrangement: lantern, shadows and a very tired man.'],
      scenes: [
        Scene.talk(
          'a',
          say(['The stall has been tidied. The Lumen Press is swathed in canvas. The shelf is bare. In the middle of the table stands the lantern, steady, with a single, pale flame. Mr. Penumbra folds his hands.']),
          [
            Choice('[SETTLE WITH HIM]', 'settle'),
            Choice('[PUT OUT THE LANTERN]', 'lights'),
            Choice('[REUNITE THE SHADOWS WITH THEIR OWNERS]', 'reunite'),
          ],
        ),
        Scene.talk('settle', say(['“A fair price,” you say. “A very fair one.” Mr. Penumbra names it. It’s small. It’s regular. It will, you realise, be your problem for a very long time. But it’s fair.']), [Choice('[AGREE]', 'end_rental')]),
        Scene.talk('lights', say(['You take hold of the lantern. “Are you sure?” whispers Mr. Penumbra. “I’m not,” you say. “But it’s time.” You lean in, and blow.']), [Choice('[WATCH IT GO DARK]', 'end_lights')]),
        Scene.talk('reunite', say(['You spend the evening walking the road with a hurricane lamp, whistling. One by one, the shadows come, and are given, with great ceremony, to people who’d never thought to ask. At dawn, there’s only one left: a very small, very reluctant boy’s, which you carry home in a jar.']), [Choice('[CONTINUE]', 'end_reunion')]),
        Scene.end('end_rental', say(['The first payment is a handshake. His palm is cool and dry. The shadow, when you step into the light, is back at your heels, a little thin, a little sheepish. It looks at you. You look at it. It’s the nicest thing you’ve owned in a month.']), ending: 'rental'),
        Scene.end('end_lights', say(['The flame goes out. For a moment, the crossroads is darker than night. Then, softly, all along the road, a whisper begins. It’s shadows, finding their feet. When you strike a match, Mr. Penumbra is standing in its light, wide-eyed, with a long, dark, slender shape at his heels. “Oh,” he says. “Hello.”']), ending: 'lights'),
        Scene.end('end_reunion', say(['By morning, the wasteland has been very slightly, quietly righted. A boy of nine stares at a jar, and the jar, with a long, shy, shining motion, stares back. “Hello,” he says. “I’m sorry I left.” The shadow writes, on the glass: ME TOO.']), ending: 'reunion'),
      ],
    ),
  ],
);
