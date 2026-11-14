from art_lib import *

def mk(w=64, h=64): return Canvas(w, h)

# ------------------------------------------------------------------ enemies (64x64)
def skitter():
    c = mk()
    for i, x in enumerate([16, 24, 32, 40]):
        c.line([(x, 40), (x - 6 + (i % 2) * 2, 50), (x - 8, 60)], 3)
        c.line([(x + 2, 34), (x + 6, 28), (x + 8, 24)], 2)
    c.ell(8, 28, 52, 50, 2); c.ell(12, 31, 48, 46, 1)
    c.poly([(12, 30), (30, 22), (48, 30)], 2)
    for x in range(16, 46, 6): c.line([(x, 31), (x + 2, 44)], 1)
    c.ell(46, 32, 58, 46, 2)
    for p in ((51, 36), (52, 36), (55, 39)): c.px(*p, 3)
    c.line([(56, 44), (62, 50)], 3); c.line([(54, 46), (58, 54)], 3)
    c.line([(54, 32), (60, 22)], 3); c.line([(50, 31), (54, 20)], 3)
    c.outline(); c.save('enemy_skitter')

def hound():
    c = mk()
    for x0, x1 in ((16, 12), (22, 24), (36, 34), (42, 46)):
        c.line([(x0, 40), (x0 - 2, 50), (x1, 60)], 3, 2)
    c.ell(10, 24, 48, 44, 2); c.ell(14, 28, 44, 42, 1)
    for x in range(16, 44, 5): c.line([(x, 30), (x + 1, 40)], 2)
    c.poly([(44, 24), (58, 26), (63, 36), (54, 42), (44, 38)], 2)
    c.poly([(48, 24), (51, 14), (54, 25)], 3)
    for x in (52, 55, 58): c.px(x, 41, 3); c.px(x, 42, 3)
    c.px(54, 30, 3); c.px(55, 30, 3)
    c.line([(10, 28), (4, 20), (2, 12)], 3, 2)
    for x in range(14, 44, 4): c.px(x, 23, 3)
    c.outline(); c.save('enemy_hound')

def sentry():
    c = mk()
    c.rect(14, 46, 52, 58, 2); c.dither(14, 46, 52, 58, 3, 0.5, 0.2)
    for x in (20, 33, 46): c.ell(x - 5, 49, x + 5, 59, 1); c.px(x, 54, 3)
    c.rect(22, 16, 44, 44, 2); c.rect(25, 19, 41, 41, 1)
    for y in (24, 32, 38): c.line([(25, y), (41, y)], 3)
    c.rect(26, 4, 40, 14, 2); c.rect(30, 7, 36, 11, 1); c.px(33, 9, 3); c.px(32, 9, 3); c.px(34, 9, 3)
    c.line([(33, 4), (33, 0)], 3)
    c.rect(4, 22, 22, 28, 2); c.rect(0, 23, 6, 27, 3)
    c.rect(44, 22, 52, 36, 2)
    for p in ((24, 18), (42, 18), (24, 42), (42, 42)): c.px(*p, 3)
    c.outline(); c.save('enemy_sentry')

def raider():
    c = mk()
    c.line([(28, 40), (24, 60)], 3, 3); c.line([(34, 40), (40, 60)], 3, 3)
    c.rect(22, 20, 40, 42, 2); c.dither(22, 20, 40, 42, 3, 0.4, 0.1)
    c.line([(22, 22), (40, 38)], 3, 2)
    c.ell(24, 6, 38, 20, 2); c.rect(25, 12, 37, 18, 1); c.px(29, 14, 3); c.px(34, 14, 3)
    c.poly([(18, 18), (22, 14), (26, 22)], 3); c.poly([(36, 14), (42, 12), (40, 22)], 3)
    c.line([(40, 24), (52, 30)], 3, 2); c.line([(46, 27), (62, 24)], 3, 2); c.rect(54, 22, 62, 26, 2)
    c.line([(22, 24), (16, 34)], 3, 2)
    c.outline(); c.save('enemy_raider')

def crawler():
    c = mk()
    for i in range(7):
        x = 6 + i * 8
        c.ell(x - 5, 32 - (i % 2) * 2, x + 6, 46 - (i % 2) * 2, 2 if i % 2 == 0 else 1)
        c.line([(x, 44), (x - 4, 54), (x - 6, 60)], 3)
        c.line([(x + 2, 44), (x + 6, 54), (x + 8, 60)], 3)
    c.ell(50, 28, 62, 44, 2)
    c.px(55, 33, 3); c.px(58, 33, 3); c.line([(56, 42), (62, 38)], 3); c.line([(56, 44), (62, 46)], 3)
    c.dither(6, 32, 52, 36, 3, 0.7, 0.0)
    c.outline(); c.save('enemy_crawler')

def brute():
    c = mk()
    c.line([(24, 46), (20, 60)], 3, 4); c.line([(40, 46), (44, 60)], 3, 4)
    c.ell(14, 16, 50, 52, 2); c.ell(20, 22, 44, 46, 1)
    c.ell(26, 6, 38, 18, 2); c.px(30, 11, 3); c.px(34, 11, 3); c.line([(29, 15), (35, 15)], 3)
    c.ell(2, 22, 18, 56, 2); c.ell(46, 22, 62, 56, 2)
    c.ell(0, 50, 12, 62, 3); c.ell(52, 50, 64, 62, 3)
    for p in ((24, 26), (38, 30), (30, 38), (42, 22), (18, 36), (50, 40), (8, 34), (56, 34)):
        c.ell(p[0] - 1, p[1] - 1, p[0] + 1, p[1] + 1, 3)
    c.dither(14, 16, 50, 52, 3, 0.35, 0.05)
    c.outline(); c.save('enemy_brute')

def lurker():
    c = mk()
    c.ell(24, 4, 40, 26, 2); c.ell(28, 8, 36, 22, 1)
    c.px(29, 14, 3); c.px(30, 14, 3); c.px(34, 14, 3); c.px(35, 14, 3)
    c.line([(28, 22), (36, 22)], 3); c.line([(29, 22), (29, 25)], 3); c.line([(35, 22), (35, 25)], 3)
    c.poly([(26, 26), (38, 26), (36, 50), (28, 50)], 2)
    for x in (30, 33, 36): c.line([(x, 28), (x, 48)], 1)
    c.line([(26, 28), (14, 44), (10, 62)], 3, 2); c.line([(38, 28), (50, 44), (54, 62)], 3, 2)
    for dx in (-3, 0, 3): c.line([(10 + dx, 60), (8 + dx * 2, 63)], 3); c.line([(54 + dx, 60), (56 + dx * 2, 63)], 3)
    c.line([(30, 50), (28, 62)], 3, 2); c.line([(34, 50), (38, 62)], 3, 2)
    c.outline(); c.save('enemy_lurker')

def warmachine():
    c = mk()
    for x in (14, 30, 46): c.line([(x, 40), (x - 4, 52), (x - 6, 62)], 3, 3)
    c.rect(8, 24, 56, 42, 2); c.dither(8, 24, 56, 42, 3, 0.45, 0.1)
    for x in range(10, 56, 8): c.line([(x, 24), (x - 4, 42)], 1, 2)
    c.rect(18, 10, 46, 24, 2); c.rect(22, 13, 42, 21, 1); c.px(32, 17, 3); c.px(31, 17, 3); c.px(33, 17, 3)
    c.rect(0, 12, 18, 16, 2); c.rect(0, 20, 18, 24, 2); c.rect(46, 14, 64, 18, 2)
    c.line([(32, 10), (32, 2)], 3); c.ell(30, 0, 34, 4, 3)
    for p in ((10, 26), (54, 26), (10, 40), (54, 40)): c.px(*p, 3)
    c.outline(); c.save('enemy_warmachine')

def swarm():
    c = mk()
    rng = random.Random(4)
    for _ in range(16):
        x, y = rng.randint(8, 56), rng.randint(8, 52)
        v = rng.choice([2, 3, 3])
        c.line([(x - 4, y - 3), (x, y), (x + 4, y - 3)], v)
        c.px(x, y + 1, 3)
    for x, y in ((24, 28), (38, 22), (32, 38), (46, 34), (18, 40)):
        c.line([(x - 6, y - 4), (x, y), (x + 6, y - 4)], 3, 2); c.px(x, y + 2, 3); c.px(x, y + 3, 3)
    c.save('enemy_swarm')

def spitter():
    c = mk()
    c.line([(20, 44), (16, 60)], 3, 3); c.line([(34, 46), (38, 60)], 3, 3)
    c.ell(10, 20, 46, 52, 2); c.ell(16, 26, 40, 46, 1)
    for p in ((20, 30), (30, 26), (36, 36), (24, 40)): c.ell(p[0] - 2, p[1] - 2, p[0] + 2, p[1] + 2, 3)
    c.poly([(42, 28), (60, 20), (62, 34), (60, 46), (42, 42)], 2); c.poly([(46, 32), (60, 28), (58, 40), (46, 38)], 0)
    for y in (30, 34, 38): c.line([(48, y), (58, y)], 3)
    for x in (12, 18, 24, 30): c.poly([(x, 20), (x + 3, 8), (x + 6, 20)], 3)
    for p in ((61, 48), (60, 54), (62, 60)): c.ell(p[0] - 1, p[1] - 1, p[0] + 1, p[1] + 1, 3)
    c.outline(); c.save('enemy_spitter')

def colossus():
    c = mk()
    c.rect(18, 44, 46, 62, 2); c.rect(22, 48, 42, 58, 1)
    c.ell(6, 40, 26, 62, 1); c.ell(10, 44, 22, 58, 0); c.ell(38, 40, 58, 62, 1); c.ell(42, 44, 54, 58, 0)
    c.rect(14, 22, 50, 46, 2); c.dither(14, 22, 50, 46, 3, 0.4, 0.1)
    c.rect(22, 6, 42, 22, 2); c.ell(26, 8, 38, 20, 1); c.ell(30, 12, 34, 16, 3)
    c.rect(0, 24, 14, 32, 2); c.rect(0, 32, 8, 48, 2); c.rect(50, 26, 64, 34, 2); c.rect(58, 34, 64, 50, 2)
    c.line([(20, 22), (16, 8)], 3, 2); c.line([(44, 22), (50, 10)], 3, 2)
    for x in range(16, 50, 8): c.line([(x, 24), (x, 44)], 1)
    c.outline(); c.save('enemy_colossus')

def captain():
    c = mk()
    c.line([(28, 44), (26, 62)], 3, 3); c.line([(36, 44), (40, 62)], 3, 3)
    c.poly([(18, 20), (46, 20), (50, 48), (14, 48)], 2); c.dither(14, 20, 50, 48, 3, 0.4, 0.05)
    c.rect(30, 24, 34, 46, 1)
    c.ell(24, 4, 40, 20, 2); c.rect(26, 12, 38, 18, 1); c.px(30, 14, 3); c.px(34, 14, 3)
    c.poly([(22, 10), (16, 2), (26, 6)], 3); c.poly([(42, 10), (48, 2), (38, 6)], 3)
    c.ell(10, 16, 24, 26, 3); c.ell(40, 16, 54, 26, 3)
    c.line([(44, 28), (58, 34)], 3, 2); c.line([(50, 30), (63, 24)], 3, 3); c.rect(54, 22, 63, 27, 2)
    c.line([(16, 30), (10, 44)], 3, 2)
    c.outline(); c.save('enemy_captain')

def straggler():
    c = mk()
    c.line([(26, 42), (22, 60)], 3, 3); c.line([(36, 42), (42, 60)], 3, 3)
    c.poly([(20, 20), (38, 18), (44, 44), (22, 46)], 2); c.dither(20, 18, 44, 46, 3, 0.45, 0.1)
    for x, y in ((24, 30), (34, 36), (28, 42)): c.line([(x, y), (x + 6, y + 2)], 1)
    c.ell(34, 6, 50, 22, 2); c.px(40, 12, 3); c.px(46, 12, 3); c.rect(40, 17, 46, 20, 0)
    c.line([(40, 20), (46, 20)], 3)
    c.line([(24, 24), (12, 42), (8, 62)], 3, 2); c.line([(38, 24), (54, 38), (60, 54)], 3, 2)
    for dx in (-2, 1, 4): c.line([(8 + dx, 60), (6 + dx * 2, 63)], 3); c.line([(60 + dx, 52), (62 + dx, 56)], 3)
    c.outline(); c.save('enemy_straggler')

def wyrm():
    c = mk()
    c.dither(0, 52, 63, 63, 2, 0.6, 0.2)
    pts = []
    for i in range(10):
        t = i / 9.0
        x = 8 + t * 46
        y = 60 - math.sin(t * math.pi) * 48 + t * 6
        r = 9 - t * 3
        c.ell(x - r, y - r, x + r, y + r, 2 if i % 2 == 0 else 1)
        c.arc([x - r, y - r, x + r, y + r], 200, 340, 3)
    hx, hy = 56, 14
    c.ell(hx - 9, hy - 9, hx + 9, hy + 9, 2); c.ell(hx - 5, hy - 4, hx + 5, hy + 7, 0)
    for a in range(0, 360, 45):
        c.px(hx + 4 * math.cos(math.radians(a)), hy + 1 + 5 * math.sin(math.radians(a)), 3)
    c.px(hx - 4, hy - 7, 3); c.px(hx + 4, hy - 7, 3)
    c.outline(); c.save('enemy_wyrm')

# ------------------------------------------------------------------ player (32x48, 4 walk frames)
def player(frame):
    c = Canvas(32, 48)
    la, lb = [(-5, 5), (-2, 2), (5, -5), (2, -2)][frame]
    bob = [0, -1, 0, -1][frame]
    # legs
    c.line([(14, 30 + bob), (13 + la, 46)], 3, 3)
    c.line([(18, 30 + bob), (19 + lb, 46)], 2, 3)
    c.line([(13 + la, 46), (16 + la, 46)], 3, 2)
    c.line([(19 + lb, 46), (22 + lb, 46)], 3, 2)
    # pack
    c.rect(4, 14 + bob, 11, 29 + bob, 1); c.rect(5, 15 + bob, 10, 18 + bob, 2); c.line([(7, 20 + bob), (7, 27 + bob)], 3)
    # torso + hood
    c.rect(11, 14 + bob, 22, 31 + bob, 2); c.dither(11, 14 + bob, 22, 31 + bob, 3, 0.35, 0.05)
    c.ell(11, 2 + bob, 24, 16 + bob, 2); c.ell(17, 6 + bob, 24, 14 + bob, 0); c.px(21, 10 + bob, 3)
    c.line([(12, 14 + bob), (22, 14 + bob)], 3)
    # arm + rifle
    sw_a = [3, 0, -3, 0][frame]
    c.line([(19, 17 + bob), (23 + sw_a, 25 + bob)], 3, 2)
    c.line([(5, 15 + bob), (28, 28 + bob)], 3)
    c.outline(); c.save('player_%d' % frame)

if __name__ == '__main__':
    for fn in (skitter, hound, sentry, raider, crawler, brute, lurker, warmachine, swarm, spitter, colossus, captain, straggler, wyrm):
        fn()
    for f in range(4): player(f)
    names = ['enemy_' + n for n in ('skitter', 'hound', 'sentry', 'raider', 'crawler', 'brute', 'lurker', 'warmachine', 'swarm', 'spitter', 'colossus', 'captain', 'straggler', 'wyrm')]
    contact_sheet(names, 7, scale=3, path='/tmp/enemies.png')
    contact_sheet(['player_%d' % i for i in range(4)], 4, scale=5, path='/tmp/player.png')
    print('ok')
