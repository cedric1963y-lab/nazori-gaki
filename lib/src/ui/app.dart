import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../ads/ad_service.dart';
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
          listenable: unlock,
          builder: (context, _) {
            if (unlock.unlocked || !ads.enabled) return child!;
            final mq = MediaQuery.of(context);
            return ColoredBox(
              color: const Color(0xFF2B2F33),
              child: Column(
                children: [
                  Expanded(
                    child: MediaQuery(
                      data: mq.removePadding(removeBottom: true).removeViewPadding(removeBottom: true),
                      child: child!,
                    ),
                  ),
                  BannerStrip(ads: ads),
                  SizedBox(height: mq.viewPadding.bottom),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
