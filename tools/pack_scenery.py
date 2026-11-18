#!/usr/bin/env python3
"""Pack the categorised scenery sprites into ONE atlas for the exploration scene.

  python3 tools/pack_scenery.py [--src art_src/Sprites] [--preview]

Reads   <src>/{Buildings,Trees,Rocks,Props,Terrain,Vehicles,Suburban,Encounter}/*.png
Writes  assets/atlas/scenery.png + scenery.json   (same format lib/ui/atlas.dart already loads)
        work/scenery_pools.png                     (--preview: every pool, labelled, to check the sorting)

Player, NPC and Minigame folders are deliberately NOT packed (dweller rig, combat troopers and the
lockpick / terminal art keep using their existing atlases).

Each sprite is trimmed to its opaque pixels and gets a foot anchor `ax` (centroid of the bottom 30%),
so mirroring it keeps its base planted. `flip: false` marks sprites that carry lettering - the scene
never mirrors those. Pools are what the scene themes reference ("scenery#bld.block.tan").
Sorting lives in the lists below; edit them and re-run to re-sort.
"""
import json, os, re, sys
import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
OUT = os.path.join(ROOT, 'assets', 'atlas')
DBG = os.path.join(ROOT, 'work')
SRC = os.path.join(ROOT, 'art_src', 'Sprites')
if '--src' in sys.argv:
    SRC = sys.argv[sys.argv.index('--src') + 1]
FOLDERS = ['Buildings', 'Trees', 'Rocks', 'Props', 'Terrain', 'Vehicles', 'Suburban', 'Encounter']
ATLAS_W = 2048
THR = 40  # alpha counted as ink when trimming


def nums(*spec):
    """ints and (a, b) inclusive ranges -> set of ints"""
    out = set()
    for s in spec:
        out |= set(range(s[0], s[1] + 1)) if isinstance(s, tuple) else {s}
    return out


# --------------------------------------------------------------------------- sorting rules
# BUILDINGS ("building (N)"): 95-148 are the tan/rust set, 149-204 the mossy green set.
B_TAN = nums((95, 148), 1, 45, 46, 47, 50, 64)
B_TEXT = nums(102, 141, 152, 156, 179)                  # lettering / picture: never mirrored
B_ROADSIDE = nums(102, 141, 152, 156, 179, 196, 200)    # diner, gas, motel, billboards, canopies
B_LANDMARK = nums(99, 107, 110, 114, 115, 116, 117, 119, 123, 124, 126, 127, 128, 129, 162, 163,
                  177, 181, 182)                        # capitol, domes, towers, dishes, hangars
B_SPIRE = nums(118, 120, 131, 136, 175, 193, 197, 198)  # tall slim silhouettes
B_POLE = nums(154, 155, 161, 167, 171, 178, 145, 149, 150, 151)  # chimneys / thin masts / slim wrecks

# TREES: by file stem.
T_CACTUS = {'cactus (2)', 'cactus (3)', 'cactus (4)', 'cactus (5)', 'cactus (6)',
            'sprite_136', 'sprite_151', 'sprite_179'}
T_DEAD = {'sprite_140(2)', 'sprite_140(3)', 'sprite_141', 'sprite_142', 'sprite_144', 'sprite_177',
          'tree (3)', 'tree (4)', 'tree (9)', 'tree (11)', 'tree (12)', 'tree (17)', 'tree (28)',
          'tree (34)', 'tree (40)', 'tree (44)'}
T_PINE = {'tree (14)', 'tree (15)', 'tree (29)', 'tree (33)', 'tree (35)', 'tree (37)'}
# everything else: h >= 75 -> tree.leaf, shorter -> shrub

# ROCKS
R_BONES = {'rock (12)'}
R_TUMBLE = {'rock (27)'}

# PROPS ("prop (N)")
P_SIGN = nums(16, 17, 23, 36, 52, 55, 56, 69, 77, 86, 95, 96, 97, 98, 102, 104, 108, 109, 115, 116,
              118, 121, 123, 219)                        # lettering / symbols: never mirrored
P_LANDSIGN = nums(115, 118, 121, 123, 125)               # big roadside signs and the billboard
P_POLE = nums(2, 6, 18, 21, 24, 27, 41, 43, 58, 59, 60, 64, 71, 72, 74, 76, 78, 83, 87, 92, 163,
              182, 189, 202, 209, 214, 218, 221)
P_FENCE = nums(7, 44, 50, 51, 79, 84, 89, 90, 93, 94, 101, 105, 107, 114, 120, 122)
P_BIG = nums(103, 110, 111, 112, 113, 117, 119, 124)     # wrecks, stalls, gantries
# everything else is small clutter; 'tiny' = also short and narrow (barrels, cones, tyres...)

# VEHICLES
V_BUS = {'vehicle (1)', 'vehicle (2)', 'vehicle (13)'}
V_TRUCK = {'vehicle (7)', 'vehicle (14)', 'vehicle (5)'}
V_WRECK = {'vehicle (4)', 'vehicle (8)', 'vehicle (10)', 'vehicle (12)'}
V_CRASHED = {'sprite_197'}

# TERRAIN strips (top 40px band is used by the scene). Only sprites >= 80 wide.
G_ROAD = {'sprite_098', 'sprite_099', 'sprite_100', 'sprite_102', 'sprite_120', 'sprite_122',
          'sprite_125', 'terrain (32)', 'terrain (33)'}
G_DIRT = {'sprite_123', 'sprite_124', 'sprite_126', 'sprite_128', 'terrain (25)', 'terrain (26)',
          'terrain (27)', 'terrain (35)', 'terrain (40)', 'terrain (41)', 'terrain (49)'}
G_RUBBLE = {'sprite_107', 'terrain (34)', 'terrain (36)', 'terrain (37)', 'terrain (38)',
            'terrain (44)', 'terrain (45)', 'terrain (48)', 'terrain (54)'}
G_GRASS = {'sprite_121', 'terrain (1)', 'terrain (2)', 'terrain (3)', 'terrain (6)', 'terrain (12)',
           'terrain (13)', 'terrain (16)', 'terrain (28)', 'terrain (30)', 'terrain (43)',
           'terrain (46)', 'terrain (52)'}


def num(stem):
    m = re.search(r'\((\d+)\)', stem)
    return int(m.group(1)) if m else -1


def classify(folder, stem, w, h):
    """-> (pool names, mirror-safe)"""
    n = num(stem)
    pools, flip = [], True
    if folder == 'Buildings':
        tone = 'tan' if n in B_TAN else 'green'
        flip = n not in B_TEXT
        if n in B_ROADSIDE: pools.append('bld.roadside')
        elif n in B_LANDMARK: pools.append('bld.landmark')
        elif n in B_SPIRE: pools.append('bld.spire')
        elif n in B_POLE: pools.append('bld.pole')
        elif h <= 100 and w >= h * 1.3: pools += ['bld.low', f'bld.low.{tone}']
        else: pools += ['bld.block', f'bld.block.{tone}']
        if n in B_LANDMARK or n in B_SPIRE:
            pools.append(f'bld.far.{tone}')   # tall silhouettes that also read well at distance
    elif folder == 'Trees':
        if stem in T_CACTUS: pools.append('tree.cactus')
        elif stem in T_DEAD: pools.append('tree.dead')
        elif stem in T_PINE: pools.append('tree.pine')
        elif h >= 75: pools.append('tree.leaf')
        else: pools.append('shrub')
        if pools[0] != 'shrub': pools.append('tree.any')
    elif folder == 'Rocks':
        if stem in R_BONES: pools.append('bones')
        elif stem in R_TUMBLE: pools.append('tumble')
        elif h <= 42 and w <= 70: pools.append('rock.small')
        else: pools.append('rock.big')
    elif folder == 'Props':
        if n in P_SIGN: flip = False
        if n in P_LANDSIGN: pools.append('prop.landsign')
        elif n in P_SIGN and h <= 90: pools.append('prop.sign')
        elif n in P_POLE or (n in P_SIGN): pools.append('prop.pole')
        elif n in P_FENCE: pools.append('prop.fence')
        elif n in P_BIG: pools.append('prop.big')
        else:
            pools.append('prop.small')
            if h <= 62 and w <= 46: pools.append('prop.tiny')
    elif folder == 'Terrain':
        if w >= 80:
            for names, pool in ((G_ROAD, 'ground.road'), (G_DIRT, 'ground.dirt'),
                                (G_RUBBLE, 'ground.rubble'), (G_GRASS, 'ground.grass')):
                if stem in names: pools.append(pool)
    elif folder == 'Vehicles':
        if stem in V_CRASHED: pools.append('veh.crashed')
        elif stem in V_BUS: pools += ['veh.bus', 'veh.any']
        elif stem in V_TRUCK: pools += ['veh.truck', 'veh.any']
        elif stem in V_WRECK: pools += ['veh.wreck', 'veh.any']
        else: pools += ['veh.car', 'veh.any']
    elif folder == 'Suburban':
        pools.append('bld.roadside' if n == 8 else 'house')
    elif folder == 'Encounter':
        pools.append('bunker')
    return pools, flip


def load_all():
    items = []
    for folder in FOLDERS:
        d = os.path.join(SRC, folder)
        if not os.path.isdir(d):
            sys.exit(f'missing folder: {d}  (use --src <path to the Sprites folder>)')
        for fn in sorted(os.listdir(d)):
            if not fn.lower().endswith('.png'):
                continue
            stem = fn[:-4]
            im = Image.open(os.path.join(d, fn)).convert('RGBA')
            a = np.array(im)[..., 3]
            ys, xs = np.where(a > THR)
            if len(xs) == 0:
                continue
            im = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
            a = np.array(im)[..., 3]
            low = a[int(a.shape[0] * 0.7):]
            lx = np.where(low > THR)[1]
            ax = int(round(lx.mean())) if len(lx) else im.width // 2
            pools, flip = classify(folder, stem, im.width, im.height)
            items.append(dict(name=f'{folder.lower()}.{stem}', im=im, ax=ax, pools=pools, flip=flip))
    return items


def pack(items):
    items.sort(key=lambda s: -s['im'].height)
    x = y = shelf = 0
    pad = 2
    for s in items:
        w, h = s['im'].size
        if x + w + pad > ATLAS_W:
            x, y, shelf = 0, y + shelf + pad, 0
        s['x'], s['y'] = x, y
        x += w + pad
        shelf = max(shelf, h)
    H = y + shelf + pad
    sheet = Image.new('RGBA', (ATLAS_W, H), (0, 0, 0, 0))
    for s in items:
        sheet.paste(s['im'], (s['x'], s['y']))
    return sheet, H


def main():
    items = load_all()
    sheet, H = pack(items)
    os.makedirs(OUT, exist_ok=True)
    # 256-colour palette: visually identical for this art, ~4x smaller (matters for the web build)
    sheet.quantize(colors=256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE).save(
        os.path.join(OUT, 'scenery.png'), optimize=True)
    pools, names, sprites = {}, {}, []
    for i, s in enumerate(items):
        sp = dict(i=i, x=s['x'], y=s['y'], w=s['im'].width, h=s['im'].height, ax=s['ax'])
        if not s['flip']:
            sp['flip'] = False
        sprites.append(sp)
        names[s['name']] = i
        for p in s['pools']:
            pools.setdefault(p, []).append(i)
    json.dump(dict(image='scenery.png', width=ATLAS_W, height=H, sprites=sprites, names=names,
                   rows={}, pools=dict(sorted(pools.items()))),
              open(os.path.join(OUT, 'scenery.json'), 'w'), separators=(',', ':'))
    print(f'scenery.png {ATLAS_W}x{H}, {len(items)} sprites')
    for p, v in sorted(pools.items()):
        print(f'  {p:16s} {len(v)}')
    if '--preview' in sys.argv:
        preview(items, pools)


def preview(items, pools):
    os.makedirs(DBG, exist_ok=True)
    W, rowsd, y = 1600, [], 0
    # lay out each pool as a labelled band
    bands = []
    for p, idx in sorted(pools.items()):
        x, yy, rowh, cells = 4, 16, 0, []
        for i in idx:
            im = items[i]['im']
            s = min(1.0, 150 / im.height)
            if s < 1:
                im = im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))), Image.NEAREST)
            if x + im.width > W:
                x, yy = 4, yy + rowh + 4
                rowh = 0
            cells.append((im, x, yy, items[i]['flip']))
            x += im.width + 6
            rowh = max(rowh, im.height)
        bands.append((p, cells, yy + rowh + 8))
    H = sum(b[2] for b in bands)
    sh = Image.new('RGBA', (W, H), (35, 35, 35, 255))
    d = ImageDraw.Draw(sh)
    for p, cells, bh in bands:
        d.text((4, y + 2), p, fill=(255, 255, 0, 255))
        for im, cx, cy, fl in cells:
            sh.paste(im, (cx, y + cy), im)
            if not fl:
                d.rectangle((cx, y + cy, cx + 3, y + cy + 3), fill=(255, 0, 0, 255))
        y += bh
    sh.save(os.path.join(DBG, 'scenery_pools.png'))
    print('preview ->', os.path.join(DBG, 'scenery_pools.png'), sh.size)


if __name__ == '__main__':
    main()
