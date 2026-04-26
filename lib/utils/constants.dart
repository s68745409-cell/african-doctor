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

  /// Default Hugging Face Space that hosts the medicinal-plants classifier
  /// and exposes a public `POST /api/classify` endpoint. Override at
  /// runtime with the `HF_ENDPOINT_URL` env var. Anonymous access — no
  /// API token required for public Spaces.
  static const String defaultHfSpaceUrl =
      'https://edgarphiri1-african-doctor-classifier.hf.space';

  /// Hugging Face Inference router (fallback path used when HF_MODEL_ID is
  /// set and HF_ENDPOINT_URL is not). The full URL is
  /// `$huggingFaceRouter/$modelId`. See
  /// https://huggingface.co/docs/inference-providers/.
  static const String huggingFaceRouter =
      'https://router.huggingface.co/hf-inference/models';

  /// Plant.id v3 identification endpoint — kept so a future session can
  /// swap providers back.
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
