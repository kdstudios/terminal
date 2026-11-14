#!/usr/bin/env python3
"""Slice the artist sprite sheets into individually addressable sprites.

Reads the raw sheets from  art_src/  and writes
  assets/atlas/<sheet>.png          (the sheet, copied through untouched)
  assets/atlas/<sheet>.json         (auto-detected rects, reading order)
  work/<sheet>_overlay.png          (numbered debug overlay, optional)

Detection = alpha threshold -> small dilation (re-joins fragments such as
sparks / broken pick bits) -> connected components -> wide merged components
(buildings whose grass bases touch) are split along empty columns found in
their UPPER part. Run:  python3 tools/slice_sheets.py [--overlay]
"""
import json, os, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SRC = os.path.join(ROOT, 'art_src')
OUT = os.path.join(ROOT, 'assets', 'atlas')
DBG = os.path.join(ROOT, 'work')

# sheet file -> (output name, dilation px, min opaque area, split-width, row-merge)
SHEETS = {
    'ArtAsset01.png': ('world_a', 1, 40, 260, 215),
    'ArtAsset02.png': ('world_b', 1, 40, 260, 215),
    'Terminal_LockpickInterface.png': ('minigame', 6, 30, 10**9, 10**9),
}
THR = 40  # alpha threshold counted as "ink"

# Per-sheet zones re-detected with their own dilation (y0, y1, dilation px).
# Character animation rows need NO dilation or neighbouring frames fuse.
ZONES = {
    'ArtAsset02.png': [(335, 612, 0), (612, 800, 0)],
    'Terminal_LockpickInterface.png': [(320, 590, 0)],   # locks incl. levered pair
}


def tight(mask, x, y, w, h, min_px=30):
    piece = mask[y:y + h, x:x + w]
    ys, xs = np.where(piece)
    if len(xs) < min_px:
        return None
    return (x + xs.min(), y + ys.min(), xs.max() - xs.min() + 1, ys.max() - ys.min() + 1)


def split_wide(mask, box, max_w, max_h=215):
    """Recursively split merged blobs: first by a horizontal valley (stacked
    building bands), then by near-empty columns in the upper part of a band."""
    x, y, w, h = box
    if h > max_h:
        occ = mask[y:y + h, x:x + w].sum(axis=1).astype(float)
        occ = np.convolve(occ, np.ones(5) / 5, mode='same')
        lo, hi = int(h * 0.3), int(h * 0.7)
        cut = lo + int(np.argmin(occ[lo:hi]))
        parts = [tight(mask, x, y, w, cut), tight(mask, x, y + cut, w, h - cut)]
        out = []
        for p in parts:
            if p:
                out += split_wide(mask, p, max_w, max_h)
        return out
    if w <= max_w:
        return [box]
    sub = mask[y:y + h, x:x + w]
    occ = sub[: int(h * 0.62)].sum(axis=0)
    cuts, run = [], 0
    for i, v in enumerate(occ):
        if v <= 1:
            run += 1
        else:
            if run >= 3:
                cuts.append(i - run // 2 - 1)
            run = 0
    if not cuts:
        return [box]
    edges = [0] + cuts + [w]
    out = []
    for a, b in zip(edges, edges[1:]):
        if b - a < 12:
            continue
        t = tight(mask, x + a, y, b - a, h)
        if t:
            out.append(t)
    return out or [box]


# Hand overrides for the few cases detection can't solve.
VSPLITS = {'Terminal_LockpickInterface.png': [432]}            # x cuts through touching sprites
MERGE = {'Terminal_LockpickInterface.png': [(20, 600, 530, 1110)]}   # computer + its overhang
IGNORE = {'Terminal_LockpickInterface.png': [(1060, 350, 1210, 378),   # "rotate lock" label
                                             (600, 1085, 790, 1128)]}  # "rotation pin" label


def _components(mask, dil, min_area, max_w, max_h, y_off=0):
    lab, n = ndi.label(ndi.binary_dilation(mask, np.ones((3, 3)), iterations=dil)
                       if dil else mask)
    boxes = []
    for i, s in enumerate(ndi.find_objects(lab)):
        comp = mask[s] & (lab[s] == i + 1)
        if comp.sum() < min_area:
            continue
        ys, xs = np.where(comp)
        box = (s[1].start + xs.min(), s[0].start + ys.min() + y_off,
               xs.max() - xs.min() + 1, ys.max() - ys.min() + 1)
        boxes.append(box)
    return boxes


def detect(path, dil, min_area, max_w, max_h):
    a = np.array(Image.open(path).convert('RGBA'))[..., 3]
    mask = a > THR
    boxes = []
    for box in _components(mask, dil, min_area, max_w, max_h):
        boxes += split_wide(mask, box, max_w, max_h)
    for (y0, y1, zdil) in ZONES.get(os.path.basename(path), []):
        boxes = [b for b in boxes if not (y0 <= b[1] + b[3] / 2 <= y1)]
        zone = mask[y0:y1]
        boxes += _components(zone, zdil, min_area, max_w, max_h, y_off=y0)
    name = os.path.basename(path)
    for cx in VSPLITS.get(name, []):
        out = []
        for (x, y, w, h) in boxes:
            if x < cx < x + w:
                for a, b in ((x, cx), (cx, x + w)):
                    t = tight(mask, a, y, b - a, h)
                    if t:
                        out.append(t)
            else:
                out.append((x, y, w, h))
        boxes = out
    for (x0, y0, x1, y1) in MERGE.get(name, []):
        inside = [b for b in boxes if x0 <= b[0] + b[2] / 2 <= x1 and y0 <= b[1] + b[3] / 2 <= y1]
        if len(inside) > 1:
            ux0 = min(b[0] for b in inside); uy0 = min(b[1] for b in inside)
            ux1 = max(b[0] + b[2] for b in inside); uy1 = max(b[1] + b[3] for b in inside)
            boxes = [b for b in boxes if b not in inside] + [(ux0, uy0, ux1 - ux0, uy1 - uy0)]
    for (x0, y0, x1, y1) in IGNORE.get(name, []):
        boxes = [b for b in boxes if not (x0 <= b[0] + b[2] / 2 <= x1 and y0 <= b[1] + b[3] / 2 <= y1)]
    return order(boxes)


def dedupe(boxes):
    """Drop boxes that are >60% covered by a bigger/equal one already kept."""
    keep = []
    for b in sorted(boxes, key=lambda b: -b[2] * b[3]):
        bx0, by0, bx1, by1 = b[0], b[1], b[0] + b[2], b[1] + b[3]
        dup = False
        for k in keep:
            ix = max(0, min(bx1, k[0] + k[2]) - max(bx0, k[0]))
            iy = max(0, min(by1, k[1] + k[3]) - max(by0, k[1]))
            if ix * iy > 0.6 * b[2] * b[3] and b[2] * b[3] < 0.9 * k[2] * k[3] + 1 and k[2] * k[3] < 3 * b[2] * b[3]:
                dup = True
                break
        if not dup:
            keep.append(b)
    return keep


def order(boxes):
    boxes = dedupe(boxes)
    """Reading order: group into rows by vertical-centre overlap, then by x."""
    boxes = sorted(boxes, key=lambda b: b[1] + b[3] / 2)
    rows = []
    for b in boxes:
        cy = b[1] + b[3] / 2
        for r in rows:
            if abs(cy - r['cy']) < max(18, 0.35 * r['h']):
                r['items'].append(b)
                r['cy'] = np.mean([i[1] + i[3] / 2 for i in r['items']])
                r['h'] = max(r['h'], b[3])
                break
        else:
            rows.append({'cy': cy, 'h': b[3], 'items': [b]})
    rows.sort(key=lambda r: r['cy'])
    return [b for r in rows for b in sorted(r['items'], key=lambda b: b[0])]


def resolve(sheet, sprites):
    """Turn sprite_names.py positions into names / frame rows / pools."""
    import sprite_names as sn

    def pick(x, y):
        for s in sprites:
            if s['x'] <= x <= s['x'] + s['w'] and s['y'] <= y <= s['y'] + s['h']:
                return s['i']
        return min(sprites, key=lambda s: (s['x'] + s['w'] / 2 - x) ** 2 + (s['y'] + s['h'] / 2 - y) ** 2)['i']

    names = {k: pick(*xy) for k, xy in sn.NAMES.get(sheet, {}).items()}
    rows = {}
    for k, (cy, x0, x1) in sn.ROWS.get(sheet, {}).items():
        r = [s for s in sprites if abs(s['y'] + s['h'] / 2 - cy) < 30 and x0 <= s['x'] <= x1]
        rows[k] = [s['i'] for s in sorted(r, key=lambda s: s['x'])]
    pools = {}
    for k, rule in sn.POOLS.items():
        sh, y0, y1, mh = rule[:4]
        xh = rule[4] if len(rule) > 4 else 10 ** 6
        if sh == sheet:
            pools[k] = [s['i'] for s in sprites
                        if s['y'] >= y0 and s['y'] + s['h'] <= y1 + 40 and mh <= s['h'] <= xh]
    for k, (sh, (x0, y0, x1, y1), (hmin, hmax), (wmin, wmax)) in sn.RECT_POOLS.items():
        if sh == sheet:
            pools[k] = [s['i'] for s in sprites
                        if x0 <= s['x'] + s['w'] / 2 <= x1 and y0 <= s['y'] + s['h'] / 2 <= y1
                        and hmin <= s['h'] <= hmax and wmin <= s['w'] <= wmax]
    return {'names': names, 'rows': rows, 'pools': pools}


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(DBG, exist_ok=True)
    for fname, (name, dil, min_area, max_w, max_h) in SHEETS.items():
        src = os.path.join(SRC, fname)
        boxes = detect(src, dil, min_area, max_w, max_h)
        im = Image.open(src)
        shutil.copyfile(src, os.path.join(OUT, name + '.png'))
        alpha = np.array(im.convert('RGBA'))[..., 3] > THR

        def foot_x(x, y, w, h):
            """Foot anchor: centroid x of the opaque pixels in the bottom 30%.
            Keeps walk-cycle frames planted even when a rifle swings out."""
            band = alpha[y + int(h * 0.7): y + h, x: x + w]
            xs = np.where(band)[1]
            return int(round(xs.mean())) if len(xs) else w // 2

        data = {'image': name + '.png', 'width': im.width, 'height': im.height,
                'sprites': [{'i': i, 'x': int(x), 'y': int(y), 'w': int(w), 'h': int(h),
                             'ax': foot_x(int(x), int(y), int(w), int(h))}
                            for i, (x, y, w, h) in enumerate(boxes)]}
        data.update(resolve(name, data['sprites']))
        with open(os.path.join(OUT, name + '.json'), 'w') as f:
            json.dump(data, f)
        print(f'{name}: {len(boxes)} sprites')
        if '--overlay' in sys.argv:
            bg = Image.new('RGBA', im.size, (40, 40, 40, 255))
            bg.alpha_composite(im.convert('RGBA'))
            d = ImageDraw.Draw(bg)
            for i, (x, y, w, h) in enumerate(boxes):
                d.rectangle([x, y, x + w, y + h], outline=(255, 0, 255, 255))
                d.text((x + 1, y + 1), str(i), fill=(255, 255, 0, 255))
            bg.convert('RGB').save(os.path.join(DBG, name + '_overlay.png'))


if __name__ == '__main__':
    main()
