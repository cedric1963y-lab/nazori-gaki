import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ad_service.dart';

/// 画面下のバナー広告（320×50、帯の高さ 50pt）。読み込み前も高さを確保して、画面がずれないようにする。
class BannerStrip extends StatefulWidget {
  const BannerStrip({super.key, required this.ads});

  final AdService ads;

  @override
  State<BannerStrip> createState() => _BannerStripState();
}

class _BannerStripState extends State<BannerStrip> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.ads.addListener(_maybeLoad);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  @override
  void dispose() {
    widget.ads.removeListener(_maybeLoad);
    _ad?.dispose();
    super.dispose();
  }

  void _maybeLoad() {
    if (!widget.ads.ready || _ad != null || !mounted) return;
    final ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: widget.ads.request(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (failed, error) {
          debugPrint('banner failed: ${error.message}');
          failed.dispose();
          if (mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
          }
          Future<void>.delayed(const Duration(seconds: 45), _maybeLoad);
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2F33),
      ),
      alignment: Alignment.center,
      child: _loaded && ad != null
          ? SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            )
          : null,
    );
  }
}
