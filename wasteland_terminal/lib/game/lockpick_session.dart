import 'dart:math';
import 'package:flutter/foundation.dart';

enum LockEvent { none, snapped, opened }

/// Rules and physics for one lock. Ticked by LockpickingSystem; listened to by
/// the lock view only (so 60fps updates don't rebuild the whole game UI).
///
/// The pick angle runs -90..90 degrees (0 = straight down). One hidden "sweet
/// spot" angle opens the lock. The player pulls a lever (0..1): the cylinder
/// follows the lever, but only as far as the current angle allows (close to the
/// sweet spot = a long turn, far = barely any). Pulling the lever PAST what the
/// lock allows strains the pick, and the harder the over-pull, the faster the
/// strain builds. Strain is wear on the pick and carries over between locks.
class LockpickSession extends ChangeNotifier {
  static const names = ['BASIC', 'RESIDENTIAL', 'MILITARY', 'VAULT', 'LEGENDARY', 'BLACKSITE'];

  // Tuning constants.
  static const _follow = 4.0; // cylinder catches up to the lever (per second)
  static const _returnSpeed = 5.0; // cylinder springs back (per second)
  static const _leverReturn = 3.0; // released lever springs back (per second)
  static const _strainScale = 2.2; // overall strain speed
  static const _strainPower = 1.5; // >1 = hard over-pulls hurt disproportionately

  final int level; // 1..4
  final double sweet; // hidden sweet-spot angle in degrees
  final double tolerance; // half-width of the sweet spot in degrees
  final double spread; // how quickly "warmth" fades with distance
  final double stressRate; // base strain speed for this lock

  double pickAngle = 0;
  double lever = 0; // 0 = released, 1 = pulled fully left
  double progress = 0; // 0..1 cylinder turn
  double stress; // 0..1, pick snaps at 1 (starts at the pick's current wear)
  bool gripping = false; // finger is on the lever
  bool blocked = false; // pulling past what the lock allows
  bool engaged = false; // false = still on the PICK / IGNORE prompt
  bool finished = false;
  bool success = false;
  bool flawless = false;
  int broken = 0;

  LockpickSession._(this.level, this.sweet, this.tolerance, this.spread,
      this.stressRate, this.stress);

  String get lockName => names[level - 1];

  static const _tol = [14.0, 10.0, 7.0, 4.5, 3.2, 2.2];
  static const _spread = [70.0, 55.0, 42.0, 30.0, 24.0, 18.0];
  static const _rate = [0.5, 0.7, 0.95, 1.25, 1.5, 1.8];

  /// [skill] (Lockpicking, 0..10) widens the sweet spot and slows strain.
  factory LockpickSession.generate(int level, Random rng,
      {double strain = 0, int skill = 0}) {
    return LockpickSession._(
      level,
      rng.nextDouble() * 140 - 70,
      _tol[level - 1] + 0.8 * skill,
      _spread[level - 1],
      _rate[level - 1] * max(0.5, 1 - 0.04 * skill),
      strain,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'sweet': sweet,
        'tol': tolerance,
        'rate': stressRate,
        'stress': stress,
        'pickAngle': pickAngle,
        'progress': progress,
        'engaged': engaged,
        'finished': finished,
        'success': success,
        'flawless': flawless,
        'broken': broken,
      };

  /// The lever isn't saved: a restored lock always starts with the lever released.
  factory LockpickSession.fromJson(Map<String, dynamic> j) {
    final level = (j['level'] as num).toInt();
    final s = LockpickSession._(
      level,
      (j['sweet'] as num).toDouble(),
      (j['tol'] as num?)?.toDouble() ?? _tol[level - 1],
      _spread[level - 1],
      (j['rate'] as num?)?.toDouble() ?? _rate[level - 1],
      (j['stress'] as num).toDouble(),
    );
    s.pickAngle = (j['pickAngle'] as num).toDouble();
    s.progress = (j['progress'] as num).toDouble();
    s.engaged = j['engaged'] as bool;
    s.finished = j['finished'] as bool;
    s.success = j['success'] as bool;
    s.flawless = j['flawless'] as bool;
    s.broken = (j['broken'] as num).toInt();
    return s;
  }

  /// How far the cylinder may turn at the current pick angle (1.0 = opens).
  double get maxTurn {
    final d = (pickAngle - sweet).abs();
    if (d <= tolerance) return 1.0;
    final f = min(1.0, max(0.0, (d - tolerance) / spread));
    return 0.55 * (1 - f);
  }

  void refresh() => notifyListeners();

  /// Aim the pick. Not possible while tension is on the lever.
  void rotate(double degrees) {
    if (!engaged || finished || lever > 0.04) return;
    pickAngle = min(90.0, max(-90.0, pickAngle + degrees));
    notifyListeners();
  }

  void grip(bool v) {
    if (!engaged || finished) return;
    gripping = v;
    notifyListeners();
  }

  /// Move the lever by a fraction of its travel (positive = pulled further).
  void dragLever(double d) {
    if (!engaged || finished || !gripping) return;
    lever = min(1.0, max(0.0, lever + d));
    notifyListeners();
  }

  /// Fresh pick after a snap: no wear, no tension.
  void resetPick() {
    progress = 0;
    stress = 0;
    lever = 0;
    gripping = false;
    blocked = false;
    notifyListeners();
  }

  LockEvent step(double dt) {
    if (!engaged || finished) return LockEvent.none;

    // A released lever springs back.
    if (!gripping && lever > 0) lever = max(0.0, lever - _leverReturn * dt);

    // The cylinder follows the lever, but never past what the lock allows.
    final limit = maxTurn;
    final target = min(lever, limit);
    if (progress < target) {
      progress = min(target, progress + _follow * dt);
    } else if (progress > target) {
      progress = max(target, progress - _returnSpeed * dt);
    }

    var ev = LockEvent.none;
    if (limit >= 1.0 && progress >= 0.999) {
      progress = 1.0;
      finished = true;
      success = true;
      gripping = false;
      blocked = false;
      ev = LockEvent.opened;
    } else {
      final excess = lever - limit; // how hard you're pulling against the lock
      blocked = excess > 0.03;
      if (blocked) {
        // Wear is permanent: Pick HP never recovers, it only ever goes down
        // until the pick snaps (then you start a fresh one).
        stress += stressRate * _strainScale * pow(excess, _strainPower) * dt;
      }
      if (stress >= 1.0) {
        ev = LockEvent.snapped;
        lever = 0;
        gripping = false;
        blocked = false;
      }
    }
    notifyListeners();
    return ev;
  }
}
