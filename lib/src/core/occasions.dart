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

  bool get isCustom => omote.isEmpty;
}

const groupCelebration = 'お祝い';
const groupCondolence = 'お悔やみ・法要';
const groupOther = 'お礼・お見舞い・そのほか';

const occasionGroups = [groupCelebration, groupCondolence, groupOther];

const occasions = <Occasion>[
  Occasion(
    id: 'wedding',
    label: '結婚祝い',
    group: groupCelebration,
    mood: Mood.celebration,
    omote: ['寿', '御祝', '御結婚御祝', '祝御結婚'],
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
    omote: ['御仏前', '御供物料', '御供'],
    note: '四十九日以降の法要は、濃い墨で書くのが一般的です。',
    envelopeId: 'medium',
  ),
  Occasion(
    id: 'ofuse',
    label: 'お布施',
    group: groupCondolence,
    mood: Mood.condolence,
    omote: ['御布施', '御車代', '御膳料'],
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
