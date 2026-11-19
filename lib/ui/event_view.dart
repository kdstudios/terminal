import 'dart:math';
import 'package:flutter/material.dart';
import '../game/event_data.dart';
import '../game/event_session.dart';
import '../game/game_state.dart';
import '../game/story_content.dart';
import 'atlas.dart';
import 'crt.dart';
import 'sprites.dart';
import 'theme.dart';

/// Main screen during a choice encounter: what you have come across. The story
/// and the choices live in the Encounter Log beside it.
class EventView extends StatelessWidget {
  final GameState state;
  const EventView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state.event!;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(eventTitleOf(s.id), style: T.mono(T.amber, size: 15, bold: true)),
          Expanded(
              child: CustomPaint(
                  painter: _ScenePainter(isStorySession(s.id) ? storyArtOf(s.id) : s.id))),
          Text(
            s.finished ? 'ENCOUNTER RESOLVED' : 'AWAITING YOUR DECISION',
            textAlign: TextAlign.center,
            style: T.mono(T.label, size: 12),
          ),
        ],
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final String id;
  _ScenePainter(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    // New derived illustration (full colour, run through the CRT filter).
    final art = Atlas.named('derived', 'event.$id');
    if (art != null) {
      final k = min(size.width / art.w, size.height / art.h);
      art.drawRect(
          canvas,
          Rect.fromCenter(center: size.center(Offset.zero), width: art.w * k, height: art.h * k),
          Paint()
            ..filterQuality = FilterQuality.medium
            ..colorFilter = Crt.phosphor(T.green, keep: 0.5));
      return;
    }
    final im = Sprites.get('event_$id');
    if (im != null) {
      final k = min(size.width / im.width, size.height / im.height);
      final sc = k >= 1 ? k.floorToDouble() : k;
      final dst = Rect.fromCenter(
          center: size.center(Offset.zero), width: im.width * sc, height: im.height * sc);
      Sprites.draw(canvas, 'event_$id', dst, T.green);
      return;
    }
    final u = min(size.width / 10, size.height / 6);
    if (u < 4) return;
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..color = T.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final dim = Paint()
      ..color = T.dim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final warm = Paint()
      ..color = T.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawLine(Offset(0, c.dy + u * 2.4), Offset(size.width, c.dy + u * 2.4), dim);

    switch (id) {
      case 'merchant':
        canvas.drawRect(
            Rect.fromCenter(center: Offset(c.dx, c.dy + u * 0.6), width: u * 4, height: u * 1.8), p);
        canvas.drawCircle(Offset(c.dx - u * 1.3, c.dy + u * 1.9), u * 0.5, p);
        canvas.drawCircle(Offset(c.dx + u * 1.3, c.dy + u * 1.9), u * 0.5, p);
        canvas.drawLine(Offset(c.dx - u * 2, c.dy + u * 0.2), Offset(c.dx - u * 3.2, c.dy - u * 0.8), p);
        canvas.drawLine(Offset(c.dx, c.dy - u * 0.3), Offset(c.dx, c.dy - u * 1.6), p);
        canvas.drawCircle(Offset(c.dx, c.dy - u * 1.8), u * 0.25, warm);
        break;
      case 'survivor':
        canvas.drawRect(Rect.fromLTWH(c.dx + u * 0.8, c.dy - u * 0.4, u * 3, u * 2.8), dim);
        canvas.drawCircle(Offset(c.dx - u * 0.8, c.dy - u * 0.6), u * 0.55, p);
        canvas.drawLine(Offset(c.dx - u * 0.8, c.dy - u * 0.05), Offset(c.dx - u * 0.6, c.dy + u * 1.3), p);
        canvas.drawLine(Offset(c.dx - u * 0.6, c.dy + u * 1.3), Offset(c.dx - u * 2, c.dy + u * 2.4), p);
        canvas.drawLine(Offset(c.dx - u * 0.6, c.dy + u * 1.3), Offset(c.dx + u * 0.5, c.dy + u * 2.4), p);
        canvas.drawLine(Offset(c.dx - u * 0.8, c.dy + u * 0.2), Offset(c.dx - u * 0.2, c.dy + u * 0.9), p);
        break;
      case 'building':
        final b = Path()
          ..moveTo(c.dx - u * 2.5, c.dy + u * 2.4)
          ..lineTo(c.dx - u * 2.5, c.dy - u * 1.2)
          ..lineTo(c.dx - u * 1.2, c.dy - u * 2)
          ..lineTo(c.dx - u * 0.2, c.dy - u * 1.2)
          ..lineTo(c.dx + u * 1.2, c.dy - u * 1.9)
          ..lineTo(c.dx + u * 2.5, c.dy - u * 1.1)
          ..lineTo(c.dx + u * 2.5, c.dy + u * 2.4);
        canvas.drawPath(b, p);
        canvas.drawRect(Rect.fromLTWH(c.dx - u * 0.5, c.dy + u * 0.6, u * 1.1, u * 1.8), dim);
        canvas.drawRect(Rect.fromLTWH(c.dx - u * 2, c.dy - u * 0.4, u * 0.9, u * 0.9), dim);
        break;
      case 'signal':
        canvas.drawLine(Offset(c.dx, c.dy + u * 2.4), Offset(c.dx, c.dy - u * 1.6), p);
        canvas.drawLine(Offset(c.dx, c.dy + u * 0.2), Offset(c.dx - u * 1.2, c.dy + u * 2.4), p);
        canvas.drawLine(Offset(c.dx, c.dy + u * 0.2), Offset(c.dx + u * 1.2, c.dy + u * 2.4), p);
        for (int i = 1; i <= 3; i++) {
          canvas.drawArc(
            Rect.fromCircle(center: Offset(c.dx, c.dy - u * 1.6), radius: u * 0.7 * i),
            -pi * 0.85,
            pi * 0.7,
            false,
            i == 3 ? dim : p,
          );
        }
        break;
      case 'camp':
        final t = Path()
          ..moveTo(c.dx - u * 2.6, c.dy + u * 2.4)
          ..lineTo(c.dx - u * 1.2, c.dy - u * 0.8)
          ..lineTo(c.dx + u * 0.2, c.dy + u * 2.4)
          ..close();
        canvas.drawPath(t, p);
        canvas.drawLine(Offset(c.dx - u * 1.2, c.dy - u * 0.8), Offset(c.dx - u * 1.2, c.dy + u * 2.4), dim);
        final f = Path()
          ..moveTo(c.dx + u * 1.6, c.dy + u * 2.4)
          ..lineTo(c.dx + u * 2, c.dy + u * 1.2)
          ..lineTo(c.dx + u * 2.3, c.dy + u * 1.8)
          ..lineTo(c.dx + u * 2.7, c.dy + u * 0.9)
          ..lineTo(c.dx + u * 3, c.dy + u * 2.4)
          ..close();
        canvas.drawPath(f, warm);
        break;
      case 'cave':
        final cv = Path()
          ..moveTo(c.dx - u * 3, c.dy + u * 2.4)
          ..lineTo(c.dx - u * 3, c.dy)
          ..quadraticBezierTo(c.dx - u * 3, c.dy - u * 2.4, c.dx, c.dy - u * 2.4)
          ..quadraticBezierTo(c.dx + u * 3, c.dy - u * 2.4, c.dx + u * 3, c.dy)
          ..lineTo(c.dx + u * 3, c.dy + u * 2.4);
        canvas.drawPath(cv, p);
        final inner = Path()
          ..moveTo(c.dx - u * 1.4, c.dy + u * 2.4)
          ..lineTo(c.dx - u * 1.4, c.dy + u * 0.3)
          ..quadraticBezierTo(c.dx - u * 1.4, c.dy - u * 1.2, c.dx, c.dy - u * 1.2)
          ..quadraticBezierTo(c.dx + u * 1.4, c.dy - u * 1.2, c.dx + u * 1.4, c.dy + u * 0.3)
          ..lineTo(c.dx + u * 1.4, c.dy + u * 2.4);
        canvas.drawPath(inner, dim);
        break;
      default:
        canvas.drawCircle(c, u, p);
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.id != id;
}
