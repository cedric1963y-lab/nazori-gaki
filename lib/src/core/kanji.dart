// 中袋の金額（大字）と縦書き用の文字変換。

const _daijiDigits = ['', '壱', '弐', '参', '肆', '伍', '陸', '漆', '捌', '玖'];
const _units = ['', '拾', '佰', '阡'];

/// 30000 → 金参萬圓。1〜99,999,999円。範囲外は null。
String? daijiAmount(int yen, {bool nari = false}) {
  if (yen <= 0 || yen > 99999999) return null;
  final man = yen ~/ 10000;
  final rest = yen % 10000;
  final b = StringBuffer('金');
  if (man > 0) {
    b.write(_group(man, leading: true));
    b.write('萬');
  }
  if (rest > 0) b.write(_group(rest, leading: man == 0));
  b.write('圓');
  if (nari) b.write('也');
  return b.toString();
}

String _group(int n, {required bool leading}) {
  final b = StringBuffer();
  var first = true;
  for (var place = 3; place >= 0; place--) {
    final p = _pow10(place);
    final d = (n ~/ p) % 10;
    if (d == 0) continue;
    // 先頭の「拾」だけは壱を付けない（金拾萬圓）。それ以外は改ざん防止で壱を付ける。
    final omitOne = d == 1 && place == 1 && first && leading;
    if (!omitOne) b.write(_daijiDigits[d]);
    b.write(_units[place]);
    first = false;
  }
  return b.toString();
}

int _pow10(int e) {
  var v = 1;
  for (var i = 0; i < e; i++) {
    v *= 10;
  }
  return v;
}

/// 入力された金額の文字列（全角・カンマ・円・「3万5千」でも可）を数値に。
int? parseYen(String raw) {
  final b = StringBuffer();
  for (final r in raw.runes) {
    if (r >= 0xFF10 && r <= 0xFF19) {
      b.writeCharCode(r - 0xFF10 + 0x30);
    } else if (r == 0x2C || r == 0xFF0C || r == 0x20 || r == 0x3000) {
      continue;
    } else {
      b.writeCharCode(r);
    }
  }
  var s = b.toString();
  if (s.endsWith('円')) s = s.substring(0, s.length - 1);
  if (s.isEmpty) return null;
  var total = 0;
  final man = s.indexOf('万');
  if (man >= 0) {
    final head = int.tryParse(s.substring(0, man));
    if (head == null) return null;
    total += head * 10000;
    s = s.substring(man + 1);
  }
  final sen = s.indexOf('千');
  if (sen >= 0) {
    final head = sen == 0 ? 1 : int.tryParse(s.substring(0, sen));
    if (head == null) return null;
    total += head * 1000;
    s = s.substring(sen + 1);
  }
  if (s.isNotEmpty) {
    final tail = int.tryParse(s);
    if (tail == null) return null;
    total += tail;
  }
  return total;
}

const _kanjiNum = ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九'];

/// 縦書きの住所用。数字を漢数字に、ハイフンを長音（縦棒）に。
String addressForVertical(String raw, {bool kanjiDigits = true}) {
  final b = StringBuffer();
  for (final r in raw.runes) {
    var c = r;
    if (c >= 0xFF10 && c <= 0xFF19) c = c - 0xFF10 + 0x30;
    if (kanjiDigits && c >= 0x30 && c <= 0x39) {
      b.write(_kanjiNum[c - 0x30]);
    } else if ('-－‐−―'.contains(String.fromCharCode(c))) {
      b.write('ー');
    } else {
      b.writeCharCode(c);
    }
  }
  return b.toString();
}

/// 縦に1文字ずつ並べるための分割。異体字セレクタは前の字にくっつける。
/// 半角英数は全角に、空白は ' ' 1つにまとめる。
List<String> verticalGlyphs(String text) {
  final out = <String>[];
  for (final r in text.trim().runes) {
    final isSelector =
        (r >= 0xFE00 && r <= 0xFE0F) || (r >= 0xE0100 && r <= 0xE01EF);
    if (isSelector && out.isNotEmpty) {
      out[out.length - 1] = out.last + String.fromCharCode(r);
      continue;
    }
    if (r == 0x20 || r == 0x3000) {
      if (out.isNotEmpty && out.last != ' ') out.add(' ');
      continue;
    }
    if (r > 0x20 && r < 0x7F) {
      out.add(String.fromCharCode(r + 0xFEE0));
      continue;
    }
    out.add(String.fromCharCode(r));
  }
  return out;
}
