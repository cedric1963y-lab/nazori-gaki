import 'package:flutter/material.dart';

import '../core/kanji.dart';

/// 縦書きの1列。
class VColumn {
  const VColumn(this.text, {required this.sizePx, this.dropPx = 0});
  final String text;
  final double sizePx;

  /// 列の書き出しを下げる量。
  final double dropPx;
}

const _vert = [FontFeature.enable('vert'), FontFeature.enable('vrt2')];
const glyphStep = 1.04;

/// 列を右から左へ並べ、群れ全体を [center] の x を中心に、y を上端として描く。
class VerticalTextPainter extends CustomPainter {
  VerticalTextPainter({
    required this.columns,
    required this.fontFamily,
    required this.color,
    required this.origin,
    this.pitch = 1.3,
  });

  final List<VColumn> columns;
  final String fontFamily;
  final Color color;
  final Offset origin;

  /// 列の間隔（文字の大きさに対する倍率）。
  final double pitch;

  double get groupWidth {
    if (columns.isEmpty) return 0;
    var w = 0.0;
    for (var i = 0; i < columns.length; i++) {
      w += i == 0 ? columns[i].sizePx : columns[i].sizePx * pitch;
    }
    return w;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var right = origin.dx + groupWidth / 2;
    for (var i = 0; i < columns.length; i++) {
      final c = columns[i];
      if (i > 0) right -= c.sizePx * (pitch - 1);
      final cx = right - c.sizePx / 2;
      paintColumn(canvas, c, Offset(cx, origin.dy + c.dropPx));
      right -= c.sizePx;
    }
  }

  void paintColumn(Canvas canvas, VColumn c, Offset top) {
    final s = c.sizePx;
    var y = top.dy;
    for (final g in verticalGlyphs(c.text)) {
      if (g == ' ') {
        y += s * 0.5;
        continue;
      }
      final tp = TextPainter(
        text: TextSpan(
          text: g,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: s,
            height: 1.0,
            color: color,
            fontFeatures: _vert,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(top.dx - tp.width / 2, y + (s - tp.height) / 2));
      tp.dispose();
      y += s * glyphStep;
    }
  }

  @override
  bool shouldRepaint(covariant VerticalTextPainter old) =>
      old.columns != columns ||
      old.fontFamily != fontFamily ||
      old.color != color ||
      old.origin != origin ||
      old.pitch != pitch;
}

/// 縦書きの列の高さ（px）。
double columnHeight(VColumn c) {
  var h = 0.0;
  for (final g in verticalGlyphs(c.text)) {
    h += g == ' ' ? c.sizePx * 0.5 : c.sizePx * glyphStep;
  }
  return h + c.dropPx;
}

/// 一覧やプレビュー用の小さな縦書き。
class VerticalLabel extends StatelessWidget {
  const VerticalLabel(
    this.text, {
    super.key,
    required this.size,
    this.fontFamily = 'YujiSyuku',
    this.color = Colors.black,
  });

  final String text;
  final double size;
  final String fontFamily;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final col = VColumn(text, sizePx: size);
    return SizedBox(
      width: size * 1.1,
      height: columnHeight(col),
      child: CustomPaint(
        painter: VerticalTextPainter(
          columns: [col],
          fontFamily: fontFamily,
          color: color,
          origin: Offset(size * 0.55, 0),
        ),
      ),
    );
  }
}
