import '../../story_model.dart';

// A VERY CONFUSED GARY
// Follow-up to THE GARYS. A Gary from the bunker turns up. Which one depends
// on how that story ended (garys.companion, garys.escaped, garys.community,
// garys.shutdown...). Still NOT the shoe Gary. Still wears a blue jumpsuit that
// says gary in lowercase and nothing else.
// Endings: named, kept, rejoined.

String _which(StoryCtx c) {
  if (c.world('garys.companion')) return 'companion';
  if (c.world('garys.escaped')) return 'escaped';
  if (c.world('garys.community')) return 'community';
  if (c.world('garys.war')) return 'war';
  if (c.world('garys.leader')) return 'leader';
  if (c.world('garys.shutdown')) return 'shutdown';
  return 'other';
}

final StoryDef garysReturnStory = StoryDef(
  id: 'garys_return',
  title: 'A VERY CONFUSED GARY',
  tagline: 'ONE OF THEM FOLLOWED YOU HOME. HE HAS NOT WORKED OUT WHICH ONE.',
  difficulty: 'LOW',
  destinationKm: 1.3,
  recommendedLevel: 3,
  scale: StoryScale.short,
  unlock: const Unlock(anyDone: ['garys'], hint: 'FINISH THE GARYS FIRST.'),
  intro: ['A man in a blue jumpsuit sits on a rock by the road, watching a beetle. On his chest, in black marker, one lowercase word: gary. When he sees you he stands up, delighted, and then, very slowly, uncertain.'],
  reward: const Reward(scrap: 50, xp: 45),
  endings: {
    'named': const Ending('named', 'A NAME OF HIS OWN',
        'You asked him what he wanted to be called. He thought for a very long time. He said “Gary,” and then, quietly, “but a different one.” He’s writing it on the inside of his jumpsuit in a smaller hand. It says gary. It means something else.',
        bonus: Reward(xp: 35), world: ['garys.named']),
    'kept': const Ending('kept', 'KEEPING GARY',
        'He asked if he could stay. You said yes. He sleeps in a corner, polite and curled, and wakes up every morning with a start. “It’s big,” he says, every time, about the sky. You tell him it is.',
        bonus: Reward(xp: 40, stims: 1), world: ['garys.kept', 'favour.gary_bunker']),
    'rejoined': const Ending('rejoined', 'BACK TO THE BUNKER',
        'You walked him home. The other Garys met him at the hatch, all talking at once. “WHERE WERE YOU?” “I WAS ORIGINAL.” “NO, I WAS.” He turned to you. “Thank you,” he said. “It was lovely out there. I think I’d like to argue about it.”',
        bonus: Reward(scrap: 40), world: ['garys.rejoined']),
  },
  depart: (c) {
    switch (_which(c)) {
      case 'companion':
        return ['You hear a voice behind you. “Hello! Hello! I found another rock!” It’s the Gary who came with you, from the bunker. He is carrying it with great care.'];
      case 'escaped':
        return ['A stray Gary has split from the great blue column, which is still bickering its way toward the horizon. He looks tired, and a bit lost.'];
      case 'community':
        return ['A Gary has walked out of the bunker, a little ahead of the others, and is blinking at the sky. “I’m just checking,” he says. “It was a bit loud in there.”'];
      case 'war':
        return ['A Gary appears from the direction of the bunker, with a filing cabinet drawer for a shield. “I’m a pacifist,” he says. “Please don’t tell either side.”'];
      case 'leader':
        return ['A Gary in a tie sits on a rock, with the face of a man who’s been very, very thoroughly managed. “I’m on a break,” he says. “I’ve been promoted. It’s awful.”'];
      case 'shutdown':
        return ['A Gary stands in the road, with a mug. “It was very quiet,” he says. “After. I came out to find some noise.”'];
      default:
        return ['A Gary sits on a rock.'];
    }
  },
  ambient: [
    Ambient('A beetle walks across a rock. A man in a blue jumpsuit watches it with enormous respect.', maxKm: 0.8),
    Ambient('A small chalk drawing on a wall: a stick figure in a jumpsuit, with the word gary. Beneath it, a hundred tiny scratched copies.', maxKm: 1),
    Ambient('~Everyone is the original of something. The trick is working out what.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'rock',
      title: 'THE ROCK',
      km: 0.6,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => ['A Gary from the bunker has been wandering. He talks to rocks. He is not the Gary with the shoes.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            '“Hello,” he says. “You’re the one. From the bunker. I remember you. You asked me a question and I said I was the original.” He looks, with great sadness, at his own hands. “I’m not sure I am. I’m not sure it matters. I’d like to ask you something.”',
          ]),
          [
            Choice('[ASK WHAT HE WANTS]', 'ask'),
            Choice('[ASK ABOUT THE ROCK]', 'rock'),
            Choice('[TELL HIM ABOUT THE GARY WITH SHOES]', 'shoes'),
          ],
        ),
        Scene.talk('ask', say(['“I want to know who I am,” he says. “The others never asked. They were too busy being right. But I sit here and look at the sky, and think: I’m not them. I’m not even sure I’m me. I’m just... a bit of a man, wearing a word.”']), [Choice('[CONTINUE]', 'end_r')]),
        Scene.talk('rock', say(['“It’s called Colin,” he says. “It’s the first thing I’ve ever named. I’m very proud of it. I think it’s a good name. It’s a bit... rocky.” He pats it. “I’ve told it everything. It’s an excellent listener.”']), [Choice('[CONTINUE]', 'end_r')], flags: ['colin']),
        Scene.talk('shoes', say(['“There’s another Gary?” he says, wide-eyed. “One who’s... real?” “He’s real,” you say. “He’s lost forty-one shoes.” The Gary in the jumpsuit stares. “I want to meet him,” he says, with the beginnings of a smile. “Oh, I want to meet him very much.” You decide this is a bad idea. You decide it’s also, probably, going to happen.']), [Choice('[CONTINUE]', 'end_r')]),
        Scene.end('end_r', say(['“Would you walk with me?” he says. “Just a bit. I’ve been walking in circles, and I think I’d like a direction.”'])),
      ],
    ),
    Checkpoint(
      id: 'choice',
      title: 'A DIRECTION',
      km: 1.3,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['I walked a Gary down a road. He was looking for a direction.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'You walk together for half an hour. He’s quiet, mostly. At a fork in the road, he stops. “Left is the way to the bunker,” he says. “Right is the way to... everything else. I’d like to choose. I’ve never chosen.”',
            'He looks at you, hopefully. “What should I call myself?” he says. “Gary doesn’t feel like mine.”',
          ]),
          [
            Choice('[“CHOOSE YOUR OWN NAME.”]', 'name'),
            Choice('[“STAY WITH ME.”]', 'keep'),
            Choice('[“GO HOME.”]', 'home'),
          ],
        ),
        Scene.talk('name', say(['He thinks for a long time. He takes the marker from his pocket. He looks at his chest. After a minute, he says, in a voice like a man stepping into cold water: “I’m going to stay Gary. But I’m going to mean it differently.” He smiles. “It’s a lot nicer when you decide.”']), [Choice('[CONTINUE]', 'end_named')]),
        Scene.talk('keep', say(['“Could I?” he says. “Really? I’d be no trouble. I can sit. I’m very good at sitting.” You say you’d like that. He hugs you. It’s a quick, bony, astonished hug. He smells of tea and starch and, faintly, of an unopened sky.']), [Choice('[CONTINUE]', 'end_kept')]),
        Scene.talk('home', say(['“Home,” he says. “Yes. Of course.” He nods. He straightens his jumpsuit. “It was nice to see the sky,” he says. “It’s very big. I’ll tell them.” You walk him to the hatch. On the way down, a hundred voices rise together: “WHERE HAVE YOU BEEN?”']), [Choice('[CONTINUE]', 'end_rejoined')]),
        Scene.end('end_named', say(['He draws a very small, very neat line under the word on his chest. “That’s me,” he says. “Gary. Underlined.” He gives you a gentle, delighted look. “Thank you. For asking.”']), ending: 'named'),
        Scene.end('end_kept', say(['He walks beside you, down the road, telling Colin the rock all about it. You carry the rock. It’s heavier than you thought. He is, you realise, going to need a lot of company, and so, you suspect, are you.']), ending: 'kept'),
        Scene.end('end_rejoined', say(['The hatch closes. Through the steel, you can hear a hundred voices, all at once, arguing. And in the middle, a single, small, glad one: “...I WAS THE ORIGINAL, AND I WENT FOR A WALK.”']), ending: 'rejoined'),
      ],
    ),
  ],
);
