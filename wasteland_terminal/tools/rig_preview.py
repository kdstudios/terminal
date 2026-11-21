"""Render the walk cycle with the SAME kinematics the Dart code uses (debug aid).
python3 tools/rig_preview.py  -> work/rig_cycle.png"""
import math, numpy as np
from PIL import Image, ImageDraw
import rig_dweller as rd

AMP, FLEX, FOOT_K = 34.0, 40.0, 0.35     # degrees; keep in sync with lib/ui/dweller_rig.dart
S = 4

def mat_T(x, y): return np.array([[1, 0, x], [0, 1, y], [0, 0, 1.0]])
def mat_R(a): c, s = math.cos(a), math.sin(a); return np.array([[c, -s, 0], [s, c, 0], [0, 0, 1.0]])

def pose(meta, phi, amp=1.0):
    out = []
    for k, leg in enumerate(meta['legs']):
        p = phi + (0 if k == 0 else math.pi)
        th = AMP * amp * math.sin(p)                       # forward-positive degrees
        flex = FLEX * amp * max(0.0, math.cos(p))
        sg = th - flex
        psi = FOOT_K * sg
        out.append((th, flex, sg, psi))
    return out

def depth(leg, th, sg, psi, meta):
    P, K, A = leg['P'], leg['K'], leg['A']
    Lt = math.dist(P, K); Ls = math.dist(K, A); Hf = meta['sole_y'] - A[1]
    r = math.radians
    return Lt * math.cos(r(th)) + Ls * math.cos(r(sg)) + Hf * math.cos(r(psi))

def render(phi, imgs, meta, W=130, H=130, amp=1.0, ground=118):
    img = Image.new('RGBA', (W * S, H * S), (0, 0, 0, 0))
    pz = pose(meta, phi, amp)
    d = max(depth(l, *pz[k][0::1][:1], pz[k][2], pz[k][3], meta) if False else depth(l, pz[k][0], pz[k][2], pz[k][3], meta) for k, l in enumerate(meta['legs']))
    hx, hy = 65, ground - d
    r = math.radians
    def put(name, M):
        ox, oy = meta['parts'][name]
        Mp = np.diag([S, S, 1.0]) @ mat_T(hx, hy) @ M @ mat_T(ox, oy)  # piece-local px -> canvas
        inv = np.linalg.inv(Mp)
        layer = imgs[name].transform((W * S, H * S), Image.AFFINE, tuple(inv[:2].flatten()), resample=Image.BICUBIC)
        img.alpha_composite(layer)
    order = [0, 1]    # leg 0 = far (drawn first), leg 1 = near
    for k in order:
        leg = meta['legs'][k]; th, flex, sg, psi = pz[k]
        P, K, A = leg['P'], leg['K'], leg['A']
        rt = -r(th - leg['th0'])
        rs = r(leg['sg0'] - leg['th0']) + r(flex)
        rf = -r(psi) + r(sg - leg['sg0'])
        Mt = mat_R(rt) @ mat_T(-P[0], -P[1])
        Mk = mat_R(rt) @ mat_T(K[0] - P[0], K[1] - P[1]) @ mat_R(rs)
        Ma = Mk @ mat_T(A[0] - K[0], A[1] - K[1]) @ mat_R(rf)
        put(leg['foot'], Ma @ mat_T(-A[0], -A[1]))
        put(leg['shin'], Mk @ mat_T(-K[0], -K[1]))
        put(leg['thigh'], Mt)
    hipx, hipy = meta['hip']
    put('dw.body', mat_T(-hipx, -hipy))
    return img.resize((W * S // 2, H * S // 2), Image.LANCZOS)

if __name__ == '__main__':
    imgs, meta = rd.build()
    n = 8
    sheet = Image.new('RGBA', (n * 130 * S // 2, 130 * S // 2), (30, 50, 30, 255))
    dr = ImageDraw.Draw(sheet)
    for i in range(n):
        f = render(i / n * 2 * math.pi, imgs, meta)
        sheet.alpha_composite(f, (i * 130 * S // 2, 0))
        dr.line([(i * 130 * S // 2, 118 * S // 2), ((i + 1) * 130 * S // 2, 118 * S // 2)], fill=(90, 160, 90, 255))
    sheet.convert('RGB').save(rd.ROOT + '/work/rig_cycle.png'); print(sheet.size)
