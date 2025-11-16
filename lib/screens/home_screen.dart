import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../models/anime.dart';
import '../models/api_response.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart' as custom_widget;
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ApiResponse<List<Anime>>> _trendingAnime;
  late Future<ApiResponse<List<Anime>>> _popularAnime;
  late Future<ApiResponse<List<Anime>>> _recentAnime;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 100 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 100 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  void _loadData() {
    setState(() {
      _trendingAnime = ApiService.getTrendingAnime(limit: 10);
      _popularAnime = ApiService.getPopularAnime(limit: 10);
      _recentAnime = ApiService.getRecentAnime(limit: 10);
    });
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          
          return RefreshIndicator(
            onRefresh: () async {
              _loadData();
            },
            backgroundColor: Colors.deepPurple,
            color: Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: isTablet ? 350 : 280,
                  flexibleSpace: FlexibleSpaceBar(
                    title: _showAppBarTitle 
                      ? Text(
                          'ResoNime',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 28 : 22,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        )
                      : null,
                    centerTitle: true,
                    background: _buildHeaderBackground(isTablet),
                  ),
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: _showAppBarTitle ? 4 : 0,
                  actions: [
                    if (_showAppBarTitle)
                      IconButton(
                        icon: Icon(Icons.search_rounded, color: Colors.white, size: isTablet ? 28 : 24),
                        onPressed: _navigateToSearch,
                      ),
                    if (_showAppBarTitle)
                      IconButton(
                        icon: Icon(Icons.notifications_none_rounded, color: Colors.white, size: isTablet ? 28 : 24),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tidak ada notifikasi baru'),
                              backgroundColor: Colors.deepPurple.shade600,
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _buildQuickStats(isTablet),
                ),
                SliverToBoxAdapter(
                  child: _buildAnimeSection(_trendingAnime, 'Trending Sekarang', Icons.trending_up_rounded, isTablet),
                ),
                SliverToBoxAdapter(
                  child: _buildAnimeSection(_popularAnime, 'Populer', Icons.local_fire_department_rounded, isTablet),
                ),
                SliverToBoxAdapter(
                  child: _buildAnimeSection(_recentAnime, 'Terbaru', Icons.new_releases_rounded, isTablet),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: isTablet ? 40 : 30),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBackground(bool isTablet) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.black,
                Colors.black,
              ],
            ),
          ),
        ),
        Positioned(
          right: -50,
          top: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.8,
            child: Lottie.network(
              'https://lottie.host/ce346fa6-606d-4145-bb8a-5e155e261b87/kP1qPnHEJQ.json',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: isTablet ? 40 : 30,
          left: isTablet ? 30 : 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ResoNime',
                style: TextStyle(
                  fontSize: isTablet ? 42 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Streaming Anime Terlengkap',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 14,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16, horizontal: isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('1000+', 'Anime', Icons.movie_rounded, Colors.amber),
          _buildStatItem('50+', 'Studio', Icons.business_rounded, Colors.purple),
          _buildStatItem('25+', 'Genre', Icons.category_rounded, Colors.blue),
          _buildStatItem('4.8', 'Rating', Icons.star_rounded, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildAnimeSection(Future<ApiResponse<List<Anime>>> future, String sectionName, IconData icon, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade600,
                        Colors.orange.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                  ),
                  child: Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
                ),
                SizedBox(width: isTablet ? 12 : 10),
                Text(
                  sectionName,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Membuka semua $sectionName'),
                        backgroundColor: Colors.deepPurple.shade600,
                      ),
                    );
                  },
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Colors.amber.shade400,
                      fontSize: isTablet ? 14 : 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          FutureBuilder<ApiResponse<List<Anime>>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: _calculateSectionHeight(MediaQuery.of(context).size.width),
                  child: _buildHorizontalShimmer(MediaQuery.of(context).size.width > 600),
                );
              } else if (snapshot.hasError) {
                return custom_widget.CustomErrorWidget(
                  message: 'Gagal memuat $sectionName: ${snapshot.error}',
                  onRetry: _loadData,
                );
              } else if (snapshot.hasData) {
                final response = snapshot.data!;
                if (!response.success) {
                  return custom_widget.CustomErrorWidget(
                    message: 'Gagal memuat $sectionName: ${response.message}',
                    onRetry: _loadData,
                  );
                }
                final animes = response.data!;
                return SizedBox(
                  height: _calculateSectionHeight(MediaQuery.of(context).size.width),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: _calculateSectionPadding(MediaQuery.of(context).size.width),
                    ),
                    itemCount: animes.length,
                    itemBuilder: (context, index) {
                      return AnimeCard(
                        anime: animes[index],
                        onTap: () {
                          _showAnimeDetail(animes[index]);
                        },
                      );
                    },
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }

  double _calculateSectionHeight(double screenWidth) {
    if (screenWidth > 1200) return 320;
    if (screenWidth > 900) return 300;
    if (screenWidth > 600) return 280;
    if (screenWidth > 400) return 250;
    return 240;
  }

  double _calculateSectionPadding(double screenWidth) {
    if (screenWidth > 1200) return 24;
    if (screenWidth > 900) return 22;
    if (screenWidth > 600) return 20;
    if (screenWidth > 400) return 18;
    return 16;
  }

  Widget _buildHorizontalShimmer(bool isTablet) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: isTablet ? 180 : 150,
          margin: EdgeInsets.only(right: isTablet ? 16 : 12),
          child: Card(
            color: Colors.grey.shade900,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  child: Container(
                    width: double.infinity,
                    height: isTablet ? 180 : 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        child: Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ShimmerLoading(
                        child: Container(
                          width: 100,
                          height: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
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
          ),
        );
      },
    );
  }
}