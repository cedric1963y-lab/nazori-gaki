import 'package:flutter/foundation.dart';

/// AdMob の ID。リリースビルドだけ本番、それ以外は Google 公式のテスト ID。
///
/// アプリ ID（GADApplicationIdentifier）は ios/Flutter/*.xcconfig で切り替える。
class AdIds {
  const AdIds._();

  static const releaseAppId = 'ca-app-pub-5342568663681412~6917089028';
  static const releaseBanner = 'ca-app-pub-5342568663681412/3451477572';

  static const testAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const testBanner = 'ca-app-pub-3940256099942544/2934735716';

  static String get banner => kReleaseMode ? releaseBanner : testBanner;

}
