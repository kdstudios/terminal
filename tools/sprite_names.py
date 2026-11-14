"""Curated names for the auto-sliced sprites.

Everything is addressed by POSITION on the original sheet (pixel coords), never
by index, so re-running the slicer with different detection settings keeps the
names valid. `P(x, y)` = the sprite containing / nearest to that point.
`ROW(y, x0, x1)` = every sprite whose centre is within 30px of y, left->right.
"""

# ---- names: sheet-file -> { name: (x, y) } -------------------------------
NAMES = {
    'world_a': {
        'ground.grass': (74, 731), 'ground.dirt': (211, 743), 'ground.dirt2': (349, 731),
        'ground.road': (503, 731), 'ground.road2': (623, 731),
        'tree.dead1': (246, 920), 'tree.dead2': (326, 920), 'tree.autumn': (406, 931),
        'tree.pine1': (503, 931), 'tree.pine2': (583, 931), 'tree.green': (646, 931),
        'cactus': (960, 914), 'rock.big': (829, 903),
        'sign.radiation': (1451, 615), 'sign.welcome': (1080, 577), 'sign.gas': (931, 594),
        'sign.food': (1217, 566), 'sign.speed25': (1383, 611), 'sign.stop': (1389, 663),
        'pole.a': (1383, 497), 'pole.b': (1434, 497), 'pole.c': (1491, 497),
        'trafficlight': (1057, 720),
        'trooper.0': (50, 640), 'trooper.1': (105, 640), 'trooper.2': (150, 647),
        'trooper.3': (205, 647), 'trooper.4': (262, 647), 'trooper.5': (320, 647),
    },
    'world_b': {
        'sign.route66': (851, 394), 'sign.stop': (926, 400), 'sign.radiation': (1086, 400),
        'sign.gas': (1166, 400), 'sign.cola': (1245, 400), 'sign.welcome': (1434, 406),
        'sign.danger': (1451, 486), 'billboard': (1314, 91), 'motel': (749, 246),
        'church': (291, 263), 'house': (429, 269), 'gasstation': (606, 263),
        'radar': (1337, 269), 'watertower': (1411, 280), 'radome': (1463, 280),
        'car.rust': (874, 760), 'tent': (674, 749), 'plane.wreck': (1200, 674),
        'watchtower': (1446, 697), 'barrel.0': (40, 623),
    },
    'minigame': {
        'pick.0': (42, 190), 'pick.1': (95, 190), 'pick.2': (150, 190), 'pick.3': (205, 190),
        'pick.angled': (290, 190), 'pick.hook': (370, 190), 'pick.snapped': (475, 190),
        'pick.rusty': (568, 190), 'wrench.long': (632, 190), 'wrench.l': (685, 190),
        'lockplate.0': (990, 148), 'lockplate.1': (1184, 148), 'lockplate.2': (1400, 148),
        'lock.0': (80, 456), 'lock.1': (229, 455),
        'lock.lever0': (380, 455), 'lock.lever1': (508, 455), 'lock.lever2': (730, 455),
        'cylinder': (1130, 434),
        'computer': (270, 855), 'keyboard': (987, 740),
        'screen.denied': (1757, 715), 'screen.correct': (1442, 955), 'screen.lockout': (1757, 955),
        'icon.pick': (89, 1226), 'screwdriver.red': (398, 1225), 'screwdriver.green': (455, 1225),
        'key.grey': (512, 1250), 'key.gold': (573, 1240),
        'pickpin': (689, 1217), 'pick.tilted': (871, 1217), 'pick.broken': (1068, 1225),
        'iso.chest': (1597, 1218), 'iso.desk': (1850, 1213),
    },
}

# ---- frame rows: name -> (y centre, x_min, x_max) ------------------------
ROWS = {
    'world_b': {
        'dweller.a': (389, 0, 815),   # walk / run, rifle slung
        'dweller.b': (474, 0, 830),   # walk, rifle held / aim / kneel / idle
        'dweller.c': (560, 0, 770),   # sprint, dive, wave, misc
    },
}

# ---- pools: geometry rules -> [sprite ids] for procedural scenery --------
# (sheet, y_min, y_max, min_h): sprites fully inside the y band that are tall
POOLS = {
    'bld_b': ('world_b', 0, 350, 90),
    'bld_a': ('world_a', 0, 410, 90),
    'rock_a': ('world_a', 850, 1024, 12, 50),   # small rocks / bushes / stumps
    'rock_b': ('world_b', 835, 900, 10, 45),
}

# ---- rect pools: (sheet, (x0,y0,x1,y1) region, (h_min,h_max), (w_min,w_max)) --------
# Sprites whose CENTRE lies in the region and whose size fits. Props for variety.
RECT_POOLS = {
    'crates_a': ('world_a', (0, 425, 1000, 572), (15, 80), (12, 140)),
    'crates_b': ('world_b', (0, 595, 800, 720), (12, 75), (12, 140)),
    'poles_b': ('world_b', (780, 450, 1400, 650), (35, 150), (4, 70)),
    'fence_a': ('world_a', (1130, 680, 1480, 800), (30, 110), (10, 140)),
    'fence_b': ('world_b', (330, 650, 860, 730), (30, 90), (20, 140)),
    'plants_a': ('world_a', (0, 850, 1536, 1024), (14, 70), (12, 90)),
}
