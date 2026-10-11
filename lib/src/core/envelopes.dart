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
    this.premium = false,
    this.noshi = false,
  });

  final String id;
  final String label;
  final String detail;
  final double omoteMm;
  final double nameMm;
  final double? amountMm;
  final double? addressMm;
  final double? nakaNameMm;

  /// 全機能アンロック限定のサイズか。
  final bool premium;

  /// 品物に掛けるのし紙（中袋なし）。
  final bool noshi;

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
  EnvelopeSize(
    id: 'noshiA4',
    label: 'のし紙（A4）',
    detail: '菓子折り・タオルなどの箱に掛ける',
    omoteMm: 30,
    nameMm: 22,
    premium: true,
    noshi: true,
  ),
  EnvelopeSize(
    id: 'noshiB4',
    label: 'のし紙（B4）',
    detail: 'お中元・お歳暮の大きめの箱に',
    omoteMm: 36,
    nameMm: 26,
    premium: true,
    noshi: true,
  ),
  EnvelopeSize(
    id: 'noshiTanzaku',
    label: '短冊のし',
    detail: '細長い略式ののし紙',
    omoteMm: 20,
    nameMm: 15,
    premium: true,
    noshi: true,
  ),
];

EnvelopeSize envelopeById(String id) =>
    envelopeSizes.firstWhere((e) => e.id == id, orElse: () => envelopeSizes[1]);
