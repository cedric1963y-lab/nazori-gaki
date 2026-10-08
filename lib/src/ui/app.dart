import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    this.home,
  });

  final Draft draft;
  final UnlockService unlock;

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
      ),
    );
  }
}
