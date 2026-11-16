"""Campfire art for the title screen: four flame frames, a log-and-stone pile,
and a seat log. Same pixel rules as the rest (outline, 4 tones, dither)."""
import math
import numpy as np
from PIL import Image
from pixlib import Canvas, RAMPS

FLAME_OUT = [(70, 14, 6), (170, 44, 12), (240, 110, 24), (255, 176, 60)]
FLAME_MID = [(190, 60, 12), (246, 130, 28), (255, 190, 70), (255, 226, 120)]
FLAME_CORE = [(250, 170, 50), (255, 214, 96), (255, 240, 170), (255, 252, 226)]
LOG = [(30, 20, 14), (74, 48, 30), (116, 80, 50), (160, 118, 78)]


def _drop(c, cx, base, w, h, tipx):
    m = c.poly([(cx - w, base), (cx - w * .75, base - h * .45), (cx + tipx * .5, base - h * .8),
                (cx + tipx, base - h), (cx + w * .35, base - h * .55), (cx + w * .85, base - h * .35), (cx + w, base)])
    return m | c.ellipse(cx, base - w * .5, w, w * .75)


def flame(frame):
    c = Canvas(34, 46, 40 + frame)
    tips = [(-3, 1.0), (2, 0.92), (-1, 1.08), (3, 0.96)][frame]
    tip, hs = tips
    base = 44
    c.paint(_drop(c, 17, base, 12, 40 * hs, tip), FLAME_OUT, base=.55, k=.8, edge=False)
    c.paint(_drop(c, 16, base - 1, 8, 30 * hs, tip * .8), FLAME_MID, base=.55, k=.8, edge=False)
    c.paint(_drop(c, 16, base - 2, 4.5, 19 * hs, tip * .5), FLAME_CORE, base=.6, k=.7, edge=False)
    side = [(-1, 8, 5, -8), (1, 26, 6, 9), (-1, 5, 9, -6), (1, 28, 10, 7)][frame % 4]
    c.paint(c.poly([(side[1] - 3, base), (side[1] + side[3] * .5, base - 15 * hs), (side[1] + 3, base)]),
            FLAME_MID, base=.5, edge=False)
    return c.finish(2)


def logs():
    c = Canvas(64, 26, 51)
    for (a, b) in [((6, 20), (50, 10)), ((10, 10), (56, 20))]:
        c.paint(c.capsule(a, b, 4.2), LOG, base=.55, noise=.08)
        c.paint(c.ellipse(b[0], b[1], 3.4, 4), LOG, base=.82, edge=True)
    for i, (x, y, rx, ry) in enumerate([(4, 21, 5, 4), (18, 23, 5, 3), (32, 24, 5, 3), (46, 23, 5, 3), (59, 21, 5, 4)]):
        c.paint(c.ellipse(x, y, rx, ry), 'steel', base=.5 + .05 * (i % 2))
    return c.finish(2)


def seat():
    c = Canvas(64, 16, 53)
    c.paint(c.capsule((6, 8), (56, 8), 6.4), LOG, base=.5, noise=.1)
    c.paint(c.ellipse(56, 8, 4.4, 6.4), LOG, base=.85)
    c.line((10, 5), (40, 5), LOG[0]); c.line((16, 10), (48, 10), LOG[0]); c.line((22, 13), (36, 13), LOG[0])
    return c.finish(2)


ITEMS = lambda: {'camp.fire0': flame(0), 'camp.fire1': flame(1), 'camp.fire2': flame(2),
                 'camp.fire3': flame(3), 'camp.logs': logs(), 'camp.seat': seat()}

if __name__ == '__main__':
    import os
    it = ITEMS()
    sheet = Image.new('RGBA', (900, 260), (14, 22, 18, 255)); x = 6
    for k, im in it.items():
        big = im.resize((im.width * 2, im.height * 2), Image.NEAREST); sheet.alpha_composite(big, (x, 250 - big.height)); x += big.width + 8
    sheet.convert('RGB').save(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'work', 'campfire.png'))
    print('ok')
