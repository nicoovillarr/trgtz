import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BasicAdBanner extends StatefulWidget {
  const BasicAdBanner({super.key});

  @override
  State<BasicAdBanner> createState() => _BasicAdBannerState();
}

class _BasicAdBannerState extends State<BasicAdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final adUnitId = dotenv.env[
          "${(Platform.isAndroid ? "ANDROID" : "IOS")}DASHBOARD_AD_UNIT"] ??
      '';

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && _isLoaded) {
      return AdWidget(ad: _bannerAd!);
    }

    return const Center(
      child: CircularProgressIndicator(
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
