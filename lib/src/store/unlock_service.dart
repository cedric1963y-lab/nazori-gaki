import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bridge.dart';

const unlockedPrefsKey = 'unlock.owned';
const _unlockedKey = unlockedPrefsKey;

/// 全機能アンロックの状態。買い切りなので期限はない。
class UnlockService extends ChangeNotifier {
  UnlockService({required this.bridge, required this.prefs})
    : _unlocked = prefs.getBool(_unlockedKey) ?? false;

  final StoreBridge bridge;
  final SharedPreferences prefs;

  bool _unlocked;
  bool _busy = false;
  String _price = unlockFallbackPrice;
  String? _message;
  Timer? _restoreTimer;

  bool get unlocked => _unlocked;
  bool get busy => _busy;
  String get price => _price;
  String? get message => _message;

  Future<void> start() async {
    await bridge.start(_onEvent);
    final price = await bridge.loadPrice();
    if (price != null) {
      _price = price;
      notifyListeners();
    }
    if (!_unlocked && await bridge.owns() == true) {
      await _setUnlocked();
    }
  }

  void _onEvent(StoreEvent e) {
    _restoreTimer?.cancel();
    switch (e.kind) {
      case StoreEventKind.unlocked:
        _busy = false;
        _message = e.restored ? '購入を復元しました。すべての機能が使えます。' : 'ありがとうございます。すべての機能が使えるようになりました。';
        unawaited(_setUnlocked());
      case StoreEventKind.pending:
        _message = '購入の承認を待っています。';
        notifyListeners();
      case StoreEventKind.canceled:
        _busy = false;
        _message = null;
        notifyListeners();
      case StoreEventKind.error:
        _busy = false;
        _message = e.message;
        notifyListeners();
    }
  }

  Future<void> _setUnlocked() async {
    _unlocked = true;
    await prefs.setBool(_unlockedKey, true);
    notifyListeners();
  }

  Future<void> buy() async {
    if (_busy || _unlocked) return;
    _busy = true;
    _message = null;
    notifyListeners();
    try {
      await bridge.buy();
    } on StoreProblem catch (e) {
      _busy = false;
      _message = e.message;
      notifyListeners();
    } catch (_) {
      _busy = false;
      _message = '購入を開始できませんでした。';
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (_busy) return;
    _busy = true;
    _message = null;
    notifyListeners();
    try {
      await bridge.restore();
      _restoreTimer?.cancel();
      _restoreTimer = Timer(const Duration(seconds: 12), () {
        if (!_busy) return;
        _busy = false;
        _message = _unlocked ? '購入は復元済みです。' : 'このApple IDで復元できる購入は見つかりませんでした。';
        notifyListeners();
      });
    } on StoreProblem catch (e) {
      _busy = false;
      _message = e.message;
      notifyListeners();
    } catch (_) {
      _busy = false;
      _message = '復元できませんでした。';
      notifyListeners();
    }
  }

  void clearMessage() {
    if (_message == null) return;
    _message = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _restoreTimer?.cancel();
    bridge.dispose();
    super.dispose();
  }
}
