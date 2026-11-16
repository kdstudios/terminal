import 'dart:math';
import 'package:flutter/material.dart';
import 'atlas.dart';

class _Part {
  final AtlasSprite sp;
  final double ox, oy; // top-left in the ORIGINAL frame's pixel space
  const _Part(this.sp, this.ox, this.oy);
}

class _Leg {
  final _Part thigh, shin, foot;
  final Offset p, k, a; // hip / knee / ankle pivots (frame space)
  final double th0, sg0; // rest angles of thigh and shin (radians, forward-positive)
  final double lt, ls, hf; // thigh length, shin length, ankle->sole
  const _Leg(this.thigh, this.shin, this.foot, this.p, this.k, this.a, this.th0, this.sg0, this.lt,
      this.ls, this.hf);
}

/// The dweller as a paper doll (body + two legs of thigh/shin/foot) cut from one
/// frame of the artist's sheet by tools/rig_dweller.py. Joint angles are driven
/// every frame from a gait phase, so the walk is continuous, can run at ANY speed
/// and stops/starts smoothly (no pose swapping). Keep the constants in sync with
/// tools/rig_preview.py, which renders the same maths for checking.
class DwellerRig {
  static const double ampDeg = 34; // thigh swing either side of vertical
  static const double flexDeg = 40; // knee bend on the forward swing
  static const double footK = 0.35; // how much the foot follows the shin (rest = flat)

  final _Part _body;
  final _Part? _bodyMelee; // the rifle removed, for melee / tool poses
  final List<_Leg> _legs;
  final Offset hip;
  final Offset _hand; // where a held weapon is gripped (frame space)
  const DwellerRig._(this._body, this._bodyMelee, this._legs, this.hip, this._hand);

  /// Sheet pixels the walker travels per full gait cycle (two steps).
  static const double stridePx = 50;

  static DwellerRig? load() {
    final m = Atlas.rig('derived', 'dweller');
    if (m == null) return null;
    try {
      final parts = Map<String, dynamic>.from(m['parts'] as Map);
      _Part part(String name) {
        final sp = Atlas.named('derived', name);
        final o = parts[name] as List;
        if (sp == null) throw StateError('missing $name');
        return _Part(sp, (o[0] as num).toDouble(), (o[1] as num).toDouble());
      }

      Offset pt(dynamic v) => Offset((v[0] as num).toDouble(), (v[1] as num).toDouble());
      final soleY = (m['sole_y'] as num).toDouble();
      final legs = <_Leg>[];
      for (final l in m['legs'] as List) {
        final p = pt(l['P']), k = pt(l['K']), a = pt(l['A']);
        legs.add(_Leg(
          part(l['thigh'] as String),
          part(l['shin'] as String),
          part(l['foot'] as String),
          p,
          k,
          a,
          (l['th0'] as num).toDouble() * pi / 180,
          (l['sg0'] as num).toDouble() * pi / 180,
          (k - p).distance,
          (a - k).distance,
          soleY - a.dy,
        ));
      }
      final melee = m['body_melee'] == null ? null : part(m['body_melee'] as String);
      return DwellerRig._(part(m['body'] as String), melee, legs, pt(m['hip']),
          m['hand'] == null ? pt(m['hip']) : pt(m['hand']));
    } catch (_) {
      return null;
    }
  }

  void _draw(Canvas c, _Part part, Offset pivot, Paint paint) {
    final sp = part.sp;
    c.drawImageRect(sp.image, sp.src,
        Rect.fromLTWH(part.ox - pivot.dx, part.oy - pivot.dy, sp.w, sp.h), paint);
  }

  /// Gait: [ground] is where the standing feet touch the ground (hip x), [phase]
  /// the gait phase in radians, [energy] 0 = standing .. 1 = full stride, [t]
  /// seconds (idle breathing).
  void draw(Canvas c,
      {required Offset ground,
      required double scale,
      required double phase,
      required double energy,
      required double t,
      required Paint near,
      required Paint far}) {
    final th = List<double>.filled(2, 0), flex = List<double>.filled(2, 0);
    for (int k = 0; k < 2; k++) {
      final p = phase + (k == 0 ? 0 : pi);
      th[k] = ampDeg * pi / 180 * energy * sin(p);
      flex[k] = flexDeg * pi / 180 * energy * max(0.0, cos(p));
    }
    _render(c, ground, scale, th, flex, sin(t * 2.2) * 0.5 * (1 - energy), 0, near, far);
  }

  /// A fixed pose instead of a gait: explicit thigh / knee angles per leg
  /// ([back, front], degrees; thigh forward-positive, knee bend as in the gait).
  /// [lean] tips the body forward. Used for sitting by the campfire.
  void drawPose(Canvas c,
      {required Offset ground,
      required double scale,
      required List<double> thighDeg,
      required List<double> flexDeg,
      double leanDeg = 0,
      double breathe = 0,
      bool unarmed = false,
      void Function(Canvas c, Offset hand)? overlay,
      required Paint near,
      required Paint far}) {
    _render(c, ground, scale, [for (final d in thighDeg) d * pi / 180],
        [for (final d in flexDeg) d * pi / 180], breathe, leanDeg * pi / 180, near, far,
        unarmed: unarmed, overlay: overlay);
  }

  void _render(Canvas c, Offset ground, double scale, List<double> th, List<double> flex,
      double breathe, double lean, Paint near, Paint far,
      {bool unarmed = false, void Function(Canvas c, Offset hand)? overlay}) {
    final sg = List<double>.filled(2, 0);
    double maxDepth = 0;
    for (int k = 0; k < 2; k++) {
      sg[k] = th[k] - flex[k];
      final l = _legs[k];
      // Planted-foot rule: the lowest sole sits on the ground, so the body bobs
      // exactly as the legs dictate (highest passing, lowest at full stride).
      final d = l.lt * cos(th[k]) + l.ls * cos(sg[k]) + l.hf * cos(footK * sg[k]);
      maxDepth = max(maxDepth, d);
    }

    c.save();
    c.translate(ground.dx, ground.dy - (maxDepth + breathe) * scale);
    c.scale(scale);
    for (int k = 0; k < 2; k++) {
      final l = _legs[k];
      final paint = k == 0 ? far : near; // leg 0 is the far leg: drawn first, dimmer
      final rt = -(th[k] - l.th0);
      final rs = (l.sg0 - l.th0) + flex[k];
      final rf = -footK * sg[k] + (sg[k] - l.sg0);
      c.save();
      c.rotate(rt);
      c.translate(l.k.dx - l.p.dx, l.k.dy - l.p.dy);
      c.save();
      c.rotate(rs);
      c.save();
      c.translate(l.a.dx - l.k.dx, l.a.dy - l.k.dy);
      c.rotate(rf);
      _draw(c, l.foot, l.a, paint);
      c.restore();
      _draw(c, l.shin, l.k, paint);
      c.restore();
      _draw(c, l.thigh, l.k, paint);
      c.restore();
    }
    if (lean != 0) c.rotate(-lean);
    _draw(c, unarmed && _bodyMelee != null ? _bodyMelee! : _body, hip, near);
    // Drawn in the body's own frame (origin = hip, 1 unit = 1 sheet px), so a held
    // weapon follows the lean. The callback gets the grip point.
    overlay?.call(c, _hand - hip);
    c.restore();
  }
}
