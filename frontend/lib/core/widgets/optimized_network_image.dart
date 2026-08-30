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
    final displayWidth = hasFiniteWidth ? width : null;
    final displayHeight = hasFiniteHeight ? height : null;
    final cacheWidth = !hasFiniteWidth
        ? 720
        : (width! * pixelRatio).round().clamp(64, 1080).toInt();
    final cacheHeight = !hasFiniteHeight
        ? null
        : (height! * pixelRatio).round().clamp(64, 1080).toInt();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: displayWidth,
      height: displayHeight,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: const Duration(milliseconds: 80),
      placeholder: (_, _) => Container(
        width: displayWidth,
        height: displayHeight,
        color: AppTheme.greyBackground,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ),
      errorWidget: (_, _, _) => Container(
        width: displayWidth,
        height: displayHeight,
        color: AppTheme.greyBackground,
        alignment: Alignment.center,
        child: Icon(errorIcon, color: AppTheme.greyText),
      ),
    );
  }
}
