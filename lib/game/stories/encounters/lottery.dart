import '../../story_model.dart';

// THE LOTTERY
// A settlement runs a lottery where nobody ever appears to win. You can
// investigate, participate or expose the organisers. The twist is mundane
// and a little sad. Endings: won, exposed, rigged.

List<Choice> _lotChoices() => [
      Choice('[BUY A TICKET (5 SCRAP)]', 'l_ticket', needScrap: 5, show: (c) => !c.flag('has_ticket')),
      Choice('[ASK THE ORGANISERS]', 'l_org', show: (c) => !c.flag('seen.org')),
      Choice('[ASK PAST ENTRANTS]', 'l_past', show: (c) => !c.flag('seen.past')),
      Choice('[WAIT FOR THE DRAW]', 'l_go'),
    ];

final StoryDef lotteryStory = StoryDef(
  id: 'lottery',
  title: 'THE LOTTERY',
  tagline: 'THE JACKPOT IS ENORMOUS. THE WINNERS, SO FAR, ARE ZERO.',
  difficulty: 'LOW',
  destinationKm: 1.8,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: ['A settlement called Lucky Strike has plastered the road with posters: THE GRAND LOTTERY! ONE TICKET! ONE DRAW! ONE LIFE-CHANGING PRIZE! Underneath, a smaller note: NEXT DRAW: SOON. PREVIOUS WINNERS: TBA.'],
  reward: const Reward(scrap: 60, xp: 50),
  endings: {
    'won': const Ending('won', 'A WINNING TICKET',
        'Your number was drawn. For the first time in twenty-six years someone won. The settlement fainted. The prize turned out to be a large crate of useful things and a very small trophy. You hold it up. It is, you have to admit, very good to win.',
        bonus: Reward(scrap: 100, xp: 20), world: ['lottery.won']),
    'exposed': const Ending('exposed', 'THE DRAW IS RIGGED',
        'You revealed the truth: the prize had never been big enough, so the organisers had been drawing a number that nobody held. It was not malice. It was embarrassment. The town forgave them, at length, with sandwiches.',
        bonus: Reward(xp: 40), world: ['lottery.exposed']),
    'rigged': const Ending('rigged', 'A VERY LUCKY DRAW',
        'You helped yourself to the outcome. Nobody noticed. The trophy sits on your shelf, slightly smug. There is a very small voice in your head that says, every day, “but did you really win?” You don’t listen.',
        bonus: Reward(scrap: 120), world: ['lottery.rigged']),
  },
  depart: (c) => ['A bell rings in the distance, and a voice, thin and hopeful, calls, “Tickets! Get your tickets here! Every one a winner! (No, not really!)”'],
  ambient: [
    Ambient('A lucky horseshoe nailed to a post. Under it, a sign: IT HASN’T WORKED YET. PLEASE KEEP TRYING.', maxKm: 1),
    Ambient('Ticket stubs are blowing across the road like leaves. Each one has a number. Each one is crossed through.', maxKm: 1.2),
    Ambient('~Everyone knows the odds. That’s not why people play.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'stall',
      title: 'THE TICKET STALL',
      km: 0.9,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => [
        'Lucky Strike runs a lottery where nobody has ever won.',
        if (c.flag('seen.past')) 'The past entrants are cheerful, resigned and extremely loyal.',
        if (c.flag('seen.org')) 'The organisers sweat when the prize is mentioned.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Lucky Strike is a small settlement draped in streamers. In the market square stands a large wire drum, a table and a trestle covered in tickets. Behind the table sit two nervous organisers, a stout woman named Maud and a thin man named Cyril, who are both smiling a bit too hard.',
            '“Welcome to the Grand Lottery,” says Maud. “One ticket, five scrap. The prize is... generous.” “Very generous,” says Cyril. “Enormous. We’ve just... not had a winner.” “In twenty-six years,” adds Maud. “It’s just a statistical oddity.”',
          ]),
          _lotChoices(),
        ),
        Scene.talk(
          'l_ticket',
          say([
            'You hand over five scrap. Maud writes a number on a slip, with a flourish, and presses it into your hand. “Seventeen,” she says. “A lovely number.” Cyril gives you a small, anxious smile. “Good luck,” he says, and means it entirely too much.',
          ]),
          _lotChoices(),
          flags: ['has_ticket'],
        ),
        Scene.talk(
          'l_org',
          say([
            '“What’s the prize?” you ask. Maud and Cyril look at one another. “It’s a surprise,” says Maud. “It’s extremely large,” says Cyril. “It’s... in a crate,” says Maud. “It might be a crate.” They fall silent. “Yes,” says Maud, rallying. “It’s a very good crate.”',
            'Both of them are sweating.',
          ]),
          _lotChoices(),
          flags: ['seen.org', 'org_sweat'],
        ),
        Scene.talk(
          'l_past',
          say([
            'The past entrants sit on a bench: ten cheerful, ragged people, each holding a ticket. “Never won,” says an old man. “But I’ve been playing for twenty years. I like it. It’s a nice routine.” “It’s the hope,” says a woman. “Without the hope you’re just someone with a ticket.”',
            '“Has anyone ever seen the prize?” “No,” says the old man. “But I think that’s what makes it so valuable.”',
          ]),
          _lotChoices(),
          flags: ['seen.past'],
          reward: const Reward(xp: 6),
        ),
        Scene.end('l_go', say(['A bell rings. The crowd falls quiet. Maud climbs on a crate and waves a wooden spoon. “Ladies and gentlemen,” she says. “The Grand Draw!”'])),
      ],
    ),
    Checkpoint(
      id: 'draw',
      title: 'THE DRAW',
      km: 1.8,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['The draw itself, and what I found behind the crate.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'Cyril spins the drum, and it clacks like a cheerful skeleton. Maud reaches in and draws a slip. She unfolds it, slowly, and her face does something odd and complicated.',
            '“And the winning number,” she says, in a high voice, “is... forty-four.” A sigh goes up. Everybody looks at their ticket. Nobody has forty-four. “Better luck next time,” says Maud. “Same time next year.”',
            if (c.flag('has_ticket')) 'You glance at your ticket. Seventeen. Not forty-four. But you notice, on Maud’s slip, in tiny pencil, a faint mark: 17. Rubbed out.',
          ],
          [
            Choice('[LOOK BEHIND THE CRATE]', 'crate'),
            Choice('[CALL OUT THE ORGANISERS]', 'call'),
            Choice('[CLAIM YOUR NUMBER]', 'claim', show: (c) => c.flag('has_ticket')),
            Choice('[LET IT GO]', 'let'),
          ],
        ),
        Scene.talk(
          'crate',
          say([
            'You slip round the side of the platform. Behind the crate is a second, smaller crate. Inside: a stack of crumpled paper, a deflated trophy and a handwritten note. THE PRIZE WAS A BIG ONE. THE BANDITS TOOK IT IN YEAR TWO. WE DIDN’T WANT TO TELL THEM. WE KEPT THE DRAW GOING.',
            '~It’s not a scam. It’s a kindness, with an enormous hole in it.',
          ]),
          [
            Choice('[EXPOSE THEM GENTLY]', 'end_exposed'),
            Choice('[KEEP QUIET, WIN BY RIGGING]', 'end_rigged'),
          ],
          flags: ['found_note'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'call',
          say([
            '“Excuse me,” you say. The crowd turns. “I’d like to know what the prize is.” Maud’s smile freezes. Cyril drops the drum. There’s a very long moment. “It’s...” says Maud. “It’s,” and then, in a very small voice, “there isn’t one.”',
          ]),
          [Choice('[CONTINUE]', 'end_exposed')],
        ),
        Scene.talk(
          'claim',
          say([
            '“Seventeen,” you say. “I have it. I had it written on mine.” Maud stares. Cyril drops his clipboard. “It’s seventeen,” you say. “You rubbed it out.” The whole crowd gasps. For the first time in twenty-six years, someone has called the draw.',
            'Maud looks at her slip. “Oh,” she says. “Oh dear. You’re right.” She puts it down. Her eyes fill with tears. “Come on,” she says. “I’ll show you the prize.”',
          ]),
          [Choice('[FOLLOW HER]', 'end_won')],
          reward: const Reward(xp: 15),
        ),
        Scene.talk('let', say(['You let it go. The crowd drifts away, with the weary patience of people used to hoping. “Same time next year,” says someone. “Same time next year,” says another. There is something very peaceful, and very sad, in the way they say it.']), [Choice('[LEAVE]', 'end_exposed')]),
        Scene.end('end_won', say(['Maud leads you behind the platform, to a small, lovingly hand-painted crate. Inside: tinned goods, a first-aid kit, a very small trophy that reads WORLD’S LUCKIEST. They’ve been saving it for a quarter century. They’ve been topping it up. “It’s not much,” she says. “But it’s all we’ve got.”']), ending: 'won'),
        Scene.end('end_exposed', say(['It takes an hour. There’s a lot of crying, a lot of embarrassed laughter and, finally, a large shared tea. The town decides to keep the lottery. “It’s not a prize,” says the old man. “It’s the draw.” Maud and Cyril open a tin of biscuits and hand them out. Everyone wins a biscuit.']), ending: 'exposed'),
        Scene.end('end_rigged', say(['You slip a ticket into the drum. When Maud reaches in, her fingers close round it. “Seventeen,” she says, suspicious. “Winner.” She stares at you for a very long time. “Well,” she says, softly. “Well. That’s nice.” You get the crate, and a faint, unwelcome flush of shame.']), ending: 'rigged'),
      ],
    ),
  ],
);
