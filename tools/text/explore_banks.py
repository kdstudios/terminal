"""Exploration flavour text: slot banks + sentence templates. {slot} fills from a
bank; {slot^} capitalises the first letter. Edit freely: tools/gen_flavor.py turns
this into lib/game/flavor_gen.dart."""

def L(s):
    return [x.strip() for x in s.strip().split('\n') if x.strip()]

THING = L("""
a bus folded in half like a sandwich
a vending machine lying face-down
a shopping trolley full of bleached stones
a child's tricycle with one wheel missing
a wedding dress hanging from a lamppost
a line of shoes, neatly placed, owners absent
a wrecked ambulance with its siren still wired on
a stack of tyres taller than a house
a statue of someone important, head missing
a billboard promising a better tomorrow
a fridge standing alone in the road, door open
a church bell lying in a crater
an overturned tanker, long since drained
a grand piano, keys fused into one lump
a dentist's chair bolted to nothing
a crashed crop-duster stuck nose-first in the dirt
a roundabout with a rusted car on every exit
a flagpole with a few grey threads still clinging
a swing set, one swing swaying
a carousel horse, mid-gallop, rotting
a row of mailboxes, all stuffed with ash
a petrol pump with the hose coiled like a sleeping snake
a bank vault door lying flat in a field
a fire hydrant painted to look like a dog
a library with its shelves open to the sky
a motel sign missing every letter but the V
a washing machine full of rainwater and frogs
a tractor sunk to its axles in black mud
a lifeguard chair on a beach of cracked clay
a train carriage perched on a bridge it never crossed
a mannequin in a bus shelter, waiting patiently
a skeleton at a steering wheel, hands still ten-and-two
a campervan with a "Gone Fishing" sticker
a satellite dish pointing at nothing
a dead tree wearing a crown of wire
a roadside diner with the lights somehow on
an ice cream van playing no music
a collapsed footbridge over a dry river
a parking meter still demanding payment
a toy robot sitting upright in the gutter
a mattress folded around a streetlight
a phone box with the receiver off the hook
a cathedral window standing alone, glassless
a row of burnt-out cars, bumper to bumper
a crane frozen mid-lift, its load long gone
a hot-air balloon draped over a ruined mall
a wheelchair at the top of a staircase
a skeletal horse made of rebar and wire
a barber's pole, still faintly red
a cinema marquee reading only "NOW SHO"
a school bus full of birds' nests
a rowing boat, miles from any water
a cash machine with a hand-written "SORRY"
a laundromat with every dryer door open
a stop sign pointing at a sunset
a crashed helicopter with its rotor on the roof of a house
a garden gnome, unaccountably pristine
a cracked globe on a pedestal
a bicycle chained to a signpost, tyres gone
a tent city of faded blue tarps, empty
a gas mask hung on a fence post like a trophy
a statue of a dog, patient and green with age
an escalator going nowhere, forever
a hospital bed in the middle of the road
a prefab hut with a door painted cheerful yellow
a sack of cement set hard in the shape of its sack
a radio mast bent like a drinking straw
a rocking chair on a porch with no house
a gun turret grown over with vines
a coffee machine in an open field
a canoe nailed to a wall
a monument to a battle nobody remembers
a bathtub half-buried in the roadside
a ferris wheel with one gondola missing
a slab of concrete scrawled with "WE WERE HERE"
a snack kiosk, shutters rusted open
a pram, empty, parked very carefully
a drum kit sitting in a puddle
a cargo container with a door that has been painted over
a toppled water tower resting like a tired giant
a motorbike leaning on its stand as if its rider just stepped away
""")

WHERE = L("""
beside the road
in a ditch of black water
half-buried in ash
pinned under a fallen billboard
at the foot of a dead streetlight
wedged in a doorway
in the middle of the road, as if waiting
on a hill of rubble
next to a cracked fountain
against a wall of faded graffiti
under a sky the colour of an old bruise
where the road forks for no reason
beyond a field of rusted fences
past a row of hollow shopfronts
by a puddle that shimmers the wrong colours
across a bridge that has given up
on the crest of the next rise
tucked behind a wall of tyres
beside a signpost with all its arrows snapped
at the edge of a crater
among the weeds, tall as your hip
inside the shell of a bus shelter
in a car park painted with faded bays
under the long shadow of a pylon
beyond the last working streetlight
in a patch of unnatural green
over a drift of grey, powdery snow
where the pavement turns to glass
on what used to be someone's lawn
along a fence strung with bones and bottles
in the lee of a ruined overpass
perched on a heap of broken bricks
under a bridge that hums in the wind
next to a mailbox shaped like a fish
along a gutter full of silver dust
right where the road should have been
at the bottom of a drained swimming pool
just off the path, almost hidden
behind a shattered shop window
hard against a collapsed wall
in the shade of a leaning pylon
""")

DETAIL = L("""
its paint peeled in long curls
someone has stacked stones on it, carefully
the wind makes it sing one flat note
a tiny garden of weeds grows from its engine
it looks almost new, which is worse
it has been picked clean by people better at this than you
there are claw marks down its whole length
a crow watches you from it and does not leave
somebody wrote a name on it, and then a date, and then a second name
it ticks softly as it cools, though nothing has run in years
there's a handprint in the dust, smaller than yours
it leans at an angle that suggests a long, slow decision
the sun has bleached the lettering to a whisper
rust has eaten a perfect lace pattern through it
a line of ants carries something small and bright across it
a faded sticker still insists it is "NEW!"
the whole thing smells faintly of pine, impossibly
there's a bullet hole straight through the middle, neat as a punch
moss has taken one side and left the other alone
a child's drawing has been scratched into the paint
there are old footprints around it, all walking the same way
it seems to be watching, which is nonsense
it creaks in a way you'd rather not look into
the glass is gone, but the frame is still polite about it
something nested in it and left in a hurry
it is warm to the touch, for no reason you can name
it has a coat of fine grey dust, undisturbed
a faded ribbon is tied to it, still red at the knot
the lock was cut a long time ago
a single glove sits on top of it, fingers curled
what's left of the label reads only "HANDLE WITH"
it is much bigger than it looks from the road
the edges have gone soft, like sugar left in the rain
someone has tried to repair it, badly, with wire
it's the only straight line for a mile
it casts a shadow that seems a little too long
the ground around it is strangely clean
a thin trickle of something dark runs from underneath
it hums when the wind drops, then stops when you listen
you can still make out a smiley face on it
there's a coin glued to it, heads up
a bird has built something elaborate in its ribs
it looks like it was beautiful, once, to someone
the lichen has made a map on it of somewhere that doesn't exist
a single shoe sits beside it, laces still tied
it's covered in tally marks, hundreds of them
somebody sat here a long time, judging by the dent
it clinks quietly, though nothing is touching it
it has been scorched in one clean stripe
it's exactly where you'd put it if you wanted it found
a streak of faded blue runs through the rust
the sound of the wind changes as you pass it
""")

SIGHT_T = L("""
{thing^} {where}, {detail}.
You pass {thing} {where}. {detail^}.
{where^}, {thing}. {detail^}.
Ahead: {thing}. Up close, {detail}.
{thing^}. {detail^}. You keep walking.
Something catches your eye {where}: {thing}.
{thing^} {where}. You give it a wide, polite berth.
You almost walk past {thing} {where}. Then you notice that {detail}.
{rthing^}. {detail^}.
{rthing^} {where}, and {detail}.
A little way off, {thing}. {detail^}, you realise.
The road bends and there it is: {thing}. {detail^}.
{thing^}. Whoever left it there had a reason, once.
{thing^} {where}. {rdetail^}.
You stop for a moment at {thing}. {detail^}.
{rthing^} {where}. {detail^}.
Out of the haze: {thing}. {rdetail^}.
{where^}, you spot {thing}. You decide not to touch it.
It takes you a moment to recognise {thing} {where}. {detail^}.
{thing^}, {where}. The scene has the stillness of a held breath.
""")

# region-specific (index matches world.dart regions): things and details
RTHING = [
 L("""
a long, straight ribbon of cracked asphalt
a petrol station with its roof folded over the pumps
a convoy of cars, all pointing the same direction
a roadside motel with a pool full of dust
a truck stop sign: EAT, GAS, FORGET
a mile marker reading a number that no longer means anything
a line of telegraph poles marching into the haze
a motorway bridge with a sedan still balanced on the edge
"""),
 L("""
a factory chimney leaning on its neighbour
a warehouse of rusted shelving, row on row
a rail yard where the carriages have all gone red
a crane graveyard, jibs crossed like swords
a scrapyard stacked in neat, hopeless towers
a pipe-works with tangled steel arteries
a conveyor belt that vanishes into a wall
a water tank pierced by a hundred shots
"""),
 L("""
a plain of dark glass, rippled like frozen water
a bowl of fused sand with a charred tree in the middle
a skyline of black glass spikes
a road that ends abruptly in molten stone
a flattened suburb, outlines of rooms still etched in the ground
a ring of melted cars, nose to nose
a silent crater, wide as a stadium
the long shadow of something that was once a tower
"""),
 L("""
a flooded street, rooftops rising like islands
a swing set standing in knee-deep green water
a kitchen with a table still set for dinner, under an inch of silt
a row of houses all leaning the same way
a front garden of tall reeds and a bobbing letterbox
a school with its gym turned into a pond
a car half-sunk in a driveway, headlights green with algae
a suburban cul-de-sac, quiet as a held breath
"""),
 L("""
a ship's hull rusting in a dry field
a stack of crushed cars, ten high
a plane wing cut in half by something unthinkable
a tank turret on a hill, barrel pointed up
a wall of scrap armour, riveted and patched
a drone graveyard, hundreds of dead rotors
a barbed-wire fence with something huge snagged on it
a bunker mouth with the blast door ajar
"""),
 L("""
a ridge of grey ash, smoothed by wind
a cairn of blackened bricks, taller than a person
a communications dish twisted like a petal
a switchback trail lined with snapped pylons
an observation tower with no stairs left
a stand of dead pines, silver in the dust
a lookout point with a coin telescope that still turns
a ski lift chair, swinging above nothing
"""),
]
RDETAIL = [
 L("""
the road shimmers as though it's still hot
a thousand tyre tracks cross it and none of them lead back
the white lines have become a rumour
heat haze makes the horizon dance
"""),
 L("""
the air tastes of old oil
every surface has a rime of orange rust
something far inside it still ticks and clanks
a flock of crows treats it like a cathedral
"""),
 L("""
the glass underfoot sings faintly with each step
the light bends strangely off every surface
your shadow looks sharper here, somehow
the horizon is flat as a table
"""),
 L("""
frogs go quiet as you pass, then start again
the water reflects a sky better than the real one
everything is soft with moss and damp
something small slips beneath the surface as you look
"""),
 L("""
the metal is warm, as if it just finished working
the wind carries a thin, steady whine
everything is lined up in rows, neat and wrong
shadows lie across the ground like fallen soldiers
"""),
 L("""
every footstep puffs up a small grey cloud
the air is thin and cold and smells of cinders
you can see for miles, and none of it is alive
the wind never quite drops
"""),
]

WONDER = L("""
who used to live here
whether anyone is still looking for you
if the old world ever really worked, or whether we just remember it kindly
what the sky looked like before
how many people walked this exact road
if the stars are still up there behind all that ash
whether the radio is a person or a recording of a person
how long a tin of beans really lasts
what you'd say if you met your younger self out here
whether the birds know something you don't
how far the road goes, and whether it's meant to end
if anywhere is still quiet in the good way
what the last person to sleep here dreamed about
who decided to leave the lights on
whether you'd recognise safety if you saw it
whether the dust remembers every footprint
what your first meal will be when this is over
if there's a map somewhere with all of this on it
whether the big silent buildings are waiting or just tired
why the weeds always win
whether kindness counts if no one sees it
what happened to everyone's cats
how many of these cars someone loved
if it was one terrible day, or just a lot of small ones
who is out there, and whether they're better at this
whether the horizon is getting closer or you're getting slower
how long a pair of boots is supposed to last
what the first person to pick this road was running from
if there's a version of you that stayed home
whether the sun is tired too
why you always think about soup out here
what the people who survived the worst did next
if hope is a skill or just a habit
if the wind has a destination
how many hands touched this before it was left
if every ruin was once someone's favourite place
what you'd do with a single hot shower
if you're getting closer to something, or just further from everything else
where the sound goes when it stops
whether anyone ever finished a crossword in this place
whether there's a name for how quiet it is
""")

OBSERVE = L("""
how loud your own footsteps get when nothing else is moving
how every ruin looks smaller up close
that the silence has a texture, like thick cloth
that your shadow is the only company that's stayed
how the wind carries sounds that shouldn't carry
how quickly a place stops being a place and becomes a shape
that the sky never quite makes up its mind
how a straight road feels longer than a winding one
that you've started talking to yourself, and you quite like the answers
how an empty shoe is the saddest thing, somehow
that the smallest things survive: buttons, coins, marbles
how every wall has someone's handwriting
that rust is just the world slowly taking things back
how hungry you get when you're being brave
that hope looks a lot like a thermos of something hot
how the light goes gold just before it goes grey
that old paint is oddly cheerful
how every gate seems to hang open on purpose
how dogs, wherever they are, leave the best tracks
that you can tell a lot from a well-worn path
how a dead engine still looks like it's about to start
that the wind is polite until it isn't
how it's always the left boot that fails first
how every house has one room that wasn't touched
how a pause can be louder than a shout
how the dust settles differently around things that mattered
that people save the strangest things
that being alone is easier than being lonely
that every ruin has one thing that survived out of spite
how the dead trees look like handwriting against the sky
""")

MEMORY = L("""
the smell of rain on a hot road
a kitchen with a yellow light and someone humming
the sound of a screen door slapping shut
a warm blanket straight from the dryer
your name shouted from the bottom of a staircase
the taste of an orange eaten in a car
a radio playing in another room
somebody's laughter, with no face attached
a school corridor on the last day of term
the colour of the sky just before the first snow
a street party, bunting everywhere
a hand holding yours in a crowded place
birthday candles and the long second before the wish
a train window, and the fields going by
the creak of a particular stair
the feeling of being carried to bed
a porch light left on for you
the tinny jingle of an ice cream van
a long, lazy afternoon with nowhere to be
the weight of a sleeping dog across your feet
the sound of a football against a wall
the smell of fresh bread, even though you can't place it
a conversation you didn't know was the last
a tangle of fairy lights, half of them working
the way somebody used to say goodnight
a quiet library, dust in the sunbeams
a swimming pool at dusk
the exact sound of a kettle coming to the boil
a favourite song, and who it belonged to
a lift, and the hush before the doors open
""")

AFTER = L("""
It doesn't help.
You hold onto it as long as you can.
You let it go.
Then the wind changes and it's gone.
It stings more than you expected.
You smile, and it surprises you.
Odd, the things that stay.
You file it away for a worse day.
That version of the world feels like a rumour.
You keep walking, a little lighter, a little sadder.
You're not sure whether it's a gift or a wound.
The road swallows the rest.
""")

MUNDANE = L("""
Your left boot has a hole. You've named it Gerald.
You've been walking so long your legs have started voting on alternatives.
You wonder if your shadow gets tired of copying you.
You'd trade a great deal for a cup of tea. Not good tea. Any tea.
You count your steps. You lose count. You count again.
You rehearse an argument with someone who isn't here, and you win.
You notice you've been humming. You don't know the song. It's very sad.
Your pack strap has found your one sore spot and made it a home.
You try whistling. The wasteland doesn't whistle back.
You find a pebble in your boot and give it a small funeral.
You decide, once again, that you are definitely not lost. Just exploring.
You remember you forgot to feed someone, years ago. You hope they forgave you.
You wonder if running out of things to think about is a kind of peace.
You'd really like a chair. A good one. With arms.
Your stomach makes a noise like a bad omen.
You walk to the rhythm of an old advert you can't stop hearing.
Somewhere in your pack is a sock you've never seen before.
Your canteen sloshes in a way that sounds smug.
You practise your confident face for no one.
You promise yourself a bath. You've promised it a lot.
You wonder what the wasteland would do if you just sat down and refused.
You wonder how many times the word "nearly" has saved your life.
You think about biscuits for an unreasonable amount of time.
Your hands remember a keyboard. Your fingers drum on nothing.
You talk to a rock. It doesn't say anything. You respect that.
You're pretty sure you've walked past this exact bush before.
You realise you haven't blinked in a while and make up for it.
You count how many different greys there are. Thirty-one, so far.
There's a rhythm to walking. It's almost like thinking, without the worrying.
You wonder if anyone would notice if you changed your name here.
""")

ABSURD = L("""
You briefly believe a cloud is following you. It isn't. It might be.
A tumbleweed rolls past with deep purpose. You wish it well.
You'd swear that lamppost just winked. You choose not to investigate.
You have the sudden, certain feeling that someone is about to say "Cut!"
You find yourself composing a strongly worded letter to the weather.
You wonder what a seagull would make of all this. Then you wonder where the seagulls went.
You think of a joke so good you're certain it was invented by a dead civilisation.
You are, for a few moments, completely convinced you left the oven on.
You walk past a sign that says "WELCOME". You feel welcome. You feel suspicious.
You pat your pockets for a phone you haven't owned in years. Habit is a strange creature.
A thought arrives, unannounced: "What if all the ducks were in on it?"
You wonder if there is a museum, somewhere, and whether you're in it.
You start naming the clouds. This one is Kevin.
You've gone so long without a mirror you're willing to believe you look great.
Somewhere, a sandwich is being made. You can feel it. It haunts you.
You feel a deep, irrational loyalty to the next dead tree.
You consider declaring yourself mayor of this particular hill.
Your stomach grumbles in what is definitely a key change.
You suddenly desire a pickle with a fervour that frightens you.
You think of every chair you've ever sat in. It takes a while.
You have the nagging feeling a very small man is steering your decisions.
You wave at a crow. It does not wave back. It will remember this.
Your pack clinks in a way that sounds suspiciously like applause.
For one dizzy second you can't remember what a door is for.
You wonder if all those missing socks ended up somewhere nice.
Your reflection in a puddle looks disappointed. You apologise to it.
You realise you're walking in time with the wind and speed up to annoy it.
You imagine a heroic soundtrack. It's mostly a kazoo.
You think about the first person who ever tried an egg and feel strangely proud of humanity.
You are suddenly, vividly aware of your own elbows.
""")

PHILOS = L("""
A ruin is just a story that stopped telling itself.
Maybe the point of surviving isn't the survival, it's who's beside you.
You can carry a lot, if you stop carrying the right things.
The world doesn't end. It just changes the people who get to live in it.
There's a kind of freedom in having nothing left to lose but the next hour.
Every road is somebody's decision, still.
You were taught that the world was fragile. It turns out it was only polite.
Everything you pick up is someone's former everything.
You can't outrun the past, but you can out-walk it, a little.
Some silences are for listening. This one is for leaving alone.
It is a strange mercy to forget the order of things.
There is no map for this. There are only your two feet and a decision.
You only truly have the stretch of road you're standing on.
To be missed is a kind of survival.
Maybe a ruin is just a house that finished being needed.
The sun still rises. That's not a promise. That's a habit.
""")

THOUGHT_T = L("""
You wonder {wonder}.
Not for the first time, you wonder {wonder}.
{wonder^}? You'd rather not think about it, and you do anyway.
You find yourself wondering {wonder}.
Out here, it's hard not to wonder {wonder}.
You notice {observe}.
It occurs to you {observe}.
Funny, {observe}.
You can't help noticing {observe}.
You remember {memory}. {after}
Out of nowhere you remember {memory}. {after}
{memory^}. That's the thing you find yourself thinking about. {after}
{mundane}
{mundane}
{absurd}
{absurd}
{philos}
""")

FARAWAY = L("""
Far to the east
Somewhere behind you
Beneath your feet
From inside a collapsed wall
A long way off
Just beyond the next ridge
From somewhere inside a hollow building
High overhead
Down in a drainage ditch
On the wind
Close, then suddenly far
From the other side of the road
In the walls of a nearby ruin
Across the flats
Out in the haze
From a place you can't see
From a pile of rubble to your left
Inside a rusted tank
""")
SOUNDTHING = L("""
a door slams, over and over, with no one to close it
something heavy shifts and settles
metal groans like a distant, dying whale
a dog barks three times, then thinks better of it
a siren winds up, and stops, as if embarrassed
a chain drags slowly over concrete
a thin whistle runs through a broken pipe
glass trickles down a pile of rubble with a sound like rain
a bird shrieks once, a very human sound
a radio hisses a single, sharp word, then nothing
a faint, rhythmic tapping, like a patient fingernail
a gate swings on a hinge that needs oil and mercy
a hollow boom echoes through a drained reservoir
the wind plays an old bottle like a flute
a steady, mechanical clicking starts up and stops
something small scurries through dry leaves
a faraway engine coughs once and dies
a bell rings, soft and off-key
a long, low groan rolls through the ground
a child's laughter, thin and probably the wind
a tarpaulin snaps and cracks like a whip
distant thunder with no storm to go with it
a power line sings an unfinished chord
dry grass whispers like a crowd that has just fallen quiet
something falls, bounces twice, rolls away
a rusted weathervane squeals round and round
wings, many wings, then silence
a faint echo of a song you almost know
a creak, then a long, long pause
a single, slow footstep that is not yours
a stray gust makes a whole building hum
wet, sticky footsteps in the next street
the chink of a coin rolling in a drain
a distant, dull thud, like a very large door closing
the crackle of something burning where there should be nothing
a mechanical whirr spins up, considers, and spins down
the wind slides under a sheet of metal and makes it moan
gravel pours down a slope in a thin hiss
a rattle of loose stones, and then nothing at all
an electrical buzz stutters through the dusk
""")
SOUND_T = L("""
{faraway^}, {soundthing}.
{faraway^}, {soundthing}. You stand very still for a moment.
{faraway^}, {soundthing}. You walk a little faster.
You hear it before you see anything: {soundthing}.
{faraway^}, {soundthing}. Then, just silence.
{soundthing^}. You decide it's the wind. You decide firmly.
""")

SMELL = L("""
burnt plastic and wet ash
rust, and under it, something sweet
old rain on hot stone
rotting leaves, somehow
a ghost of woodsmoke
sour metal, like a coin on the tongue
stale perfume from a long-closed shop
chemical sharpness, like the inside of a new bag
damp earth after a long, long dry
cold ash and something that might be lavender
spilled petrol and the sea, impossibly
wet dog, though there's no dog
mouldy bread and warm engine oil
pine resin from a tree that isn't there
sun-baked tarmac
old books, and the dust of old books
singed hair and cooking meat, far off
the green stink of stagnant water
fresh-cut grass, which is nonsense
baked clay and rain
something fermenting in a sealed room
cigarette smoke, decades stale
bleach, faint and clean
a hospital, somehow
a bonfire from a long-ago night
cold iron and wet stone
roasting coffee, ghost-thin
the sharp zing of a battery
the green breath of moss
sour milk and warm plastic
""")
SMELL_T = L("""
The wind brings a whiff of {smell}.
You catch a hint of {smell} on the breeze, then lose it.
There's a faint smell of {smell} in the air.
The air carries a hint of {smell}, and you stop to place it.
For a moment the whole world smells of {smell}.
""")

SKY = L("""
The sky is the colour of dishwater
A pale sun hangs like a coin in a dirty glass
Clouds stack up like grey bricks to the west
The horizon is a smear of rust and bruise
A hard white light falls without warmth
The sky is thick and low and sulking
Thin rain is coming, drifting sideways
High cloud shreds in the wind like torn paper
A cold, clear sky, and every star insisting on being seen
Ash drifts down, soft as dandruff
The sun is a smudge behind a veil of smoke
Wind is combing the dust into long, low waves
Heat pours down and the road trembles
A dull light seeps from every cloud at once
The sky is oddly, hopefully blue
Mist pools in the low places
The clouds are lit from beneath, orange
A storm sits on the horizon, thinking about it
The dusk is purple and bruised
A dry, gritty wind pushes at your back
""")
EFFECT = L("""
Your shadow looks tired.
You pull your collar up and keep going.
Everything feels like it's holding its breath.
You squint, and the world squints back.
It's not unpleasant, in a bleak way.
You walk the faster for it.
Somehow it makes the quiet louder.
You take it as a sign, though you can't read it.
Everything has the colour of an old photograph.
You wonder who is under the same sky, and when.
You're glad of the walking, and the warm blood it brings.
The light does you no favours, and you don't care.
""")
WEATHER_T = L("""
{sky}. {effect}
{sky}. {effect}
{sky}.
""")

SURFACE = L("""
a lamppost
a bus window
a cracked mirror
a shop shutter
a collapsed notice board
a fence post
a ruined doorframe
a signpost
a traffic light
a rusted locker
a phone box
a garage door
a supermarket trolley
a bench
a wall of faded posters
a market stall
a bus stop
a cash machine
a cracked windscreen
the inside of a ruined porch
""")
NOTE_BODY = L("""
Water here is bad. Don't drink it. I did. -M
If you're reading this, I'm sorry about the dog.
DAY 211. Still no one.
Heading north. If you come looking, follow the blue paint.
Don't trust the quiet part of the road.
The tin cans are a trap. Sorry. Needed the food.
Back in an hour. (This was written six weeks ago.)
I left a spare filter in the red bin. Take it. Pay it forward.
Found a cat. Named it Gary. Gary is doing better than me.
They don't come out when it rains. Rains soon. Good luck.
We're not what you think. Please don't shoot.
Wife and kids, three miles east. Please, if you can.
Locked the gate. Whatever you are, thank you for knocking.
I forgave everyone. Felt stupid. Felt good.
There's a vault behind the florist. There isn't. I checked.
If you find my boots, keep them. They're cursed. Great boots though.
Bring a torch. Bring two. Don't tell anyone about the second.
The mutated ones hate bells. We rang them all night.
Don't open the cold room. Please.
THE SKY IS LYING.
We held out for 40 days. Take whatever's left.
Sorry about the mess. We left in a hurry.
Seven of us arrived. Four of us left. Be kind.
I lost count of the days, but I remember all the faces.
Everything in the pantry is a lie except the sugar.
Anyone out there? Anyone? Just checking. Still here.
We painted a smiley on the door for morale. It's not working.
Tomorrow I leave. Don't follow. It's not your road.
The sign says SAFE. The sign is not a reliable narrator.
If this finds you well, tell the next one to be gentle with the stairs.
Wait for the wind to turn before crossing the flats.
Kept the garden alive for three summers. Tomatoes. I miss tomatoes.
A very small thing: you're doing fine.
Don't read the other notes. They get worse.
I hid the key. Under the thing. You know the thing.
It's not the cold that gets you. It's the Tuesday.
Someone is leaving food at the corner. I don't know who. Thank you.
The radio told us to stay. We stayed. We're still staying.
We left a light on in the upstairs window, in case.
If you find the dog, tell him I said good boy.
No ghosts here. Just us. And the draught.
""")
SIGNOFF = L("""
 - M.
 - the last tenant
 - Rosa
 - "Two-Boots"
 - D.
 - someone who was here
 - a friend
 - Hal and the kid
 - J
 - the lighthouse keeper (ex)
 - Pip
 - Nobody in particular
""")
NOTE_T = L("""
A note is taped to {surface}: "{notebody}"
Scrawled on {surface}: "{notebody}"
Someone has scratched into {surface}: "{notebody}"
Pinned under a rock on {surface}, a note: "{notebody}"
""")
NOTE_SIGN_T = L("""
A note is taped to {surface}: "{notebody}"{signoff}
Scrawled on {surface}: "{notebody}"{signoff}
""")

RADIO_BODY = L("""
...this is a test of the emergency broadcast system. This is only a test. This was only a test...
...station KRX, playing the hits, whatever's left of them...
...seven. four. four. nine. forty. blue. blue. blue...
...if you can hear this, you are not alone. If you can hear this, you are not alone. If you can...
...traffic update: everything is stopped. Please remain calm. Please remain...
...a warm front moving in from the east, with a ninety percent chance of what you'd expect...
...stay indoors. Do not approach the lights. Do not approach...
...and now a word from our sponsors, who are, we assume, still out there...
...the following has been brought to you by the letter D, and by the number zero...
...please hold. Your call is important to us. Please hold. Your call...
...this is the voice of the new beginning, brought to you by a man who hasn't slept...
...remember: the water is clean when you've boiled it twice and prayed once...
...all units, all units, return to base. Nobody is coming...
...it's a beautiful day to be a survivor. Smile. They can't see you...
...I know someone is listening. I just want you to know I'm still here...
...today's lucky numbers are: none of them...
...we are experiencing technical difficulties. We have been experiencing them for some time...
...a lullaby, hummed slightly out of tune, for no one in particular...
...if you're in trouble, hum into your receiver twice. We'll know. We'll try...
...repeat: do not open the red doors. Repeat...
...the weather is currently: dust. The forecast is: more dust...
...breaking news: you made it this far. Congratulations. Carry on...
...a woman reads the names of the lost, one by one, patiently...
...I'm going to play a song now. I won't say what it is. You'll know...
...the time is... the time is... the time is a thing we used to have...
...you are listening to the sound of a very long hallway...
...please enjoy this minute of silence. Thank you. Thank you for listening...
...attention. Attention. The following is a recording of a recording of a recording...
...and for the late shift, a little bit of something to keep you company...
...I'd like to dedicate this next one to whoever's out there walking...
""")
RADIO_T = L("""
The radio on your belt crackles: "{radiobody}"
A stray signal bleeds through the static: "{radiobody}"
Your radio coughs into life: "{radiobody}"
For a moment the static parts: "{radiobody}"
""")

FIND_ITEM = L("""
a tin of peaches with the label gone
a handful of copper wire, still bright
a scrap of good steel plate
a sealed jar of something orange
a wrench with all its teeth
a clean spool of thread and a needle
a box of rusty nails, mostly straight
a coil of cable, barely frayed
a stub of a candle and half a matchbook
a dented flask that sloshes pleasingly
a mess of springs and gears
a plastic bag full of bottle caps
a small hoard of copper pipe
a bag of cement, miraculously dry
a neat bundle of solder
a scatter of coins nobody wanted
some circuit boards, ready for harvest
a pouch of spare screws
a sleeve of crackers, only a little stale
a bright, perfect tin lid
a battery, warm to the touch somehow
a pair of intact glasses (not your prescription)
a cracked radio with a promising heart
a coin purse of ancient currency
a whole, unsplit leather belt
a jar of buttons, pleasingly sorted
a few salvageable gears
a roll of decent tape
a length of rope, mostly rope
a medical pouch with nothing medical left, but a good pouch
""")
STASH = L("""
under a sunken seat
in a hollow wall
behind a rusted panel
at the bottom of a drawer
inside a flipped car
beneath a drift of ash
in a toolbox no one finished
tucked behind a pipe
inside a torn rucksack
in the pocket of a coat on a hook
under a floorboard that sighs as you lift it
among the roots of a dead tree
in the shell of an old fridge
wedged under a collapsed beam
behind a stack of crates
inside a shoebox, of all places
""")
REACTION = L("""
Good enough.
Still sealed. Miracles happen.
It's not much, but it's yours.
Somebody was proud of this once.
You wipe off the dust and pack it away.
A small win. You'll take it.
You say a quiet thank-you to whoever left it.
That'll be worth something.
You hold it a moment. Then you pocket it.
Not bad at all.
You'd have paid for that, back when paying meant something.
It's strange how much a little luck weighs.
""")
FIND_T = L("""
You turn up {item} {stash}. {reaction}
{item^}, {stash}. {reaction}
Rummaging {stash}, you find {item}. {reaction}
{stash^}, you find {item}. {reaction}
""")

JUNK = L("""
a collapsed shelf
a pile of splintered chairs
a drift of ash and plaster
a bin that smells of centuries
a cupboard of dead spiders
a bag of wet rags
a shelf of empty tins
a rack of unlabelled boxes
a box of mouldy paperbacks
a heap of broken tiles
a mess of tangled cables
a drawer of rusted cutlery
a bin liner of nothing
a cabinet of dusty trophies
""")
NOTHING = L("""
dust, mostly
a lot of nothing in particular
a single sock
mouse droppings and regret
a rusted spring, and not even a good one
things that crumble when touched
a handful of dry, brittle leaves
somebody's very old shopping list
a mildew stain shaped like a rabbit
an unreasonable amount of grit
a decades-old receipt
the ghost of an idea
""")
SHRUG = L("""
Worth a try.
Next time.
You wipe your hands and move on.
You try not to take it personally.
At least it was quiet.
You'll live. Probably.
The wasteland remains unimpressed.
Something smaller than you got here first.
You tell yourself it was good exercise.
Hope is a habit; you keep it up.
""")
FAIL_T = L("""
You dig through {junk} and find {nothing}. {shrug}
You paw through {junk}: {nothing}. {shrug}
There's nothing in {junk} but {nothing}. {shrug}
{junk^}: {nothing}. {shrug}
""")
