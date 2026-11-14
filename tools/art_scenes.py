from art_lib import *

def mk(w=96, h=64): return Canvas(w, h)

def ground(c, y=56):
    c.line([(0, y), (c.w - 1, y)], 3)
    c.dither(0, y + 1, c.w - 1, c.h - 1, 2, 0.6, 0.1)

def person(c, x, y, v=2, sit=False, hood=True):
    """Little figure: x,y = feet. 20px tall standing."""
    if sit:
        c.ell(x - 4, y - 18, x + 4, y - 10, v); c.poly([(x - 5, y - 10), (x + 5, y - 10), (x + 8, y), (x - 8, y)], v)
        c.line([(x - 8, y), (x - 16, y)], 3, 2)
    else:
        c.ell(x - 4, y - 20, x + 4, y - 12, v); c.poly([(x - 5, y - 12), (x + 5, y - 12), (x + 7, y - 2), (x - 7, y - 2)], v)
        c.line([(x - 3, y - 2), (x - 3, y)], 3, 2); c.line([(x + 3, y - 2), (x + 3, y)], 3, 2)
    c.px(x + 2, y - 17 if not sit else y - 15, 3)

def flame(c, x, y, s=1):
    c.poly([(x - 3 * s, y), (x - 2 * s, y - 5 * s), (x, y - 3 * s), (x + 1 * s, y - 8 * s), (x + 3 * s, y)], 3)

def merchant():
    c = mk(); ground(c)
    c.rect(26, 38, 62, 50, 2); c.dither(26, 38, 62, 50, 3, 0.4, 0.1)
    c.poly([(22, 38), (36, 22), (62, 22), (68, 38)], 1)
    for x in range(28, 64, 6): c.line([(x, 38), (x + 2, 23)], 2)
    for wx in (32, 56): c.ell(wx - 8, 44, wx + 8, 60, 3); c.ell(wx - 5, 47, wx + 5, 57, 0); c.px(wx, 52, 3)
    c.line([(26, 44), (12, 36)], 3, 2)
    for x in (30, 44, 58): c.line([(x, 22), (x, 18)], 3); c.ell(x - 1, 16, x + 1, 18, 3)
    person(c, 78, 56, 2)
    c.line([(82, 40), (82, 30)], 3); c.rect(80, 30, 84, 34, 3)
    c.outline(); c.save('event_merchant')

def survivor():
    c = mk(); ground(c)
    c.rect(52, 36, 92, 52, 2); c.poly([(56, 36), (64, 26), (84, 26), (88, 36)], 1); c.rect(66, 29, 80, 35, 0)
    for wx in (62, 82): c.ell(wx - 6, 48, wx + 6, 60, 3); c.ell(wx - 3, 51, wx + 3, 57, 0)
    person(c, 38, 56, 2, sit=True)
    c.dither(30, 40, 38, 50, 3, 0.7, 0.3); c.line([(36, 44), (42, 48)], 3, 2)
    for p in ((20, 54), (14, 50), (24, 49)): c.px(*p, 3)
    c.outline(); c.save('event_survivor')

def building():
    c = mk(); ground(c)
    pts = [(14, 56), (14, 24), (24, 18), (30, 26), (40, 14), (50, 22), (58, 12), (68, 20), (82, 26), (82, 56)]
    c.poly(pts, 2); c.dither(14, 14, 82, 56, 3, 0.25, 0.05)
    for wy in (28, 40):
        for wx in (20, 34, 48, 62, 74):
            if (wx + wy) % 3: c.rect(wx, wy, wx + 6, wy + 7, 0); c.line([(wx, wy + 7), (wx + 6, wy + 7)], 3)
    c.rect(40, 42, 54, 56, 0); c.line([(40, 42), (54, 42)], 3)
    for x in range(8, 92, 7): c.poly([(x, 56), (x + 3, 51), (x + 6, 56)], 1 + (x // 7) % 2)
    c.line([(58, 12), (60, 4)], 3); c.line([(60, 4), (64, 6)], 3)
    c.outline(); c.save('event_building')

def signal():
    c = mk(); ground(c)
    c.line([(40, 56), (48, 6), (56, 56)], 3, 2)
    for y in (16, 26, 36, 46):
        t = (y - 6) / 50; l = 48 - 8 * t - 1; r = 48 + 8 * t + 1
        c.line([(l, y), (r, y)], 2); c.line([(l, y), (r + 2, y + 10)], 1)
    c.ell(44, 4, 52, 10, 3)
    for r in (8, 14, 20): c.arc([48 - r, 7 - r, 48 + r, 7 + r], 200, 340, 3 if r < 20 else 2)
    c.rect(68, 40, 90, 56, 2); c.rect(72, 44, 78, 52, 0); c.line([(66, 40), (92, 40)], 3); c.line([(86, 40), (86, 30)], 3)
    c.outline(); c.save('event_signal')

def camp():
    c = mk(); ground(c)
    c.poly([(10, 56), (30, 22), (50, 56)], 2); c.dither(10, 22, 50, 56, 3, 0.3, 0.05)
    c.poly([(26, 56), (30, 36), (34, 56)], 0); c.line([(30, 22), (30, 12)], 3)
    c.line([(30, 22), (30, 56)], 1)
    for x, y in ((62, 52), (68, 54), (76, 52), (82, 54), (72, 50)): c.ell(x - 3, y - 2, x + 3, y + 3, 1 if (x % 2) else 2)
    c.dither(64, 50, 80, 56, 3, 0.6, 0.3)
    c.rect(86, 44, 94, 56, 1); c.line([(86, 46), (94, 46)], 3)
    c.outline(); c.save('event_camp')

def cave():
    c = mk(); ground(c)
    c.poly([(2, 56), (6, 28), (22, 8), (48, 2), (74, 8), (90, 28), (94, 56)], 2); c.dither(2, 2, 94, 56, 3, 0.35, 0.1)
    c.ell(28, 20, 68, 66, 0)
    for x in (34, 42, 52, 60): c.poly([(x, 22), (x + 3, 34), (x + 6, 22)], 1)
    for k in range(3): c.line([(14 + k * 3, 30), (18 + k * 3, 42)], 3)
    for p in ((40, 54), (46, 52), (52, 54)): c.px(*p, 3)
    c.ell(54, 51, 60, 56, 3); c.px(56, 53, 0); c.px(58, 53, 0)
    c.outline(); c.save('event_cave')

def vault():
    c = mk(); ground(c)
    c.rect(4, 6, 92, 56, 2); c.dither(4, 6, 92, 56, 3, 0.25, 0.05)
    for x in range(4, 92, 8): c.poly([(x, 6), (x + 4, 6), (x, 12), (x - 4, 12)], 3)
    c.ell(24, 14, 72, 62, 1); c.ell(28, 18, 68, 58, 2); c.ell(36, 26, 60, 50, 1); c.ell(42, 32, 54, 44, 3)
    for a in range(0, 360, 60):
        c.line([(48 + 6 * math.cos(math.radians(a)), 38 + 6 * math.sin(math.radians(a))),
                (48 + 20 * math.cos(math.radians(a)), 38 + 20 * math.sin(math.radians(a)))], 3)
    for a in range(30, 360, 60):
        c.ell(48 + 22 * math.cos(math.radians(a)) - 1, 38 + 22 * math.sin(math.radians(a)) - 1,
              48 + 22 * math.cos(math.radians(a)) + 1, 38 + 22 * math.sin(math.radians(a)) + 1, 3)
    c.outline(); c.save('event_vault')

def wreck():
    c = mk(); ground(c)
    c.poly([(12, 52), (22, 26), (76, 30), (86, 54)], 2); c.dither(12, 26, 86, 54, 3, 0.3, 0.05)
    c.poly([(22, 26), (30, 14), (64, 18), (76, 30)], 1)
    for x in range(30, 66, 8): c.line([(x, 17), (x + 2, 30)], 3)
    for wx, wy in ((26, 54), (70, 56)): c.ell(wx - 7, wy - 7, wx + 7, wy + 7, 3); c.ell(wx - 4, wy - 4, wx + 4, wy + 4, 0)
    for x, y in ((6, 50), (90, 50), (4, 54), (84, 46)): c.rect(x, y, x + 7, y + 6, 2); c.line([(x, y), (x + 7, y + 6)], 3)
    c.line([(40, 56), (52, 56)], 3, 2); c.ell(46, 48, 52, 54, 3)
    c.outline(); c.save('event_wreck')

def shrine():
    c = mk(); ground(c)
    for x, y, w in ((24, 56, 18), (30, 50, 14), (34, 44, 10)): c.rect(x, y - 6, x + w, y, 2); c.line([(x, y - 6), (x + w, y - 6)], 3)
    c.line([(48, 56), (48, 14)], 3, 2); c.line([(38, 24), (58, 24)], 3, 2)
    c.ell(44, 6, 52, 14, 2); c.px(46, 9, 3); c.px(50, 9, 3)
    for x in (66, 74, 82):
        c.rect(x, 46, x + 4, 56, 2); flame(c, x + 2, 46, 1)
    for x, y in ((60, 54), (90, 54), (16, 54)): c.rect(x, y - 4, x + 4, y, 1); c.px(x + 2, y - 5, 3)
    c.outline(); c.save('event_shrine')

def rival():
    c = mk(); ground(c)
    c.rect(36, 44, 60, 56, 2); c.line([(36, 44), (60, 44)], 3); c.line([(48, 44), (48, 56)], 1)
    person(c, 22, 56, 2); c.line([(26, 40), (34, 44)], 3, 2)
    person(c, 76, 56, 2); c.line([(72, 40), (64, 44)], 3, 2); c.line([(78, 40), (88, 32)], 3, 2); c.line([(88, 32), (92, 26)], 3)
    c.px(46, 40, 3); c.px(50, 40, 3)
    c.outline(); c.save('event_rival')

def tunnel():
    c = mk(); ground(c)
    c.poly([(4, 56), (4, 30), (20, 10), (48, 4), (76, 10), (92, 30), (92, 56)], 2); c.dither(4, 4, 92, 56, 3, 0.3, 0.05)
    c.poly([(26, 56), (28, 32), (48, 20), (68, 32), (70, 56)], 0)
    for k, (x, y) in enumerate(((30, 50), (40, 44), (52, 48), (60, 40), (36, 38), (46, 34))):
        c.poly([(x, y), (x + 8, y - 4), (x + 12, y + 4), (x + 4, y + 8)], 1 + k % 2)
    for x in (34, 44, 56, 64): c.line([(x, 34), (x + 6 - (x % 5), 24)], 3)
    c.line([(48, 4), (46, 20)], 3); c.dither(40, 4, 56, 30, 3, 0.4, 0.0)
    c.outline(); c.save('event_tunnel')

def nest():
    c = mk(); ground(c)
    c.poly([(8, 56), (16, 38), (34, 30), (60, 30), (80, 38), (90, 56)], 2); c.dither(8, 30, 90, 56, 3, 0.4, 0.1)
    for x, y in ((30, 36), (44, 32), (58, 36), (70, 42)):
        c.ell(x - 5, y - 6, x + 5, y + 6, 1); c.ell(x - 3, y - 4, x + 3, y + 4, 3); c.px(x, y - 1, 0)
    for k in range(12): c.line([(10 + k * 7, 52), (14 + k * 7, 44)], 3 if k % 2 else 1)
    for k in range(4): c.line([(6 + k * 2, 14), (14 + k * 2, 30)], 3)
    c.outline(); c.save('event_nest')

def drifter():
    c = mk(); ground(c)
    c.poly([(24, 56), (28, 30), (40, 20), (52, 30), (56, 56)], 2); c.dither(24, 20, 56, 56, 3, 0.3, 0.05)
    c.ell(34, 22, 46, 34, 0); c.px(38, 28, 3); c.px(42, 28, 3)
    c.line([(52, 40), (62, 46)], 3, 2)
    c.rect(66, 50, 82, 56, 1)
    flame(c, 70, 50, 1); flame(c, 76, 50, 2); flame(c, 80, 50, 1)
    c.line([(62, 38), (84, 38)], 3); c.line([(64, 38), (64, 50)], 3); c.line([(82, 38), (82, 50)], 3); c.ell(70, 38, 80, 44, 2)
    for x, y in ((8, 8), (30, 4), (66, 10), (88, 6), (50, 12)): c.px(x, y, 3)
    c.outline(); c.save('event_drifter')

def drone():
    c = mk(); ground(c)
    c.ell(28, 34, 68, 56, 2); c.dither(28, 34, 68, 56, 3, 0.4, 0.05); c.ell(40, 38, 56, 50, 1); c.ell(46, 41, 50, 47, 3)
    c.line([(28, 40), (6, 30)], 3, 2); c.line([(68, 40), (90, 28)], 3, 2)
    c.line([(0, 28), (14, 34)], 2, 2); c.line([(88, 22), (96, 30)], 2, 2)
    c.line([(36, 36), (48, 30), (60, 36)], 3)
    c.line([(48, 52), (44, 58)], 3); c.line([(34, 52), (30, 58)], 3)
    c.line([(40, 34), (44, 26)], 3); c.dither(36, 6, 56, 30, 2, 0.5, 0.0)
    c.outline(); c.save('event_drone')

def pond():
    c = mk(); ground(c)
    c.ell(14, 40, 82, 64, 1); c.dither(14, 40, 82, 64, 2, 0.7, 0.3)
    for x, y in ((30, 48), (44, 52), (60, 47), (70, 54), (36, 56)): c.ell(x - 2, y - 2, x + 2, y + 2, 3); c.px(x, y, 0)
    for r in (6, 11): c.arc([48 - r * 2, 50 - r, 48 + r * 2, 50 + r], 0, 360, 3 if r < 8 else 2)
    for x in (8, 12, 86, 90): c.line([(x, 56), (x + 2, 38)], 3); c.line([(x + 2, 38), (x + 5, 36)], 3)
    c.ell(18, 50, 24, 56, 3); c.px(20, 52, 0); c.px(22, 52, 0)
    c.outline(); c.save('event_pond')

def gang():
    c = mk(); ground(c)
    c.rect(18, 40, 78, 56, 2); c.dither(18, 40, 78, 56, 3, 0.35, 0.05)
    c.poly([(10, 56), (14, 30), (40, 30), (48, 40)], 1); c.rect(22, 34, 34, 40, 0)
    for wx in (26, 66): c.ell(wx - 6, 50, wx + 6, 62, 3); c.ell(wx - 3, 53, wx + 3, 59, 0)
    for x in range(20, 78, 6): c.line([(x, 40), (x + 3, 34), (x + 6, 40)], 3)
    c.line([(86, 56), (86, 10)], 3, 2); c.ell(81, 4, 91, 14, 2); c.px(84, 8, 0); c.px(88, 8, 0); c.line([(84, 12), (88, 12)], 0)
    for x in (80, 86, 92): c.line([(x, 20), (x, 14)], 3)
    person(c, 14, 56, 2); c.line([(18, 40), (28, 36)], 3, 2)
    c.outline(); c.save('event_gang')

# ------------------------------------------------------------------ location pictures
def terminal():
    c = Canvas(64, 56)
    c.rect(8, 4, 56, 38, 2); c.rect(12, 8, 52, 34, 0); c.rect(14, 10, 50, 32, 1)
    for y in range(13, 31, 4): c.line([(17, y), (17 + (y * 7) % 24 + 8, y)], 3)
    c.px(46, 28, 3); c.px(47, 28, 3)
    c.rect(4, 38, 60, 48, 2); c.dither(4, 38, 60, 48, 3, 0.4, 0.1)
    for x in range(10, 56, 6): c.rect(x, 42, x + 3, 44, 1)
    c.line([(60, 44), (63, 50), (63, 55)], 3)
    c.outline(); c.save('loc_terminal')

def chest():
    c = Canvas(64, 48)
    c.poly([(6, 22), (10, 8), (54, 8), (58, 22)], 2); c.dither(6, 8, 58, 22, 3, 0.3, 0.05)
    c.rect(6, 22, 58, 44, 2); c.dither(6, 22, 58, 44, 3, 0.25, 0.05)
    for x in (14, 50): c.rect(x, 8, x + 4, 44, 1); c.line([(x, 8), (x, 44)], 3)
    c.line([(6, 22), (58, 22)], 3)
    c.rect(26, 18, 38, 30, 3); c.rect(28, 20, 36, 28, 0); c.ell(30, 21, 34, 25, 3); c.rect(31, 24, 33, 28, 3)
    c.outline(); c.save('loc_chest')

def safehouse():
    c = Canvas(128, 64)
    c.line([(0, 58), (127, 58)], 3); c.dither(0, 59, 127, 63, 2, 0.6, 0.1)
    c.rect(22, 26, 104, 58, 2); c.dither(22, 26, 104, 58, 3, 0.3, 0.05)
    c.poly([(16, 28), (30, 14), (96, 14), (110, 28)], 1)
    for x in range(30, 98, 7): c.line([(x, 14), (x - 4, 28)], 2)
    c.rect(52, 36, 70, 58, 0); c.line([(52, 36), (70, 36)], 3); c.px(66, 48, 3)
    for x0 in (28, 80):
        c.rect(x0, 34, x0 + 14, 46, 0); c.line([(x0, 40), (x0 + 14, 40)], 3); c.line([(x0 + 7, 34), (x0 + 7, 46)], 3)
    c.line([(96, 14), (96, 2)], 3); c.line([(90, 6), (102, 6)], 3); c.line([(92, 10), (100, 10)], 3)
    for x in (4, 12, 108, 116): c.ell(x, 50, x + 10, 58, 1); c.line([(x, 50), (x + 10, 50)], 3)
    c.ell(58, 24, 64, 30, 3); c.line([(61, 14), (61, 24)], 3)
    c.dither(40, 2, 60, 12, 2, 0.5, 0.0)
    c.outline(); c.save('loc_safehouse')

if __name__ == '__main__':
    fns = [merchant, survivor, building, signal, camp, cave, vault, wreck, shrine, rival, tunnel, nest, drifter, drone, pond, gang, terminal, chest, safehouse]
    for f in fns: f()
    names = ['event_' + n for n in ('merchant', 'survivor', 'building', 'signal', 'camp', 'cave', 'vault', 'wreck', 'shrine', 'rival', 'tunnel', 'nest', 'drifter', 'drone', 'pond', 'gang')]
    contact_sheet(names, 4, scale=2, path='/tmp/scenes.png')
    contact_sheet(['loc_terminal', 'loc_chest', 'loc_safehouse'], 3, scale=2, path='/tmp/locs.png')
    print('ok')
