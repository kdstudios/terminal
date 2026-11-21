import '../../story_model.dart';
import '../characters/doctor_bones.dart';

// THE WORLD’S WORST DOCTOR (Doctor Bones)
// Confident, enthusiastic, frequently wrong. His patients are not always
// reassured. Endings: patient, complained, hired.

List<Choice> _clinicChoices() => [
      Choice('[ASK ABOUT HIS QUALIFICATIONS]', 'c_quals', show: (c) => !c.flag('seen.quals')),
      Choice('[LOOK AT HIS OTHER PATIENTS]', 'c_patients', show: (c) => !c.flag('seen.patients')),
      Choice('[DESCRIBE A SYMPTOM]', 'c_sym', show: (c) => !c.flag('seen.sym')),
      Choice('[DECIDE ABOUT TREATMENT]', 'c_go'),
    ];

final StoryDef doctorStory = StoryDef(
  id: 'doctor',
  title: 'THE WORLD’S WORST DOCTOR',
  tagline: 'DOCTOR BONES IS SURE YOU HAVE A RASH. YOU HAVE NOT MENTIONED A RASH.',
  difficulty: 'LOW',
  destinationKm: 1.8,
  recommendedLevel: 1,
  scale: StoryScale.short,
  intro: [
    'A tent on the road, hung with small bones, a skull with a stethoscope and a sign: DOCTOR BONES. WALK-INS WELCOME. WALK-OUTS ALSO WELCOME. FIRST OPINION FREE.',
  ],
  reward: const Reward(scrap: 40, xp: 40, stims: 1),
  endings: {
    'patient': const Ending('patient', 'A SATISFIED PATIENT',
        'You let Doctor Bones treat you. The results were mixed. You smell of mint and mild alarm. A rash you didn’t have has cleared up, and a minor ache has become a major one. The doctor is thrilled.',
        bonus: Reward(xp: 10, stims: 1), world: ['bones.patient']),
    'complained': const Ending('complained', 'A FORMAL COMPLAINT',
        'You lodged a complaint. Doctor Bones took it graciously and filed it in a bucket. The patients, watching, began, one by one, to lodge their own. By evening, the bucket was full. By morning, so was the road.',
        bonus: Reward(xp: 30), world: ['bones.complained']),
    'hired': const Ending('hired', 'THE ASSISTANT',
        'You became his assistant. He gave you a white coat, a name tag and a very large saw. You are, according to the certificate, now a Doctor. It was drawn in crayon. It is nonetheless legally binding.',
        bonus: Reward(scrap: 40, xp: 20), world: ['bones.hired']),
  },
  depart: (c) => ['You walk toward a distant voice announcing, with huge confidence, that something is “almost certainly nothing.”'],
  ambient: [
    Ambient('A man sits at the roadside with his arm in a sling made of a scarf. The scarf is on fire. He doesn’t seem to mind.', maxKm: 1),
    Ambient('A banner: ASK ABOUT OUR LOYALTY SCHEME. (EVERY TENTH OPERATION IS FREE.)', maxKm: 1.3),
    Ambient('You hear a cheerful “There, that’ll do it!” followed by a terrible silence, followed by, “...or not.”', minKm: 0.5),
    Ambient('~In the wasteland, there’s a thin line between a doctor and a hobby.', minKm: 1),
  ],
  checkpoints: [
    Checkpoint(
      id: 'clinic',
      title: 'THE CLINIC TENT',
      km: 0.9,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => [
        'Doctor Bones’s tent: a waiting room of three worried patients and a goat.',
        if (c.flag('seen.quals')) 'His certificate is a drawing. He drew it himself. It’s a good drawing.',
        if (c.flag('seen.patients')) 'One patient has been “cured” of having a head. He’s very alarmed.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...DoctorBones.greeting(c),
            'Inside the tent, a camp bed, a bench of unlabelled jars, and a sign: THE DOCTOR WILL SEE YOU NOW. THE DOCTOR WILL SEE YOU REGARDLESS.',
          ],
          _clinicChoices(),
        ),
        Scene.talk(
          'c_quals',
          say([
            'He points at the wall. A large framed certificate hangs there, in brightly coloured crayon: THIS CERTIFIES THAT DOCTOR BONES IS A DOCTOR. SIGNED, DOCTOR BONES. A small, pleased tick sits in the corner.',
            '“Fully accredited,” says Doctor Bones. “By a very reputable institution. I went to it. Very prestigious. They gave me a mug.”',
          ]),
          _clinicChoices(),
          flags: ['seen.quals'],
        ),
        Scene.talk(
          'c_patients',
          say([
            'Three patients sit on the bench. One has a bandage round his head, with a tiny drawn-on face. One has his legs in two different sizes of boot. The third, an old woman, is holding a very large jar of leeches and talking to them quietly, as if they’re her grandchildren.',
            '“How’s everyone?” you ask. “Better,” says the first. “Mostly,” says the second. “Alive,” says the third, and, after a moment’s reflection: “For the time being.”',
          ]),
          _clinicChoices(),
          flags: ['seen.patients'],
          reward: const Reward(xp: 6),
        ),
        Scene.talk(
          'c_sym',
          say([
            '“I’ve a headache,” you say. “A mild one.” Doctor Bones gasps, grabs your wrist, stares deeply into your left eye with a torch, and says, with solemn horror, “Four weeks.”',
            '“Four weeks until what?”',
            '“Until the headache!” says the doctor, with enormous relief. “Don’t worry. It’s a very good prognosis. It can’t come sooner than that. I’ll prescribe you a small bottle of something.”',
          ]),
          _clinicChoices(),
          flags: ['seen.sym'],
        ),
        Scene.end('c_go', say(['Doctor Bones rubs his hands. “Right!” he says. “Shall we begin? I have a number of options. And a very big saw.”'])),
      ],
    ),
    Checkpoint(
      id: 'treat',
      title: 'THE TREATMENT',
      km: 1.8,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['The question of treatment. I had choices. All of them were unwise.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            'Doctor Bones snaps on a pair of rubber gloves that are not designed for a human hand. He lays out an instrument tray: a spoon, a hammer, a small spirit lamp and a bottle marked SOMETHING FOR THE NERVES. He beams at you.',
            '“Now,” he says. “Three options. One: let me treat you. Two: tell me what you think of my methods. Three: help me. I’m extremely short of staff. All my last assistants have, er, recovered.”',
          ]),
          [
            Choice('[LET HIM TREAT YOU]', 'treat'),
            Choice('[COMPLAIN]', 'complain'),
            Choice('[BECOME HIS ASSISTANT]', 'help'),
          ],
        ),
        Scene.talk(
          'treat',
          say([
            'He taps your knee with a hammer. Your leg shoots out. He taps your other knee. Your other leg shoots out. “Marvellous,” he says. “Perfect reflexes.” He gives you a small, sticky pill. “Take this. It’ll make everything better, or at least a bit blue.”',
            'You take the pill. You feel, in fairness, a little blue. And, in a distant, hopeful sort of way, healthier.',
          ]),
          [Choice('[LEAVE]', 'end_patient')],
          reward: const Reward(hp: 14),
        ),
        Scene.talk(
          'complain',
          say([
            '“I don’t think,” you say, carefully, “that you’re qualified.” There’s an extended silence. Doctor Bones’s smile does not so much fall as gently rearrange itself.',
            '“Ah,” he says. “A complaint. Good. Very good. I shall put it with the others.” He opens a bucket. It’s very full of complaints. “I’ve been meaning to read them,” he says. “For years.”',
          ]),
          [Choice('[CONTINUE]', 'end_complained')],
        ),
        Scene.talk(
          'help',
          say([
            '“I’ll help,” you say. Doctor Bones’s whole face lights up. He seizes both of your hands. “Wonderful! Magnificent! You can do the first twelve operations. I’ll supervise from a safe distance.”',
            'He hands you a white coat, a clipboard and the saw. You hold the saw. It’s heavier than you expected. It’s already got a name on it. The name is Steve.',
          ]),
          [Choice('[PUT ON THE COAT]', 'end_hired')],
        ),
        Scene.end('end_patient', say(['You walk out of the tent with a pill in your hand, a pain in your knee and a faint, faintly alarming glow. “Come back in a fortnight,” calls the doctor. “Or sooner! Or never! It’s all the same to the body!”']), ending: 'patient'),
        Scene.end('end_complained', say(['The patients, who have been listening, shuffle in from the tent flap, one by one. The first says, “Actually.” The second says, “Me too.” The old woman, with the leeches, says, “I think I’d like to make a statement.” The bucket fills. The road, by dusk, is full of complaints.']), ending: 'complained'),
        Scene.end('end_hired', say(['You spend an afternoon as Doctor Bones’s assistant. You perform no operations. You hand out a great many bandages. You discover that a surprising number of people just want somebody to say, “Yes, that does look unpleasant.” By sunset, you are, against all your better judgement, rather good at it.']), ending: 'hired'),
      ],
    ),
  ],
);
