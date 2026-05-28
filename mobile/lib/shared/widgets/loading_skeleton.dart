import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A single shimmer-animated placeholder rectangle.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5E3);
    final highlight = isDark ? const Color(0xFF3C3C3E) : const Color(0xFFF0F0EE);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Skeleton matching the PlantListTile layout.
class PlantListTileSkeleton extends StatelessWidget {
  const PlantListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          SkeletonBox(width: 48, height: 48, borderRadius: BorderRadius.all(Radius.circular(10))),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 100, height: 11),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 70, height: 24),
        ],
      ),
    );
  }
}

/// Skeleton matching the ArticleCard layout.
class ArticleCardSkeleton extends StatelessWidget {
  const ArticleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 28, height: 28, borderRadius: BorderRadius.all(Radius.circular(14))),
              SizedBox(width: 8),
              SkeletonBox(width: 80, height: 11),
            ],
          ),
          SizedBox(height: 8),
          SkeletonBox(width: double.infinity, height: 16),
          SizedBox(height: 6),
          SkeletonBox(width: 160, height: 11),
        ],
      ),
    );
  }
}
