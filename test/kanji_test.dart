import 'package:flutter_test/flutter_test.dart';
import 'package:nazori_gaki/src/core/kanji.dart';

void main() {
  test('大字の金額', () {
    expect(daijiAmount(30000), '金参萬圓');
    expect(daijiAmount(10000), '金壱萬圓');
    expect(daijiAmount(5000), '金伍阡圓');
    expect(daijiAmount(100000), '金拾萬圓');
    expect(daijiAmount(15000), '金壱萬伍阡圓');
    expect(daijiAmount(110000), '金拾壱萬圓');
    expect(daijiAmount(3000, nari: true), '金参阡圓也');
    expect(daijiAmount(1000), '金壱阡圓');
    expect(daijiAmount(0), isNull);
  });

  test('金額の入力', () {
    expect(parseYen('30,000'), 30000);
    expect(parseYen('３００００円'), 30000);
    expect(parseYen('3万'), 30000);
    expect(parseYen('1万5千'), 15000);
    expect(parseYen('abc'), isNull);
    expect(parseYen(''), isNull);
  });

  test('縦書き用の分割', () {
    expect(verticalGlyphs('鈴木　隼人'), ['鈴', '木', ' ', '隼', '人']);
    expect(verticalGlyphs('A1'), ['Ａ', '１']);
    expect(verticalGlyphs('葛\u{E0100}城'), ['葛\u{E0100}', '城']);
    expect(addressForVertical('南青山1-2-3'), '南青山一ー二ー三');
  });
}
