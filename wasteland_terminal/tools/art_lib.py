"""Tiny pixel-art toolkit. Four brightness levels (0 = transparent, 1 dim, 2 mid,
3 bright) saved as white-with-alpha PNGs, so the game can tint them with the
current terminal theme colour."""
import math, os, random
import numpy as np
from PIL import Image, ImageDraw

ALPHA = [0, 70, 140, 255]
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'images') + os.sep


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.img = Image.new('L', (w, h), 0)
        self.d = ImageDraw.Draw(self.img)

    def rect(self, x0, y0, x1, y1, v): self.d.rectangle([x0, y0, x1, y1], fill=v)
    def poly(self, pts, v): self.d.polygon(pts, fill=v)
    def ell(self, x0, y0, x1, y1, v): self.d.ellipse([x0, y0, x1, y1], fill=v)
    def line(self, pts, v, w=1): self.d.line(pts, fill=v, width=w)
    def arc(self, box, a0, a1, v, w=1): self.d.arc(box, a0, a1, fill=v, width=w)

    def px(self, x, y, v):
        x, y = int(x), int(y)
        if 0 <= x < self.w and 0 <= y < self.h:
            self.img.putpixel((x, y), v)

    def get(self, x, y):
        return self.img.getpixel((x, y)) if 0 <= x < self.w and 0 <= y < self.h else 0

    def dither(self, x0, y0, x1, y1, v, top=1.0, bottom=0.0, only_empty=True):
        """Gradient fill using an ordered dither (density top -> bottom)."""
        for y in range(max(0, y0), min(self.h, y1 + 1)):
            t = (y - y0) / max(1, (y1 - y0))
            dens = top + (bottom - top) * t
            for x in range(max(0, x0), min(self.w, x1 + 1)):
                if BAYER[y % 4][x % 4] < dens and (not only_empty or self.get(x, y) == 0):
                    self.img.putpixel((x, y), v)

    def outline(self, v=3):
        """Bright 1px edge around everything drawn (gives the CRT-vector look)."""
        a = np.array(self.img)
        out = a.copy()
        for y in range(self.h):
            for x in range(self.w):
                if a[y, x] == 0:
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < self.w and 0 <= ny < self.h and a[ny, nx] > 0:
                            out[y, x] = v
                            break
        self.img = Image.fromarray(out)
        self.d = ImageDraw.Draw(self.img)

    def save(self, name):
        a = np.array(self.img)
        rgba = np.zeros((self.h, self.w, 4), dtype=np.uint8)
        rgba[..., :3] = 255
        rgba[..., 3] = np.array(ALPHA, dtype=np.uint8)[np.clip(a, 0, 3)]
        Image.fromarray(rgba, 'RGBA').save(OUT + name + '.png')


def wrap_draw(W, x, fn):
    """Call fn(x) plus the wrapped copies so a layer tiles horizontally."""
    for ox in (-W, 0, W):
        fn(x + ox)


def contact_sheet(names, cols, scale=3, path='/tmp/sheet.png', pad=4):
    ims = [Image.open(OUT + n + '.png') for n in names]
    cw = max(i.width for i in ims) * scale + pad
    ch = max(i.height for i in ims) * scale + pad
    rows = (len(ims) + cols - 1) // cols
    sheet = Image.new('RGB', (cw * cols, ch * rows), (4, 12, 6))
    for k, im in enumerate(ims):
        a = np.array(im)[..., 3] / 255.0
        g = np.zeros((im.height, im.width, 3), dtype=np.uint8)
        g[..., 1] = (a * 255).astype(np.uint8)
        g[..., 0] = (a * 60).astype(np.uint8)
        gi = Image.fromarray(g).resize((im.width * scale, im.height * scale), Image.NEAREST)
        sheet.paste(gi, ((k % cols) * cw, (k // cols) * ch))
    sheet.save(path)
