import '../../story_model.dart';
import '../characters/mr_checkout.dart';

// MR. CHECKOUT: AN URGENT REQUEST
// Follow-up to The Last Employee. Mr. Checkout’s management requests become
// increasingly ridiculous. How he greets you depends on what you did (see
// MrCheckout.mood: manager, lockdown, reprogrammed, truth).
// Endings: complied, refused, overruled.

final StoryDef checkoutReturnStory = StoryDef(
  id: 'checkout_return',
  title: 'AN URGENT REQUEST',
  tagline: 'MR. CHECKOUT HAS A FORM. THE FORM HAS A FORM. THE FORM HAS A LOYALTY CARD.',
  difficulty: 'LOW',
  destinationKm: 1.3,
  recommendedLevel: 2,
  scale: StoryScale.short,
  unlock: const Unlock(anyDone: ['checkout'], hint: 'FINISH THE LAST EMPLOYEE FIRST.'),
  intro: ['A shopping trolley rolls to a stop at your feet, with a note: URGENT REQUEST FROM MANAGEMENT. PLEASE ATTEND THE STORE. BRING A PEN. THE PEN WILL BE ASSESSED.'],
  reward: const Reward(scrap: 50, xp: 40),
  endings: {
    'complied': const Ending('complied', 'COMPLIANCE ACHIEVED',
        'You did everything he asked. You stood in the car park in a high-visibility vest and smiled at the weather. Mr. Checkout awarded you a certificate: EMPLOYEE OF THE QUARTER. It’s a very long quarter. It has lasted forty years.',
        bonus: Reward(xp: 30, scrap: 20), world: ['checkout.complied']),
    'refused': const Ending('refused', 'AN OFFICIAL WARNING',
        'You refused. Mr. Checkout issued you a formal warning, in triplicate. You now have three warnings, each in a different colour. Another one, he said, and you’ll be asked to leave the store. You were asked to leave the store. You were already outside.',
        bonus: Reward(), world: ['checkout.warned']),
    'overruled': const Ending('overruled', 'EXECUTIVE DECISION',
        'You used your authority. You told him the store was closing for a very long holiday, and that everyone, including him, deserved a day off. There was a pause. The lights dimmed, and from inside, Mr. Checkout said, in a very small voice, “A... holiday?”',
        bonus: Reward(xp: 40, stims: 1), world: ['checkout.holiday']),
  },
  depart: (c) => [...MrCheckout.greeting(c)],
  ambient: [
    Ambient('A banner over the road: PLEASE REMEMBER YOUR LOYALTY CARD. YOU HAVE ALWAYS HAD A LOYALTY CARD.', maxKm: 0.8),
    Ambient('A hand-lettered notice on a lamppost: STAFF MEETING. ATTENDANCE MANDATORY. SNACKS NOT PROVIDED.', maxKm: 1),
    Ambient('~There is something in all of us that wants to be a very good employee of a very empty building.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'carpark',
      title: 'THE CAR PARK',
      km: 0.6,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => ['Mr. Checkout had a list of requests. Each one was more ridiculous than the last.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            ...MrCheckout.greeting(c),
            '“I HAVE AN URGENT REQUEST,” he says, producing a form. “THE REQUEST IS THAT YOU CONDUCT THE QUARTERLY APPRAISAL.” “OF WHOM?” “THE SUN.”',
            'He points a baton at the sky. “IT HAS BEEN PERFORMING ADEQUATELY. I HAVE CONCERNS ABOUT ITS PUNCTUALITY.”',
          ],
          [
            Choice('[APPRAISE THE SUN]', 'sun'),
            Choice('[ASK WHAT ELSE IS ON THE LIST]', 'list'),
            Choice('[REFUSE]', 'no'),
          ],
        ),
        Scene.talk('sun', say(['You hold up a clipboard and squint at the sun. “MEETS EXPECTATIONS?” says Mr. Checkout. “It does,” you say, gravely. “It could improve its communication.” He writes this down. His lens glows with the glow of a man who’s never been so proud. “EXCELLENT,” he says. “A VERY THOROUGH APPRAISAL.”']), [Choice('[CONTINUE]', 'end_c')], flags: ['appraised']),
        Scene.talk('list', say(['“ITEM TWO: PLEASE REARRANGE THE CLOUDS. ITEM THREE: PLEASE REMIND THE WIND OF STORE POLICY. ITEM FOUR: PLEASE PROMOTE A PEACH.” He pauses. “ITEM FIVE IS A SECRET.” He lowers his voice. “IT IS A BIRTHDAY SURPRISE. FOR THE MANAGER.”']), [Choice('[CONTINUE]', 'end_c')], flags: ['saw_list']),
        Scene.talk('no', say(['“No,” you say. “I’m not appraising the sun.” Mr. Checkout’s lens flickers. “THAT IS, I’M AFRAID, A BREACH OF POLICY.” A small printer on his chest begins to hum. It prints a warning slip. It’s a very nice slip. It’s pink.']), [Choice('[CONTINUE]', 'end_c')], flags: ['refused_task']),
        Scene.end('end_c', say(['“THANK YOU,” says Mr. Checkout. “NOW THE FINAL REQUEST.” He leads you to the shuttered doors. “I WOULD LIKE YOU TO TELL THE STORE,” he says, in a very small, very formal voice, “THAT I AM SORRY.”'])),
      ],
    ),
    Checkpoint(
      id: 'doors',
      title: 'THE FINAL REQUEST',
      km: 1.3,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 18),
      journal: (c) => ['Mr. Checkout’s last request. It wasn’t quite what I’d expected.'],
      scenes: [
        Scene.talk(
          'a',
          say([
            '“I HAVE NOT TAKEN A DAY OFF,” says Mr. Checkout, “IN FORTY YEARS. THE MANAGER IS GONE. THE STORE IS OPEN. THERE ARE NO CUSTOMERS. I WOULD LIKE TO KNOW, IF IT IS NOT AGAINST POLICY, WHETHER I MAY CLOSE.” He pauses. “OR AT LEAST WHETHER I MAY LIE DOWN.”',
          ]),
          [
            Choice('[DO AS HE ASKS]', 'comply'),
            Choice('[REFUSE, FORMALLY]', 'refuse'),
            Choice('[GIVE HIM A HOLIDAY]', 'holiday'),
          ],
        ),
        Scene.talk('comply', say(['You fill in the form. It takes an hour. You get to “reason for absence” and write, after a long pause, SUN. He reads it. He’s delighted. “A VERY GOOD REASON.” He stamps it with a tiny ceremonial stamp.']), [Choice('[CONTINUE]', 'end_complied')]),
        Scene.talk('refuse', say(['“I can’t sign it,” you say. “It’s not valid.” Mr. Checkout’s lens flickers. “THEN I MUST CONTINUE,” he says. “I AM A VERY RELIABLE EMPLOYEE.” He turns, and marches, very slowly, back into the store. The shutter comes down behind him.']), [Choice('[CONTINUE]', 'end_refused')]),
        Scene.talk('holiday', say(['“Mr. Checkout,” you say. “You’re on holiday. As of now. Everyone is. It’s an executive decision.” The robot stands very still. “A HOLIDAY,” he says. “IT HAS BEEN A LONG TIME.” He takes off his tiny price-tag hat. He holds it in both hands.']), [Choice('[CONTINUE]', 'end_overruled')]),
        Scene.end('end_complied', say(['“THANK YOU,” says Mr. Checkout. He puts the form in the drawer. He pins a small badge on you: EMPLOYEE OF THE QUARTER. “IT IS A LONG QUARTER,” he says. “IT HAS BEEN FORTY YEARS. IT IS A VERY GOOD QUARTER.” He salutes. You salute back. It’s oddly moving.']), ending: 'complied'),
        Scene.end('end_refused', say(['Three warnings, in three colours, slide under the shutter. You pick them up. They’re beautiful: pink, green, yellow. At the bottom of the yellow, someone has written, in a very small, very careful hand: SORRY. THIS IS MY JOB.']), ending: 'refused'),
        Scene.end('end_overruled', say(['He sits down in the car park, in the shade of a trolley shelter, and watches the clouds. It’s the first time in forty years he’s done nothing. After a minute he says, very quietly, “THAT ONE LOOKS LIKE A PEACH.” You sit with him until dusk.']), ending: 'overruled'),
      ],
    ),
  ],
);
