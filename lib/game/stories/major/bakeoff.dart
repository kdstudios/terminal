import '../../combat_session.dart';
import '../../story_model.dart';
import '../characters/brother_positive.dart';

// THE GREAT WASTELAND BAKE-OFF
// A cooking competition with mutated ingredients and absurdly serious judges.
// An ordinary tin of beans turns out to matter: the judges are starving, not
// for novelty, but for something ordinary and honest.
//
// Contestants: Madame Brioche (snob), Big Tam (eats anything), Sister Crumb
// (devout), Dave (suspiciously ordinary). Judges: Chef Vane (icy), Colonel
// Pudding (military, secretly grieving). Endings: beans, dave, tam, riot.

List<Choice> _tentChoices() => [
      Choice('[MEET MADAME BRIOCHE]', 't_brioche', show: (c) => !c.flag('seen.brioche')),
      Choice('[MEET BIG TAM]', 't_tam', show: (c) => !c.flag('seen.tam')),
      Choice('[MEET THE QUIET MAN IN THE CORNER]', 't_dave', show: (c) => !c.flag('seen.dave')),
      Choice('[GO FORAGING]', 't_go'),
    ];

final StoryDef bakeoffStory = StoryDef(
  id: 'bakeoff',
  title: 'THE GREAT WASTELAND BAKE-OFF',
  tagline: 'ONE OVEN. FOUR CONTESTANTS. TWO JUDGES WHO HAVE NOT SMILED SINCE THE WAR.',
  difficulty: 'LOW',
  destinationKm: 6.5,
  recommendedLevel: 2,
  intro: [
    'The poster is stuck to your shutter with a fork. THE GREAT WASTELAND BAKE-OFF. ONE WINNER. ONE GOLDEN LADLE. NO REFUNDS. ENTRANTS MUST BRING THEIR OWN INGREDIENTS. THE JUDGES WILL NOT BE ASKED TO EAT ANYTHING THAT BITES BACK. (THEY HAVE ALREADY BEEN BITTEN.)',
    'There’s a smaller note at the bottom, in the judges’ official hand: ENTRY FEE: ONE (1) TIN OF ANYTHING ORDINARY.',
    'You do not own anything ordinary. You own a dented tin of beans that you’ve carried for months, out of sentiment, spite or both. You put it in your pocket.',
  ],
  reward: const Reward(scrap: 140, xp: 90, stims: 1),
  endings: {
    'beans': const Ending('beans', 'THE GOLDEN LADLE (BEANS)',
        'You warmed your beans on a slice of burnt toast and set them in front of two judges who had seen everything. The Colonel wept. The Chef put down her spoon. You won on a single, perfect, ordinary plate. The ladle is on your shelf. It is a bit sticky.',
        bonus: Reward(xp: 50, stims: 1), world: ['bakeoff.beans']),
    'dave': const Ending('dave', 'DAVE WINS',
        'Dave made a plain sponge. It was flawless. It was, said the Chef, “the most boring thing I have ever tasted, and I cannot stop.” Dave accepted the Golden Ladle with an air of mild apology. Nobody remembers his face the next day.',
        bonus: Reward(xp: 30, scrap: 40), world: ['bakeoff.dave']),
    'tam': const Ending('tam', 'THE TAM INCIDENT',
        'Big Tam’s dish had eleven legs and a pulse. The judges were taken to hospital. Tam won by default, with a certificate and a very small prize. He says he will frame it. He says he will also eat it.',
        bonus: Reward(scrap: 60), world: ['bakeoff.tam']),
    'riot': const Ending('riot', 'THE CUSTARD RIOT',
        'You sabotaged one dish too many. The custard went first, then the pastry, then a trifle that nobody could account for. The tent has been closed for repairs. The Golden Ladle is missing. So, for the time being, are you.',
        bonus: Reward(xp: 20, scrap: 50), world: ['bakeoff.riot']),
  },
  depart: (c) => c.run.done.isEmpty && c.km < 0.1
      ? ['You set off for the bake-off with a tin of beans in your pocket and your dignity on a very thin string.']
      : ['The smell of burning sugar drifts across the road. You are, against all reason, hungry.'],
  ambient: [
    Ambient('A hand-painted sign: BAKE-OFF THIS WAY. IF IT SCREAMS, IT’S NOT READY.', maxKm: 2),
    Ambient('A scavenger walks past with a whole tray of something shiny and wobbling. It’s alive. It’s not rushing.', maxKm: 3),
    Ambient('Somewhere ahead, a whisk is being used in anger.', maxKm: 3),
    Ambient('You pass a mutant chicken sitting on an upturned crate, looking terrified. It knows what the poster said.', minKm: 1, maxKm: 4),
    Ambient('A thin, cold voice on the wind: “It’s... flat. It’s a flat, joyless crumb.” A pause. “Next.”', minKm: 1.5, maxKm: 4),
    Ambient('Someone has hung bunting. It’s made out of tea towels. Each of them is stained with a different, interesting mistake.', minKm: 2),
    Ambient('~There are hundreds of ways to make something taste good. Out here, there’s only one way to make it taste of anything.', minKm: 2.5),
    Ambient('You pass a tin on a post. It says SECRET INGREDIENT. It’s a tin of beans. It’s the same brand as yours.', minKm: 3, when: (c) => c.done('tent')),
    Ambient('A crow with a tiny paper hat is stealing meringue. Nobody tries to stop it.', minKm: 3.5),
    Ambient('Your tin of beans clinks in your pocket. It sounds almost smug.', minKm: 4, when: (c) => c.flag('kept_beans')),
    Ambient('The smell of a Victoria sponge reaches you. It’s so ordinary that it stops you in your tracks.', minKm: 5, when: (c) => c.flag('seen.dave')),
    Ambient('Judges’ voices, tinny and tired: “Is that all you’ve got?” “It’s an egg.” “...an egg. How radical.”', minKm: 5.5),
  ],
  checkpoints: [
    Checkpoint.auto(
      id: 'poster',
      title: 'THE POSTER',
      km: 0.9,
      text: (c) => [
        'Another poster, nailed to a fence post, with a small crowd of people reading it solemnly. THE GREAT WASTELAND BAKE-OFF. Beneath, someone has scrawled a list of past winners: LAST YEAR: A PIE (UNIDENTIFIED). THE YEAR BEFORE: A LOAF (SENTIENT). THE YEAR BEFORE THAT: NOBODY. (THE JUDGES WERE UNWELL.)',
        'One of the readers is a man in a perfectly ordinary coat. He nods at you and goes on reading. He’s holding a sandwich.',
        '~Even the poster knows what’s coming.|',
      ],
      journal: say(['A poster listed past winners. One was “sentient.” A man in an ordinary coat nodded at me.']),
      reward: const Reward(xp: 5),
    ),
    Checkpoint(
      id: 'tent',
      title: 'THE BAKING TENT',
      km: 2.2,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 10, xp: 20),
      journal: (c) => [
        'The baking tent: four ovens, four contestants, two judges. Madame Brioche, Big Tam, Sister Crumb and Dave.',
        if (c.flag('seen.dave')) 'Dave was there. Of course he was. He had a recipe for sponge.',
      ],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The baking tent is a patchwork of tarpaulins with four trestle ovens in a row. At the front, behind a long table, two judges sit very straight: a cold, tall woman in a chef’s whites, and a rigid, moustached man in a faded uniform.',
            '“I am Chef Marguerite Vane,” says the woman. “This is Colonel Pudding. We have judged every dish in this wasteland for twenty years. We have not been impressed.”',
            '“I was impressed once,” says the Colonel, to himself. “There was a pudding.”',
            'Four contestants await. Sister Crumb is already praying at her oven. And in the corner, a man in an ordinary coat, tying an ordinary apron.',
            if (BrotherPositive.mood(c) != 'new') 'To your surprise, a figure in a robe made of jump leads is a spectator, near the back, with a bag of crisps. “I came for the snacks,” he whispers.',
          ],
          _tentChoices(),
        ),
        Scene.talk(
          't_brioche',
          say([
            'Madame Brioche is a tall, powdered woman in a silk apron who holds her whisk like a conductor’s baton. She does not look at you.',
            '“I do not bake with scavenged ingredients,” she says. “I do not bake with things that have names. I bake with art. I bake with butter. I bake,” she adds, with a shudder, “with eggs from a chicken that has been to school.”',
            '“What are you making?”',
            '“A tarte of emotional resonance,” says Madame Brioche. “It will be inedible. That is how you know it’s good.”',
          ]),
          _tentChoices(),
          flags: ['seen.brioche'],
        ),
        Scene.talk(
          't_tam',
          say([
            'Big Tam is a vast, cheerful man with a stained apron and a pot lid for a hat. A trestle table behind him is covered in things you can’t immediately name: three jars of something that wriggles, a mutant crab, and a whole, slightly offended cow’s tongue.',
            '“I eat anything,” he says. “I’ve eaten the lot. I once ate a hubcap. Nobody told me it wasn’t food.” He pats his stomach. “I think the wasteland’s a very big larder, and nobody’s really looked.”',
            'The crab waves at you. Tam waves back. “That’s Gerald,” he says. “He’s the main course.”',
          ]),
          _tentChoices(),
          flags: ['seen.tam'],
        ),
        Scene.talk(
          't_dave',
          (c) => [
            ...BrotherPositive.dave(c),
            '“Dave,” he says, offering a very ordinary hand. “I’m just here for the sponge. Don’t mind me.”',
            'You notice the judges don’t look at him either. They’ve looked at Tam. They’ve looked at Brioche. Their eyes pass over Dave like water over a stone.',
            '“Do you think you’ll win?” you ask. “Oh, I shouldn’t think so,” says Dave. And he smiles, a small one, with something very steady behind it.',
          ],
          _tentChoices(),
          flags: ['seen.dave', 'dave_threat'],
          reward: const Reward(xp: 6),
        ),
        Scene.end('t_go', say([
          '“Contestants,” says Chef Vane. “You have one hour to forage. Do not return with anything we have to put out.”',
          'A gong sounds. The contestants scatter. You consider your tin of beans for a long moment, and put it back in your pocket.',
        ])),
      ],
    ),
    Checkpoint(
      id: 'forage',
      title: 'FORAGING',
      km: 3.8,
      art: 'drifter',
      start: 'a',
      reward: const Reward(scrap: 15, xp: 25),
      journal: (c) => [
        'Foraging for the bake-off: mutant eggs, a pantry full of preserved food, and a tin of beans that I had.',
        if (c.flag('got_eggs')) 'I got mutant eggs. They were warm and slightly pulsing.',
        if (c.flag('got_jam')) 'I got a jar of pre-war jam, sealed.',
        if (c.flag('kept_beans')) 'I decided to keep my tin of beans.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The wasteland is generous in odd ways. You have an hour, a basket and an uneasy sense of rivalry. To your left, a ruined cold store with a padlocked pantry. To your right, a nest of enormous, faintly glowing eggs, guarded by something large.',
            'And in your pocket, the beans.',
          ]),
          [
            Choice('[RAID THE NEST]', 'nest'),
            Choice('[PICK THE PANTRY]', 'pantry'),
            Choice('[JUST USE THE BEANS]', 'beans'),
          ],
        ),
        Scene.fight(
          'nest',
          say(['You creep up on the nest. The mother, a giant, mottled thing with six legs and a look of immense disapproval, turns and sees you. You hold up a basket. She charges.']),
          EnemyType.crawler,
          win: 'eggs',
          fail: 'noeggs',
        ),
        Scene.talk(
          'eggs',
          say([
            'You come away with three warm, faintly glowing eggs and a bruise. One of them hums. You decide not to think about it.',
            '~Every ingredient is a story, and the story always ends with someone being bitten.',
          ]),
          [Choice('[CONTINUE]', 'back')],
          flags: ['got_eggs'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'noeggs',
          say(['You flee with nothing but a feather, a limp and a strongly worded smell. The nest is still there. So is the mother. You think she is laughing.']),
          [Choice('[CONTINUE]', 'back')],
        ),
        Scene.lock(
          'pantry',
          say(['The pantry door is padlocked. A little note taped to it: DO NOT OPEN. SEE MR. HOLLIS. (MR. HOLLIS IS NOT AVAILABLE.)']),
          win: 'jam',
          fail: 'nojam',
        ),
        Scene.talk(
          'jam',
          say([
            'Inside, a shelf of preserved food: three jars of pre-war jam, one still sealed, a half-eaten sausage that moves faintly, and a single, ominous jar labelled “FERMENTED, 2031: FOR EMERGENCIES.”',
            'You take the sealed jam. It’s old, and sweet, and not, as far as you can tell, plotting.',
          ]),
          [Choice('[CONTINUE]', 'back')],
          flags: ['got_jam'],
          reward: const Reward(xp: 10),
        ),
        Scene.talk(
          'nojam',
          say(['The lock holds. You hear a voice from inside the pantry say, very softly, “Not yet.” You back away at a respectful pace.']),
          [Choice('[CONTINUE]', 'back')],
        ),
        Scene.talk(
          'beans',
          say([
            'You take out the tin. It’s dented, faded and very plain. The label says AUNT DOT’S BAKED BEANS: A TASTE OF HOME. It has a picture of a smiling woman in a bonnet. You feel foolish.',
            'But it is the only honest thing you own.',
          ]),
          [Choice('[CONTINUE]', 'back')],
          flags: ['kept_beans'],
          reward: const Reward(xp: 8),
        ),
        Scene.end('back', say(['The gong sounds. You head back to the tent with a basket of whatever the wasteland chose to give you. Behind you, a crow steals a meringue.'])),
      ],
    ),
    Checkpoint(
      id: 'trial',
      title: 'THE FIRST TASTING',
      km: 5.2,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 20, xp: 30),
      journal: (c) => [
        'The judges tasted the contestants’ first dishes. Madame Brioche’s was “art.” Tam’s was “alive.” Dave’s was “a sponge.”',
        if (c.flag('sabotaged')) 'I sabotaged somebody’s dish. I will not say whose.',
      ],
      scenes: [
        Scene.talk(
          'a',
          say([
            'The tasting begins. Madame Brioche’s tarte is greeted with a long, appalled silence, then a single nod from Chef Vane. “It is art,” she says. “I hate it.” Sister Crumb’s bread causes the Colonel to weep, quietly, and apologise to nobody.',
            'Big Tam’s dish of Gerald and friends, still squirming gently on a plate, is declined. “I won’t,” says the Chef. “I physically can’t.” Tam shrugs. “More for me.”',
            'At the end of the table, Dave sets down a plain, golden sponge on a clean white plate. Nobody looks at it. The Colonel looks at it for a very long time.',
            'It’s your turn. You hold the basket. The judges look bored.',
          ]),
          [
            Choice('[PRESENT YOUR DISH]', 'present'),
            Choice('[SABOTAGE DAVE’S SPONGE]', 'sab_dave'),
            Choice('[SABOTAGE MADAME BRIOCHE]', 'sab_brioche'),
            Choice('[SPEAK TO THE COLONEL FIRST]', 'colonel'),
          ],
        ),
        Scene.talk(
          'present',
          (c) => [
            if (c.flag('got_eggs') && c.flag('got_jam'))
              'You present what you foraged: a nest’s worth of glowing egg and a jar of old, sweet jam, whipped into something that is mostly defensible. The Chef takes a bite, grimaces, takes another, and says, “It is... trying.”'
            else if (c.flag('got_eggs'))
              'You present three glowing eggs, whipped into something that hums faintly. The Chef takes a bite, grimaces, takes another, and says, “It is... trying.”'
            else if (c.flag('got_jam'))
              'You present a jar of old, sweet jam on bread. The Chef takes a bite, grimaces, takes another, and says, “It is... trying.”'
            else
              'You present what you have: a tin of beans, a burnt slice of bread and a trembling hope. The Chef stares at it. “That,” she says, “is not a dish.”',
            'The Colonel is looking out of the window. He isn’t eating. He doesn’t look like he’s eaten in days.',
          ],
          [
            Choice('[SPEAK TO THE COLONEL]', 'colonel'),
            Choice('[MOVE ON TO THE FINAL]', 'out'),
          ],
          reward: const Reward(xp: 8),
        ),
        Scene.talk(
          'sab_dave',
          say([
            'You edge toward Dave’s sponge with a pinch of salt in your sleeve. At the last second, you stop. Dave is watching you, mild as milk, with the very faintest smile.',
            '“I wouldn’t,” he says, quite gently. “It wouldn’t make it worse. It’s a very forgiving sponge.”',
            'You put the salt away. You feel, strangely, like you’ve been told something about yourself.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['tried_sab'],
        ),
        Scene.talk(
          'sab_brioche',
          say([
            'You lean over Madame Brioche’s pastry and tip in a handful of grit from your boot. She turns. You’re standing there, boot in hand, nonchalant.',
            '“The tarte is ruined,” she says, with immense, trembling calm. “It is the most wonderful thing you have ever done to me. I have never felt so seen.”',
            'You’ve made it worse for her and, somehow, better for her art.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['sabotaged', 'brioche_sab'],
        ),
        Scene.talk(
          'colonel',
          say([
            'You step aside with the Colonel. He’s stiff and silent, with the haunted look of a man whose rations ran out a long time ago. “What is it that you’re looking for?” you ask. “In a dish.”',
            'The Colonel exhales. “I was married,” he says. “Forty years ago. My wife made a stew. She called it just beans. It had a tin of beans in it, and nothing else, and it was the best meal I ever had. I’ve judged thirty thousand dishes since. None of them were that.”',
            '“What was the brand?”',
            'He looks at you. “Aunt Dot’s,” he says. “Why?”',
          ]),
          [
            Choice('[SAY NOTHING]', 'out'),
            Choice('[SHOW HIM THE TIN]', 'tin', show: (c) => c.flag('kept_beans')),
          ],
          flags: ['colonel_talk'],
          reward: const Reward(xp: 12),
        ),
        Scene.talk(
          'tin',
          say([
            'You slowly pull out the dented tin. The Colonel’s moustache trembles. “May I?” he whispers. He turns it over and over in his hands. He runs a thumb over the picture of the bonneted woman.',
            '“I haven’t seen one in thirty years,” he says. His voice cracks. “May I... may I eat this?”',
            '“It’s the entry,” you say. “It’s for the final.”',
            'He gives it back, with enormous reluctance and a small salute. “Then I’ll wait,” he says.',
          ]),
          [Choice('[CONTINUE]', 'out')],
          flags: ['showed_tin'],
          reward: const Reward(xp: 15),
        ),
        Scene.end('out', say(['The gong sounds for the final round. The tent goes silent. The Golden Ladle glimmers on the judges’ table, in a pool of lantern light.'])),
      ],
    ),
    Checkpoint(
      id: 'final',
      title: 'THE FINAL',
      km: 6.5,
      art: 'camp',
      start: 'a',
      reward: const Reward(scrap: 30, xp: 45),
      journal: (c) => ['The final round of the Great Wasteland Bake-Off, and the Golden Ladle. I had one tin of beans, one chance and two judges.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'The final round: each contestant has one dish and one chance. Madame Brioche presents a deconstructed grief. Big Tam presents something with a pulse. Sister Crumb prays over a pie. Dave sets down his sponge.',
            'Now it’s you. The tent is silent. Chef Vane looks at you with an expression of absolute, merciless boredom. The Colonel is looking at your pocket.',
            if (c.flag('showed_tin')) 'He leans forward in his chair, a very tiny amount. A tiny, hopeful amount.',
          ],
          [
            Choice('[SERVE THE BEANS]', 'beans', show: (c) => c.flag('kept_beans')),
            Choice('[SERVE WHAT YOU FORAGED]', 'forage'),
            Choice('[BACK DAVE’S SPONGE]', 'dave'),
            Choice('[SABOTAGE EVERYONE]', 'riot'),
          ],
        ),
        Scene.talk(
          'beans',
          say([
            'You open the tin. The smell comes out like a ghost. You warm the beans over a spirit stove, slowly, and spoon them onto a slice of toast you’ve burnt only a little. You put the plate in front of the judges.',
            'Nobody speaks. The Colonel picks up a fork with a trembling hand, and takes a bite, and puts it down. He covers his face. A tear runs along the line of his moustache.',
            '“Thirty years,” he whispers. “It’s exactly the same.”',
            'Chef Vane takes a bite. And, for the first time in twenty years, her face moves. “It’s... ordinary,” she says, in astonishment. “It’s just beans. It’s... it’s so... oh.”',
          ]),
          [Choice('[WAIT FOR THE VERDICT]', 'end_beans')],
          reward: const Reward(xp: 25),
        ),
        Scene.talk(
          'forage',
          (c) => [
            'You serve the best of what you found. It’s a strange, inventive mess: part glowing custard, part jam, part hope. The Chef tastes, nods, and says: “Competent.” The Colonel tastes, and says nothing.',
            if (c.flag('got_eggs'))
              'The egg hums as he chews. The tent goes uneasy. Big Tam leans in, quite impressed.',
            'It’s not enough. It isn’t a bad dish. It’s just not the dish.',
          ],
          [
            Choice('[BACK DAVE, THEN]', 'dave'),
            Choice('[LET TAM HAVE IT]', 'end_tam'),
          ],
        ),
        Scene.talk(
          'dave',
          say([
            'You step back and gesture at the sponge. “That one,” you say. “Taste that.”',
            'The judges look at the plain golden sponge as if for the first time. Chef Vane cuts a slice, and eats, and puts down her fork. Her face does something complicated. “It’s a sponge,” she says. “It’s perfectly, precisely, impeccably a sponge.”',
            'Dave blushes. He looks like he’s apologising to the cake.',
          ]),
          [Choice('[LET THE JUDGES DECIDE]', 'end_dave')],
          flags: ['backed_dave', 'carry.dave.bakeoff'],
        ),
        Scene.talk(
          'riot',
          say([
            'You step up to the table. You knock a trifle off the trestle. It lands on Madame Brioche. She screams. Big Tam, thinking this is part of the show, hurls Gerald. Sister Crumb ducks. The Colonel stands to attention. The whole tent erupts.',
            'A custard hits the ceiling. A tent pole gives way. By the time the dust settles, nobody is left standing but the crow, with a meringue, and a very small, very satisfied look.',
          ]),
          [Choice('[RUN]', 'end_riot')],
          flags: ['sabotaged_all'],
        ),
        Scene.end('end_beans', say([
          'The tent holds its breath. The Colonel stands, very slowly, and puts his medal on your plate. “I award the Golden Ladle,” he says, “to the only thing in this wasteland that tastes like somebody’s home.”',
          'The ladle is large, dented, a bit sticky. You hold it up and the tent cheers. Dave claps politely at the back. Madame Brioche weeps into her tarte and says it is the best loss she’s ever had. Big Tam eats his dish and the plate.',
          'Afterwards the Colonel finds you by the stove. “Thank you,” he says. “I’d forgotten.” He asks, very politely, if he might have the empty tin. You give it to him. He puts it in his breast pocket, over his heart.',
        ]), ending: 'beans'),
        Scene.end('end_dave', say([
          'The Golden Ladle goes to a man in an ordinary coat. Dave accepts it with a faint, apologetic cough. “I really didn’t do much,” he says. The judges clap, enormously, with enormous, bewildered emotion, and the moment he steps off the dais, nobody can remember what he looks like.',
          'You find yourself telling a stranger about it the next day. “A man won the bake-off,” you say. “Dave. He was... ordinary.” The stranger nods. “I think I was there,” he says. “I can’t picture him at all.”',
        ]), ending: 'dave'),
        Scene.end('end_tam', say([
          'Big Tam’s dish goes in front of the judges. Both of them take a bite. Both of them regret it. The Colonel is taken ill. The Chef goes a pale green and has to lie down on a tablecloth. Tam is awarded the ladle by default, since nobody else is left standing.',
          'He holds it up, with enormous pride. “For Gerald,” he says. And then, because he’s Big Tam, he eats it.',
        ]), ending: 'tam'),
        Scene.end('end_riot', say([
          'You leave the tent by the back flap, with a ladle you didn’t ask for tucked inside your coat. Behind you, the sounds of an increasingly desperate custard-based war.',
          '~You are going to regret this. But, on the other hand, it was a very good trifle.',
        ]), ending: 'riot'),
      ],
    ),
  ],
);
