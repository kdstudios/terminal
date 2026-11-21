import 'world.dart';

/// Extra flavour text. Regions keep their core lines in world.dart; these are
/// added on top so the wasteland keeps surprising you.

const extraSights = <String, List<String>>{
  'DUSTY HIGHWAY': [
    'A rusted gas pump stands alone, its hose coiled like a dead snake.',
    'Tire tracks, long since baked into the asphalt, wander off toward nowhere.',
    'Heat shimmers over the road. For a moment you see a car that is not there.',
    'A roadside diner sits gutted, its neon sign shattered into a thousand colours of nothing.',
    'Crows, black and patient, line a guardrail and watch you pass.',
    'Somebody has spray-painted a heart on an overturned truck. Beneath it: two sets of initials, and a date.',
  ],
  'RUSTED OUTSKIRTS': [
    'A forklift sits abandoned mid-turn, forks raised in a half-finished salute.',
    'Pigeons nest in the ribcage of a collapsed loading bay.',
    'Rusted barrels leak something that was once a colour.',
    "A foreman's office still has a calendar pinned to the wall. A date is circled.",
    'Wind-chimes of scrap clatter somewhere out of sight, hung there by someone, for something.',
    'A hand-painted sign reads: SAFE ZONE. Beneath it, in newer paint: NOT ANYMORE.',
  ],
  'GLASSED BASIN': [
    'A pillar of fused glass rises like a frozen scream, taller than any building around it.',
    'A burnt-out playground sits fused into the basin, the swings melted into question marks.',
    'The sun is doubled in the glass, one above, one beneath. Neither is warm.',
    'Bleached shapes of figures lie as if sleeping, outlined in a darker glass.',
    'A shallow crack runs across the basin, whistling softly where the wind finds it.',
    'Shards crunch underfoot like frost on a nightmare morning.',
  ],
  'DROWNED SUBURBS': [
    'A school bus sits in the shallows, its yellow faded to the colour of old teeth.',
    'Pale fish, blind and fat, drift past a drowned living room window.',
    'A FOR SALE sign leans out of the water, wearing its hopeful smile.',
    "A child's bicycle lies under a few inches of water, one wheel still turning in the current.",
    'Fog clings to the rooftops like gauze over a wound.',
    'A wedding photo drifts by face-up, ink bleeding away into the black water.',
  ],
  'IRON GRAVEYARD': [
    "A row of mechanical suits hangs from a gantry like a butcher's window.",
    'Rust-red dust coats everything, softening the edges of cannons and cabs alike.',
    'A fighter jet lies nose-down in the dirt, its tail fin standing like a gravestone.',
    'Dozens of helmets sit stacked on a crate. Nobody has claimed them.',
    'Barbed wire coils through the scrap in lazy loops, still catching the light.',
    'Painted on a wall of armour: LONG LIVE THE REPUBLIC. Beneath it, scratched through: LONG LIVE.',
  ],
  'ASHEN HEIGHTS': [
    'A suspended elevator car hangs in a shaft, its doors open to a hundred-metre drop.',
    'Ash gathers in drifts against doorways, deep enough to bury a child.',
    'Wind plays the broken towers like a church organ, a low, grieving chord.',
    'A billboard the size of a house shows a smiling family, half-burnt away.',
    'In the ash: a line of footprints, then a line of paw-prints following them, then nothing.',
    'Lightning flickers behind the clouds without a sound.',
  ],
};

const extraThoughts = <String, List<String>>{
  'DUSTY HIGHWAY': [
    'You try to remember the last time you saw green grass. It takes longer than it should.',
    'The road goes on forever. So does your list of things to scavenge.',
    'You hum a tune you do not remember learning, and stop when you realise how loud it is.',
    'There were towns out here once. People who waved from porches.',
    'Your canteen sloshes. A good sound. The best sound, lately.',
  ],
  'RUSTED OUTSKIRTS': [
    'Work jackets hang by a door, untouched. People left in a hurry, or did not leave.',
    'Every machine here still looks like it could start. You know better.',
    'You wonder who the last person to clock out was.',
    'Rust has a smell, and it is the smell of the whole world now.',
    'Someone is following your footprints, you think. Or the wind is just wearing them away.',
  ],
  'GLASSED BASIN': [
    'The silence in the basin is not empty. It feels like held breath.',
    'You catch your reflection and it looks older than you are.',
    'Every step on the glass sounds like a gunshot to something, somewhere.',
    'People stood here once, looking up. You try not to wonder what they saw.',
    'Heat rises through your boots. The ground remembers what happened to it.',
  ],
  'DROWNED SUBURBS': [
    'Where did everyone go? Higher ground, or deeper water?',
    'The mailboxes still have letters. You decide not to read any of them.',
    'The cold of the water seeps through your boots. It has patience.',
    'Somewhere under there is a kitchen. Somewhere under there, a dinner still laid out.',
    'You keep expecting a porch light to come on.',
  ],
  'IRON GRAVEYARD': [
    'Imagine the noise this place must have made.',
    'Somewhere in here is a working engine. Somewhere in here is a trap.',
    'You count rivets to steady your nerves. You lose count at four hundred.',
    'The dead machines look at you. You pretend they do not.',
    'You wonder what they were fighting for. You wonder if they knew.',
  ],
  'ASHEN HEIGHTS': [
    'This is where the world ended. You can feel it in your teeth.',
    'You are the loudest thing for ten kilometres, and you know it.',
    'Nothing grows here. Not even fear does well. It just sits and waits.',
    'You think of home, and are surprised how clearly you remember the smell of coffee.',
    'Whatever made those footprints is not interested in hiding.',
  ],
};

const soundLines = [
  'Somewhere far off, metal groans as the wind leans on it.',
  'A distant gunshot echoes once, then silence closes over it.',
  'Something small skitters behind a wall. You do not turn to look.',
  'A rusted hinge squeals in the breeze, over and over, like a tired animal.',
  'The wind carries a faint, tinny melody. A music box, maybe. Maybe not.',
  'Glass settles somewhere with a sound like a sigh.',
  'Your stomach growls, loud in the stillness.',
  'A dog barks in the distance, then thinks better of it.',
  'Thunder rolls, low and dry. No rain follows. There never is any.',
  'Rubble shifts in a building ahead, then holds still.',
  'Far above, something with wings and no sense of mercy circles lazily.',
  'A child laughs, once, somewhere in the ruins. Then nothing at all.',
  'The wind whistles through a bullet hole in a signpost, a thin sad note.',
  'A distant rumble: a building giving up at last.',
];

const weatherLines = [
  'A wall of dust rolls across the horizon, tinting the sky the colour of rust.',
  'The sun beats down, merciless, and your shadow shrinks to a puddle at your feet.',
  'Grey clouds gather, heavy with something that is probably not rain.',
  'A hot wind picks up, hissing grit against your goggles.',
  'The evening light turns the ruins gold for a minute, almost kind.',
  'Ash drifts in the air, soft as snow and twice as cold.',
  'A thin red haze hangs over everything, as if the sky itself were bruised.',
  'The wind drops. The air is suddenly still, and strangely expectant.',
  'Dusk deepens. The first stars come out, fewer than there used to be.',
  'A dry lightning storm paints the clouds, and the thunder arrives much too late.',
];

const noteLines = [
  'Scrawled on a wall: DAY 212. STILL HERE. STILL HUNGRY.',
  'A note under a stone: "To whoever finds this: the well at the old farm is clean. Boil it anyway."',
  'Painted on a bridge pillar: THEY COME AT NIGHT. DO NOT STOP WALKING.',
  "A child's drawing taped inside a window: a house, a sun, four stick people. Three are crossed out.",
  'A crude map is scratched into a doorframe, one spot circled: WATER. Someone has crossed it out: POISON.',
  'On a wall, in careful handwriting: "If you are reading this, you are not alone. Keep moving."',
  'Carved into a tree: M + J. Beneath: "She never came back."',
  'A sun-bleached poster urges: STAY CALM. HELP IS ON THE WAY.',
  'A scrap of paper pinned to a door: "Gone to find Dad. Back soon." The paper is brittle with age.',
  'Sprayed across a shuttered shop: TRUST NO ONE WHO SMILES.',
  'A journal page blows past: "Rations low. We drew lots. I will not write who lost."',
  'A rusted tin box holds a handful of old coins, a ribbon, and a note: "For luck."',
  'Etched in dust on a car window: "WASH ME." Somebody\'s idea of a joke, a lifetime ago.',
  'A ring of candles, guttered out, around a photograph you do not look at for long.',
  'Tally marks cover the wall of an alcove, hundreds, thousands, and then they simply stop.',
  'Chalked on the road: an arrow, and the word SAFE. You choose not to believe it.',
];

const radioLines = [
  'A scrap of static crackles from somewhere: "...repeat, all survivors proceed to..." then nothing.',
  'A faint broadcast drifts in: someone reading names, slowly, one after another.',
  'Your salvaged radio crackles. A voice, tinny and far away: "Anyone out there? Anyone?"',
  'A looping voice on an old frequency: "Safe zone established. Safe zone established. Safe zone..."',
  'The radio picks up music for a few seconds. A song you almost remember. Then gone.',
  'Static, then a whisper: "Do not go east." Then only static.',
  'A cheerful automated message plays from a buried speaker: "Have a nice day!"',
  'The airwaves hum with nothing, deep and endless, like an ocean with no shore.',
  'A voice counts down, slowly, from ten. It never reaches zero.',
  'Someone is reading a bedtime story over the radio. Your throat tightens. You turn the dial.',
  'A burst of laughter on the radio, then a gunshot. Static.',
  'Long-range chatter: traders haggling over a "bag of clean". You wonder what that means.',
];

const memoryLines = [
  'You remember the smell of rain on hot pavement. Real rain, the kind that cleaned things.',
  'You remember a kitchen, a radio, someone humming. The details slide away like water.',
  'You remember the old world as noise: cars, voices, a thousand small machines. You miss the noise.',
  'There was a time you took clean water for granted. It seems like a story now.',
  'You remember your first day out here. You were so certain you would not last a week.',
  'Somebody taught you how to pick a lock. You can almost see their hands.',
  'You remember people laughing around a table. You cannot remember what was funny.',
  'Once, you watched fireworks. The world was loud and bright in a good way.',
  'You remember a promise. You are no longer sure who made it, or to whom.',
  'You wonder if the old world would recognise you, hardened as you are.',
];

const extraScavengeLines = [
  'Behind a rotted vending machine, a tin that rattles pleasingly.',
  'A toolbox, rust-welded shut but heavy with promise. You pry it open.',
  "You find a dead scavenger's pack. You murmur an apology and take what you can use.",
  'Under a collapsed awning: a crate that somehow survived.',
  'A cracked cooler holds nothing edible but plenty of salvage.',
  'In the glovebox of a wreck: batteries, wire, a faded photograph.',
  'A wall of lockers, most empty, one still locked, one still full.',
  'You turn over the husk of a drone and the hardware inside is nearly pristine.',
  'An old cash register: not the money, but the mechanisms are worth something.',
  'A shelf of preserved jars. Nothing you will eat, but the lids and wire are good.',
];

const extraFailLines = [
  'Someone picked this place clean long ago. You find only a single, bent nail.',
  'You dig for ten minutes and come up with handfuls of grit and bad luck.',
  'A promising crate turns out to be full of old newspapers.',
  'You find a hidden stash, and the nest of vermin guarding it. You back away.',
  'Everything here is burnt, melted or already stolen.',
  'Whatever was here has rotted into powder.',
  'You dislodge a rockslide and lose a few precious minutes.',
  'Nothing. Not a thing. The wasteland is stingy today.',
];

const extraStartThoughts = [
  'You check your pack: water, pipe, a little hope. Enough.',
  'The wasteland waits, as it always does, like an old debt.',
  'You pull your hood up. The wind has teeth today.',
  'Another day, another kilometre, another chance of coming back.',
  'You lock the door behind you and tell yourself you will return. You always do.',
  'Somewhere out there is something worth finding. Or something worth running from.',
];

const extraLowHpThoughts = [
  'The edges of your vision have gone soft and grey. This is how people stop coming home.',
  'You taste blood. Your own, you hope.',
  'Your legs feel borrowed. Rest soon, or fall soon.',
  'Every heartbeat is a small, loud argument for turning back.',
];

const extraRichThoughts = [
  'The weight of your pack is a comfort and a target.',
  'You rattle faintly when you walk. Somebody will hear that.',
  'You could buy a lot with this. If you live to spend it.',
];

const extraFarThoughts = [
  'The safehouse is a long way behind you. A small, warm thought in a cold place.',
  'Out here, even the maps are guessing.',
  'Nobody knows exactly where you are. That is both freedom and sentence.',
];

const arrivalHome = [
  'You haul the bolts shut and lean against the door, listening to the quiet.',
  'The safehouse smells of dust, oil and old coffee. It smells like home.',
  'You shrug off the pack and let your shoulders drop. For now, you are safe.',
  'The lantern still burns. A tiny, stubborn bubble of light in the dark.',
  'You check the shutters, the lock, the stash. All exactly as you left them.',
  'You sink onto the cot. Every bone in your body files a formal complaint.',
  'The radio crackles softly on the shelf, still searching.',
  'A thin line of dawn leaks through the shutters. You count it as a good omen.',
];

const levelUpLines = [
  'Something clicks: you move more surely, think more clearly. The wasteland is a hard teacher.',
  'You catch yourself standing straighter. You have earned that.',
  'Another hard lesson, learned and kept. You are becoming someone this place has to respect.',
  'Aches and old scars, and underneath them, a new steadiness.',
  'Survival is a skill, and you are getting good at it.',
  'You are not the person who left home that first morning.',
];

const extraHazards = <Hazard>[
  Hazard('ACID RAIN', 'A greasy drizzle begins to fall, and it stings where it lands.', 'END', 4, 9),
  Hazard('FALLING DEBRIS', 'The wall above you groans, then lets go of a ton of masonry.', 'AGI', 7, 13),
  Hazard('TRIPWIRE', 'Your boot catches a wire. Somewhere, something rattles.', 'PER', 5, 10),
  Hazard('SPORE BLOOM', 'A pale cloud puffs from a fungal mass, and your eyes water.', 'END', 4, 8),
  Hazard('STRAY BULLET', 'A shot cracks from nowhere, and you throw yourself flat.', 'AGI', 6, 12),
];
