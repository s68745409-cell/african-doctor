import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/community_video.dart';
import '../utils/constants.dart';

class YouTubeException implements Exception {
  final String message;
  YouTubeException(this.message);
  @override
  String toString() => 'YouTubeException: $message';
}

/// Queries the YouTube Data API v3 for community videos about a plant.
class YouTubeService {
  YouTubeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Returns up to [maxResults] videos matching
  /// `"PLANT_NAME traditional medicine africa"`. Results are ordered by
  /// YouTube's relevance ranking.
  Future<List<CommunityVideo>> searchForPlant(
    String plantName, {
    int maxResults = 6,
  }) async {
    const defineKey = String.fromEnvironment('YOUTUBE_API_KEY');
    final apiKey = defineKey.isNotEmpty
        ? defineKey
        : (dotenv.env['YOUTUBE_API_KEY'] ?? '');
    if (apiKey.isEmpty) {
      // Fail soft: community videos are an enhancement, not a blocker.
      return const [];
    }

    final query = '$plantName traditional medicine africa';
    final uri = Uri.parse(AppConstants.youtubeSearchEndpoint).replace(
      queryParameters: <String, String>{
        'part': 'snippet',
        'type': 'video',
        'safeSearch': 'strict',
        'maxResults': '$maxResults',
        'q': query,
        'key': apiKey,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw YouTubeException(
        'YouTube API returned ${response.statusCode}: ${response.body}',
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((item) => (item['id'] as Map<String, dynamic>?)?['videoId'] != null)
        .map(CommunityVideo.fromYouTubeJson)
        .toList();
    return items;
  }

  /// Build a TikTok hashtag deep link. Opening this from the app will launch
  /// the TikTok app if installed, else the web fallback.
  Uri tikTokHashtag(String plantName) {
    final tag = plantName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return Uri.parse('https://www.tiktok.com/tag/$tag');
  }

  void close() => _client.close();
}
