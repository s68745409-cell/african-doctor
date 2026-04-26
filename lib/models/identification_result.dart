import 'package:flutter/foundation.dart';

/// A single plant suggestion from a plant-identification provider.
///
/// Two factory constructors are provided so we can swap providers without
/// touching the UI layer:
///
/// * [IdentificationResult.fromPlantIdJson] — Plant.id v3 `classification`
///   suggestion (the current default).
/// * [IdentificationResult.fromPlantNetJson] — legacy Pl@ntNet v2 /identify
///   result, kept for reference.
@immutable
class IdentificationResult {
  /// Confidence score in [0.0, 1.0].
  final double score;
  final String scientificName;
  final List<String> commonNames;
  final String family;
  final String genus;

  const IdentificationResult({
    required this.score,
    required this.scientificName,
    required this.commonNames,
    required this.family,
    required this.genus,
  });

  factory IdentificationResult.fromPlantIdJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    final taxonomy = details['taxonomy'] as Map<String, dynamic>? ?? {};
    final commonNamesRaw = details['common_names'] as List<dynamic>? ?? [];
    return IdentificationResult(
      score: (json['probability'] as num?)?.toDouble() ?? 0.0,
      scientificName: json['name'] as String? ?? 'Unknown',
      commonNames: List<String>.from(commonNamesRaw),
      family: taxonomy['family'] as String? ?? '',
      genus: taxonomy['genus'] as String? ?? '',
    );
  }

  factory IdentificationResult.fromPlantNetJson(Map<String, dynamic> json) {
    final species = json['species'] as Map<String, dynamic>? ?? {};
    final common = species['commonNames'] as List<dynamic>? ?? [];
    final scientific =
        species['scientificNameWithoutAuthor'] as String? ?? 'Unknown';
    final family =
        (species['family'] as Map<String, dynamic>?)?['scientificNameWithoutAuthor']
                as String? ??
            '';
    final genus =
        (species['genus'] as Map<String, dynamic>?)?['scientificNameWithoutAuthor']
                as String? ??
            '';
    return IdentificationResult(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      scientificName: scientific,
      commonNames: List<String>.from(common),
      family: family,
      genus: genus,
    );
  }

  int get scorePercent => (score * 100).round();
}
