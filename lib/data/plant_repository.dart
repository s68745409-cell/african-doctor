import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/plant.dart';

/// Loads the seed medicinal-plant dataset shipped with the app.
///
/// In a production version this should be backed by Firestore (or equivalent)
/// and populated *only* with entries explicitly verified by partnering
/// botanists and traditional healers.
class PlantRepository {
  PlantRepository._();
  static final PlantRepository instance = PlantRepository._();

  List<Plant>? _cache;

  Future<List<Plant>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/plants.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['plants'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Plant.fromJson)
        .toList();
    _cache = list;
    return list;
  }

  /// Find the best matching seed entry for a scientific name returned by the
  /// identifier. Matching is case-insensitive and falls back to genus match.
  Future<Plant?> lookup(String scientificName) async {
    final all = await loadAll();
    final target = scientificName.toLowerCase().trim();
    if (target.isEmpty) return null;

    for (final p in all) {
      if (p.scientificName.toLowerCase() == target) return p;
    }
    // Genus-level fallback (e.g. identifier returned "Aloe arborescens" but we
    // only have "Aloe vera" in the seed DB — we'd still like to show a related
    // entry, clearly flagged to the user at the UI layer).
    final genus = target.split(' ').first;
    for (final p in all) {
      if (p.scientificName.toLowerCase().startsWith('$genus ')) return p;
    }
    return null;
  }
}
