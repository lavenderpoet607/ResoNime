import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/anime.dart';
import '../models/api_response.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart' as custom_widget;
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  ApiResponse<List<Anime>> _searchResponse = ApiResponse(success: false, message: '', data: []);
  bool _isLoading = false;
  final List<String> _searchHistory = ['Naruto', 'One Piece', 'Attack on Titan', 'Demon Slayer'];
  final List<String> _popularSearches = ['Jujutsu Kaisen', 'My Hero Academia', 'Tokyo Revengers', 'Chainsaw Man', 'Spy x Family'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchAnime(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResponse = ApiResponse(success: true, message: '', data: []);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResponse = ApiResponse(success: false, message: '', data: []);
    });

    try {
      final response = await ApiService.searchAnime(query: query);
      setState(() {
        _searchResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResponse = ApiResponse(success: false, message: 'Terjadi kesalahan jaringan', data: []);
        _isLoading = false;
      });
    }
  }

  void _handleHistoryTap(String query) {
    _searchController.text = query;
    _searchAnime(query);
  }

  void _showAnimeDetail(Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(animeId: anime.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: _buildSearchBar(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
            child: _buildBody(isTablet),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: 'Cari judul anime...',
          hintStyle: TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          suffixIcon: IconButton(
            icon: Icon(Icons.search_rounded, color: Colors.deepPurple.shade400),
            onPressed: () => _searchAnime(_searchController.text),
          ),
        ),
        onSubmitted: _searchAnime,
      ),
    );
  }

  Widget _buildBody(bool isTablet) {
    if (_isLoading) {
      return const AnimeLoadingShimmer(itemCount: 9, isGrid: true);
    }

    if (!_searchResponse.success && _searchController.text.isNotEmpty) {
      final errorMessage = _searchResponse.message.isNotEmpty
          ? _searchResponse.message
          : 'Gagal memuat hasil pencarian. Silakan coba lagi.';
      
      return custom_widget.CustomErrorWidget(
        message: errorMessage,
        onRetry: () => _searchAnime(_searchController.text),
      );
    }

    if (_searchResponse.success && _searchResponse.data!.isNotEmpty) {
      return _buildSearchResults(_searchResponse.data!, isTablet);
    }

    if (_searchController.text.isNotEmpty && !_isLoading) {
      return _buildNoResults(isTablet);
    }

    return _buildInitialScreen(isTablet);
  }

  Widget _buildSearchResults(List<Anime> animes, bool isTablet) {
    return GridView.builder(
      padding: EdgeInsets.only(top: isTablet ? 20 : 16, bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 3,
        crossAxisSpacing: isTablet ? 16 : 10,
        mainAxisSpacing: isTablet ? 16 : 10,
        childAspectRatio: AnimeCard.mobileCardWidth / (AnimeCard.mobileImageHeight + 70) * (isTablet ? 1.3 : 1.0),
      ),
      itemCount: animes.length,
      itemBuilder: (context, index) {
        return AnimeCard(
          anime: animes[index],
          onTap: () => _showAnimeDetail(animes[index]),
        );
      },
    );
  }

  Widget _buildNoResults(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 180 : 130,
            height: isTablet ? 180 : 130,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.sentiment_dissatisfied_rounded,
              color: Colors.deepPurple.shade400,
              size: isTablet ? 80 : 60,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Anime tidak ditemukan',
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Coba kata kunci lain atau periksa ejaan Anda.',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialScreen(bool isTablet) {
    return ListView(
      children: [
        _buildHistorySection(isTablet),
        SizedBox(height: isTablet ? 30 : 20),
        _buildPopularSection(isTablet),
      ],
    );
  }

  Widget _buildHistorySection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Pencarian',
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Wrap(
          spacing: isTablet ? 12 : 8,
          runSpacing: isTablet ? 12 : 8,
          children: _searchHistory.map((query) => InkWell(
            onTap: () => _handleHistoryTap(query),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: isTablet ? 8 : 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade700, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, color: Colors.deepPurple.shade400, size: isTablet ? 18 : 16),
                  SizedBox(width: isTablet ? 8 : 6),
                  Text(
                    query,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pencarian Populer',
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: isTablet ? 16 : 10,
            mainAxisSpacing: isTablet ? 16 : 10,
          ),
          itemCount: _popularSearches.length,
          itemBuilder: (context, index) {
            final query = _popularSearches[index];
            return InkWell(
              onTap: () => _handleHistoryTap(query),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade900.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade700, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: Colors.pink.shade400, size: isTablet ? 20 : 18),
                    SizedBox(width: isTablet ? 8 : 6),
                    Expanded(
                      child: Text(
                        query,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}