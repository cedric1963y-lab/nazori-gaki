import 'package:flutter/material.dart';

import '../widgets/washi_backdrop.dart';
import 'calibration_page.dart';
import 'palette.dart';
import 'scope.dart';
import 'unlock_page.dart';

const appVersion = '1.0.0';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    void push(Widget page) => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: WashiBackdrop(
        child: ListenableBuilder(
          listenable: Listenable.merge([scope.draft, scope.unlock]),
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              _Group(children: [
                ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined, color: Washi.kin),
                  title: const Text('全機能アンロック'),
                  subtitle: Text(scope.unlock.unlocked ? 'アンロック済み' : '書体・連名・中袋・履歴（買い切り）'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => push(const UnlockPage()),
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('購入を復元'),
                  onTap: () {
                    scope.unlock.restore();
                    push(const UnlockPage());
                  },
                ),
              ]),
              _Group(children: [
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('実寸の調整'),
                  subtitle: Text(scope.draft.calibrated ? '調整済み' : '標準（iPhoneの画面密度から計算）'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => push(const CalibrationPage()),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('上手になぞるコツ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => push(const HowToPage()),
                ),
              ]),
              _Group(children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('サポート・お問い合わせ'),
                  onTap: () => openLink(SiteLinks.support),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('プライバシーポリシー'),
                  onTap: () => openLink(SiteLinks.privacy),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('利用規約'),
                  onTap: () => openLink(SiteLinks.terms),
                ),
                ListTile(
                  leading: const Icon(Icons.font_download_outlined),
                  title: const Text('フォントのライセンス'),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'なぞり書き',
                    applicationVersion: appVersion,
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'なぞり書き $appVersion\n入力した名前や住所はこのiPhoneの中だけに保存されます。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Washi.sumiSoft, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: Washi.card,
        border: Border.all(color: Washi.line),
      ),
      child: Column(children: children),
    );
  }
}

class HowToPage extends StatelessWidget {
  const HowToPage({super.key});

  static const _tips = [
    ('薄い紙を重ねる', '祝儀袋の短冊（表書き用の紙）や中袋は、外して画面に重ねると文字がよく透けます。厚い袋は、半紙などで練習してから清書するのがおすすめです。'),
    ('画面を固定する', '「固定してなぞる」を押すと、紙や手が触れても文字が動きません。長押しで操作に戻ります。'),
    ('筆ペンは軽く', '画面を強く押さず、筆ペンやサインペンで軽くなぞります。インクが画面に付かないよう、紙は1枚以上重ねてください。'),
    ('位置と大きさ', '袋の短冊に合わせて、ドラッグで位置、2本指や −／＋ で大きさを変えられます。中心線を袋の中心に合わせるとまっすぐ書けます。'),
    ('薄墨', '通夜・葬儀の香典は薄墨で書くのが一般的です。薄墨の筆ペンを使うときは、表示も薄墨にすると仕上がりを想像しやすくなります。'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上手になぞるコツ')),
      body: WashiBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            for (final (i, t) in _tips.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'一二三四五'[i]}、',
                      style: const TextStyle(fontFamily: Washi.title, fontSize: 20, color: Washi.shu),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(t.$2, style: const TextStyle(height: 1.65)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
