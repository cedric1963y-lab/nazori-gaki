import 'package:flutter/foundation.dart';

/// なぞり画面の全画面モード中だけ true。広告帯を一時的に隠す（他の画面はそのまま）。
final hideAdBanner = ValueNotifier<bool>(false);
