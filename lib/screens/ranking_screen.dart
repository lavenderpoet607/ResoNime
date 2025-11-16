import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/anime.dart';
import '../models/api_response.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart' as custom_widget;
import 'detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

String _getEpisodeInfo(Anime anime) {
  if (anime.numEpisodes == null || anime.numEpisodes == 0) {
    return 'Ongoing';
  } else {
    return '${anime.numEpisodes} eps';
  }
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<ApiResponse<List<Anime>>> _rankingAnime;
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'airing', 'upcoming', 'bypopularity'];

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  void _loadRanking() {
    setState(() {
      _rankingAnime = ApiService.getAnimeRanking(filter: _selectedFilter, limit: 20);
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _loadRanking();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter diterapkan: ${_getFilterName(filter)}'),
        backgroundColor: Colors.deepPurple.shade600,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  String _getFilterName(String filter) {
    switch (filter) {
      case 'airing':
        return 'Tayang Sekarang';
      case 'upcoming':
        return 'Segera Tayang';
      case 'bypopularity':
        return 'Berdasarkan Popularitas';
      case 'all':
      default:
        return 'Semua Waktu';
    }
  }

  void _showAnimeDetail(int animeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(animeId: animeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Peringkat Anime',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: _buildFilterChips(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;

          return FutureBuilder<ApiResponse<List<Anime>>>(
            future: _rankingAnime,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingShimmer(isTablet);
              } else if (snapshot.hasError) {
                return custom_widget.CustomErrorWidget(
                  message: 'Gagal memuat peringkat: ${snapshot.error}',
                  onRetry: _loadRanking,
                );
              } else if (snapshot.hasData) {
                final response = snapshot.data!;
                if (!response.success) {
                  return custom_widget.CustomErrorWidget(
                    message: 'Gagal memuat peringkat: ${response.message}',
                    onRetry: _loadRanking,
                  );
                }
                final animes = response.data!;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 16),
                  itemCount: animes.length,
                  itemBuilder: (context, index) {
                    return _buildRankingItem(animes[index], index + 1, isTablet);
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_getFilterName(filter)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _onFilterChanged(filter);
                }
              },
              selectedColor: Colors.deepPurple.shade700,
              backgroundColor: Colors.grey.shade900,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.deepPurple.shade400 : Colors.grey.shade700,
                  width: 1.0,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankingItem(Anime anime, int rank, bool isTablet) {
    return InkWell(
      onTap: () => _showAnimeDetail(anime.id),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              width: isTablet ? 40 : 30,
              height: isTablet ? 40 : 30,
              decoration: BoxDecoration(
                color: rank <= 3 ? Colors.amber.shade700 : Colors.deepPurple.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(width: isTablet ? 20 : 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: anime.mainPicture ?? '',
                width: isTablet ? 70 : 60,
                height: isTablet ? 100 : 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade800,
                  width: isTablet ? 70 : 60,
                  height: isTablet ? 100 : 80,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade800,
                  width: isTablet ? 70 : 60,
                  height: isTablet ? 100 : 80,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.title,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Row(
                    children: [
                      Icon(Icons.star_rate_rounded, color: Colors.amber.shade400, size: isTablet ? 18 : 14),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        anime.mean?.toStringAsFixed(2) ?? 'N/A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 14 : 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Icon(Icons.people_alt_rounded, color: Colors.grey.shade500, size: isTablet ? 18 : 14),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        '${(anime.popularity ?? 0) ~/ 1000}k',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: isTablet ? 14 : 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Text(
                    '${anime.mediaType ?? 'TV'} • ${_getEpisodeInfo(anime)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: isTablet ? 12 : 10,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 16),
      itemCount: 10,
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