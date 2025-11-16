import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_source.dart';

class StreamingService {
  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Referer': 'https://gogoanime3.co/',
  };

  static Future<List<Episode>> getAnimeEpisodes(int animeId, String animeTitle) async {
    try {
      final searchResponse = await http.get(
        Uri.parse('https://api.consumet.org/meta/anilist/info/$animeId'),
        headers: _headers,
      );

      if (searchResponse.statusCode == 200) {
        final data = json.decode(searchResponse.body);
        return _parseEpisodes(data);
      }
      
      return _generateMockEpisodes(animeTitle);
    } catch (e) {
      return _generateMockEpisodes(animeTitle);
    }
  }

  static Future<List<VideoSource>> getEpisodeSources(String episodeId, String animeId) async {
    try {
      final servers = await _getAvailableServers(episodeId);
      final List<VideoSource> allSources = [];
      
      for (final server in servers) {
        try {
          final sources = await _getSourcesFromServer(episodeId, server);
          allSources.addAll(sources);
        } catch (e) {
          continue;
        }
      }
      
      if (allSources.isNotEmpty) {
        return allSources;
      }
      
      return _generateMockSources();
    } catch (e) {
      return _generateMockSources();
    }
  }

  static Future<List<String>> _getAvailableServers(String episodeId) async {
    return ['gogocdn', 'streamsb', 'vidstreaming'];
  }

  static Future<List<VideoSource>> _getSourcesFromServer(String episodeId, String server) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.consumet.org/meta/anilist/watch/$episodeId?server=$server'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseVideoSources(data, server);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static List<Episode> _parseEpisodes(Map<String, dynamic> data) {
    List<Episode> episodes = [];
    
    if (data['episodes'] != null) {
      for (var episodeData in data['episodes']) {
        episodes.add(Episode(
          number: episodeData['number'] ?? 0,
          title: episodeData['title'] ?? 'Episode ${episodeData['number']}',
          thumbnail: episodeData['image'],
          duration: episodeData['duration'] != null ? '${episodeData['duration']} min' : null,
          sources: [],
          episodeId: episodeData['id'],
        ));
      }
    }
    
    episodes.sort((a, b) => b.number.compareTo(a.number));
    return episodes;
  }

  static List<VideoSource> _parseVideoSources(Map<String, dynamic> data, String server) {
    List<VideoSource> sources = [];
    
    if (data['sources'] != null) {
      for (var sourceData in data['sources']) {
        sources.add(VideoSource(
          url: sourceData['url'] ?? '',
          quality: sourceData['quality'] ?? 'Unknown',
          server: server,
          isM3U8: (sourceData['url'] as String).contains('.m3u8'),
        ));
      }
    }
    
    return sources;
  }

  static List<Episode> _generateMockEpisodes(String animeTitle) {
    return List.generate(12, (index) => Episode(
      number: index + 1,
      title: 'Episode ${index + 1}',
      thumbnail: 'https://via.placeholder.com/300x169?text=$animeTitle+EP${index + 1}',
      duration: '24 min',
      sources: [],
      episodeId: 'episode-${index + 1}',
    ));
  }

  static List<VideoSource> _generateMockSources() {
    return [
      VideoSource(
        url: 'https://example.com/video/master.m3u8',
        quality: '1080p',
        server: 'Server 1',
        isM3U8: true,
      ),
      VideoSource(
        url: 'https://example.com/video/720p.m3u8',
        quality: '720p',
        server: 'Server 2',
        isM3U8: true,
      ),
      VideoSource(
        url: 'https://example.com/video/480p.m3u8',
        quality: '480p',
        server: 'Server 3',
        isM3U8: true,
      ),
    ];
  }
}