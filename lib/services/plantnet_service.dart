import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/identification_result.dart';
import '../utils/constants.dart';

class PlantNetException implements Exception {
  final String message;
  PlantNetException(this.message);
  @override
  String toString() => 'PlantNetException: $message';
}

/// Thin wrapper around the Pl@ntNet /v2/identify REST API.
class PlantNetService {
  PlantNetService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Identify a plant from a single local image file.
  ///
  /// Throws [PlantNetException] on network or API error.
  Future<List<IdentificationResult>> identify({
    required File image,
    String organ = 'leaf',
  }) async {
    const defineKey = String.fromEnvironment('PLANTNET_API_KEY');
    final apiKey = defineKey.isNotEmpty
        ? defineKey
        : (dotenv.env['PLANTNET_API_KEY'] ?? '');
    if (apiKey.isEmpty) {
      throw PlantNetException(
        'PLANTNET_API_KEY is missing. Copy .env.example to .env and add your '
        'key from https://my.plantnet.org/',
      );
    }

    final uri = Uri.parse('${AppConstants.plantNetEndpoint}?api-key=$apiKey');
    final request = http.MultipartRequest('POST', uri)
      ..fields['organs'] = organ
      ..files.add(await http.MultipartFile.fromPath('images', image.path));

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw PlantNetException(
        'Pl@ntNet returned ${response.statusCode}: ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .take(AppConstants.maxSuggestions)
        .map(IdentificationResult.fromPlantNetJson)
        .toList();
    return results;
  }

  void close() => _client.close();
}
