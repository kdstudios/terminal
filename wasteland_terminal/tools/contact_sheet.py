"""Debug: render every named sprite / pool member with its label.  python3 tools/contact_sheet.py"""
import json, os
from PIL import Image, ImageDraw
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
def sheet(name, items, out, cell=130):
    d = json.load(open(f'{R}/assets/atlas/{name}.json')); im = Image.open(f'{R}/assets/atlas/{d["image"]}').convert('RGBA')
    cols = 9; rows = (len(items) + cols - 1) // cols
    canvas = Image.new('RGBA', (cols * cell, rows * (cell + 14)), (35, 45, 35, 255)); dr = ImageDraw.Draw(canvas)
    for n, (label, i) in enumerate(items):
        s = d['sprites'][i]; c = im.crop((s['x'], s['y'], s['x'] + s['w'], s['y'] + s['h']))
        k = min((cell - 8) / c.width, (cell - 8) / c.height, 2.0); c = c.resize((max(1, int(c.width * k)), max(1, int(c.height * k))))
        x, y = (n % cols) * cell, (n // cols) * (cell + 14)
        canvas.alpha_composite(c, (x + (cell - c.width) // 2, y + 2 + (cell - c.height) // 2)); dr.text((x + 2, y + cell + 1), f'{label}', fill=(255, 255, 0, 255))
    canvas.convert('RGB').save(f'{R}/work/{out}.png')
for n in ['world_a', 'world_b', 'minigame']:
    d = json.load(open(f'{R}/assets/atlas/{n}.json'))
    items = [(k, v) for k, v in d['names'].items()]
    for k, v in d['rows'].items(): items += [(f'{k}{j}', i) for j, i in enumerate(v)]
    for k, v in d['pools'].items(): items += [(f'{k}{j}', i) for j, i in enumerate(v)]
    sheet(n, items, f'names_{n}')
