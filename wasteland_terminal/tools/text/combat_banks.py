"""Combat flavour text. Per-weapon strike words, per-creature parts / reactions /
attacks / deaths, generic quips. {n} is left in place for the enemy's short name."""
from explore_banks import L

KINDS = ['bug', 'beast', 'pale', 'birds', 'sludge', 'golem', 'worm', 'machine', 'human', 'brute']

# ---- player attacks -------------------------------------------------------
WINDUP = L("""
You step in low
You set your feet and breathe out
You swing wide and a little late
Breath held, you commit
You snarl something unprintable
You feint left, then don't
You let the fear out as a shout
You pick your moment, then take it
You duck a clumsy lunge and answer
You wait for the stumble and pounce
You drive forward with your whole weight
You spin on your heel
You let instinct have the wheel
You grit your teeth and throw yourself in
You bait it, then punish it
Quick as a thought, you strike
You take one steadying breath
You close the gap in two steps
You slip past its guard
Without thinking, you swing
""")
SHOTOPEN = L("""
You brace the rifle against your hip
You squeeze the trigger
A flat crack rolls across the ruins
The pipe rifle bucks in your hands
You steady your breath and fire
You thumb the hammer back and let go
You aim low and trust the crude sights
You fire from the hip, because there's no time
A cloud of smoke and a hard bang
You work the action and shoot
The rifle roars in a pipe-and-powder voice
You hold your breath, and the shot breaks
""")
CUTOPEN = L("""
The cutter whines up to full heat
A white-blue lance leaps from the nozzle
You thumb the trigger and the air stinks of ozone
The plasma tool spits, then sings
The cutter flares and the dust jumps back
You sweep the cutter in a short, bright arc
The tool shrieks, rattling in your fist
A thin beam of impossible heat lances out
""")
WEAPON_NOUN = {
 'pipe': L("the pipe\nyour pipe\nthe rusted length of pipe\nthe heavy pipe"),
 'rpipe': L("the plated pipe\nthe reinforced pipe\nthe steel-wrapped length\nyour armoured pipe"),
 'machete': L("the machete\nyour blade\nthe scrap blade\nthe sharpened sheet-metal"),
 'rifle': L("the pipe rifle\nthe rifle\nthe crude rifle"),
 'cutter': L("the cutter\nthe plasma lance\nthe cutter's blue-white beam"),
}
STRIKE = {
 'pipe': L("cracks into\nhammers\nthuds into\ncaves in\nrings off\nsmacks across\nbashes\ndrives into"),
 'rpipe': L("pounds\ncrumples\nslams into\ncaves in\ndrives into\nbludgeons\nhammers down on\nflattens"),
 'machete': L("slices across\nchops into\nopens up\ndrags a bright line along\nbites into\nlays open\nhacks at\nskims"),
 'rifle': L("tears into\npunches a hole through\nclips\nfinds\nslams into\nscores a line across\nbites into\nruns through"),
 'cutter': L("sears through\nwelds shut\nburns a clean hole in\nscorches\nslices through\nlights up\nmelts into\nstitches a line across"),
}

PART = {
 'bug': L("carapace\nleg joint\nsensor cluster\ncan-lid plating\nunderbelly\nfront legs\nantennae\nsoft hinge"),
 'beast': L("flank\nribs\njaw\nshoulder\nscarred muzzle\nhaunch\nforepaw\nthroat"),
 'pale': L("spindly arm\njaw\nribcage\nskull\nknee\nclawed hand\nlong neck\nsunken chest"),
 'birds': L("outer wings\nragged edge\nblack heart\nnearest cluster\nfeathered mass\nbeating centre\nflock's flank\ntrailing stragglers"),
 'sludge': L("swollen neck\ndrum-hide belly\ngullet\ntentacle\ndripping jaw\nrusted shell\nbulging sac\nacid-slick skin"),
 'golem': L("scrap-plate chest\nsingle glowing lens\nelbow hinge\ntyre shoulder\nweld seam\nengine-block fist\nexposed cabling\nhip joint"),
 'worm': L("ringed flank\nthroat of teeth\nsoft segment\ngaping maw\nbanded back\nsand-caked hide\nfleshy lip\nwet inner ring"),
 'machine': L("optic\narmour seam\nservo\nexhaust vent\ngun mount\nhydraulic line\nsensor eye\ncracked casing"),
 'human': L("ribs\nknee\ngun hand\njaw\nshoulder\near\nthigh\nforearm"),
 'brute': L("blistered gut\nknuckles\nthick neck\nknee\nbrow\nflank\nswollen shoulder\nbare foot"),
}
REACT = {
 'bug': L("It chitters and scrabbles back.\nPlates split like dry bark.\nA leg folds under it.\nSomething wet and green leaks out.\nIt spins, clicking furiously.\nIt scuttles sideways, dragging a ruined limb."),
 'beast': L("It yelps, a nasty, almost human sound.\nIt backs off, hackles up, snarling.\nBlood spatters the dirt.\nIt scrabbles, regroups, and bares its teeth.\nIt shakes its head like a dog with water in its ears.\nThe snarl turns ragged."),
 'pale': L("It lets out a whispery shriek.\nIts jaw clicks sideways, wrongly.\nIt folds over the wound and hisses.\nPale skin splits and leaks something dark.\nIt recoils with unsettling grace.\nIt giggles, once, in pain."),
 'birds': L("A burst of black feathers fills the air.\nThe cloud ripples, then closes ranks.\nA dozen shrieks rise at once.\nWings beat the dust into a storm.\nThe flock scatters, then regroups, angrier.\nSomething small and broken tumbles down."),
 'sludge': L("It squeals and spits a bubbling gob.\nSomething inside it gurgles in protest.\nGreen ichor hisses on the ground.\nIt shudders, wobbles, and swells.\nIt gives a wet, offended burp.\nThe drum clangs hollow."),
 'golem': L("A shower of sparks lights the dust.\nMetal screams on metal.\nA panel clangs to the ground.\nIt staggers, then rights itself with a groan.\nA hissing jet of steam shoots out.\nIts lens flickers, offended."),
 'worm': L("It rears and roars, throat opening wide.\nA slick of dark fluid coats the sand.\nIt convulses, sending up a plume of grit.\nA rank, wet breath washes over you.\nIt thrashes, and the ground shakes.\nThe rings of teeth grind in fury."),
 'machine': L("Sparks leap from the wound.\nIt jerks, servos whining.\nOil sprays in a black arc.\nIts optic stutters from red to white.\nA warning tone repeats, getting faster.\nThe casing rings like a struck bell."),
 'human': L("It grunts and staggers, cursing.\nIt grabs the wound, eyes wide.\nIt spits blood and keeps coming.\nIt swears, a long, creative string.\nIt goes pale, but doesn't fall.\nIt takes a step back, breathing hard."),
 'brute': L("It bellows, and the air shakes.\nBlisters burst; steam hisses out.\nIt staggers, swinging wildly.\nIt roars something that was almost a word.\nIts mass shudders, and shrugs it off.\nIt lowers its head and glares."),
}
DODGE = {
 'bug': L("skitters sideways just in time\nclicks away on needle legs\nflips onto its back and flips up again"),
 'beast': L("twists away with a snarl\nleaps out of reach\ndrops low and slides under it"),
 'pale': L("folds itself aside, too smoothly\nbends in a direction bones shouldn't\nslides back into the shadow"),
 'birds': L("breaks apart and re-forms elsewhere\nscatters like smoke\nlets the strike pass through the gaps"),
 'sludge': L("wobbles aside in a quivering heap\nflinches into its shell\nsloshes out of the way"),
 'golem': L("sways its bulk aside, surprisingly nimble\nraises a heavy arm and deflects\nshrugs it off against a plate"),
 'worm': L("sinks into the sand and reappears\nrears back, swaying out of reach\nflexes its great length and dodges"),
 'machine': L("whirs aside on shrieking servos\ntilts its plating into the blow\nglides back, tracking you"),
 'human': L("ducks and curses\nbacks off, grinning\nrolls aside, swearing"),
 'brute': L("lurches aside with surprising speed\nbats it away with a thick forearm\nsteps back, grinning stupidly"),
}
MISS_MELEE = L("""
Your swing wastes itself on empty air.
You stumble as your weight carries you past.
Your weapon rings off a rock instead.
For a heartbeat you are wide open.
You overcommit, and the world swings by.
The strike glances off and jars up your arm.
You swing, and the wind is all you hit.
Your boots slip in the dust and the blow goes wide.
The blow lands where it just was.
You grunt with effort and hit nothing at all.
""")
MISS_RANGED = L("""
The shot whines off into the ruins.
Your aim is true. The target, unfortunately, isn't there.
A puff of dust marks where you should have hit.
The round chews a chunk out of a wall instead.
You squeeze, you miss, and the echo laughs at you.
Your shot clips a rusted sign and goes ringing away.
The bang rolls off. The enemy does not seem moved.
Somewhere behind it, a distant window finally breaks.
""")
MISS_CUTTER = L("""
The beam sizzles through empty air and scorches the dirt.
The cutter shrieks, cutting a bright, useless line.
A hot wire of light slashes past, an inch wide of its mark.
Plasma crackles, then fizzles, the mark unharmed.
You sweep the cutter and carve a lovely arc in the nothing.
""")
ENEMY_MISSVERB = {
 'bug': L("skitters past you and overshoots\nstabs at the dirt where you were\ntangles its own legs and flails"),
 'beast': L("snaps at empty air\nleaps, and lands in your dust\nlunges short, and growls about it"),
 'pale': L("claws at where your head was\nlunges, and folds into its own shadow\nreaches out and finds only air"),
 'birds': L("swarm past and rake nothing\nswoop and miss, shrieking\nwheel in a black spiral and re-form"),
 'sludge': L("spits a gob that sizzles in the dirt\nlashes a tentacle that slaps the ground\nlurches and slops, missing you"),
 'golem': L("swings a massive fist and punches a crater\nstomps and shakes the ground, short of you\nlunges with a groan of metal and misses"),
 'worm': L("surges out of the sand, jaws closing on air\nsmashes down beside you\nlunges, and takes a mouthful of grit"),
 'machine': L("fires a burst that stitches the wall behind you\nlocks on a moment late\nspins its turret in a spray of sparks"),
 'human': L("swings and curses as you duck\nfires wide and hisses through its teeth\nlunges and stumbles over its own feet"),
 'brute': L("swings a fist that would have ended a bus\nlunges, and the blow hits only dust\nstomps, bellows, and misses"),
}
ATTACK = {
 'bug': L("skitters up and stabs\nrakes a knife-sharp leg across\nclicks and clamps onto"),
 'beast': L("sinks its teeth into\nbarrels in and rakes\nleaps, snarling, and rips at"),
 'pale': L("slides in close and rakes\nclamps long fingers around\nlunges out of the shadows and slashes"),
 'birds': L("swarms in and tears at\npecks and claws at\nlashes whirling wings across"),
 'sludge': L("spits a burning gout across\nlashes a slimy tentacle around\nbelches acid over"),
 'golem': L("swings a girder-heavy arm into\nslams a fist into\nbears down with its whole weight on"),
 'worm': L("surges out of the sand and bites\nsmashes a ringed body into\nsnaps its jaws shut around"),
 'machine': L("stitches a burst across\nfires a hot, white bolt through\nslams a piston arm into"),
 'human': L("swings a pipe at\nfires a handful of rounds into\ndrives a knife into"),
 'brute': L("pounds a ham-sized fist into\nsmashes a swinging forearm across\nbarrels in and crushes"),
}
BODYPART = L("""
your arm
your shoulder
your ribs
your thigh
your side
your calf
your back
your hip
your forearm
your hand
""")
PAIN = L("""
White heat blooms.
You taste copper.
Your vision swims for a second.
You grit your teeth around the sound you almost made.
It stings, and then it really stings.
The world narrows to the pain.
You stumble, and catch yourself.
Warm blood runs, and you ignore it.
Your breath catches, then returns.
That is going to leave a mark.
""")
DIE = {
 'bug': L("The {n} curls its legs and goes still, ticking as it cools.\nThe {n} crunches into a pile of sad scrap.\nThe {n}'s eye dims, and a leg twitches once more."),
 'beast': L("The {n} gives a last wet wheeze and goes quiet.\nThe {n} slumps, and the growl dies in its throat.\nThe {n} falls, whining, and then silently."),
 'pale': L("The {n} folds in on itself and does not rise.\nThe {n} lets out a long, thin sigh and is still.\nThe {n} crumples, small and strange in death."),
 'birds': L("The flock tumbles to the ground in a patter of feathers, silent.\nThe {n} comes apart, and the black cloud becomes a drift of wings.\nThe last of the {n} wheels once, and drops."),
 'sludge': L("The {n} slumps and collapses with a long, wet fart.\nThe {n} bursts and steams away into the dirt.\nThe {n} gives a last gargle and sags into its drum."),
 'golem': L("The {n} sways, then comes down in a landslide of scrap.\nThe {n}'s lens dies like a snuffed candle.\nThe {n} topples with the roar of a collapsing garage."),
 'worm': L("The {n} thrashes, then slumps into the sand like a punctured hose.\nThe {n} sinks, lifeless, and the dunes go still.\nThe {n}'s great maw drops open and stays open."),
 'machine': L("The {n} judders, spits sparks, and clunks into silence.\nThe {n}'s optic fades from red to black.\nThe {n} lets out one long, low tone, then none."),
 'human': L("The {n} falls and does not get up.\nThe {n} drops, swearing weakly, then not at all.\nThe {n} sinks to its knees, and keeps going down."),
 'brute': L("The {n} sways like a felled tower, then goes down hard.\nThe {n} bellows once more and falls forward.\nThe {n} collapses, and the ground thumps to mark it."),
}
AFTER_FIGHT = L("""
You wait until your hands stop shaking.
Silence rushes back in, rude and sudden.
You wipe your weapon on your sleeve and breathe.
Dust settles over everything as if nothing had happened.
You find you're grinning, then wonder why.
Your pulse takes a long time to remember how to be quiet.
You thank no one in particular.
You pick through the mess for anything worth keeping.
You look around. Still alone. Good.
You will definitely feel that in the morning.
""")
CRIT = L("""
A perfect strike, right where it hurts.
You find the gap in its defences.
The blow lands with a wet crack. You feel it in your teeth.
Instinct takes over: a shot you could never have planned.
Time slows, and your aim doesn't.
Right on the money, and then some.
It never sees it coming.
Every bit of luck you've ever hoarded cashes in at once.
The world holds still, and so do you, and then you don't.
You hit it where it counts, and the whole thing knows it.
You'll be telling this one in your head for days.
That is the cleanest hit of your life.
""")
STIM = L("""
The needle bites, and warmth floods your veins.
You jam the stimpack home. The pain thins, then steps back.
Chemical fire spreads through you. Your hands stop shaking.
Something bitter and bright rushes through you.
You hiss through your teeth as the stim does its work.
The world's edges snap back into sharp focus.
For a moment you feel nearly invincible. It passes. You keep the shape of it.
Your heartbeat slams once, hard, and settles.
Muscles you'd given up on remember their job.
""")
DEFEND = L("""
You drop low and tuck your guard in tight.
You plant your feet and make yourself a smaller target.
You hunch behind your weapon and brace.
You cover up and wait for the worst.
You breathe, set your jaw, and take the stance.
You crouch behind what cover your arms can give.
You pick a spot to look at, and a way to survive.
You tuck your chin and grip your weapon like a promise.
""")
ESCAPE_OK = L("""
You bolt, and the wasteland swallows you.
You dive behind a wall and keep running until your lungs complain.
You break away and don't look back.
You give them nothing to chase and slip away.
Boots pounding, you put distance between you and trouble.
""")
ESCAPE_FAIL = L("""
You try to run. It runs faster.
Your foot catches on something, and the chance slips away.
You bolt, and cut yourself off in a dead end.
You feel its breath on your neck, and think better of fleeing.
Not this time. You're boxed in.
""")

# whole-line absurd / surreal interjections (shown now and then between rounds)
QUIPS = L("""
A pigeon lands on a nearby pole and watches the fight with open contempt.
Somewhere, a very small bell rings, for no reason anyone will ever explain.
A tumbleweed rolls through the middle of everything and does not apologise.
You could swear a nearby cactus just shrugged.
A paper bag dances across the ground, with enormous dignity.
Far above, a plane that is definitely not there leaves a perfectly white trail.
Someone, somewhere, is playing a trumpet badly. It adds a lot.
A single balloon drifts past, uninterested.
The sun picks this exact moment to come out from behind a cloud and have an opinion.
A nearby crow tilts its head, as if judging your technique.
Your stomach growls. Now. Of all times.
There's a faint smell of toast. It makes no sense and ruins your concentration.
For a second you hear applause. It was the wind. Probably.
A bit of rubble tumbles from a ruin and lands with great, meaningful timing.
A distant dog barks a single, supportive bark.
Somewhere in the dust, a coin rings and rolls away.
A fragment of old radio shouts "GOAL!" and promptly dies.
Your shadow flinches. Your shadow is a coward.
You are very aware of your own breathing, and the awkward rhythm of it.
A scrap of paper flutters by, announcing a sale that ended decades ago.
A wasp, impossibly, buzzes through. Nobody has time for it.
A rusted sign creaks, "WELCOME", slow and hopeful.
You have never felt so seen by a lizard.
A tin can rolls in a slow circle, finishing a thought of its own.
The wind carries the words "NO REFUNDS" from far away.
Your boot laces, undone, choose this moment to become a plot point.
Somewhere an alarm rings, tired and half-hearted.
A faraway door slams, as though in disapproval.
You trip on an absolutely nothing and recover with an air of intent.
A chandelier, miraculously, tinkles in a nearby ruin.
For a second, everything smells of birthday cake.
The ground hums faintly with a bass line you can't place.
A rusted weathervane swings to point at you, specifically.
You note, as a purely technical matter, that this is a very strange place for a fight.
A small stone skips off a wall and rolls, ticking like a clock.
A sheet of tin falls over, taking its time.
A distant voice yells "OI!" and then thinks better of it.
Your pack rattles, then, plaintively, clinks.
A tiny, optimistic flower pushes up through the dust and has terrible timing.
A very large moth lands on your shoulder, considers the situation, and leaves.
The wind whistles a few bars of something familiar. You hate that you recognise it.
A mannequin hand in the rubble gives you a thumbs-up. You decide it's a trick of the light.
Birds, high above, circle once and wait.
Somewhere, someone says "Hold my drink", very faintly.
You feel an overwhelming wish for a sandwich, and an overwhelming guilt for it.
The shadows grow long, then think better of it.
A broken streetlight flickers on for exactly one second, in solidarity.
A hubcap rolls past, upright and unbothered.
You do not remember agreeing to this.
Your reflection in a shattered window looks like it'd rather be elsewhere.
A paper plane glides past. Who made that? When? How? You'll never know.
The air smells of old pennies, and something about it makes you braver.
Somewhere a goat bleats. A goat. Here. Never mind.
A single snowflake of ash lands on your nose, with great ceremony.
A sock, entirely unconnected to anything, lies in the dirt.
You are 97 percent sure that wasn't there a minute ago.
A hazy rainbow arcs over the ruins, just to be cruel.
A tiny voice in your head says "ooh, shiny", at completely the wrong moment.
A voice in the distance says "Is this thing on?" It's a long way off. It's a lot of confidence.
You have the strange feeling you're being filmed.
A rat on a rooftop salutes, ironically.
The wasteland offers a moment of silence for whoever loses.
A cloud passes over the sun in the exact shape of a duck.
The distant "bong" of a church bell tolls an off-hour.
A leaf, impossibly, drifts down from a tree that does not exist.
A line of ants marches past, uninterested in violence.
A gust of wind sets a thousand cans clinking, like a tiny, tinny orchestra.
A frog croaks, from nowhere, and then thinks about it.
You catch yourself thinking, absurdly, about trousers.
A scrap of newspaper wraps itself around your ankle and then un-wraps, embarrassed.
A stray shopping trolley rolls by, with the grace of a ship.
Somebody left a toaster here. Why? You will never know, and you'll think about it for a month.
A bored vulture lands, then looks at its watch.
You blink, and for a moment the whole scene is just a painting of a fight.
A kettle whistles, far away. You are overcome with sorrow.
The air tastes like pennies and old thunder.
A lonely wind chime, somewhere, plays a note of encouragement.
A distant voice, very quietly: "Told you."
A dust devil walks off with a sun hat.
You glance at the sky for help. The sky has no comment.
There's a smell of burnt toast and a faint, creeping dread.
An old song floats from a broken speaker, three notes long, then stops.
Your knees file a formal complaint.
A weathered scarecrow, in the distance, tips its hat.
Nobody is going to believe this. Nobody is here to not believe it.
You develop, briefly and intensely, a theory about ducks.
A pebble rolls to a stop at your toe, and you take it as a sign.
A magpie steals something shiny from the fray and leaves with it.
The hairs on your arms rise, for no reason except that the world is odd.
A fly lands on the enemy's nose. Everyone pauses. The fly leaves.
Something in your pocket purrs, then doesn't, then you check, and it's nothing.
You hum a little battle tune to yourself, mostly in the wrong key.
It occurs to you that this will make a very bad bedtime story.
A cracked clock, nearby, strikes thirteen.
A bubble of old chewing gum pops somewhere. You hope it was gum.
The ground trembles slightly. It's far away. It's far away, you tell yourself.
Your boot squelches. You really don't want to know in what.
You catch your breath and your own eyes in a puddle, briefly.
A bat darts overhead, daytime, panicked, entirely wrong.
A small, hairy spider crosses the battlefield with grim determination.
You hear, very faintly, someone sobbing a song you used to know.
A loose shutter bangs three times and everyone pretends not to notice.
Someone's laundry is still hanging on a distant line, defiantly.
There's a little yellow flower in your path. You carefully step around it. Mid-fight. Why.
""")
