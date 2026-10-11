import 'package:flutter/material.dart';

import '../core/occasions.dart';
import '../widgets/envelope_tile.dart';
import '../widgets/washi_backdrop.dart';
import 'palette.dart';
import 'scope.dart';
import 'settings_page.dart';
import 'setup_page.dart';
import 'unlock_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Occasion o) {
    if (o.premium && !AppScope.of(context).unlock.unlocked) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const UnlockPage()),
      );
      return;
    }
    AppScope.of(context).draft.startFor(o);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SetupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlock = AppScope.of(context).unlock;
    return Scaffold(
      body: WashiBackdrop(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 8, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'なぞり書き',
                              style: TextStyle(
                                fontFamily: Washi.title,
                                fontSize: 34,
                                color: Washi.sumi,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ご祝儀袋・香典袋の表書きと名前を、\n実寸の筆文字でなぞって書けます。',
                              style: TextStyle(
                                fontSize: 14,
                                color: Washi.sumiSoft,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: '設定',
                        icon: const Icon(Icons.settings_outlined),
                        color: Washi.sumi,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SettingsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final group in occasionGroups) ...[
                SliverToBoxAdapter(child: _GroupHeader(group)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 18,
                          childAspectRatio: 0.56,
                        ),
                    delegate: SliverChildListDelegate([
                      for (final o in occasions.where((o) => o.group == group))
                        ListenableBuilder(
                          listenable: unlock,
                          builder: (context, _) => Stack(
                            children: [
                              Positioned.fill(
                                child: EnvelopeTile(occasion: o, onTap: () => _open(context, o)),
                              ),
                              if (o.premium && !unlock.unlocked)
                                const Positioned(
                                  top: 6,
                                  right: 6,
                                  child: IgnorePointer(
                                    child: CircleAvatar(
                                      radius: 11,
                                      backgroundColor: Washi.sumi,
                                      child: Icon(Icons.lock_outline, size: 13, color: Washi.kin),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: unlock,
                  builder: (context, _) => unlock.unlocked
                      ? const SizedBox(height: 40)
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(22, 28, 22, 40),
                          child: _UnlockBanner(price: unlock.price),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
      child: Row(
        children: [
          Container(width: 4, height: 18, color: Washi.shu),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: Washi.title,
              fontSize: 19,
              color: Washi.sumi,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _UnlockBanner extends StatelessWidget {
  const _UnlockBanner({required this.price});
  final String price;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Washi.sumi,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const UnlockPage()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, color: Washi.kin),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '全機能アンロック\nのし紙・追加の表書き・書体・連名・会社名・中袋・履歴',
                  style: TextStyle(color: Washi.paper, height: 1.5, fontSize: 13.5),
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: Washi.paper,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.chevron_right, color: Washi.paper),
            ],
          ),
        ),
      ),
    );
  }
}
