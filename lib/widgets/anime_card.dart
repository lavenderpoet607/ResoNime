import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;

  const AnimeCard({
    super.key,
    required this.anime,
    required this.onTap,
  });

  static const double mobileCardWidthValue = 140.0;
  static const double mobileImageHeightValue = 100.0;
  
  static get mobileCardWidth => mobileCardWidthValue;
  static get mobileImageHeight => mobileImageHeightValue;

  String _getEpisodeInfo() {
    if (anime.numEpisodes == null || anime.numEpisodes == 0) {
      return 'Ongoing';
    } else {
      return '${anime.numEpisodes} eps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = _calculateCardWidth(constraints.maxWidth);
        final double imageHeight = _calculateImageHeight(constraints.maxWidth);
        final double paddingSize = _calculatePadding(constraints.maxWidth);
        final double fontSize = _calculateFontSize(constraints.maxWidth);
        final double iconSize = _calculateIconSize(constraints.maxWidth);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            margin: EdgeInsets.all(paddingSize / 2),
            child: Card(
              color: Colors.grey.shade900,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black.withOpacity(0.3),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: anime.mainPicture ?? '',
                              width: double.infinity,
                              height: imageHeight,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade800,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.amber,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade800,
                                height: imageHeight,
                                child: Icon(
                                  Icons.error,
                                  color: Colors.grey.shade600,
                                  size: iconSize * 1.5,
                                ),
                              ),
                            ),
                            Container(
                              height: imageHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            if (anime.mean != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, color: Colors.black, size: iconSize - 2),
                                      const SizedBox(width: 2),
                                      Text(
                                        anime.mean!.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: fontSize - 2,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      Container(
                        height: _calculateTextContainerHeight(constraints.maxWidth),
                        padding: EdgeInsets.all(paddingSize),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                anime.title,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.3,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            Row(
                              children: [
                                if (anime.mediaType != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      anime.mediaType!,
                                      style: TextStyle(
                                        fontSize: fontSize - 3,
                                        color: Colors.deepPurple.shade300,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                if (anime.numEpisodes != null)
                                  Text(
                                    _getEpisodeInfo(),
                                    style: TextStyle(
                                      fontSize: fontSize - 2,
                                      color: Colors.white70,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  Positioned(
                    top: imageHeight / 2 - 20,
                    left: cardWidth / 2 - 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateCardWidth(double screenWidth) {
    if (screenWidth > 1200) return 200;
    else if (screenWidth > 900) return 180;
    else if (screenWidth > 600) return 160;
    else if (screenWidth > 400) return 150;
    else return 140;
  }

  double _calculateImageHeight(double screenWidth) {
    if (screenWidth > 1200) return 140;
    else if (screenWidth > 900) return 130;
    else if (screenWidth > 600) return 120;
    else if (screenWidth > 400) return 110;
    else return 100;
  }

  double _calculateTextContainerHeight(double screenWidth) {
    if (screenWidth > 1200) return 80;
    else if (screenWidth > 900) return 70;
    else if (screenWidth > 600) return 65;
    else if (screenWidth > 400) return 60;
    else return 55;
  }

  double _calculatePadding(double screenWidth) {
    if (screenWidth > 1200) return 12;
    else if (screenWidth > 900) return 10;
    else if (screenWidth > 600) return 8;
    else if (screenWidth > 400) return 7;
    else return 6;
  }

  double _calculateFontSize(double screenWidth) {
    if (screenWidth > 1200) return 14;
    else if (screenWidth > 900) return 13;
    else if (screenWidth > 600) return 12;
    else if (screenWidth > 400) return 11;
    else return 10;
  }

  double _calculateIconSize(double screenWidth) {
    if (screenWidth > 1200) return 16;
    else if (screenWidth > 900) return 15;
    else if (screenWidth > 600) return 14;
    else if (screenWidth > 400) return 13;
    else return 12;
  }
}