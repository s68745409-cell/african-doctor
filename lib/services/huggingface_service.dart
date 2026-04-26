import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/identification_result.dart';
import '../utils/constants.dart';

class HuggingFaceException implements Exception {
  final String message;
  HuggingFaceException(this.message);
  @override
  String toString() => 'HuggingFaceException: $message';
}

/// Thin wrapper around a Hugging Face `image-classification` model exposed via
/// the HF Inference router.
///
/// The default model is `dima806/medicinal_plants_image_detection` — a ViT
/// fine-tuned on medicinal plants. Override via `HF_MODEL_ID` if a better
/// model becomes available, or point at an Inference Endpoint URL via
/// `HF_ENDPOINT_URL`.
///
/// Signup: https://huggingface.co/join (30 seconds, email + password). Then
/// generate a token at https://huggingface.co/settings/tokens (role: "Read").
class HuggingFaceService {
  HuggingFaceService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Identify a plant from a single local image file.
  ///
  /// The HF image-classification API returns a flat list of
  /// `{"label": "...", "score": 0.0-1.0}` objects sorted by score desc. We
  /// take the top [AppConstants.maxSuggestions] and wrap them in
  /// [IdentificationResult]s so the UI layer does not need to know or care
  /// which provider generated them.
  Future<List<IdentificationResult>> identify({required File image}) async {
    final token = _readEnv('HF_API_TOKEN');
    if (token.isEmpty) {
      throw HuggingFaceException(
        'HF_API_TOKEN is missing. Create a free account at '
        'https://huggingface.co/join, then generate a read token at '
        'https://huggingface.co/settings/tokens and paste it into .env.',
      );
    }

    final modelId = _readEnv('HF_MODEL_ID').isNotEmpty
        ? _readEnv('HF_MODEL_ID')
        : AppConstants.defaultHuggingFaceModel;
    final explicitEndpoint = _readEnv('HF_ENDPOINT_URL');
    final uri = Uri.parse(
      explicitEndpoint.isNotEmpty
          ? explicitEndpoint
          : '${AppConstants.huggingFaceRouter}/$modelId',
    );

    final bytes = await image.readAsBytes();
    final response = await _client.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'image/jpeg',
        'Accept': 'application/json',
      },
      body: bytes,
    );

    if (response.statusCode == 503) {
      // Cold start — the model is being loaded. Surface a friendly error so
      // the ResultScreen's retry button makes sense to the user.
      throw HuggingFaceException(
        'The plant-identification model is warming up. Please try again in '
        'about 20 seconds.',
      );
    }
    if (response.statusCode != 200) {
      throw HuggingFaceException(
        'Hugging Face returned ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw HuggingFaceException(
        'Unexpected response shape from Hugging Face: ${response.body}',
      );
    }
    return decoded
        .cast<Map<String, dynamic>>()
        .take(AppConstants.maxSuggestions)
        .map(IdentificationResult.fromHuggingFaceJson)
        .toList();
  }

  static String _readEnv(String name) {
    // --dart-define takes precedence over .env so CI can inject values at
    // build time without touching the filesystem.
    final define = switch (name) {
      'HF_API_TOKEN' => const String.fromEnvironment('HF_API_TOKEN'),
      'HF_MODEL_ID' => const String.fromEnvironment('HF_MODEL_ID'),
      'HF_ENDPOINT_URL' => const String.fromEnvironment('HF_ENDPOINT_URL'),
      _ => '',
    };
    if (define.isNotEmpty) return define;
    return dotenv.env[name] ?? '';
  }

  void close() => _client.close();
}
