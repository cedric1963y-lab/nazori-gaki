/// 買い切り「全機能アンロック」（非消耗型）1つだけを扱う StoreKit の境界。
const unlockProductId = 'jp.nazorigaki.app.unlock';
const unlockFallbackPrice = '¥300';

enum StoreEventKind { unlocked, pending, canceled, error }

class StoreEvent {
  const StoreEvent(this.kind, {this.message, this.restored = false});

  final StoreEventKind kind;
  final String? message;
  final bool restored;
}

abstract class StoreBridge {
  Future<void> start(void Function(StoreEvent event) onEvent);

  /// App Store のローカライズ済み価格。取れないときは null。
  Future<String?> loadPrice();

  Future<void> buy();

  Future<void> restore();

  /// 端末にこの商品の取引があるか。確認できないときは null。
  Future<bool?> owns();

  void dispose();
}

class StoreProblem implements Exception {
  const StoreProblem(this.message);
  final String message;
  @override
  String toString() => message;
}
