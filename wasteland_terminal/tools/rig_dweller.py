"""Paper-doll rig for the dweller, cut from ONE clean frame of the artist's sheet.

The sheet's dweller frames are poses, not a cycle (different scales / leg
positions), so playing them back pops. Instead we cut the best wide-stride
frame (row 'dweller.a' #5: rifle held at the hip, matching the concept) into
  body + per leg (thigh, shin, foot)
and let the game drive the joint angles every frame -> continuous, speed-
independent, planted-foot walk with no pose swapping.

All coordinates below are in the ORIGINAL FRAME's pixel space (x right, y down).
"""
import json, math, os
import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
ATLAS = os.path.join(ROOT, 'assets', 'atlas')

SOURCE_ROW, SOURCE_INDEX = 'dweller.a', 5
HIP_Y = 47            # hip-joint row (belt is ~31-33, crotch gap opens at 51)
SPLIT_X = 24.5        # legs overlap above row 51; split on this column
WAIST = 43            # body ends here; the V-shaped hip flare below belongs to the thighs
THIGH_TOP = 41        # thighs start 2 rows higher so they tuck under the body
KNEE_ROW, ANKLE_ROW = 57, 63


def _frame():
    d = json.load(open(os.path.join(ATLAS, 'world_b.json')))
    s = d['sprites'][d['rows'][SOURCE_ROW][SOURCE_INDEX]]
    im = Image.open(os.path.join(ATLAS, 'world_b.png')).convert('RGBA')
    return im.crop((s['x'], s['y'], s['x'] + s['w'], s['y'] + s['h']))


def _piece(frame, mask):
    """Crop the frame to `mask` (bool HxW); returns (image, ox, oy)."""
    ys, xs = np.where(mask)
    x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    arr = np.array(frame).copy()
    arr[~mask] = 0
    return Image.fromarray(arr[y0:y1, x0:x1], 'RGBA'), int(x0), int(y0)


def _center(alpha, row, side_mask):
    xs = np.where(alpha[row] & side_mask[row])[0]
    return float(xs.mean()) + 0.5


def build():
    fr = _frame()
    a = np.array(fr)[..., 3] > 40
    h, w = a.shape
    yy, xx = np.mgrid[0:h, 0:w]
    parts, legs = {}, []

    body_mask = a & (yy < WAIST)
    parts['dw.body'] = _piece(fr, body_mask)
    # Unarmed body for melee poses: the rifle (x>=32, rows 26-38) removed, hands kept.
    rifle = (xx >= 32) & (yy >= 26) & (yy <= 38)
    parts['dw.body_melee'] = _piece(fr, body_mask & ~rifle)

    for k, back in enumerate((True, False)):           # leg 0 = back leg, leg 1 = front leg
        side = (xx < SPLIT_X) if back else (xx >= SPLIT_X)
        leg = a & side & (yy >= THIGH_TOP)
        top = _center(a, HIP_Y + 1, side)
        P = (top, float(HIP_Y))
        K = (_center(a, KNEE_ROW, side), float(KNEE_ROW))
        A = (_center(a, ANKLE_ROW - 1, side), float(ANKLE_ROW))

        def disc(c, r):
            # Round joint cap: pixels within r of the pivot. Rotating about the
            # pivot they never leave the silhouette of the part above: no seams.
            return (xx + 0.5 - c[0]) ** 2 + (yy + 0.5 - c[1]) ** 2 <= r * r

        thigh = (leg & (yy < KNEE_ROW)) | (a & disc(P, 7.5))
        shin = (leg & (yy >= KNEE_ROW) & (yy < ANKLE_ROW)) | (leg & disc(K, 4.5))
        foot = (leg & (yy >= ANKLE_ROW)) | (leg & disc(A, 3.0))
        for nm, m in (('thigh', thigh), ('shin', shin), ('foot', foot)):
            parts[f'dw.{nm}{k}'] = _piece(fr, m)
        th0 = math.degrees(math.atan2(K[0] - P[0], K[1] - P[1]))   # forward(+x)-positive, from vertical
        sg0 = math.degrees(math.atan2(A[0] - K[0], A[1] - K[1]))
        legs.append({'P': P, 'K': K, 'A': A, 'th0': th0, 'sg0': sg0,
                     'thigh': f'dw.thigh{k}', 'shin': f'dw.shin{k}', 'foot': f'dw.foot{k}'})

    hip_x = float(np.mean([l['P'][0] for l in legs]))      # body placement uses the ORIGINAL pelvis centre
    # Walking symmetry: the two source legs differ (one is the trailing leg of a stride, with a
    # different foot), which made the walk look like a limp. Both legs now use the FRONT leg's
    # pieces and joints, so left and right are identical (the far one is just drawn dimmer).
    legs = [dict(legs[1]), dict(legs[1])]
    meta = {
        'frame': [w, h],
        'hip': [hip_x, float(HIP_Y)],
        'sole_y': float(h),
        'body': 'dw.body',
        'body_melee': 'dw.body_melee',
        'hand': [28.5, 33.5],      # where a held weapon is gripped (frame space)
        'legs': legs,
        'parts': {n: [ox, oy] for n, (im, ox, oy) in parts.items()},
    }
    return {n: im for n, (im, ox, oy) in parts.items()}, meta


if __name__ == '__main__':
    imgs, meta = build()
    print(json.dumps({k: v for k, v in meta.items() if k != 'parts'}, indent=1))
