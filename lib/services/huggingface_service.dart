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

/// Classifies a plant image against a Hugging Face `image-classification`
/// model.
///
/// Two transport modes are supported, selected automatically:
///
/// 1. **Public HF Space REST endpoint** (default, no auth required).
///    `POST $endpoint/api/classify` with a `multipart/form-data` field
///    named `image`. Default endpoint is the project's own Space at
///    [AppConstants.defaultHfSpaceUrl]; override via the `HF_ENDPOINT_URL`
///    env var.
/// 2. **Serverless HF Inference router** (fallback, requires `HF_API_TOKEN`).
///    Used if `HF_ENDPOINT_URL` is explicitly blank AND an `HF_MODEL_ID`
///    is set that is deployed on the shared `hf-inference` provider.
///
/// Response shape (both modes): a JSON list of
/// `{"label": "Moringa", "score": 0.87}` objects sorted by score desc.
class HuggingFaceService {
  HuggingFaceService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<IdentificationResult>> identify({required File image}) async {
    final explicitEndpoint = _readEnv('HF_ENDPOINT_URL');
    final endpoint = explicitEndpoint.isNotEmpty
        ? explicitEndpoint
        : AppConstants.defaultHfSpaceUrl;

    final useSpaceApi = endpoint.contains('.hf.space') ||
        endpoint.endsWith('/api/classify') ||
        _readEnv('HF_MODEL_ID').isEmpty;

    return useSpaceApi
        ? _identifyViaSpace(endpoint: endpoint, image: image)
        : _identifyViaRouter(image: image);
  }

  Future<List<IdentificationResult>> _identifyViaSpace({
    required String endpoint,
    required File image,
  }) async {
    // Ensure we POST to the /api/classify path; callers may set
    // HF_ENDPOINT_URL to either the Space root or the full classify URL.
    final base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    final url = base.endsWith('/api/classify') ? base : '$base/api/classify';

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    // Bearer header is only needed if the Space is private; harmless if set.
    final token = _readEnv('HF_API_TOKEN');
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 503) {
      throw HuggingFaceException(
        'The plant-identification Space is warming up (cold-start). '
        'Please try again in ~20 seconds.',
      );
    }
    if (response.statusCode != 200) {
      throw HuggingFaceException(
        'Space returned ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw HuggingFaceException(
        'Unexpected response shape: ${response.body}',
      );
    }
    return decoded
        .cast<Map<String, dynamic>>()
        .take(AppConstants.maxSuggestions)
        .map(IdentificationResult.fromHuggingFaceJson)
        .toList();
  }

  Future<List<IdentificationResult>> _identifyViaRouter({
    required File image,
  }) async {
    final token = _readEnv('HF_API_TOKEN');
    if (token.isEmpty) {
      throw HuggingFaceException(
        'HF_API_TOKEN is missing for router-mode inference. Either point '
        'HF_ENDPOINT_URL at a public HF Space, or create a Read token at '
        'https://huggingface.co/settings/tokens.',
      );
    }
    final modelId = _readEnv('HF_MODEL_ID').isNotEmpty
        ? _readEnv('HF_MODEL_ID')
        : 'google/vit-base-patch16-224';
    final uri = Uri.parse('${AppConstants.huggingFaceRouter}/$modelId');
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
      throw HuggingFaceException(
        'The model is warming up. Please try again in about 20 seconds.',
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
