class BrushFont {
  const BrushFont({
    required this.id,
    required this.family,
    required this.label,
    required this.credit,
    this.free = false,
  });

  final String id;
  final String family;
  final String label;
  final String credit;
  final bool free;
}

/// どれも SIL Open Font License 1.1（assets/licenses）。
const brushFonts = <BrushFont>[
  BrushFont(
    id: 'syuku',
    family: 'YujiSyuku',
    label: '楷書',
    credit: 'Yuji Syuku',
    free: true,
  ),
  BrushFont(id: 'boku', family: 'YujiBoku', label: '太筆', credit: 'Yuji Boku'),
  BrushFont(id: 'mai', family: 'YujiMai', label: 'しなやか', credit: 'Yuji Mai'),
  BrushFont(
    id: 'kurenaido',
    family: 'ZenKurenaido',
    label: '筆ペン',
    credit: 'Zen Kurenaido',
  ),
  BrushFont(id: 'klee', family: 'KleeOne', label: 'ペン字', credit: 'Klee One'),
];

const freeFont = 'syuku';

BrushFont fontById(String id) =>
    brushFonts.firstWhere((f) => f.id == id, orElse: () => brushFonts.first);
