import '../../story_model.dart';
import '../story_kit.dart';

// THE EXTREMELY DANGEROUS BOX
// A box covered in increasingly alarming warning labels. Everyone insists it
// must not be opened. There are several ways to open it. What’s inside is
// the joke, and then, slightly, the point.
// Endings: opened, picked, left (and a small surprise for each).

List<Choice> _boxChoices() => [
      Choice('[READ THE LABELS]', 'b_labels', show: (c) => !c.flag('seen.labels')),
      Choice('[LISTEN AT THE BOX]', 'b_listen', show: (c) => !c.flag('seen.listen')),
      Choice('[ASK THE PEOPLE]', 'b_people', show: (c) => !c.flag('seen.people')),
      Choice('[DECIDE WHAT TO DO]', 'b_go'),
    ];

final StoryDef boxStory = StoryDef(
  id: 'box',
  title: 'THE EXTREMELY DANGEROUS BOX',
  tagline: 'DO NOT OPEN. DO NOT SHAKE. DO NOT LOOK DIRECTLY. DO NOT BE TEMPTED. DO NOT.',
  difficulty: 'LOW',
  destinationKm: 1.5,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: ['The box sits in the middle of a field, on a plinth, under a canopy. It is the size of a hat box. It is wrapped in chains, tape, wire and a very long series of labels, each more urgent than the last. A ring of people stand around it at a respectful distance, saying nothing.'],
  reward: const Reward(scrap: 60, xp: 50, stims: 1),
  endings: {
    'opened': const Ending('opened', 'OPENED',
        'You opened it. Nothing happened. Then, in a very small voice, something inside said, “Oh. Thank goodness. It was so dark.” A very small, very old woman in a bonnet climbed out. She was a cat. She had been in a box for forty years. She asked for a saucer.',
        bonus: Reward(xp: 40, stims: 1), world: ['box.opened']),
    'picked': const Ending('picked', 'PICKED CLEAN',
        'You picked the locks with the delicacy of a safecracker. The box opened with a click. Inside was a single folded note, in a very careful hand: IF YOU’VE GOT THIS FAR, WELL DONE. PLEASE CLOSE IT AGAIN. WE WERE ONLY TESTING.',
        bonus: Reward(scrap: 60, xp: 25), world: ['box.picked']),
    'left': const Ending('left', 'SOME THINGS ARE SAFER SHUT',
        'You left it where it was. It sat on its plinth, humming faintly, waiting for someone less sensible. You have never found out what was in it. You think about it, once a day, for the rest of your life.',
        bonus: Reward(xp: 30), world: ['box.left']),
  },
  depart: (c) => ['You cross the field. The ring of people turns as one. A very old man holds up a hand. “Please,” he says. “Whatever you’re thinking: don’t.”'],
  ambient: [
    Ambient('A sign on the road: SOMETHING IS IN THE FIELD. DO NOT ASK WHAT.', maxKm: 0.8),
    Ambient('A scarecrow in a hazmat suit stands near a fence. It is wearing two hazmat suits.', maxKm: 1),
    Ambient('A hush. A tiny, polite thump, from a long way off. As if a very small thing, in a very small space, had knocked.', minKm: 0.5),
    Ambient('~Warnings are written for the people most likely to ignore them. This is how you know it’s going to be good.', minKm: 1),
  ],
  checkpoints: [
    Checkpoint(
      id: 'field',
      title: 'THE FIELD',
      km: 0.7,
      art: 'wreck',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => [
        'The box is covered in labels: DO NOT OPEN, DO NOT SHAKE, DO NOT LOOK AT IT WITH A TONE.',
        if (c.flag('seen.listen')) 'There’s a very faint sound inside. It sounds like someone waiting.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'You step closer. The labels cover the whole box, in layers, like wallpaper. DANGER. EXTREME DANGER. SERIOUSLY. WE MEAN IT. DO NOT OPEN UNDER ANY CIRCUMSTANCES. Under that: THIS MEANS YOU. Under that, in smaller type: (YES, YOU.)',
          ]),
          _boxChoices(),
        ),
        Scene.talk(
          'b_labels',
          say([
            'You read the labels. Some of them are alarming: BIOHAZARD. RADIOACTIVE. CURSED. Some of them are less so: DO NOT FEED. DO NOT TELL IT ABOUT THE WAR. MIND THE CORNER. The last one, at the very bottom, is handwritten: PLEASE BE KIND.',
            '~That’s not the label of a thing that wants to hurt you.',
          ]),
          _boxChoices(),
          flags: ['seen.labels', 'be_kind'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'b_listen',
          say([
            'You press an ear to the box. A very faint scratching. A very faint tap. And, a long way inside, a voice, so thin you’re not sure whether you’re imagining it: “Hello? Is there anyone there? It’s been a long, long time.”',
            'The people behind you gasp. “It does that,” says someone. “We don’t listen.”',
          ]),
          _boxChoices(),
          flags: ['seen.listen', 'heard_voice'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'b_people',
          say([
            '“What’s in it?” you ask. They look at each other. “We don’t know,” says the old man. “It was here when we came. The one before us said not to open it. The one before that said the same. We just... all agreed. It’s very comfortable, not knowing.”',
            '“Has anyone tried?” “Once,” says the old man. “He came back changed.” “How?” “He was very, very polite.”',
          ]),
          _boxChoices(),
          flags: ['seen.people'],
        ),
        Scene.end('b_go', say(['The old man steps aside. “If you must,” he says. “We’ll be over there. We’ll be pretending we’re not watching.” They all, very elaborately, turn their backs.'])),
      ],
    ),
    Checkpoint(
      id: 'open',
      title: 'THE OPENING',
      km: 1.5,
      art: 'wreck',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 20),
      journal: (c) => ['I decided what to do about the box.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'It’s a very simple box. Under the chains, a little brass lock; under the lock, a simple catch; under the catch, a very small, faintly polite crack. There are, you count, at least four ways to open it.',
          ]),
          [
            Choice('[JUST OPEN THE LID]', 'lid'),
            Choice('[PICK THE LOCK]', 'pick'),
            skillChoice('ENGINEERING', 1, 'UNSCREW THE HINGES', 'hinge'),
            Choice('[LEAVE IT ALONE]', 'end_left'),
          ],
        ),
        Scene.talk(
          'lid',
          say([
            'You cut the chains. You peel off the tape. You lift the lid. For an entire second, you’re ready for anything. And then you look inside, and there is, quite simply, a very small cat, in a very small bonnet, sitting on a cushion and giving you a look of tremendous, affronted dignity.',
            '“Well,” says the cat. “You took your time.”',
          ]),
          [Choice('[CONTINUE]', 'end_opened')],
          flags: ['lid'],
        ),
        Scene.lock(
          'pick',
          say(['The lock is a handsome brass thing with a tiny keyhole shaped like a smile.']),
          win: 'picked',
          fail: 'lid',
        ),
        Scene.talk(
          'picked',
          say(['The lock opens with the softest click you’ve ever heard. Inside, on a velvet cushion, lies a single folded card. IF YOU’VE GOT THIS FAR: WELL DONE. WE WERE ONLY TESTING. PLEASE CLOSE IT AGAIN. THE OTHERS NEED TO FEEL SAFE.']),
          [Choice('[CLOSE IT AGAIN]', 'end_picked')],
        ),
        Scene.talk(
          'hinge',
          say(['You remove the hinges with a quick, neat twist. The box falls open at the side, without ever having been opened at the top. Inside is a small plush cushion, an empty saucer and a note: GONE FOR A WALK. BACK SOON. DON’T TELL ANYONE. You’re fairly sure the box has never been occupied by anything dangerous in its life.']),
          [Choice('[CONTINUE]', 'end_picked')],
          reward: const Reward(xp: 12),
        ),
        Scene.end('end_opened', say(['The cat steps out onto the grass, shakes herself, and looks at the sky. She’s very old. She’s very tired. She’s been in a box since the first bomb. A small, quiet, joyful sound escapes her, a purr like an engine starting for the first time in forty years. Behind you the ring of people turns, and lets out a single, enormous sigh.']), ending: 'opened'),
        Scene.end('end_picked', say(['You close the box again, very carefully. You put the card back, and the chains. You walk away. As you pass the old man, he asks, “Well?” You tell him it’s perfectly safe. He nods. “Good,” he says. “I’d hate to know.”']), ending: 'picked'),
        Scene.end('end_left', say(['You walk away. Behind you, from the box, you hear a long, thin, patient voice: “Oh. Another one.” You keep walking. You don’t look back. It’s a very good box.']), ending: 'left'),
      ],
    ),
  ],
);
