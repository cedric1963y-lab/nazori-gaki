/// 用途ごとの表書き候補。最初の候補がいちばん一般的なもの。
enum Mood { celebration, condolence, neutral }

class Occasion {
  const Occasion({
    required this.id,
    required this.label,
    required this.group,
    required this.mood,
    required this.omote,
    required this.note,
    this.usuzumi = false,
    this.envelopeId = 'large',
    this.premium = false,
    this.premiumOmote = const [],
  });

  final String id;
  final String label;
  final String group;
  final Mood mood;
  final List<String> omote;
  final String note;

  /// 初期値で薄墨にするか。
  final bool usuzumi;
  final String envelopeId;

  /// 用途そのものが全機能アンロック限定か。
  final bool premium;

  /// 全機能アンロックで増える表書き候補。
  final List<String> premiumOmote;

  bool get isCustom => omote.isEmpty;
}

const groupCelebration = 'お祝い';
const groupCondolence = 'お悔やみ・法要';
const groupSeasonal = '季節の贈答・のし紙';
const groupOther = 'お礼・お見舞い・そのほか';

const occasionGroups = [groupCelebration, groupSeasonal, groupCondolence, groupOther];

const occasions = <Occasion>[
  Occasion(
    id: 'wedding',
    label: '結婚祝い',
    group: groupCelebration,
    mood: Mood.celebration,
    omote: ['寿', '御祝', '御結婚御祝', '祝御結婚'],
    premiumOmote: ['御祝儀'],
    note: '水引は紅白か金銀の結び切り。濃い墨で、楷書ではっきり書きます。',
  ),
  Occasion(
    id: 'birth',
    label: '出産祝い',
    group: groupCelebration,
    mood: Mood.celebration,
    omote: ['御出産御祝', '御祝', '祝御出産'],
    note: '水引は紅白の蝶結び。何度あってもうれしいお祝いに使います。',
  ),
  Occasion(
    id: 'school',
    label: '入学・就職',
    group: groupCelebration,
    mood: Mood.celebration,
    omote: ['御入学御祝', '御卒業御祝', '御就職御祝', '御祝'],
    note: '水引は紅白の蝶結び。',
  ),
  Occasion(
    id: 'general',
    label: 'お祝い全般',
    group: groupCelebration,
    mood: Mood.celebration,
    omote: ['御祝', '祝御新築', '祝御開店', '御祝儀'],
    premiumOmote: ['祝御開業', '祝御昇進', '祝御栄転'],
    note: '水引は紅白の蝶結び。',
  ),
  Occasion(
    id: 'otoshidama',
    label: 'お年玉',
    group: groupCelebration,
    mood: Mood.celebration,
    omote: ['お年玉', '御年玉'],
    note: 'ポチ袋の表にはあげる子の名前、裏に自分の名前を書くことが多いです。',
    envelopeId: 'pochi',
  ),
  Occasion(
    id: 'uchiiwai',
    label: '内祝い',
    group: groupCelebration,
    mood: Mood.celebration,
    omote: ['内祝', '結婚内祝', '出産内祝'],
    note: '名前は贈る側の名字、または子どもの名前を書きます。',
  ),
  Occasion(
    id: 'chugen',
    label: '御中元',
    group: groupSeasonal,
    mood: Mood.celebration,
    omote: ['御中元', '暑中御伺', '残暑御伺'],
    note: '水引は紅白の蝶結び。お中元の時期を過ぎたら「暑中御伺」、立秋のあとは「残暑御伺」にします。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'seibo',
    label: '御歳暮',
    group: groupSeasonal,
    mood: Mood.celebration,
    omote: ['御歳暮', '寒中御伺'],
    note: '水引は紅白の蝶結び。年明けに贈るときは「御年賀」、松の内のあとは「寒中御伺」にします。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'nenga',
    label: '御年賀',
    group: groupSeasonal,
    mood: Mood.celebration,
    omote: ['御年賀', '御年始'],
    note: '水引は紅白の蝶結び。松の内（1月7日ごろ）までに贈ります。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'aisatsu',
    label: '御挨拶・粗品',
    group: groupSeasonal,
    mood: Mood.celebration,
    omote: ['御挨拶', '粗品', '御礼', '御近付'],
    note: '引っ越しや着任のあいさつの品に。名字だけを書くのが一般的です。',
    envelopeId: 'noshiA4',
    premium: true,
  ),
  Occasion(
    id: 'shrine',
    label: '神社・お祭り',
    group: groupSeasonal,
    mood: Mood.celebration,
    omote: ['初穂料', '御玉串料', '御奉納', '御神前', '御祝儀'],
    note: 'お宮参り・七五三のご祈祷は「初穂料」。お祭りの寄付は「御奉納」「御祝儀」にします。',
    envelopeId: 'medium',
    premium: true,
  ),
  Occasion(
    id: 'kids',
    label: '七五三・節句',
    group: groupSeasonal,
    mood: Mood.celebration,
    omote: ['七五三御祝', '祝初節句', '御初節句御祝', '御入園御祝'],
    note: '水引は紅白の蝶結び。名前は贈る側の名前を書きます。',
    envelopeId: 'medium',
    premium: true,
  ),
  Occasion(
    id: 'chouju',
    label: '長寿祝い',
    group: groupSeasonal,
    mood: Mood.celebration,
    omote: ['還暦御祝', '祝古希', '祝喜寿', '祝米寿', '御長寿御祝'],
    note: '水引は紅白の蝶結び。還暦60歳・古希70歳・喜寿77歳・米寿88歳。',
    envelopeId: 'medium',
    premium: true,
  ),
  Occasion(
    id: 'buddhist',
    label: '香典（仏式）',
    group: groupCondolence,
    mood: Mood.condolence,
    omote: ['御霊前', '御香典', '御香料', '御仏前'],
    note: '通夜・葬儀は薄墨で書くのが一般的です。御仏前は四十九日以降に使います（浄土真宗では葬儀から御仏前）。',
    usuzumi: true,
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'shinto',
    label: '香典（神式）',
    group: groupCondolence,
    mood: Mood.condolence,
    omote: ['御玉串料', '御榊料', '御霊前'],
    note: '蓮の絵柄がない、白無地の不祝儀袋を選びます。',
    usuzumi: true,
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'christian',
    label: '香典（キリスト教）',
    group: groupCondolence,
    mood: Mood.condolence,
    omote: ['御花料', '献花料', '御霊前'],
    note: '十字架や百合の絵柄、または白無地の封筒を選びます。',
    usuzumi: true,
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'houji',
    label: '法事・法要',
    group: groupCondolence,
    mood: Mood.condolence,
    omote: ['御仏前', '御供物料', '御供', '御回向'],
    note: '四十九日以降の法要は、濃い墨で書くのが一般的です。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'kaeshi',
    label: '香典返し・志',
    group: groupCondolence,
    mood: Mood.condolence,
    omote: ['志', '粗供養', '満中陰志'],
    note: '香典返しや法要の引き出物に。志は宗派を問わず使えます。粗供養は主に関西、満中陰志は関西の四十九日の香典返しです。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'ofuse',
    label: 'お布施',
    group: groupCondolence,
    mood: Mood.condolence,
    omote: ['御布施', '御車代', '御膳料', '御回向'],
    note: 'お寺へのお礼なので、薄墨ではなく濃い墨で書きます。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'mimai',
    label: '御見舞',
    group: groupOther,
    mood: Mood.neutral,
    omote: ['御見舞', '祈御全快'],
    note: '水引は紅白の結び切りか、白無地の封筒を使います。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'kaiki',
    label: '快気祝い',
    group: groupOther,
    mood: Mood.celebration,
    omote: ['快気祝', '快気内祝'],
    premiumOmote: ['全快祝', '御見舞御礼'],
    note: '水引は紅白の結び切り。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'orei',
    label: '御礼',
    group: groupOther,
    mood: Mood.neutral,
    omote: ['御礼', '謝礼', '薄謝', '御車代'],
    note: 'お世話になった方へのお礼に。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'sunshi',
    label: '寸志・心付け',
    group: groupOther,
    mood: Mood.neutral,
    omote: ['寸志', '心付', '御礼'],
    note: '寸志は目上の人から目下の人へ渡すときの表書きです。',
    envelopeId: 'small',
  ),
  Occasion(
    id: 'senbetsu',
    label: '餞別',
    group: groupOther,
    mood: Mood.neutral,
    omote: ['御餞別', '御礼'],
    note: '転勤や退職で離れる方へ。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'custom',
    label: '自由に入力',
    group: groupOther,
    mood: Mood.neutral,
    omote: [],
    note: '表書きを自由に入力できます。',
  ),
];

Occasion occasionById(String id) =>
    occasions.firstWhere((o) => o.id == id, orElse: () => occasions.first);
