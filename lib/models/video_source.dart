class VideoSource {
  final String url;
  final String quality;
  final String server;
  final bool isM3U8;
  final String type;

  VideoSource({
    required this.url,
    required this.quality,
    required this.server,
    this.isM3U8 = false,
    this.type = 'hls',
  });
}

class Episode {
  final int number;
  final String title;
  final String? thumbnail;
  final String? duration;
  final List<VideoSource> sources;
  final String? episodeId;
  final bool isFiller;

  Episode({
    required this.number,
    required this.title,
    this.thumbnail,
    this.duration,
    required this.sources,
    this.episodeId,
    this.isFiller = false,
  });
}