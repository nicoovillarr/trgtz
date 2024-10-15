import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LazyImage extends StatefulWidget {
  final String imageUrl;
  const LazyImage({
    super.key,
    required this.imageUrl,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  ImageProvider? _imageProvider;
  bool _isImageLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadImage();
    });
  }

  @override
  void didUpdateWidget(LazyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.imageUrl.isEmpty && widget.imageUrl.isNotEmpty) ||
        (oldWidget.imageUrl.isNotEmpty &&
            widget.imageUrl.isNotEmpty &&
            oldWidget.imageUrl != widget.imageUrl)) {
      _loadImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _isImageLoaded && !_hasError ? _imageProvider : null;

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        decoration: BoxDecoration(
          image: image == null
              ? null
              : DecorationImage(
                  image: image,
                  fit: BoxFit.cover, // Usa BoxFit para ajustar la imagen
                ),
          color: Colors.grey[200], // Color de fondo si no hay imagen
        ),
        child: image == null
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
            : null,
      ),
    );
  }

  void _loadImage() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isImageLoaded = false;
      _hasError = false;
    });

    if (widget.imageUrl.isEmpty) {
      return;
    }

    _imageProvider = NetworkImage(widget.imageUrl);

    final imageStream = _imageProvider!.resolve(const ImageConfiguration());

    imageStream.addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _isImageLoaded = true;
            });
          }
        },
        onError: (exception, stackTrace) {
          if (!_hasError && mounted) {
            setState(() {
              _isImageLoaded = true;
              _hasError = true;
            });
          }
        },
      ),
    );
  }
}
