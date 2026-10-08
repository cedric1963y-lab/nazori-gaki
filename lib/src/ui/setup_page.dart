import 'package:flutter/material.dart';

import '../core/brush_fonts.dart';
import '../core/draft.dart';
import '../core/envelopes.dart';
import '../core/kanji.dart';
import '../core/occasions.dart';
import '../widgets/washi_backdrop.dart';
import 'palette.dart';
import 'scope.dart';
import 'trace_page.dart';
import 'unlock_page.dart';

void openUnlock(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const UnlockPage()),
  );
}

/// 表書き・名前・袋の大きさ・墨の色・書体・中袋を決める画面。
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _custom = TextEditingController();
  final List<TextEditingController> _names = [];
  final _amount = TextEditingController();
  final _address = TextEditingController();
  bool _customOmote = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_names.isNotEmpty) return;
    final d = AppScope.of(context).draft;
    _customOmote = d.occasion.isCustom;
    _custom.text = d.occasion.isCustom ? d.omote : '';
    for (final n in d.names) {
      _names.add(TextEditingController(text: n));
    }
    _amount.text = d.amountText;
    _address.text = d.address;
  }

  @override
  void dispose() {
    _custom.dispose();
    _amount.dispose();
    _address.dispose();
    for (final c in _names) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _start() async {
    final scope = AppScope.of(context);
    final d = scope.draft;
    if (d.omote.trim().isEmpty && d.namesFor(unlocked: true).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('表書きか名前を入力してください。')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    if (scope.unlock.unlocked) await d.remember();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TracePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final d = scope.draft;
    final unlock = scope.unlock;
    return ListenableBuilder(
      listenable: Listenable.merge([d, unlock]),
      builder: (context, _) {
        final o = d.occasion;
        final accent = Washi.accentFor(o.mood);
        return Scaffold(
          appBar: AppBar(title: Text(o.label)),
          extendBodyBehindAppBar: false,
          body: WashiBackdrop(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  _Note(text: o.note, accent: accent),
                  _Section(
                    title: '表書き',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final t in o.omote)
                              ChoiceChip(
                                label: Text(t),
                                selected: !_customOmote && d.omote == t,
                                onSelected: (_) {
                                  setState(() => _customOmote = false);
                                  d.update((d) => d.omote = t);
                                },
                              ),
                            ChoiceChip(
                              label: const Text('自由に入力'),
                              selected: _customOmote,
                              onSelected: (_) {
                                setState(() => _customOmote = true);
                                d.update((d) => d.omote = _custom.text);
                              },
                            ),
                          ],
                        ),
                        if (_customOmote) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _custom,
                            maxLength: 8,
                            decoration: const InputDecoration(
                              hintText: '例: 御祝・御礼・志',
                              counterText: '',
                            ),
                            onChanged: (v) => d.update((d) => d.omote = v),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _Section(
                    title: 'お名前',
                    trailing: unlock.unlocked ? null : const _LockBadge('連名は全機能'),
                    child: _namesEditor(d, unlock.unlocked),
                  ),
                  _Section(
                    title: '袋の大きさ',
                    child: Column(
                      children: [
                        for (final e in envelopeSizes)
                          _EnvelopeOption(
                            size: e,
                            selected: d.envelopeId == e.id,
                            onTap: () => d.setEnvelope(e.id),
                          ),
                      ],
                    ),
                  ),
                  _Section(
                    title: '墨の色',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: Washi.sumi,
                            selectedForegroundColor: Washi.paper,
                            side: const BorderSide(color: Washi.line),
                          ),
                          segments: const [
                            ButtonSegment(value: false, label: Text('濃墨（お祝い・お礼）')),
                            ButtonSegment(value: true, label: Text('薄墨（弔事）')),
                          ],
                          selected: {d.usuzumi},
                          onSelectionChanged: (s) =>
                              d.update((d) => d.usuzumi = s.first),
                        ),
                        if (o.mood == Mood.condolence)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              '薄墨は「涙で墨が薄まった」という意味。通夜・葬儀の香典に使います。',
                              style: TextStyle(fontSize: 12.5, color: Washi.sumiSoft),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _Section(
                    title: '書体',
                    trailing: unlock.unlocked ? null : const _LockBadge('4書体は全機能'),
                    child: _fontPicker(d, unlock.unlocked),
                  ),
                  if (d.envelope.hasNaka)
                    _Section(
                      title: '中袋',
                      trailing: unlock.unlocked ? null : const _LockBadge('全機能'),
                      child: _nakaEditor(d, unlock.unlocked),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '次の画面で、ドラッグで位置、2本指で大きさを調整できます',
                  style: TextStyle(fontSize: 12, color: Washi.sumiSoft),
                ),
                const SizedBox(height: 6),
                FilledButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.brush_outlined),
                  label: const Text('なぞり書きを始める'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _namesEditor(Draft d, bool unlocked) {
    final count = unlocked ? d.names.length : 1;
    while (_names.length < d.names.length) {
      _names.add(TextEditingController());
    }
    final history = unlocked ? d.nameHistory : const <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: _names[i],
              maxLength: 12,
              decoration: InputDecoration(
                counterText: '',
                hintText: i == 0 ? '例: 鈴木 隼人' : '${i + 1}人目（左に並びます）',
                suffixIcon: i == 0
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _names.removeAt(i).dispose();
                          d.removeName(i);
                        },
                      ),
              ),
              onChanged: (v) => d.setName(i, v),
            ),
          ),
        const Text(
          '姓と名の間にスペースを入れると、少し間をあけて表示します。',
          style: TextStyle(fontSize: 12.5, color: Washi.sumiSoft),
        ),
        const SizedBox(height: 8),
        if (count < maxNames)
          TextButton.icon(
            onPressed: unlocked ? d.addName : () => openUnlock(context),
            icon: Icon(unlocked ? Icons.person_add_alt : Icons.lock_outline, size: 18),
            label: Text('連名を追加（最大$maxNames名）'),
          ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 4),
          const Text('履歴', style: TextStyle(fontSize: 12.5, color: Washi.sumiSoft)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final h in history.take(8))
                InputChip(
                  label: Text(h),
                  onPressed: () {
                    final i = d.names.indexWhere((n) => n.trim().isEmpty);
                    final at = i >= 0 ? i : 0;
                    _names[at].text = h;
                    d.setName(at, h);
                  },
                  onDeleted: () => d.forget(h),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _fontPicker(Draft d, bool unlocked) {
    final sample = d.omote.trim().isEmpty ? '御祝' : d.omote.trim();
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brushFonts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final f = brushFonts[i];
          final locked = !unlocked && !f.free;
          final selected = d.fontFamilyFor(unlocked: unlocked) == f.family;
          return GestureDetector(
            onTap: () => locked ? openUnlock(context) : d.setFont(f.id),
            child: Container(
              width: 92,
              decoration: BoxDecoration(
                color: Washi.card,
                border: Border.all(
                  color: selected ? Washi.sumi : Washi.line,
                  width: selected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
              child: Column(
                children: [
                  Expanded(
                    child: FittedBox(
                      child: Text(
                        sample.characters.take(2).toString(),
                        style: TextStyle(
                          fontFamily: f.family,
                          fontSize: 34,
                          color: locked ? Washi.sumiSoft : Washi.sumi,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (locked)
                        const Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(Icons.lock_outline, size: 13, color: Washi.sumiSoft),
                        ),
                      Text(f.label, style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _nakaEditor(Draft d, bool unlocked) {
    final yen = parseYen(d.amountText);
    final daiji = yen == null ? null : daijiAmount(yen, nari: d.nari);
    final editor = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _amount,
          enabled: unlocked,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '包む金額（円）',
            hintText: '例: 30000',
          ),
          onChanged: (v) => d.update((d) => d.amountText = v),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                daiji ?? (d.amountText.isEmpty ? '大字で表示します（例: 金参萬圓）' : '金額を数字で入力してください'),
                style: TextStyle(
                  fontFamily: daiji == null ? null : 'YujiSyuku',
                  fontSize: daiji == null ? 12.5 : 22,
                  color: daiji == null ? Washi.sumiSoft : Washi.sumi,
                ),
              ),
            ),
            const Text('也をつける', style: TextStyle(fontSize: 13)),
            Switch(
              value: d.nari,
              onChanged: unlocked ? (v) => d.update((d) => d.nari = v) : null,
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _address,
          enabled: unlocked,
          maxLength: 40,
          decoration: const InputDecoration(
            labelText: '住所（中袋の裏）',
            hintText: '例: 東京都港区南青山1-2-3',
            counterText: '',
          ),
          onChanged: (v) => d.update((d) => d.address = v),
        ),
        if (unlocked && d.addressHistory.isNotEmpty)
          Wrap(
            spacing: 6,
            children: [
              for (final a in d.addressHistory.take(3))
                ActionChip(
                  label: Text(a, overflow: TextOverflow.ellipsis),
                  onPressed: () {
                    _address.text = a;
                    d.update((d) => d.address = a);
                  },
                ),
            ],
          ),
        Row(
          children: [
            const Expanded(
              child: Text('住所の数字を漢数字にする（1-2-3 → 一ー二ー三）', style: TextStyle(fontSize: 13)),
            ),
            Switch(
              value: d.kanjiDigits,
              onChanged: unlocked ? (v) => d.update((d) => d.kanjiDigits = v) : null,
            ),
          ],
        ),
      ],
    );
    if (unlocked) return editor;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openUnlock(context),
      child: Stack(
        children: [
          Opacity(opacity: 0.45, child: IgnorePointer(child: editor)),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Washi.sumi,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, color: Washi.paper, size: 18),
                    SizedBox(width: 8),
                    Text('全機能アンロックで使えます', style: TextStyle(color: Washi.paper)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: Washi.title,
                  fontSize: 18,
                  color: Washi.sumi,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openUnlock(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 14, color: Washi.kin),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 12, color: Washi.kin)),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.accent});
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Washi.card,
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.6)),
    );
  }
}

class _EnvelopeOption extends StatelessWidget {
  const _EnvelopeOption({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final EnvelopeSize size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? Washi.sumi : Washi.card,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: selected ? Washi.sumi : Washi.line),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        size.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: selected ? Washi.paper : Washi.sumi,
                        ),
                      ),
                      Text(
                        size.detail,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: selected ? Washi.paperDeep : Washi.sumiSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '表書き ${_mm(size.omoteMm)}／名前 ${_mm(size.nameMm)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Washi.paperDeep : Washi.sumiSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _mm(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}mm' : '${v}mm';
}
