import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/core/draft.dart';
import 'src/core/occasions.dart';
import 'src/store/app_store_bridge.dart';
import 'src/store/showcase_bridge.dart';
import 'src/store/unlock_service.dart';
import 'src/ui/app.dart';
import 'src/ui/trace_page.dart';
import 'src/ui/unlock_page.dart';

/// デバッグビルドの App Store 用スクリーンショット撮影だけで使う
/// （tool/capture_app_store_screenshots.sh）。リリースビルドでは無視される。
/// home / shugi / kouden / unlock
const _showcase = String.fromEnvironment('SHOWCASE');

const _fontLicenses = {
  'Yuji Syuku': 'YujiSyuku',
  'Yuji Boku': 'YujiBoku',
  'Yuji Mai': 'YujiMai',
  'Zen Kurenaido': 'ZenKurenaido',
  'Klee One': 'KleeOne',
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final e in _fontLicenses.entries) {
      final text = await rootBundle.loadString('assets/licenses/${e.value}-OFL.txt');
      yield LicenseEntryWithLineBreaks([e.key], text);
    }
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final showcase = kDebugMode ? _showcase : '';
  final prefs = await SharedPreferences.getInstance();
  if (showcase.isNotEmpty) await prefs.clear();

  final draft = Draft(prefs);
  final unlock = UnlockService(
    bridge: showcase.isNotEmpty ? ShowcaseBridge() : AppStoreBridge(),
    prefs: prefs,
  );
  unawaited(unlock.start());

  Widget? home;
  switch (showcase) {
    case 'shugi':
      draft
        ..startFor(occasionById('wedding'))
        ..update((d) {
          d.omote = '寿';
          d.names = ['鈴木 隼人'];
        });
      home = const TracePage(initialPage: TracePageKind.name);
    case 'kouden':
      draft
        ..startFor(occasionById('buddhist'))
        ..update((d) {
          d.omote = '御霊前';
          d.names = ['鈴木 隼人'];
        });
      home = const TracePage(initialPage: TracePageKind.omote);
    case 'unlock':
      home = const UnlockPage();
  }

  runApp(NazoriApp(draft: draft, unlock: unlock, home: home));
}
