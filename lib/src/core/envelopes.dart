/// 袋の大きさごとの文字の大きさ（ミリ）。文字の高さ＝1文字分の枠の高さ。
class EnvelopeSize {
  const EnvelopeSize({
    required this.id,
    required this.label,
    required this.detail,
    required this.omoteMm,
    required this.nameMm,
    this.amountMm,
    this.addressMm,
    this.nakaNameMm,
  });

  final String id;
  final String label;
  final String detail;
  final double omoteMm;
  final double nameMm;
  final double? amountMm;
  final double? addressMm;
  final double? nakaNameMm;

  bool get hasNaka => amountMm != null;
}

const envelopeSizes = <EnvelopeSize>[
  EnvelopeSize(
    id: 'large',
    label: '祝儀袋・のし袋（大）',
    detail: '短冊つきの豪華なのし袋',
    omoteMm: 26,
    nameMm: 20,
    amountMm: 18,
    addressMm: 7,
    nakaNameMm: 12,
  ),
  EnvelopeSize(
    id: 'medium',
    label: '香典袋・金封（標準）',
    detail: 'いちばんよくある大きさ',
    omoteMm: 22,
    nameMm: 17,
    amountMm: 16,
    addressMm: 6.5,
    nakaNameMm: 10,
  ),
  EnvelopeSize(
    id: 'small',
    label: '略式の金封（小）',
    detail: '印刷水引の小さめの袋',
    omoteMm: 17,
    nameMm: 13,
    amountMm: 13,
    addressMm: 6,
    nakaNameMm: 9,
  ),
  EnvelopeSize(
    id: 'pochi',
    label: 'ポチ袋',
    detail: 'お年玉・心付けの小袋',
    omoteMm: 10,
    nameMm: 7.5,
  ),
];

EnvelopeSize envelopeById(String id) =>
    envelopeSizes.firstWhere((e) => e.id == id, orElse: () => envelopeSizes[1]);
