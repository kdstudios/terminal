import '../../story_model.dart';
import '../characters/brother_positive.dart';
import '../story_kit.dart';

// THE WASTELAND WEDDING
// Cedric the groom asks you to find his missing bride, Marigold. She is
// hiding because she does not want to marry him. The truth is gentler and
// funnier than that.
//
// Cast: Cedric (groom, earnest), Marigold (bride, hiding in a silo), Wilf (best
// man, quietly in love with her, and she with him), Aunt Beryl (formidable),
// Brother Positive (officiant, if the church story has been finished).
// Endings: escape, truth, compromise, officiate.

List<Choice> _groomChoices() => [
      Choice('[ASK CEDRIC ABOUT MARIGOLD]', 'g_mari', show: (c) => !c.flag('seen.mari')),
      Choice('[ASK THE BEST MAN, WILF]', 'g_wilf', show: (c) => !c.flag('seen.wilf')),
      Choice('[ASK AUNT BERYL]', 'g_beryl', show: (c) => !c.flag('seen.beryl')),
      Choice('[START LOOKING]', 'g_go'),
    ];

final StoryDef weddingStory = StoryDef(
  id: 'wedding',
  title: 'THE WASTELAND WEDDING',
  tagline: 'EVERYONE IS HERE. THE CAKE IS READY. THE BRIDE IS NOT.',
  difficulty: 'LOW',
  destinationKm: 6.5,
  recommendedLevel: 2,
  intro: [
    'The invitation is hand-delivered by a very sweaty man in a rented suit. It’s printed on a seed packet. It reads: YOU ARE CORDIALLY INVITED TO THE WEDDING OF CEDRIC AND MARIGOLD. THERE WILL BE CAKE. THERE WILL BE A BAND. THERE WILL, ABSOLUTELY, BE A BRIDE.',
    'The last line has been crossed out and rewritten in a trembling hand: PLEASE HELP. SHE’S GONE.',
    'The man is Cedric, the groom. He is thirty-five and looks like an apologetic labrador. “I need someone to find her,” he says. “I’d do it myself, but I’ve got a speech, and I’ve lost my cufflinks, and, frankly, I’m afraid of what I’ll find.”',
  ],
  reward: const Reward(scrap: 130, xp: 90, stims: 1),
  endings: {
    'escape': const Ending('escape', 'THE GREAT ESCAPE',
        'You helped her out of the silo, over the fence and into the dark. Cedric was devastated for about an hour, and then, to everyone’s astonishment, relieved. Marigold sends you a postcard every spring. It always says the same thing: THANK YOU. I’M STILL FREE.',
        bonus: Reward(xp: 50, scrap: 20), world: ['wedding.escape']),
    'truth': const Ending('truth', 'THE TRUTH WILL OUT',
        'You told the wedding party everything. There was a long, awful silence, a slap, a weep, and a catastrophic collapse of the cake. Afterwards, though, everyone seemed oddly better. It was the best-attended funeral for a marriage the wasteland has ever seen.',
        bonus: Reward(xp: 60), world: ['wedding.truth']),
    'compromise': const Ending('compromise', 'A VERY GOOD FRIENDSHIP',
        'You talked them round. There was no wedding, but the party went ahead, and by midnight Cedric and Marigold were dancing, as friends, with a speech about it. They are, to this day, extremely close. They share a house. It has two doors.',
        bonus: Reward(xp: 70, stims: 1), world: ['wedding.compromise']),
    'officiate': const Ending('officiate', 'BY THE POWER VESTED IN ME',
        'You stood up in front of two hundred guests, a cake and a goat, and married the right two people. Nobody had planned it. Everybody had hoped for it. The vows were improvised. The cake survived. You are, by a technicality, still licensed.',
        bonus: Reward(xp: 80, scrap: 40), world: ['wedding.officiate']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You borrow a clean shirt and walk to the wedding with a bunch of weeds you’re pretending are flowers.']
      : ['The sound of a very tired band playing “The Way You Look Tonight” floats over the hill.'],
  ambient: [
    Ambient('Confetti blows across the road, a long, dusty ribbon of it. Some of it is clearly torn-up tax forms.', maxKm: 2),
    Ambient('A hand-painted sign: WEDDING THIS WAY. IF YOU’RE LOST, YOU’RE EARLY.', maxKm: 3),
    Ambient('You pass a very small chapel built from a bus shelter, a garden gnome and a door. It looks happy.', maxKm: 3),
    Ambient('Somewhere a bridesmaid shrieks. It could be joy. It could be a goose.', minKm: 1, maxKm: 4),
    Ambient('A bouquet lies in a ditch, flowers wilting. A tiny note: SORRY, BERYL. I RAN.', minKm: 1.5, maxKm: 4),
    Ambient('Two children run past in dress clothes, chasing a deflated balloon. Neither of them is crying. It’s a triumph.', minKm: 2),
    Ambient('You hear a faint “I do.” It’s a rehearsal. The groom is practising on a lamppost.', minKm: 2.5, maxKm: 5),
    Ambient('~Weddings are mostly logistics held together by love and an aunt.', minKm: 3),
    Ambient('A white veil is snagged on a barbed-wire fence, flapping. It looks like a flag of surrender.', minKm: 3.5, when: (c) => c.done('groom')),
    Ambient('The band strikes up a hopeful chord. Then stops. Then, very quietly, begins again.', minKm: 4.5),
    Ambient('Aunt Beryl’s voice, from far away: “IF SHE’S NOT HERE IN TEN MINUTES, I’M CUTTING THE CAKE.”', minKm: 5, when: (c) => c.done('groom')),
    Ambient('~There’s someone, somewhere, rehearsing a speech they’ll never get to give.', minKm: 5.5),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'road',
      title: 'THE WEDDING ROAD',
      km: 1.0,
      text: (c) => [
        'The wedding is held in a farmyard decked with fairy lights, bunting made from old pillowcases and two hundred folding chairs. A banner over the barn reads CEDRIC ♥ MARIGOLD. There is a long white table with a four-tier cake. There is a goat in a bow tie.',
        'And there is no bride. There is a gap in the procession, and a veil on a fence.',
        '~Somewhere out there is a person who said yes, and has had a very long think.|',
      ],
      journal: say(['A farmyard wedding, fairy lights, a four-tier cake and a goat in a bow tie. No bride.']),
      reward: const Reward(xp: 5),
    ),
    Checkpoint(
      id: 'groom',
      title: 'THE WEDDING PARTY',
      km: 2.2,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 20),
      journal: (c) => [
        'The wedding party: Cedric the groom, Wilf the best man, Aunt Beryl, and a goat in a bow tie.',
        if (c.flag('seen.wilf')) 'Wilf was strangely quiet about Marigold. He went pink.',
        if (c.flag('seen.beryl')) 'Aunt Beryl suspects Marigold is “having a funny turn.” She suspects everyone of everything.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The wedding party is arranged under the bunting in a state of high, trembling dread. Cedric wrings his hands. A tall, awkward man in a too-small suit stares at his shoes. An elderly woman in a purple hat taps her stick on the ground with a rhythm like a ticking bomb.',
            '“She’s been gone since seven,” says Cedric. “The dress is on the bed. The shoes are on the step. She’s just... not.”',
            if (BrotherPositive.mood(c) != 'new') 'Near the back, in a robe made of jump leads, Brother Positive is hovering with a prayer book. “I’m the officiant,” he whispers. “I’ve done a hundred funerals and one christening. This is a first.”',
            'Everyone looks at you.',
          ],
          _groomChoices(),
        ),
        Scene.talk(
          'g_mari',
          say([
            '“She’s wonderful,” says Cedric. “She’s funny and clever and she knows how to make a bean casserole that doesn’t explode. I asked her, three months ago, in a field. She said, ‘Oh. Yes. Alright.’ I think it was a yes.”',
            '“Did she sound happy?”',
            'Cedric thinks about it for a long time. “She sounded,” he says, “like someone being offered a second biscuit. Politely. Not quite wanting it.”',
            'He stares at his hands. “I thought that’s how it was, for grown-ups.”',
          ]),
          _groomChoices(),
          flags: ['seen.mari', 'doubt_cedric'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'g_wilf',
          say([
            'The best man startles. His name is Wilf, and he is built of elbows. He answers your every question with a different shade of pink. “I don’t know where she is,” he says. “I haven’t seen her. I’ve been, er, sorting the chairs.”',
            '“Which chairs?”',
            '“All of them,” says Wilf, too quickly. “Twice.”',
            'He has a single, wilted flower in his buttonhole. You notice, with a small, creeping sense of understanding, that it’s the same kind as the bride’s bouquet. It is the only fresh thing on him.',
          ]),
          _groomChoices(),
          flags: ['seen.wilf', 'wilf_pink'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'g_beryl',
          say([
            '“Of course she’s run off,” says Aunt Beryl. “The girl’s got sense. Cedric is a lamb, but a lamb is not what you want in a husband. She wants a nice, solid, sensible man with a pension.”',
            '“Does Cedric have a pension?”',
            '“He has a goat,” says Beryl, with a snort. “Which is, if anything, worse.” She jabs your arm with her stick. “Find her. Bring her back. And when you do, tell her she’s a damn fool. And that I’m very proud.”',
          ]),
          _groomChoices(),
          flags: ['seen.beryl', 'beryl_hint'],
        ),
        Scene.end('g_go', say([
          'You set off with a tin cup, a torch and a growing sense of responsibility. Cedric presses a photograph into your hand: a smiling woman in a sunhat, laughing at a bean. “Please,” he says. “Be gentle. If she doesn’t want me, I want to hear it from her.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'trail',
      title: 'THE TRAIL',
      km: 3.8,
      art: 'drifter',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 25),
      journal: (c) => [
        'I followed Marigold’s trail: a dropped glove, a discarded bouquet, a track of small, determined bootprints heading for the old grain silo.',
        if (c.flag('found_letter')) 'I found a letter she’d begun, and not finished.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The trail begins at the farmyard gate. A single shoe, white satin, lies in the dust. Further on, a glove. Then a little way off, the bouquet in the ditch, with its note: SORRY, BERYL. I RAN.',
            'The bootprints are small and determined, heading across two fields toward a tall, round, rust-streaked silo. It stands against the sky like a lighthouse.',
            'A farmhand leaning on a fence watches you with open curiosity. “If you’re looking for the bride,” he says, “she went that way. At a run. In boots. I thought it was part of the ceremony.”',
          ]),
          [
            Choice('[FOLLOW THE BOOTPRINTS]', 'follow'),
            skillChoice('SURVIVAL', 1, 'READ THE TRAIL CAREFULLY', 'read'),
            Choice('[SEARCH THE DITCH]', 'ditch', show: (c) => !c.flag('found_letter')),
          ],
        ),
        Scene.talk(
          'read',
          say([
            'You crouch over the prints. They don’t wander. She knew exactly where she was going. The prints are deep at the toes: running. But halfway across the second field, they stop, turn round, go ten paces back toward the farm, turn again.',
            'She hesitated. She went back, and then she changed her mind. It’s the saddest, most human thing you’ve ever seen in the dirt.',
            'Beside the last print, someone has dropped a hanky, and written on it, in felt-tip: I’M NOT RUNNING FROM HIM.',
          ]),
          [Choice('[FOLLOW THE BOOTPRINTS]', 'follow')],
          flags: ['read_trail', 'not_from_him'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'ditch',
          say([
            'In the ditch, under the bouquet, you find a letter. It’s half-written, on the back of a seating plan. “Dear Cedric,” it starts. “I think you’re the kindest person I know. I’d be a good wife. I’d be a perfectly good wife. But...” And the writing stops.',
            'There’s a smudge on the paper. She’s been crying on it.',
            '~She’s not leaving him. She’s leaving the idea.',
          ]),
          [Choice('[FOLLOW THE BOOTPRINTS]', 'follow')],
          flags: ['found_letter'],
          reward: const Reward(xp: 12),
        ),
        Scene.end('follow', say([
          'You cross two fields and a stream, over a gate with a notice saying DO NOT ENTER (WEDDING). The silo grows as you approach: a rust-streaked tower with a small ladder up one side. A single boot, white, sits at the bottom of it, with the laces tied in a defiant bow.',
          'From inside the silo comes a sound. Someone is crying quietly, or laughing, or, you realise, doing both.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'silo',
      title: 'THE SILO',
      km: 5.0,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 30),
      journal: (c) => [
        'I found Marigold in a grain silo, in her wedding dress, eating a sandwich. She did not want to marry Cedric. She had a reason, and it was Wilf.',
        if (c.flag('promised_secret')) 'I promised to keep her secret. I may have to break it.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'You climb the ladder. At the top is a hatch, and beyond it a round, dim, echoing chamber. In the middle, sitting on an upturned crate, in a half-ruined wedding dress with her hair coming down, is a woman eating a cheese sandwich.',
            '“Hello,” says Marigold. “I thought I heard someone. Is it Beryl? It’s not Beryl, is it? I’ve prepared for Beryl. I’ve a whole speech.”',
            '“It’s not Beryl.”',
            '“Thank goodness.” She offers you half of the sandwich. “I’ve been hiding for six hours,” she says. “It’s very peaceful in here. There’s an echo.”',
          ]),
          [
            Choice('[ASK WHY SHE’S HIDING]', 'why'),
            Choice('[SAY CEDRIC IS WORRIED]', 'worry'),
            Choice('[SIT AND LISTEN]', 'sit'),
          ],
        ),
        Scene.talk(
          'why',
          say([
            '“I don’t want to marry Cedric,” says Marigold. She says it out loud for what seems to be the first time, and her whole face loosens with relief. “I love him. I do. But as a sort of... very large, very kind brother. He’s lovely. He’s the nicest person in the wasteland. And I don’t want to wake up next to him every day and feel I’m being nice back.”',
            'She laughs, wet and helpless. “I said yes because he looked so hopeful. Nobody’s ever looked at me like that. I couldn’t bear to disappoint him.”',
            '“Is there someone else?”',
            'Her face does something complicated. “Don’t,” she says. “Please. I haven’t told anyone.”',
          ]),
          [
            Choice('[“IT’S WILF, ISN’T IT.”]', 'wilf'),
            Choice('[“YOUR SECRET IS SAFE.”]', 'safe', flags: ['promised_secret']),
          ],
          flags: ['heard_why'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'worry',
          say([
            '“Cedric’s worried sick,” you say. “He’s out there with a speech and a goat.”',
            'Marigold covers her face. “Oh, I know,” she says. “It’s awful. He’ll be standing at the altar like a lost umbrella. And I’m up here eating cheese. I’m a terrible person.”',
            '“You’re not a terrible person.”',
            '“No,” she agrees, quietly. “I’m just a person who’s run out of ways to be polite.”',
          ]),
          [Choice('[ASK WHY SHE’S HIDING]', 'why')],
        ),
        Scene.talk(
          'sit',
          say([
            'You sit on the floor of the silo with her, among the husks and the dust and the light falling in from the hatch. She finishes her sandwich. She talks. She talks about Cedric’s casseroles, and her mother’s funeral, and how a person can be loved so sincerely that they can’t find the door.',
            'By the end, she’s stopped crying. She is, rather beautifully, in her ruined dress, laughing. “Do you know,” she says, “nobody’s asked me what I wanted since I was seven?”',
          ]),
          [Choice('[ASK WHAT SHE WANTS]', 'why')],
          flags: ['listened_mari'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'wilf',
          say([
            'There’s a very long silence. Marigold’s mouth opens and shuts. “How,” she says, “did you know?”',
            '“He’s the only person who’s kept a flower in his buttonhole. And the only one who didn’t cry when you vanished.”',
            '“He’s the only one who understood,” says Marigold, in a tiny voice. “We’ve never said a word. We just, sort of, stand near each other. At parties. It’s been three years. We’ve been very, very polite.”',
            'She starts laughing again, and this time it breaks. “Oh, God,” she says. “I’ve ruined everything.”',
          ]),
          [Choice('[“NOT YET.”]', 'out')],
          flags: ['knows_wilf', 'wilf_secret'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'safe',
          say([
            '“Your secret’s safe,” you say. “I won’t say a word.”',
            'Marigold looks at you with tears in her eyes. “Thank you,” she says. “I’d like to tell it myself. Someday.” She smooths her dress. “I just wish someone had told me you’re allowed to say no.”',
          ]),
          [Choice('[HELP HER DOWN]', 'out')],
        ),
        Scene.end('out', say([
          'You help her down the ladder. She takes it slowly, one rung at a time, with her skirts bunched in one hand and the silo watching her go. At the bottom she turns and looks at the farmyard, far off in the evening light, a spray of fairy lights and bunting. “They’re all waiting,” she says. “I suppose I’d better decide.”',
        ])),
      ],
    ),
    Checkpoint(
      id: 'ceremony',
      title: 'THE CEREMONY',
      km: 6.5,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 30, xp: 45),
      journal: (c) => ['Back at the farm, two hundred guests, a cake, a goat and a bride who didn’t want to be one. I had to choose how it ended.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'Two hundred guests turn as one. The band hits a chord and falters. The goat’s bow tie slips. In the aisle stands Marigold, in the half-ruined dress, with her chin up. At the altar, Cedric stares at her like a man looking at a sunrise he’s suddenly afraid of.',
            'Aunt Beryl rises. Wilf goes white. Brother Positive, if he’s there, drops the prayer book.',
            'Everyone is waiting. You’re the only one who knows what Marigold wants. She looks at you with enormous, pleading, funny eyes.',
          ],
          [
            Choice('[HELP HER ESCAPE]', 'escape'),
            Choice('[TELL EVERYONE THE TRUTH]', 'truth'),
            Choice('[NEGOTIATE]', 'negotiate'),
            Choice('[TAKE THE VOWS YOURSELF]', 'officiate', show: (c) => c.flag('knows_wilf') || c.flag('wilf_pink')),
          ],
        ),
        Scene.talk(
          'escape',
          say([
            'You catch Marigold’s eye and tilt your head at the back gate. She nods. You create a small, ruthless diversion: you knock a tray of canapés into the band. In the chaos, you steer her round the barn, through the hedge and into the dusk.',
            'Behind you, Cedric’s voice, small, confused: “...is it part of the ceremony?”',
          ]),
          [Choice('[RUN]', 'end_escape')],
          flags: ['helped_escape'],
        ),
        Scene.talk(
          'truth',
          say([
            'You step up to the altar. “She doesn’t want to marry you, Cedric,” you say. “Not because you’re bad. Because she isn’t in love with you. And she’s too kind to say it.”',
            'The whole farmyard inhales. Aunt Beryl’s stick hits the ground. Cedric stands there for a very long time. “Oh,” he says. “Oh. Well. That’s... that’s a very clear thing to say.”',
            'Somebody sobs. Somebody else drops a cake slice. The goat bleats, and the world lurches on.',
          ]),
          [Choice('[CONTINUE]', 'end_truth')],
          flags: ['exposed_truth'],
        ),
        Scene.talk(
          'negotiate',
          (c) => [
            'You take Cedric aside, and then Marigold, and then both of them together, behind the barn, among the stacked folding chairs. You do what you do best: you listen. You ask them what each of them wants, and you let them say it.',
            'It’s awful for a minute. Cedric weeps. Marigold weeps. Then, slowly, Cedric looks up. “I was lonely,” he says. “I thought a wedding would fix it. I’d have married anyone who said yes.”',
            '“I’d have said yes to anyone who asked,” says Marigold, and they both start laughing, in a helpless, damp, relieved way, like people who’ve just been let out of the rain.',
            if (c.flag('doubt_cedric')) 'You can see it was always, quietly, in him.',
          ],
          [Choice('[SUGGEST A PARTY]', 'end_compromise')],
          flags: ['negotiated'],
          reward: const Reward(xp: 20),
        ),
        Scene.talk(
          'officiate',
          (c) => [
            'You step up to the altar. You raise a hand. “Cedric,” you say. “Marigold. Wilf.” Wilf, at the back, chokes on a canapé. “I think this wedding,” you tell two hundred guests, “is happening. It’s just not the one we expected.”',
            'Cedric’s mouth opens. He looks at Marigold. He looks at Wilf. And something in his face goes soft. “Oh,” he says. “Oh. You and... Wilf. Oh, of course. I’m so stupid. It’s so obvious.” He starts laughing, and crying. “I’ve been so slow.”',
            'He gives Wilf a shove. “Go on,” he says, and takes Marigold’s hand and puts it into Wilf’s, with a ruinous dignity that makes the whole barn weep.',
            if (BrotherPositive.mood(c) != 'new') 'Brother Positive clasps his prayer book to his chest. “It’s the most beautiful current I’ve ever seen,” he sobs.',
          ],
          [Choice('[MARRY THEM]', 'end_officiate')],
          flags: ['married_them'],
          reward: const Reward(xp: 30),
        ),
        Scene.end('end_escape', say([
          'You run until the lights are far behind. Marigold stops, laughing, in the middle of a dark field, and takes off her other boot. “I’ve never done anything like this,” she says. “I feel like a disaster. I feel wonderful.”',
          'She walks away into the dusk, barefoot, with her veil in her hand. At the top of a hill she turns and waves. Cedric, to his credit, doesn’t go after her. He stands among the chairs for a long time, then goes to the cake and cuts a slice.',
        ]), ending: 'escape'),
        Scene.end('end_truth', say([
          'It’s a disaster. It’s also, undeniably, the most honest day in the history of the farm. There is a slap, a weep, a very long speech from Aunt Beryl about “young people,” and a collapse of the cake so complete it’s almost a performance.',
          'By dusk, everyone is sitting on the grass, eating cake with their hands, talking about their own marriages, in a way they never have. Cedric and Marigold sit side by side, silently, with a plate between them. By morning they’re friends.',
        ]), ending: 'truth'),
        Scene.end('end_compromise', say([
          'The wedding becomes a party. A big one. Cedric makes a speech, a surprisingly good one, about “the importance of being loved the right way.” Marigold cries. The band plays something with a lot of trumpet. Aunt Beryl dances with the goat.',
          'It isn’t a wedding. It’s better. At midnight, Cedric and Marigold, side by side, cut the cake with a single knife and pose for a photograph. “To us,” says Cedric. “To the nearly-married.”',
        ]), ending: 'compromise'),
        Scene.end('end_officiate', say([
          'You make it up as you go. It’s a very short ceremony. “Do you, Wilf, promise to stand awkwardly near her for the rest of your life?” “I do.” “Do you, Marigold, promise to say what you want?” “I do. I really, really do.”',
          'The farmyard erupts. The band plays. The goat, in its bow tie, rears up and, with immense dignity, falls into the cake. Cedric, in the front row, weeps with joy, with great abandon, with a napkin on his head.',
          'Afterwards, Aunt Beryl finds you by the buffet. She pokes you with her stick. “Not bad,” she says. “For an amateur.” It’s the finest praise you have ever received.',
        ]), ending: 'officiate'),
      ],
    ),
  ],
);
