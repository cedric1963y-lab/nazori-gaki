import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


/// 広告の準備（UMP の同意 → SDK 初期化 → バナー読み込み → ATT）。無料版だけで使う。
class AdService extends ChangeNotifier {
  AdService({required this.enabled, this.skipPrompts = false});

  /// デバッグ撮影用。同意フォームと ATT を出さない（非パーソナライズのまま）。
  final bool skipPrompts;

  /// 撮影用（SHOWCASE）では false。広告も同意画面も出さない。
  final bool enabled;

  bool _started = false;
  bool _ready = false;
  bool _personalized = false;
  bool _privacyOptions = false;
  
  bool get ready => _ready;
  bool get privacyOptionsRequired => _privacyOptions;

  AdRequest request() => AdRequest(nonPersonalizedAds: !_personalized);

  /// 最初のフレームのあとに呼ぶ。
  Future<void> start() async {
    if (!enabled || _started || !Platform.isIOS) return;
    _started = true;
    try {
      if (!skipPrompts) await _consent();
      await _refreshFlags();
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('ads start: $e');
    }
    // ATT の回答を待たずにバナーを読み込む（未回答・拒否は非パーソナライズ）。
    _ready = true;
    notifyListeners();
    try {
      if (!skipPrompts) await _att();
      await _refreshFlags();
    } catch (e) {
      debugPrint('ATT after start: $e');
    }
  }

  Future<void> _consent() async {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (error != null) debugPrint('UMP form: ${error.message}');
          });
        } catch (e) {
          debugPrint('UMP form skipped: $e');
        }
        if (!done.isCompleted) done.complete();
      },
      (error) {
        debugPrint('UMP update failed: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future.timeout(const Duration(seconds: 20), onTimeout: () {});
  }

  Future<void> _att() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('ATT skipped: $e');
    }
  }

  Future<void> _refreshFlags() async {
    try {
      final options = await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      _privacyOptions = options == PrivacyOptionsRequirementStatus.required;
      final consent = await ConsentInformation.instance.getConsentStatus();
      final att = await AppTrackingTransparency.trackingAuthorizationStatus;
      _personalized = att == TrackingStatus.authorized &&
          (consent == ConsentStatus.obtained || consent == ConsentStatus.notRequired);
    } catch (e) {
      _personalized = false;
    }
  }

  /// 設定の「広告のプライバシー設定」（同意が必要な地域だけ表示）。
  Future<void> showPrivacyOptions() async {
    if (!enabled) return;
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) debugPrint('privacy options: ${error.message}');
      });
      await _refreshFlags();
      notifyListeners();
    } catch (e) {
      debugPrint('privacy options skipped: $e');
    }
  }
}
