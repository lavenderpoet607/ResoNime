import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      enabled: enabled,
      child: child,
    );
  }
}

class AnimeLoadingShimmer extends StatelessWidget {
  final int itemCount;
  final bool isGrid;

  const AnimeLoadingShimmer({
    super.key,
    this.itemCount = 6,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    if (isGrid) {
      return GridView.builder(
        padding: EdgeInsets.only(top: isTablet ? 20 : 16, bottom: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 4 : 3,
          crossAxisSpacing: isTablet ? 16 : 10,
          mainAxisSpacing: isTablet ? 16 : 10,
          childAspectRatio: 0.55,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final double cardWidth = isTablet ? (screenWidth - (isTablet ? 48 : 32) - (isTablet ? 48 : 20)) / 4 : (screenWidth - 32 - 20) / 3;
          final double imageHeight = cardWidth * 1.35;
          final double titleWidth = cardWidth * 0.9;
          final double subtitleWidth = cardWidth * 0.6;
          
          return Container(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  child: Container(
                    width: cardWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        child: Container(
                          width: titleWidth,
                          height: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ShimmerLoading(
                        child: Container(
                          width: subtitleWidth,
                          height: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  child: Container(
                    width: isTablet ? 40 : 30,
                    height: isTablet ? 40 : 30,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 12),
                ShimmerLoading(
                  child: Container(
                    width: isTablet ? 70 : 60,
                    height: isTablet ? 100 : 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        child: Container(
                          width: double.infinity,
                          height: 18,
                          color: Colors.grey.shade800,
                          margin: const EdgeInsets.only(bottom: 8),
                        ),
                      ),
                      ShimmerLoading(
                        child: Container(
                          width: 150,
                          height: 14,
                          color: Colors.grey.shade800,
                          margin: const EdgeInsets.only(bottom: 6),
                        ),
                      ),
                      ShimmerLoading(
                        child: Container(
                          width: 80,
                          height: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}