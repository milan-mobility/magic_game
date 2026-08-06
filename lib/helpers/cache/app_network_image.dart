import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magic_games/helpers/cache/app_image_cache_manager.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    super.key,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.cacheKey,
    this.headers,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final double borderRadius;
  final String? cacheKey;
  final Map<String, String>? headers;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final bool hasFiniteWidth = width.isFinite && width > 0;
    final bool hasFiniteHeight = height.isFinite && height > 0;

    // Decode the image close to its displayed physical pixel size.
    final int? cacheWidth = hasFiniteWidth ? (width * pixelRatio).round() : null;
    final int? cacheHeight = hasFiniteHeight
        ? (height * pixelRatio).round()
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        cacheKey: cacheKey,
        httpHeaders: headers,
        cacheManager: AppImageCacheManager.instance,
        width: hasFiniteWidth ? width : null,
        height: hasFiniteHeight ? height : null,
        fit: fit,

        // Controls decoded image size in RAM.
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,

        // Stores a resized image in disk cache.
        maxWidthDiskCache: cacheWidth,
        maxHeightDiskCache: cacheHeight,

        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 100),

        placeholder: (_, __) {
          return placeholder ??
              Container(
                width: hasFiniteWidth ? width : null,
                height: hasFiniteHeight ? height : null,
                color: Colors.grey.shade200,
              );
        },

        errorWidget: (_, __, ___) {
          return errorWidget ??
              Container(
                width: hasFiniteWidth ? width : null,
                height: hasFiniteHeight ? height : null,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
              );
        },
      ),
    );
  }
}
