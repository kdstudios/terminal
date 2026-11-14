#!/usr/bin/env python3
"""Derive assets that are not on the artist sheets, in the same style:
dark 1px outline, 4 flat tones, ordered-dither gradients, hard pixel edges.
Output: assets/atlas/derived.png + derived.json (same schema as the sheets).
Run AFTER slice_sheets.py (it reads the sliced sheets):  python3 tools/derive_assets.py
"""
import json, os, math, random, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig_dweller
import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
OUT = os.path.join(ROOT, 'assets', 'atlas')
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
# palette sampled from the sheets' weathered stone tones (dark -> light), + outline
PAL = [(28, 34, 24), (74, 82, 62), (118, 128, 100), (168, 176, 146)]
SCALE = 3          # sheets are ~3 px per art pixel; derived art matches that density


def mushroom(w=84, h=104, seed=7):
    rnd = random.Random(seed)
    yy, xx = np.mgrid[0:h, 0:w].astype(float)
    cx = w / 2
    solid = np.zeros((h, w), bool)
    # stem: tapered, wobbling edges
    for y in range(36, h):
        t = (y - 36) / (h - 36)
        half = 5 + 9 * t ** 2.2 + math.sin(y * 0.55) * 1.2
        solid[y, int(cx - half):int(cx + half) + 1] = True
    # cap: overlapping lobes
    lobes = [(cx, 26, 20), (cx - 17, 30, 12), (cx + 17, 30, 12), (cx - 8, 18, 12),
             (cx + 9, 17, 13), (cx - 26, 36, 7), (cx + 26, 36, 7), (cx, 40, 11)]
    for (lx, ly, r) in lobes:
        r += rnd.uniform(-1, 1)
        solid |= (xx - lx) ** 2 + ((yy - ly) * 1.25) ** 2 < r * r
    # skirt of dust at the base
    solid[h - 6:, int(cx - 24):int(cx + 24)] |= (np.abs(xx[h - 6:, int(cx - 24):int(cx + 24)] - cx) < 24 - (yy[h - 6:, int(cx - 24):int(cx + 24)] - (h - 6)) * 1.5)
    # tone: lit from upper-left + darker towards the underside / stem
    tone = np.clip(3.2 - (xx - cx * 0.7) / w * 1.6 - yy / h * 1.7, 0, 3.4)
    tone += (np.sin(xx * 0.9 + np.sin(yy * 0.4) * 2) + np.sin(yy * 0.7)) * 0.18
    tone = tone + (BAYER[(yy.astype(int)) % 4, (xx.astype(int)) % 4] - 0.5) * 0.9
    idx = np.clip(np.round(tone), 0, 3).astype(int)
    rgba = np.zeros((h, w, 4), np.uint8)
    for k in range(4):
        rgba[(idx == k) & solid] = (*PAL[k], 255)
    # 1px dark outline
    pad = np.pad(solid, 1)
    edge = ~solid & (pad[:-2, 1:-1] | pad[2:, 1:-1] | pad[1:-1, :-2] | pad[1:-1, 2:])
    rgba[edge] = (14, 18, 12, 255)
    return Image.fromarray(rgba, 'RGBA')


def _crop(sheet, name):
    d = json.load(open(os.path.join(OUT, sheet + '.json')))
    sp = d['sprites'][d['names'][name]]
    im = Image.open(os.path.join(OUT, d['image'])).convert('RGBA')
    return im.crop((sp['x'], sp['y'], sp['x'] + sp['w'], sp['y'] + sp['h']))


def on_post(sign, post_h=70, post_w=9):
    """Mount a floating plaque on a short weathered metal post (same 3-tone
    shading + dark outline as the sheets' poles)."""
    W, H = max(sign.width, 24), sign.height + post_h
    out = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    px = np.zeros((H, W, 4), np.uint8)
    cx = W // 2
    top = sign.height - 6
    ol = (14, 18, 12, 255)
    for y in range(top, H):
        for k in range(-post_w // 2 - 3, post_w // 2 + 4):
            x = cx + k
            if not (0 <= x < W):
                continue
            edge = abs(k) > post_w // 2
            col = ol if edge else (PAL[2] + (255,) if k < -post_w // 6 else (PAL[1] + (255,) if k < post_w // 6 else PAL[0] + (255,)))
            px[y, x] = col
    # little ground flange
    for y in range(H - 7, H):
        for x in range(max(0, cx - 12), min(W, cx + 13)):
            px[y, x] = ol if (y == H - 1 or x in (cx - 12, cx + 12)) else PAL[1] + (255,)
    out.alpha_composite(Image.fromarray(px, 'RGBA'))
    out.alpha_composite(sign, ((W - sign.width) // 2, 0))
    return out


def main():
    items = {'sky.mushroom': mushroom().resize((84 * SCALE, 104 * SCALE), Image.NEAREST)}
    items['sign.radpost'] = on_post(_crop('world_a', 'sign.radiation'))
    items['sign.stoppost'] = on_post(_crop('world_b', 'sign.stop'))
    items['sign.route66post'] = on_post(_crop('world_b', 'sign.route66'))
    rig_imgs, rig_meta = rig_dweller.build()
    items.update(rig_imgs)
    pad = 4
    W = sum(i.width + pad for i in items.values()) + pad
    H = max(i.height for i in items.values()) + 2 * pad
    sheet = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    sprites, names, x = [], {}, pad
    for n, (name, im) in enumerate(items.items()):
        sheet.alpha_composite(im, (x, pad))
        sprites.append({'i': n, 'x': x, 'y': pad, 'w': im.width, 'h': im.height, 'ax': im.width // 2})
        names[name] = n
        x += im.width + pad
    os.makedirs(OUT, exist_ok=True)
    sheet.save(os.path.join(OUT, 'derived.png'))
    json.dump({'image': 'derived.png', 'width': W, 'height': H, 'sprites': sprites,
               'names': names, 'rows': {}, 'pools': {}, 'rigs': {'dweller': rig_meta}},
              open(os.path.join(OUT, 'derived.json'), 'w'))
    print('derived:', list(items))


if __name__ == '__main__':
    main()
