import 'package:flutter_test/flutter_test.dart';
import 'package:nazori_gaki/src/core/envelopes.dart';
import 'package:nazori_gaki/src/core/occasions.dart';

void main() {
  test('年賀状・喪中はがき・寒中見舞いとお年玉袋のひな型がある', () {
    final nengajo = occasionById('nengajo');
    final mochu = occasionById('mochu');
    final kanchu = occasionById('kanchu');
    final otoshi = occasionById('otoshidama');

    expect(nengajo.label, '年賀状');
    expect(nengajo.envelopeId, 'hagaki');
    expect(nengajo.omote, containsAll(['賀正', '迎春', '謹賀新年']));
    expect(nengajo.usuzumi, isFalse);

    expect(mochu.label, '喪中はがき');
    expect(mochu.envelopeId, 'hagaki');
    expect(mochu.usuzumi, isTrue);
    expect(mochu.omote, containsAll(['喪中', '年賀欠礼']));

    expect(kanchu.label, '寒中見舞い');
    expect(kanchu.envelopeId, 'hagaki');
    expect(kanchu.omote, contains('寒中御見舞'));

    expect(otoshi.label, 'お年玉袋');
    expect(otoshi.envelopeId, 'pochi');
    expect(otoshi.omote, containsAll(['お年玉', '迎春']));

    final hagaki = envelopeById('hagaki');
    expect(hagaki.label, contains('はがき'));
    expect(hagaki.hasNaka, isFalse);
    expect(hagaki.premium, isFalse);

    expect(occasionGroups, contains(groupHagaki));
  });
}
