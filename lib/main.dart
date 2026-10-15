import 'src/review/review_prompt.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/ads/ad_service.dart';
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

/// デバッグの広告帯確認用（free / paid、+ _trace でなぞり画面）。同意・ATT を出さずに撮影する。
const _adsShot = String.fromEnvironment('ADS_SHOT');

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
  // のし紙は全機能の画面なので、撮影時だけアンロック済みとして表示する（購入はしない）。
  if (showcase == 'noshi') await prefs.setBool(unlockedPrefsKey, true);

  final adsShot = kDebugMode ? _adsShot : '';
  if (adsShot.isNotEmpty) {
    await prefs.clear();
    if (adsShot.startsWith('paid')) await prefs.setBool(unlockedPrefsKey, true);
  }

  final draft = Draft(prefs);
  final unlock = UnlockService(
    bridge: showcase.isNotEmpty ? ShowcaseBridge() : AppStoreBridge(),
    prefs: prefs,
  );
  unawaited(unlock.start());

  // 無料版だけ広告。ATT の回答は待たずに読み込みを始める。購入・復元で帯ごと消える。
  final ads = AdService(enabled: showcase.isEmpty, skipPrompts: adsShot.isNotEmpty);
  if (!unlock.unlocked) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!unlock.unlocked) unawaited(ads.start());
    });
  }

  Widget? home;
  switch (showcase) {
    case 'shugi':
      draft
        ..startFor(occasionById('wedding'))
        ..update((d) {
          d.omote = '寿';
          d.names = ['山田 太郎'];
        });
      home = const TracePage(initialPage: TracePageKind.name);
    case 'kouden':
      draft
        ..startFor(occasionById('buddhist'))
        ..update((d) {
          d.omote = '御霊前';
          d.names = ['山田 太郎'];
        });
      home = const TracePage(initialPage: TracePageKind.omote);
    case 'noshi':
      draft
        ..startFor(occasionById('seibo'))
        ..setEnvelope('noshiB4')
        ..update((d) {
          d.omote = '御歳暮';
          d.names = ['山田 太郎'];
        });
      home = const TracePage(initialPage: TracePageKind.omote);
    case 'unlock':
      home = const UnlockPage();
  }

  if (adsShot.endsWith('_trace')) {
    draft
      ..startFor(occasionById('wedding'))
      ..update((d) {
        d.omote = '寿';
        d.names = [const String.fromEnvironment('NAME', defaultValue: '山田 太郎')];
      });
    home = TracePage(
      initialPage: TracePageKind.name,
      startFull: const bool.fromEnvironment('FULL'),
    );
  }

  await ReviewPrompt.recordLaunch();
  runApp(NazoriApp(draft: draft, unlock: unlock, ads: ads, home: home));
}
