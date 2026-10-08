import 'dart:math';

import 'package:flutter/material.dart';

import '../ui/palette.dart';

/// 和紙の繊維をうっすら描いた背景。
class WashiBackdrop extends StatelessWidget {
  const WashiBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(child: CustomPaint(painter: _FiberPainter())),
        child,
      ],
    );
  }
}

class _FiberPainter extends CustomPainter {
  const _FiberPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Washi.paper);
    final rnd = Random(17);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final count = (size.width * size.height / 900).round();
    for (var i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final len = 6 + rnd.nextDouble() * 26;
      final a = rnd.nextDouble() * pi;
      final light = rnd.nextBool();
      paint
        ..strokeWidth = 0.4 + rnd.nextDouble() * 0.7
        ..color = (light ? Colors.white : Washi.paperDeep).withValues(
          alpha: 0.35 + rnd.nextDouble() * 0.4,
        );
      final path = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(
          x + cos(a) * len / 2 + rnd.nextDouble() * 4,
          y + sin(a) * len / 2 + rnd.nextDouble() * 4,
          x + cos(a) * len,
          y + sin(a) * len,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
