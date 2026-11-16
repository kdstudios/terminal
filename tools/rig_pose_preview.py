"""Render fixed rig poses (melee swing, guard, seated) with a held weapon, using the
same maths as lib/ui/dweller_rig.dart.  python3 tools/rig_pose_preview.py"""
import math, json, os
import numpy as np
from PIL import Image, ImageDraw
import rig_dweller as rd
import rig_preview as rp
from rig_preview import mat_T, mat_R, FOOT_K, S

def render_pose(imgs, meta, th, flex, lean, weapon=None, wangle=0, grip=0.2, W=150, H=140, ground=125, scale=1.0, unarmed=True):
    img = Image.new('RGBA', (W * S, H * S), (0, 0, 0, 0))
    r = math.radians
    thr = [r(x) for x in th]; fr = [r(x) for x in flex]; sg = [thr[k] - fr[k] for k in range(2)]
    depth = max(math.dist(l['P'], l['K']) * math.cos(thr[k]) + math.dist(l['K'], l['A']) * math.cos(sg[k]) + (meta['sole_y'] - l['A'][1]) * math.cos(FOOT_K * sg[k]) for k, l in enumerate(meta['legs']))
    hx, hy = 70, ground - depth * scale
    def put(name, M):
        ox, oy = meta['parts'][name]
        Mp = np.diag([S, S, 1.0]) @ mat_T(hx, hy) @ np.diag([scale, scale, 1.0]) @ M @ mat_T(ox, oy)
        inv = np.linalg.inv(Mp)
        img.alpha_composite(imgs[name].transform((W * S, H * S), Image.AFFINE, tuple(inv[:2].flatten()), resample=Image.BICUBIC))
    for k in (0, 1):
        leg = meta['legs'][k]; P, K, A = leg['P'], leg['K'], leg['A']
        rt = -(thr[k] - r(leg['th0'])); rs = r(leg['sg0'] - leg['th0']) + fr[k]; rf = -FOOT_K * sg[k] + (sg[k] - r(leg['sg0']))
        Mt = mat_R(rt) @ mat_T(-P[0], -P[1]); Mk = mat_R(rt) @ mat_T(K[0] - P[0], K[1] - P[1]) @ mat_R(rs)
        Ma = Mk @ mat_T(A[0] - K[0], A[1] - K[1]) @ mat_R(rf)
        put(leg['foot'], Ma @ mat_T(-A[0], -A[1])); put(leg['shin'], Mk @ mat_T(-K[0], -K[1])); put(leg['thigh'], Mt)
    hip = meta['hip']; body = meta['body_melee'] if unarmed else meta['body']
    Mb = mat_R(-r(lean))
    put(body, Mb @ mat_T(-hip[0], -hip[1]))
    if weapon is not None:
        hand = meta['hand']; hv = np.array([hand[0] - hip[0], hand[1] - hip[1], 1.0])
        # weapon: rotate about the grip, handle-bottom offset `grip` px below the hand along the handle
        wh = weapon.height
        # piece-local px -> frame-space: translate so (w/2, h - grip*?) sits on the hand
        gy = wh - grip * wh
        Mw = Mb @ mat_T(hv[0], hv[1]) @ mat_R(r(wangle)) @ mat_T(-weapon.width / 2, -gy)
        M = np.diag([S, S, 1.0]) @ mat_T(hx, hy) @ np.diag([scale, scale, 1.0]) @ np.diag([0.5, 0.5, 1.0]) @ Mw   # weapon art is 2x
        inv = np.linalg.inv(M)
        img.alpha_composite(weapon.transform((W * S, H * S), Image.AFFINE, tuple(inv[:2].flatten()), resample=Image.BICUBIC))
    return img.resize((W * S // 2, H * S // 2), Image.LANCZOS)

if __name__ == '__main__':
    import weapons
    imgs, meta = rd.build(); wp = weapons.ITEMS()
    poses = [
        ('stance pipe', [-14, 16], [6, 0], 2, wp['wpn.pipe'], 25),
        ('windup',      [-22, 10], [20, 0], -8, wp['wpn.pipe'], -75),
        ('strike',      [-26, 38], [30, 0], 14, wp['wpn.pipe'], 120),
        ('machete',     [-24, 34], [28, 0], 12, wp['wpn.machete'], 95),
        ('cutter',      [-14, 16], [6, 0], 4, wp['wpn.cutter'], 90),
        ('guard',       [-30, 80], [130, 85], 8, wp['wpn.pipe'], -10),
        ('seated',      [96, 100], [92, 96], 4, None, 0),
    ]
    cw = 150 * S // 2
    sheet = Image.new('RGBA', (cw * len(poses), 140 * S // 2 + 14), (28, 46, 32, 255)); d = ImageDraw.Draw(sheet)
    for i, (nm, th, fl, ln, w, ang) in enumerate(poses):
        im = render_pose(imgs, meta, th, fl, ln, weapon=w, wangle=ang, unarmed=nm != 'seated' or True)
        sheet.alpha_composite(im, (i * cw, 14)); d.text((i * cw + 4, 2), nm, fill=(255, 255, 0, 255))
    sheet.convert('RGB').save(os.path.join(rd.ROOT, 'work', 'rig_poses.png')); print(sheet.size)
