import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

import 'bridge.dart';

class AppStoreBridge implements StoreBridge {
  AppStoreBridge({InAppPurchase? store}) : _iap = store ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  @override
  Future<void> start(void Function(StoreEvent event) onEvent) async {
    await _sub?.cancel();
    _sub = _iap.purchaseStream.listen(
      (list) => unawaited(_handle(list, onEvent)),
      onError: (Object _) =>
          onEvent(const StoreEvent(StoreEventKind.error, message: '購入処理でエラーが起きました。')),
    );
  }

  Future<void> _handle(
    List<PurchaseDetails> list,
    void Function(StoreEvent event) onEvent,
  ) async {
    for (final p in list) {
      if (p.productID == unlockProductId) {
        switch (p.status) {
          case PurchaseStatus.pending:
            onEvent(const StoreEvent(StoreEventKind.pending));
          case PurchaseStatus.purchased:
            onEvent(const StoreEvent(StoreEventKind.unlocked));
          case PurchaseStatus.restored:
            onEvent(const StoreEvent(StoreEventKind.unlocked, restored: true));
          case PurchaseStatus.canceled:
            onEvent(const StoreEvent(StoreEventKind.canceled));
          case PurchaseStatus.error:
            onEvent(
              StoreEvent(
                StoreEventKind.error,
                message: p.error?.message ?? '購入できませんでした。',
              ),
            );
        }
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<ProductDetails?> _query() async {
    if (_product != null) return _product;
    final res = await _iap.queryProductDetails({unlockProductId});
    if (res.productDetails.isEmpty) return null;
    return _product = res.productDetails.first;
  }

  @override
  Future<String?> loadPrice() async {
    try {
      if (!await _iap.isAvailable()) return null;
      return (await _query())?.price;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> buy() async {
    if (!await _iap.isAvailable()) {
      throw const StoreProblem('App Store に接続できません。通信状態と、App Store へのサインインを確認してください。');
    }
    final product = await _query();
    if (product == null) {
      throw const StoreProblem('商品情報を読み込めませんでした。しばらくしてからもう一度お試しください。');
    }
    final started = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    if (!started) throw const StoreProblem('購入を開始できませんでした。');
  }

  @override
  Future<void> restore() async {
    if (!await _iap.isAvailable()) {
      throw const StoreProblem('App Store に接続できません。通信状態を確認してください。');
    }
    await _iap.restorePurchases();
  }

  @override
  Future<bool?> owns() async {
    try {
      final transactions = await SK2Transaction.transactions();
      return transactions.any((t) => t.productId == unlockProductId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _sub = null;
  }
}
