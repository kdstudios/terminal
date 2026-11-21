import '../../combat_session.dart';
import '../../story_model.dart';
import '../story_kit.dart';

// THE GREAT WATER HEIST
// Low Well’s water has vanished. The council blames raiders, the mechanics blame
// the council, the Water Rats (led by Wrench) claim they are framed. The truth:
// Mayor Harlan diverted it into his private swimming pool. The pool has a leak.
//
// Factions you can win or lose: council, mechanics, Water Rats (flags
// fav.council / fav.mechanics / fav.rats). Endings: exposed, blackmail,
// repaired, rats.

List<Choice> _townChoices() => [
      Choice('[QUESTION COUNCILLOR PRUE]', 't_prue', show: (c) => !c.flag('seen.prue')),
      Choice('[QUESTION THE MAYOR]', 't_harlan', show: (c) => !c.flag('seen.harlan')),
      Choice('[CHECK THE EMPTY FOUNTAIN]', 't_fountain', show: (c) => !c.flag('seen.fountain')),
      Choice('[HEAD FOR THE PUMP HOUSE]', 't_go'),
    ];

final StoryDef waterheistStory = StoryDef(
  id: 'waterheist',
  title: 'THE GREAT WATER HEIST',
  tagline: 'A WHOLE TOWN’S WATER HAS VANISHED. SOMEBODY IS BEING VERY DAMP ABOUT IT.',
  difficulty: 'LOW',
  destinationKm: 7.0,
  recommendedLevel: 2,
  intro: [
    'Low Well is a settlement of a hundred and ten people, one pump and a very proud sign that reads LOW WELL: WE’RE MOSTLY HYDRATED. The sign has been crossed out. Underneath, in a shaking hand, someone has written: WE ARE NOT.',
    'The reservoir has been drained overnight. No spills, no tracks, no puddles. The council says raiders. The mechanics say the council. A gang called the Water Rats say they’ve been framed, which is what raiders would say.',
    'Somebody has pinned a reward to your shutter: ONE HUNDRED SCRAP FOR THE TRUTH. It is signed by the Mayor of Low Well, with a very damp thumbprint.',
  ],
  reward: const Reward(scrap: 160, xp: 100, stims: 1, parts: 1),
  endings: {
    'exposed': const Ending('exposed', 'THE MAYOR GOES DRY',
        'You told Low Well where its water had gone. The Mayor was removed from office in a procession of wheelbarrows. He still insists the pool was “a municipal feature.” The council has voted to turn it into a reservoir. It leaks a bit. It is, however, theirs.',
        bonus: Reward(xp: 40, scrap: 30), world: ['waterheist.exposed']),
    'blackmail': const Ending('blackmail', 'A SMALL, DAMP ARRANGEMENT',
        'You and the Mayor came to an understanding. The water will come back slowly, as long as a little of it goes in your canteen. Neither of you has ever used the word “blackmail.” You both use the word “fees.”',
        bonus: Reward(scrap: 120), world: ['waterheist.blackmail', 'debt.mayor']),
    'repaired': const Ending('repaired', 'THE LEAK IS FIXED',
        'You patched the pool, pumped the water back, and sent Mayor Harlan a bill and a very short letter. Low Well got its water. The Mayor kept his dignity, which was mostly a towel.',
        bonus: Reward(xp: 60, parts: 2), world: ['waterheist.repaired']),
    'rats': const Ending('rats', 'RULE OF THE RATS',
        'The Water Rats took the pool, the pump and the town hall, and were, as it turned out, fairer than the council. Wrench is Mayor now. She insists she is “just a temporary Rat.” Nobody has voted since.',
        bonus: Reward(xp: 30, scrap: 40), world: ['waterheist.rats']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You head for Low Well with an empty canteen and an uneasy feeling that everyone is about to ask you for it.']
      : ['The track to Low Well is dry, and getting drier with each step you take.'],
  ambient: [
    Ambient('A dried-up puddle with a bootprint in it. The bootprint is wet. The puddle is not. You decide not to think about it.', maxKm: 3),
    Ambient('A sign: FILL BUCKET HERE. Someone has scratched out FILL and written WISH.', maxKm: 3),
    Ambient('You pass a rat sitting on a post with a tiny bucket. It looks at you with deep accusation.', maxKm: 4),
    Ambient('Everywhere you look, a person is licking a stone. Nobody is happy about it.', maxKm: 4),
    Ambient('A cart rolls by loaded with empty barrels. The driver is crying, quietly, into a flask that is also empty.', minKm: 1, maxKm: 5),
    Ambient('You hear a distant splash. A single, joyful, out-of-place splash. Then a sheepish silence.', minKm: 2),
    Ambient('~A hundred and ten people with no water, and one man who definitely has some.', minKm: 2.5, when: (c) => c.done('town')),
    Ambient('A pipe runs across the track, bone dry, with a hand-written note: DO NOT SIP. WE CHECKED. IT IS ALL GONE.', minKm: 3.5, maxKm: 6),
    Ambient('Water Rat graffiti: WE DIDN’T DO IT. Beneath it, in a different hand: THAT’S WHAT RATS SAY.', minKm: 3.5),
    Ambient('Somewhere ahead, a fountain gurgles. You turn, and it’s only your stomach.', minKm: 4),
    Ambient('You find a wet footprint leading from the mayor’s road to the mayor’s gate. It’s a very big, flat, bare footprint.', minKm: 5, when: (c) => c.done('rats')),
    Ambient('The air smells faintly of chlorine. It’s the nicest thing you’ve smelled in days. It shouldn’t be.', minKm: 6),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'fountain',
      title: 'THE DRY FOUNTAIN',
      km: 1.2,
      text: (c) => [
        'The village fountain stands in Low Well’s market square: a handsome stone dolphin that used to spit water. It is dry. Its mouth is open in surprise. Someone has tied a bib around its neck.',
        'There are no dried tracks, no hose marks, no chalk. The cistern beneath the square has been emptied in what must have been a very tidy, very quiet night. A single wet bootprint, large and flat, leads away from it. Then the prints disappear on dry ground.',
        '~Someone took a whole reservoir and left good manners.|',
      ],
      journal: say(['The fountain dolphin in Low Well’s square was dry, with a bib on. A single large wet footprint led away from the cistern.']),
      reward: const Reward(xp: 8),
    ),
    Checkpoint(
      id: 'town',
      title: 'THE TOWN HALL',
      km: 2.6,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 20),
      journal: (c) => [
        'The council blames raiders. Councillor Prue is certain. Mayor Harlan is jovial, tanned and strangely damp.',
        if (c.flag('seen.harlan')) 'The Mayor’s hair was wet. He said it was “sweat.”',
        if (c.flag('seen.fountain')) 'The fountain’s dolphin had a bib on. Somebody cared a lot.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The town hall is a crowded, furious room full of dry people. Councillor Prue, a stern woman with a ledger, bangs a gavel. “It was RAIDERS,” she shouts. “It was OBVIOUSLY raiders. Who else takes water?”',
            'At the head of the table sits Mayor Harlan: a big, shiny, sun-dried man in a good shirt, with hair that has been recently, mysteriously, wet. He gives you a warm handshake. His palm is faintly pruned.',
            '“Our hero,” says the Mayor. “The scrapper who will save us. Let me know what you need. Except water. We’re out.”',
          ]),
          _townChoices(),
        ),
        Scene.talk(
          't_prue',
          say([
            '“Raiders,” says Councillor Prue, before you speak. “The Water Rats. They’ve been stealing for years. I have it in the ledger.” She opens it. It’s a ledger of the Rats’ crimes, two pages long, and one of them is “looked at my chickens.”',
            '“Do you have any evidence they took the reservoir?”',
            '“They’re RATS,” she says, as though that were evidence. But a flicker of doubt crosses her face. “It’s just... the cistern was drained so quietly. They’re not quiet people.”',
          ]),
          _townChoices(),
          flags: ['seen.prue', 'fav.council'],
        ),
        Scene.talk(
          't_harlan',
          (c) => [
            'The Mayor leans back, one hand behind his head. A drip falls from his hair onto a perfectly dry desk. He watches it fall, and then, with great composure, wipes it away with his sleeve.',
            '“Terrible business,” he says. “I’m devastated. I spend my days in my office. Hardly a drop to drink. I’ve lost two kilos.” He pats a stomach that looks like it has not noticed.',
            if (c.skill('SURVIVAL') >= 1)
              'You notice the faint line of sunburn across his nose, in the exact shape of a pair of goggles. A man who has been in the sun, in goggles, with no water, in a drought.',
            'He leans forward, smiling. “Do find the thieves. I’ll pay handsomely. I just don’t,” he adds, with a small laugh, “have a lot of liquid assets.”',
          ],
          _townChoices(),
          flags: ['seen.harlan', 'harlan_odd'],
        ),
        Scene.talk(
          't_fountain',
          say([
            'You examine the dolphin. Under its chin is a plaque: IN LOVING MEMORY OF A WELL. Behind it, in the shadow, a pipe has been unscrewed and a new one fitted, a thick, shiny, expensive pipe, pointing away from the square.',
            'It heads toward the Mayor’s road. The cap was put back on afterwards. Very carefully. The way you would if you meant to come back.',
          ]),
          _townChoices(),
          flags: ['seen.fountain', 'found_pipe'],
          reward: const Reward(xp: 8),
        ),
        Scene.end(
          't_go',
          say(['The mechanics’ foreman has sent word: the pump house, if you’re brave, if you’re listening, if you’re not with the council. You go, trying to look like someone who isn’t.']),
        ),
      ],
    ),
    Checkpoint(
      id: 'mechanics',
      title: 'THE PUMP HOUSE',
      km: 4.0,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 25),
      journal: (c) => [
        'Foreman Odd and the mechanics blame the council. The pump itself is undamaged; the water was pulled off a side valve.',
        if (c.flag('fav.mechanics')) 'I took the mechanics’ side. They gave me a wrench. It was Wrench’s, but nobody was going to say.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The pump house is a brick shed full of grease and bad moods. Foreman Odd, a vast man with forearms like gate posts, stands in front of a gleaming pump engine with his arms folded.',
            '“It’s the council,” he says. “They’ve been rationing for years. They took the whole lot and said it was a leak. Look at this pump. Perfect. If it had broken, I’d know. It’s been turned off at the main valve. By a person.”',
            '“Which person?”',
            '“One who can afford a very big wrench,” says Odd.',
          ]),
          [
            Choice('[SIDE WITH THE MECHANICS]', 'side', flags: ['fav.mechanics']),
            skillChoice('ENGINEERING', 1, 'INSPECT THE MAIN VALVE', 'valve'),
            Choice('[ASK ABOUT THE WATER RATS]', 'rats'),
            Choice('[SAY YOU’LL LOOK INTO IT]', 'out'),
          ],
        ),
        Scene.talk(
          'side',
          say([
            'Odd shakes your hand so hard it needs a minute. “Finally,” he says. “Somebody sensible.” He hands you a spare spanner, slightly worse for wear. “Take that. If you see anyone with a pool, hit them with it.”',
            '“Why a pool?”',
            'Odd looks surprised. “I don’t know why I said that.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'valve',
          say([
            'The main valve has been closed with a very specific tool: a three-quarter pipe key, the kind you’d find in a plumbing van or a rich man’s toolbox. There is a fine film of white powder on the handle.',
            'You rub it between two fingers. It’s chlorine tablets. Somebody has been handling pool chemicals.',
            '“Chlorine,” says Odd, confused. “Nobody uses chlorine. We haven’t had a pool in thirty years.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['found_chlorine'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'rats',
          say([
            '“The Rats?” Odd snorts. “They couldn’t drain a bath. Mostly they just steal pumps for a laugh and put them back with notes. WRENCH LEFT THIS ON. That sort of thing. They’re not clever enough to take a town’s water. They’re barely clever enough to take it politely.”',
            'He looks around, lowers his voice. “If you want a real answer, ask her yourself. She’s in the old cannery.”',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['rats_tip'],
        ),
        Scene.end('out', say(['You head toward the old cannery, where the Water Rats are supposed to live. On the way you pass a sign: NO ADMITTANCE. RATS WELCOME.'])),
      ],
    ),
    Checkpoint(
      id: 'rats',
      title: 'THE WATER RATS',
      km: 5.4,
      art: 'gang',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 30),
      journal: (c) => [
        'The Water Rats’ leader, Wrench, claims they were framed. She has a pipe map showing where the water actually went.',
        if (c.flag('rats_trust')) 'I trusted the Rats. It’s early days.',
        if (c.flag('rats_fought')) 'I fought the Rats first. Wrench respects that, grudgingly.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The Rats live in an old cannery under a faded sign that says SPRATT’S FINE PRESERVES. About a dozen of them lounge on crates: sunburned kids and tired adults, all in goggles pushed up on their foreheads.',
            'A short, wiry woman with a wrench through her belt stands up from the middle of them. “I’m Wrench,” she says. “We didn’t do it. You’re going to say we would. You’re right. We would. We just didn’t.”',
            'Behind her hangs a map, in crayon, of the town’s pipes. Someone has drawn a very worried rat in the corner.',
          ]),
          [
            Choice('[LISTEN TO WRENCH]', 'listen'),
            Choice('[ACCUSE THEM]', 'accuse'),
            Choice('[SEARCH THE CANNERY]', 'search', show: (c) => !c.flag('seen.search')),
          ],
        ),
        Scene.talk(
          'listen',
          say([
            'Wrench taps the map. “Water never leaves a town without a pipe. We’ve been mapping them for years. It’s a hobby. A bad one. Look.” She traces a bright blue line out of the reservoir and up the hill, into a patch labelled THE MAYOR’S DRIVE. “That pipe wasn’t here last month. We checked.”',
            '“Why not tell the council?”',
            '“They’d say we put it there,” says Wrench. “They say everything we do is a crime. Even the good things. We rescued a goat once. They put us on a list.”',
          ]),
          [
            Choice('[TRUST HER]', 'trust'),
            Choice('[“PROVE IT.”]', 'prove'),
          ],
          flags: ['heard_wrench'],
        ),
        Scene.talk(
          'trust',
          say([
            '“All right,” you say. “I believe you.” A silence. A very long silence. Then a Rat in the back says, in a small voice, “Nobody’s ever said that.”',
            'Wrench’s jaw works. She’s not a woman who cries. She looks a bit like she’s considering it. “Don’t make me regret this,” she says, and hands you a pair of goggles. They’re warm from someone’s forehead.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['rats_trust', 'fav.rats'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'prove',
          say([
            'Wrench folds her arms. “Fine.” She takes you up onto the roof of the cannery and passes you a pair of binoculars. A mile up the hill, on the Mayor’s drive, a long, glittering, blue shape glimmers in the sun.',
            'It’s a swimming pool. It is almost certainly the only swimming pool for fifty kilometres. It is also, from here, visibly leaking: a long dark stain runs down the hill from the corner, soaking the hillside, feeding a very green, very smug bit of grass.',
            '“Told you,” says Wrench.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['saw_pool', 'fav.rats'],
          reward: const Reward(xp: 15),
        ),
        Scene.talk(
          'accuse',
          say([
            '“It was you,” you say. The cannery goes very quiet. A dozen Rats stand up. Wrench’s hand falls to her wrench.',
            '“It would be,” she says, softly, “a lot of fun to prove that to you.”',
          ]),
          [
            Choice('[BACK DOWN]', 'a'),
            Choice('[PRESS THE POINT]', 'fight'),
          ],
        ),
        Scene.fight(
          'fight',
          say(['Wrench whistles. Two Rats leap from the crates with pipe-lengths. They’re all very enthusiastic and none of them are any good at it.']),
          EnemyType.straggler,
          win: 'won',
          fail: 'lost',
        ),
        Scene.talk(
          'won',
          say([
            'Wrench sits against the wall, breathing hard, and then she laughs. “Okay,” she says. “You’re all right. Nobody’s hit me in a year. Do you want to see the map?”',
          ]),
          [Choice('[LOOK AT THE MAP]', 'listen')],
          flags: ['rats_fought'],
        ),
        Scene.talk(
          'lost',
          say([
            'You land on a pile of crates and a very small Rat sits on your chest. “Sorry,” she says. “Is this a bad time?”',
            'Wrench pulls her off. “Look,” she says, rubbing her face. “We’re bad at this. But we’re not liars. Listen.”',
          ]),
          [Choice('[LISTEN]', 'listen')],
        ),
        Scene.talk(
          'search',
          say([
            'You poke around the cannery. There’s a mattress, a fridge full of crackers, and a hundred and twelve plastic rats nailed to a wall. Behind a cracked mirror you find a stash of town property: a stolen sundial, the council’s second-best gavel, and a note: WE ONLY BORROW.',
            'You can see why people don’t trust them.',
          ]),
          [
            Choice('[LISTEN TO WRENCH]', 'listen'),
            Choice('[SAY NOTHING]', 'a'),
          ],
          flags: ['seen.search'],
        ),
        Scene.end('out', say(['You leave the cannery with a hand-drawn map in your pocket. It has a big blue pool on it, drawn with relish. The pool has a little drip-drip-drip line coming out of the corner.'])),
      ],
    ),
    Checkpoint(
      id: 'pool',
      title: 'THE MAYOR’S POOL',
      km: 7.0,
      art: 'building',
      start: 'a',
      reward: const Reward(scrap: 30, xp: 45),
      journal: (c) => ['Mayor Harlan had the whole reservoir diverted into a private swimming pool. The pool has a leak. I had to decide what to do about all of it.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The Mayor’s drive ends at a high white wall and a rose-coloured gate. Behind it, on a terrace of white tiles, sparkles a swimming pool the size of a church. It’s a perfect blue. It has a diving board. A deckchair. A little waiter’s bell.',
            'Mayor Harlan is floating in the middle of it on an inflatable swan, with a drink, a towel and a straw hat. He is humming. He is very, very happy.',
            'In the far corner, a thin dark crack runs down the pool’s tiled wall, and a steady, shining trickle of water runs out into the dust. The Mayor, you realise, is looking at the crack, and trying very hard not to.',
            if (c.flag('fav.rats')) 'From the hedge, Wrench gives you a tiny nod. Four Rats are crouched beside her with buckets.',
          ],
          [
            Choice('[CONFRONT THE MAYOR]', 'confront'),
            Choice('[LOOK AT THE LEAK]', 'leak'),
            Choice('[SIGNAL THE RATS]', 'rats', show: (c) => c.flag('fav.rats')),
          ],
        ),
        Scene.talk(
          'confront',
          say([
            'You clear your throat. The Mayor opens one eye. “Ah,” he says. “The scrapper. Come to report on the thieves?”',
            '“It’s you,” you say. “You took the water.”',
            'There is a long silence. The swan creaks. He sits up with great dignity. “I prefer to think,” he says, “that I managed it. Strategically. For the long-term good of the community. I was going to share it. Eventually. I just wanted to be in a pool first.”',
            '“And the leak?”',
            'His smile goes brittle. “Ah,” says the Mayor. “That is... a work in progress.”',
          ]),
          [
            Choice('[EXPOSE HIM TO THE TOWN]', 'end_exposed'),
            Choice('[“LET’S TALK ABOUT FEES.”]', 'end_blackmail'),
            Choice('[“LET’S FIX THE LEAK.”]', 'fix'),
          ],
          flags: ['confronted'],
        ),
        Scene.talk(
          'leak',
          say([
            'You walk the tiled edge and crouch at the crack. It’s a long, hairline fracture: cheap grout, thin concrete, a patch of what you suspect is chewing gum.',
            'The water is running down the hill and into a perfectly good field of clover. All the town’s water, trickling into a ditch, a few litres at a time, for a rich man’s comfort.',
            '~There’s a kind of bitter comedy to it. He stole a reservoir to float in, and has been losing it a bucket at a time.',
          ]),
          [Choice('[CONFRONT THE MAYOR]', 'confront')],
          flags: ['saw_leak'],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'rats',
          say([
            'You whistle. The hedge erupts. Twelve Water Rats pour over the wall with buckets, hoses, and a shocking amount of enthusiasm. They’re in the pool before the Mayor has time to say “trespass.”',
            '“THIEF!” shouts Wrench. “IT’S THE MAYOR!” Half the neighbourhood has gathered by the gate, drawn by the commotion. The Mayor, in his swan, is slowly drifting toward the edge, eyes wide.',
          ]),
          [
            Choice('[LET THE RATS TAKE OVER]', 'end_rats'),
            Choice('[CALM THE CROWD AND EXPOSE HIM]', 'end_exposed'),
          ],
        ),
        Scene.talk(
          'fix',
          say([
            'The Mayor blinks. “You’d... fix it?”',
            'You take a look at the leak. It’s a straightforward patch, with the right parts. You set about it with a trowel, a bag of quick-set, and a short, sharp lecture about why you don’t build a pool on a hill.',
            'By evening, the pool is sealed. The Mayor stands in a towel, watching you pump it back through the town’s pipe, and looks, for the first time, ashamed.',
          ]),
          [Choice('[SEND HIM THE BILL]', 'end_repaired')],
          reward: const Reward(xp: 15, parts: 1),
        ),
        Scene.end(
          'end_exposed',
          say([
            'You stand on the terrace and tell Low Well what the Mayor has done. The crowd goes quiet. Then a very old woman at the front says, “He had a SWAN?” and the day is lost.',
            'They march him off the terrace in his towel, and drain the pool by hand. It takes all night, a hundred and ten people with buckets. At dawn the cistern is full and the pool is a muddy hole.',
            'Mayor Harlan insists to the end that it was “a municipal feature.” Nobody listens, but they do put it on the plaque.',
          ]),
          ending: 'exposed',
        ),
        Scene.end(
          'end_blackmail',
          say([
            '“Fees,” the Mayor repeats, carefully. “Yes. That’s a very sensible word.” He pours you a drink from a pitcher that has been, you note, filled from the town’s water.',
            'The water will go back slowly, he tells you. A bit each day. And a bit each day will find its way into your canteen. It is, he says, the least he can do for a hero.',
            'You leave with your canteen heavy and your conscience light, and you’re not sure whether either of those is a good sign.',
          ]),
          ending: 'blackmail',
        ),
        Scene.end(
          'end_repaired',
          say([
            'The town gets its water back. The Mayor gets a small, formal letter of apology and a large, informal invoice. He pays it in full, in clean, dry coin, and is never seen in a swimming pool again.',
            'Wrench sends you a thank-you note, signed with a rat. It’s the best letter you’ve ever received. It says WE STILL DID NOT DO IT.',
          ]),
          ending: 'repaired',
        ),
        Scene.end(
          'end_rats',
          say([
            'The Rats take the pool, the pump and the town hall in under an hour. It’s the most efficient coup in the history of Low Well. Wrench is installed in the Mayor’s chair, which she finds both too big and too clean.',
            '“It’s temporary,” she says. “Just until we sort things out.” She issues her first decree: all water belongs to everyone, and nobody may swim without a licence. The licence is free. It’s written in crayon.',
            'The Mayor, in his towel, is sent to work in the pump house. Foreman Odd is delighted. He gives him a very small spanner.',
          ]),
          ending: 'rats',
        ),
      ],
    ),
  ],
);
