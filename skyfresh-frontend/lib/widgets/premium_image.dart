import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyfresh/theme.dart';

class PremiumImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const PremiumImage({
    super.key,
    this.imageUrl,
    required this.fallbackUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = (imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.startsWith('http')) 
        ? imageUrl! 
        : fallbackUrl;

    Widget imageWidget = Image.network(
      effectiveUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Shimmer.fromColors(
          baseColor: AppTheme.surfaceMuted,
          highlightColor: AppTheme.surfaceLight,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            color: Colors.white,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          color: AppTheme.surfaceLight,
          child: Center(
            child: Icon(Icons.broken_image_rounded, color: AppTheme.textMuted.withValues(alpha: 0.3), size: 32),
          ),
        );
      },
    );

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
}
