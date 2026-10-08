import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/draft.dart';
import '../store/unlock_service.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.draft,
    required this.unlock,
    required super.child,
  });

  final Draft draft;
  final UnlockService unlock;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope old) =>
      old.draft != draft || old.unlock != unlock;
}

abstract final class SiteLinks {
  static const base = 'https://cedric1963y-lab.github.io/nazori-gaki/';
  static const support = base;
  static const privacy = '${base}privacy.html';
  static const terms = '${base}terms.html';
}

Future<bool> openLink(String url) async {
  try {
    return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
