from art_lib import *

W, H, GY = 256, 120, 96   # layer width (tiles horizontally), height, ground line


def put(x, fn):
    for ox in (-W, 0, W):
        fn(x + ox)

def sky(c, top=0.0, bot=0.5):
    c.dither(0, 0, W - 1, GY, 1, top, bot)

def sun(c, x, y, r, halo=14, core=3, glow=2):
    for yy in range(y - r - halo, y + r + halo + 1):
        for xx in range(x - r - halo, x + r + halo + 1):
            d = math.hypot(xx - x, yy - y)
            if d <= r:
                c.px(xx, yy, core)
            elif d <= r + halo and 0 <= yy < GY and BAYER[yy % 4][xx % 4] < (1 - (d - r) / halo) * 0.85:
                c.px(xx, yy, glow)

def ash(c, seed, n=70):
    rng = random.Random(seed)
    for _ in range(n): c.px(rng.randint(0, W - 1), rng.randint(0, GY - 6), 2)

# ---------------------------------------------------------------- props (each returns fn(ox))
def building(c, w, h, fill, seed, base=GY, holes=True, edge=3, ant=False):
    rng = random.Random(seed)
    segs = max(2, w // 7)
    tops = [rng.randint(0, max(1, h // 5)) for _ in range(segs + 1)]
    wins = [(wx, wy) for wy in range(6, h - 4, 7) for wx in range(3, w - 4, 6) if rng.random() < 0.5]
    def fn(ox):
        pts = [(ox, base), (ox, base - h)] + [(ox + i * w / segs, base - h + tops[i]) for i in range(1, segs)] + [(ox + w, base - h), (ox + w, base)]
        c.poly(pts, fill)
        if edge: c.line(pts[1:-1], edge)
        for wx, wy in wins: c.rect(ox + wx, base - h + wy, ox + wx + 2, base - h + wy + 3, 0 if holes else 2)
        if ant: c.line([(ox + w // 2, base - h), (ox + w // 2, base - h - 10)], edge or 2)
    return fn

def mesa(c, w, h, fill=1, base=GY):
    def fn(ox): c.poly([(ox, base), (ox + w * 0.15, base - h), (ox + w * 0.85, base - h), (ox + w, base)], fill)
    return fn

def pole(c, span, base=GY):
    def fn(ox):
        c.line([(ox, base), (ox, base - 34)], 3, 2); c.line([(ox - 6, base - 30), (ox + 6, base - 30)], 3); c.line([(ox - 4, base - 25), (ox + 4, base - 25)], 3)
        for k in (-5, 0, 5):
            pts = [(ox + k, base - 30 + 0)]
            for i in range(1, 9):
                t = i / 8; pts.append((ox + k + span * t, base - 30 + math.sin(t * math.pi) * 8))
            c.line(pts, 2)
    return fn

def car(c, base=GY, tilt=0):
    def fn(ox):
        c.rect(ox, base - 12, ox + 44, base - 3, 2); c.poly([(ox + 8, base - 12), (ox + 14, base - 21), (ox + 30, base - 21), (ox + 37, base - 12)], 2)
        c.rect(ox + 15, base - 19, ox + 22, base - 13, 0); c.rect(ox + 25, base - 19, ox + 31, base - 13, 0)
        c.line([(ox, base - 12), (ox + 8, base - 12), (ox + 14, base - 21), (ox + 30, base - 21), (ox + 37, base - 12), (ox + 44, base - 12)], 3)
        for wx in (8, 35): c.ell(ox + wx - 6, base - 9, ox + wx + 6, base + 3, 3); c.ell(ox + wx - 3, base - 6, ox + wx + 3, base, 0)
        c.dither(ox, base - 12, ox + 44, base - 3, 3, 0.3, 0.1)
    return fn

def sign(c, base=GY):
    def fn(ox):
        c.line([(ox, base), (ox, base - 30)], 3, 2); c.rect(ox - 12, base - 40, ox + 14, base - 26, 2)
        c.rect(ox - 10, base - 38, ox + 12, base - 28, 1); c.line([(ox - 8, base - 33), (ox + 8, base - 33)], 3); c.line([(ox - 12, base - 40), (ox + 14, base - 40)], 3)
    return fn

def shrub(c, base=GY, seed=1):
    rng = random.Random(seed)
    def fn(ox):
        for k in range(7):
            a = -0.2 - k * 0.45; l = rng.randint(7, 13)
            c.line([(ox, base), (ox + math.cos(a) * l * 1.3, base - abs(math.sin(a)) * l)], 3)
    return fn

def container(c, w=34, h=14, base=GY, level=0):
    def fn(ox):
        y = base - h * (level + 1)
        c.rect(ox, y, ox + w, y + h, 2); c.rect(ox, y, ox + w, y + h, 2)
        for x in range(ox + 3, ox + w, 4): c.line([(x, y + 1), (x, y + h - 1)], 1)
        c.line([(ox, y), (ox + w, y)], 3); c.line([(ox, y + h), (ox + w, y + h)], 3)
    return fn

def barrel(c, base=GY):
    def fn(ox):
        c.rect(ox, base - 12, ox + 9, base, 2); c.line([(ox, base - 8), (ox + 9, base - 8)], 3); c.line([(ox, base - 4), (ox + 9, base - 4)], 3); c.line([(ox, base - 12), (ox + 9, base - 12)], 3)
    return fn

def fence(c, w=60, base=GY):
    def fn(ox):
        for x in range(0, w + 1, 10): c.line([(ox + x, base), (ox + x, base - 18)], 3)
        for y in (6, 14): c.line([(ox, base - y), (ox + w, base - y)], 2)
        for x in range(0, w, 10): c.line([(ox + x, base - 14), (ox + x + 10, base - 6)], 1); c.line([(ox + x + 10, base - 14), (ox + x, base - 6)], 1)
        c.line([(ox + 24, base - 18), (ox + 30, base - 8)], 0)
    return fn

def tower(c, base=GY):
    def fn(ox):
        for x in (-8, 8): c.line([(ox + x, base), (ox + x * 0.8, base - 30)], 3)
        c.line([(ox - 8, base - 12), (ox + 8, base - 22)], 1); c.line([(ox + 8, base - 12), (ox - 8, base - 22)], 1)
        c.rect(ox - 12, base - 46, ox + 12, base - 30, 2); c.poly([(ox - 14, base - 46), (ox, base - 56), (ox + 14, base - 46)], 2)
        c.line([(ox - 12, base - 38), (ox + 12, base - 38)], 3); c.line([(ox - 14, base - 46), (ox, base - 56), (ox + 14, base - 46)], 3)
    return fn

def crane(c, h=70, base=GY, fill=2):
    def fn(ox):
        c.line([(ox, base), (ox, base - h)], fill, 3); c.line([(ox - 4, base), (ox - 4, base - h)], 3)
        c.line([(ox - 30, base - h), (ox + 40, base - h)], 3, 2); c.line([(ox, base - h - 12), (ox - 30, base - h)], 2); c.line([(ox, base - h - 12), (ox + 40, base - h)], 2)
        c.line([(ox + 34, base - h), (ox + 34, base - h + 26)], 3); c.line([(ox + 30, base - h + 26), (ox + 38, base - h + 26)], 3)
        for y in range(base - h + 6, base, 9): c.line([(ox - 4, y), (ox, y + 5)], 1)
    return fn

def stack(c, h=50, w=9, fill=2, base=GY, smoke=True):
    def fn(ox):
        c.poly([(ox, base), (ox + 2, base - h), (ox + w - 2, base - h), (ox + w, base)], fill)
        c.line([(ox + 2, base - h), (ox + w - 2, base - h)], 3)
        if smoke: c.dither(ox - 8, base - h - 26, ox + w + 12, base - h, 1, 0.0, 0.6)
    return fn

def tank(c, base=GY):
    def fn(ox):
        c.poly([(ox, base - 4), (ox + 6, base - 14), (ox + 48, base - 14), (ox + 54, base - 4)], 2)
        c.ell(ox + 14, base - 24, ox + 38, base - 10, 2); c.line([(ox + 36, base - 18), (ox + 62, base - 8)], 3, 2)
        c.rect(ox - 2, base - 6, ox + 56, base, 1)
        for x in range(4, 54, 9): c.ell(ox + x - 3, base - 6, ox + x + 4, base + 1, 3); c.px(ox + x, base - 3, 0)
        c.line([(ox + 6, base - 14), (ox + 48, base - 14)], 3)
    return fn

def robot(c, base=GY):
    def fn(ox):
        c.rect(ox + 4, base - 40, ox + 22, base - 14, 2); c.rect(ox + 7, base - 52, ox + 19, base - 42, 2); c.rect(ox + 11, base - 49, ox + 15, base - 46, 0)
        c.line([(ox + 4, base - 38), (ox - 8, base - 22), (ox - 10, base - 4)], 3, 2); c.line([(ox + 22, base - 38), (ox + 34, base - 30)], 3, 2)
        c.line([(ox + 8, base - 14), (ox + 6, base)], 3, 3); c.line([(ox + 18, base - 14), (ox + 24, base - 4)], 3, 3)
        c.dither(ox + 4, base - 40, ox + 22, base - 14, 3, 0.35, 0.05)
    return fn

def tires(c, base=GY):
    def fn(ox):
        for x, y in ((0, 0), (14, 0), (28, 0), (7, -10), (21, -10), (14, -20)):
            c.ell(ox + x - 7, base + y - 12, ox + x + 7, base + y, 3); c.ell(ox + x - 3, base + y - 8, ox + x + 3, base + y - 4, 0)
    return fn

def wire(c, w=40, base=GY):
    def fn(ox):
        for x in range(0, w, 4): c.line([(ox + x, base - 8 - (x % 8)), (ox + x + 4, base - 4 + (x % 8) // 2)], 3)
        c.line([(ox, base - 6), (ox + w, base - 6)], 2)
    return fn

def house(c, w=48, h=34, base=GY, seed=0):
    rng = random.Random(seed)
    def fn(ox):
        c.rect(ox, base - h, ox + w, base, 2); c.poly([(ox - 4, base - h), (ox + w / 2, base - h - 20), (ox + w + 4, base - h)], 1)
        c.line([(ox - 4, base - h), (ox + w / 2, base - h - 20), (ox + w + 4, base - h)], 3); c.rect(ox + w - 12, base - h - 16, ox + w - 7, base - h - 4, 2)
        for wx in (8, 28): c.rect(ox + wx, base - h + 8, ox + wx + 8, base - h + 18, 0); c.line([(ox + wx, base - h + 13), (ox + wx + 8, base - h + 13)], 3)
        c.dither(ox, base - h, ox + w, base, 3, 0.25, 0.05)
    return fn

def deadtree(c, seed, base=GY, h=34, fill=3):
    rng = random.Random(seed)
    segs = []
    def grow(x, y, a, l, d):
        if d == 0 or l < 3: return
        x2, y2 = x + math.cos(a) * l, y - math.sin(a) * l
        segs.append((x, y, x2, y2, d))
        grow(x2, y2, a + rng.uniform(0.3, 0.7), l * 0.72, d - 1); grow(x2, y2, a - rng.uniform(0.3, 0.7), l * 0.7, d - 1)
    grow(0, 0, math.pi / 2, h * 0.45, 5)
    def fn(ox):
        for x, y, x2, y2, d in segs: c.line([(ox + x, base + y), (ox + x2, base + y2)], fill, 2 if d > 3 else 1)
    return fn

def shard(c, h, w=10, base=GY, fill=2):
    def fn(ox):
        c.poly([(ox, base), (ox + w * 0.4, base - h), (ox + w, base)], fill)
        c.line([(ox, base), (ox + w * 0.4, base - h), (ox + w, base)], 3); c.line([(ox + w * 0.4, base - h), (ox + w * 0.5, base - 4)], 1)
    return fn

def bones(c, base=GY):
    def fn(ox):
        c.line([(ox, base), (ox + 36, base - 4)], 3, 2)
        for x in range(4, 34, 6): c.arc([ox + x - 6, base - 20, ox + x + 6, base - 2], 180, 360, 3)
        c.ell(ox + 36, base - 12, ox + 46, base - 2, 2); c.px(ox + 40, base - 8, 0); c.px(ox + 43, base - 8, 0)
    return fn

def rubble(c, w=50, h=16, base=GY, seed=0):
    rng = random.Random(seed)
    pts = [(0, 0)] + [(i, -rng.randint(h // 3, h)) for i in range(5, w, 6)] + [(w, 0)]
    def fn(ox):
        c.poly([(ox + x, base + y) for x, y in pts], 2); c.line([(ox + x, base + y) for x, y in pts[1:-1]], 3)
        for k in range(4): c.line([(ox + 6 + k * 11, base - h + 2), (ox + 10 + k * 11, base - h - 8)], 3)
        c.dither(ox, base - h, ox + w, base, 3, 0.3, 0.05)
    return fn

def mailbox(c, base=GY):
    def fn(ox):
        c.line([(ox, base), (ox, base - 14)], 3, 2); c.rect(ox - 5, base - 20, ox + 6, base - 13, 2); c.line([(ox - 5, base - 20), (ox + 6, base - 20)], 3)
    return fn

def swing(c, base=GY):
    def fn(ox):
        c.line([(ox, base), (ox + 10, base - 30), (ox + 20, base)], 3); c.line([(ox + 10, base - 30), (ox + 40, base - 30)], 3)
        c.line([(ox + 40, base - 30), (ox + 30, base)], 3); c.line([(ox + 18, base - 30), (ox + 18, base - 10)], 2); c.line([(ox + 28, base - 30), (ox + 28, base - 10)], 2)
        c.line([(ox + 16, base - 10), (ox + 30, base - 10)], 3, 2)
    return fn

def boat(c, base=GY):
    def fn(ox):
        c.poly([(ox, base - 8), (ox + 36, base - 8), (ox + 28, base), (ox + 8, base)], 2); c.line([(ox, base - 8), (ox + 36, base - 8)], 3)
        c.line([(ox + 18, base - 8), (ox + 18, base - 28)], 3); c.poly([(ox + 18, base - 28), (ox + 32, base - 12), (ox + 18, base - 12)], 1)
    return fn

def slab(c, w=60, h=28, base=GY):
    def fn(ox):
        c.poly([(ox, base), (ox + 8, base - h), (ox + w, base - h * 0.45), (ox + w, base)], 2)
        c.line([(ox + 8, base - h), (ox + w, base - h * 0.45)], 3)
        for y in (8, 16): c.line([(ox + 6, base - h + y), (ox + w - 4, base - h * 0.45 + y)], 1)
        for x in (14, 28, 42): c.line([(ox + x, base - h + 2), (ox + x + 3, base - h - 9)], 3)
    return fn

# ---------------------------------------------------------------- ground tiles (64x24)
def ground_tile(name, kind, seed):
    c = Canvas(64, 24); rng = random.Random(seed)
    c.line([(0, 0), (63, 0)], 3)
    dens = {'road': (0.55, 0.15), 'concrete': (0.5, 0.12), 'glass': (0.35, 0.08), 'water': (0.35, 0.2), 'ash': (0.45, 0.1), 'rust': (0.55, 0.15)}[kind]
    c.dither(0, 1, 63, 23, 2, dens[0], dens[1])
    if kind == 'road':
        for x in (6,): c.line([(x, 12), (x + 26, 12)], 3, 2)
        for _ in range(5): x = rng.randint(0, 60); c.line([(x, rng.randint(3, 22)), (x + rng.randint(3, 8), rng.randint(3, 22))], 1)
    elif kind in ('concrete', 'rust'):
        for x in (0, 32): c.line([(x, 1), (x, 23)], 1)
        for _ in range(6): x, y = rng.randint(2, 60), rng.randint(3, 20); c.line([(x, y), (x + 4, y + 3), (x + 2, y + 7)], 3 if kind == 'concrete' else 1)
    elif kind == 'glass':
        for k in range(4): x = rng.randint(0, 56); c.line([(x, 20), (x + 8, 2)], 3 if k % 2 else 2)
    elif kind == 'water':
        for y in (4, 9, 14, 19):
            for _ in range(2): x = rng.randint(0, 52); c.line([(x, y), (x + rng.randint(5, 10), y)], 3 if y < 12 else 2)
    elif kind == 'ash':
        for k in range(3): c.arc([k * 24 - 10, 6, k * 24 + 30, 40], 200, 330, 1)
        for _ in range(8): c.px(rng.randint(0, 63), rng.randint(2, 22), 3)
    for _ in range(8): c.px(rng.randint(0, 63), rng.randint(2, 22), 3)
    c.save(name)

# ---------------------------------------------------------------- regions
def region0():
    f = Canvas(W, H); sky(f, 0.0, 0.5); sun(f, 190, 82, 12)
    for x, w, h in ((20, 60, 16), (80, 44, 10), (210, 70, 20)): put(x, mesa(f, w, h))
    f.save('bg_far_0')
    m = Canvas(W, H)
    put(32, pole(m, 128)); put(160, pole(m, 128)); put(62, car(m)); put(188, car(m)); put(112, sign(m)); put(236, shrub(m, base=GY, seed=3)); put(10, shrub(m, seed=5))
    m.save('bg_mid_0'); ground_tile('ground_0', 'road', 1)

def region1():
    f = Canvas(W, H); sky(f, 0.05, 0.45)
    rng = random.Random(11); x = 0
    while x < W:
        w = rng.randint(14, 30); h = rng.randint(18, 44); put(x, building(f, w, h, 1, x, holes=True, edge=2)); x += w + rng.randint(0, 6)
    put(60, stack(f, 56, 8, 1)); put(196, stack(f, 48, 8, 1)); put(130, crane(f, 74, fill=1))
    f.save('bg_far_1')
    m = Canvas(W, H)
    put(14, container(m)); put(14, container(m, level=1)); put(94, barrel(m)); put(106, barrel(m)); put(128, fence(m)); put(196, tower(m)); put(238, container(m, w=14, h=12))
    m.save('bg_mid_1'); ground_tile('ground_1', 'concrete', 2)

def region2():
    f = Canvas(W, H); sky(f, 0.0, 0.4); sun(f, 150, 74, 20, halo=18)
    for x, w, h in ((0, 80, 22), (90, 60, 14), (170, 90, 26)): put(x, mesa(f, w, h))
    for i, x in enumerate(range(10, W, 26)): put(x, shard(f, 18 + (i * 7) % 20, 8, fill=1))
    f.save('bg_far_2')
    m = Canvas(W, H)
    for i, x in enumerate((20, 52, 98, 176, 214, 240)): put(x, shard(m, 16 + (i * 9) % 18, 10 + (i % 3) * 2))
    put(64, bones(m)); put(138, car(m)); m.save('bg_mid_2'); ground_tile('ground_2', 'glass', 3)

def region3():
    f = Canvas(W, H); sky(f, 0.05, 0.55); sun(f, 60, 30, 9, halo=10, glow=1)
    for i, x in enumerate((20, 84, 150, 214)): put(x, house(f, 40 + (i % 2) * 8, 26, base=GY, seed=i))
    for i, x in enumerate((60, 120, 190, 244)): put(x, deadtree(f, i + 3, h=30))
    f.save('bg_far_3')
    m = Canvas(W, H)
    put(18, house(m, 54, 38, base=GY + 8, seed=7)); put(120, house(m, 46, 30, base=GY + 8, seed=9)); put(86, deadtree(m, 21, h=40)); put(206, mailbox(m, base=GY + 4))
    put(222, boat(m, base=GY + 2)); put(160, swing(m, base=GY + 2)); m.save('bg_mid_3'); ground_tile('ground_3', 'water', 4)

def region4():
    f = Canvas(W, H); sky(f, 0.05, 0.5)
    for x, h in ((10, 52), (70, 64), (150, 46), (214, 58)): put(x, stack(f, h, 9, 1))
    put(36, crane(f, 70, fill=1)); put(176, crane(f, 62, fill=1))
    x = 0; rng = random.Random(5)
    while x < W:
        w = rng.randint(18, 34); put(x, rubble(f, w, rng.randint(10, 24), seed=x)); x += w + 2
    f.save('bg_far_4')
    m = Canvas(W, H)
    put(20, tank(m)); put(110, robot(m)); put(176, tires(m)); put(232, wire(m, 36)); m.save('bg_mid_4'); ground_tile('ground_4', 'rust', 5)

def region5():
    f = Canvas(W, H); sky(f, 0.1, 0.55); sun(f, 110, 56, 14, halo=12, core=2, glow=1)
    for i, x in enumerate((0, 34, 70, 112, 150, 186, 224)):
        put(x, building(f, 20 + (i * 5) % 14, 46 + (i * 17) % 44, 1, i + 40, holes=True, edge=2, ant=(i % 3 == 0)))
    ash(f, 9, 110); f.save('bg_far_5')
    m = Canvas(W, H)
    put(12, slab(m)); put(96, rubble(m, 70, 22, seed=2)); put(150, building(m, 38, 66, 2, 77, holes=True, edge=3)); put(214, slab(m, 44, 20))
    ash(m, 4, 40); m.save('bg_mid_5'); ground_tile('ground_5', 'ash', 6)

def preview(path='/tmp/world.png', scale=2):
    from PIL import Image
    import numpy as np
    sheet = Image.new('RGB', (W * scale * 2, H * scale * 3), (4, 12, 6))
    for i in range(6):
        comp = np.zeros((H, W, 3), dtype=np.float64)
        def add(img, ox, oy, k):
            a = np.array(img)[..., 3] / 255.0
            h, w = a.shape
            for y in range(h):
                yy = y + oy
                if 0 <= yy < H:
                    for x in range(w):
                        xx = (x + ox) % W if ox is not None else x
                        comp[yy, xx, 1] = max(comp[yy, xx, 1], a[y, x] * k)
        add(Image.open(OUT + 'bg_far_%d.png' % i), 0, 0, 0.55)
        add(Image.open(OUT + 'bg_mid_%d.png' % i), 0, 0, 1.0)
        g = Image.open(OUT + 'ground_%d.png' % i)
        for t in range(0, W, 64): add(g, t, GY, 0.85)
        p = Image.open(OUT + 'player_0.png'); add(p, 70, GY + 6 - 48, 1.0)
        arr = np.zeros((H, W, 3), dtype=np.uint8)
        arr[..., 1] = (comp[..., 1] * 255).astype(np.uint8); arr[..., 0] = (comp[..., 1] * 50).astype(np.uint8)
        im = Image.fromarray(arr).resize((W * scale, H * scale), Image.NEAREST)
        sheet.paste(im, ((i % 2) * W * scale, (i // 2) * H * scale))
    sheet.save(path)

if __name__ == '__main__':
    for f in (region0, region1, region2, region3, region4, region5): f()
    preview()
    print('ok')
