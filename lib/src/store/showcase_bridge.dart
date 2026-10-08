import 'bridge.dart';

/// デバッグのスクリーンショット撮影専用（main.dart 参照）。シミュレーターは
/// 日本のストアにつながらないため、App Store Connect に登録した日本の価格を
/// 表示するだけで、購入は一切しない。リリースビルドでは使われない。
class ShowcaseBridge implements StoreBridge {
  @override
  Future<void> start(void Function(StoreEvent event) onEvent) async {}

  @override
  Future<String?> loadPrice() async => unlockFallbackPrice;

  @override
  Future<void> buy() async {}

  @override
  Future<void> restore() async {}

  @override
  Future<bool?> owns() async => null;

  @override
  void dispose() {}
}
