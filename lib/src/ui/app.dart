import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../ads/ad_service.dart';
import '../ads/ad_visibility.dart';
import '../ads/banner_strip.dart';
import '../core/draft.dart';
import '../store/unlock_service.dart';
import 'home_page.dart';
import 'palette.dart';
import 'scope.dart';

class NazoriApp extends StatelessWidget {
  const NazoriApp({
    super.key,
    required this.draft,
    required this.unlock,
    required this.ads,
    this.home,
  });

  final Draft draft;
  final UnlockService unlock;
  final AdService ads;

  /// デバッグのスクリーンショット撮影時だけ差し替える。
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      draft: draft,
      unlock: unlock,
      child: MaterialApp(
        title: 'なぞり書き',
        debugShowCheckedModeBanner: false,
        theme: buildWashiTheme(),
        locale: const Locale('ja', 'JP'),
        supportedLocales: const [Locale('ja', 'JP')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home ?? const HomePage(),
        // 無料版は全画面の下に 50pt の広告帯を固定。画面（なぞり書きのキャンバス含む）はその上に配置する。
        builder: (context, child) => ListenableBuilder(
          listenable: Listenable.merge([unlock, hideAdBanner]),
          builder: (context, _) {
            // 木の形は常に同じにする（帯の出し入れ・購入で Navigator の状態が消えないように）。
            final show = !unlock.unlocked && ads.enabled && !hideAdBanner.value;
            final mq = MediaQuery.of(context);
            return ColoredBox(
              color: const Color(0xFF2B2F33),
              child: Column(
                children: [
                  Expanded(
                    child: MediaQuery(
                      data: show
                          ? mq.removePadding(removeBottom: true).removeViewPadding(removeBottom: true)
                          : mq,
                      child: child!,
                    ),
                  ),
                  if (show) BannerStrip(ads: ads),
                  if (show) SizedBox(height: mq.viewPadding.bottom),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
