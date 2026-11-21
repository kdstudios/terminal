import '../../story_model.dart';

// THE LAST RADIO DJ
// DJ Sunny Dave Delight (a different Dave, ordinary only in the sense of being
// extremely not) broadcasts cheerful music and terrible jokes to an audience
// that may no longer exist. Endings: listener, caller, silence.

final StoryDef djStory = StoryDef(
  id: 'dj',
  title: 'THE LAST RADIO DJ',
  tagline: 'HE’S LIVE. HE’S LOVING IT. HE HAS NOT HAD A LISTENER SINCE THE BOMBS.',
  difficulty: 'LOW',
  destinationKm: 1.6,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: ['A tower on a hill, a cabin at its foot and, from a loudspeaker, a voice like warm toast: “THAT WAS A TRACK, FOLKS. THIS IS A DEEPLY NICE DAY TO BE ALIVE. WHAT COULD POSSIBLY BE WRONG? STAY TUNED FOR THE WEATHER, WHICH IS, AS ALWAYS, DUST.”'],
  reward: const Reward(scrap: 50, xp: 45),
  endings: {
    'listener': const Ending('listener', 'A LISTENER AT LAST',
        'You told him you’d been listening. He went completely silent for the first time in forty years. Then he said, very quietly, “Hello, listener,” and played you a song he had saved for exactly this moment.',
        bonus: Reward(xp: 25, stims: 1), world: ['dj.listener']),
    'caller': const Ending('caller', 'YOU’RE ON THE AIR',
        'You took a call. You told the empty wasteland a joke. It was a bad one. Somewhere, a hundred kilometres away, someone laughed, and it was the loveliest sound in the world. He has asked you to be a regular.',
        bonus: Reward(xp: 35), world: ['dj.caller']),
    'silence': const Ending('silence', 'DEAD AIR',
        'You pulled the plug on the broadcast. The silence went on for a long time. He thanked you. “I wasn’t sure how to stop,” he said, and he wasn’t crying, and then he was.',
        bonus: Reward(scrap: 30), world: ['dj.silence']),
  },
  depart: (c) => ['You walk toward the tower, and the voice gets louder, and, strangely, warmer: “...AND IF YOU’RE OUT THERE, IF ANYONE’S OUT THERE, THIS ONE’S FOR YOU.”'],
  ambient: [
    Ambient('A battered transistor radio hangs on a fence post, crackling with a very distant, very cheerful jingle.', maxKm: 0.8),
    Ambient('A hand-painted sign: LISTEN LIVE. LISTEN EVER. LISTEN, PLEASE.', maxKm: 1.2),
    Ambient('Someone has hung a hundred tin cans from a pylon, each with a wire. They’re all pointed at the tower.', minKm: 0.5),
    Ambient('~There’s a certain kind of faith in speaking into the dark every day. It doesn’t need an answer.', minKm: 1),
  ],
  checkpoints: [
    Checkpoint(
      id: 'booth',
      title: 'THE BOOTH',
      km: 0.8,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => [
        'The last radio DJ is a cheerful, rumpled man who broadcasts to nobody.',
        if (c.flag('seen.jokes')) 'His jokes are very bad. I laughed at one anyway.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The booth is a shed with a tin roof, a microphone the size of a fist and a hundred hand-labelled records. At the desk, in a headset and a Hawaiian shirt, sits a man with a broad grin and the tired eyes of a lighthouse keeper.',
            'He spots you through the glass and goes briefly silent. The microphone hisses. “Folks,” he says, very slowly, “we have, um, a visitor.”',
          ]),
          [
            Choice('[ASK ABOUT THE BROADCAST]', 'bc', show: (c) => !c.flag('seen.bc')),
            Choice('[LISTEN TO A JOKE]', 'joke', show: (c) => !c.flag('seen.jokes')),
            Choice('[ASK WHO’S LISTENING]', 'who'),
          ],
        ),
        Scene.talk(
          'bc',
          say([
            '“Twenty-four hours,” he says. “Every day. I play the greatest hits, I tell the jokes, I do the weather. It’s always dust.” He grins. “I’ve not missed a slot since the war. Some days, it’s the only thing I’m sure of.”',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['seen.bc'],
        ),
        Scene.talk(
          'joke',
          say([
            '“Why did the scavenger cross the road?” says the DJ. “To get to the other side of the debt!” He waits. There’s a very long pause. “That one,” he says, “always kills.” You laugh. It’s a very bad joke, but you laugh anyway, and his face lights up, and he goes pink to the roots of his hair.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['seen.jokes', 'laughed'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'who',
          say([
            '“Who’s listening?” you ask. The DJ goes quiet. He looks at the dials, at the cans on the pylon, at his own hands. “I don’t know,” he says. “I’ve never had a call. I’ve never had a letter. Not a single one. I just... I assume. You have to assume. It’s the only way it works.”',
          ]),
          [Choice('[CONTINUE]', 'end_booth')],
          flags: ['asked_who'],
          reward: const Reward(xp: 8),
        ),
        Scene.end('end_booth', say(['He takes off his headset and sets it carefully on the desk. “It’s nearly time for the hourly,” he says. “Would you like to... would you like to say something? On air?”'])),
      ],
    ),
    Checkpoint(
      id: 'air',
      title: 'ON AIR',
      km: 1.6,
      art: 'signal',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['I went on air. I didn’t know what to say.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The red light comes on. The microphone is warm. The DJ holds up a hand to count you in: three, two, one. His eyes are very bright.',
            'You can hear the tin cans humming, out on the pylon, picking up your breath. For a moment you imagine a thousand ears at the other end of a very long wire.',
          ]),
          [
            Choice('[SAY YOU’VE BEEN LISTENING]', 'listen'),
            Choice('[TELL A JOKE]', 'joke'),
            Choice('[PULL THE PLUG]', 'plug'),
          ],
        ),
        Scene.talk('listen', say(['“I’ve been listening,” you say. “For months. I heard you on the way over.” It’s not quite true. It isn’t quite a lie. The DJ takes off his headset very slowly. He puts his face in his hands.']), [Choice('[CONTINUE]', 'end_listener')]),
        Scene.talk('joke', say(['You tell the one about the mutant who walks into a bar. It’s dreadful. You ruin the punchline. The DJ is in fits. “Oh, folks,” he says, into the microphone, “that’s a keeper.” And somewhere, very faintly, over the hills, you hear the sound of one person laughing.']), [Choice('[CONTINUE]', 'end_caller')]),
        Scene.talk('plug', say(['You reach for the master switch. The DJ looks up. He’s not angry. “Go on,” he says. “It’s all right. It’s just that I don’t know how to stop on my own.”']), [Choice('[PULL IT]', 'end_silence')]),
        Scene.end('end_listener', say(['“Hello, listener,” he says, very softly, into the empty room. He puts on a record. It’s a slow, silly, beautiful song. He sways to it, with his eyes closed. You stay for the whole thing. It’s the only time in forty years the broadcast has had a second person in the room.']), ending: 'listener'),
        Scene.end('end_caller', say(['You’re a regular for the next hour. He calls you “our caller from the wasteland.” You take a request, from nobody. You play a song, for nobody. It’s the best radio show you’ve ever been on. There’s no one listening, and everyone is.']), ending: 'caller'),
        Scene.end('end_silence', say(['The light goes out. The tin cans on the pylon go still. The DJ sits very quietly for a minute, and then says, to the empty room, “That’s all, folks.” He’s smiling. He doesn’t look like he knows he’s crying.']), ending: 'silence'),
      ],
    ),
  ],
);
