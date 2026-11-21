import '../../combat_session.dart';
import '../../story_model.dart';

// THE PEOPLE’S REPUBLIC OF NOWHERE
// Seven citizens, one president (Gary: NOT the shoe Gary, NOT a bunker Gary,
// merely a third man of the same name), and a civil dispute about a water
// pump. Everyone is absurd. Everyone is also a person.
//
// Citizens: President Gary, Minister Marge (the Pump Ministry), Tilly
// (Opposition), Old Pete (Poet Laureate), Nan Barrow (Treasury, sole taxpayer),
// Bart (Chief of Defence, a very large goat-fancier), Jos (Minister of Fun, age 9).
// Endings: treaty, coup, referendum, annexed.

List<Choice> _parliamentChoices() => [
      Choice('[HEAR PRESIDENT GARY]', 'p_gary', show: (c) => !c.flag('seen.gary')),
      Choice('[HEAR MINISTER MARGE]', 'p_marge', show: (c) => !c.flag('seen.marge')),
      Choice('[HEAR TILLY, OPPOSITION]', 'p_tilly', show: (c) => !c.flag('seen.tilly')),
      Choice('[ADJOURN]', 'p_end'),
    ];

final StoryDef republicStory = StoryDef(
  id: 'republic',
  title: 'THE PEOPLE’S REPUBLIC OF NOWHERE',
  tagline: 'POPULATION: SEVEN. ARMY: ONE GOAT FANCIER. DISPUTE: ONE PUMP.',
  difficulty: 'LOW',
  destinationKm: 5.5,
  recommendedLevel: 1,
  intro: [
    'A hand-painted sign beside the road reads: YOU ARE NOW LEAVING THE WASTELAND. YOU ARE ENTERING THE PEOPLE’S REPUBLIC OF NOWHERE. PLEASE HAVE YOUR PAPERWORK READY. IF YOU HAVE NO PAPERWORK, PLEASE HAVE SNACKS.',
    'A messenger comes to your shutter with a scroll. It is addressed to “The Honourable Visitor, Esteemed Mediator and Neutral Party.” It asks you, on behalf of the Government, to resolve a civil dispute involving a water pump. It is signed, with considerable ceremony, GARY, PRESIDENT.',
    'You read it twice. The messenger waits. He is nine years old, in a rosette, and he is clearly the Minister of Fun.',
  ],
  reward: const Reward(scrap: 120, xp: 80, stims: 1),
  endings: {
    'treaty': const Ending('treaty', 'THE TREATY OF THE PUMP',
        'You brokered a treaty: the pump belongs to everybody and is operated by nobody in particular, on alternate Tuesdays. Everyone is slightly unhappy, which in diplomacy is called success. The Republic issues you a commemorative stamp. It is a drawing of a pump.',
        bonus: Reward(xp: 40, scrap: 30), world: ['republic.treaty']),
    'coup': const Ending('coup', 'A VELVET COUP',
        'Tilly is now President. She is, within the week, as impossible as Gary. Gary is now Minister of Complaints and has never been happier. The pump is run by committee, and the committee meets in a tent.',
        bonus: Reward(scrap: 70), world: ['republic.coup']),
    'referendum': const Ending('referendum', 'THE GREAT REFERENDUM',
        'You held a vote. Seven citizens, one ballot box, three recounts. The result was a tie, which the Poet Laureate resolved with a limerick. The limerick was upheld. The pump was shared.',
        bonus: Reward(xp: 50), world: ['republic.referendum']),
    'annexed': const Ending('annexed', 'THE ANNEXATION',
        'You annexed Nowhere into a slightly larger Nowhere that has you as its Honourable Visitor-for-Life. It is a hollow title with a very nice hat. The pump is yours, in theory. In practice you are mostly asked to settle disputes about goats.',
        bonus: Reward(scrap: 60, xp: 30), world: ['republic.annexed']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You set out toward the Republic with a spare set of manners. You suspect you will need them.']
      : ['The Republic’s border sign grows on the horizon like an overconfident weed.'],
  ambient: [
    Ambient('A signpost: NOWHERE — 3 KM. Another beneath it: ALSO NOWHERE — 3 KM. A third: PLEASE STOP ARGUING ABOUT THE SIGNS.', maxKm: 2.5),
    Ambient('A scarecrow in a sash stands to attention. Its badge says MINISTRY OF CROWS. There is not a single crow in sight.', maxKm: 3),
    Ambient('You pass a flagpole flying a single, enormous sock. The sock has been signed by someone important.', maxKm: 3.5),
    Ambient('A hand-lettered sign: IMMIGRATION TO THE REPUBLIC IS WELCOMED. EMIGRATION IS ALSO WELCOMED. BOTH TAKE TIME.', maxKm: 4),
    Ambient('Somewhere ahead, a tiny brass band plays the national anthem on a single recorder.', minKm: 1, maxKm: 4),
    Ambient('You step over a painted line. “BORDER,” says a very small voice from a bush. You didn’t see anyone there.', minKm: 1.5, maxKm: 3.5),
    Ambient('Posters: VOTE FOR GARY. VOTE AGAINST GARY. VOTE FOR WHOEVER IS NOT GARY, EVEN IF IT IS ALSO GARY.', minKm: 2),
    Ambient('~Seven people. One pump. You have seen wars start over less. You have never seen one start with a recorder.', minKm: 3),
    Ambient('A goat wearing a medal watches you pass with the weary dignity of a veteran.', minKm: 3.5, when: (c) => c.done('border')),
    Ambient('Minister Marge’s voice, from a long way off: “IT’S MY PUMP.” Then another: “IT’S THE PEOPLE’S PUMP.” Then a small, wise voice: “It’s a pump.”', minKm: 4),
    Ambient('You catch yourself saluting a lamppost. It’s the Republic’s only lamppost, and it has a rank.', minKm: 4.5),
    Ambient('~Whatever you decide, they’ll hold a ceremony. There will be bunting. It will be made of socks.', minKm: 5),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'sign',
      title: 'THE FRONTIER',
      km: 0.8,
      text: (c) => [
        'The border of the People’s Republic of Nowhere is a painted line across the road and a deckchair. A flag made from a single large sock flaps from a broom handle. A man in the deckchair is eating an apple, and he is in uniform: a hat, a sash and a shirt that says GUARD in marker.',
        '“Papers,” he says. You show him your hands. “Those will do,” he says, with relief. He stamps your forearm with a potato.',
        '~You have entered a country. You are not sure the country has noticed.|',
      ],
      journal: say(['I crossed the border into the People’s Republic of Nowhere. A guard in a deckchair stamped me with a potato.']),
      reward: const Reward(xp: 5),
    ),
    Checkpoint(
      id: 'border',
      title: 'CUSTOMS',
      km: 2.0,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 15),
      journal: (c) => [
        'Customs in Nowhere is a table. Nan Barrow collects the Republic’s only tax. Bart the goat fancier is Chief of Defence.',
        if (c.flag('paid_tax')) 'I paid the tax: one scrap. Nan wept with joy.',
        if (c.flag('dodged_tax')) 'I declined to pay the tax. Nan wrote it on a list titled DEBTS OF HONOUR.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'A table has been set across the road with a lace cloth, a bell and a hand-lettered sign: CUSTOMS (AND CATERING). Behind it, a stout woman in a tricorn hat polishes a very large coin. A mountainous man with a goat on a lead stands guard at her shoulder.',
            '“Nan Barrow, Minister of the Treasury,” says the woman. “This is Bart, Chief of Defence. That’s Moira, Bart’s second-in-command.” The goat bleats. “Visitors must declare any goods, any grievances and any unauthorised opinions.”',
            '“Also, there’s a tax,” says Bart. “One scrap. It’s the only one we have.”',
          ]),
          [
            Choice('[PAY THE TAX]', 'pay'),
            Choice('[DECLARE AN OPINION]', 'opinion'),
            Choice('[REFUSE TO PAY]', 'refuse'),
          ],
        ),
        Scene.talk(
          'pay',
          say([
            'You pass over a scrap. Nan Barrow weeps. It’s the first tax she has collected since last month. She enters it in the great ledger with a flourish. “A citizen of the Republic, in spirit, if not in paperwork,” she says.',
            'Bart salutes. Moira the goat looks away.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['paid_tax'],
          reward: const Reward(xp: 5),
        ),
        Scene.talk(
          'opinion',
          say([
            '“I think,” you say, carefully, “that the national sock is excellent.”',
            'There is a very tense silence. Bart’s eyes mist over. “It was my grandfather’s,” he says. “He’d have wanted it flown.” You get a handshake, a small badge, and an unmistakable feeling that you’ve passed a test.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['praised_sock'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'refuse',
          say([
            '“No,” you say. “I’m not paying a goat’s tax.”',
            'Bart looks wounded. Nan Barrow looks at her ledger as though it has been slapped. “It isn’t the goat’s tax,” she says, in a small voice. “It’s the Republic’s.”',
            'Moira, the goat, places a hoof on the table. It is a very small hoof, but the gesture carries weight.',
          ]),
          [
            Choice('[PAY, EMBARRASSED]', 'pay'),
            Choice('[WALK PAST]', 'out', flags: ['dodged_tax']),
          ],
        ),
        Scene.end('out', say(['Beyond the table the road turns into a main street. It’s about thirty metres long. At the end of it stands a building with a sign: PARLIAMENT (PLEASE KNOCK). The door is open.'])),
      ],
    ),
    Checkpoint(
      id: 'parliament',
      title: 'THE PARLIAMENT',
      km: 3.6,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 12, xp: 25),
      journal: (c) => [
        'Parliament is a shed with a chair on a barrel. President Gary, Minister Marge and the Opposition leader Tilly are in dispute over a pump.',
        if (c.flag('seen.gary')) 'President Gary is warm, pompous and always about to cry.',
        if (c.flag('seen.marge')) 'Minister Marge claims the pump belongs to the Pump Ministry. She is the Pump Ministry.',
        if (c.flag('seen.tilly')) 'Tilly says the pump belongs to everyone. She is also the Opposition.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Parliament is a long shed with seven chairs in a circle and a lectern made from a barrel. Seven people look up as you enter. There is a tiny band in the corner: a recorder and a washboard. They play a flourish.',
            'A jovial man in a medal-laden waistcoat rises. “President Gary!” he booms, and bows, and lets the bow go on a bit. “Welcome to our Republic. I am pleased to announce that you have arrived at the worst possible moment.”',
            'Around him: a furious woman in overalls, a tall woman with a clipboard, an elderly man in a laurel wreath, and the young Minister of Fun, who is under the table.',
          ]),
          _parliamentChoices(),
        ),
        Scene.talk(
          'p_gary',
          say([
            '“The pump!” cries President Gary, with a hand on his heart. “The pump is the heart of the nation. I want it nationalised, I want it salaried, I want it to have a flag. But Marge wants it for the Ministry, and Tilly wants it for the People, and nobody wants it for me.”',
            '“What do you want for it?” you ask.',
            'His face crumples. “I want everyone to like me,” he says. “I thought a pump would do it.”',
            'Old Pete the Poet Laureate quietly hands him a hankie, and, in the same movement, a verse.',
          ]),
          _parliamentChoices(),
          flags: ['seen.gary', 'gary_soft'],
        ),
        Scene.talk(
          'p_marge',
          say([
            'Minister Marge puts down a spanner the size of a leg. “It’s MY pump. I built it. I oiled it. I named it Brenda. The Ministry of the Pump is me. It’s all of me. It’s the only thing I’ve got that works.”',
            'She’s shaking with anger, and underneath it, fear. “If I lose it,” she says, “what am I? A woman with a spanner.”',
            '“A woman with a spanner,” says Tilly, quietly, “is exactly what we need.”',
          ]),
          _parliamentChoices(),
          flags: ['seen.marge', 'marge_proud'],
        ),
        Scene.talk(
          'p_tilly',
          say([
            'Tilly, tall and clipped, raises one finger. “For the record, I’m not against the pump. I’m against the person who owns it. Nobody should own water. Everyone should own water. A pump owned by one citizen is a tyranny.”',
            '“Brenda’s not a tyranny,” says Marge. “She’s a pump.”',
            '“A pump,” says Tilly, “with a lock.”',
            'It’s a real point. Under the clipboard, you can see she’s been up all night with it. She wants, very badly, to be right in a way that is also kind.',
          ]),
          _parliamentChoices(),
          flags: ['seen.tilly', 'tilly_fair'],
        ),
        Scene.talk(
          'p_end',
          say([
            'You raise a hand and the room falls silent. The band stops mid-note. Old Pete lowers his laurel. The Minister of Fun peeks from under the table.',
            '“I’d like to see the pump,” you say. “Before I say anything at all.”',
            'The whole Republic exhales. A tiny cheer goes up. President Gary, mopping his eyes, declares an adjournment, a recess and a small, unplanned parade.',
          ]),
          [
            Choice('[ASK THE MINISTER OF FUN]', 'fun'),
            Choice('[GO TO THE PUMP]', 'out'),
          ],
        ),
        Scene.talk(
          'fun',
          say([
            'Jos, nine years old, salutes with a licked finger. “I know everything,” he says. “Marge sabotaged the pump last week so Gary wouldn’t take it. Gary took it anyway. Now it’s locked. Tilly has the key. She won’t give it to either of them.”',
            '“Why not?”',
            '“Because the key is the only thing that keeps them from killing each other,” says Jos. “It’s a very good key.”',
          ]),
          [Choice('[GO TO THE PUMP]', 'out')],
          flags: ['jos_tip', 'knows_key'],
          reward: const Reward(xp: 8),
        ),
        Scene.end('out', say(['The pump stands on a little hill at the edge of town. A crowd has already assembled: all seven citizens, a goat, a recorder and a stern, tearful atmosphere.'])),
      ],
    ),
    Checkpoint(
      id: 'pump',
      title: 'BRENDA THE PUMP',
      km: 4.6,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 30),
      journal: (c) => [
        'The pump, Brenda, is padlocked. Tilly has the key. Marge built it. Gary wants it nationalised. A brawl is brewing.',
        if (c.flag('pump_fixed')) 'I found the real fault: Brenda was never broken. She was just badly loved.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Brenda is a handsome, ancient hand pump, painted green, with a brass tap and a padlock the size of a fist. A faded ribbon is tied around her handle, and someone has pinned a small flower to her spout.',
            'Marge stands to her left, President Gary to her right. Tilly stands in front with the key held up. Bart stands behind with the goat, unhelpfully.',
            '“Everyone calm down,” says President Gary, calmly. Nobody does.',
          ]),
          [
            Choice('[EXAMINE THE PUMP]', 'exam', show: (c) => !c.flag('saw_pump')),
            Choice('[PICK THE PADLOCK]', 'lock'),
            Choice('[TALK TO TILLY ABOUT THE KEY]', 'tilly'),
          ],
        ),
        Scene.talk(
          'exam',
          (c) => [
            'You crouch beside Brenda. Her handle is smooth. Her spout is clean. She is, you realise, in perfect working order. She has a slow, steady, plentiful draw.',
            if (c.skill('ENGINEERING') >= 1)
              'In fact, she is better than perfect. She’s been refitted: a new seal, a new washer, a new bearing. All of it recent. All of it done in the dark by someone who loves her.',
            'Nobody has ever stolen from Brenda. Nobody has ever hurt her. The whole dispute is over a pump that is, entirely and unreasonably, fine.',
          ],
          [Choice('[CONTINUE]', 'a')],
          flags: ['pump_fixed', 'saw_pump'],
          reward: const Reward(xp: 8),
        ),
        Scene.lock(
          'lock',
          say(['The padlock gives a small, stubborn click. Everyone holds their breath.']),
          win: 'unlocked',
          fail: 'jammed',
        ),
        Scene.talk(
          'unlocked',
          say([
            'The padlock opens. A gasp goes up. Marge dives at the pump; Gary dives at Marge; Tilly dives at the padlock. The goat runs. By the time the dust settles, nobody has done any harm and everyone has the pump handle in one hand.',
            'Brenda sits there, unbothered, a little crooked. They all look at one another, guilty. “Well,” says President Gary, “that’s one way to share it.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['unlocked'],
        ),
        Scene.talk(
          'jammed',
          say([
            'The lock bites your pick in half. There is a silence. “That,” says Marge, “was the most disrespectful thing anyone has ever done to Brenda.”',
            'You are asked, firmly, to stop.',
          ]),
          [Choice('[CONTINUE]', 'a')],
          flags: ['jammed'],
        ),
        Scene.talk(
          'tilly',
          say([
            'You take Tilly aside. “Why do you have the key?” “Because,” she says, “if I give it to Marge, she’ll hoard it, and if I give it to Gary, he’ll build a statue of it. I’m holding it for everyone.”',
            '“Does anyone know that?”',
            'She stares at you. “No,” she says. “No one has asked.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['talked_tilly'],
          reward: const Reward(xp: 10),
        ),
        Scene.end('out', say(['The crowd falls quiet. They are all looking at you, seven faces, a goat and a nine-year-old with a rosette. “Your Honour,” says the President. “Please. Decide.”'])),
      ],
    ),
    Checkpoint(
      id: 'summit',
      title: 'THE SUMMIT',
      km: 5.5,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 25, xp: 40),
      journal: (c) => ['I had to decide who owned Brenda the pump. Everyone watched. There was bunting.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The whole Republic has gathered around a rug in the dust. A small table holds a bottle of ginger beer and a flag. The Minister of Fun has made a banner: THE DISPUTE IS OVER (SOON).',
            'All seven stand before you with their arms folded or clasped, and each of them has a plan. You can feel the weight of it. A country is asking you for the answer.',
          ]),
          [
            Choice('[DRAFT A TREATY]', 'treaty'),
            Choice('[BACK TILLY]', 'tilly'),
            Choice('[PUT IT TO A VOTE]', 'vote'),
            Choice('[TAKE CHARGE YOURSELF]', 'take'),
          ],
        ),
        Scene.talk(
          'treaty',
          (c) => [
            'You write it on the back of a customs form. The pump belongs to everyone. The key is held by Tilly. The handle is held by Marge. The flag is held by Gary. The goat is held by nobody, as is traditional.',
            if (c.flag('marge_proud') && c.flag('gary_soft') && c.flag('tilly_fair'))
              'Because you heard each of them out, each recognises something of their own in it. Marge nods. Gary dabs his eye. Tilly says, grudgingly, “Acceptable.”'
            else
              'It is not perfect. Each one finds a fault. But you’ve left a space in the middle where something fair might grow, and they agree to try.',
          ],
          [Choice('[SIGN IT]', 'end_treaty')],
        ),
        Scene.talk(
          'tilly',
          say([
            'You say, “Tilly should be in charge. She’s the only one who hasn’t wanted the pump for herself.”',
            'There’s a gasp. President Gary’s hand goes to his medals. Marge looks like she’s been slapped with a wet fish. Tilly says, “I... wasn’t prepared for this.”',
            'Bart takes a step forward, and Moira the goat lowers her head. Nobody has told you what a goat can do in a coup. You’re about to find out.',
          ]),
          [
            Choice('[LET IT HAPPEN]', 'end_coup'),
            Choice('[SETTLE IT BY COMBAT]', 'brawl'),
          ],
        ),
        Scene.fight(
          'brawl',
          say(['Bart charges, with Moira at his side. It is, you’ll later tell people, the most dignified goat fight of your career.']),
          EnemyType.straggler,
          win: 'end_coup',
          fail: 'end_treaty_lost',
        ),
        Scene.talk(
          'vote',
          say([
            'You propose a referendum. Instantly, the Republic erupts into joy. Nan Barrow brings the ballot box, a biscuit tin with a slot cut in the lid. Old Pete draws up the ballot in iambic pentameter. The Minister of Fun hands out pencils.',
            'The result is three votes to three, with one abstention from the goat. A recount is called. The recount is also a tie. President Gary weeps. Old Pete stands, clears his throat, and delivers a limerick.',
          ]),
          [Choice('[ABIDE BY THE LIMERICK]', 'end_referendum')],
        ),
        Scene.talk(
          'take',
          say([
            'You step up onto a barrel. “I’ll take it,” you say. “The pump is mine. Everyone else is a citizen of Greater Nowhere, under my benevolent supervision.”',
            'There’s a very long pause. Then, slowly, someone starts to clap. It’s the Minister of Fun. Then Old Pete. Then Nan. President Gary looks stricken, then relieved. “Thank goodness,” he whispers. “Someone else can do it.”',
          ]),
          [Choice('[WEAR THE HAT]', 'end_annexed')],
        ),
        Scene.end(
          'end_treaty',
          say([
            'The treaty is signed in seven hands and one hoof. Moira, the goat, ceremonially eats the margin. A ginger beer is passed round. President Gary delivers a speech that lasts a full forty minutes and makes everyone cry.',
            'Marge touches Brenda’s handle. “Alternate Tuesdays,” she mutters. Tilly returns the key to its hook. Nobody argues. It is the strangest sound you’ve ever heard in Nowhere.',
            'You’re awarded the Order of the Sock, Second Class. You didn’t know there was a First.',
          ]),
          ending: 'treaty',
        ),
        Scene.end(
          'end_treaty_lost',
          say([
            'The goat wins. Bart picks you up from the dust and apologises three times. “Moira doesn’t like losing,” he says. “Neither do I.”',
            'The treaty is signed by consensus after that. It’s a good one. You’re nursing a bruise the size of a hoofprint.',
          ]),
          ending: 'treaty',
        ),
        Scene.end(
          'end_coup',
          say([
            'It is, as coups go, almost unbearably polite. Tilly accepts the key and the sash. President Gary hands over the medals one by one, with a little sob each time. “I’m very proud of her,” he says. “It’s just so hard to let go of a country.”',
            'He is appointed Minister of Complaints at once. He is already making a list.',
            'The pump runs smoothly. Tilly turns out to be a surprisingly brisk ruler. Marge is quietly delighted to be left alone with Brenda. It is, for Nowhere, a new golden age.',
          ]),
          ending: 'coup',
        ),
        Scene.end(
          'end_referendum',
          say([
            'The limerick is upheld by a show of hands. It concerns a pump and a goat and a man from Peru, and nobody can quite say what it decides. But everyone agrees it’s fair.',
            'The pump will be shared. The key will be rotated by lot. President Gary stays on as President, because nobody else wants it. Tilly stays on as Opposition, because that’s who she is.',
            'You leave Nowhere to the sound of a recorder. It is, on the whole, the best country you’ve ever left.',
          ]),
          ending: 'referendum',
        ),
        Scene.end(
          'end_annexed',
          say([
            'You are crowned in a hat made of three socks. It’s a very warm hat. It’s also, you realise, unremovable. The Republic bows. The goat bows. President Gary quietly begins training you in the art of the ceremonial wave.',
            'Within the hour you have settled four disputes about goats and one about a hat. By dusk you have learned a terrible truth: ruling is mostly listening to people who want to be told they’re right.',
            '~You’re the only head of state with a hat that has a name. It is Colin.',
          ]),
          ending: 'annexed',
        ),
      ],
    ),
  ],
);
