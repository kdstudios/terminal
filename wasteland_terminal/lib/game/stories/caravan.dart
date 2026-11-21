import '../combat_session.dart';
import '../story_model.dart';

// THE MISSING CARAVAN
// Nine wagons turned off the highway together and never came back. They are
// not dead. They are very, very happy, and the water is why.

List<Choice> _campChoices() => [
      Choice('[CHECK THE LEDGER]', 'ledger', show: (c) => !c.flag('seen.ledger')),
      Choice('[TASTE THE STEW]', 'stew', show: (c) => !c.flag('seen.stew')),
      Choice('[TRY THE CASH WAGON]', 'wagon', show: (c) => !c.flag('seen.wagon')),
      Choice('[MOVE ON]', 'leave'),
    ];

List<Choice> _townChoices() => [
      Choice('[ASK WHY THEY STAYED]', 'why', show: (c) => !c.flag('seen.why')),
      Choice('[ASK WHO LEFT]', 'left', show: (c) => !c.flag('seen.left')),
      Choice('[TELL THEM INES MADE IT]', 'ines',
          show: (c) => c.hasQuest('caravan') && c.flag('seen.left') && !c.flag('seen.ines')),
      Choice('[LOOK AROUND THE TOWN]', 'around', show: (c) => !c.flag('seen.around')),
      Choice('[SIT DOWN TO DINNER]', 'dinner'),
    ];

final StoryDef caravanStory = StoryDef(
  id: 'caravan',
  title: 'THE MISSING CARAVAN',
  tagline: 'NINE WAGONS, FORTY-ONE PEOPLE, ONE STRAIGHT ROAD. THEY STILL MANAGED TO GET LOST.',
  difficulty: 'LOW',
  destinationKm: 7.5,
  recommendedLevel: 1,
  intro: [
    'The Hollis & Daughters freight caravan left the Cinder Crossing market eleven days ago, bound for the safehouse circuit. Nine wagons, forty-one people, four hundred kilos of canned peaches and one extremely opinionated goat.',
    'They should have arrived a week back. Nobody has seen them. Nobody has seen anything, actually: no smoke, no vultures, no bones. The road is just a road. That is somehow the worst part.',
    'A sealed note was pushed under your shutter overnight. It offers a finder’s fee, signed by six different creditors, none of whom sound especially worried about the people.',
    'You read it twice. Six creditors and no relatives. You’ve met enough caravans to know what that means about the man in charge of this one.',
  ],
  reward: const Reward(scrap: 140, xp: 90, stims: 1, picks: 1),
  endings: {
    'freed': const Ending('freed', 'THE WATER STOPS',
        'You shut the pump off. Contentment woke up. It did not thank you, and you did not expect it to.',
        world: ['caravan.freed']),
    'balanced': const Ending('balanced', 'LEVEL ONE',
        'You turned the dose down instead of off. Forty-one people started arguing about a goat. It was the best sound you heard all year.',
        bonus: Reward(xp: 40, stims: 1), world: ['caravan.balanced']),
    'left': const Ending('left', 'NOT YOUR BUSINESS',
        'You left the pump running. They are fed, safe and happy. You collected the fee and have not entirely stopped humming.',
        bonus: Reward(scrap: 60), world: ['caravan.left']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? [
          'You find the first wagon ruts half a kilometre down the highway and follow them the way you’d follow a rumour: reluctantly, with one eye on the exits.',
          '~Forty-one people don’t just vanish. They get eaten, robbed or lost. Pick one.',
        ]
      : [
          'You pick the trail back up where you left it. The ruts are exactly where they were, which is more than you can say for your enthusiasm.',
          if (c.flag('drank')) '~You’re humming. Why are you humming?',
        ],
  ambient: [
    Ambient('A wagon rut in the dust, perfectly straight. Whoever drove it was either very good or very relaxed.', maxKm: 3),
    Ambient('You pass an empty peach tin, rinsed clean and set upright on a rock. Rinsed. You can’t remember the last time you saw anything rinsed.', maxKm: 4),
    Ambient('Somebody has been through here with a broom. In the wasteland. You find this more alarming than a corpse.', maxKm: 4.6),
    Ambient('~Tidy camps. Cheerful ledgers. You catch yourself checking your own pack for folded corners.', when: (c) => c.done('camp')),
    Ambient('The ruts here are decorated. Someone has drawn small suns in the dust beside each one.', minKm: 3.2, maxKm: 6),
    Ambient('%A faint sweetness hangs in the air, like peaches and nothing else at all.', minKm: 4),
    Ambient('You realise you’ve been humming for a kilometre. You don’t know the tune. It’s very nice.', minKm: 4.6, when: (c) => c.flag('drank')),
    Ambient('Your knuckles ache. Nobody has come to complain about it, which feels less like mercy and more like a bill.', minKm: 4.6, when: (c) => c.flag('violence')),
    Ambient('~Tell them I made it this far. You hope there’s someone left to tell.', when: (c) => c.hasQuest('caravan')),
    Ambient('From somewhere ahead, a goat bleats once, in a tone of profound approval.', minKm: 6),
    Ambient('~Nobody argues here. You’ve been walking through it for an hour and you haven’t heard a single raised voice. You didn’t know that was possible.', minKm: 6, when: (c) => c.done('town')),
    Ambient('#...peaches... peaches... a fine harvest this year... (static)', minKm: 5, when: (c) => c.skill('HACKING') >= 1),
  ],
  checkpoints: [
    // ---------------------------------------------------------------- 1.6
    Checkpoint.auto(
      id: 'wheel',
      title: 'THE WHEEL',
      km: 1.6,
      text: (c) => [
        'A single wagon wheel stands upright in the middle of the highway, propped against nothing. Someone has painted a yellow smiley face on the hub. The paint is fresh. Fresh as in: this year.',
        'You crouch beside it. Nine sets of wagon tracks run along the road, then peel off to the left one after another, like ducklings who all heard the same joke.',
        'No drag marks. No scattered crates. No boot-prints running the other way. Nobody fled. Everybody just... turned.',
        '~Panic leaves a mess. This is what it looks like when a lot of people make one decision together.|',
        if (c.hasQuest('caravan'))
          'You think of the stranger bleeding against a wreck, asking you to tell someone they’d made it this far. You had assumed “this far” meant the end of a road. It might have meant the beginning of something else.',
      ],
      journal: say([
        'A lone wagon wheel with a fresh smiley on the hub. Nine sets of tracks turn off the highway together. No panic, no struggle.'
      ]),
      reward: const Reward(xp: 10),
    ),
    // ---------------------------------------------------------------- 3.1
    Checkpoint(
      id: 'camp',
      title: 'THE TIDY CAMP',
      km: 3.1,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 15),
      journal: (c) => [
        'The first night camp was spotless: folded bedrolls, washed plates, stew gone cold with the ladle hung handle-out.',
        if (c.flag('seen.ledger'))
          'The clerk’s ledger got cheerier by the day until it stopped counting peaches altogether.',
        if (c.flag('opened')) 'The cash wagon held debts, not money. Hollis owed everyone.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The caravan’s first night camp is still here, and it is spotless.',
            'Nine bedrolls in a neat row. Plates stacked and drying on a rack someone built from tent poles. A pot of stew sits over a dead fire with its ladle hung on the rim, handle outward, the way a mother would hang it.',
            'You have seen a great many abandoned camps. They are chaos. This one is tidier than your safehouse.',
            '~Nobody leaves a place this clean unless they were told to, planned to come back, or are extremely well brought up.',
          ]),
          _campChoices(),
        ),
        Scene.talk(
          'hub',
          say(['You look around the tidy camp again. It looks back, tidily.']),
          _campChoices(),
        ),
        Scene.talk(
          'ledger',
          (c) => [
            'The cargo clerk’s ledger lies open on a crate, pencil tucked into the spine. Careful columns of peaches and goat feed. Then the handwriting loosens.',
            '#DAY 6: ROAD GOOD. MORALE GOOD. HOLLIS SAYS THE DETOUR WILL ADD ONE HOUR.',
            '#DAY 6, LATER: DETOUR IS LOVELY. EVERYONE IS IN SUCH A GOOD MOOD.',
            '#DAY 7: DID NOT COUNT THE PEACHES. DOES IT MATTER.',
            '#DAY 8:',
            'The last entry is a smiley face, pressed so gently the pencil barely dented the page.',
          ],
          [
            Choice('[KEEP LOOKING]', 'hub'),
            Choice('[MOVE ON]', 'leave'),
          ],
          flags: ['seen.ledger'],
        ),
        Scene.talk(
          'stew',
          say([
            'You lift the lid. The stew is cold, thick and perfectly seasoned, and there is not a single fly on it. In this wasteland. Not one.',
            'You put the lid back with the care of someone defusing something.',
            '~Food nobody has touched in days that smells this good is either a gift or an invoice.',
          ]),
          [
            Choice('[KEEP LOOKING]', 'hub'),
            Choice('[MOVE ON]', 'leave'),
          ],
          flags: ['seen.stew'],
        ),
        Scene.talk(
          'wagon',
          say([
            'The cash wagon is parked a little apart, as though embarrassed. Its strongbox is chained under the bench, with a padlock the size of a fist.',
          ]),
          [
            Choice('[PICK THE PADLOCK]', 'wagon_lock', needPick: 0),
            Choice('[LEAVE IT]', 'hub'),
          ],
          flags: ['seen.wagon'],
        ),
        Scene.lock(
          'wagon_lock',
          say(['You kneel at the strongbox and get to work.']),
          win: 'wagon_ok',
          fail: 'wagon_no',
        ),
        Scene.talk(
          'wagon_ok',
          say([
            'The strongbox is not full of money. It is full of paper. Promissory notes, loan agreements, a letter in red ink that begins “FINAL NOTICE” and then, sadly, gets worse.',
            'Dov Hollis owed money to everyone between here and the coast, and a few people beyond it. There is a small purse at the bottom with a handful of scrap in it. Probably the only cash he had.',
            '~No wonder he stopped being worried. Anyone would, with a pile like this.',
          ]),
          [
            Choice('[KEEP LOOKING]', 'hub'),
            Choice('[MOVE ON]', 'leave'),
          ],
          flags: ['opened'],
          reward: const Reward(scrap: 25, xp: 8),
        ),
        Scene.talk(
          'wagon_no',
          say([
            'The padlock wins. You are left with a bent pick, a bruised ego and a chain that looks very pleased with itself.',
          ]),
          [
            Choice('[KEEP LOOKING]', 'hub'),
            Choice('[MOVE ON]', 'leave'),
          ],
        ),
        Scene.end(
          'leave',
          (c) => [
            'You follow the tracks out of camp. They are easy to find. They are, in fact, so easy to find that someone seems to have swept the grass flat beside them to help.',
            '~You’re being invited somewhere. You’re not sure you’ve ever been invited anywhere before.',
          ],
        ),
      ],
    ),
    // ---------------------------------------------------------------- 4.6
    Checkpoint(
      id: 'toll',
      title: 'THE FREE TOLL',
      km: 4.6,
      art: 'gang',
      start: 'a',
      reward: const Reward(xp: 15),
      journal: (c) => [
        'A toll shack on the trail, manned by a man named Wendell whose smile never changed.',
        if (c.flag('drank')) 'You took his flask. It was the best water of your life.',
        if (c.flag('declined')) 'You declined his flask. He did not mind. That bothered you.',
        if (c.flag('violence')) 'You put him on the ground. He apologised to you.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'A toll shack straddles the trail, with a bedframe for a barrier. The sign says TOLL: ONE SMILE. Underneath, in different handwriting: (OPTIONAL).',
            'The man inside is beaming. Pressed jacket, combed hair, a name tag reading WENDELL — HAPPY TO HELP. He is holding out a steel flask with both hands, like an offering.',
            '“Welcome, friend! Long walk? Of course it is. Sit. Have a drink. Everything’s free here. Everything’s lovely.”',
            '~Nobody’s ever this pleased to see a stranger. You’ve only met one kind of person who is, and they usually have a knife.',
          ]),
          [
            Choice('[ASK ABOUT THE CARAVAN]', 'ask'),
            Choice('[TAKE THE FLASK]', 'drink'),
            Choice('[DECLINE POLITELY]', 'decline'),
            Choice('[SHOVE PAST HIM]', 'shove'),
          ],
        ),
        Scene.talk(
          'ask',
          (c) => [
            '“The Hollises? Oh, they’re wonderful. Best thing to happen to us in years. They’re all at the Commons, you’ll see them at dinner!”',
            'He says “dinner” the way someone says it who has never once missed one.',
            if (c.hasQuest('caravan'))
              '“There was a scout, a woman. Ines. She ran off. Poor thing. She was so tense all the time, we offered her water and she just wouldn’t take it.”',
            '~Wouldn’t take it. You file that away, somewhere near the back of your head, next to the other things you’d rather not think about.',
          ],
          [
            Choice('[TAKE THE FLASK]', 'drink'),
            Choice('[DECLINE POLITELY]', 'decline'),
            Choice('[SHOVE PAST HIM]', 'shove'),
          ],
          flags: ['asked.toll'],
        ),
        Scene.end(
          'drink',
          say([
            'It is just water. Cold, clean, faintly sweet. The best you’ve tasted in months.',
            'Something in your shoulders unclenches that you hadn’t known was clenched. The road ahead looks shorter. The sky looks less like a lid.',
            '~This is nice.|',
            '~This is... suspiciously nice.',
            'Wendell lifts the bedframe with a flourish. “Thank you for the smile!” You hadn’t noticed you were smiling.',
          ]),
          flags: ['drank'],
          reward: const Reward(hp: 12, xp: 5),
        ),
        Scene.end(
          'decline',
          say([
            '“No thank you. I’m not thirsty.”',
            'His smile does not change by a single muscle. “Of course! No pressure!” he says, with exactly zero pressure, which is a pressure of its own.',
            'He lifts the barrier. As you pass, he calls after you, cheerfully, “Everybody gets thirsty eventually!”',
            '~You’ve decided you’re going to keep your canteen very close.',
          ]),
          flags: ['declined'],
        ),
        Scene.fight(
          'shove',
          say([
            'You put a shoulder into him. He goes down, and the flask goes with him. “Ow,” he says, mildly, like a man reading the word off a card.',
            'Then three more smiling figures step out from behind the shack.',
          ]),
          EnemyType.straggler,
          win: 'shoved',
          fail: 'shove_back',
        ),
        Scene.end(
          'shoved',
          say([
            'It’s quiet again. Wendell lies in the dust, still smiling. You can’t tell whether that’s his face or a nerve.',
            '“That’s alright,” he says, from the ground. “We forgive you.”',
            'Forgive. Already. Before you asked.',
            '~You’d prefer being cursed at. You know where you are with a curse.',
          ]),
          flags: ['violence'],
        ),
        Scene.talk(
          'shove_back',
          say([
            'You back out of range, breathing hard. They don’t chase you. They stand in a line and wave, as if you’d come to visit and were leaving a bit early.',
          ]),
          [
            Choice('[APOLOGISE AND TAKE THE FLASK]', 'drink'),
            Choice('[DECLINE POLITELY]', 'decline'),
          ],
        ),
      ],
    ),
    // ---------------------------------------------------------------- 6.0
    Checkpoint(
      id: 'town',
      title: 'CONTENTMENT',
      km: 6.0,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 25),
      journal: (c) => [
        'The caravan is not missing. It “arrived”: forty-one people, one goat in a sash, and a town sign whose population has been painted over four times.',
        if (c.flag('seen.why')) 'Nobody in Contentment has argued in months.',
        if (c.flag('seen.ines')) 'You told them Ines made it. A girl named Pim cried, the only sad face in town.',
        if (c.flag('seen.around')) 'The pump house has a sign: PLEASE DO NOT WORRY ABOUT THE PUMP HOUSE.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The trail ends at a village built around an old waterworks. A sign at the gate reads WELCOME TO CONTENTMENT. POP. 12. The 12 has been painted over four times: 31, 53, 94, and finally, in fresh yellow, ROOM FOR MORE!',
            'The nine wagons are parked in a ring in the square, with flower boxes on their sideboards. A goat in a ribbon sash watches you from a feed trough, as if appointed to do so.',
            'A long table has been set for ninety. People wave at you. Every single one of them waves.',
            'A broad man in a clean waistcoat rises and takes your hand in both of his. “Dov Hollis. We’re not lost, you know. We were never lost.”',
            '“We arrived.”',
            if (c.flag('drank'))
              'You notice you’re smiling back and cannot immediately find the reason.',
            if (c.flag('declined'))
              'His eyes drift to the canteen on your belt. For a heartbeat, the smile gets very slightly thinner. “Not thirsty? That’s fine. Everyone gets thirsty.”',
            if (c.flag('violence'))
              'He glances at your knuckles. “Ah. You’ve met Wendell. He bruises so easily. We forgive you.” You wish people would stop forgiving you.',
          ],
          _townChoices(),
        ),
        Scene.talk(
          'why',
          say([
            '“Because it’s good here,” Hollis says, and means it. “Do you know how long it’s been since forty-one people agreed on something? We voted on dinner and it took four seconds. Four.”',
            'You wait for a “but.” A mutter. A mother snapping at a child. A door slamming. There is none. In an hour in this village, you have heard no single raised voice.',
            '~A village with no arguments. You didn’t know that was possible. You’re not sure it’s allowed.',
          ]),
          _townChoices(),
          flags: ['seen.why'],
        ),
        Scene.talk(
          'left',
          (c) => [
            '“Left?” Hollis tilts his head like a dog hearing a new word. “Oh, you mean Ines. Our scout. She took ill. Said the water didn’t agree with her. We gave her our best canteen and wished her well.”',
            '“She was so anxious all the time,” he adds, with great tenderness. “It was heartbreaking.”',
            if (c.hasQuest('caravan'))
              'Ines. The name lands like a dropped stimpack. The stranger on the road, bleeding against a wreck, asking you to pass word along. She hadn’t been asking you to find a lost caravan. She’d been asking you to find the people she’d had to run away from.',
          ],
          _townChoices(),
          flags: ['seen.left'],
        ),
        Scene.talk(
          'ines',
          say([
            '“There was a woman on the road,” you say. “Ines. She asked me to tell you she made it this far.”',
            'Hollis’s smile holds. A young girl at the end of the table does not hold. Her face crumples, and she says “Mama?” to nobody, in a voice that sounds, finally, like a person.',
            'Two women lead her away, murmuring soothing things. The sound of her crying fades behind a door.',
            'Hollis watches them go. For one second, one, something moves behind his face, like a fish passing under ice.',
            '“Pim gets sensitive,” he says. “She’ll be fine by dinner.”',
            '~She had a sob in her. In this whole town of ninety places, that was the only one that was real.',
          ]),
          _townChoices(),
          flags: ['seen.ines', 'toldines'],
          reward: const Reward(xp: 20),
        ),
        Scene.talk(
          'around',
          say([
            'You wander. It’s a nice town. That’s the unsettling thing: it is genuinely, relentlessly nice. Every window has a candle. Every door is open.',
            'On a rise behind the square stands the old water tower, and below it a squat concrete pump house behind a chain-link fence. The fence has a freshly painted sign: PLEASE DO NOT WORRY ABOUT THE PUMP HOUSE.',
            'You weren’t worried about the pump house. You are now.',
          ]),
          _townChoices(),
          flags: ['seen.around', 'pumpseen'],
        ),
        Scene.talk(
          'dinner',
          say([
            'You sit. The food is extraordinary: roast goat’s-cheese flatbread, pickled something, and, oh, the peaches. The peaches.',
            'A woman at your elbow keeps filling your cup from a ceramic jug. You say no thanks twice. She fills it anyway, without malice, like a tide.',
            'The cup sits in front of you, bright and cold. Everyone at the table is watching you politely not watching you.',
          ]),
          [
            Choice('[DRINK FROM THE CUP]', 'sip'),
            Choice('[HOLD IT, DO NOT DRINK]', 'hold'),
            Choice('[PUSH THE CUP AWAY AND LEAVE]', 'dusk'),
          ],
          reward: const Reward(hp: 25),
        ),
        Scene.end(
          'sip',
          say([
            'You drink. The world goes soft at the edges, like a photograph of a day you’d like to remember.',
            'It’s remarkable. You haven’t felt this relaxed since... you try to think when. Never, maybe. Never is a possibility.',
            'By the time the plates are cleared, you’ve agreed to three things you can’t quite remember, and you’re sure they were all fine.',
            '~It’s fine. Everything’s fine. That’s the water. It’s just the water.',
          ]),
          flags: ['drank'],
        ),
        Scene.end(
          'hold',
          say([
            'You hold the cup in both hands, as one holds a small, warm animal, and drink nothing. Nobody says a word about it. Nobody has to.',
            'By the end of the meal, the cup has gone from cold to warm. The woman refills it twice more. You do not drink.',
            'You catch Pim’s mother looking at the cup. Then at you. Then at the cup again. For a moment, her smile is only a shape.',
          ]),
          flags: ['sober'],
        ),
        Scene.end(
          'dusk',
          (c) => [
            'Dusk drops like a blanket. Lamps come on, one after another, with a kind of gentle precision.',
            'The sign at the gate seems taller now. POP. 94. And below it, someone with a very small brush has started on the next number.',
            if (c.flag('toldines')) 'Pim’s window glows at the end of the lane. You can hear nothing from it at all.',
            'Up the hill, the water tower stands over the pump house, patient as a church.',
          ],
        ),
      ],
    ),
    // ---------------------------------------------------------------- 7.5
    Checkpoint(
      id: 'pump',
      title: 'THE PUMP HOUSE',
      km: 7.5,
      art: 'vault',
      start: 'a',
      reward: const Reward(xp: 30),
      journal: (c) => [
        'The pump house doses the town’s water with SERENOL-9, a pre-war “municipal wellbeing supplement” set to Level 4: CONTENT.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The pump house is warm and smells of clean concrete. A bank of steel drums stands along one wall, each stencilled MUNICIPAL WELLBEING SUPPLEMENT — SERENOL-9. DOSAGE: LEVEL 4 (CONTENT). SEE SUPERVISOR BEFORE ADJUSTING.',
            'Below the stencil, a pre-war maintenance log hangs on a nail.',
            '#YEAR 1: LEVEL 2 (AT EASE). RESIDENTS CALMER. COMPLAINTS DOWN 40%.',
            '#YEAR 3: LEVEL 4 (CONTENT). EVACUATION RESISTANCE DOWN 90%. THIS PROGRAM WORKS.',
            '#NOTE FROM COUNCIL: DO NOT LET RESIDENTS KNOW. THEY WOULD WORRY. (A JOKE. THEY CANNOT.)',
            'Somebody has hand-written at the bottom, much later, in a cheerful loop: LEVEL 6 (BLISSFUL) WOULD BE LOVELY.',
            '~There it is. The most pleasant thing you’ve ever found in the wasteland is a drug. In the water. For everyone.',
            if (c.flag('drank'))
              'Your hand drifts toward the controls and then stops, resting there, for no reason you can name. The thought of touching them feels, absurdly, bad manners.',
            if (c.flag('toldines') && !c.flag('drank'))
              'You think of Pim’s face, crumpled, real, and you know exactly whose face the water has been keeping off the table.',
          ],
          [
            Choice('[HACK THE CONTROLLER]', 'hackc'),
            Choice('[PICK THE SERVICE LOCK]', 'pick'),
            Choice('[WALK AWAY]', 'end_left', flags: ['walked']),
          ],
        ),
        Scene.hack(
          'hackc',
          say(['A flat grey controller is bolted to the wall, its single light a steady, patient green.']),
          win: 'ctrl',
          fail: 'nopanel',
        ),
        Scene.lock(
          'pick',
          say(['Behind the drums, a steel service hatch guards the main valve.']),
          win: 'valve',
          fail: 'nopanel',
        ),
        Scene.talk(
          'ctrl',
          say([
            '#SERENOL-9 DOSING CONTROLLER. CURRENT LEVEL: 4 (CONTENT). SELECT NEW LEVEL: 0 (OFF) / 1 (AT EASE) / 2 / 3 / 4 / 5 / 6.',
            '#WARNING: SUDDEN WITHDRAWAL MAY CAUSE DISTRESS IN SOME RESIDENTS. ESTIMATED: ALL.',
            'Three options present themselves. One is gentle, one is brutal, one is nothing.',
          ]),
          [
            Choice('[SET LEVEL 1: AT EASE]', 'end_balanced'),
            Choice('[SHUT THE PUMP OFF]', 'end_freed'),
            Choice('[LEAVE IT RUNNING]', 'end_left'),
          ],
        ),
        Scene.talk(
          'valve',
          say([
            'The hatch swings open on a big red wheel, stiff with disuse, labelled DOSE VALVE. There is no dial. Only open and shut.',
          ]),
          [
            Choice('[CLOSE THE VALVE]', 'end_freed'),
            Choice('[LEAVE IT]', 'end_left'),
          ],
        ),
        Scene.talk(
          'nopanel',
          say([
            'The controller hums at you, polite and immovable. The lock does not so much as click. The pump house has beaten you, and it has done it in a very gentle way.',
            'A valve wheel, red and tempting, sits behind the drums. You could reach it, if you didn’t mind the noise.',
          ]),
          [
            Choice('[SMASH THE VALVE WITH YOUR PIPE]', 'end_freed', flags: ['smashed']),
            Choice('[LEAVE IT]', 'end_left'),
          ],
        ),
        Scene.end(
          'end_freed',
          (c) => [
            if (c.flag('smashed'))
              'You bring the pipe down on the valve. It rings like a bell, twice, and a hiss goes out of the whole building, like a held breath.'
            else
              'The wheel turns with a long groan. Somewhere in the walls, a flow stops.',
            'You stay long enough to watch it happen.',
            'It takes about a day. A woman at the well stops mid-sentence and says, in an entirely new voice, “Why am I holding a bucket?” A child starts crying and doesn’t stop. A man sits down in the middle of the road and asks nobody in particular where his wagon is.',
            'Dov Hollis finds you at the gate. He is not smiling. His face looks like a house with the lights suddenly turned on. “Forty days,” he says. “I lost forty days.”',
            'He doesn’t thank you. You didn’t expect him to. But Pim, red-eyed, takes your hand and holds it for a long time.',
            '~They’re awake. That’s the best you can say for it. It’s not much of a gift.',
            if (c.flag('toldines')) 'Somewhere in the confusion, someone is asking whether Ines really made it. You say she did.',
          ],
          ending: 'freed',
        ),
        Scene.end(
          'end_balanced',
          (c) => [
            'You set the dial to 1. The controller considers this, gives a small polite chime, and says nothing at all.',
            'You go back to the square and wait. It takes a while.',
            'Around sundown, Dov Hollis stops mid-sentence at the long table and says, “Hm.”',
            'Then: “We should really get the goat looked at.”',
            'Someone says the goat is fine. Someone else says the goat has been strange for weeks. Somebody’s voice rises, and somebody else says, “Now hold on,” and in about forty seconds the entire village is arguing about the goat.',
            'It is the most beautiful sound you have ever heard.',
            '~They’re anxious, and tired, and cross with each other. They’re awake enough to choose, and still soft enough to stay. It’s a start.',
            if (c.flag('toldines')) 'Pim finds you before you leave. “Can you tell Mama,” she says, “that we’re coming?”',
          ],
          ending: 'balanced',
        ),
        Scene.end(
          'end_left',
          (c) => [
            if (c.flag('walked'))
              'You walk out of the pump house without touching anything.'
            else
              'You close the panel. You rest your hand on the cool steel for a moment. Then you take it away.',
            'It’s none of your business. It’s very hard to build a case for it being your business. They aren’t hungry. They aren’t afraid. They aren’t hurting anyone. They’re as happy as anyone you’ve ever met.',
            'Hollis walks you to the gate, a hand on your shoulder. “Tell the creditors we’re well,” he says. “Tell them it’s all been so... lovely.” The fee is in your pocket by the time you reach the road.',
            'You tell yourself it’s fine. You tell it again. By kilometre two it has stopped working, and you realise you’re humming.',
            '~That’s the water. That’s just the water.|',
            '~...it’s a nice tune, though.',
          ],
          ending: 'left',
        ),
      ],
    ),
  ],
);
