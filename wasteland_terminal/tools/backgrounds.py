"""Seamless interior wall tiles for the minigame / encounter screens, in the
sheets' muted palette. Tileable: all noise is wrap-around, features sit on the
tile grid."""
import numpy as np
from scipy import ndimage as ndi
from PIL import Image
from pixlib import BAYER, RAMPS

N = 64


def _noise(sigma, seed):
    n = ndi.gaussian_filter(np.random.RandomState(seed).rand(N, N), sigma, mode='wrap')
    return (n - n.mean()) / (n.std() + 1e-6)


def _quant(tone, ramp):
    yy, xx = np.mgrid[0:N, 0:N]
    t = tone * 3 + (BAYER[yy % 4, xx % 4] - 0.5) * 0.9
    idx = np.clip(np.round(t), 0, 3).astype(int)
    out = np.zeros((N, N, 4), np.uint8)
    for i in range(4):
        out[idx == i] = (*ramp[i], 255)
    return out, idx


def wall():
    yy, xx = np.mgrid[0:N, 0:N]
    tone = 0.42 + 0.07 * _noise(1.2, 1) + 0.05 * _noise(4, 2)
    seam = ((xx % 32) == 0) | ((yy % 32) == 0)
    bevel = ((xx % 32) == 1) | ((yy % 32) == 1)
    tone = np.where(seam, 0.05, np.where(bevel, tone + .16, tone))
    for (px, py) in [(4, 4), (27, 4), (4, 27), (27, 27)]:                     # rivets, per panel
        for ox in (0, 32):
            for oy in (0, 32):
                x, y = (px + ox) % N, (py + oy) % N
                tone[y, x] = 0.85
                tone[(y + 1) % N, (x + 1) % N] = 0.08
    pipe = (yy >= 40) & (yy <= 49)                                            # horizontal pipe band
    prof = 1 - ((yy - 44.5) / 5.0) ** 2
    tone = np.where(pipe, 0.35 + 0.5 * np.clip(prof, 0, 1) * (0.7 + 0.3 * _noise(2, 3)), tone)
    tone = np.where((yy == 39) | (yy == 50), 0.04, tone)
    clamp = ((xx % 32) >= 14) & ((xx % 32) <= 17) & (yy >= 38) & (yy <= 51)    # pipe brackets
    tone = np.where(clamp, 0.28 + 0.1 * (yy % 3), tone)
    for x in (9, 21, 44, 57):                                                 # drip stains
        L = int(np.random.RandomState(x).randint(10, 26))
        for y in range(L):
            f = 1 - y / L
            tone[(52 + y) % N, x] -= 0.22 * f
            tone[(52 + y) % N, (x + 1) % N] -= 0.10 * f
    out, _ = _quant(np.clip(tone, 0, 1), RAMPS['grey'])
    return Image.fromarray(out, 'RGBA')


def steel():
    yy, xx = np.mgrid[0:N, 0:N]
    tone = 0.46 + 0.06 * _noise(1.0, 5) + 0.05 * _noise(5, 6)
    seam = ((xx % 32) == 0) | ((yy % 32) == 0)
    tone = np.where(seam, 0.04, np.where(((xx % 32) == 1) | ((yy % 32) == 1), tone + .14, tone))
    for ox in (0, 32):
        for oy in (0, 32):
            for (px, py) in [(5, 5), (26, 5), (5, 26), (26, 26)]:
                x, y = (px + ox) % N, (py + oy) % N
                for dx, dy, v in [(0, 0, .8), (1, 0, .55), (0, 1, .55), (1, 1, .1), (-1, -1, .12)]:
                    tone[(y + dy) % N, (x + dx) % N] = v
    band = (yy >= 52) & (yy <= 61)                                            # hazard stripes
    stripe = ((xx + yy) // 5) % 2 == 0
    tone = np.where(band, np.where(stripe, 0.88, 0.1), tone)
    tone = np.where((yy == 51) | (yy == 62), 0.05, tone)
    rust = _noise(2.2, 8) > 1.1                                               # rust bloom
    out, idx = _quant(np.clip(tone, 0, 1), RAMPS['steel'])
    r = RAMPS['rust']
    for i in range(4):
        out[rust & ~band & (idx == i)] = (*r[i], 255)
    return Image.fromarray(out, 'RGBA')


BACKGROUNDS = {'bg.wall': wall, 'bg.steel': steel}

if __name__ == '__main__':
    import os
    ims = [f().resize((N * 3, N * 3), Image.NEAREST) for f in BACKGROUNDS.values()]
    sheet = Image.new('RGBA', (len(ims) * 2 * N * 3, 2 * N * 3))
    for i, im in enumerate(ims):
        for tx in range(2):
            for ty in range(2):
                sheet.alpha_composite(im, (i * 2 * N * 3 + tx * N * 3, ty * N * 3))
    sheet.convert('RGB').save(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'work', 'backgrounds.png'))
    print('ok', sheet.size)
