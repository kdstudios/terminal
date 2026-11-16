"""Illustrations for the 16 event screens. Derived pixel art (same rules as the
rest) composited with the artist's own cleaned sprites where they fit. Each is
256x160 sheet px with its own ground strip, transparent above."""
import json, os, math
import numpy as np
from PIL import Image
from pixlib import Canvas, RAMPS, RED, YEL, ACID

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
ATLAS = os.path.join(ROOT, 'assets', 'atlas')
GROUND = [(18, 26, 18), (40, 54, 34), (68, 86, 48), (106, 128, 70)]
WOOD = [(30, 20, 14), (74, 48, 30), (116, 80, 50), (160, 118, 78)]
CLOTH = [(70, 58, 44), (130, 116, 90), (184, 170, 138), (226, 214, 182)]
WATER = [(14, 52, 30), (34, 110, 52), (84, 180, 70), (170, 240, 110)]
W, H = 128, 80
_sheets = {}


def spr(sheet, name):
    """A cleaned sprite from the artist's sheets (full colour, sheet px)."""
    if sheet not in _sheets:
        d = json.load(open(os.path.join(ATLAS, sheet + '.json')))
        _sheets[sheet] = (d, Image.open(os.path.join(ATLAS, d['image'])).convert('RGBA'))
    d, im = _sheets[sheet]
    s = d['sprites'][d['names'][name]]
    return im.crop((s['x'], s['y'], s['x'] + s['w'], s['y'] + s['h']))


def canvas(seed):
    return Canvas(W, H, seed)


def ground(c, y0=60):
    top = y0 + (np.sin(c.xx * 0.21) * 1.4 + np.sin(c.xx * 0.07 + 1) * 1.8).astype(int)
    m = c.yy >= top
    c.paint(m, GROUND, base=.5, noise=.22, edge=False, k=.8)
    for x in range(1, W, 3):
        y = int(top[0, x]) - 1
        if c.rng.rand() < .7:
            c.px([(x, y), (x, y - 1)], GROUND[3] if c.rng.rand() < .5 else GROUND[2])
    return m


def put(base, im, x, y, anchor='bottom'):
    """Composite a sheet-px image onto the (already x2) scene at sheet coords."""
    if anchor == 'bottom':
        base.alpha_composite(im, (int(x - im.width / 2), int(y - im.height)))
    else:
        base.alpha_composite(im, (int(x), int(y)))


def fin(c):
    return c.finish(2)


def vault():
    c = canvas(1); ground(c, 62)
    c.paint(c.ellipse(64, 66, 54, 38), GROUND, base=.5, noise=.2)
    c.paint(c.ellipse(64, 46, 20, 20), 'rust', base=.35)
    c.paint(c.ellipse(64, 46, 17, 17), 'steel', base=.55)
    for a in (0, 60, 120):
        r = math.radians(a)
        c.line((64 - 14 * math.cos(r), 46 - 14 * math.sin(r)), (64 + 14 * math.cos(r), 46 + 14 * math.sin(r)), RAMPS['steel'][0], 2)
    c.paint(c.ellipse(64, 46, 4.5, 4.5), 'steel', base=.8)
    for k in range(10):
        r = math.radians(k * 36); c.px([(64 + 18.5 * math.cos(r), 46 + 18.5 * math.sin(r))], RAMPS['steel'][3])
    c.paint(c.rect(92, 38, 104, 55), 'black', base=.5)
    c.paint(c.rect(94, 40, 102, 46), [(10, 40, 20), (30, 90, 40), (80, 160, 70), (160, 240, 120)], base=.6, edge=False)
    c.px([(97, 50), (98, 50), (97, 51), (98, 51)], (255, 176, 0))
    c.line((98, 55), (98, 62), RAMPS['black'][2])
    return fin(c)


def wreck():
    c = canvas(2); ground(c, 62)
    c.paint(c.poly([(20, 40), (80, 35), (86, 56), (24, 60)]), 'rust', base=.55, noise=.2)
    c.paint(c.poly([(78, 36), (96, 42), (98, 58), (84, 57)]), 'rust', base=.45, noise=.15)
    c.paint(c.poly([(24, 34), (36, 20), (46, 30), (58, 18), (72, 33), (60, 38), (30, 40)]), CLOTH, base=.55, noise=.15)
    c.paint(c.ellipse(32, 60, 8, 8), 'black', base=.5); c.paint(c.ellipse(32, 60, 3, 3), 'steel', base=.6, edge=False)
    c.paint(c.ellipse(70, 62, 8, 3), 'black', base=.4)
    for (x, y) in [(100, 54), (108, 58), (112, 50)]:
        c.paint(c.rect(x, y, x + 10, y + 8), WOOD, base=.55); c.line((x, y + 4), (x + 9, y + 4), WOOD[0])
    c.paint(c.poly([(8, 56), (18, 50), (22, 62), (10, 62)]), CLOTH, base=.5)
    for (x, y) in [(40, 8), (54, 14)]:
        c.px([(x, y), (x + 1, y + 1), (x + 2, y), (x - 1, y + 1), (x + 3, y + 1)], RAMPS['black'][2])
    return fin(c)


def shrine():
    c = canvas(3); ground(c, 62)
    for (x, y, rx, ry) in [(64, 58, 16, 6), (64, 51, 12, 5), (64, 45, 8, 4)]:
        c.paint(c.ellipse(x, y, rx, ry), 'grey', base=.55, noise=.2)
    c.paint(c.rect(62, 14, 67, 46), WOOD, base=.5, noise=.1); c.paint(c.rect(52, 22, 77, 27), WOOD, base=.5, noise=.1)
    for (a, b, col) in [((66, 24), (76, 36), (200, 50, 40)), ((64, 26), (56, 40), (230, 180, 60)), ((68, 26), (72, 44), (200, 210, 190))]:
        c.line(a, b, col)
    for x in (42, 86):
        c.paint(c.rect(x, 54, x + 4, 60), 'bone', base=.6, edge=False)
        c.px([(x + 2, 52), (x + 2, 51)], YEL); c.px([(x + 1, 52), (x + 3, 52)], (255, 140, 40))
    c.paint(c.rect(54, 46, 62, 54), CLOTH, base=.55); c.px([(58, 49), (58, 50)], RAMPS['black'][1])
    c.paint(c.ellipse(78, 58, 4, 2.5), 'steel', base=.5, edge=False)
    return fin(c)


def tunnel():
    c = canvas(4); ground(c, 64)
    c.paint(c.ellipse(64, 54, 40, 36) & (c.yy < 64), 'steel', base=.5, noise=.15)
    c.paint(c.ellipse(64, 56, 28, 28) & (c.yy < 64), 'black', base=.12, edge=False)
    for (x, y, rx, ry) in [(44, 62, 12, 7), (60, 64, 14, 8), (80, 62, 13, 7), (70, 56, 10, 6), (52, 54, 9, 5), (88, 66, 9, 5)]:
        c.paint(c.ellipse(x, y, rx, ry), 'grey', base=.5, noise=.25)
    for x in (48, 64, 78):
        c.line((x, 56), (x + 6, 40), RAMPS['rust'][2])
    c.px([(64, 22), (64, 23)], YEL); c.line((64, 12), (64, 22), RAMPS['black'][2])
    c.paint(c.rect(98, 40, 112, 50), 'rust', base=.55); c.px([(102, 44), (106, 44), (104, 46)], (255, 214, 70))
    return fin(c)


def nest():
    c = canvas(5); ground(c, 62)
    c.paint(c.ellipse(64, 60, 38, 16) & (c.yy < 70), 'flesh', base=.45, noise=.3)
    c.paint(c.ellipse(64, 54, 22, 10), [(20, 10, 10), (50, 20, 18), (84, 36, 28), (130, 60, 44)], base=.4, edge=False)
    for (x, y, r) in [(50, 50, 6), (62, 46, 7), (76, 48, 6), (88, 54, 5), (44, 58, 5)]:
        c.paint(c.ellipse(x, y, r * .8, r), 'bone', base=.55); c.px([(x - 1, y - 1), (x + 2, y + 1), (x, y + 2)], RAMPS['bone'][0])
    for (x, y) in [(30, 58), (100, 60), (40, 44)]:
        c.line((x, y), (x + 8, y - 3), RAMPS['bone'][2], 2)
    c.paint(c.ellipse(104, 56, 5, 4), 'bone', base=.6); c.px([(102, 56), (106, 56)], RAMPS['black'][0])
    for x in (24, 40, 88, 104):
        c.line((x, 58), (64, 30), RAMPS['bone'][2])
    c.eye(60, 36, RED, 0); c.eye(68, 36, RED, 0)
    return fin(c)


def drone():
    c = canvas(6); ground(c, 62)
    c.paint(c.ellipse(60, 64, 30, 5), [(10, 14, 10), (24, 30, 22), (40, 48, 32), (60, 72, 46)], base=.4, edge=False)
    c.line((60, 38), (50, 20), RAMPS['steel'][1], 2); c.line((60, 38), (74, 30), RAMPS['steel'][1], 2)
    c.paint(c.ellipse(50, 18, 14, 2.4), 'steel', base=.5); c.paint(c.ellipse(78, 28, 10, 2), 'steel', base=.4)
    c.paint(c.ellipse(60, 50, 16, 11), 'steel', base=.55, noise=.1)
    c.paint(c.ellipse(52, 52, 6, 6), [(60, 10, 10), (130, 24, 20), (230, 60, 44), (255, 150, 110)], base=.5, edge=False)
    c.line((49, 49), (54, 55), RAMPS['black'][0])
    c.paint(c.poly([(66, 46), (80, 50), (76, 58), (66, 56)]), 'rust', base=.5)
    for (x, y, r) in [(80, 36, 4), (86, 28, 5), (94, 18, 6)]:
        c.paint(c.ellipse(x, y, r, r * .8), [(20, 22, 22), (40, 44, 44), (62, 66, 66), (92, 98, 98)], base=.5, edge=False)
    c.px([(46, 58), (70, 44), (44, 46), (74, 60)], YEL)
    return fin(c)


def pond():
    c = canvas(7); ground(c, 60)
    c.paint(c.ellipse(64, 64, 42, 11), WATER, base=.5, noise=.15)
    c.paint(c.ellipse(64, 64, 30, 6), WATER, base=.72, edge=False)
    for (x, y, r) in [(50, 62, 2), (62, 66, 1.6), (78, 63, 2.4), (70, 68, 1.4), (88, 66, 1.6)]:
        c.paint(c.ellipse(x, y, r, r), WATER, base=.9, edge=True)
    c.paint(c.capsule((98, 56), (96, 22), 2.2, 1.2), WOOD, base=.4)
    for (a, b) in [((97, 36), (110, 26)), ((96, 30), (86, 20)), ((97, 42), (88, 36))]:
        c.line(a, b, WOOD[1], 1)
    c.paint(c.rect(18, 48, 28, 62), 'rust', base=.5); c.px([(20, 63), (20, 65), (21, 67)], ACID)
    c.paint(c.ellipse(36, 61, 4, 3), 'bone', base=.6); c.px([(35, 60), (37, 60)], RAMPS['black'][0])
    for (x, y) in [(30, 40), (66, 44), (78, 38)]:
        c.px([(x, y), (x + 1, y - 1), (x, y - 2), (x + 1, y - 3)], (120, 190, 90))
    return fin(c)


def signal():
    c = canvas(8); ground(c, 64)
    for (x0, x1) in [(52, 60), (76, 68)]:
        c.line((64, 8), (x0, 64), RAMPS['steel'][2], 2)
    for y in range(14, 62, 8):
        t = (y - 8) / 56; hw = 2 + 12 * t
        c.line((64 - hw, y), (64 + hw, y + 8), RAMPS['steel'][1]); c.line((64 + hw, y), (64 - hw, y + 8), RAMPS['steel'][1])
    c.line((64, 8), (64, 1), RAMPS['steel'][2]); c.px([(64, 0), (63, 0), (65, 0)], RED)
    c.paint(c.ellipse(74, 20, 6, 4), 'steel', base=.6)
    c.paint(c.rect(86, 48, 106, 64), 'rust', base=.5, noise=.15)
    c.paint(c.rect(90, 52, 96, 58), [(10, 40, 20), (30, 90, 40), (80, 160, 70), (160, 240, 120)], base=.6, edge=False)
    for r in (10, 16, 22):
        for a in range(-50, 51, 8):
            ar = math.radians(a - 90)
            c.px([(64 + r * math.cos(ar) * 1.0, 6 + r * math.sin(ar) * 0.8 - 0)], YEL if (a // 8) % 2 == 0 else (150, 200, 90))
    c.line((74, 24), (90, 50), RAMPS['black'][2])
    return fin(c)


def cave():
    c = canvas(9); ground(c, 64)
    c.paint(c.ellipse(64, 52, 52, 40) & (c.yy < 66), 'grey', base=.5, noise=.3)
    c.paint(c.ellipse(64, 56, 20, 24) & (c.yy < 66), 'black', base=.08, edge=False)
    for x in range(48, 82, 6):
        c.paint(c.poly([(x, 36), (x + 3, 36), (x + 1.5, 36 + 8 + (x % 7))]), 'grey', base=.7, edge=False)
    for (x, y) in [(34, 62), (96, 62), (30, 56)]:
        c.paint(c.ellipse(x, y, 3, 2.4), [(20, 70, 20), (50, 130, 40), (110, 200, 70), (200, 255, 130)], base=.7, edge=False)
        c.px([(x, y - 3), (x, y - 4)], (120, 200, 80))
    c.line((44, 64), (52, 62), RAMPS['bone'][2], 2); c.paint(c.ellipse(86, 63, 3, 2.4), 'bone', base=.55)
    c.px([(60, 52), (61, 52), (68, 52), (69, 52)], YEL)
    return fin(c)


def _scene_with_sprites(seed, y0, parts, extra=None):
    """Derived ground + composited artist sprites. parts: [(sheet, name, x, y_bottom, flip, scale)]."""
    c = canvas(seed); ground(c, y0)
    if extra: extra(c)
    im = fin(c)
    for (sheet, name, x, y, flip, sc) in parts:
        s = spr(sheet, name)
        if sc != 1: s = s.resize((int(s.width * sc), int(s.height * sc)), Image.LANCZOS)
        if flip: s = s.transpose(Image.FLIP_LEFT_RIGHT)
        put(im, s, x, y)
    return im


def rival():
    def x(c):
        c.paint(c.rect(60, 50, 70, 60), WOOD, base=.55); c.line((60, 55), (69, 55), WOOD[0]); c.px([(64, 52), (65, 52)], YEL)
    return _scene_with_sprites(11, 62, [('world_a', 'trooper.0', 60, 136, False, 1), ('world_a', 'trooper.1', 196, 134, False, 1)], x)


def gang():
    def x(c):
        c.paint(c.rect(46, 52, 82, 58), 'black', base=.4)
        for k in range(46, 82, 8):
            c.paint(c.poly([(k, 52), (k + 4, 52), (k + 8, 58), (k + 4, 58)]), CLOTH, base=.7, edge=False)
        c.paint(c.rect(50, 58, 54, 64), 'steel', base=.4); c.paint(c.rect(74, 58, 78, 64), 'steel', base=.4)
    return _scene_with_sprites(12, 62, [('world_a', 'trooper.2', 40, 134, False, 0.95), ('world_a', 'trooper.3', 122, 134, False, 0.95), ('world_a', 'trooper.4', 204, 134, False, 0.95), ('world_b', 'barrel.0', 232, 130, False, 0.55)], x)


def merchant():
    def x(c):
        c.paint(c.rect(28, 46, 100, 53), WOOD, base=.55, noise=.1)
        c.paint(c.poly([(24, 30), (104, 30), (112, 40), (16, 40)]), CLOTH, base=.55, noise=.1)
        for k in range(24, 104, 10):
            c.paint(c.poly([(k, 30), (k + 5, 30), (k + 8, 40), (k + 3, 40)]), [(100, 30, 24), (150, 46, 34), (190, 66, 48), (226, 100, 70)], base=.5, edge=False)
        c.line((44, 40), (44, 46), RAMPS['black'][2]); c.paint(c.ellipse(44, 47, 2.4, 3), 'bone', base=.7, edge=False); c.px([(44, 47)], YEL)
        for (xx, h) in [(38, 6), (52, 8), (64, 5), (88, 7)]:
            c.paint(c.rect(xx, 46 - h, xx + 6, 46), 'rust', base=.5)
        c.line((100, 53), (100, 62), WOOD[1]); c.line((30, 53), (30, 62), WOOD[1])
    return _scene_with_sprites(13, 62, [('world_a', 'trooper.0', 128, 132, False, 0.95)], x)


def drifter():
    def x(c):
        c.paint(c.rect(0, 64, W, 74), 'steel', base=.35, noise=.12, edge=False)
        for k in range(4, W, 16):
            c.line((k, 69), (k + 8, 69), (200, 170, 50))
    return _scene_with_sprites(14, 62, [('world_a', 'trooper.0', 100, 150, True, 1), ('derived', 'sign.stoppost', 220, 150, False, 0.8)], x)


def survivor():
    def x(c):
        c.paint(c.rect(70, 24, 104, 62), 'grey', base=.5, noise=.25)
        for k in range(30, 60, 10):
            c.line((78, k), (100, k + 2), RAMPS['grey'][0])
        c.line((72, 24), (66, 14), RAMPS['rust'][2]); c.line((98, 24), (104, 12), RAMPS['rust'][2])
        c.paint(c.ellipse(46, 62, 20, 3), CLOTH, base=.5, edge=False)
    im = _scene_with_sprites(15, 62, [], x)
    s = spr('world_a', 'trooper.1').rotate(78, expand=True, resample=Image.BICUBIC)
    put(im, s, 92, 138)
    return im


def building():
    def x(c):
        c.paint(c.rect(110, 48, 112, 62), WOOD, base=.4); c.paint(c.rect(100, 44, 122, 50), WOOD, base=.5)
    return _scene_with_sprites(16, 62, [('world_b', 'house', 120, 130, False, 1.0)], x)


def camp():
    def x(c):
        c.paint(c.ellipse(96, 60, 14, 3), CLOTH, base=.5, edge=False)
        c.paint(c.capsule((18, 56), (30, 56), 3.4), CLOTH, base=.55)
        c.paint(c.ellipse(40, 58, 4, 3), 'steel', base=.5); c.line((36, 54), (44, 54), RAMPS['steel'][1])
    im = _scene_with_sprites(17, 62, [('world_b', 'tent', 168, 138, False, 1.0), ('derived', 'camp.logs', 100, 134, False, 0.5)], x)
    return im


EVENTS = dict(vault=vault, wreck=wreck, shrine=shrine, rival=rival, tunnel=tunnel, nest=nest,
              drifter=drifter, drone=drone, pond=pond, gang=gang, merchant=merchant, survivor=survivor,
              building=building, signal=signal, camp=camp, cave=cave)


def items():
    return {'event.' + k: f() for k, f in EVENTS.items()}


if __name__ == '__main__':
    it = items()
    cols = 4; rows = 4
    sheet = Image.new('RGBA', (cols * 262, rows * 168), (20, 36, 26, 255))
    from PIL import ImageDraw
    d = ImageDraw.Draw(sheet)
    for i, (k, im) in enumerate(it.items()):
        x, y = (i % cols) * 262, (i // cols) * 168
        sheet.alpha_composite(im, (x + 3, y + 6)); d.text((x + 4, y), k, fill=(255, 255, 0, 255))
    sheet.convert('RGB').save(os.path.join(ROOT, 'work', 'events.png')); print(sheet.size)
