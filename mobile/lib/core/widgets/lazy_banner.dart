import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class LazyBanner extends StatefulWidget {
  final AdSize size;
  final Function()? onAdLoaded;
  final Function()? onAdFailed;
  const LazyBanner({
    super.key,
    this.onAdLoaded,
    this.onAdFailed,
    this.size = AdSize.banner,
  });

  @override
  State<LazyBanner> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasError = false;

  final adUnitId =
      Platform.isAndroid ? 'ca-app-pub-8197259688703499/4542829014' : '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadImage();
    });
  }

  @override
  void didUpdateWidget(LazyBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final banner = _isLoaded && !_hasError ? _bannerAd : null;
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: banner == null
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    color: Colors.white,
                  ),
                  height: constraints.maxHeight - 50.0,
                ),
              )
            : AdWidget(ad: banner),
      ),
    );
  }

  void _loadImage() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoaded = false;
      _hasError = false;
      _bannerAd = null;
    });

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: widget.size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });

          if (widget.onAdLoaded != null) widget.onAdLoaded!();
        },
        onAdFailedToLoad: (ad, _) {
          if (!_hasError && mounted) {
            setState(() {
              _isLoaded = true;
              _hasError = true;
            });
          }

          ad.dispose();

          if (widget.onAdFailed != null) widget.onAdFailed!();
        },
      ),
    );

    _bannerAd!.load();
  }
}
