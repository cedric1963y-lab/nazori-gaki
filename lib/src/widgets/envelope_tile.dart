import 'package:flutter/material.dart';

import '../core/occasions.dart';
import '../ui/palette.dart';
import 'vertical_text.dart';

/// 用途を選ぶ一覧の、金封の形をしたタイル。
class EnvelopeTile extends StatelessWidget {
  const EnvelopeTile({super.key, required this.occasion, required this.onTap});

  final Occasion occasion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sample = occasion.isCustom ? '御祝' : occasion.omote.first;
    final ink = occasion.usuzumi ? Washi.usuzumi : Washi.sumi;
    return Semantics(
      button: true,
      label: occasion.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.64,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Washi.card,
                    border: Border.all(color: Washi.line),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A5E4B2A),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final glyph = (box.maxWidth * 0.26).clamp(10.0, 22.0);
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MizuhikiPainter(occasion.mood),
                            ),
                          ),
                          Positioned(
                            top: box.maxHeight * 0.08,
                            left: 0,
                            right: 0,
                            height: box.maxHeight * 0.44,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: occasion.isCustom
                                  ? Icon(
                                      Icons.edit_outlined,
                                      color: Washi.sumiSoft,
                                      size: glyph * 1.4,
                                    )
                                  : VerticalLabel(
                                      sample,
                                      size: glyph,
                                      color: ink,
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                occasion.label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Washi.sumi,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MizuhikiPainter extends CustomPainter {
  _MizuhikiPainter(this.mood);
  final Mood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.6;
    final colors = switch (mood) {
      Mood.celebration => [Washi.shu, Washi.shu, Colors.white, Colors.white],
      Mood.condolence => [Washi.sumi, Washi.sumi, Washi.gin, Washi.gin],
      Mood.neutral => [Washi.shu, Washi.kin, Washi.kin, Colors.white],
    };
    final w = size.height * 0.018;
    final p = Paint()..strokeWidth = w;
    for (var i = 0; i < colors.length; i++) {
      p.color = colors[i];
      final dy = y + (i - colors.length / 2) * w * 1.15;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), p);
    }
    // 結び目
    final knot = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 1.3
      ..color = colors.first;
    final r = size.width * 0.12;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2 - r * 0.8, y), width: r * 1.8, height: r * 1.1),
      knot,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2 + r * 0.8, y), width: r * 1.8, height: r * 1.1),
      knot,
    );
    if (mood == Mood.celebration) {
      // 熨斗
      final c = Offset(size.width * 0.82, size.height * 0.11);
      final s = size.width * 0.09;
      final path = Path()
        ..moveTo(c.dx, c.dy - s * 1.3)
        ..lineTo(c.dx + s * 0.7, c.dy - s * 0.3)
        ..lineTo(c.dx + s * 0.35, c.dy + s * 1.3)
        ..lineTo(c.dx - s * 0.35, c.dy + s * 1.3)
        ..lineTo(c.dx - s * 0.7, c.dy - s * 0.3)
        ..close();
      canvas.drawPath(path, Paint()..color = Colors.white);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Washi.shu,
      );
      canvas.drawLine(
        Offset(c.dx, c.dy - s * 0.4),
        Offset(c.dx, c.dy + s * 1.0),
        Paint()
          ..strokeWidth = s * 0.28
          ..color = const Color(0xFFE2B33C),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MizuhikiPainter old) => old.mood != mood;
}
