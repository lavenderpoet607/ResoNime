import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';
import '../models/api_response.dart';

class ApiService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';
  static const int _rateLimitDelay = 1000;

  static Future<ApiResponse<List<Anime>>> getTrendingAnime({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: _rateLimitDelay));
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/top/anime?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeData = data['data'];
        final List<Anime> animes = animeData.map((json) => Anime.fromJson(json)).toList();
        return ApiResponse.success(animes);
      } else {
        return ApiResponse.error('Failed to load trending anime: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  static Future<ApiResponse<List<Anime>>> getPopularAnime({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: _rateLimitDelay));
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/top/anime?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeData = data['data'];
        final List<Anime> animes = animeData.map((json) => Anime.fromJson(json)).toList();
        return ApiResponse.success(animes);
      } else {
        return ApiResponse.error('Failed to load popular anime: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  static Future<ApiResponse<List<Anime>>> getRecentAnime({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: _rateLimitDelay));
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/seasons/now?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeData = data['data'];
        final List<Anime> animes = animeData.map((json) => Anime.fromJson(json)).toList();
        return ApiResponse.success(animes);
      } else {
        return ApiResponse.error('Failed to load recent anime: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  static Future<ApiResponse<List<Anime>>> searchAnime({required String query, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: _rateLimitDelay));
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/anime?q=${Uri.encodeQueryComponent(query)}&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeData = data['data'];
        final List<Anime> animes = animeData.map((json) => Anime.fromJson(json)).toList();
        return ApiResponse.success(animes);
      } else {
        return ApiResponse.error('Failed to search anime: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  static Future<ApiResponse<Anime>> getAnimeDetails(int animeId) async {
    await Future.delayed(const Duration(milliseconds: _rateLimitDelay));
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/anime/$animeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Anime anime = Anime.fromJson(data['data']);
        return ApiResponse.success(anime);
      } else {
        return ApiResponse.error('Failed to load anime details: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  static Future<ApiResponse<List<Anime>>> getAnimeRanking({int limit = 20, required String filter}) async {
    await Future.delayed(const Duration(milliseconds: _rateLimitDelay));
    
    try {
      String filterParam = 'all';
      switch (filter) {
        case 'airing':
          filterParam = 'airing';
          break;
        case 'upcoming':
          filterParam = 'upcoming';
          break;
        case 'bypopularity':
          filterParam = 'bypopularity';
          break;
        default:
          filterParam = 'all';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/top/anime?limit=$limit&filter=$filterParam'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeData = data['data'];
        final List<Anime> animes = animeData.map((json) => Anime.fromJson(json)).toList();
        return ApiResponse.success(animes);
      } else {
        return ApiResponse.error('Failed to load anime ranking: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }
}