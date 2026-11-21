"""Derived enemy sprites (all authored FACING LEFT, towards the dweller).
Each returns a pixlib.Canvas at art resolution; finish(2) gives sheet scale."""
import math
import numpy as np
from pixlib import Canvas, RAMPS, RED, YEL, ACID


def skitter():
    c = Canvas(64, 36, 3)
    for hx, kx, ky, fx in [(30, 40, 12, 44), (38, 50, 10, 54), (46, 58, 14, 60)]:   # far legs
        c.paint(c.capsule((hx, 24), (kx, ky), 1.7), 'steel', base=.3, edge=False)
        c.paint(c.capsule((kx, ky), (fx, 34), 1.4, 1.0), 'steel', base=.3, edge=False)
    body = c.ellipse(34, 22, 21, 12) & (c.yy < 31)
    c.paint(body, 'rust', base=.6, noise=.12)
    for y, x0, x1 in [(15, 20, 48), (19, 17, 52), (24, 15, 54)]:
        c.line((x0, y), (x1, y), RAMPS['rust'][0])
    c.px([(22, 13), (30, 12), (38, 12), (46, 14), (24, 22), (44, 22)], RAMPS['rust'][3])
    c.paint(c.rect(40, 7, 50, 16), 'steel', base=.5)          # scrap can on its back
    c.line((41, 10), (49, 10), RAMPS['steel'][0]); c.line((41, 13), (49, 13), RAMPS['steel'][0])
    for hx, kx, ky, fx in [(22, 13, 12, 8), (29, 24, 9, 20), (37, 33, 11, 31)]:      # near legs
        c.paint(c.capsule((hx, 25), (kx, ky), 2.0), 'steel', base=.55, edge=False)
        c.paint(c.capsule((kx, ky), (fx, 34), 1.7, 1.2), 'steel', base=.6, edge=False)
        c.px([(kx, ky), (kx + 1, ky)], RAMPS['steel'][3])
    c.paint(c.ellipse(13, 25, 8, 6), 'steel', base=.55)
    c.eye(10, 24, RED, 1)
    c.paint(c.capsule((8, 29), (5, 34), 1.4, .9), 'bone', base=.5, edge=False)
    c.paint(c.capsule((12, 30), (11, 35), 1.4, .9), 'bone', base=.5, edge=False)
    c.line((11, 20), (5, 6), RAMPS['steel'][1]); c.line((14, 19), (11, 4), RAMPS['steel'][1])
    c.px([(5, 5), (11, 3)], RED)
    return c


def hound():
    c = Canvas(72, 40, 5)
    for x in (30, 52):                                                              # far legs
        c.paint(c.capsule((x, 22), (x - 3, 31), 3.2, 2.2), 'grey', base=.3, edge=False)
        c.paint(c.capsule((x - 3, 31), (x - 2, 38), 2.2, 1.6), 'grey', base=.3, edge=False)
    c.paint(c.capsule((57, 17), (69, 8), 2.2, 1.0), 'grey', base=.45, edge=False)   # tail
    body = c.ellipse(38, 19, 17, 8) | c.ellipse(25, 20, 9, 9) | c.ellipse(51, 21, 8, 8)
    c.paint(body, 'grey', base=.55, noise=.16)
    for x in range(22, 30, 3):
        c.line((x, 17), (x + 2, 24), RAMPS['grey'][0])                              # ribs
    for x in range(29, 53, 4):
        c.paint(c.poly([(x, 12), (x + 2, 8), (x + 4, 12)]), 'grey', base=.75, edge=False)  # spine
    c.paint(c.capsule((22, 15), (12, 14), 6, 5), 'grey', base=.6, noise=.1)
    c.paint(c.ellipse(10, 14, 6, 5), 'grey', base=.62)
    c.paint(c.capsule((9, 16), (2, 17), 3, 2.2), 'grey', base=.62, edge=False)
    c.paint(c.capsule((9, 20), (3, 24), 1.9, 1.3), 'grey', base=.4, edge=False)      # open jaw
    c.line((3, 19), (9, 19), RAMPS['flesh'][0])
    c.px([(3, 18), (5, 18), (7, 18), (4, 20), (6, 20)], RAMPS['bone'][3])            # teeth
    c.paint(c.poly([(12, 10), (16, 2), (17, 11)]), 'grey', base=.45)
    c.eye(10, 12, YEL, 1)
    c.px([(4, 16), (5, 16)], RAMPS['flesh'][1])
    for x in (22, 28, 49, 56):                                                      # near legs
        c.paint(c.capsule((x, 22), (x - 3, 31), 3.4, 2.4), 'grey', base=.58, edge=False)
        c.paint(c.capsule((x - 3, 31), (x - 2, 38), 2.4, 1.7), 'grey', base=.58, edge=False)
        c.paint(c.ellipse(x - 3, 38, 3.2, 1.6), 'grey', base=.5, edge=False)
    c.spots(body, RAMPS['flesh'][1], .03)
    return c


def crawler():
    c = Canvas(76, 36, 7)
    for pts in [[(36, 18), (28, 6), (16, 10), (12, 30)], [(42, 20), (32, 4), (20, 8), (18, 32)]]:   # far arms
        for a, b, r in zip(pts, pts[1:], (2.2, 1.8, 1.4)):
            c.paint(c.capsule(a, b, r), 'pale', base=.3, edge=False)
    c.paint(c.capsule((56, 26), (68, 31), 4, 2), 'pale', base=.35, edge=False)       # dragging legs
    c.paint(c.capsule((52, 28), (62, 33), 3.5, 1.8), 'pale', base=.4, edge=False)
    c.paint(c.ellipse(40, 22, 16, 8) | c.ellipse(55, 24, 8, 6), 'pale', base=.55, noise=.14)
    for x in range(30, 52, 4):
        c.line((x, 17), (x + 2, 23), RAMPS['pale'][0])
    for pts in [[(30, 20), (22, 9), (11, 14), (7, 31)], [(36, 22), (28, 7), (15, 9), (11, 33)]]:   # near arms
        for a, b, r in zip(pts, pts[1:], (2.6, 2.1, 1.7)):
            c.paint(c.capsule(a, b, r), 'pale', base=.62, edge=False)
        c.px([pts[1], pts[2]], RAMPS['pale'][3])
        for dx in (-2, 0, 2):
            c.line(pts[3], (pts[3][0] + dx, pts[3][1] + 3), RAMPS['bone'][2])
    c.paint(c.ellipse(19, 27, 6, 5), 'pale', base=.6)
    c.paint(c.capsule((14, 30), (9, 33), 1.8, 1.2), 'pale', base=.4, edge=False)
    c.eye(17, 25, RED, 0); c.eye(21, 24, RED, 0)
    c.px([(11, 30), (13, 31), (15, 31)], RAMPS['bone'][3])
    c.spots(c.ellipse(46, 22, 14, 6), RAMPS['flesh'][2], .06)
    return c


def lurker():
    c = Canvas(44, 50, 9)
    c.paint(c.capsule((32, 18), (35, 30), 3, 2), 'pale', base=.3, edge=False)        # far arm
    c.paint(c.capsule((35, 30), (32, 44), 2, 1.4), 'pale', base=.3, edge=False)
    c.paint(c.capsule((27, 30), (26, 40), 4.5, 3), 'pale', base=.35, edge=False)     # far leg
    c.paint(c.capsule((26, 40), (24, 48), 3, 2), 'pale', base=.35, edge=False)
    c.paint(c.ellipse(24, 25, 9, 12) | c.ellipse(27, 17, 8, 7), 'pale', base=.58, noise=.1)
    for y in range(20, 32, 3):
        c.line((20, y), (27, y + 1), RAMPS['pale'][0])
    c.paint(c.capsule((22, 30), (20, 41), 4.5, 3.2), 'pale', base=.58, edge=False)    # near leg
    c.paint(c.capsule((20, 41), (18, 48), 3.2, 2.2), 'pale', base=.58, edge=False)
    c.paint(c.ellipse(17, 48, 4, 2), 'pale', base=.5, edge=False)
    c.paint(c.capsule((22, 17), (12, 30), 3, 2.2), 'pale', base=.62, edge=False)      # near arm
    c.paint(c.capsule((12, 30), (8, 44), 2.2, 1.5), 'pale', base=.62, edge=False)
    for dx in (-3, 0, 3):
        c.line((8, 44), (8 + dx, 48), RAMPS['bone'][3])
    c.paint(c.ellipse(14, 13, 6, 6), 'pale', base=.66)                               # skull
    c.paint(c.ellipse(10, 17, 3, 2), 'pale', base=.55, edge=False)
    c.px([(10, 11), (11, 11), (12, 11), (10, 12), (11, 12)], RAMPS['black'][0])
    c.px([(14, 11), (15, 11), (14, 12)], RAMPS['black'][0])
    c.px([(11, 12)], YEL); c.px([(15, 11)], YEL)
    c.line((8, 18), (12, 18), RAMPS['black'][0])
    c.px([(9, 18), (11, 18)], RAMPS['bone'][3])
    return c


def swarm():
    c = Canvas(70, 44, 11)
    rng = np.random.RandomState(4)

    def bird(cx, cy, up):
        c.paint(c.poly([(cx + 2, cy), (cx + 8, cy - 1), (cx + 8, cy + 3)]), 'black', base=.35, edge=False)  # tail
        wing = [(cx - 1, cy - 1), (cx + 3, cy - 1), (cx + 7, cy - 8 if up else cy + 6), (cx, cy - 7 if up else cy + 5)]
        c.paint(c.poly(wing), 'black', base=.4, edge=False)
        c.paint(c.ellipse(cx, cy, 3.4, 2.2), 'black', base=.6, edge=False)
        c.paint(c.ellipse(cx - 3.5, cy - 1, 1.9, 1.7), 'black', base=.65, edge=False)
        c.px([(cx - 6, cy - 1), (cx - 5, cy - 1)], RAMPS['bone'][1])
        c.px([(cx - 4, cy - 2)], RED)
    pts = []
    while len(pts) < 17:
        x, y = rng.uniform(6, 60), rng.uniform(6, 36)
        if ((x - 33) / 29) ** 2 + ((y - 21) / 17) ** 2 < 1:
            pts.append((x, y))
    for (x, y) in sorted(pts, key=lambda p: p[1]):
        bird(int(x), int(y), rng.rand() < .5)
    for _ in range(14):
        c.px([(rng.randint(2, 68), rng.randint(2, 42))], RAMPS['black'][2])
    return c


def spitter():
    c = Canvas(44, 50, 13)
    c.paint(c.capsule((27, 30), (36, 20), 3.2, 2.4), 'green', base=.35, edge=False)      # far tentacle
    c.paint(c.capsule((36, 20), (37, 10), 2.4, 1.5), 'green', base=.35, edge=False)
    c.eye(37, 8, YEL, 0)
    drum = c.rect(6, 29, 34, 49)
    c.paint(drum, 'rust', base=.58, noise=.2)
    for y in (33, 39, 45):
        c.line((6, y), (33, y), RAMPS['rust'][0])
    c.line((12, 30), (12, 48), RAMPS['rust'][3])
    c.paint(c.ellipse(20, 29, 14, 3), 'steel', base=.6)
    c.paint(c.ellipse(20, 29, 10, 1.8), 'green', base=.2, edge=False)
    c.px([(9, 40), (10, 40), (10, 41), (28, 36), (29, 36)], ACID)                          # leaking ooze
    c.paint(c.capsule((20, 29), (16, 18), 5.5, 4.2), 'green', base=.55, noise=.14)
    c.paint(c.capsule((16, 18), (10, 9), 4.2, 3.4), 'green', base=.6, edge=False)
    c.paint(c.ellipse(9, 8, 7, 5), 'green', base=.64)
    c.paint(c.capsule((9, 10), (3, 15), 2.2, 1.5), 'green', base=.4, edge=False)           # lower jaw
    c.line((3, 9), (9, 9), RAMPS['flesh'][0])
    c.px([(3, 8), (5, 8), (7, 8), (4, 10), (6, 11)], RAMPS['bone'][3])
    c.eye(11, 6, YEL, 1)
    c.px([(2, 16), (2, 17), (1, 19), (2, 21), (1, 24)], ACID)                              # acid spit
    c.px([(1, 17), (3, 18), (0, 22)], (110, 200, 50))
    return c


def colossus():
    c = Canvas(66, 70, 15)
    c.paint(c.capsule((48, 28), (56, 44), 5, 4), 'steel', base=.3, edge=False)             # far arm
    c.paint(c.ellipse(56, 47, 6, 5), 'steel', base=.3)
    c.paint(c.capsule((42, 46), (44, 63), 8, 7), 'rust', base=.35, edge=False)             # far leg
    c.paint(c.rect(34, 62, 54, 70), 'steel', base=.35)
    c.paint(c.capsule((24, 46), (22, 63), 8.5, 7.5), 'rust', base=.58, noise=.18)           # near leg
    c.paint(c.rect(11, 62, 33, 70), 'steel', base=.55)
    for y in (52, 57):
        c.line((15, y), (30, y), RAMPS['rust'][0])
    torso = c.rect(16, 22, 50, 48)
    c.paint(torso, 'rust', base=.58, noise=.2)
    c.line((33, 22), (33, 48), RAMPS['rust'][0]); c.line((16, 35), (50, 35), RAMPS['rust'][0])
    c.paint(c.poly([(20, 38), (30, 38), (28, 46), (20, 46)]), 'steel', base=.55)           # welded patch
    c.px([(21, 39), (29, 39), (21, 45), (27, 45), (18, 24), (47, 24)], RAMPS['steel'][3])
    c.spots(torso, RAMPS['rust'][3], .04)
    c.paint(c.ellipse(16, 24, 7, 6), 'black', base=.6)                                     # tyre shoulders
    c.paint(c.ellipse(50, 24, 7, 6), 'black', base=.5)
    c.paint(c.rect(24, 9, 41, 22), 'steel', base=.55)                                      # head
    c.paint(c.ellipse(30, 15, 5, 5), 'black', base=.3)
    c.paint(c.ellipse(30, 15, 3.4, 3.4), (RED and [(90, 10, 10), (170, 30, 24), (255, 70, 46), (255, 150, 110)]), base=.65, edge=False)
    c.px([(29, 14)], (255, 240, 220))
    c.line((44, 8), (44, 22), RAMPS['steel'][1], 2)                                        # stack
    c.paint(c.capsule((18, 28), (10, 40), 5.5, 4.5), 'steel', base=.6, edge=False)         # near arm
    c.paint(c.ellipse(7, 46, 7.5, 6.5), 'steel', base=.6, noise=.1)
    c.px([(4, 44), (9, 44), (4, 49), (10, 49)], RAMPS['steel'][3])
    c.line((16, 20), (12, 10), RAMPS['black'][1]); c.line((50, 20), (56, 12), RAMPS['black'][1])
    return c


def wyrm():
    c = Canvas(60, 74, 17)
    p = [np.array(v, float) for v in [(40, 70), (48, 46), (32, 30), (18, 20)]]
    def bez(t):
        return ((1 - t) ** 3) * p[0] + 3 * ((1 - t) ** 2) * t * p[1] + 3 * (1 - t) * t * t * p[2] + t ** 3 * p[3]
    c.paint(c.ellipse(38, 70, 24, 6) & (c.yy > 64), 'sand', base=.55, noise=.2)            # dune base
    n = 13
    for i in range(n):
        t = i / (n - 1)
        x, y = bez(t)
        r = 12.5 - 2.5 * math.sin(t * math.pi) + (1.5 if t > .9 else 0)
        c.paint(c.ellipse(x, y, r, r * .92), 'sand', base=.52 + .02 * (i % 2), noise=.15)
        c.line((int(x + r * .55), int(y - r * .8)), (int(x + r * .75), int(y + r * .6)), RAMPS['sand'][0])
    hx, hy = bez(1.0)
    c.paint(c.ellipse(hx - 1, hy, 13, 13), 'sand', base=.58)
    mouth = c.ellipse(hx - 7, hy + 1, 6.5, 10)
    c.paint(mouth, [(30, 10, 14), (70, 20, 24), (120, 36, 36), (170, 60, 54)], base=.25, edge=True)
    for k in range(14):                                                                    # outer ring of teeth
        a = k / 14 * 2 * math.pi
        tx, ty = hx - 7 + math.cos(a) * 6.8, hy + 1 + math.sin(a) * 10.5
        c.px([(tx, ty), (tx + (math.cos(a) * -1), ty + (math.sin(a) * -1))], RAMPS['bone'][3])
    for k in range(9):                                                                     # inner ring
        a = k / 9 * 2 * math.pi + .3
        c.px([(hx - 7 + math.cos(a) * 3.4, hy + 1 + math.sin(a) * 5.6)], RAMPS['bone'][2])
    c.eye(int(hx + 2), int(hy - 8), YEL, 0)
    return c


def sentry():
    c = Canvas(44, 48, 19)
    c.paint(c.capsule((24, 22), (30, 30), 3, 2.6), 'steel', base=.3, edge=False)           # far arm
    c.paint(c.capsule((22, 31), (24, 44), 3.4, 3), 'steel', base=.32, edge=False)          # far leg
    c.paint(c.capsule((17, 31), (15, 43), 3.8, 3.2), 'steel', base=.55, edge=False)         # near leg
    c.paint(c.rect(9, 43, 22, 48), 'rust', base=.5)
    c.paint(c.rect(26, 43, 36, 48), 'rust', base=.3)
    body = c.rect(11, 15, 33, 32)
    c.paint(body, 'rust', base=.58, noise=.2)
    for y in (19, 24, 28):
        c.line((13, y), (30, y), RAMPS['rust'][0])
    c.paint(c.rect(14, 20, 20, 26), [(60, 10, 8), (120, 20, 16), (200, 40, 30), (255, 90, 70)], base=.55, edge=False)
    c.px([(12, 16), (31, 16), (12, 30), (31, 30)], RAMPS['rust'][3])
    c.paint(c.ellipse(19, 10, 9, 6.5) & (c.yy < 14), 'steel', base=.6)                      # dome head
    c.paint(c.rect(10, 9, 28, 14), 'steel', base=.52, edge=False)
    c.eye(13, 11, RED, 1)
    c.line((24, 5), (28, 0), RAMPS['steel'][1]); c.px([(28, 0)], RED)
    c.paint(c.capsule((14, 22), (3, 25), 3.2, 3), 'steel', base=.6)                         # arm cannon
    c.paint(c.rect(0, 23, 4, 28), 'black', base=.5)
    c.px([(0, 25)], YEL)
    c.spots(body, RAMPS['rust'][3], .05)
    return c


def warmachine():
    c = Canvas(80, 50, 21)
    c.paint(c.rect(8, 35, 72, 49), 'black', base=.5)
    for x in range(14, 68, 9):
        c.paint(c.ellipse(x, 42, 4, 4), 'steel', base=.5)
        c.px([(x, 42)], RAMPS['steel'][0])
    chassis = c.poly([(12, 24), (68, 24), (72, 36), (8, 36)])
    c.paint(chassis, 'rust', base=.58, noise=.2)
    c.line((10, 30), (70, 30), RAMPS['rust'][0])
    c.px([(14, 27), (24, 27), (40, 27), (56, 27), (66, 27)], RAMPS['rust'][3])
    c.paint(c.rect(56, 8, 62, 24), 'steel', base=.45)                                      # stack
    c.paint(c.ellipse(40, 20, 17, 9) & (c.yy < 25), 'steel', base=.58)                      # turret
    c.paint(c.capsule((28, 18), (2, 20), 3, 3.6), 'steel', base=.6, edge=True)             # cannon
    c.paint(c.rect(0, 16, 5, 24), 'black', base=.5)
    c.line((10, 19), (10, 21), RAMPS['steel'][3])
    c.paint(c.ellipse(32, 17, 4, 4), [(80, 10, 10), (160, 26, 20), (255, 70, 46), (255, 160, 120)], base=.6, edge=False)
    c.px([(31, 16)], (255, 245, 225))
    c.line((46, 12), (52, 0), RAMPS['steel'][1]); c.px([(52, 0)], RED)
    c.spots(chassis, RAMPS['rust'][3], .04)
    return c


def brute():
    c = Canvas(60, 56, 23)
    c.paint(c.capsule((44, 18), (52, 34), 7, 5.5), 'pale', base=.3, edge=False)             # far arm
    c.paint(c.capsule((52, 34), (50, 48), 5.5, 4.5), 'pale', base=.3, edge=False)
    c.paint(c.ellipse(50, 50, 5, 4), 'pale', base=.3)
    c.paint(c.capsule((38, 36), (39, 52), 7, 5.5), 'pale', base=.35, edge=False)            # far leg
    c.paint(c.capsule((26, 36), (24, 52), 7.5, 6), 'pale', base=.58, edge=False)            # near leg
    c.paint(c.ellipse(22, 53, 7, 3), 'pale', base=.5)
    torso = c.ellipse(32, 26, 16, 14) | c.ellipse(24, 16, 10, 8)
    c.paint(torso, 'pale', base=.56, noise=.18)
    c.paint(c.poly([(18, 34), (46, 34), (48, 42), (16, 42)]), 'rust', base=.5, noise=.2)     # rags
    for bx, by, r in [(28, 24, 3), (38, 20, 2.5), (34, 32, 2.5), (22, 20, 2), (42, 28, 2)]:   # blisters
        c.paint(c.ellipse(bx, by, r, r), 'green', base=.62, edge=True)
        c.px([(bx - 1, by - 1)], RAMPS['green'][3])
    c.paint(c.capsule((20, 18), (10, 34), 7.5, 6), 'pale', base=.62, edge=False)             # near arm
    c.paint(c.capsule((10, 34), (8, 49), 6, 5), 'pale', base=.62, edge=False)
    c.paint(c.ellipse(8, 51, 6, 4.5), 'pale', base=.66)
    c.paint(c.ellipse(21, 9, 6, 5.5), 'pale', base=.64)                                     # small head
    c.eye(18, 8, RED, 0); c.eye(22, 8, RED, 0)
    c.line((17, 12), (23, 12), RAMPS['black'][0])
    c.px([(18, 12), (20, 12), (22, 12)], RAMPS['bone'][3])
    c.spots(torso, RAMPS['flesh'][1], .05)
    return c


CREATURES = dict(skitter=skitter, hound=hound, crawler=crawler, lurker=lurker, swarm=swarm,
                 spitter=spitter, colossus=colossus, wyrm=wyrm, sentry=sentry,
                 warmachine=warmachine, brute=brute)

if __name__ == '__main__':
    import os
    from PIL import Image
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'work')
    ims = {k: f().finish(3) for k, f in CREATURES.items()}
    W = 4 * 270; rows = (len(ims) + 3) // 4
    sheet = Image.new('RGBA', (W, rows * 250), (20, 38, 26, 255))
    from PIL import ImageDraw
    d = ImageDraw.Draw(sheet)
    for i, (k, im) in enumerate(ims.items()):
        x, y = (i % 4) * 270, (i // 4) * 250
        sheet.alpha_composite(im, (x + 10, y + 235 - im.height)); d.text((x + 4, y + 2), k, fill=(255, 255, 0, 255))
    sheet.convert('RGB').save(os.path.join(root, 'creatures.png')); print('ok', sheet.size)
