"""Derived sky / horizon art: seamless ridge tiles and cloud banks, same pixel
rules as the rest (hard edges, ordered dither, few tones). Ridges tile
horizontally, so they scroll forever; the scene tints them with the phosphor
filter and dims them with distance."""
import math
import numpy as np
from PIL import Image
from pixlib import Canvas, BAYER

W, H = 256, 44          # art pixels per ridge tile (drawn at 2x)
RIDGE = [(22, 30, 26), (46, 58, 50), (78, 94, 82), (116, 134, 116)]
CLOUD = [(54, 66, 62), (96, 110, 104), (146, 160, 152), (196, 208, 200)]


def _periodic(rng, octaves):
    x = np.arange(W)
    h = np.zeros(W)
    for k, a in octaves:
        h += a * np.sin(2 * math.pi * k * x / W + rng.uniform(0, 6.28))
    return h


def _ridge(height_fn, seed, tex=0.0):
    rng = np.random.RandomState(seed)
    top = height_fn(rng)                                # ridge height (px above tile bottom) per column
    yy, xx = np.mgrid[0:H, 0:W]
    surf = (H - 1 - top)[None, :]
    inside = yy >= surf
    depth = np.clip((yy - surf) / 14.0, 0, 1)           # 0 at the crest, 1 deeper in
    tone = 0.85 - 0.55 * depth - 0.12 * (yy / H)
    if tex:
        tone += (rng.rand(H, W) - 0.5) * tex
    t = tone * 3 + (BAYER[yy % 4, xx % 4] - 0.5) * 0.9
    idx = np.clip(np.round(t), 0, 3).astype(int)
    out = np.zeros((H, W, 4), np.uint8)
    for i in range(4):
        out[inside & (idx == i)] = (*RIDGE[i], 255)
    crest = inside & ~np.roll(inside, 1, axis=0)         # 1px dark crest line
    out[crest] = (12, 16, 12, 255)
    return Image.fromarray(out, 'RGBA').resize((W * 2, H * 2), Image.NEAREST)


def hills():
    def f(rng):
        h = _periodic(rng, [(1, 5), (2, 3.5), (3, 2.2), (5, 1.2)])
        return np.round(18 + h).astype(int).clip(6, H - 2)
    return _ridge(f, 3)


def mountains():
    def f(rng):
        h = np.abs(_periodic(rng, [(2, 9), (3, 6), (5, 3), (9, 1.4)]))
        return np.round(8 + h * 1.5).astype(int).clip(6, H - 2)
    return _ridge(f, 5, tex=0.1)


def treeline():
    rng = np.random.RandomState(9)
    top = np.full(W, 14.0)
    x = 0
    while x < W:                                         # pines (triangles) and rounded crowns
        wdt = rng.randint(8, 17)
        hgt = rng.randint(10, 28)
        pine = rng.rand() < 0.62
        for i in range(wdt):
            xi = (x + i) % W
            u = (i + 0.5) / wdt
            prof = hgt * (1 - abs(2 * u - 1)) if pine else hgt * 0.8 * math.sqrt(max(0, 1 - (2 * u - 1) ** 2))
            top[xi] = max(top[xi], 10 + prof)
        x += rng.randint(5, 11)
    return _ridge(lambda r: np.round(top).astype(int).clip(6, H - 2), 11, tex=0.12)


CLOUD_DARK = [(36, 48, 46), (64, 80, 76), (98, 114, 108), (140, 156, 148)]


def _puffs(c, rng, n, ramp, y0, hgt, spread=1.0, x0=None, x1=None, bump=True):
    """Overlapping lit puffs (each its own bulge + upper-left light), biggest in
    the middle, so the whole silhouette is rounded: scalloped top AND bottom."""
    x0 = 6 if x0 is None else x0
    x1 = c.w - 6 if x1 is None else x1
    puffs = []
    for i in range(n):
        u = (i + 0.5) / n
        env = (1 - abs(2 * u - 1) ** 1.6) if bump else 0.7
        r = hgt * rng.uniform(0.2, 0.32) * (0.55 + 0.75 * env)
        cx = x0 + u * (x1 - x0) + rng.uniform(-2, 2) * spread
        cy = y0 - r * rng.uniform(0.35, 0.8) + rng.uniform(-1.5, 1.5)
        puffs.append((r, cx, cy))
    for r, cx, cy in sorted(puffs, key=lambda p: -p[0]):          # big first, small on top
        c.paint(c.ellipse(cx, cy, r * rng.uniform(1.1, 1.45), r), ramp, base=0.56, k=1.15, edge=False)
    return puffs


def _cumulus(w, h, seed, n, layered=False, tall=False):
    c = Canvas(w, h, seed)
    rng = np.random.RandomState(seed)
    if layered:                                            # a darker bank behind a lighter one
        _puffs(c, rng, n + 1, CLOUD_DARK, h * 0.55, h * 0.8, x0=2, x1=w - 10)
        _puffs(c, rng, n, CLOUD, h * 0.72, h * 0.9, x0=10, x1=w - 4)
    elif tall:                                             # stacked, towering
        for k, (yy, sc) in enumerate([(h * 0.9, 1.0), (h * 0.62, 0.82), (h * 0.38, 0.6)]):
            _puffs(c, rng, 3, CLOUD if k else CLOUD_DARK, yy, h * 0.55 * sc, x0=w * 0.12 + k * 5, x1=w * 0.88 - k * 5)
    else:
        _puffs(c, rng, n, CLOUD, h * 0.7, h * 0.95)
    return c.finish(2, outline=(58, 72, 68))


def _wisp(w, h, seed):
    c = Canvas(w, h, seed)
    rng = np.random.RandomState(seed)
    for k in range(3):
        cy = h * (0.25 + 0.25 * k) + rng.uniform(-1, 1)
        cx = w * rng.uniform(0.35, 0.65)
        c.paint(c.ellipse(cx, cy, w * rng.uniform(0.28, 0.45), h * 0.16), CLOUD, base=0.62, k=0.8, edge=False)
    return c.finish(2, outline=None)


def clouds():
    return {
        'sky.cloud0': _cumulus(64, 34, 31, 3),                   # small puff group
        'sky.cloud1': _cumulus(96, 44, 32, 4),                   # medium
        'sky.cloud2': _cumulus(150, 56, 33, 6),                  # wide bank
        'sky.cloud3': _cumulus(130, 72, 34, 5, layered=True),    # big, two-tone layered
        'sky.cloud4': _cumulus(80, 90, 35, 3, tall=True),        # towering cumulus
        'sky.cloud5': _wisp(120, 22, 36),                        # thin streaks
        'sky.cloud6': _cumulus(46, 28, 37, 2),                   # little single puff
        'sky.cloud7': _cumulus(180, 68, 38, 6, layered=True),    # huge layered bank
    }


ITEMS = lambda: {'ridge.hills': hills(), 'ridge.mountains': mountains(), 'ridge.treeline': treeline(), **clouds()}

if __name__ == '__main__':
    import os
    it = ITEMS()
    sheet = Image.new('RGBA', (W * 2 * 2 + 40, 3 * 100 + 330), (24, 52, 34, 255))
    y = 4
    for k in ('ridge.hills', 'ridge.mountains', 'ridge.treeline'):
        for t in range(2):
            sheet.alpha_composite(it[k], (t * W * 2, y))
        y += it[k].height + 8
    x = 4
    for k in [k for k in it if k.startswith('sky.cloud')]:
        sheet.alpha_composite(it[k], (x, y)); x += it[k].width + 8
    sheet.convert('RGB').save(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'work', 'skyline.png'))
    print('ok')
