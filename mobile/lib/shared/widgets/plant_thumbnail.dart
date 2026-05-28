import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Square plant photo with a rounded border and emoji fallback.
class PlantThumbnail extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final BorderRadius? borderRadius;

  const PlantThumbnail({
    super.key,
    this.photoUrl,
    this.size = 48,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(10);

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: br,
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(br),
          errorWidget: (_, __, ___) => _placeholder(br),
        ),
      );
    }
    return _placeholder(br);
  }

  Widget _placeholder(BorderRadius br) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accentMuted,
        borderRadius: br,
      ),
      child: Center(
        child: Text(
          '🪴',
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
