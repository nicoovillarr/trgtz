import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';

class ProfileImage extends StatefulWidget {
  final User user;
  final double size;
  const ProfileImage({
    super.key,
    required this.user,
    this.size = 64,
  });

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
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
  void didUpdateWidget(ProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.user.avatar == null && widget.user.avatar != null) ||
        (oldWidget.user.avatar != null &&
            widget.user.avatar != null &&
            widget.user.avatar!.url != oldWidget.user.avatar!.url)) {
      _loadImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.user.avatar == null
        ? null
        : _isImageLoaded && !_hasError
            ? _imageProvider
            : null;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Forma circular
        image: image == null
            ? null
            : DecorationImage(
                image: image,
                fit: BoxFit.cover, // Usa BoxFit para ajustar la imagen
              ),
        color: Colors.grey[200], // Color de fondo si no hay imagen
      ),
      child: image == null
          ? _isImageLoaded
              ? const CircularProgressIndicator()
              : Center(
                  child: Text(widget.user.firstName[0]),
                )
          : null,
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

    final imageUrl = widget.user.avatar?.url ?? '';

    if (imageUrl.isEmpty) {
      return;
    }

    _imageProvider = NetworkImage(imageUrl);

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
