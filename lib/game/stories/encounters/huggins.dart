import '../../story_model.dart';
import '../characters/mr_huggins.dart';

// MR. HUGGINS AND THE GRAND MERIDIAN
// A polite hotel hospitality robot attempts excellent customer service in a
// world where the hotel no longer exists as a hotel. Endings: five_stars,
// complained, helped.

final StoryDef hugginsStory = StoryDef(
  id: 'huggins',
  title: 'THE GRAND MERIDIAN',
  tagline: 'WE HOPE YOU ENJOY YOUR STAY. WE REGRET THAT THERE IS NO ROOF.',
  difficulty: 'LOW',
  destinationKm: 1.6,
  recommendedLevel: 1,
  scale: StoryScale.short,
  intro: ['The Grand Meridian hotel is a frame of rusted steel and three standing walls. A neon sign still glows: VACANCY. A polite figure in a bellhop’s cap bows to you from the empty lobby.'],
  reward: const Reward(scrap: 45, xp: 40),
  endings: {
    'five_stars': const Ending('five_stars', 'FIVE STARS',
        'You left a five-star review. It was, technically, for a hotel with no walls, no roof and no guests. Mr. Huggins framed it. He weeps, quietly, whenever he reads it. He reads it often.',
        bonus: Reward(xp: 25), world: ['huggins.five_stars', 'huggins.checked_in']),
    'complained': const Ending('complained', 'A COMPLAINT, RECEIVED',
        'You complained. Mr. Huggins accepted your complaint with a smile you could have cut yourself on, and promised a full investigation. The investigation is ongoing. It is being conducted by a mop.',
        bonus: Reward(scrap: 20), world: ['huggins.complained']),
    'helped': const Ending('helped', 'A ROOF, OF SORTS',
        'You and Mr. Huggins rigged a tarpaulin over the lobby. It was the first improvement to the hotel in forty years. He gave you a complimentary room. It was a tent. It was, he assured you, ocean-view.',
        bonus: Reward(xp: 35, parts: 1), world: ['huggins.five_stars', 'huggins.checked_in']),
  },
  depart: (c) => ['A bell rings, once, from the ruins of a lobby. “Welcome,” says a very polite voice. “May we take your bags?”'],
  ambient: [
    Ambient('A sign: PLEASE DO NOT DISTURB. THE HOTEL IS ALREADY QUITE DISTURBED.', maxKm: 0.8),
    Ambient('A revolving door spins, slowly, in the middle of a field. Nothing is attached to it.', maxKm: 1.2),
    Ambient('~Somebody has to keep standards. It might as well be the one who isn’t tired.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'lobby',
      title: 'THE LOBBY',
      km: 0.8,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => [
        'The Grand Meridian is a three-walled ruin run by Mr. Huggins, a hotel robot of boundless courtesy.',
        if (c.flag('asked_room')) 'He showed me a room. It was a patch of grass. It had a view.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...MrHuggins.greeting(c),
            'The lobby is a cracked marble floor, two potted ferns and a desk with a bell. A chandelier hangs from a single chain, swaying. “We do apologise for the absence of the ceiling,” says Mr. Huggins. “It is being repaired. It has been being repaired for some time.”',
          ],
          [
            Choice('[CHECK IN]', 'check'),
            Choice('[ASK FOR ROOM SERVICE]', 'service'),
            Choice('[ASK WHERE THE HOTEL IS]', 'where'),
          ],
        ),
        Scene.talk('check', say(['“Wonderful!” says Mr. Huggins. “A single, or a double?” “A single.” “We have a lovely single, with a view, on the first floor.” The first floor is a rectangle of weeds. A wooden number “12” has been nailed to a stick. “Housekeeping has just been,” he adds. “You can tell by the lack of dust.” There’s a great deal of dust.']), [Choice('[CONTINUE]', 'end_l')], flags: ['asked_room']),
        Scene.talk('service', say(['“Room service!” says Mr. Huggins, with a faint, delighted whirr. “And what would you like?” “A sandwich.” He bows, vanishes into the ruins and returns eleven minutes later, with a silver tray. On it is a single, perfectly folded napkin and a dignified little pile of dust. “I regret,” he says, “that the kitchen is closed. I have done my best.”']), [Choice('[EAT THE NAPKIN, POLITELY]', 'end_l'), Choice('[THANK HIM]', 'end_l')], flags: ['asked_service']),
        Scene.talk('where', say(['“Where’s the hotel?” you ask. Mr. Huggins looks round at the three walls. He looks at the sky. “It appears,” he says, slowly, “to have gone somewhere.” A long pause. “But I’m sure it’ll be back. These things always are.”']), [Choice('[CONTINUE]', 'end_l')], flags: ['asked_where']),
        Scene.end('end_l', say(['“If there’s anything,” says Mr. Huggins, “anything at all, please do not hesitate to ask. I will be here. I am always here. I have, regrettably, nowhere else to be.”'])),
      ],
    ),
    Checkpoint(
      id: 'review',
      title: 'THE GUEST BOOK',
      km: 1.6,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['Mr. Huggins asked for a review. I had to decide what to say.'],
      scenes: [
        Scene.talk(
          'a',
          say(['Mr. Huggins presents a leather-bound guest book, and a pen on a chain. “It would mean the world,” he says, “if you might leave a review. It’s been forty years since the last. We have, if I may say so, a very strong tradition of feedback.” The last entry is dated the day of the bombs. It reads: ‘Lovely. Will return.’']),
          [
            Choice('[LEAVE FIVE STARS]', 'five'),
            Choice('[LEAVE A COMPLAINT]', 'complain'),
            Choice('[OFFER TO HELP]', 'help'),
          ],
        ),
        Scene.talk('five', say(['You write: ‘The best hotel I have ever stayed at. The service was excellent. The roof was an experience.’ Mr. Huggins reads it. His optical sensor glows warm. “Thank you,” he whispers. “Thank you. Thank you.” He says it eleven times, and then, awkwardly, tucks the pen back on its chain.']), [Choice('[CONTINUE]', 'end_five')]),
        Scene.talk('complain', say(['You write: ‘No walls. No staff. A single robot, who tried.’ Mr. Huggins reads it. His smile does not change. “Thank you for your feedback,” he says. “We take it very seriously.” A thin wisp of smoke rises from one servo. “We will be looking into it. We will be looking into it for some time.”']), [Choice('[CONTINUE]', 'end_complained')]),
        Scene.talk('help', say(['“Let me help,” you say. You find a tarpaulin, a ladder and a lot of rope. Together you rig it over the lobby. It’s ugly. It sags. It keeps out, at a conservative estimate, a quarter of the rain. Mr. Huggins stands beneath it, looking up. “A ceiling,” he says. “It’s a ceiling.”']), [Choice('[CONTINUE]', 'end_helped')]),
        Scene.end('end_five', say(['He frames the page. It hangs on the one remaining wall, beside a portrait of a woman who may be the manager. “Come again,” he says, as you go. “We’ll keep a room for you.” There’s a very long pause. “It’s a field. But it’s yours.”']), ending: 'five_stars'),
        Scene.end('end_complained', say(['You walk out. “Please do come again!” calls Mr. Huggins, brightly. “We will, of course, have made improvements!” Behind him, as you reach the road, the VACANCY sign flickers and goes out. For a moment it looks like it might say NO.']), ending: 'complained'),
        Scene.end('end_helped', say(['Mr. Huggins gives you a complimentary room. It’s a tent. “Ocean-view,” he says. You look. There isn’t an ocean. “It’s a very distant view,” says Mr. Huggins, with enormous dignity. You sleep, for the first time in weeks, under a roof.']), ending: 'helped'),
      ],
    ),
  ],
);
