"""Held weapons for melee poses, drawn vertically with the HANDLE at the bottom
(so the game can rotate them about the grip). Same pixel rules as the rest."""
from PIL import Image
from pixlib import Canvas, RAMPS

TAPE = [(10, 12, 14), (28, 32, 38), (50, 56, 64), (82, 90, 98)]
WOOD = [(30, 20, 14), (74, 48, 30), (116, 80, 50), (160, 118, 78)]
YELLOW = [(70, 56, 10), (140, 112, 20), (214, 176, 40), (250, 224, 100)]
PLASMA = [(16, 70, 62), (36, 160, 140), (110, 240, 210), (225, 255, 246)]


def pipe():
    c = Canvas(9, 42, 61)
    c.paint(c.capsule((4.5, 3), (4.5, 39), 2.7), 'rust', base=.5, noise=.22)
    c.paint(c.rect(2, 3, 7, 6), 'steel', base=.75, edge=False)
    c.paint(c.rect(2, 27, 7, 40), TAPE, base=.45, edge=False)
    for y in range(28, 39, 3):
        c.line((2, y), (6, y + 1), TAPE[3])
    c.spots(c.rect(2, 8, 7, 26), (150, 100, 56), .08)
    return c.finish(2)


def rpipe():
    c = Canvas(15, 44, 63)
    c.paint(c.capsule((7.5, 4), (7.5, 41), 2.8), 'steel', base=.48, noise=.15)
    for y in (7, 16, 25):
        c.paint(c.rect(3, y, 12, y + 4), 'rust', base=.62, noise=.12)
        c.px([(4, y + 1), (10, y + 1)], RAMPS['rust'][3])
    for (x, y, d) in [(3, 6, -1), (12, 14, 1), (3, 23, -1)]:          # welded spikes
        c.paint(c.poly([(x, y), (x + d * 3, y + 2), (x, y + 3)]), 'steel', base=.7, edge=False)
    c.paint(c.rect(5, 30, 10, 43), TAPE, base=.45, edge=False)
    for y in range(31, 42, 3):
        c.line((5, y), (9, y + 1), TAPE[3])
    return c.finish(2)


def machete():
    c = Canvas(16, 50, 65)
    blade = c.poly([(4, 32), (11, 32), (12, 24), (12, 13), (10, 5), (6, 1), (4, 6), (4, 20)])
    c.paint(blade, 'steel', base=.58, noise=.1)
    c.line((5, 7), (5, 30), RAMPS['steel'][3])                          # honed edge
    c.px([(11, 10), (11, 11), (10, 17)], RAMPS['rust'][1])
    c.px([(4, 15), (3, 16)], (12, 14, 10))                              # a chip
    c.paint(c.rect(2, 32, 14, 35), 'rust', base=.4)
    c.paint(c.rect(5, 35, 11, 49), WOOD, base=.5, noise=.1)
    for y in range(37, 48, 3):
        c.line((5, y), (10, y + 1), WOOD[0])
    c.px([(7, 38), (7, 44)], RAMPS['steel'][3])
    return c.finish(2)


def cutter():
    c = Canvas(22, 44, 67)
    c.paint(c.rect(7, 12, 15, 17), 'steel', base=.4)                    # nozzle
    c.paint(c.rect(9, 5, 13, 12), 'steel', base=.35)
    c.paint(c.ellipse(11, 4, 3.4, 3.4), PLASMA, base=.65, edge=False)
    c.px([(10, 3)], (255, 255, 250))
    c.paint(c.rect(4, 17, 18, 35), 'steel', base=.55)
    c.paint(c.poly([(4, 21), (18, 17), (18, 21), (4, 25)]), YELLOW, base=.55, edge=False)   # hazard band
    c.paint(c.poly([(4, 29), (18, 25), (18, 29), (4, 33)]), YELLOW, base=.55, edge=False)
    c.paint(c.rect(8, 35, 14, 43), TAPE, base=.45)
    c.paint(c.capsule((18, 28), (21, 36), 1.2), TAPE, base=.4, edge=False)  # feed hose
    c.px([(6, 19), (16, 33)], RAMPS['steel'][3])
    return c.finish(2)


ITEMS = lambda: {'wpn.pipe': pipe(), 'wpn.rpipe': rpipe(), 'wpn.machete': machete(), 'wpn.cutter': cutter()}

if __name__ == '__main__':
    import os
    it = ITEMS()
    sheet = Image.new('RGBA', (520, 330), (22, 40, 28, 255)); x = 10
    for k, im in it.items():
        big = im.resize((im.width * 3, im.height * 3), Image.NEAREST); sheet.alpha_composite(big, (x, 320 - big.height)); x += big.width + 16
    sheet.convert('RGB').save(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'work', 'weapons.png')); print('ok')
