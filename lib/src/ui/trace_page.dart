import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/draft.dart';
import '../core/kanji.dart';
import '../widgets/vertical_text.dart';
import 'palette.dart';
import 'scope.dart';
import 'setup_page.dart' show openUnlock;

/// 実寸の縦書きを白い画面に出し、紙を重ねてなぞる画面。
class TracePage extends StatefulWidget {
  const TracePage({super.key, this.initialPage = TracePageKind.omote});

  final TracePageKind initialPage;

  @override
  State<TracePage> createState() => _TracePageState();
}

class _TracePageState extends State<TracePage> {
  late TracePageKind _page = widget.initialPage;
  bool _locked = false;
  bool _hint = false;
  Timer? _hintTimer;
  Nudge _startNudge = const Nudge();

  @override
  void initState() {
    super.initState();
    unawaited(_enterTraceMode());
  }

  Future<void> _enterTraceMode() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}
    try {
      await WakelockPlus.enable();
    } catch (_) {}
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    } catch (_) {}
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    unawaited(WakelockPlus.disable().catchError((_) {}));
    unawaited(
      ScreenBrightness.instance.resetApplicationScreenBrightness().catchError((_) {}),
    );
    super.dispose();
  }

  void _lock() {
    HapticFeedback.mediumImpact();
    setState(() {
      _locked = true;
      _hint = true;
    });
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _hint = false);
    });
  }

  void _unlockControls() {
    HapticFeedback.selectionClick();
    _hintTimer?.cancel();
    setState(() {
      _locked = false;
      _hint = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final d = scope.draft;
    final unlocked = scope.unlock.unlocked;
    return ListenableBuilder(
      listenable: Listenable.merge([d, scope.unlock]),
      builder: (context, _) {
        final pages = [
          TracePageKind.omote,
          TracePageKind.name,
          if (d.envelope.hasNaka) ...[TracePageKind.nakaFront, TracePageKind.nakaBack],
        ];
        if (!pages.contains(_page)) _page = TracePageKind.omote;
        final pageLocked = _page.needsUnlock && !unlocked;
        final mm = d.ptPerMm(MediaQuery.devicePixelRatioOf(context));
        final nudge = d.nudge(_page);
        return Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (context, box) {
              final layout = _layoutFor(d, _page, unlocked, mm, nudge, box.biggest);
              return Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: _locked ? _unlockControls : null,
                    onScaleStart: _locked ? null : (_) => _startNudge = d.nudge(_page),
                    onScaleUpdate: _locked
                        ? null
                        : (s) {
                            final cur = d.nudge(_page);
                            d.setNudge(
                              _page,
                              cur.copyWith(
                                dxMm: cur.dxMm + s.focalPointDelta.dx / mm,
                                dyMm: cur.dyMm + s.focalPointDelta.dy / mm,
                                scale: s.pointerCount > 1
                                    ? _startNudge.scale * s.scale
                                    : cur.scale,
                              ),
                            );
                          },
                    child: CustomPaint(
                      painter: _GuidePainter(
                        show: d.guides,
                        ptPerMm: mm,
                        centerX: layout.origin.dx,
                      ),
                      foregroundPainter: pageLocked || layout.columns.isEmpty
                          ? null
                          : VerticalTextPainter(
                              columns: layout.columns,
                              fontFamily: d.fontFamilyFor(unlocked: unlocked),
                              color: d.usuzumi ? Washi.usuzumi : Washi.koizumi,
                              origin: layout.origin,
                              pitch: layout.pitch,
                            ),
                    ),
                  ),
                  if (!pageLocked && layout.columns.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          layout.emptyMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Washi.sumiSoft, height: 1.6),
                        ),
                      ),
                    ),
                  if (pageLocked) _LockedPage(page: _page),
                  if (!_locked) ...[
                    _TopBar(
                      pages: pages,
                      current: _page,
                      unlocked: unlocked,
                      onPage: (p) => setState(() => _page = p),
                    ),
                    _BottomBar(
                      scale: nudge.scale,
                      guides: d.guides,
                      onScale: (v) => d.setNudge(_page, nudge.copyWith(scale: v)),
                      onReset: () => d.resetNudge(_page),
                      onGuides: () => d.update((d) => d.guides = !d.guides),
                      onLock: _lock,
                    ),
                  ],
                  if (_locked)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 40,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _hint ? 1 : 0,
                          duration: const Duration(milliseconds: 400),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Washi.sumi.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '画面を固定しました。長押しで操作に戻ります',
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _Layout {
  const _Layout(this.columns, this.origin, {this.pitch = 1.3, this.emptyMessage = ''});
  final List<VColumn> columns;
  final Offset origin;
  final double pitch;
  final String emptyMessage;
}

const _topMarginMm = 22.0;

_Layout _layoutFor(
  Draft d,
  TracePageKind page,
  bool unlocked,
  double mm,
  Nudge n,
  Size screen,
) {
  final e = d.envelope;
  final s = n.scale * mm;
  final origin = Offset(
    screen.width / 2 + n.dxMm * mm,
    _topMarginMm * mm + n.dyMm * mm,
  );
  switch (page) {
    case TracePageKind.omote:
      final t = d.omote.trim();
      if (t.isEmpty) {
        return _Layout(const [], origin, emptyMessage: '表書きが入力されていません。\n前の画面で選ぶか入力してください。');
      }
      return _Layout([VColumn(t, sizePx: e.omoteMm * s)], origin);
    case TracePageKind.name:
      final names = d.namesFor(unlocked: unlocked);
      if (names.isEmpty) {
        return _Layout(const [], origin, emptyMessage: 'お名前が入力されていません。\n前の画面で入力してください。');
      }
      final factor = switch (names.length) { 1 => 1.0, 2 => 0.9, _ => 0.8 };
      return _Layout(
        [for (final name in names) VColumn(name, sizePx: e.nameMm * factor * s)],
        origin,
        pitch: 1.35,
      );
    case TracePageKind.nakaFront:
      final yen = parseYen(d.amountText);
      final text = yen == null ? null : daijiAmount(yen, nari: d.nari);
      if (text == null || e.amountMm == null) {
        return _Layout(const [], origin, emptyMessage: '包む金額が入力されていません。\n前の画面の「中袋」で入力してください。');
      }
      return _Layout([VColumn(text, sizePx: e.amountMm! * s)], origin);
    case TracePageKind.nakaBack:
      final names = d.namesFor(unlocked: unlocked);
      final addr = addressForVertical(d.address.trim(), kanjiDigits: d.kanjiDigits);
      if ((names.isEmpty && addr.isEmpty) || e.addressMm == null) {
        return _Layout(const [], origin, emptyMessage: '住所とお名前が入力されていません。\n前の画面で入力してください。');
      }
      final aSize = e.addressMm! * s;
      final availMm = screen.height / mm - _topMarginMm * 2;
      final perColumn = math.max(4, (availMm / (e.addressMm! * n.scale * glyphStep)).floor());
      final glyphs = verticalGlyphs(addr);
      final cols = <VColumn>[];
      for (var i = 0; i < glyphs.length; i += perColumn) {
        final chunk = glyphs.sublist(i, math.min(glyphs.length, i + perColumn)).join();
        cols.add(VColumn(chunk.trim(), sizePx: aSize, dropPx: i == 0 ? 0 : aSize));
      }
      for (final name in names.take(1)) {
        cols.add(VColumn(name, sizePx: e.nakaNameMm! * s, dropPx: aSize * 3));
      }
      return _Layout(cols, origin, pitch: 1.5);
  }
}

class _GuidePainter extends CustomPainter {
  _GuidePainter({required this.show, required this.ptPerMm, required this.centerX});
  final bool show;
  final double ptPerMm;
  final double centerX;

  @override
  void paint(Canvas canvas, Size size) {
    if (!show) return;
    final p = Paint()
      ..color = const Color(0xFFD5D5D5)
      ..strokeWidth = 0.8;
    // ものさし（左端、1mm ごと）
    final count = (size.height / ptPerMm).floor();
    for (var i = 0; i <= count; i++) {
      final y = i * ptPerMm;
      final len = i % 10 == 0 ? 5.0 : (i % 5 == 0 ? 3.5 : 2.0);
      canvas.drawLine(Offset(0, y), Offset(len * ptPerMm, y), p);
      if (i % 10 == 0 && i > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${i ~/ 10}',
            style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 9),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(6 * ptPerMm, y - tp.height / 2));
        tp.dispose();
      }
    }
    // 中心線（点線）
    final dash = 3 * ptPerMm;
    for (var y = 0.0; y < size.height; y += dash * 2) {
      canvas.drawLine(Offset(centerX, y), Offset(centerX, y + dash), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePainter old) =>
      old.show != show || old.ptPerMm != ptPerMm || old.centerX != centerX;
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.pages,
    required this.current,
    required this.unlocked,
    required this.onPage,
  });

  final List<TracePageKind> pages;
  final TracePageKind current;
  final bool unlocked;
  final ValueChanged<TracePageKind> onPage;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Washi.paper.withValues(alpha: 0.94),
        child: SafeArea(
          bottom: false,
          minimum: const EdgeInsets.only(top: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 12, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: '戻る',
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final p in pages)
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: ChoiceChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                              avatar: p.needsUnlock && !unlocked
                                  ? const Icon(Icons.lock_outline, size: 14)
                                  : null,
                              label: Text(p.label),
                              selected: p == current,
                              onSelected: (_) => onPage(p),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.scale,
    required this.guides,
    required this.onScale,
    required this.onReset,
    required this.onGuides,
    required this.onLock,
  });

  final double scale;
  final bool guides;
  final ValueChanged<double> onScale;
  final VoidCallback onReset;
  final VoidCallback onGuides;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Washi.paper.withValues(alpha: 0.94),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundIcon(
                      icon: Icons.remove,
                      tooltip: '小さく',
                      onTap: () => onScale((scale - 0.02).clamp(0.5, 1.6)),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '${(scale * 100).round()}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    _RoundIcon(
                      icon: Icons.add,
                      tooltip: '大きく',
                      onTap: () => onScale((scale + 0.02).clamp(0.5, 1.6)),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: '実寸・中央に戻す',
                      icon: const Icon(Icons.restart_alt),
                      onPressed: onReset,
                    ),
                    IconButton(
                      tooltip: 'ものさしと中心線',
                      icon: const Icon(Icons.straighten),
                      color: guides ? Washi.shu : Washi.sumiSoft,
                      onPressed: onGuides,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: onLock,
                  icon: const Icon(Icons.lock_outline, size: 20),
                  label: const Text('画面を固定してなぞる'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(side: const BorderSide(color: Washi.line)),
    );
  }
}

class _LockedPage extends StatelessWidget {
  const _LockedPage({required this.page});
  final TracePageKind page;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 36, color: Washi.kin),
            const SizedBox(height: 12),
            Text(
              '「${page.label}」は全機能アンロックで使えます',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              '中袋の金額を大字（例: 金参萬圓）で、住所とお名前を縦書きで表示します。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Washi.sumiSoft, height: 1.5),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => openUnlock(context),
              child: const Text('くわしく見る'),
            ),
          ],
        ),
      ),
    );
  }
}
