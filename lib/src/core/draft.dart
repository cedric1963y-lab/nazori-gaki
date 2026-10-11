import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'brush_fonts.dart';
import 'envelopes.dart';
import 'occasions.dart';

enum TracePageKind { omote, name, nakaFront, nakaBack }

extension TracePageLabel on TracePageKind {
  String get label => switch (this) {
    TracePageKind.omote => '表書き',
    TracePageKind.name => 'お名前',
    TracePageKind.nakaFront => '中袋 表',
    TracePageKind.nakaBack => '中袋 裏',
  };

  bool get needsUnlock => this == TracePageKind.nakaFront || this == TracePageKind.nakaBack;
}

/// ページごとの微調整（倍率とずらし量〈ミリ〉）。
class Nudge {
  const Nudge({this.scale = 1, this.dxMm = 0, this.dyMm = 0});
  final double scale;
  final double dxMm;
  final double dyMm;

  Nudge copyWith({double? scale, double? dxMm, double? dyMm}) => Nudge(
    scale: scale ?? this.scale,
    dxMm: dxMm ?? this.dxMm,
    dyMm: dyMm ?? this.dyMm,
  );
}

const maxNames = 3;
const _historyKey = 'history.names';
const _addressKey = 'history.address';
const _calibrationKey = 'calibration.ptPerMm';
const _fontKey = 'draft.font';
const _envelopeKey = 'draft.envelope.';

/// いま書こうとしている袋の内容。名前の履歴と実寸の補正もここで持つ。
class Draft extends ChangeNotifier {
  Draft(this.prefs) : _ptPerMmOverride = prefs.getDouble(_calibrationKey) {
    _fontId = prefs.getString(_fontKey) ?? freeFont;
  }

  final SharedPreferences prefs;

  Occasion occasion = occasions.first;
  String omote = occasions.first.omote.first;
  List<String> names = [''];
  String envelopeId = 'large';
  bool usuzumi = false;
  String amountText = '';
  bool nari = false;
  String address = '';
  bool kanjiDigits = true;
  bool guides = true;

  /// のし紙で名字だけを書くか。
  bool surnameOnly = false;

  /// 会社名・肩書き（全機能）。名前の右に小さく並べる。
  String company = '';
  String title = '';
  late String _fontId;
  final Map<TracePageKind, Nudge> _nudges = {};
  double? _ptPerMmOverride;

  String get fontId => _fontId;
  EnvelopeSize get envelope => envelopeById(envelopeId);

  void startFor(Occasion o) {
    occasion = o;
    omote = o.isCustom ? '' : o.omote.first;
    envelopeId = prefs.getString('$_envelopeKey${o.id}') ?? o.envelopeId;
    usuzumi = o.usuzumi;
    _nudges.clear();
    notifyListeners();
  }

  void update(void Function(Draft d) change) {
    change(this);
    notifyListeners();
  }

  void setEnvelope(String id) {
    envelopeId = id;
    _nudges.clear();
    prefs.setString('$_envelopeKey${occasion.id}', id);
    notifyListeners();
  }

  void setFont(String id) {
    _fontId = id;
    prefs.setString(_fontKey, id);
    notifyListeners();
  }

  void setName(int index, String value) {
    while (names.length <= index) {
      names.add('');
    }
    names[index] = value;
    notifyListeners();
  }

  void addName() {
    if (names.length < maxNames) names.add('');
    notifyListeners();
  }

  void removeName(int index) {
    if (names.length > 1 && index < names.length) names.removeAt(index);
    notifyListeners();
  }

  /// 実際に表示する名前（無料版は1人目だけ）。
  List<String> namesFor({required bool unlocked}) {
    final filled = names.where((n) => n.trim().isNotEmpty).toList();
    if (filled.isEmpty) return const [];
    final list = unlocked ? filled.take(maxNames).toList() : [filled.first];
    if (unlocked && surnameOnly && envelope.noshi) {
      return [for (final n in list) n.trim().split(RegExp(r'[ 　]+')).first];
    }
    return list;
  }

  /// 名前の右に添える会社名・肩書き（全機能）。
  String companyLineFor({required bool unlocked}) {
    if (!unlocked) return '';
    return [company.trim(), title.trim()].where((e) => e.isNotEmpty).join('　');
  }

  String fontFamilyFor({required bool unlocked}) {
    final f = fontById(_fontId);
    return (unlocked || f.free) ? f.family : fontById(freeFont).family;
  }

  Nudge nudge(TracePageKind page) => _nudges[page] ?? const Nudge();

  void setNudge(TracePageKind page, Nudge n) {
    _nudges[page] = Nudge(
      scale: n.scale.clamp(0.5, 1.6),
      dxMm: n.dxMm.clamp(-60, 60),
      dyMm: n.dyMm.clamp(-120, 120),
    );
    notifyListeners();
  }

  void resetNudge(TracePageKind page) {
    _nudges.remove(page);
    notifyListeners();
  }

  // --- 実寸 ---

  /// 1ミリあたりの論理ピクセル（pt）。iPhone は @3x 機がほぼ 460ppi、@2x 機が 326ppi。
  static double standardPtPerMm(double devicePixelRatio) {
    final ppi = devicePixelRatio >= 2.5 ? 460.0 / 3 : 326.0 / 2;
    return ppi / 25.4;
  }

  double ptPerMm(double devicePixelRatio) =>
      _ptPerMmOverride ?? standardPtPerMm(devicePixelRatio);

  bool get calibrated => _ptPerMmOverride != null;

  Future<void> setCalibration(double? value) async {
    _ptPerMmOverride = value;
    if (value == null) {
      await prefs.remove(_calibrationKey);
    } else {
      await prefs.setDouble(_calibrationKey, value);
    }
    notifyListeners();
  }

  // --- 履歴（アンロック後） ---

  List<String> get nameHistory => prefs.getStringList(_historyKey) ?? const [];
  List<String> get addressHistory => prefs.getStringList(_addressKey) ?? const [];

  Future<void> remember() async {
    final list = [...nameHistory];
    for (final n in names.reversed) {
      final v = n.trim();
      if (v.isEmpty) continue;
      list
        ..remove(v)
        ..insert(0, v);
    }
    await prefs.setStringList(_historyKey, list.take(20).toList());
    final a = address.trim();
    if (a.isNotEmpty) {
      final al = [...addressHistory]
        ..remove(a)
        ..insert(0, a);
      await prefs.setStringList(_addressKey, al.take(5).toList());
    }
    notifyListeners();
  }

  Future<void> forget(String name) async {
    final list = [...nameHistory]..remove(name);
    await prefs.setStringList(_historyKey, list);
    notifyListeners();
  }

}
