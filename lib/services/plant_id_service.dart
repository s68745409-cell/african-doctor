import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/identification_result.dart';
import '../utils/constants.dart';

class PlantIdException implements Exception {
  final String message;
  PlantIdException(this.message);
  @override
  String toString() => 'PlantIdException: $message';
}

/// Thin wrapper around the Plant.id v3 /identification REST API.
///
/// Signup: https://web.plant.id/ — free tier includes 100 identifications.
class PlantIdService {
  PlantIdService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Identify a plant from a single local image file.
  ///
  /// Throws [PlantIdException] on network or API error.
  Future<List<IdentificationResult>> identify({required File image}) async {
    const defineKey = String.fromEnvironment('PLANT_ID_API_KEY');
    final apiKey = defineKey.isNotEmpty
        ? defineKey
        : (dotenv.env['PLANT_ID_API_KEY'] ?? '');
    if (apiKey.isEmpty) {
      throw PlantIdException(
        'PLANT_ID_API_KEY is missing. Copy .env.example to .env and add your '
        'key from https://web.plant.id/',
      );
    }

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode(<String, dynamic>{
      'images': <String>['data:image/jpeg;base64,$base64Image'],
      'similar_images': false,
      'classification_level': 'species',
    });

    final uri = Uri.parse(AppConstants.plantIdEndpoint).replace(
      queryParameters: <String, String>{
        'details': 'common_names,taxonomy',
      },
    );

    final response = await _client.post(
      uri,
      headers: <String, String>{
        'Api-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw PlantIdException(
        'Plant.id returned ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final result = decoded['result'] as Map<String, dynamic>? ?? {};

    // Guard against non-plant images.
    final isPlant = result['is_plant'] as Map<String, dynamic>? ?? {};
    final isPlantProbability =
        (isPlant['probability'] as num?)?.toDouble() ?? 1.0;
    if (isPlantProbability < 0.5) {
      return const [];
    }

    final classification =
        result['classification'] as Map<String, dynamic>? ?? {};
    final suggestions =
        (classification['suggestions'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .take(AppConstants.maxSuggestions)
            .map(IdentificationResult.fromPlantIdJson)
            .toList();
    return suggestions;
  }

  void close() => _client.close();
}
