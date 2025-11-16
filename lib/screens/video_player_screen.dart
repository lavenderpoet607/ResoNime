import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/video_source.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<VideoSource> videoSources;
  final String animeTitle;
  final int episodeNumber;
  final List<Episode> allEpisodes;
  final Function(int) onEpisodeChange;

  const VideoPlayerScreen({
    super.key,
    required this.videoSources,
    required this.animeTitle,
    required this.episodeNumber,
    required this.allEpisodes,
    required this.onEpisodeChange,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  int _selectedSourceIndex = 0;
  bool _isLoading = true;
  final bool _showControls = true;
  bool _isFullscreen = false;
  bool _showServerSelection = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    if (widget.videoSources.isEmpty) {
      if (mounted) {
        _showErrorDialog();
      }
      return;
    }

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoSources[_selectedSourceIndex].url),
      );

      await _videoPlayerController.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.deepPurple,
          handleColor: Colors.deepPurple,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade400,
        ),
        placeholder: Container(
          color: Colors.black,
        ),
        autoInitialize: true,
        showOptions: true,
        customControls: const CupertinoControls(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
          iconColor: Colors.white,
        ),
      );

      _chewieController!.addListener(() {
        if (_chewieController!.isFullScreen != _isFullscreen) {
          setState(() {
            _isFullscreen = _chewieController!.isFullScreen;
          });
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  void _changeVideoSource(int index) async {
    if (index == _selectedSourceIndex) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    _chewieController?.dispose();
    _videoPlayerController.dispose();

    _selectedSourceIndex = index;
    _initializeVideoPlayer();
  }

  void _showErrorDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Gagal memuat video. Silakan coba server lain.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  void _navigateToEpisode(int episodeNumber) {
    widget.onEpisodeChange(episodeNumber);
    Navigator.pop(context);
  }

  void _showEpisodeList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Daftar Episode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.allEpisodes.length,
                itemBuilder: (context, index) {
                  final episode = widget.allEpisodes[index];
                  final isCurrent = episode.number == widget.episodeNumber;
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.deepPurple : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${episode.number}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      episode.title,
                      style: TextStyle(
                        color: isCurrent ? Colors.deepPurple.shade300 : Colors.white,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      episode.duration ?? '24 min',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    trailing: isCurrent 
                        ? Icon(Icons.play_arrow, color: Colors.deepPurple.shade300)
                        : null,
                    onTap: () => _navigateToEpisode(episode.number),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleServerSelection() {
    setState(() {
      _showServerSelection = !_showServerSelection;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            if (!_isFullscreen)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.animeTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Episode ${widget.episodeNumber}',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.list_rounded, color: Colors.white),
                      onPressed: _showEpisodeList,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_input_antenna_rounded, color: Colors.white),
                      onPressed: _toggleServerSelection,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.deepPurple),
                    )
                  : Stack(
                      children: [
                        Chewie(controller: _chewieController!),
                        if (_showControls && !_isFullscreen)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Column(
                              children: [
                                if (widget.videoSources.length > 1)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: FloatingActionButton(
                                      onPressed: _toggleServerSelection,
                                      backgroundColor: Colors.deepPurple.shade700,
                                      mini: true,
                                      child: const Icon(Icons.settings_input_antenna_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                FloatingActionButton(
                                  onPressed: () {
                                    _chewieController?.enterFullScreen();
                                  },
                                  backgroundColor: Colors.deepPurple.shade700,
                                  child: const Icon(Icons.fullscreen, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            if (_showServerSelection && !_isFullscreen && widget.videoSources.length > 1)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade900,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Server & Kualitas:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.videoSources.asMap().entries.map((entry) {
                          final index = entry.key;
                          final source = entry.value;
                          final isSelected = index == _selectedSourceIndex;
                          
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                '${source.server} (${source.quality})',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) => _changeVideoSource(index),
                              selectedColor: Colors.deepPurple.shade700,
                              backgroundColor: Colors.grey.shade800,
                            ),
                          );
                        }).toList(),
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
}