import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazori_gaki/src/ads/ad_service.dart';
import 'package:nazori_gaki/src/core/draft.dart';
import 'package:nazori_gaki/src/core/occasions.dart';
import 'package:nazori_gaki/src/store/showcase_bridge.dart';
import 'package:nazori_gaki/src/store/unlock_service.dart';
import 'package:nazori_gaki/src/ui/app.dart';
import 'package:nazori_gaki/src/ui/calibration_page.dart';
import 'package:nazori_gaki/src/ui/home_page.dart';
import 'package:nazori_gaki/src/ui/settings_page.dart';
import 'package:nazori_gaki/src/ui/setup_page.dart';
import 'package:nazori_gaki/src/ui/trace_page.dart';
import 'package:nazori_gaki/src/ui/unlock_page.dart';

void main() {
  const sizes = {'SE': Size(375, 667), 'PM': Size(440, 956)};
  final scales = const String.fromEnvironment('SCALES', defaultValue: '1.0,1.35,2.0').split(',').map(double.parse);
  final pages = <String, Widget Function()>{
    'home': () => const HomePage(),
    'setup': () => const SetupPage(),
    'trace_omote': () => const TracePage(initialPage: TracePageKind.omote),
    'trace_name': () => const TracePage(initialPage: TracePageKind.name),
    'trace_naka': () => const TracePage(initialPage: TracePageKind.nakaFront),
    'unlock': () => const UnlockPage(),
    'settings': () => const SettingsPage(),
    'howto': () => const HowToPage(),
    'calib': () => const CalibrationPage(),
  };
  for (final unlocked in [false, true]) {
    for (final pg in pages.entries) {
      for (final e in sizes.entries) {
        for (final sc in scales) {
          testWidgets('$unlocked ${pg.key} ${e.key} x$sc', (tester) async {
            SharedPreferences.setMockInitialValues({if (unlocked) unlockedPrefsKey: true});
            final prefs = await SharedPreferences.getInstance();
            final draft = Draft(prefs)
              ..startFor(occasionById('wedding'))
              ..update((d) {
                d.omote = '寿';
                d.names = ['山田 太郎'];
                d.amountText = '30000';
                d.address = '東京都千代田区丸の内一丁目一番一号';
              });
            final unlock = UnlockService(bridge: ShowcaseBridge(), prefs: prefs);
            tester.view.physicalSize = e.value * 3;
            tester.view.devicePixelRatio = 3;
            addTearDown(tester.view.reset);
            final errors = <String>[];
            final old = FlutterError.onError;
            FlutterError.onError = (d) {
              final m = d.exceptionAsString().split('\n').first;
              if (m.contains('ListTile background') || m.contains('not laid out') || m.contains('Unable to load asset')) return;
              final loc = RegExp(r'lib/[^ :]+:\d+').allMatches(d.toString()).map((x) => x.group(0)).take(1).join();
              errors.add('$m @ $loc');
            };
            await tester.pumpWidget(MediaQuery(
              data: MediaQueryData(size: e.value, devicePixelRatio: 3, textScaler: TextScaler.linear(sc),
                  padding: const EdgeInsets.only(top: 20), viewPadding: const EdgeInsets.only(top: 20)),
              child: NazoriApp(draft: draft, unlock: unlock, ads: AdService(enabled: false), home: pg.value()),
            ));
            await tester.pump(const Duration(seconds: 1));
            await tester.pump(const Duration(seconds: 1));
            FlutterError.onError = old;
            if (errors.isNotEmpty) {
              // ignore: avoid_print
              print('OVERFLOW unlocked=$unlocked ${pg.key} ${e.key} x$sc: ${errors.toSet().join(' | ')}');
            }
          });
        }
      }
    }
  }
}
