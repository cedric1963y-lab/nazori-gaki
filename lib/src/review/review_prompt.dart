import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Store の評価ダイアログ（SKStoreReviewController.requestReview）を出す。
///
/// - なぞり画面を30秒以上使って戻ってきた回を「完了したセッション」と数える
/// - 3回目以降の完了セッションの後、入力画面に戻ったタイミングでだけ依頼
/// - 1バージョンにつき最大1回。初回起動・なぞり中・全画面中には出さない
/// - 独自の前置き文や特典は一切なし（Apple 標準ダイアログのみ）
/// - バージョン判定は CFBundleShortVersionString（PackageInfo.version）を使う
class ReviewPrompt {
  const ReviewPrompt._();

  static const minSessionSeconds = 30;
  static const minSessions = 3;

  static const _kSessions = 'review.completedSessions';
  static const _kAskedVersion = 'review.askedVersion';
  static const _kLaunches = 'review.launchCount';

  /// 起動時に1回呼ぶ。
  static Future<void> recordLaunch() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kLaunches, (p.getInt(_kLaunches) ?? 0) + 1);
    } catch (_) {}
  }

  static Future<String> _shortVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '';
    }
  }

  /// なぞり画面から戻った直後に呼ぶ。
  static Future<void> onTraceSessionEnded(Duration used) async {
    if (used.inSeconds < minSessionSeconds) return;
    try {
      final p = await SharedPreferences.getInstance();
      final sessions = (p.getInt(_kSessions) ?? 0) + 1;
      await p.setInt(_kSessions, sessions);
      if (sessions < minSessions) return;
      if ((p.getInt(_kLaunches) ?? 0) < 2) return; // 初回起動中は出さない
      final version = await _shortVersion();
      if (version.isEmpty) return;
      if (p.getString(_kAskedVersion) == version) return;
      final r = InAppReview.instance;
      if (!await r.isAvailable()) return;
      await p.setString(_kAskedVersion, version);
      await Future<void>.delayed(const Duration(milliseconds: 800));
      await r.requestReview();
    } catch (_) {}
  }
}
