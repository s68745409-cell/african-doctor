import 'package:flutter/foundation.dart';

/// A single YouTube community video associated with a plant.
@immutable
class CommunityVideo {
  final String videoId;
  final String title;
  final String channel;
  final String thumbnailUrl;
  final DateTime publishedAt;

  const CommunityVideo({
    required this.videoId,
    required this.title,
    required this.channel,
    required this.thumbnailUrl,
    required this.publishedAt,
  });

  factory CommunityVideo.fromYouTubeJson(Map<String, dynamic> json) {
    final id = json['id'] as Map<String, dynamic>? ?? {};
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final medium = thumbnails['medium'] as Map<String, dynamic>? ??
        thumbnails['default'] as Map<String, dynamic>? ??
        {};
    return CommunityVideo(
      videoId: id['videoId'] as String? ?? '',
      title: snippet['title'] as String? ?? '',
      channel: snippet['channelTitle'] as String? ?? '',
      thumbnailUrl: medium['url'] as String? ?? '',
      publishedAt: DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Uri get watchUrl => Uri.parse('https://www.youtube.com/watch?v=$videoId');

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'channel': channel,
        'thumbnailUrl': thumbnailUrl,
        'publishedAt': publishedAt.toIso8601String(),
      };

  factory CommunityVideo.fromJson(Map<String, dynamic> json) => CommunityVideo(
        videoId: json['videoId'] as String,
        title: json['title'] as String,
        channel: json['channel'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
      );
}
