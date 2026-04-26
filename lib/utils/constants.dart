/// Compile-time / environment-wide configuration.
class AppConstants {
  AppConstants._();

  /// Minimum Pl@ntNet confidence score (0.0 – 1.0) before the app will show
  /// the traditional-medicine information screen. Below this threshold the
  /// app shows a "Could not identify with certainty" message and encourages
  /// the user to consult a local expert.
  static const double minConfidence = 0.85;

  /// How long social-media lookups are cached before being re-fetched.
  static const Duration socialCacheTtl = Duration(hours: 24);

  /// Maximum Pl@ntNet suggestions to consider from the API response.
  static const int maxSuggestions = 5;

  /// Plant.id v3 identification endpoint — current default provider.
  static const String plantIdEndpoint =
      'https://api.plant.id/v3/identification';

  /// Pl@ntNet REST endpoint — kept for reference so a future session can
  /// swap providers back without re-deriving the URL.
  static const String plantNetEndpoint =
      'https://my-api.plantnet.org/v2/identify/all';

  /// YouTube Data API v3 search endpoint.
  static const String youtubeSearchEndpoint =
      'https://www.googleapis.com/youtube/v3/search';
}
