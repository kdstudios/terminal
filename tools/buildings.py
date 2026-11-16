"""Background structures / landmarks, same pixel rules as the artist's sheets
(dark outline, four tones, light from the upper left, ordered dither). All
authored at art resolution then upscaled x2 so they sit with the sheets' ruins."""
import math, json, os
import numpy as np
from scipy import ndimage as ndi
from PIL import Image
from pixlib import Canvas, RAMPS

CONC = [(30, 34, 30), (74, 82, 72), (120, 130, 112), (168, 176, 150)]
BRICK = [(40, 26, 22), (92, 56, 42), (140, 90, 66), (188, 132, 98)]
GLASS = [(16, 30, 36), (38, 66, 74), (78, 114, 120), (138, 172, 172)]
WINDOW = [(8, 10, 10), (22, 28, 26), (48, 58, 54), (96, 110, 100)]
WARM = (255, 200, 96)
PALE = [(60, 66, 60), (110, 118, 108), (160, 168, 156), (210, 214, 200)]
STRATA = [[(70, 50, 34), (120, 86, 56), (166, 124, 82), (208, 166, 112)],
          [(52, 44, 40), (96, 82, 72), (140, 122, 104), (184, 164, 140)],
          [(80, 56, 38), (136, 94, 60), (184, 134, 84), (224, 176, 118)]]
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')


def rubble(c, y, x0, x1, n, rng, ramp=CONC):
    for _ in range(n):
        x = rng.uniform(x0, x1); r = rng.uniform(2, 5)
        c.paint(c.ellipse(x, y - r * .4, r * 1.3, r), ramp, base=.5 + rng.uniform(-.1, .1), noise=.2, edge=True)


def vines(c, rng, mask, n, maxlen):
    ys, xs = np.where(mask)
    if not len(xs): return
    G = RAMPS['green']
    for _ in range(n):
        i = rng.randint(len(xs)); x, y = xs[i], ys[i]
        L = rng.randint(6, maxlen)
        for k in range(L):
            if 0 <= x < c.w and 0 <= y + k < c.h and mask[min(y + k, c.h - 1), x]:
                c.px([(x + (1 if k % 5 == 3 else 0), y + k)], G[1 + (k % 2)])
        c.px([(x, y + L), (x + 1, y + L - 1)], G[3])


def ruin_block(wc, hc, seed, mat=CONC, damage='top', roof='tank', lit=0.03):
    rng = np.random.RandomState(seed)
    cw, ch = 7, 9
    W, H = wc * cw + 14, hc * ch + 30
    c = Canvas(W, H, seed)
    gy = H - 8; top = gy - hc * ch; x0, x1 = 7, 7 + wc * cw
    body = c.rect(x0, top, x1, gy)
    c.paint(body, mat, base=.55, noise=.16, edge=False)
    for r in range(hc + 1):                                           # floor slabs
        y = top + r * ch
        c.line((x0, y), (x1 - 1, y), mat[0]); c.line((x0, y + 1), (x1 - 1, y + 1), mat[3])
    for col in range(wc + 1):                                         # pilasters
        x = x0 + col * cw
        c.line((x, top), (x, gy), mat[0])
    for r in range(hc):                                               # windows
        for col in range(wc):
            wx, wy = x0 + col * cw + 1, top + r * ch + 2
            kind = rng.rand()
            c.paint(c.rect(wx, wy, wx + 5, wy + 6), WINDOW, base=.35, edge=False)
            c.line((wx, wy + 6), (wx + 4, wy + 6), mat[3])           # sill
            if kind < lit and True:
                c.paint(c.rect(wx + 1, wy + 1, wx + 4, wy + 4), [(120, 70, 20), (200, 130, 40), WARM, (255, 240, 190)], base=.7, edge=False)
            elif kind < .22:
                c.px([(wx + 1, wy + 1), (wx + 2, wy + 2), (wx + 4, wy + 1), (wx + 3, wy + 4)], WINDOW[3])      # glass shards
            elif kind < .32:
                c.paint(c.rect(wx, wy, wx + 5, wy + 6), [(40, 26, 16), (80, 52, 30), (120, 80, 46), (150, 106, 64)], base=.5, edge=False)  # boarded
                c.line((wx, wy + 3), (wx + 4, wy + 3), (30, 20, 12))
            elif kind < .40:
                c.paint(c.rect(wx, wy, wx + 5, wy + 6), RAMPS['green'], base=.4, noise=.4, edge=False)         # overgrown
    # ---- damage
    cut = np.zeros((H, W), bool)
    if damage == 'top':
        xa = int(x0 + wc * cw * rng.uniform(.18, .45)); ycut = top + int(hc * ch * rng.uniform(.25, .5))
        prof = ycut + np.cumsum(rng.randint(-2, 3, W)).astype(int)
        for x in range(xa, W):
            ye = int(prof[x] + (x - xa) * 0.35 * rng.uniform(.4, 1.3))     # the roof line falls away to the right
            cut[:max(min(ye, gy - 14), top - 1), x] = True
    elif damage == 'side':
        cx = x0 if rng.rand() < .5 else x1; cy = top + hc * ch * rng.uniform(.3, .6); r = wc * cw * rng.uniform(.3, .45)
        cut = ((c.xx - cx) ** 2 + ((c.yy - cy) * 0.8) ** 2) < r * r
        cut ^= (rng.rand(H, W) < .06) & cut
    elif damage == 'hole':
        cx = x0 + wc * cw * rng.uniform(.3, .7); cy = top + hc * ch * rng.uniform(.25, .6)
        cut = ((c.xx - cx) / (wc * 2.2)) ** 2 + ((c.yy - cy) / (hc * 2.4)) ** 2 < 1
    cut &= c.rect(x0 - 1, top - 2, x1 + 1, gy - 6)
    gone = cut & (c.rgba[..., 3] > 0)
    c.rgba[gone] = 0
    # exposed slabs jut out into the gap, with dangling rebar
    for r in range(hc + 1):
        y = top + r * ch
        for x in range(x0, x1):
            if c.rgba[y, x, 3] == 0 and cut[y, x] if 0 <= y < H else False:
                pass
        # find boundary runs on this slab row
        row = c.rgba[y, :, 3] > 0
        for x in range(x0 + 1, x1 - 1):
            if row[x] and not row[x + 1] and cut[y, x + 1]:
                L = rng.randint(2, 6)
                for k in range(1, L + 1):
                    c.px([(x + k, y)], mat[3 - (k % 2)]); c.px([(x + k, y + 1)], mat[0])
                if rng.rand() < .7:
                    c.line((x + L, y + 2), (x + L + rng.randint(-1, 2), y + 2 + rng.randint(3, 8)), RAMPS['rust'][2])
    # rooftop
    if damage != 'top':
        if roof == 'tank':
            c.paint(c.rect(x0 + 3, top - 8, x0 + 11, top - 2), 'rust', base=.5); c.line((x0 + 4, top - 2), (x0 + 4, top), RAMPS['rust'][0]); c.line((x0 + 10, top - 2), (x0 + 10, top), RAMPS['rust'][0])
            c.paint(c.poly([(x0 + 2, top - 8), (x0 + 7, top - 12), (x0 + 12, top - 8)]), 'rust', base=.6, edge=False)
        elif roof == 'mast':
            c.line((x0 + wc * cw // 2, top), (x0 + wc * cw // 2, top - 14), mat[1]); c.px([(x0 + wc * cw // 2, top - 15)], (255, 80, 60))
            c.line((x0 + wc * cw // 2 - 3, top - 8), (x0 + wc * cw // 2 + 3, top - 8), mat[1])
        else:
            for k in range(2):
                c.paint(c.rect(x0 + 3 + k * 9, top - 4, x0 + 9 + k * 9, top), 'steel', base=.5)
    vines(c, rng, (c.rgba[..., 3] > 0) & (c.yy < gy - 6), 5 + hc // 2, 22)
    rubble(c, gy + 3, 2, W - 2, 8 + wc, rng, mat)
    c.paint(c.ellipse(W / 2, gy + 4, W * .48, 4), 'grey', base=.35, noise=.3, edge=False)
    return c.finish(2)


def cooling_tower(seed=3):
    c = Canvas(64, 84, seed); rng = np.random.RandomState(seed)
    yy = c.yy
    hw = 12 + 17 * ((yy - 40) / 40.0) ** 2
    mask = (np.abs(c.xx - 32) <= hw) & (yy >= 4) & (yy <= 80)
    c.paint(mask, CONC, base=.55, noise=.14, edge=True)
    for x in range(0, 64, 4):
        c.rgba[mask & (c.xx == x)] = (*CONC[0], 255)
    for y in (14, 36, 58):
        c.rgba[(c.yy == y) & mask] = (*CONC[0], 255)
        c.rgba[(c.yy == y + 1) & mask] = (*CONC[3], 255)
    for (x, y) in [(30, 10), (34, 20), (28, 30), (33, 42), (29, 52)]:    # crack
        c.px([(x, y), (x + 1, y), (x + 1, y + 1)], (8, 10, 8))
    bite = c.poly([(40, 0), (64, 0), (64, 12), (52, 8), (46, 14), (42, 6)])
    c.rgba[bite & mask] = 0
    c.paint(c.poly([(24, 80), (24, 66), (32, 60), (40, 66), (40, 80)]), WINDOW, base=.2, edge=True)   # base arch
    vines(c, rng, mask & (c.yy > 50), 6, 18)
    rubble(c, 82, 4, 60, 10, rng)
    return c.finish(2)


def silos(seed=4):
    c = Canvas(72, 70, seed); rng = np.random.RandomState(seed)
    for (cx, hgt, ramp) in [(16, 48, CONC), (34, 56, CONC), (53, 40, BRICK)]:
        top = 66 - hgt
        c.paint(c.rect(cx - 8, top, cx + 8, 66) | c.ellipse(cx, top, 8, 5), ramp, base=.55, noise=.16)
        for y in range(top + 8, 64, 9):
            c.line((cx - 8, y), (cx + 7, y), ramp[0])
        c.px([(cx - 4, top + 3), (cx - 3, top + 3)], ramp[3])
    c.line((16, 30), (34, 18), RAMPS['rust'][2], 2); c.line((34, 20), (53, 30), RAMPS['rust'][2], 2)      # catwalk
    for y in range(22, 64, 3):
        c.line((24, y), (26, y), RAMPS['rust'][1])                                                      # ladder
    c.line((25, 22), (25, 64), RAMPS['rust'][1]); c.line((27, 22), (27, 64), RAMPS['rust'][1])
    c.paint(c.rect(60, 44, 68, 66), 'steel', base=.45); c.line((64, 30), (64, 44), RAMPS['steel'][1], 2)
    rubble(c, 67, 4, 68, 9, rng)
    return c.finish(2)


def wind_turbine(seed=5):
    c = Canvas(64, 90, seed)
    c.paint(c.poly([(30, 84), (34, 84), (33, 26), (31, 26)]), PALE, base=.6, edge=True)
    c.paint(c.rect(26, 20, 40, 27), PALE, base=.55)
    c.paint(c.ellipse(26, 23, 4, 4), 'steel', base=.6)
    for (a, b) in [((26, 23), (24, 2)), ((26, 23), (10, 40))]:
        d = np.array(b) - np.array(a); n = np.array([-d[1], d[0]]) / np.hypot(*d)
        pts = [tuple(np.array(a) + n * 2.2), tuple(np.array(a) - n * 2.2), tuple(np.array(b) + n * .4)]
        c.paint(c.poly(pts), PALE, base=.62, edge=True)
    c.paint(c.poly([(26, 21), (30, 24), (38, 33), (34, 36), (28, 27)]), PALE, base=.5, edge=True)           # broken stub
    c.paint(c.rect(24, 82, 40, 88), CONC, base=.45)
    c.px([(26, 23)], (255, 80, 60))
    return c.finish(2)


def ferris_wheel(seed=6):
    c = Canvas(80, 82, seed); rng = np.random.RandomState(seed)
    cx, cy, R = 40, 36, 32
    ring = c.ellipse(cx, cy, R, R) & ~c.ellipse(cx, cy, R - 2, R - 2)
    ring2 = c.ellipse(cx, cy, R - 10, R - 10) & ~c.ellipse(cx, cy, R - 12, R - 12)
    c.paint(ring | ring2, 'rust', base=.55, edge=False)
    for k in range(12):
        a = k * math.pi / 6
        c.line((cx, cy), (cx + (R - 1) * math.cos(a), cy + (R - 1) * math.sin(a)), RAMPS['rust'][1])
        if k not in (2, 5, 9):
            gx, gy2 = cx + R * math.cos(a), cy + R * math.sin(a)
            c.paint(c.rect(gx - 2, gy2, gx + 3, gy2 + 4), [(40, 20, 18), (120, 50, 40), (180, 90, 60), (220, 150, 110)], base=.55)
    c.paint(c.ellipse(cx, cy, 4, 4), 'steel', base=.6)
    c.line((cx, cy), (cx - 18, 80), RAMPS['rust'][2], 2); c.line((cx, cy), (cx + 18, 80), RAMPS['rust'][2], 2)
    c.line((cx - 12, 62), (cx + 12, 62), RAMPS['rust'][1])
    rubble(c, 81, 14, 66, 6, rng)
    return c.finish(2)


def overpass(seed=7):
    c = Canvas(120, 56, seed); rng = np.random.RandomState(seed)
    for x in (12, 52, 100):
        c.paint(c.rect(x, 20, x + 9, 52), CONC, base=.55, noise=.16)
        c.paint(c.ellipse(x + 4.5, 52, 8, 10) & (c.yy > 34), WINDOW, base=.2, edge=False)
    deck = c.rect(0, 14, 120, 22)
    gap = c.poly([(64, 12), (80, 12), (84, 24), (72, 20), (66, 24)])
    c.paint(deck & ~gap, CONC, base=.6, noise=.12)
    c.rgba[gap & (c.rgba[..., 3] > 0)] = 0
    for x in range(4, 60, 10): c.line((x, 17), (x + 5, 17), (200, 170, 50))
    for x in range(88, 118, 10): c.line((x, 17), (x + 5, 17), (200, 170, 50))
    c.line((0, 13), (62, 13), CONC[3]); c.line((86, 13), (119, 13), CONC[3])
    for (x, y) in [(66, 22), (70, 22), (78, 21)]:
        c.line((x, y), (x + rng.randint(-1, 2), y + rng.randint(4, 9)), RAMPS['rust'][2])
    c.paint(c.rect(30, 10, 42, 14), 'rust', base=.55); c.paint(c.rect(34, 7, 40, 10), 'rust', base=.6)   # abandoned car
    c.px([(35, 8), (38, 8)], WINDOW[3])
    rubble(c, 54, 0, 120, 10, rng)
    return c.finish(2)


def gas_holder(seed=8):
    c = Canvas(72, 60, seed); rng = np.random.RandomState(seed)
    c.paint(c.rect(8, 22, 64, 54) | c.ellipse(36, 22, 28, 6), CONC, base=.5, noise=.14)
    for x in range(8, 66, 8):
        c.line((x, 22), (x, 54), CONC[0], 2)
    for k in range(7):
        c.line((8 + k * 8, 22), (16 + k * 8, 54), RAMPS['rust'][1]); c.line((16 + k * 8, 22), (8 + k * 8, 54), RAMPS['rust'][1])
    c.line((6, 54), (66, 54), CONC[0], 2)
    c.line((8, 22), (8, 54), CONC[3])
    c.paint(c.rect(62, 12, 66, 54), 'steel', base=.5); c.px([(63, 8), (64, 8)], (255, 80, 60))
    rubble(c, 56, 2, 70, 8, rng)
    return c.finish(2)


def port_crane(seed=9):
    c = Canvas(88, 76, seed); rng = np.random.RandomState(seed)
    for x in (52, 74):
        c.paint(c.rect(x, 20, x + 3, 72), 'rust', base=.55)
        for y in range(24, 70, 6): c.line((x, y), (x + 3, y + 4), RAMPS['rust'][0])
    c.paint(c.rect(46, 14, 82, 20), 'rust', base=.55)
    c.paint(c.poly([(46, 14), (46, 20), (2, 10), (2, 6)]), 'rust', base=.55, edge=True)
    for k in range(6):
        x = 6 + k * 7; c.line((x, 8 + (x - 2) * -.0), (x + 4, 17 - k * .5), RAMPS['rust'][0])
    c.line((46, 6), (2, 6), RAMPS['rust'][3]); c.line((60, 4), (10, 9), RAMPS['steel'][1]); c.line((60, 4), (46, 14), RAMPS['steel'][1])
    c.paint(c.rect(20, 22, 34, 30), 'steel', base=.5)                                                       # trolley load
    for x in (21, 33): c.line((x, 8), (x, 22), RAMPS['black'][2])
    c.paint(c.rect(2, 66, 86, 70), CONC, base=.4, edge=False)
    rubble(c, 74, 0, 88, 9, rng)
    return c.finish(2)


def containers(seed=10):
    c = Canvas(84, 60, seed); rng = np.random.RandomState(seed)
    cols = [[(40, 20, 16), (110, 50, 36), (166, 86, 56), (212, 130, 90)], [(26, 38, 40), (60, 88, 92), (100, 132, 132), (150, 180, 176)],
            [(52, 44, 24), (112, 96, 48), (164, 142, 74), (208, 186, 110)], [(30, 40, 30), (62, 92, 62), (100, 138, 96), (150, 186, 140)]]
    layout = [(0, 48, 0), (26, 48, 1), (52, 48, 3), (10, 38, 2), (36, 38, 0), (22, 28, 1), (46, 28, 2), (60, 38, 3)]
    for (x, y, k) in layout:
        r = cols[(k + rng.randint(0, 3)) % 4]
        c.paint(c.rect(x, y, x + 28, y + 10), r, base=.55, noise=.12)
        for xx in range(x + 2, x + 27, 2): c.line((xx, y + 1), (xx, y + 9), r[0])
        c.line((x + 14, y), (x + 14, y + 10), r[3])
        c.px([(x + 3, y + 3), (x + 24, y + 6)], r[3])
    c.paint(c.ellipse(42, 58, 40, 3), 'grey', base=.35, edge=False)
    rubble(c, 59, 0, 84, 7, rng)
    return c.finish(2)


def statue_head(seed=11):
    c = Canvas(76, 76, seed); rng = np.random.RandomState(seed)
    head = c.ellipse(36, 36, 24, 28)
    c.paint(head, PALE, base=.55, noise=.12)
    c.paint(c.poly([(14, 36), (6, 46), (14, 50), (18, 40)]), PALE, base=.6)                          # nose
    c.paint(c.ellipse(24, 30, 5, 3), WINDOW, base=.2, edge=True)                                      # eye socket
    c.paint(c.poly([(10, 54), (22, 52), (20, 56), (12, 58)]), PALE, base=.45, edge=True)              # lips
    c.paint(c.ellipse(52, 36, 4, 8), PALE, base=.5)                                                   # ear
    for pts in [[(30, 8), (28, 18), (32, 26)], [(44, 12), (46, 22), (42, 34), (46, 44)]]:
        for a, b in zip(pts, pts[1:]): c.line(a, b, (8, 12, 10))                                      # cracks
    c.paint(c.poly([(20, 6), (36, 2), (52, 8), (50, 16), (22, 14)]), PALE, base=.4, edge=True)          # hair band
    vines(c, rng, (c.rgba[..., 3] > 0), 8, 20)
    c.paint(c.ellipse(36, 70, 38, 16) & (c.yy > 54), STRATA[0], base=.5, noise=.3)                  # buried in sand
    rubble(c, 72, 0, 76, 6, rng, STRATA[0])
    return c.finish(2)


def ribcage(seed=12):
    c = Canvas(96, 64, seed); rng = np.random.RandomState(seed)
    B = RAMPS['bone']
    c.paint(c.capsule((14, 56), (90, 56), 3), B, base=.5)
    for k in range(7):
        x = 24 + k * 10
        h = 40 - abs(k - 3) * 5
        pts = [(x, 56), (x - 4, 56 - h * .5), (x - 2, 56 - h), (x + 6, 56 - h * .8), (x + 8, 56 - h * .35)]
        for a, b in zip(pts, pts[1:]):
            c.paint(c.capsule(a, b, 1.9, 1.5), B, base=.6, edge=False)
        c.px([(x, 55)], B[3])
    c.paint(c.ellipse(10, 54, 9, 7), B, base=.58)                                                      # skull
    c.paint(c.ellipse(8, 52, 2.6, 2.6), WINDOW, base=.1, edge=False); c.px([(3, 57), (5, 58), (7, 58)], B[3])
    c.paint(c.ellipse(48, 62, 46, 5), STRATA[0], base=.5, noise=.3, edge=False)
    rubble(c, 63, 0, 96, 5, rng, STRATA[0])
    return c.finish(2)


def mesa(seed=13, spire=False):
    c = Canvas(70 if not spire else 36, 74, seed); rng = np.random.RandomState(seed)
    W = c.w
    if spire:
        prof = 10 + 6 * np.abs(np.sin(np.arange(W) * .35 + 1)) + (np.arange(W) % 5 == 0)
        mask = (np.abs(c.xx - W / 2) < (5 + 9 * ((c.yy / 74) ** 1.4))) & (c.yy > 6)
    else:
        mask = ((np.abs(c.xx - W / 2) < (22 + 12 * (c.yy / 74) ** 1.2)) & (c.yy > 16)) | ((np.abs(c.xx - W / 2) < 18) & (c.yy > 8))
    ys = np.arange(74)
    for i, y0 in enumerate(range(8, 74, 7)):
        m = mask & (c.yy >= y0) & (c.yy < y0 + 7)
        c.paint(m, STRATA[i % 3], base=.5 + .06 * (i % 2), noise=.18, edge=False)
    for x in rng.randint(10, W - 10, 6):
        c.line((x, 14 + rng.randint(0, 20)), (x + rng.randint(-1, 2), 40 + rng.randint(0, 30)), STRATA[1][0])
    c.rgba[~mask] = 0
    rubble(c, 73, 0, W, 8, rng, STRATA[1])
    return c.finish(2)


def stadium(seed=14):
    c = Canvas(112, 54, seed); rng = np.random.RandomState(seed)
    wall = (((c.xx - 56) / 54.0) ** 2 + ((c.yy - 52) / 40.0) ** 2 <= 1) & (((c.xx - 56) / 44.0) ** 2 + ((c.yy - 52) / 30.0) ** 2 > 1) & (c.yy < 52)
    c.paint(wall, CONC, base=.55, noise=.15)
    for k in range(14):
        a = math.pi + k * math.pi / 13.0
        x = 56 + 49 * math.cos(a); y = 52 + 35 * math.sin(a)
        if k not in (4, 5, 11):
            c.paint(c.ellipse(x, y + 1, 2.6, 4), WINDOW, base=.2, edge=False)
    c.rgba[c.poly([(70, 0), (98, 0), (92, 22), (76, 14)]) & (c.rgba[..., 3] > 0)] = 0                 # collapse
    for x in (6, 104):
        c.line((x, 52), (x, 10), CONC[1], 2); c.paint(c.rect(x - 4, 6, x + 5, 12), 'steel', base=.5)
    rubble(c, 53, 0, 112, 10, rng)
    return c.finish(2)


def drive_in(seed=15):
    c = Canvas(84, 64, seed); rng = np.random.RandomState(seed)
    c.paint(c.rect(10, 8, 74, 44), PALE, base=.6, noise=.1)
    c.paint(c.rect(10, 8, 74, 10), CONC, base=.45, edge=False); c.paint(c.rect(10, 42, 74, 44), CONC, base=.45, edge=False)
    c.rgba[c.poly([(44, 8), (62, 8), (56, 26), (50, 18)]) & (c.rgba[..., 3] > 0)] = 0
    for (a, b) in [((20, 20), (30, 28)), ((30, 28), (28, 38)), ((60, 30), (68, 40))]: c.line(a, b, (10, 14, 12))
    for x in (22, 62):
        c.line((x, 44), (x, 62), CONC[1], 3)
    for k in range(5): c.line((22 + k * 10, 44), (22 + k * 10 + 4, 56), CONC[0])
    c.paint(c.rect(70, 52, 82, 62), 'rust', base=.5); c.px([(74, 56), (77, 56)], WINDOW[3])
    rubble(c, 63, 0, 84, 7, rng)
    return c.finish(2)


def airliner_tail(seed=16):
    c = Canvas(80, 70, seed); rng = np.random.RandomState(seed)
    c.paint(c.poly([(34, 66), (40, 8), (52, 6), (62, 66)]), PALE, base=.58, noise=.1)                  # fin
    c.paint(c.poly([(37, 40), (49, 38), (50, 48), (36, 50)]), [(40, 16, 14), (110, 36, 30), (170, 60, 46), (220, 100, 80)], base=.55, edge=False)
    c.paint(c.ellipse(44, 26, 5, 5), WINDOW, base=.3, edge=False)
    c.paint(c.rect(18, 58, 74, 68) | c.ellipse(18, 63, 6, 5), PALE, base=.5, noise=.12)                 # fuselage stub
    for x in range(22, 72, 6): c.paint(c.rect(x, 61, x + 3, 64), WINDOW, base=.2, edge=False)
    c.rgba[c.poly([(62, 56), (76, 54), (76, 70), (66, 70)]) & (c.rgba[..., 3] > 0)] = 0
    c.paint(c.ellipse(40, 68, 38, 6) & (c.yy > 60), STRATA[0], base=.5, noise=.3, edge=False)
    rubble(c, 69, 0, 80, 6, rng, STRATA[0])
    return c.finish(2)


def saucer_tower(seed=17):
    c = Canvas(56, 84, seed)
    c.paint(c.poly([(26, 80), (30, 80), (29, 30), (27, 30)]), CONC, base=.55)
    c.paint(c.ellipse(28, 28, 22, 5), CONC, base=.6)
    c.paint(c.ellipse(28, 24, 14, 5), 'steel', base=.55)
    c.paint(c.rect(26, 8, 30, 20), 'steel', base=.5); c.line((28, 8), (28, 0), RAMPS['steel'][2]); c.px([(28, 0)], (255, 80, 60))
    c.rgba[c.poly([(36, 20), (52, 20), (52, 34), (44, 30)]) & (c.rgba[..., 3] > 0)] = 0
    c.paint(c.rect(18, 78, 38, 84), CONC, base=.4)
    return c.finish(2)


def _grove(names, seed, n, W=240, sheet='world_a', dark=.0):
    rng = np.random.RandomState(seed)
    d = json.load(open(os.path.join(ROOT, 'assets', 'atlas', sheet + '.json')))
    im = Image.open(os.path.join(ROOT, 'assets', 'atlas', d['image'])).convert('RGBA')
    def crop(nm):
        s = d['sprites'][d['names'][nm]]; return im.crop((s['x'], s['y'], s['x'] + s['w'], s['y'] + s['h']))
    out = Image.new('RGBA', (W, 170), (0, 0, 0, 0))
    items = sorted([(rng.uniform(.0, 1.0), nm) for nm in rng.choice(names, n)], key=lambda t: t[0])
    for depth, nm in items:
        s = crop(nm); sc = .75 + .5 * depth
        s = s.resize((int(s.width * sc), int(s.height * sc)), Image.LANCZOS)
        a = np.array(s).astype(float); a[..., :3] *= (0.62 + 0.38 * depth); s = Image.fromarray(a.clip(0, 255).astype(np.uint8), 'RGBA')
        x = int(rng.uniform(10, W - 10 - s.width)); y = int(150 + 18 * depth - s.height)
        out.alpha_composite(s, (x, max(0, y)))
    bb = out.getbbox()
    return out.crop(bb) if bb else out


BUILDERS = {
    'bg.tower_a': lambda: ruin_block(7, 10, 21, CONC, 'top', 'mast'),
    'bg.tower_b': lambda: ruin_block(8, 8, 22, BRICK, 'side', 'tank'),
    'bg.tower_c': lambda: ruin_block(5, 13, 23, GLASS, 'top', 'mast'),
    'bg.tower_d': lambda: ruin_block(7, 9, 24, BRICK, 'hole', 'units'),
    'bg.tower_e': lambda: ruin_block(9, 6, 25, GLASS, 'side', 'units'),
    'bg.slab_a': lambda: ruin_block(11, 5, 26, CONC, 'top', 'tank'),
    'bg.tower_f': lambda: ruin_block(6, 11, 27, CONC, 'hole', 'mast'),
    'bg.slab_b': lambda: ruin_block(10, 4, 28, BRICK, 'side', 'units'),
    'bg.cooling': cooling_tower, 'bg.silos': silos, 'bg.turbine': wind_turbine, 'bg.ferris': ferris_wheel,
    'bg.overpass': overpass, 'bg.gasholder': gas_holder, 'bg.crane': port_crane, 'bg.containers': containers,
    'bg.statue': statue_head, 'bg.ribs': ribcage, 'bg.mesa': mesa, 'bg.spire': lambda: mesa(19, True),
    'bg.stadium': stadium, 'bg.drivein': drive_in, 'bg.airliner': airliner_tail, 'bg.saucer': saucer_tower,
}
FOREST = {
    'bg.grove_pine': lambda: _grove(['tree.pine1', 'tree.pine2', 'tree.pine1', 'tree.pine2'], 41, 9),
    'bg.grove_dead': lambda: _grove(['tree.dead1', 'tree.dead2'], 42, 8),
    'bg.grove_mixed': lambda: _grove(['tree.pine1', 'tree.green', 'tree.autumn', 'tree.dead1', 'tree.pine2', 'tree.green'], 43, 9),
    'bg.grove_wild': lambda: _grove(['tree.green', 'tree.autumn', 'tree.green', 'tree.pine2'], 44, 8),
}
POOLS = {
    'bg_city': ['bg.tower_a', 'bg.tower_b', 'bg.tower_c', 'bg.tower_d', 'bg.tower_e', 'bg.slab_a', 'bg.tower_f', 'bg.slab_b', 'bg.stadium'],
    'bg_industry': ['bg.cooling', 'bg.silos', 'bg.gasholder', 'bg.crane', 'bg.containers', 'bg.turbine'],
    'bg_landmark': ['bg.ferris', 'bg.overpass', 'bg.statue', 'bg.ribs', 'bg.airliner', 'bg.saucer', 'bg.drivein'],
    'bg_desert': ['bg.mesa', 'bg.spire', 'bg.ribs', 'bg.statue', 'bg.airliner'],
    'bg_forest': ['bg.grove_pine', 'bg.grove_dead', 'bg.grove_mixed', 'bg.grove_wild'],
}


def items():
    out = {k: f() for k, f in BUILDERS.items()}
    out.update({k: f() for k, f in FOREST.items()})
    return out


if __name__ == '__main__':
    it = items()
    W = 1500
    sheet = Image.new('RGBA', (W, 1100), (24, 50, 36, 255)); x = y = 6; rowh = 0
    from PIL import ImageDraw
    d = ImageDraw.Draw(sheet)
    for k, im in it.items():
        if x + im.width > W - 6: x = 6; y += rowh + 16; rowh = 0
        sheet.alpha_composite(im, (x, y + 10)); d.text((x, y), k.replace('bg.', ''), fill=(255, 255, 0, 255)); x += im.width + 12; rowh = max(rowh, im.height + 10)
    sheet = sheet.crop((0, 0, W, y + rowh + 16)); sheet.convert('RGB').save(os.path.join(ROOT, 'work', 'buildings.png')); print(len(it), sheet.size)
