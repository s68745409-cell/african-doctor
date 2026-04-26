import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/community_video.dart';
import '../utils/constants.dart';

/// Lightweight JSON-over-SharedPreferences cache for community-video lookups
/// and user flags. Avoids pulling in a full DB engine for the MVP — swap this
/// for Hive or SQLite once the data volume grows.
class CacheService {
  CacheService._(this._prefs);

  final SharedPreferences _prefs;

  static CacheService? _instance;

  static Future<CacheService> instance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    return _instance = CacheService._(prefs);
  }

  // ---------------- Community video cache ----------------

  String _videosKey(String slug) => 'videos:$slug';
  String _videosTsKey(String slug) => 'videos_ts:$slug';

  Future<List<CommunityVideo>?> readVideos(String slug) async {
    final ts = _prefs.getInt(_videosTsKey(slug));
    if (ts == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age > AppConstants.socialCacheTtl.inMilliseconds) return null;
    final raw = _prefs.getString(_videosKey(slug));
    if (raw == null) return null;
    final list = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(CommunityVideo.fromJson)
        .toList();
    return list;
  }

  Future<void> writeVideos(String slug, List<CommunityVideo> videos) async {
    await _prefs.setString(
      _videosKey(slug),
      jsonEncode(videos.map((v) => v.toJson()).toList()),
    );
    await _prefs.setInt(
      _videosTsKey(slug),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ---------------- Scan history ----------------

  static const _historyKey = 'scan_history';

  Future<List<String>> readHistory() async {
    return _prefs.getStringList(_historyKey) ?? const [];
  }

  Future<void> appendHistory(String scientificName) async {
    final current = _prefs.getStringList(_historyKey) ?? <String>[];
    current.removeWhere((e) => e == scientificName);
    current.insert(0, scientificName);
    final trimmed = current.take(100).toList();
    await _prefs.setStringList(_historyKey, trimmed);
  }

  // ---------------- Flag / upvote ----------------

  String _flagsKey(String videoId) => 'flags:$videoId';
  String _upvotesKey(String videoId) => 'upvotes:$videoId';

  Future<int> flagCount(String videoId) async =>
      _prefs.getInt(_flagsKey(videoId)) ?? 0;

  Future<int> upvoteCount(String videoId) async =>
      _prefs.getInt(_upvotesKey(videoId)) ?? 0;

  Future<int> flag(String videoId) async {
    final next = (await flagCount(videoId)) + 1;
    await _prefs.setInt(_flagsKey(videoId), next);
    return next;
  }

  Future<int> upvote(String videoId) async {
    final next = (await upvoteCount(videoId)) + 1;
    await _prefs.setInt(_upvotesKey(videoId), next);
    return next;
  }

  /// A video is hidden once it accumulates 3+ local flags. In production this
  /// should be replaced by a server-side aggregated count from Firestore.
  Future<bool> isHidden(String videoId) async => (await flagCount(videoId)) >= 3;

  // ---------------- Disclaimer state ----------------

  static const _disclaimerAcceptedKey = 'disclaimer_accepted';

  bool get hasAcceptedDisclaimer =>
      _prefs.getBool(_disclaimerAcceptedKey) ?? false;

  Future<void> acceptDisclaimer() =>
      _prefs.setBool(_disclaimerAcceptedKey, true);
}
