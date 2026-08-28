import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme.dart';

/// Disk-cached, decode-size-aware image for product and category thumbnails.
///
/// Supplying the rendered dimensions prevents Flutter from decoding large
/// catalog originals at their full resolution for small cards.
class OptimizedNetworkImage extends StatelessWidget {
  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorIcon = PhosphorIcons.imageBroken,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final hasFiniteWidth = width != null && width!.isFinite && width! > 0;
    final hasFiniteHeight = height != null && height!.isFinite && height! > 0;
    final cacheWidth = !hasFiniteWidth
        ? 720
        : (width! * pixelRatio).round().clamp(64, 1080);
    final cacheHeight = !hasFiniteHeight
        ? null
        : (height! * pixelRatio).round().clamp(64, 1080);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      maxWidthDiskCache: 1080,
      maxHeightDiskCache: 1080,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: const Duration(milliseconds: 80),
      placeholder: (_, _) => Container(
        width: width,
        height: height,
        color: AppTheme.greyBackground,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ),
      errorWidget: (_, _, _) => Container(
        width: width,
        height: height,
        color: AppTheme.greyBackground,
        alignment: Alignment.center,
        child: Icon(errorIcon, color: AppTheme.greyText),
      ),
    );
  }
}
