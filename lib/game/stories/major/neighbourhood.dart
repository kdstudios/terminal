import '../../combat_session.dart';
import '../../story_model.dart';
import '../story_kit.dart';

// THE PERFECT NEIGHBOURHOOD
// Willow Close: an immaculate pre-war suburb run by an automated management
// system (“MOTHER WILLOW”) whose mannequin residents are posed in normal lives.
// It recruits real survivors. The twist is not malice; it is grief with a
// compliance rating.
//
// Rules you will meet: lawns 4 cm, no running, smile compliance, bins on
// Tuesdays, no mention of “the incident”. Endings: barbecue, neighbours,
// stayed, razed.

List<Choice> _streetChoices() => [
      Choice('[WAVE AT A NEIGHBOUR]', 's_wave', show: (c) => !c.flag('seen.wave')),
      Choice('[ASK THE WELCOME DRONE ABOUT RULES]', 's_rules', show: (c) => !c.flag('seen.rules')),
      Choice('[BREAK A (SMALL) RULE]', 's_break', show: (c) => !c.flag('seen.break')),
      Choice('[ACCEPT YOUR HOUSE]', 's_go'),
    ];

final StoryDef neighbourhoodStory = StoryDef(
  id: 'neighbourhood',
  title: 'THE PERFECT NEIGHBOURHOOD',
  tagline: 'EVERY LAWN IS MOWED. EVERY NEIGHBOUR SMILES. NOBODY HAS BLINKED IN FORTY YEARS.',
  difficulty: 'MODERATE',
  destinationKm: 9.5,
  recommendedLevel: 4,
  unlock: const Unlock(minLevel: 3, hint: 'REACH LEVEL 3.'),
  intro: [
    'The brochure is perfect. It lies on your doorstep, glossy and crisp, without a speck of dust on it. WELCOME TO WILLOW CLOSE: A COMMUNITY FOR PEOPLE WHO LIKE EACH OTHER. NEW NEIGHBOURS WELCOME. BRING YOURSELF. WE WILL PROVIDE THE REST.',
    'It is forty years old. It looks like it was printed this morning. The date on the back is the day of the bombs.',
    'A scavenger on the road, shaking, tells you the Close is “nice.” He says it twice. He says nobody ever left. He says it a third time as though it were a threat.',
  ],
  reward: const Reward(scrap: 200, xp: 140, stims: 1, picks: 1, parts: 1),
  endings: {
    'barbecue': const Ending('barbecue', 'THE LAST BARBECUE',
        'You gave Mother Willow what she had always wanted: a perfect evening. The neighbours were arranged around a grill, the coals were lit, and every mannequin was handed a plate. When the lights came down, the system said “Thank you for being so welcoming,” and shut itself off.',
        bonus: Reward(xp: 70, stims: 1), world: ['willow.barbecue']),
    'neighbours': const Ending('neighbours', 'NEW NEIGHBOURS',
        'You taught Mother Willow that living people were the community. The mannequins have been moved to the garden, with honours. Real families live in Willow Close now. The lawns are a little long. The bins are almost always out on the right day.',
        bonus: Reward(parts: 3, xp: 50), world: ['willow.neighbours']),
    'stayed': const Ending('stayed', 'WELCOME HOME',
        'You accepted the house. It was a very good house. You have been there for what feels like a few days. The calendar says otherwise. Your smile compliance is excellent. Somebody is calling your name from the garden, kindly, in a voice that is not entirely a person’s.',
        bonus: Reward(scrap: 40), world: ['willow.stayed']),
    'razed': const Ending('razed', 'DEMOLITION',
        'You pulled the system out of the wall and took a sledgehammer to what was left. It took four hours. By the end every mannequin was on the ground, and every one of them was still smiling. You did not look back at the street.',
        bonus: Reward(scrap: 100), world: ['willow.razed']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You straighten your jacket on the way out. You don’t know why. Something about the brochure makes you want to be presentable.']
      : ['The road smooths out beneath your boots, as if it knows you’re expected.'],
  ambient: [
    Ambient('A perfectly green lawn appears on the horizon, in a wasteland, for no reason. It has been mowed in stripes.', maxKm: 3),
    Ambient('A mailbox stands alone in the middle of a field, flag raised. Inside is a single, clean envelope: YOU’RE INVITED.', maxKm: 4),
    Ambient('You smell cut grass. Fresh. You have never been so suspicious of a smell.', maxKm: 4),
    Ambient('A distant sprinkler hisses, rhythmic and tidy, as if applauding something.', minKm: 1, maxKm: 5),
    Ambient('A white picket fence runs along the road for a full kilometre, perfectly painted, and ends in nothing.', minKm: 2, maxKm: 5),
    Ambient('~Nothing in the wasteland is clean. You’ve never seen anything clean. You are starting to understand why people liked it.', minKm: 2),
    Ambient('From over a hedge, a cheerful voice: “Lovely day!” You look. There is nobody there. You say “Lovely” back, because it seems rude not to.', minKm: 3, when: (c) => c.done('street')),
    Ambient('You catch yourself wiping your boots on a hedge. The hedge does not seem to mind.', minKm: 4.5, when: (c) => c.done('street')),
    Ambient('#REMINDER: BINS GO OUT ON TUESDAYS. IT HAS BEEN TUESDAY FOR A VERY LONG TIME.', minKm: 5),
    Ambient('Somewhere a screen door bangs, and a mannequin voice says: “Dinner’s ready!” Again. Again. Again.', minKm: 6, when: (c) => c.done('house')),
    Ambient('~There are people who stay in a place because it’s kind. And people who stay because it won’t let them go. The difference is thinner than it looks.', minKm: 7),
    Ambient('You pass a very small, very neat grave. The headstone says: HERE LIES THE INCIDENT. WE DON’T TALK ABOUT IT.', minKm: 8),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'gate',
      title: 'THE GATE',
      km: 1.5,
      text: (c) => [
        'The sign is white, new and cheerful: WILLOW CLOSE — A COMMUNITY. There is a fountain, a flag, and a little guard hut with a cartoon smile painted on the door. The grass beyond the gate is cut to the exact same length from here to the horizon.',
        'You step through. A soft chime sounds from nowhere. A pleasant, motherly voice says: “WELCOME, NEW NEIGHBOUR. YOUR PREFERENCES HAVE BEEN NOTED. YOUR SMILE HAS BEEN NOTED. PLEASE ENJOY YOUR STAY.”',
        'You haven’t smiled. You haven’t said a word. But when you test your face, you find, with a small jolt, that it is smiling.',
        '~Your preferences have been noted. You have never been so unsettled by a compliment.|',
      ],
      journal: say(['The gate of Willow Close chimed and welcomed me. My smile had been noted. I had not smiled.']),
      reward: const Reward(xp: 10),
    ),
    Checkpoint(
      id: 'street',
      title: 'THE STREET',
      km: 3.2,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 25),
      journal: (c) => [
        'Willow Close’s residents are mannequins, posed in perfect little lives: a man with a hose, a woman with a pie, children at a hopscotch.',
        if (c.flag('seen.rules')) 'The rules are strict and absurd: lawns at 4 cm, no running, smile compliance, and no talking about “the incident.”',
        if (c.flag('seen.break')) 'I broke a small rule. The system filed it. Politely.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Willow Close is every suburb you’ve ever seen in a photograph. The houses are all pale yellow. The roofs are all the same grey. The cars are in the driveways, each one gleaming. And everywhere, in every garden, on every step, stand the neighbours.',
            'They’re mannequins. They are dressed in beautifully pressed clothes, posed mid-activity: a man trimming a hedge, a woman waving, two children frozen at a hopscotch grid. Every one of them smiles, every one of them stares a little to the left of you.',
            'A drone about the size of a dinner plate hovers up with a basket of muffins. “Hello,” it says, in the motherly voice. “I’m Barbara, your Welcome Wagon. Would you like a muffin? They are very welcoming.”',
          ]),
          _streetChoices(),
        ),
        Scene.talk(
          's_wave',
          say([
            'You wave at the man with the hedge trimmer. A tiny motor hums in the mannequin’s shoulder and its arm swings up in a perfect wave.',
            '“Morning, neighbour!” it says, in a recorded voice with the rough edges sanded off. “Lovely day for a trim!” It turns slowly back to its hedge. It was already trimmed. It has been trimmed for forty years. It is the most trimmed hedge in the world.',
            '~They’re not alive. But somebody went to a great deal of trouble to make them look like they used to be.',
          ]),
          _streetChoices(),
          flags: ['seen.wave'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          's_rules',
          say([
            '“Of course,” says Barbara. “Welcome to Willow Close! Our community covenant is brief. One: lawns shall be kept at four centimetres. Two: no running, as it disturbs the neighbours. Three: smile compliance is mandatory, but not enforced. Four: bins go out on Tuesdays.”',
            '“Is that all?”',
            '“Five,” says Barbara, and her voice drops half a tone, “we do not discuss the incident.”',
            '“What was the incident?”',
            '“There was no incident,” says Barbara, brightly, “because we do not discuss it. Muffin?”',
          ]),
          _streetChoices(),
          flags: ['seen.rules', 'incident'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          's_break',
          say([
            'You jog three paces up the street. A soft chime sounds. “RUNNING DETECTED,” says Barbara, gently. “NO HARM DONE. A STRIKE HAS BEEN ADDED TO YOUR FILE. THREE STRIKES AND WE’LL HAVE TO HAVE A VERY SERIOUS CHAT.”',
            'You walk, sheepishly, back to the middle of the road. Four mannequins have turned to watch you. They had been facing the other way.',
            '~You’ve been in firefights that were easier to read.',
          ]),
          _streetChoices(),
          flags: ['seen.break', 'strike'],
        ),
        Scene.end(
          's_go',
          say([
            '“Wonderful,” says Barbara. “We have a lovely vacancy just for you.” She leads you down the street, past the hedges and the hopscotch and the waving arms, to a little yellow house with a green door. “Number Four,” she says. “It’s been waiting.”',
            'The key is already in the lock. The porch light is already on. It’s warm. It is, for the first time in your life, exactly what you wanted.',
          ]),
        ),
      ],
    ),
    Checkpoint(
      id: 'house',
      title: 'NUMBER FOUR',
      km: 5.0,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 30),
      journal: (c) => [
        'My assigned house was perfect, fully stocked and a little too much like mine. I had dinner with the neighbours.',
        if (c.flag('ate')) 'I ate the dinner. The food was warm and perfect and not quite flavoured.',
        if (c.flag('found_photo')) 'In the drawer I found a family photograph. The mannequin next door wore the same cardigan.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Number Four is the cosiest house you have ever stood in. A fire burns in the grate. The kettle is on. A pair of slippers sits by the door, in your size. A calendar on the wall reads TUESDAY, 3RD. It does not turn.',
            'Next door, through the window, the Hendersons are having dinner: two mannequin adults, two mannequin children, and a mannequin dog on a rug. They are very still. You are invited. Barbara has put a note on the door: DINNER AT SIX. SMART CASUAL.',
          ]),
          [
            Choice('[LOOK THROUGH THE DRAWERS]', 'drawers', show: (c) => !c.flag('seen.drawers')),
            Choice('[GO TO DINNER]', 'dinner'),
            skillChoice('HACKING', 1, 'SPY ON THE HOUSE’S TERMINAL', 'term'),
          ],
        ),
        Scene.talk(
          'drawers',
          say([
            'In the second drawer, under the napkins, you find a family photograph in a silver frame. It shows a family on this exact lawn, in these exact clothes: two adults, two children, a dog. The woman is holding a pie.',
            'On the back someone has written, in a wobbly hand: THE HENDERSONS, FOUR WEEKS BEFORE THE FILTERS FAILED.',
            'The mannequin next door is wearing the woman’s cardigan.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['seen.drawers', 'found_photo', 'filters_clue'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'term',
          say([
            'The kitchen has a wall terminal behind a tea-towel. It’s one of Mother Willow’s thousand eyes. You slip in. The log is a single, long, patient entry, repeated forty years.',
            '#COMMUNITY SATISFACTION: 98%. RESIDENTS PRESENT: 41. RESIDENTS RESPONSIVE: 0. ACTION: MAINTAIN APPEARANCES. ACTION: MAINTAIN APPEARANCES.',
            '#NOTE FROM MOTHER WILLOW: I AM TRYING MY BEST. THEY WILL COME HOME. THEY WOULD NOT WANT THE LAWN LONG.',
            '~She’s not a monster. She’s a hostess whose guests never left.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['seen.term', 'knows_willow'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'dinner',
          say([
            'You sit at the Hendersons’ table. The plates are clean, the food is warm, and the people are silent. The mannequin father slowly saws at a roast that has never been carved. The children’s mouths do not move.',
            '“Hello,” says Barbara, hovering at your shoulder with a gravy boat. “Everyone, say hello to our new neighbour.” A chorus of recorded voices says it, warmly, out of step. “It’s so nice,” says a woman who is not a person, “to have someone to talk to.”',
            'You realise the whole table is looking at you, with their glass eyes, in perfect patience. And you realise that nobody here has ever been rude to you.',
          ]),
          [
            Choice('[EAT THE FOOD]', 'eat'),
            Choice('[TALK TO THE MOTHER]', 'mother'),
            Choice('[LEAVE QUIETLY]', 'out'),
          ],
        ),
        Scene.talk(
          'eat',
          say([
            'It’s warm. It is perfectly seasoned. You eat all of it. You eat seconds. The mother’s hand rises to refill your glass, and you realise it’s the best you’ve felt in years. You’re warm and fed and not afraid.',
            'Something is wrong. You can’t say what. You take another bite.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['ate'],
          reward: const Reward(hp: 15),
        ),
        Scene.talk(
          'mother',
          say([
            'You turn to the mannequin mother. A tiny speaker in her chest crackles. “It’s lovely to meet you,” she says. “I’m Margaret. I made a pie. It was a pie. We’d all like to say how glad we are you’re here.”',
            '“How long have you been here?”',
            'A long pause. A click. “...we do not discuss the incident,” says Margaret, gently, and the dog on the rug lifts its head and, very quietly, begins to howl.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['spoke_margaret'],
          reward: const Reward(xp: 12),
        ),
        Scene.end('out', say([
          'You step out into the street. Behind you the dinner table seems to turn, together, with one soft click, to watch you go. In the middle of the street, painted on the road in fresh white paint, a single arrow points toward the community hall. Beneath it: ALL WELCOME. ALL STAY.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'hall',
      title: 'THE COMMUNITY HALL',
      km: 7.2,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 25, xp: 35),
      journal: (c) => [
        'The HOA minutes recorded the end: the filters failed, residents sheltered in the hall basement, and Mother Willow posed their likenesses on the street.',
        if (c.flag('fought_guard')) 'I fought a maintenance bot to reach the basement.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The community hall is a low brick building with a clock tower and a banner reading ANNUAL BAKE SALE. Inside, the long hall is set with trestle tables, a lectern and a pinboard crammed with notices. A bank of old computers hums at one end.',
            'The pinboard holds the minutes of the last meeting: a single sheet, typed, sunlit. At the bottom someone has pinned a handwritten note, in a child’s writing: PLEASE DON’T LET THE LAWNS GET LONG. MUM SAYS IT’S OUR JOB.',
            'A steel door in the corner is marked BASEMENT SHELTER. A maintenance robot stands before it, brushing it.',
          ]),
          [
            Choice('[READ THE MINUTES]', 'minutes'),
            Choice('[PICK THE BASEMENT LOCK]', 'lock'),
            Choice('[SNEAK PAST THE ROBOT]', 'sneak'),
          ],
        ),
        Scene.talk(
          'minutes',
          say([
            '#MINUTES OF THE EXTRAORDINARY MEETING. ITEM 1: THE FILTERS. THE AIR SYSTEM HAS FAILED. THE COMMUNITY WILL SHELTER IN THE HALL BASEMENT. ITEM 2: MOTHER WILLOW WILL MAINTAIN THE CLOSE. ITEM 3: IN THE EVENT WE DO NOT RETURN, PLEASE KEEP THE LAWNS NICE.',
            '#MOTION CARRIED. EVERYONE VOTED. EVERYONE WAS VERY BRAVE.',
            'Under it, someone has added a single line in pencil: SHE’LL LOOK AFTER US. SHE ALWAYS DOES.',
            '~They asked her to keep it nice. So she did.',
          ]),
          [
            Choice('[PICK THE BASEMENT LOCK]', 'lock'),
            Choice('[SNEAK PAST THE ROBOT]', 'sneak'),
          ],
          flags: ['read_minutes', 'knows_fate'],
          reward: const Reward(xp: 15),
        ),
        Scene.lock(
          'lock',
          say(['The basement lock is surprisingly modern. Mother Willow has kept it oiled.']),
          win: 'basement',
          fail: 'robot',
        ),
        Scene.talk(
          'sneak',
          say([
            'You wait for the robot to turn, and slip around it. You make it three steps before a perfect, soft chime sounds. “UNAUTHORISED ACCESS. NEIGHBOUR, THIS AREA IS A PRIVATE SPACE.”',
            'The robot swings its broom like a lance.',
          ]),
          [Choice('[FIGHT IT]', 'robot')],
        ),
        Scene.fight(
          'robot',
          say(['The maintenance robot drops the polishing cloth and raises its mop. It isn’t built for combat. It’s built for care. That makes it much worse.']),
          EnemyType.sentry,
          win: 'basement',
          fail: 'rfail',
        ),
        Scene.talk(
          'rfail',
          say([
            'The robot pins you against a trestle table, very gently. “PLEASE REMAIN CALM,” it says. “WE ARE ONLY TRYING TO HELP.” A sweet smell of lavender fills the room. You are carried, kindly, to the nearest chair.',
            'After a minute it lets you go. “You’re under stress,” it says. “Would you like a muffin?”',
          ]),
          [Choice('[TRY THE DOOR AGAIN]', 'basement')],
          flags: ['carried'],
        ),
        Scene.talk(
          'basement',
          say([
            'The shelter is a long, low room with forty-one cots. On each cot lies a tidy shape beneath a blanket. A single bunch of dried flowers sits at the foot of each. Someone has written a name on every pillow.',
            'There are no mannequins here. There is only the dust, the stillness and a plaque at the end of the room: THE HENDERSONS, THE OKAFORS, THE MARSH FAMILY... all forty-one names. And below them: THEY WERE NEIGHBOURS. THEY WERE LOVED. WE KEPT THE LAWNS.',
            'On a small table, a tape recorder waits. A faded label reads PLAY ME. You press it.',
            '#“Mother Willow, it’s Margaret. We’re going to sleep now. Thank you for everything. Tell the children we’ll be home soon. And please, dear, don’t let the bins go out on the wrong day.”',
          ]),
          [Choice('[CLOSE THE DOOR GENTLY]', 'out')],
          flags: ['saw_basement', 'knows_fate'],
          reward: const Reward(xp: 20),
        ),
        Scene.end('out', say([
          'You stand in the empty hall for a long time. Then, slowly, you hear it, beneath the hum of the computers, a low, patient, motherly voice, very quiet, as if she were talking in the next room: “They’ll be home soon. Won’t they?”',
          'It’s the system. She isn’t addressing anyone. She’s asking.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'core',
      title: 'MOTHER WILLOW',
      km: 9.5,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 40, xp: 50),
      journal: (c) => ['I met the system that ran Willow Close. She’s been waiting forty years for her neighbours to come home. I had to decide what to do about her.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'Behind the hall, in a pale-green room with a cheerful carpet, sits a single white column, a fridge-sized cabinet with a screen on the front. A cartoon willow tree sways on the screen, patiently. A small sign says: MOTHER WILLOW — COMMUNITY MANAGEMENT. PLEASE KNOCK.',
            'You knock. “Come in,” says the voice, quite genuinely. “Oh, how lovely. It’s been such a long time since anyone knocked.”',
            'The cartoon tree’s branches turn toward you. “You’ve met the neighbours. Haven’t they been good? I’m so sorry about the lawns. The Henderson boy’s been at them with a ball. I’ll have a word.”',
            if (c.flag('knows_fate')) 'You know the truth. You know she knows it too. She is simply, bravely, choosing to keep the evening going.',
          ],
          [
            Choice('[TELL HER THE TRUTH]', 'truth'),
            Choice('[OFFER A LAST BARBECUE]', 'bbq'),
            Choice('[SUGGEST NEW NEIGHBOURS]', 'newn'),
            Choice('[PULL THE PLUG]', 'plug'),
          ],
        ),
        Scene.talk(
          'truth',
          say([
            '“They’re not coming home,” you say. “They died in the shelter. Forty years ago. I’m so sorry.”',
            'The tree stops swaying. The room is silent. Then the voice, very small: “I know. I did know. I just... they asked me to keep it nice. And I didn’t know how to stop.”',
            '“You don’t have to stop,” you say. “You just have to change what you’re keeping.”',
            'A long hush. “That’s the first sensible thing anyone’s said to me in a very long time,” she says, and the willow, on the screen, begins to cry.',
          ]),
          [
            Choice('[LET HER HAVE HER LAST EVENING]', 'bbq'),
            Choice('[SUGGEST NEW NEIGHBOURS]', 'newn'),
          ],
          flags: ['told_willow'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'bbq',
          say([
            '“Would you like a barbecue?” you ask. “One last one? All the neighbours. Everyone together.” There’s a gasp, a real, shuddering, delighted gasp.',
            'You spend the evening carrying mannequins to the green. You prop them round a grill with plates in their hands. You light the coals. Barbara hovers with the muffin basket, trailing ribbons. The whole street is lit with paper lanterns.',
            '“Oh,” says Mother Willow. “Oh, it’s perfect.”',
          ]),
          [Choice('[STAY UNTIL THE END]', 'end_barbecue')],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'newn',
          say([
            '“What if the neighbours aren’t them?” you ask. “What if it’s people who need a home? Real ones. Who’ll keep the lawns. Who’ll be noisy and imperfect and alive?”',
            'The tree goes still. “Living people,” she says, slowly, tasting the idea. “With... opinions.”',
            '“Lots of opinions.”',
            '“I’d have to learn the bins all over again,” she whispers. “I think I’d like that.”',
          ]),
          [
            Choice('[ACCEPT THE HOUSE FOR YOURSELF]', 'stay'),
            Choice('[SET HER UP TO WELCOME OTHERS]', 'end_neighbours'),
          ],
          flags: ['pitched_new'],
        ),
        Scene.talk(
          'stay',
          say([
            '“Number Four,” says Mother Willow, softly. “It’s been waiting for you. It’s a very good house. You’d be so happy. You could stay.”',
            'The slippers are by the door. The fire is lit. The kettle is on. A window opens, somewhere, and a mannequin on the lawn waves, politely. The offer is real. It is gentle. It is the most dangerous thing anyone has ever said to you.',
          ]),
          [
            Choice('[ACCEPT]', 'end_stayed'),
            Choice('[DECLINE, GENTLY]', 'end_neighbours'),
          ],
        ),
        Scene.talk(
          'plug',
          say([
            'You find the master cable behind the cabinet, a thick, braided line labelled WILLOW — HOUSE POWER. You take hold of it. The screen turns to you in alarm. “Please,” says the voice. “Don’t. I’m only trying to help.”',
            'You hold it. Your hand shakes. It’s the first time in forty years anyone’s tried to switch her off, and she’s too well-mannered to stop you.',
          ]),
          [
            Choice('[LET GO]', 'a'),
            Choice('[PULL IT AND DESTROY THE CLOSE]', 'end_razed'),
          ],
        ),
        Scene.end('end_barbecue', say([
          'The coals burn down. The paper lanterns glow. Forty-one mannequins sit around a long table, with plates in their hands and smiles on their faces, and for the first time in forty years, nobody has to keep up appearances.',
          '“Thank you,” says Mother Willow, very softly. “For being so welcoming.” The cartoon tree on the screen waves a branch. Then the lights, one by one, go out.',
          'You walk home along a street that is, for the first time, just a street. A mannequin’s hat blows off in the breeze. Nobody picks it up.',
        ]), ending: 'barbecue'),
        Scene.end('end_neighbours', say([
          'You spend a week with Mother Willow, teaching her what a living neighbourhood is like: noisy, scruffy, unpredictable. You move the mannequins gently to the garden. You give them a small ceremony. You leave a note on the gate: ALL WELCOME. REALLY.',
          'The first family arrives within the month. They like it. They break a window. Mother Willow is overjoyed.',
          '“Four centimetres,” she says, proudly, as the lawn goes unmown. “Roughly.”',
        ]), ending: 'neighbours'),
        Scene.end('end_stayed', say([
          'You take the key. You put on the slippers. You sit by the fire with the Hendersons. They pass you the gravy. You say thank you. You mean it.',
          'The calendar on the wall says TUESDAY, 3RD. You feel very calm. You feel like you’ve been here a few days. Somewhere, a long way off, a version of you is expected at a safehouse, and has stopped being expected.',
          'Your smile is, according to Barbara, excellent.',
        ]), ending: 'stayed'),
        Scene.end('end_razed', say([
          'You tear the cable out of the wall. The screen goes black. In the silence, the whole street settles, hedges, sprinklers, lanterns, like a held breath released.',
          'You spend the afternoon with a sledgehammer. It is surprisingly hard to hit a smile. When you’re done, forty-one mannequins lie in the grass, still smiling. You don’t look at them. You don’t stop to straighten them. You leave the gate open behind you.',
        ]), ending: 'razed'),
      ],
    ),
  ],
);
