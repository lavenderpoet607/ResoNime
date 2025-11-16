class Anime {
  final int id;
  final String title;
  final String? mainPicture;
  final String? synopsis;
  final double? mean;
  final int? rank;
  final int? popularity;
  final int? numEpisodes;
  final String? mediaType;
  final String? status;
  final List<Genre>? genres;
  final StartSeason? startSeason;
  final double? averageEpisodeDuration;
  final String? rating;
  final List<Studio>? studios;
  final Statistics? statistics;
  final String? englishTitle;
  final String? japaneseTitle;
  final int? airingStartYear;
  final int? numListUsers;
  final String? source;
  final List<Producer>? producers;
  final String? airingStart;

  Anime({
    required this.id,
    required this.title,
    this.mainPicture,
    this.synopsis,
    this.mean,
    this.rank,
    this.popularity,
    this.numEpisodes,
    this.mediaType,
    this.status,
    this.genres,
    this.startSeason,
    this.averageEpisodeDuration,
    this.rating,
    this.studios,
    this.statistics,
    this.englishTitle,
    this.japaneseTitle,
    this.airingStartYear,
    this.numListUsers,
    this.source,
    this.producers,
    this.airingStart,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['mal_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? json['title_english'] ?? 'No Title',
      mainPicture: json['images'] != null 
          ? (json['images']['jpg']?['large_image_url'] ?? 
             json['images']['jpg']?['image_url']) 
          : null,
      synopsis: json['synopsis'],
      mean: json['score']?.toDouble(),
      rank: json['rank'],
      popularity: json['popularity'],
      numEpisodes: json['episodes'],
      mediaType: json['type'],
      status: json['status'],
      genres: json['genres'] != null
          ? List<Genre>.from(json['genres'].map((x) => Genre.fromJson(x)))
          : null,
      startSeason: json['season'] != null && json['year'] != null
          ? StartSeason(year: json['year'], season: json['season'])
          : null,
      averageEpisodeDuration: _parseDuration(json['duration']),
      rating: json['rating'],
      studios: json['studios'] != null
          ? List<Studio>.from(json['studios'].map((x) => Studio.fromJson(x)))
          : null,
      statistics: json['statistics'] != null
          ? Statistics.fromJson(json['statistics'])
          : null,
      englishTitle: json['title_english'],
      japaneseTitle: json['title_japanese'],
      airingStartYear: json['year'],
      numListUsers: json['members'],
      source: json['source'],
      producers: json['producers'] != null
          ? List<Producer>.from(json['producers'].map((x) => Producer.fromJson(x)))
          : null,
      airingStart: json['aired']?['string'],
    );
  }

  static double? _parseDuration(dynamic duration) {
    if (duration == null) return null;
    
    if (duration is num) {
      return duration.toDouble();
    }
    
    if (duration is String) {
      final match = RegExp(r'(\d+)').firstMatch(duration);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    
    return null;
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['mal_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class StartSeason {
  final int year;
  final String season;

  StartSeason({required this.year, required this.season});
}

class Studio {
  final int id;
  final String name;

  Studio({required this.id, required this.name});

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      id: json['mal_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Producer {
  final int id;
  final String name;

  Producer({required this.id, required this.name});

  factory Producer.fromJson(Map<String, dynamic> json) {
    return Producer(
      id: json['mal_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Statistics {
  final int? watching;
  final int? completed;
  final int? onHold;
  final int? dropped;
  final int? planToWatch;

  Statistics({
    this.watching,
    this.completed,
    this.onHold,
    this.dropped,
    this.planToWatch,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      watching: json['watching'],
      completed: json['completed'],
      onHold: json['on_hold'],
      dropped: json['dropped'],
      planToWatch: json['plan_to_watch'],
    );
  }
}