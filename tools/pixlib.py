"""Tiny pixel-art toolkit used to derive sprites in the artist's style:
dark 1px outline, 4 flat tones per material, light from the upper left,
ordered-dither transitions, hard pixel edges. Author at low resolution, then
upscale with nearest-neighbour (the sheets are ~2 sheet px per art pixel)."""
import numpy as np
from scipy import ndimage as ndi
from PIL import Image, ImageDraw

BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
OUTLINE = (12, 14, 10)

RAMPS = {
    'rust':   [(34, 30, 26), (86, 66, 48), (138, 100, 64), (186, 146, 96)],
    'steel':  [(26, 30, 32), (66, 76, 78), (110, 122, 118), (158, 170, 160)],
    'pale':   [(44, 50, 42), (96, 108, 88), (150, 162, 134), (200, 208, 178)],
    'grey':   [(34, 32, 28), (76, 70, 60), (120, 110, 92), (166, 156, 130)],
    'green':  [(24, 44, 28), (52, 92, 48), (94, 142, 68), (150, 192, 108)],
    'black':  [(10, 12, 14), (28, 32, 38), (50, 56, 64), (82, 90, 98)],
    'sand':   [(58, 46, 30), (110, 90, 58), (158, 132, 88), (204, 176, 122)],
    'bone':   [(110, 100, 78), (170, 160, 130), (222, 214, 186), (248, 244, 226)],
    'flesh':  [(56, 40, 36), (112, 82, 70), (160, 124, 104), (204, 170, 142)],
}
RED, YEL, ACID = (255, 70, 46), (255, 214, 70), (160, 255, 70)


class Canvas:
    def __init__(self, w, h, seed=1):
        self.w, self.h = w, h
        self.rgba = np.zeros((h, w, 4), np.uint8)
        self.yy, self.xx = np.mgrid[0:h, 0:w].astype(float)
        self.rng = np.random.RandomState(seed)

    # ---- masks ---------------------------------------------------------
    def ellipse(self, cx, cy, rx, ry):
        return ((self.xx + .5 - cx) / rx) ** 2 + ((self.yy + .5 - cy) / ry) ** 2 <= 1

    def capsule(self, p0, p1, r0, r1=None):
        r1 = r0 if r1 is None else r1
        p0, p1 = np.array(p0, float), np.array(p1, float)
        d = p1 - p0
        L2 = max(d @ d, 1e-6)
        t = np.clip(((self.xx + .5 - p0[0]) * d[0] + (self.yy + .5 - p0[1]) * d[1]) / L2, 0, 1)
        px, py = p0[0] + t * d[0], p0[1] + t * d[1]
        r = r0 + (r1 - r0) * t
        return (self.xx + .5 - px) ** 2 + (self.yy + .5 - py) ** 2 <= r * r

    def poly(self, pts):
        im = Image.new('L', (self.w, self.h), 0)
        ImageDraw.Draw(im).polygon([(x, y) for x, y in pts], fill=255)
        return np.array(im) > 0

    def rect(self, x0, y0, x1, y1):
        return (self.xx >= x0) & (self.xx < x1) & (self.yy >= y0) & (self.yy < y1)

    # ---- painting ------------------------------------------------------
    def paint(self, mask, ramp, base=0.55, light=(-0.6, -0.7), k=1.0, noise=0.0,
              edge=True, hl=0.0):
        """Fill `mask` with a bulged, lit, dithered 4-tone `ramp`. Draws a dark
        edge inside the mask so overlapping parts stay readable."""
        if not mask.any():
            return
        ramp = RAMPS[ramp] if isinstance(ramp, str) else ramp
        d = ndi.distance_transform_edt(mask)
        dn = d / max(d.max(), 1.0)
        g = ndi.gaussian_filter(d, 1.0)
        gy, gx = np.gradient(g)
        lit = -(gx * light[0] + gy * light[1])
        tone = base + k * (0.55 * (dn - 0.45) + 0.9 * lit) + hl * (self.yy / self.h - .5) * -1
        if noise:
            n = ndi.gaussian_filter(self.rng.rand(self.h, self.w), 0.8)
            tone += (n - n.mean()) * noise * 6
        t = tone * 3 + (BAYER[self.yy.astype(int) % 4, self.xx.astype(int) % 4] - 0.5) * 0.9
        idx = np.clip(np.round(t), 0, 3).astype(int)
        for i in range(4):
            self.rgba[mask & (idx == i)] = (*ramp[i], 255)
        if edge and d.max() >= 2.5:
            er = ndi.binary_erosion(mask, [[0, 1, 0], [1, 1, 1], [0, 1, 0]])
            self.rgba[mask & ~er] = (*[int(c * .55) for c in ramp[0]], 255)

    def px(self, pts, col):
        for x, y in pts:
            if 0 <= int(x) < self.w and 0 <= int(y) < self.h:
                self.rgba[int(y), int(x)] = (*col, 255)

    def line(self, p0, p1, col, w=1):
        im = Image.new('L', (self.w, self.h), 0)
        ImageDraw.Draw(im).line([tuple(p0), tuple(p1)], fill=255, width=w)
        self.rgba[np.array(im) > 0] = (*col, 255)

    def spots(self, mask, col, density=0.05):
        sel = mask & (self.rng.rand(self.h, self.w) < density)
        self.rgba[sel] = (*col, 255)

    def eye(self, x, y, col=RED, size=1):
        for dx in range(-size, size + 1):
            for dy in range(-size, size + 1):
                if abs(dx) + abs(dy) <= size:
                    self.px([(x + dx, y + dy)], tuple(int(c * .55) for c in col))
        self.px([(x, y)], (255, 255, 235))
        self.px([(x - 1, y), (x + 1, y)], col) if size else None

    # ---- output --------------------------------------------------------
    def finish(self, scale=2):
        a = self.rgba[..., 3] > 0
        pad = np.pad(a, 1)
        edge = ~a & (pad[:-2, 1:-1] | pad[2:, 1:-1] | pad[1:-1, :-2] | pad[1:-1, 2:])
        out = self.rgba.copy()
        out[edge] = (*OUTLINE, 255)
        im = Image.fromarray(out, 'RGBA')
        return im.resize((im.width * scale, im.height * scale), Image.NEAREST)
