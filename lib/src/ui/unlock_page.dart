import 'package:flutter/material.dart';

import '../widgets/washi_backdrop.dart';
import 'palette.dart';
import 'scope.dart';

/// 買い切り「全機能アンロック」の購入と復元。
class UnlockPage extends StatelessWidget {
  const UnlockPage({super.key});

  static const _features = [
    (Icons.brush_outlined, '筆文字の書体が4つ増えます', '太筆・しなやか・筆ペン・ペン字'),
    (Icons.people_alt_outlined, '連名（3名まで）', '夫婦や友人どうしの連名を、右から順に並べます'),
    (Icons.mail_outline, '中袋の住所とお名前', '縦書きで、番地も漢数字に'),
    (Icons.currency_yen, '金額を大字に変換', '30000 → 金参萬圓　也の有無も選べます'),
    (Icons.history, '名前と住所の履歴', '一度入れた名前を、次からタップで呼び出せます'),
  ];

  @override
  Widget build(BuildContext context) {
    final unlock = AppScope.of(context).unlock;
    return Scaffold(
      appBar: AppBar(title: const Text('全機能アンロック')),
      body: WashiBackdrop(
        child: ListenableBuilder(
          listenable: unlock,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
            children: [
              const Text(
                '一度の購入で、すべての機能を\nずっと使えます。',
                style: TextStyle(
                  fontFamily: Washi.title,
                  fontSize: 24,
                  height: 1.45,
                  color: Washi.sumi,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '買い切りです。月額や年額の支払い（サブスクリプション）はありません。広告もありません。',
                style: TextStyle(color: Washi.sumiSoft, height: 1.6),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Washi.card,
                  border: Border.all(color: Washi.line),
                ),
                child: Column(
                  children: [
                    for (final (i, f) in _features.indexed) ...[
                      if (i > 0) const Divider(indent: 56),
                      ListTile(
                        leading: Icon(f.$1, color: Washi.shu),
                        title: Text(f.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(f.$3),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '無料のままでも、楷書の書体・1名分の名前・すべての用途の表書きで、なぞり書きができます。',
                style: TextStyle(fontSize: 13, color: Washi.sumiSoft, height: 1.6),
              ),
              const SizedBox(height: 22),
              if (unlock.unlocked)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Washi.sumi,
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Washi.kin),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'アンロック済みです。すべての機能が使えます。',
                          style: TextStyle(color: Washi.paper),
                        ),
                      ),
                    ],
                  ),
                )
              else
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Washi.shu),
                  onPressed: unlock.busy ? null : unlock.buy,
                  child: unlock.busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text('${unlock.price}で購入する（買い切り）'),
                ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: unlock.busy ? null : unlock.restore,
                child: const Text('購入を復元'),
              ),
              if (unlock.message != null) ...[
                const SizedBox(height: 14),
                Text(
                  unlock.message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Washi.sumi, height: 1.5),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'お支払いは購入の確定時にApple IDへ請求されます。機種変更や再インストールのあとは「購入を復元」で、同じApple IDの購入を呼び戻せます。',
                style: TextStyle(fontSize: 12, color: Washi.sumiSoft, height: 1.6),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => openLink(SiteLinks.terms),
                    child: const Text('利用規約'),
                  ),
                  const Text('・', style: TextStyle(color: Washi.sumiSoft)),
                  TextButton(
                    onPressed: () => openLink(SiteLinks.privacy),
                    child: const Text('プライバシーポリシー'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
