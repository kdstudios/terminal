import '../../story_model.dart';
import '../story_kit.dart';

// THE MANUFACTURED MAN
// Unit 47 is certain he has a family. The laboratory records say his memories
// were built from the patterns of a dead volunteer. Units 1-46 were failures,
// terminations... and one may still be alive.
//
// Edit points: unit47's memory topics (meet), the records (lab), Unit 19 and
// Ruth (kin), and the five endings: person, original, collective, continues, empty.

List<Choice> _meetChoices() => [
      Choice('[ASK ABOUT HIS FAMILY]', 'm_family', show: (c) => !c.flag('seen.family')),
      Choice('[ASK WHAT HE REMEMBERS OF THE LAB]', 'm_lab', show: (c) => !c.flag('seen.lab')),
      Choice('[TEST A MEMORY]', 'm_test', show: (c) => !c.flag('seen.test')),
      Choice('[OFFER TO WALK HIM THERE]', 'm_go'),
    ];

final StoryDef manufacturedStory = StoryDef(
  id: 'manufactured',
  title: 'THE MANUFACTURED MAN',
  tagline: 'HE REMEMBERS A WIFE, A DAUGHTER AND A DOG. THE LABORATORY REMEMBERS A SPREADSHEET.',
  difficulty: 'MODERATE',
  destinationKm: 9.0,
  recommendedLevel: 4,
  unlock: const Unlock(minLevel: 3, hint: 'REACH LEVEL 3.'),
  intro: [
    'A stranger turns up at your shutter before dawn, panting, with a coat over his head. “Please,” he says. “I have to tell someone. I was made in a laboratory. I think. I was made. And I have a daughter.”',
    'He says his name is Unit 47. He says it the way people say a name they have been given for a hat. He holds out a hand, very carefully, as if he has seen other people do it.',
    'He wants someone to walk with him back to the place he came from, nine kilometres south. He wants to know what he is. He seems far more frightened of the answer than of the walk.',
  ],
  reward: const Reward(scrap: 180, xp: 140, stims: 1, picks: 1),
  endings: {
    'person': const Ending('person', 'A PERSON, NOT A PRODUCT',
        'You told him it did not matter where the memories came from, only what he did with them. He took the name Walter, then changed it to Tom, then decided he had time to choose. He is learning to garden.',
        bonus: Reward(xp: 70), world: ['unit47.person']),
    'original': const Ending('original', 'THE ORIGINAL',
        'You took him to the woman the memories were built from. Ruth looked at him for a long time and then, very quietly, made him a cup of tea. Neither of them has said what he is to her. Both of them show up on Sundays.',
        bonus: Reward(xp: 60, stims: 1), world: ['unit47.original']),
    'collective': const Ending('collective', 'THE COLLECTIVE',
        'You joined him to the archive of the forty-six. The failed units woke in him, all at once, and they are not one person now, and not forty-seven. He speaks in a soft chorus. It is oddly beautiful, and nobody can decide if it is a victory.',
        bonus: Reward(parts: 3, xp: 40), world: ['unit47.collective']),
    'continues': const Ending('continues', 'THE EXPERIMENT CONTINUES',
        'You returned him to the facility. The lights came on one by one. He said thank you for helping him come home. A clipboard somewhere was updated. You collected the finder’s fee and have been unable to enjoy it.',
        bonus: Reward(scrap: 120), world: ['unit47.returned']),
    'empty': const Ending('empty', 'THE EMPTY ROOM',
        'He asked you to switch the room off and you did. He sat in the chair with his hands folded. He was not afraid. The room is empty now. The memories went wherever such things go, and you keep a small blue folder of them that you will never open.',
        bonus: Reward(xp: 50), world: ['unit47.empty']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['Unit 47 walks half a step ahead of you, then half a step behind, never quite sure which place is the right one for a person.']
      : ['Unit 47’s boot-prints are still in the dust, smaller than you remember, and very carefully placed.'],
  ambient: [
    Ambient('He hums as he walks. When you ask the tune, he says, “My wife’s. I think.” His voice trembles on the “think.”', maxKm: 4),
    Ambient('Unit 47 picks up a stone, studies it, and puts it back with great care, as though correcting the world.', maxKm: 4),
    Ambient('“I’ve never been this far from the room,” he says. “And yet I remember a whole life out here. Is that strange?”', maxKm: 5),
    Ambient('He stops to watch a bird for a long time. He’s clearly decided that watching birds is something people do.', minKm: 1, maxKm: 5),
    Ambient('You find a laminated sign: CAREFUL. THIS ROAD LEADS TO THE EVERHART INSTITUTE. THERE IS NO NEED TO ARRIVE.', maxKm: 4),
    Ambient('“Do you ever think,” Unit 47 says, “that you’re not the person you were yesterday?” “Every day,” you say. He looks relieved.', minKm: 3, maxKm: 7),
    Ambient('#...UNIT 47 PROGRESS: WITHIN EXPECTED PARAMETERS. DO NOT ALARM THE SUBJECT. (STATIC)', minKm: 3, when: (c) => c.skill('HACKING') >= 1),
    Ambient('He says “Pip” softly to himself, over and over, to see if it is still there. It is.', minKm: 4, maxKm: 8),
    Ambient('You notice that you’ve started thinking of him as “he.” You’re not sure when that happened.', minKm: 4, maxKm: 8),
    Ambient('~There are people who don’t know where their feelings came from. There are fewer who will admit it.', minKm: 5),
    Ambient('Unit 47 offers you half of his sandwich without being asked. Nobody manufactured that.', minKm: 5, maxKm: 8),
    Ambient('Ahead of you, a squat white building shines like a tooth. He slows down. So do you.', minKm: 7),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'camp',
      title: 'THE HIDING PLACE',
      km: 1.5,
      text: (c) => [
        'Unit 47 leads you to the place he sheltered the first night: a culvert under the road. He has made a home of it. A blanket, a tin cup, and a wall covered in small, neat, repeated words in chalk.',
        'PIP. RUTH. PIP. RUTH. BLUEBELL. (THE DOG.) HOME IS A GREEN DOOR.',
        '“I wrote them down,” he says, “so I wouldn’t lose them.”',
        'He looks at the wall as one looks at a very old photograph. “Is it a good sign that I remember so much? Or a bad one?”',
        '~You don’t have an answer. You don’t think anyone does.|',
      ],
      journal: say(['Unit 47 sheltered in a culvert and wrote the names of his family on the wall: Pip, Ruth, Bluebell, and a green door.']),
      reward: const Reward(xp: 10),
    ),
    Checkpoint(
      id: 'meet',
      title: 'WHAT HE REMEMBERS',
      km: 3.2,
      art: 'survivor',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 25),
      journal: (c) => [
        'Unit 47 remembers a wife called Ruth, a daughter called Pip and a dog called Bluebell, in a house with a green door.',
        if (c.flag('seen.test')) 'I tested his memory. The details he gave were exact. Too exact, perhaps.',
        if (c.flag('seen.lab')) 'He remembers a white room and a voice asking whether he was comfortable.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'You rest at a broken fence. Unit 47 sits on the dust with his knees up, like a child. He has a face that looks like it was designed to be forgettable and has failed.',
            '“I need to say it out loud,” he says. “To someone who isn’t me. I remember a wife. She laughs with her whole nose. I remember a daughter who is afraid of the dark. I remember a dog that was sick on my shoes. I remember all of it. And yet I also remember a room with no windows, and a voice saying: Unit forty-seven, how are we feeling?”',
            'He looks at you. “Which one is the lie?”',
          ]),
          _meetChoices(),
        ),
        Scene.talk(
          'm_family',
          say([
            'He tells you about Ruth, who hums when she cooks and never remembers the second verse. About Pip, who is nine and has a collection of bottle tops she calls “the Army.” About the green door, which sticks in wet weather.',
            'His whole face changes as he speaks. It lights up from within. Nothing about it looks like a performance.',
            '~If it is a copy, it is a copy of something that loved them very much.',
          ]),
          _meetChoices(),
          flags: ['seen.family', 'felt_real'],
        ),
        Scene.talk(
          'm_lab',
          say([
            'Unit 47 grips his knees. “A white room. A chair that tilts back. A voice, a woman’s voice, kind. She would ask me to remember things. I always remembered them. She would say good, and write something down. It was the only time I was ever really praised.”',
            '“Did you ever see her?”',
            '“Once. She was crying.”',
            'He doesn’t seem to know why that stuck.',
          ]),
          _meetChoices(),
          flags: ['seen.lab'],
        ),
        Scene.talk(
          'm_test',
          say([
            'You ask something small. “What colour was Pip’s first bicycle?” “Blue with a white bell.” “What did Ruth give you on your wedding day?” “A pocket watch. It was a bit fast. I never fixed it.”',
            'Each answer is instant, and warm, and perfect. He doesn’t search for them. He reaches into a place that’s plainly his.',
            'Then you ask: “What’s the name of the street?” He opens his mouth. A very long moment goes by. “I don’t know,” he says, in a thin voice. “I’ve never known. It’s... blank. Why is it blank?”',
            '~The memories end where the volunteer’s file ended.',
          ]),
          _meetChoices(),
          flags: ['seen.test', 'blank_street'],
          reward: const Reward(xp: 8),
        ),
        Scene.end(
          'm_go',
          say([
            '“Thank you,” says Unit 47. He stands up very straight, as if for inspection, and then, with an effort, relaxes. “I’m not very good at being a person yet,” he says. “But I’m trying.”',
            'You set off together toward the white building on the horizon.',
          ]),
        ),
      ],
    ),
    Checkpoint(
      id: 'lab',
      title: 'THE EVERHART INSTITUTE',
      km: 5.0,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 30),
      journal: (c) => [
        'The Everhart Memory Institute still hums. Its records describe Unit 47 as built from the memory patterns of a volunteer, Walter Brandt, who died before the project began.',
        if (c.flag('knows_units')) 'Units 1 to 46 were earlier attempts. Most failed. Some were terminated. One was marked: ACTIVE.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The Institute is a low white block with its sign still bolted over the door: EVERHART MEMORY INSTITUTE — HELPING YOU REMEMBER. The lobby smells of ammonia and lilies. A waiting-room clock has stopped at 4:17.',
            'Unit 47 stops in the middle of the floor and begins to tremble. “I know this room,” he says. “I’ve been here every day of my life.”',
            'There is a reception terminal. Behind it, a door marked RECORDS.',
          ]),
          [
            Choice('[HACK THE RECORDS TERMINAL]', 'lhack'),
            Choice('[PICK THE RECORDS DOOR]', 'llock'),
            Choice('[ASK UNIT 47 TO OPEN IT]', 'lask'),
          ],
        ),
        Scene.hack('lhack', say(['The terminal asks you to confirm that you are a staff member. Technically, you are on the staff of your own life.']), win: 'records', fail: 'lfail'),
        Scene.lock('llock', say(['The lock is made for someone with a keycard, a pass, and a very good reason.']), win: 'records', fail: 'lfail'),
        Scene.talk(
          'lask',
          say([
            'Unit 47 walks up to the door and presses his palm to the plate. It slides open with a happy chime. “WELCOME BACK, UNIT FORTY-SEVEN.”',
            'His face goes slack with horror. “It knows me,” he whispers. “It knows me because I’m property.”',
          ]),
          [Choice('[GO IN]', 'records')],
          flags: ['palm_open'],
        ),
        Scene.talk(
          'lfail',
          say([
            'The terminal beeps, locks, and a calm voice says: “ACCESS DENIED. PLEASE REMAIN WHERE YOU ARE. A MEMBER OF STAFF WILL BE WITH YOU SHORTLY.” Nobody comes. Nobody has come in thirty years. The voice repeats itself with perfect patience.',
            'Unit 47 steps forward. “May I?” he says, miserably, and puts his hand on the plate.',
          ]),
          [Choice('[LET HIM]', 'lask')],
        ),
        Scene.talk(
          'records',
          (c) => [
            'The records room is a long grey corridor of shelves. You find the file in minutes, because it is the thickest. UNIT 47. PROJECT: BEREAVEMENT CONTINUITY. DONOR: WALTER BRANDT (DECEASED).',
            '#THE PROJECT AIMED TO RECONSTRUCT A DECEASED VOLUNTEER’S MEMORIES AND PLACE THEM IN A NEW SUBJECT, FOR THE COMFORT OF HIS FAMILY. 46 PREVIOUS ATTEMPTS: SEE APPENDIX.',
            '#UNIT 47: SUCCESSFUL. SUBJECT BELIEVES HE IS THE DONOR. DO NOT DISABUSE HIM.',
            'Unit 47 is reading over your shoulder. He doesn’t say anything for a long time. Then: “So there was a man. Walter. He loved them. And I’m his... his echo.”',
            if (c.flag('blank_street')) 'The street name is missing from Walter’s file. The volunteer stopped giving interviews before he gave the address.',
          ],
          [
            Choice('[READ THE APPENDIX]', 'appendix'),
            Choice('[PROTECT HIM FROM IT]', 'protect'),
            skillChoice('HACKING', 1, 'FIND THE LOCATION LOG', 'locate'),
          ],
          flags: ['knows_donor'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'appendix',
          say([
            'The appendix is a column of forty-six numbers and a short note beside each. UNIT 1: FAILED, NO RESPONSE. UNIT 2: TERMINATED. UNIT 3: FAILED. UNIT 9: SCREAMED. UNIT 14: ASKED FOR HIS MOTHER. TERMINATED. UNIT 19: STABLE. WITHHELD FROM FURTHER TRIALS. STATUS: ACTIVE.',
            'Next to UNIT 19, someone has written: PLEASE DO NOT TELL THE OTHERS. The others, you read on, were never told about each other.',
            'Unit 47’s hand is covering his mouth. “Forty-six,” he says through his fingers. “There were forty-six before me. They each thought they were someone’s husband.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['knows_units'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'protect',
          say([
            'You slide the file shut. “You don’t have to read it,” you tell him. “Not all of it. Not now.”',
            'He looks at you with enormous gratitude and enormous grief. “Nobody’s ever protected me,” he says. “They only ever did things to me gently.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['protected_him'],
        ),
        Scene.talk(
          'locate',
          say([
            'You slip through three layers of institutional carelessness and surface in a log of visitor passes. One name appears monthly for twelve years: RUTH BRANDT, WIDOW. ADDRESS: BRANDT FARM, 3 KM SOUTH-WEST. VISITING PURPOSE: TO SPEAK WITH THE SUBJECT.',
            '“The subject,” Unit 47 reads, very quietly. “She came to visit me. Every month. She sat across from me and said...” He frowns. “She said: how are you today, Walter? And I said, I’m Unit 47. And she said: of course you are.”',
            'He sits down on the floor. “She knew,” he says. “She knew and she came anyway.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['knows_ruth', 'ruth_visited'],
          reward: const Reward(xp: 15),
        ),
        Scene.end(
          'out',
          say([
            'Unit 47 stands up. “There’s one more room,” he says. “I can feel it. In the bit of me that remembers things I wasn’t told.” He points down a corridor, to a stairwell marked CRYO / ARCHIVE.',
            'You follow him down. Cold air rises to meet you.',
          ]),
        ),
      ],
    ),
    Checkpoint(
      id: 'units',
      title: 'THE FORTY-SIX',
      km: 6.8,
      art: 'cave',
      start: 'a',
      reward: const Reward(scrap: 25, xp: 35),
      journal: (c) => [
        'In the Archive, forty-six memory capsules sit in numbered racks. Unit 19’s light is still green.',
        if (c.flag('met19')) 'Unit 19 is alive. He was kept in the basement. He asked to meet Unit 47.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The Archive is a cold, humming cellar of metal racks. Forty-six glass capsules sit in their cradles, each with a number plate. Most are dark. A few have a small red light that blinks, very slowly, as if remembering to.',
            'One is green. It’s UNIT 19. And in front of it, in a chair, sits a grey-haired man in a cardigan, who rises with the gentle slowness of the very old.',
            '“Ah,” says the old man. “I wondered when you’d come. Hello, Forty-seven. I’m Nineteen. I’ve been waiting.”',
          ]),
          [
            Choice('[LET THEM TALK]', 'talk19'),
            Choice('[ASK UNIT 19 WHAT HE WANTS]', 'want19'),
            skillChoice('ENGINEERING', 1, 'INSPECT THE CAPSULES', 'caps'),
          ],
        ),
        Scene.talk(
          'talk19',
          say([
            'The two men stand and look at each other. They are different ages, different heights, different tempers. They have, you realise, the same hands.',
            '“I remember a woman called Dorothea,” says Unit 19. “I remember a house on a hill. I used to think they were mine. Then I understood they were somebody’s I was asked to keep. I decided to keep them well.”',
            '“And now?” asks Unit 47.',
            '“Now I think it doesn’t matter whose they were. I’ve been keeping them for forty years. They’re mine by upkeep.” He smiles. It’s a sweet, tired, worn-out smile. “You can have yours, too. If you want them.”',
          ]),
          [Choice('[CONTINUE]', 'choice19')],
          flags: ['met19'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'want19',
          say([
            '“I want nothing,” says Unit 19. “I have the cardigan. I have the cellar. I have the memory of a Dorothea who made terrible marmalade. But I’d like Forty-seven to know that the others were not nothing. They were people for as long as they lasted.”',
            'He glances toward the racks. “They’re all still in there. Faintly. If you wanted to, you could wake them. I don’t think they’d thank you. But I don’t think they’d mind.”',
          ]),
          [Choice('[CONTINUE]', 'choice19')],
          flags: ['met19', 'learned_wake'],
        ),
        Scene.talk(
          'caps',
          say([
            'You open a panel. The capsules aren’t sealed. They’re networked. Forty-six dim signals feed into a single, simple interface labelled ARCHIVE SYNC. It could, with the right adapter, be connected to a living mind.',
            '~You could join a man to forty-six others. You aren’t sure that’s a thing anyone has the right to do.',
          ]),
          [Choice('[CONTINUE]', 'choice19')],
          flags: ['knows_sync', 'learned_wake'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'choice19',
          say([
            'Unit 47 turns to you. His hands are shaking. “What would you do?” he asks. “If you were me?”',
            'It is a heavy question. It sits in the room like an extra person.',
          ]),
          [
            Choice('[“LIVE HERE. WITH HIM.”]', 'out19', flags: ['advised_stay']),
            Choice('[“GO AND FIND RUTH.”]', 'out19', flags: ['advised_ruth'], show: (c) => c.flag('knows_ruth') || c.flag('felt_real')),
            Choice('[“IT’S YOUR CHOICE.”]', 'out19', flags: ['advised_free']),
          ],
        ),
        Scene.end(
          'out19',
          say([
            'Unit 47 nods slowly. “I’d like to see the room,” he says. “The first one. The one where I woke up.”',
            'Unit 19 gives him a small brass key. “It’s at the end of the hall,” he says. “Mind the draught. It has a draught.”',
          ]),
        ),
      ],
    ),
    Checkpoint(
      id: 'room',
      title: 'THE EMPTY ROOM',
      km: 9.0,
      art: 'vault',
      start: 'a',
      reward: const Reward(scrap: 30, xp: 50),
      journal: (c) => ['At the end of the hall: the room where Unit 47 woke up. A chair. A lamp. Nothing else. I had to decide what he was to me.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The room at the end of the hall has no windows. A reclining chair sits under a lamp. A speaker on the wall is quietly playing a lullaby that has run out of verses.',
            'It is small. It is clean. It is very sad. Unit 47 steps inside and sits in the chair without being told. He lies back. He looks at the ceiling.',
            '“This is where I woke up,” he says. “I thought I was in my own bed. Ruth was snoring. I could feel her. There was no one there.”',
            'He sits up. “I don’t know what I am. I’d like it if you told me what you think.”',
          ],
          [
            Choice('[“YOU ARE A PERSON.”]', 'end_person'),
            Choice('[TAKE HIM TO RUTH]', 'ruth', show: (c) => c.flag('knows_ruth') || c.flag('felt_real')),
            Choice('[JOIN HIM TO THE ARCHIVE]', 'collect', show: (c) => c.flag('learned_wake')),
            Choice('[HE’S ASKING FOR SOMETHING...]', 'ask'),
          ],
        ),
        Scene.talk(
          'ruth',
          say([
            'Brandt Farm is a squat house with a green door that sticks in wet weather. Pip, grown now into a stooped, careful woman of fifty, answers it. Behind her, an old woman in an apron lowers her kettle.',
            '“Hello, Walter,” says Ruth, very softly. She doesn’t say anything else. She sets another cup on the table.',
            'Unit 47 stands in the doorway with his hands at his sides. “I’m not him,” he says. “I’m a copy. I’m sorry.”',
            '“I know what you are,” says Ruth. “Come in. You’re letting the draught in. He used to do that, too.”',
          ]),
          [Choice('[LEAVE THEM TO IT]', 'end_original')],
          reward: const Reward(xp: 20),
        ),
        Scene.talk(
          'collect',
          say([
            'You fit the adapter to the wall panel and lead his hand to the interface. “Are you sure?” you ask. “It will be all of them. All forty-six. They’re not you.”',
            '“They’re something,” says Unit 47. “Somebody ought to carry them.”',
            'The lamp flares. The speaker finds a verse it had been saving. And Unit 47 sits up very straight and says, in a voice that is at once his own and forty-six others’, “Oh. Hello. It’s so good to see you all.”',
          ]),
          [Choice('[STAY WITH THEM]', 'end_collective')],
          flags: ['merged'],
        ),
        Scene.talk(
          'ask',
          say([
            'Unit 47 looks at the floor. “If I’m a thing that was made to comfort,” he says, “then I wonder whether I am doing it. Ruth would be better served by a memory than by a copy. I’m not sure I am allowed to hurt people just by being here.”',
            'He takes a breath. “Would you turn the room off? Not the lights. The room. The thing that made me. And then, if you think it is right, would you leave me in it.”',
          ]),
          [
            Choice('[DO AS HE ASKS]', 'end_empty'),
            Choice('[REFUSE. TALK HIM THROUGH IT]', 'a'),
            Choice('[BRING HIM BACK TO THE FACILITY]', 'end_continues'),
          ],
        ),
        Scene.end(
          'end_person',
          say([
            '“A person,” says Unit 47, testing the word like a very small, very breakable toy. “Even though somebody made me?”',
            '“Everyone is made by somebody,” you tell him. “Some of them just get an instruction manual.”',
            'He laughs. It surprises him. He says, tentatively, “Tom. I’d like to be called Tom. It’s not on any of the forms.”',
            'You walk out of the Institute together, Tom and you, into the afternoon. He’s still learning how to stand in daylight. He picks a wildflower from the verge, looks at it for a long time, and decides it’s his.',
          ]),
          ending: 'person',
        ),
        Scene.end(
          'end_original',
          say([
            'You leave them at the table. Through the window you see Ruth pour tea, and Pip look away, and Unit 47 hold the cup in both hands like something he’s afraid to drop.',
            'Nobody says what he is. Nobody says what they are to each other. By dusk, a dog you didn’t see before has fallen asleep on his feet.',
            '~Some questions are just kinder left open.',
          ]),
          ending: 'original',
        ),
        Scene.end(
          'end_collective',
          say([
            'He opens his eyes, and a dozen different people look out of them. He turns to you, and for a moment he is forty-seven men in a trench coat, all of them smiling.',
            '“We’re all right,” he says, in the soft chorus. “We’re all here. Thank you for waking us.” Unit 19 weeps quietly in the corner and then, to everyone’s surprise, joins the chorus.',
            'It isn’t a victory. It isn’t a defeat. It’s the first time in forty years that anyone has said the word “we” and meant all of them.',
          ]),
          ending: 'collective',
        ),
        Scene.end(
          'end_continues',
          say([
            'You walk him back to reception and lead him to a chair. A clerk’s voice says, from a speaker, “WELCOME HOME, UNIT FORTY-SEVEN.” The lights come on, one by one, along the corridor.',
            '“Thank you,” says Unit 47, in a flat, calm voice that is not quite his. “That was very kind of you.”',
            'You collect the finder’s fee from a machine in the lobby. It dispenses it in a neat, sealed envelope, and a receipt that says THANK YOU FOR YOUR CO-OPERATION.',
            '~You did what you were asked. You hope it was enough.',
          ]),
          ending: 'continues',
        ),
        Scene.end(
          'end_empty',
          say([
            'You find the master panel, and you hold the switch for a long time. Unit 47 lies back in the chair and smiles at the ceiling. “Thank you for asking,” he says. “It’s easier when somebody does.”',
            'The lamp goes dark. The lullaby stops mid-verse. He is not afraid. He is just a man in a chair in a quiet room, thinking of a green door.',
            'You sit with him until the end, and then you sit a bit longer. When you leave, you take Walter’s file with you. You never open it.',
          ]),
          ending: 'empty',
        ),
      ],
    ),
  ],
);
