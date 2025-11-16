import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/streaming_service.dart';
import '../models/anime.dart';
import '../models/api_response.dart';
import '../models/video_source.dart';
import '../widgets/error_widget.dart' as custom_widget;
import '../widgets/loading_shimmer.dart';
import 'video_player_screen.dart';

class DetailScreen extends StatefulWidget {
  final int animeId;

  const DetailScreen({super.key, required this.animeId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<ApiResponse<Anime>> _animeFuture;
  bool _isFavorite = false;
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  late Future<List<Episode>> _episodesFuture;

  @override
  void initState() {
    super.initState();
    _loadAnimeDetails();
    _scrollController.addListener(_scrollListener);
    _episodesFuture = StreamingService.getAnimeEpisodes(widget.animeId, '');
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 250 && !_showTitle) {
        setState(() {
          _showTitle = true;
        });
      } else if (_scrollController.offset <= 250 && _showTitle) {
        setState(() {
          _showTitle = false;
        });
      }
    }
  }

  void _loadAnimeDetails() {
    setState(() {
      _animeFuture = ApiService.getAnimeDetails(widget.animeId);
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _showSnackBar(
      _isFavorite ? 'Ditambahkan ke Favorit' : 'Dihapus dari Favorit',
      _isFavorite ? Colors.pink.shade700 : Colors.grey.shade700,
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    _showSnackBar(
      _isBookmarked ? 'Ditambahkan ke Daftar Tonton' : 'Dihapus dari Daftar Tonton',
      _isBookmarked ? Colors.deepPurple.shade700 : Colors.grey.shade700,
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _playEpisode(Episode episode, String animeTitle) async {
    final sources = await StreamingService.getEpisodeSources(episode.number.toString(), widget.animeId.toString());
    final allEpisodes = await _episodesFuture;
    
    if (!mounted) return;
    
    if (sources.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoSources: sources,
            animeTitle: animeTitle,
            episodeNumber: episode.number,
            allEpisodes: allEpisodes,
            onEpisodeChange: (newEpisodeNumber) {
              final newEpisode = allEpisodes.firstWhere(
                (ep) => ep.number == newEpisodeNumber,
                orElse: () => episode,
              );
              _playEpisode(newEpisode, animeTitle);
            },
          ),
        ),
      );
    } else {
      _showSnackBar('Tidak dapat memuat video', Colors.red.shade700);
    }
  }

  void _handleWatchNow() {
    _showSnackBar('Memulai streaming...', Colors.pink.shade700);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<ApiResponse<Anime>>(
        future: _animeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          } else if (snapshot.hasError) {
            return custom_widget.CustomErrorWidget(
              message: 'Gagal memuat detail anime: ${snapshot.error}',
              onRetry: _loadAnimeDetails,
            );
          } else if (snapshot.hasData) {
            final response = snapshot.data!;
            if (!response.success) {
              return custom_widget.CustomErrorWidget(
                message: 'Gagal memuat detail anime: ${response.message}',
                onRetry: _loadAnimeDetails,
              );
            }
            final anime = response.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isTablet = constraints.maxWidth > 600;
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildSliverAppBar(anime, isTablet),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _buildActionButtons(isTablet),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16, vertical: isTablet ? 20 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitleSection(anime, isTablet),
                                _buildStatsRow(anime, isTablet),
                                SizedBox(height: isTablet ? 20 : 16),
                                _buildDescription(anime, isTablet),
                                _buildGenreList(anime, isTablet),
                                _buildInformationSection(anime, isTablet),
                                _buildEpisodeList(anime, isTablet),
                              ],
                            ),
                          ),
                          SizedBox(height: isTablet ? 50 : 30),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEpisodeList(Anime anime, bool isTablet) {
    return FutureBuilder<List<Episode>>(
      future: _episodesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildEpisodeLoadingShimmer(isTablet);
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final episodes = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Episode',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return _buildEpisodeItem(episode, anime.title, isTablet);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEpisodeItem(Episode episode, String animeTitle, bool isTablet) {
    return ListTile(
      leading: Container(
        width: isTablet ? 80 : 60,
        height: isTablet ? 60 : 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade800,
        ),
        child: episode.thumbnail != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  episode.thumbnail!,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(Icons.play_circle_filled, color: Colors.deepPurple.shade400),
      ),
      title: Text(
        'Episode ${episode.number}',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 16 : 14,
          fontFamily: 'Poppins',
        ),
      ),
      subtitle: Text(
        episode.title,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: isTablet ? 14 : 12,
          fontFamily: 'Poppins',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: episode.duration != null
          ? Text(
              episode.duration!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 12 : 10,
                fontFamily: 'Poppins',
              ),
            )
          : null,
      onTap: () => _playEpisode(episode, animeTitle),
    );
  }

  Widget _buildEpisodeLoadingShimmer(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Episode',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ListTile(
              leading: ShimmerLoading(
                child: Container(
                  width: isTablet ? 80 : 60,
                  height: isTablet ? 60 : 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              title: ShimmerLoading(
                child: Container(
                  height: 16,
                  width: 100,
                  color: Colors.grey.shade800,
                ),
              ),
              subtitle: ShimmerLoading(
                child: Container(
                  height: 12,
                  width: 150,
                  color: Colors.grey.shade800,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Anime anime, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 400 : 350,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: _showTitle ? Colors.white : Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: _isFavorite ? Colors.pink.shade500 : Colors.white),
          onPressed: _toggleFavorite,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: _showTitle
            ? Text(
                anime.title,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: anime.mainPicture ?? '',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(Anime anime, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          anime.title,
          style: TextStyle(
            fontSize: isTablet ? 30 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
            height: 1.2,
          ),
        ),
        SizedBox(height: isTablet ? 8 : 4),
        Text(
          anime.englishTitle ?? anime.japaneseTitle ?? 'No alternate title',
          style: TextStyle(
            fontSize: isTablet ? 18 : 14,
            color: Colors.grey.shade500,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
      ],
    );
  }

  Widget _buildStatsRow(Anime anime, bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatItem(Icons.star_rate_rounded, anime.mean?.toStringAsFixed(2) ?? 'N/A', Colors.amber.shade400, isTablet),
          _buildStatItem(Icons.movie_creation_rounded, anime.mediaType ?? 'N/A', Colors.deepPurple.shade400, isTablet),
          _buildStatItem(Icons.calendar_today_rounded, _getAiringYear(anime), Colors.teal.shade400, isTablet),
          _buildStatItem(Icons.people_alt_rounded, _getNumListUsers(anime), Colors.pink.shade400, isTablet),
          _buildStatItem(Icons.tag_rounded, anime.numEpisodes?.toString() ?? 'N/A', Colors.blue.shade400, isTablet),
        ],
      ),
    );
  }

  String _getAiringYear(Anime anime) {
    if (anime.startSeason?.year != null) {
      return anime.startSeason!.year.toString();
    }
    return 'N/A';
  }

  String _getNumListUsers(Anime anime) {
    if (anime.popularity != null) {
      return '${anime.popularity! ~/ 1000}k';
    }
    return 'N/A';
  }

  Widget _buildStatItem(IconData icon, String value, Color color, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(right: isTablet ? 12 : 8),
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 10, vertical: isTablet ? 6 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isTablet ? 18 : 14),
          SizedBox(width: isTablet ? 6 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16, vertical: isTablet ? 10 : 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleWatchNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: Icon(Icons.play_arrow_rounded, size: isTablet ? 28 : 24),
              label: Text(
                'Tonton Sekarang',
                style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple.shade700, width: 2),
            ),
            child: IconButton(
              onPressed: _toggleBookmark,
              icon: Icon(_isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: _isBookmarked ? Colors.deepPurple.shade400 : Colors.white),
              padding: EdgeInsets.all(isTablet ? 14 : 10),
              iconSize: isTablet ? 26 : 22,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Anime anime, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sinopsis',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          anime.synopsis ?? 'Sinopsis tidak tersedia.',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Colors.grey.shade400,
            height: 1.5,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: isTablet ? 24 : 16),
      ],
    );
  }

  Widget _buildGenreList(Anime anime, bool isTablet) {
    if (anime.genres == null || anime.genres!.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Wrap(
          spacing: isTablet ? 12 : 8,
          runSpacing: isTablet ? 12 : 8,
          children: anime.genres!.map((genre) => Container(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              genre.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          )).toList(),
        ),
        SizedBox(height: isTablet ? 24 : 16),
      ],
    );
  }

  Widget _buildInformationSection(Anime anime, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Informasi',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        _buildInfoRow('Status', anime.status ?? 'N/A', isTablet),
        _buildInfoRow('Jumlah Episode', anime.numEpisodes?.toString() ?? 'N/A', isTablet),
        _buildInfoRow('Tipe Media', anime.mediaType ?? 'N/A', isTablet),
        _buildInfoRow('Rating', anime.rating ?? 'N/A', isTablet),
        _buildInfoRow('Studio', _getStudios(anime), isTablet),
        _buildInfoRow('Musim Tayang', _getStartSeason(anime), isTablet),
      ],
    );
  }

  String _getStudios(Anime anime) {
    if (anime.studios != null && anime.studios!.isNotEmpty) {
      return anime.studios!.map((s) => s.name).join(', ');
    }
    return 'N/A';
  }

  String _getStartSeason(Anime anime) {
    if (anime.startSeason != null) {
      return '${_capitalizeFirst(anime.startSeason!.season)} ${anime.startSeason!.year}';
    }
    return 'N/A';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey.shade500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return const CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          backgroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            background: ShimmerLoading(
              child: ColoredBox(color: Colors.grey),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                ShimmerLoading(child: SizedBox(height: 24, width: 250, child: ColoredBox(color: Colors.grey))),
                SizedBox(height: 8),
                ShimmerLoading(child: SizedBox(height: 14, width: 150, child: ColoredBox(color: Colors.grey))),
                SizedBox(height: 20),
                ShimmerLoading(child: SizedBox(height: 40, child: ColoredBox(color: Colors.grey))),
                SizedBox(height: 20),
                ShimmerLoading(child: SizedBox(height: 18, width: 100, child: ColoredBox(color: Colors.grey))),
                SizedBox(height: 10),
                ShimmerLoading(child: SizedBox(height: 14, child: ColoredBox(color: Colors.grey))),
                SizedBox(height: 10),
                ShimmerLoading(child: SizedBox(height: 14, width: 300, child: ColoredBox(color: Colors.grey))),
                SizedBox(height: 30),
                ShimmerLoading(child: SizedBox(height: 18, width: 100, child: ColoredBox(color: Colors.grey))),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ShimmerLoading(child: SizedBox(width: 80, height: 30, child: ColoredBox(color: Colors.grey))),
                    ShimmerLoading(child: SizedBox(width: 100, height: 30, child: ColoredBox(color: Colors.grey))),
                    ShimmerLoading(child: SizedBox(width: 60, height: 30, child: ColoredBox(color: Colors.grey))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}