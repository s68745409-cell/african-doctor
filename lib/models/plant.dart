import 'package:flutter/foundation.dart';

/// A verified African medicinal plant entry from the seed database.
@immutable
class Plant {
  final String scientificName;
  final List<String> commonNames;
  final Map<String, String> localNames;
  final String region;
  final List<String> partUsed;
  final String primaryUse;
  final String preparation;
  final String warnings;
  final String verifiedBy;
  final String imageHints;

  const Plant({
    required this.scientificName,
    required this.commonNames,
    required this.localNames,
    required this.region,
    required this.partUsed,
    required this.primaryUse,
    required this.preparation,
    required this.warnings,
    required this.verifiedBy,
    required this.imageHints,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      scientificName: json['scientific_name'] as String,
      commonNames: List<String>.from(json['common_names'] as List<dynamic>),
      localNames: Map<String, String>.from(
        json['local_names'] as Map<dynamic, dynamic>,
      ),
      region: json['region'] as String? ?? '',
      partUsed: List<String>.from(json['part_used'] as List<dynamic>? ?? []),
      primaryUse: json['primary_use'] as String? ?? '',
      preparation: json['preparation'] as String? ?? '',
      warnings: json['warnings'] as String? ?? '',
      verifiedBy: json['verified_by'] as String? ?? 'Unverified',
      imageHints: json['image_hints'] as String? ?? '',
    );
  }

  /// Canonical key used for cache lookup and URL building.
  String get slug => scientificName.toLowerCase().replaceAll(' ', '-');

  /// Human-facing primary common name.
  String get displayName =>
      commonNames.isNotEmpty ? commonNames.first : scientificName;
}
