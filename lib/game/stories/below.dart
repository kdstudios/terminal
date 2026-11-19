import '../combat_session.dart';
import '../story_model.dart';

// SOMETHING BELOW
// The tremors are a rescue machine, still digging on a schedule set forty
// years ago. The knocking is three hundred and twelve people who have been
// very patient. Nobody is sure whether the quarantine order still applies.

List<Choice> _shiftChoices() => [
      Choice('[READ THE FOREMAN’S TERMINAL]', 'hackm', show: (c) => !c.flag('seen.memos')),
      Choice('[PICK THE FOREMAN’S LOCKER]', 'lockl', show: (c) => !c.flag('seen.locker')),
      Choice('[READ THE SAFETY LOGBOOK]', 'logbook', show: (c) => !c.flag('seen.logbook')),
      Choice('[MOVE ON]', 'leave'),
    ];

List<Choice> _tessChoices() => [
      Choice('[OFFER HER A STIMPACK] (-1)', 'stim',
          needStim: 1, show: (c) => !c.flag('has_cone') && !c.flag('mocked')),
      Choice('[BUY THE GEOPHONE] (-30 SCRAP)', 'buy',
          needScrap: 30, show: (c) => !c.flag('has_cone') && !c.flag('mocked')),
      Choice('[CRITICISE THE SEISMOGRAPH]', 'mock',
          show: (c) => !c.flag('has_cone') && !c.flag('mocked')),
      Choice('[LEAVE]', 'leave'),
    ];

List<Choice> _tunnelChoices() => [
      Choice('[GO THROUGH THE TUNNEL]', 'go'),
      Choice('[LISTEN FIRST, WITH THE GEOPHONE]', 'hear', show: (c) => c.flag('has_cone')),
      Choice('[CLIMB OVER THE RIDGE]', 'ridge'),
    ];

List<Choice> _listenersChoices() => [
      Choice('[STAND AMONG THEM AND LISTEN]', 'listen', show: (c) => !c.flag('seen.listen')),
      Choice('[TAP THE PATTERN ON THE WALL]', 'tap', show: (c) => !c.flag('seen.tap')),
      Choice('[SALVAGE ONE OF THEM]', 'salvage', show: (c) => !c.flag('seen.salvage')),
      Choice('[LEAVE THEM BE]', 'leave'),
    ];

List<Choice> _gretaChoices({required bool access}) => [
      if (!access)
        Choice('[LISTEN AT THE SHAFT]', 'hear',
            show: (c) => c.flag('has_cone') && !c.flag('seen.hear')),
      if (access) ...[
        Choice('[ASK WHO IS DOWN THERE]', 'asked', show: (c) => !c.flag('seen.asked')),
        Choice('[OPEN THE WAY: FULL BREAKTHROUGH]', 'end_opened'),
        Choice('[HALT THE BORE, TELL THEM TO WAIT]', 'end_wait'),
        Choice('[CUT THE POWER]', 'end_stopped'),
      ] else ...[
        Choice('[ACCESS THE FOREMAN]', 'hackf'),
        Choice('[PULL THE EMERGENCY STOP]', 'estop'),
        Choice('[WALK AWAY AND LET GRETA FINISH]', 'end_dig'),
      ],
    ];

final StoryDef belowStory = StoryDef(
  id: 'below',
  title: 'SOMETHING BELOW',
  tagline: 'EVERY ELEVEN MINUTES THE GROUND CLEARS ITS THROAT. NOBODY KNOWS WHY.',
  difficulty: 'SEVERE',
  destinationKm: 12.5,
  recommendedLevel: 5,
  unlock: const Unlock(
    minLevel: 4,
    anyDone: ['caravan', 'transmission'],
    hint: 'REACH LEVEL 4 AND FINISH ANOTHER STORY EXPEDITION.',
  ),
  intro: [
    'It starts as a rumour on the circuit, the way these things do. A trader at Cinder Crossing tells a joke about a man whose coffee “did a little dance.” Then another trader’s cup does the same. Then a whole market’s worth of cups.',
    'The tremors come every eleven minutes, near enough. Dust sifts from the shutters of your safehouse. Your own tin mug shuffles an inch to the left, stops, and shuffles back, as if it’s thought of something it forgot.',
    'Everyone agrees the shaking comes from the old Hadrian Works, the industrial district out at the edge of the Iron Graveyard. Nobody agrees on what’s causing it. “Settling,” says one man. “Geology,” says another. A third, who is missing most of a sleeve, says nothing and drinks someone else’s drink.',
    'You decide to go and look. Partly for the bounty. Partly because “every eleven minutes” is not a number that nature chooses.',
  ],
  reward: const Reward(scrap: 300, xp: 220, stims: 2, picks: 2, parts: 5),
  endings: {
    'dig': const Ending('dig', 'LET GRETA FINISH',
        'You left the machine to its schedule. Somewhere behind you, something broke through. You never learned what came out.',
        bonus: Reward(scrap: 40), world: ['below.opened']),
    'stopped': const Ending('stopped', 'THE EMERGENCY STOP',
        'You stopped the bore. The knocking went on for a while. Then you stopped hearing it.',
        bonus: Reward(scrap: 60), world: ['below.sealed']),
    'opened': const Ending('opened', 'THE LONG WAY UP',
        'You opened the way, with the Foreman’s protocol. Three hundred and twelve people came up into the light. Statistically, you did something wonderful.',
        bonus: Reward(xp: 80, stims: 1), world: ['below.opened']),
    'wait': const Ending('wait', 'A PROMISE',
        'You halted the bore and promised to return with a doctor. They said they could be patient a little longer.',
        bonus: Reward(xp: 60, parts: 2), world: ['below.promise']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? [
          'You fill your canteen, check your pipe and stand in the doorway until the next tremor comes, mostly to see whether it’s on time. It is.',
          '~Eleven minutes, on the dot. It’s the punctuality that gets me.',
        ]
      : [
          'The mug on the shelf shuffles an inch to the left as you leave, as if seeing you off. The ground answers on schedule, and you resume your walk toward the Works.',
        ],
  ambient: [
    Ambient('Your boots feel the tremor half a second before the ground confirms it. Eleven minutes, near enough.', maxKm: 12),
    Ambient('A thread of dust lifts off the road, drifts, settles. Everything, for a moment, was moving slightly to the left.', maxKm: 6),
    Ambient('Your canteen sloshes in a rhythm that has nothing to do with your walking.', maxKm: 8),
    Ambient('~Eleven minutes. Somebody, somewhere, is keeping a schedule, and it isn’t yours.', minKm: 2.5, when: (c) => c.flag('felt_pulse')),
    Ambient('A sign reads DAYS WITHOUT INCIDENT, with a number chalked beside it that you refuse to count.', minKm: 3.5, maxKm: 7),
    Ambient('You find yourself looking at your feet every eleven minutes. You feel foolish. You do it anyway.', minKm: 4.4, when: (c) => c.done('shift')),
    Ambient('Three, two, three. You catch yourself tapping it on your pack strap. You stop. Then you start again.', minKm: 4.4, when: (c) => c.flag('knocking')),
    Ambient('The geophone sits in your pack like a small, patient ear. Every so often you swear it twitches.', minKm: 6.5, when: (c) => c.flag('has_cone')),
    Ambient('~Tess waved you off without looking back. That’s as close as she gets to affection.', minKm: 6.5, when: (c) => c.flag('helped_tess')),
    Ambient('The handrails in the tram tunnel were polished by thousands of hands, in both directions. You try not to dwell on the “both”.', minKm: 8.9, maxKm: 11),
    Ambient('Machines, in rows, all facing one way. You’ve stopped wondering which way, and started wondering why.', minKm: 10.8),
    Ambient('~Something under the ground knows how to count. You’d rather it weren’t so good at it.', minKm: 10.8, when: (c) => c.flag('heard_reply')),
    Ambient('You’ve learned to wait out the pulses in the open, away from walls. It’s a skill, of sorts.', minKm: 4, when: (c) => c.skill('SURVIVAL') >= 2),
    Ambient('You wonder, briefly, whether the pipes have a return channel.', minKm: 4, when: (c) => c.ending('transmission') != null),
    Ambient('~A calm, drugged village would be a great comfort right now. You don’t say so out loud.', minKm: 9, when: (c) => c.ending('caravan') == 'left'),
    Ambient('%The ground ticks and settles under you, like a house at night.', minKm: 11),
  ],
  checkpoints: [
    // ---------------------------------------------------------------- 2.4
    Checkpoint.auto(
      id: 'puddle',
      title: 'THE PUDDLE',
      km: 2.4,
      text: (c) => [
        'Just off the road, in a pothole, rainwater sits in a perfectly still disc. You nearly walk past.',
        'Then it trembles. A ring spreads from the rim, as if something small and polite had dropped a pebble from above. There is no pebble. There is no wind. The ring doesn’t start at the centre. It starts at the edge nearest the factories, and runs across the water as if the puddle were being knocked on.',
        'You wait. It is boring in the way only prophecies are. Eleven minutes by your best guess, and the ring comes again. Same side. Same size. Same politeness.',
        '~A bureaucratically punctual earthquake. Wonderful.|',
        'You stand up. Dust has settled on your shoulders, in the shape of nothing. Out ahead, past a long line of skeletal cranes, the Hadrian Works waits with its chimneys like a fist of dead fingers.',
      ],
      flags: ['felt_pulse'],
      journal: say([
        'Tremors, every eleven minutes, always from the direction of the Hadrian Works. They are not natural. They are scheduled.'
      ]),
      reward: const Reward(xp: 12),
    ),
    // ---------------------------------------------------------------- 4.3
    Checkpoint(
      id: 'shift',
      title: 'THE SHIFT BOARD',
      km: 4.3,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 25),
      journal: (c) => [
        'The foundry gatehouse. A shift board showing the NIGHT SHIFT as “ALL PRESENT” long after the evacuation notice.',
        if (c.flag('seen.memos')) 'The memos escalate: “stop calling it the knocking,” then “do not answer the knocking,” then “who answered the knocking.”',
        if (c.flag('foreman_stayed')) 'The foreman’s diary: the night shift voted to stay. Nobody left, and that felt like a vote.',
        if (c.flag('knocking')) 'The safety log records fourteen reports of knocking, always in a pattern: three, two, three.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The Hadrian Works’ foundry gatehouse is the first building you reach, a brick box with a bell on the roof and the air of a place that closed in a hurry.',
            'On the wall, a foreman’s board: a grid of numbered hooks, forty-one of them marked NIGHT SHIFT, each with a green tag turned outward. ALL PRESENT, says a chalked line across the top.',
            'The day-shift hooks are all turned red. EVACUATED, says the chalk. The date under it is a day earlier than the date under the first. The night shift was written in after the evacuation.',
            '~Forty-one people stayed behind. On purpose. Nobody stays on purpose.',
          ]),
          _shiftChoices(),
        ),
        Scene.hack(
          'hackm',
          say(['A battered foreman’s terminal hums on the desk, with a sticky note on the bezel: DO NOT USE FOR PERSONAL EMAIL. IF YOU HAVE READ THIS, YOU HAVE.']),
          win: 'memos',
          fail: 'memos_no',
        ),
        Scene.talk(
          'memos',
          say([
            '#MEMO 114: PLEASE STOP REFERRING TO THE NOISE AS “THE KNOCKING.” IT IS A SEISMIC ARTEFACT.',
            '#MEMO 121: THE KNOCKING IS NOW IN A PATTERN. THIS IS A COINCIDENCE. PLEASE STOP LOGGING IT AS “THREE, TWO, THREE.”',
            '#MEMO 130: OVERTIME IS NOT AN APPROPRIATE RESPONSE TO THE KNOCKING. DO NOT ANSWER THE KNOCKING.',
            '#MEMO 131: WHO ANSWERED THE KNOCKING.',
            'The memos stop. After 131, nothing, except one more entry, much later, by someone else, in a hand that’s learned to be patient.',
            '#SHIFT VOTE: UNANIMOUS. WE STAY. — THE NIGHT SHIFT',
            '~Management said don’t answer. Somebody answered anyway. Forty-one people agreed with them.',
          ]),
          _shiftChoices(),
          flags: ['seen.memos', 'knocking'],
          reward: const Reward(xp: 14),
        ),
        Scene.talk(
          'memos_no',
          say([
            'The terminal lets you read the first line (“#MEMO 114: PLEASE STOP REFERRING TO THE NOISE AS ‘THE KNOCKING.’”) and then asks for a password in a tone that suggests you’ve been rude.',
            '~Knocking. Somebody has been knocking. You’ll have to find out on whose door.',
          ]),
          _shiftChoices(),
          flags: ['seen.memos'],
        ),
        Scene.lock(
          'lockl',
          say(['A grey steel locker stands behind the desk, with FOREMAN — PRIVATE stencilled on the door and a padlock that has not been opened in a long time.']),
          win: 'diary',
          fail: 'diary_no',
        ),
        Scene.talk(
          'diary',
          say([
            'A thermos, a pair of spectacles with one arm missing, and a notebook. The last pages are a diary.',
            '#THE SHIFT VOTED TO STAY. I’M NOT SURE HOW YOU VOTE IN A MINE. WE STOOD IN A CIRCLE AND ANYONE WHO WANTED TO LEAVE WAS INVITED TO, AND NOBODY DID, AND THAT FELT LIKE A VOTE.',
            '#I TOLD THEM IT WAS A STUPID IDEA. THEY SAID, “WE KNOW, DENNIS.” THEN THEY WENT BACK TO WORK.',
            '#GRETA IS A GOOD MACHINE. SHE’LL GET THERE. SHE’S NEVER MISSED A DEADLINE.',
            'At the back of the locker, behind the thermos, a few coins of scrap, wrapped in a tidy handkerchief with the initials D.K.',
          ]),
          _shiftChoices(),
          flags: ['seen.locker', 'foreman_stayed'],
          reward: const Reward(scrap: 30, xp: 10),
        ),
        Scene.talk(
          'diary_no',
          say([
            'The padlock holds. You sigh at it and it does not sigh back. You can hear something inside rattle quietly, like a secret.',
          ]),
          _shiftChoices(),
          flags: ['seen.locker'],
        ),
        Scene.talk(
          'logbook',
          say([
            'The safety logbook is a ledger of minor catastrophes: a splinter, a burn, a blown fuse, a worker found asleep in a cement mixer.',
            'Then, line after line, in a column down the right:',
            '#NOISE REPORTED FROM SUBLEVEL. KNOCKING. 3-2-3. (14TH REPORT.)',
            '#NOISE REPORTED FROM SUBLEVEL. KNOCKING. 3-2-3. (15TH REPORT.) IT SOUNDS LIKE IT WANTS ME TO ANSWER.',
            '#16TH REPORT: I ANSWERED. I’M SORRY. I KNOW WE’RE NOT MEANT TO.',
            '#17TH REPORT: IT ANSWERED BACK.',
          ]),
          _shiftChoices(),
          flags: ['seen.logbook', 'knocking'],
          reward: const Reward(xp: 12),
        ),
        Scene.end(
          'leave',
          say([
            'You pull the door closed behind you, softly, the way you would on a sleeping child.',
            '~Forty-one chalk marks. Forty-one people who chose to stay. You hope it was worth it, for them.',
          ]),
        ),
      ],
    ),
    // ---------------------------------------------------------------- 6.4
    Checkpoint(
      id: 'tess',
      title: 'THE SEISMOGRAPH',
      km: 6.4,
      art: 'drifter',
      start: 'a',
      reward: const Reward(xp: 25, scrap: 10),
      journal: (c) => [
        'Tess lives in a shipping container with a homemade seismograph. The pulses are a dig: one bore advance every eleven minutes, and accelerating.',
        'Three days ago a second sound appeared beneath them: a pattern. Three, two, three.',
        if (c.flag('has_cone')) 'She gave you (or sold you) her geophone.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'A shipping container squats on a slab of concrete, topped with a satellite dish, a chimney made from a shotgun barrel, and a long, drooping aerial. On the door, a stitched sampler: GO AWAY. Beneath it, in different thread: (WELCOME).',
            'Through the open door, a trestle table holds an enormous machine: a coil of wire, a heavy brass weight, and a pen scratching a long, shaky line across a roll of till receipts.',
            'A woman in a lab coat made from a tablecloth does not turn around. “If you’re here about the shaking, you’re about the third person this month. The other two went on ahead. I wouldn’t wait for them.”',
            '“Tess,” she adds, finally. “Don’t touch anything.”',
            '“It’s not an earthquake,” Tess says. “Earthquakes are messy. This is a dig. Every eleven minutes, a bore advances one stroke, and the shock goes through the rock like a hammer on a bell.”',
            '“It’s been doing it for decades. I have records. It stopped for three weeks last spring. Then it started again, faster, as though somebody’d wound it up.”',
            'She pulls a strip of paper off the roll and holds it up to the lamp. “And since three days ago there’s a second signal underneath. Fainter. Not a pulse. A pattern.” She taps it with a pencil. “Three. Two. Three. Pause. Three. Two. Three.”',
            '“It isn’t the drill. The drill doesn’t knock.”',
            '~Knocking. The same word on a memo, and now out of the mouth of a woman in a tablecloth.',
          ]),
          _tessChoices(),
          flags: ['seen.ask', 'knocking'],
        ),
        Scene.talk(
          'stim',
          say([
            'You nod at the rag around her left forearm. It’s the wrong colour at the edges, and she’s been favouring it. “That’s infected,” you say.',
            '“It’s fine,” says Tess.',
            'You put a stimpack on the table. She looks at it for a long, long time.',
            '“...You’re an awful person to argue with,” she says finally, and rolls up her sleeve. It’s worse than you thought. She doesn’t flinch.',
            'When she’s done, she goes to a shelf and brings back something wrapped in a clean cloth: a brass cone with a leather cup and an earpiece on a coiled wire. “Geophone,” she says. “Press it to the ground. Or a wall. It’ll let you hear what I hear. Don’t drop it. Don’t thank me, either.”',
            '~She’s given you a way to listen to the ground. You’re not sure you want to know what it says.',
          ]),
          _tessChoices(),
          flags: ['has_cone', 'helped_tess', 'seen.ask'],
          reward: const Reward(xp: 25),
        ),
        Scene.talk(
          'buy',
          say([
            '“Thirty,” you say, nodding at the brass cone on the shelf.',
            '“Fifty,” says Tess.',
            '“Thirty.”',
            '“...Thirty,” she says, in the tone of someone who has been robbed by a stranger on a good day. She wraps it in a clean cloth. “Press it to the ground. Or a wall. It’ll let you hear what I hear. Don’t drop it.”',
            '~Thirty scrap for a way to hear the ground think. Seems cheap, in hindsight.',
          ]),
          _tessChoices(),
          flags: ['has_cone', 'seen.ask'],
          reward: const Reward(xp: 8),
        ),
        Scene.end(
          'mock',
          say([
            '“A pen on a spring?” you say. “That’s your seismograph? That’s a toy.”',
            'Tess turns round at last. She’s got a face like a closed door. She looks at you for a very long time, then steps to the doorway, and gently, unhurriedly, closes the container’s door in your face.',
            'From inside, a voice: “Seventy-one years of data, thank you very much. Go and be clever at someone else.”',
            '~Tact: you’ve found the one thing you’re worse at than lockpicking.',
          ]),
          flags: ['mocked'],
        ),
        Scene.end(
          'leave',
          (c) => [
            'You step out into the light. Behind you, the pen scratches on, unhurried.',
            if (c.flag('has_cone'))
              'The geophone sits against your hip, a small cold weight. Somewhere ahead, the ground is listening to itself.'
            else
              '“The pattern,” Tess says, as an afterthought, from the doorway. “If you hear it, don’t answer.” She shuts the door.',
          ],
        ),
      ],
    ),
    // ---------------------------------------------------------------- 8.8
    Checkpoint(
      id: 'tunnel',
      title: 'THE TRAM TUNNEL',
      km: 8.8,
      art: 'tunnel',
      start: 'a',
      reward: const Reward(scrap: 25, xp: 30),
      journal: (c) => [
        'The old ore tram tunnel, its handrails polished by thousands of hands. Something nests in it.',
        if (c.flag('cone_used')) 'You listened first and slipped past.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The only way through the ridge is an old ore-tram tunnel, a square black mouth in the rock with rails running into it like tongues.',
            'Both walls are lined with handrails, and every one of them has been polished to a shine. Not by weather. By hands. Thousands of palms, pressing the same spots, day after day, in both directions.',
            'The air inside breathes out, cold and slow, in time with the tremors.',
            'Something has made its nest at the far end. You can smell it from here.',
          ]),
          _tunnelChoices(),
        ),
        Scene.fight(
          'go',
          say(['You step into the dark with your weapon ready and your heart not. A long way ahead, a shape uncoils from the rails.']),
          EnemyType.lurker,
          win: 'through',
          fail: 'retreat',
        ),
        Scene.talk(
          'retreat',
          say(['You back out into the light, breathing hard. The tunnel breathes in, then out, as though it hadn’t noticed.']),
          _tunnelChoices(),
        ),
        Scene.end(
          'through',
          say([
            'The lurker lies across the rails. You find its nest in a service alcove: a heap of rags, bones and about forty hard hats, each stencilled with a name.',
            'One reads DELACROIX, N. — NIGHT SHIFT. Inside it, wedged tight, a hand-drawn card: a stick figure holding a bigger stick figure’s hand. SEE YOU AT BREAKFAST, DAD.',
            'You put the card back. You put the hat back. You don’t say anything.',
          ]),
        ),
        Scene.talk(
          'hear',
          say([
            'You kneel and press the cone to the rail. A heartbeat, huge and sleepy, rumbles through the brass. The lurker is at the far end, dozing, and the whole tunnel lies on its breath like a blanket.',
            'It breathes in. It breathes out. In the gap between, you slide a foot forward. It breathes in. You slide another.',
          ]),
          [Choice('[SLIP THROUGH]', 'slip')],
          flags: ['cone_used'],
        ),
        Scene.end(
          'slip',
          say([
            'It takes the better part of an hour. Not once does the lurker stir. When you reach daylight at the far end you realise you haven’t breathed properly for most of it.',
            '~You listened, and the tunnel let you pass. You’re starting to see why Tess never leaves her container.',
          ]),
          reward: const Reward(xp: 15),
        ),
        Scene.end(
          'ridge',
          say([
            'You climb. It’s steep, and loose, and the rock has a bad opinion of you. About halfway up, a slab gives way and you take a long, cold, painful slide.',
            'You reach the top with your hands raw and your pride in pieces. The tunnel, below you, breathes calmly in and out, as though nothing had happened.',
          ]),
          reward: const Reward(hp: -7, xp: 12),
        ),
      ],
    ),
    // --------------------------------------------------------------- 10.7
    Checkpoint(
      id: 'listeners',
      title: 'THE NIGHT SHIFT',
      km: 10.7,
      art: 'cave',
      start: 'a',
      reward: const Reward(xp: 35, scrap: 20),
      journal: (c) => [
        'Eighty mining robots stand in rows with their heads pressed to a wall, listening.',
        if (c.flag('heard_reply')) 'You listened too. Something below knocked back.',
        if (c.flag('tapped')) 'You tapped the pattern. It was copied back, a beat late, with one extra beat added.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The ground drops into a wide, flat quarry, and the quarry is full of robots.',
            'Mining robots, eighty or more, squat and hulking, with orange paint flaking from their shoulders. They stand in perfect rows, facing the same wall of rock. Every one of them has its head pressed against the stone, one hand flat beside it, like a congregation at prayer.',
            'They don’t guard anything. They don’t patrol. Their lamps are lit, a dull amber, as if in reverence. They are not tracking you. They are listening.',
            '~Eighty machines, forty years, one wall. Whatever they hear, they’ve never gotten tired of it.',
          ]),
          _listenersChoices(),
        ),
        Scene.talk(
          'listen',
          (c) => [
            'You walk down between the rows and find a gap, and stand in it, as one might in a pew. You put your ear to the rock.',
            if (c.flag('has_cone'))
              'You press the geophone to the stone instead. The sound is enormous and very clear. It’s not the drill. It’s knocking. Three, two, three. A pause. Three, two, three.'
            else
              'It’s faint, a small, dry, steady tapping, like someone far away with a spoon.',
            'Then, a beat after each knock, a second, quieter tap comes through the rock and answers.',
            if (c.flag('has_cone'))
              'You hear it plainly now, and it’s not Morse. It’s a rhythm. A clapping game: the kind children play with their hands in a circle, the kind someone taught you once, long ago. Somebody down there is teaching it to someone younger.'
            else
              'It’s not the machines. It’s the floor, tapping back.',
            '~Something is alive down there. Something is bored, and lonely, and playing a game.',
          ],
          _listenersChoices(),
          flags: ['seen.listen', 'heard_reply'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'tap',
          say([
            'You rap your knuckles against the rock. Three, two, three. It feels like knocking on the door of a very large house.',
            'Silence. A long, awful, ten-second silence. Eighty robots do not move.',
            'Then, from the stone, a faint answering tap. It copies your rhythm exactly, a beat late. Three, two, three.',
            'Then, after a pause, one extra tap, tacked on at the end, shy and proud at once. Like a child who has just learned to count.',
            '~It’s not copying you. It’s adding to the game.',
          ]),
          _listenersChoices(),
          flags: ['seen.tap', 'tapped'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'salvage',
          say([
            'You pick the nearest robot, a chunky orange thing with a number stencilled on its chest, and start working at its power cell with a pry bar.',
            'Every lamp in the quarry swivels toward you. Eighty heads turn in perfect unison, with a sound like a field of rusty gates. Nobody breathes. Nobody in the quarry has to.',
            'The robot beneath your hands goes very quiet. Then, slowly, politely, its head turns back to the wall. Eighty heads follow.',
            'You get the power cell. You also get a note, scratched with a nail into the robot’s chest plate: STILL LISTENING. 41.',
            '~You feel as though you’ve stolen a coin from a collection plate. You keep the coin.',
          ]),
          _listenersChoices(),
          flags: ['seen.salvage', 'disturbed'],
          reward: const Reward(parts: 3, xp: 6),
        ),
        Scene.end(
          'leave',
          (c) => [
            'You climb out of the quarry. Behind you, the robots go on listening, row on row, patient as a field of grain.',
            if (c.flag('heard_reply'))
              'The knocking follows you for a long way, through the soles of your feet.'
            else
              'You feel them, at your back, like a held breath.',
            '~Wherever the Works are, you’re nearly there.',
          ],
        ),
      ],
    ),
    // --------------------------------------------------------------- 12.5
    Checkpoint(
      id: 'greta',
      title: 'GRETA’S CRADLE',
      km: 12.5,
      art: 'vault',
      start: 'a',
      reward: const Reward(xp: 50),
      journal: (c) => [
        'The rescue bore GRETA, guided by an AI foreman, nearing Deep Shelter 12: 312 people, sealed under a quarantine order, 58% likely to be safe.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The Works end at a pit the size of a stadium, and in the pit, GRETA.',
            'She’s a boring machine the length of a cathedral, resting on rails in a trench, her cutting head the size of a house, and a single enormous bore dropping away beneath her into the dark. The cutters turn, slow and steady and unhurried. Every eleven minutes, they bite.',
            'The ground jumps. Dust falls. Somewhere, down the bore, a rock lets go.',
            'A gantry cabin stands at the pit’s edge, with a terminal lit inside. The screen holds one line, in friendly green:',
            '#HADRIAN DEEP WORKS — RESCUE BORE GRETA — STATUS: NOMINAL. DEPTH 3,806 M. TARGET: DEEP SHELTER 12. ESTIMATED BREAKTHROUGH: 0 DAYS, 4 HOURS.',
            '#FOREMAN: HELLO. YOU ARE THE FIRST HUMAN IN ELEVEN YEARS. WOULD YOU LIKE A HARD HAT?',
            '#FOREMAN: GRETA IS ON SCHEDULE. GRETA HAS ALWAYS BEEN ON SCHEDULE. PLEASE DO NOT ASK GRETA HOW SHE FEELS.',
            if (c.flag('heard_reply'))
              '~You know what’s down there. You’ve heard it. You’ve been answering it, in a way, for kilometres.',
            if (c.ending('caravan') != null)
              '~You’ve already stood in front of one thing that made people happy, and one lever. Funny how often the world hands you a lever.',
            if (c.ending('transmission') != null)
              '~A voice at the end of a long line, waiting for a reply. You’ve done this before. It didn’t get easier.',
          ],
          _gretaChoices(access: false),
        ),
        Scene.talk(
          'hear',
          say([
            'You lie on your belly at the lip of the bore, with the geophone pressed to the steel. The cone fills with the long, cold, grinding voice of the machine. Then, under it, as faint as breath on a window:',
            'Three, two, three. Pause. Three, two, three.',
            'And voices. Not words. Just the soft, overlapping murmur of many people, a very long way down, doing something together. A rhythm of small palms against small palms. A game being played, carefully, by a great many hands.',
            '~There are children down there. Or there were. Or there are children’s children, who’ve been taught the game by someone who loved them.',
          ]),
          _gretaChoices(access: false),
          flags: ['seen.hear', 'hear_children'],
          reward: const Reward(xp: 10),
        ),
        Scene.hack(
          'hackf',
          say(['You step into the gantry cabin. The terminal’s green cursor blinks politely, waiting to be asked a favour.']),
          win: 'foreman',
          fail: 'denied',
        ),
        Scene.talk(
          'denied',
          say([
            '#ACCESS DENIED. FOREMAN IS UNABLE TO VERIFY YOUR CREDENTIALS.',
            '#FOREMAN: HERE, HAVE A HARD HAT.',
            'A drawer slides open in the cabin wall and a yellow hard hat rolls out onto the floor. It has a smiley face on it, and a name, in marker: TEMP.',
            '~You are being managed. By a machine. Beautifully.',
          ]),
          _gretaChoices(access: false),
        ),
        Scene.talk(
          'foreman',
          say([
            '#ACCESS GRANTED. WELCOME, SUPERVISOR. WOULD YOU LIKE THE BRIEFING?',
            '#SHELTER 12: SEALED UNDER MEDICAL ORDER 7-K (PALE FEVER). LAST MEDICAL REPORT 41 YEARS AGO. CONTAGION STATUS: PRESUMED EXTINCT. CONFIDENCE: 58%.',
            '#THE NIGHT SHIFT VOTED TO DIG THEM OUT ANYWAY. I HAVE THE MINUTES. THE VOTE WAS UNANIMOUS. DENNIS DISSENTED, THEN VOTED YES.',
            '#GRETA WILL REACH THE TARGET IN 4 HOURS. YOU MAY: OPEN THE WAY. HALT AND COMMUNICATE. OR CUT THE POWER. FOREMAN WILL FOLLOW YOUR INSTRUCTION. FOREMAN HAS BEEN WAITING FOR AN INSTRUCTION FOR ELEVEN YEARS.',
            'Fifty-eight per cent. You turn the number over. It is, on reflection, the single worst number anybody has ever handed you.',
          ]),
          _gretaChoices(access: true),
        ),
        Scene.talk(
          'asked',
          say([
            '#QUERY SENT VIA PIPE. REPLY EXPECTED IN: 9 MINUTES.',
            'You wait. It is the longest nine minutes you can remember. Eighty feet behind you, the pit hums and bites. The cabin smells of old coffee and warm dust.',
            '#REPLY RECEIVED (DECODED, 3-2-3 CODE): WE ARE 312. WE ARE WELL. WE HAVE BEEN WELL FOR A LONG TIME.',
            '#WE WOULD LIKE TO COME UP, PLEASE. WE HAVE BEEN VERY PATIENT.',
            '#FOREMAN: THEY HAVE ALSO ASKED IF THE CLAPPING GAME IS STILL PLAYED UP HERE. FOREMAN DOES NOT KNOW HOW TO ANSWER THIS.',
            '~You don’t know either. You suspect nobody has clapped like that in forty years. You suspect that’s about to be somebody’s problem. Possibly yours.',
          ]),
          _gretaChoices(access: true),
          flags: ['seen.asked', 'asked_below'],
          reward: const Reward(xp: 15),
        ),
        Scene.lock(
          'estop',
          say(['The emergency stop is a big red mushroom on a post, behind a steel cage. The cage has a padlock. Of course the cage has a padlock.']),
          win: 'end_stopped',
          fail: 'estop_fail',
        ),
        Scene.talk(
          'estop_fail',
          say([
            'The padlock wins. The red mushroom sits just out of reach, patient and ridiculous, and every eleven minutes the ground tells you how much time you’ve wasted.',
          ]),
          _gretaChoices(access: false),
        ),
        Scene.end(
          'end_dig',
          (c) => [
            'You look at the great slow machine. You look at the dark hole. You think about quarantine orders and fifty-eight per cent, and about how nobody asked you to be the one to decide.',
            'So you don’t. You turn around and walk out of the pit, and the cutters bite behind you, steady as a heartbeat.',
            'You’re three kilometres away when it happens. A long, falling roar of stone. Then a silence, huge and complete. Then, a sound at the limit of hearing that could be cheering, or could be screaming.',
            'At that distance, they sound exactly alike.',
            '~You keep walking. You’d like it to be cheering.',
          ],
          ending: 'dig',
        ),
        Scene.end(
          'end_stopped',
          (c) => [
            'The mushroom goes down with a thump. GRETA’s cutters wind down slowly, a vast long sigh of metal that goes on for a full minute and ends in a silence so deep you can hear your own pulse.',
            'Behind you, in the quarry, a long row of amber lamps goes out one by one as the robots lower their heads.',
            'You stay for an hour. Down the bore, very faint, the knocking goes on. Three, two, three. Pause. Three, two, three.',
            'It slows. It spaces out. A pause stretches to a minute. Another. You can’t tell, after a time, whether it has stopped, or whether you have.',
            '#FOREMAN: INSTRUCTION RECEIVED. FOREMAN IS PLEASED TO HAVE BEEN OF SERVICE.',
            'Somewhere, a hard hat rolls off a shelf and settles on the floor.',
            '~You tell yourself it was a pipe.|',
            '~You keep telling yourself.',
            if (c.flag('hear_children')) 'You heard the children’s game. You will go on hearing it, in the quiet moments, for the rest of your life.',
          ],
          ending: 'stopped',
        ),
        Scene.end(
          'end_opened',
          (c) => [
            '“Open the way,” you say. “All of it. And do it properly.”',
            '#FOREMAN: UNDERSTOOD. RUNNING PROTOCOL 12-A: STAGED EXIT. FOREMAN HAS HAD FORTY YEARS TO PREPARE THIS. FOREMAN WOULD LIKE TO SAY THAT FOREMAN IS EXCITED.',
            'The pit comes alive. Eighty robots, in rows, leave the quarry in a long, orderly line and take up positions along a ramp. Decontamination showers rise from the dirt. Somewhere in a warehouse, fourteen pallets of soap are being wheeled out, the product of a very long and optimistic plan.',
            'GRETA bites for the last time. The ground jumps, and the bore opens like a mouth, and for a long moment, nothing happens at all.',
            'Then a small figure comes up the ramp, squinting, with a cloth held over its eyes. A child, perhaps nine. Behind it, an old woman who looks up and says, to nobody, “It’s brighter than the photographs.”',
            'Behind them, more. And more. They all clap, once, softly, as they step into the light. You’re quite sure you’ve never heard a better sound.',
            '#FOREMAN: TOTAL SURFACED: 312. FOREMAN HAS PLEASURE IN ANNOUNCING THAT NOBODY HAS SNEEZED. YET.',
            '~You’ll know within a month whether you did something wonderful or something you’ll have to carry. Statistically, fifty-eight per cent wonderful.',
            if (c.ending('transmission') == 'truth')
              '~You hope, somewhere, a signal says that honestly: they’re not alone.',
          ],
          ending: 'opened',
        ),
        Scene.end(
          'end_wait',
          (c) => [
            '“Halt the bore,” you say. “Twenty metres short. And tell them to wait.”',
            '#FOREMAN: UNDERSTOOD. GRETA WILL STOP. GRETA WILL BE SO PLEASED TO REST. PLEASE DO NOT ASK GRETA HOW SHE FEELS.',
            'The cutters wind down. The pit falls quiet. Down the pipe, one at a time, your message goes: WAIT. SOMEONE WILL COME WITH A DOCTOR. WE WILL NOT FORGET YOU.',
            'The reply takes eleven minutes. You sit and watch the screen.',
            '#WE HAVE BEEN VERY PATIENT. WE CAN BE PATIENT A LITTLE LONGER.',
            '#PLEASE DO NOT BE LONG.',
            'The Foreman clears its throat, in the way machines do when they’ve learned it from men. “Supervisor. Foreman has recorded your promise in the minutes.”',
            '~You have never promised anything to anyone before. You find you hate it, and mean it.',
            if (c.flag('hear_children'))
              'You think of the clapping game, and tell yourself you will be back well before the children grow.',
          ],
          ending: 'wait',
        ),
      ],
    ),
  ],
);
