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
  /// identifier. Matching is case-insensitive; falls back to common-name,
  /// genus, and substring matches so labels from providers that emit common
  /// names (e.g. Hugging Face classification models) still resolve.
  Future<Plant?> lookup(String scientificName) async {
    final all = await loadAll();
    final target = scientificName.toLowerCase().trim();
    if (target.isEmpty) return null;

    // Exact scientific name
    for (final p in all) {
      if (p.scientificName.toLowerCase() == target) return p;
    }
    // Exact common name
    for (final p in all) {
      for (final c in p.commonNames) {
        if (c.toLowerCase() == target) return p;
      }
    }
    // Genus-level fallback (e.g. identifier returned "Aloe arborescens" but we
    // only have "Aloe vera" in the seed DB — we'd still like to show a related
    // entry, clearly flagged to the user at the UI layer).
    final genus = target.split(' ').first;
    for (final p in all) {
      if (p.scientificName.toLowerCase().startsWith('$genus ')) return p;
    }
    // Substring fallback — handles HF labels like "moringa oleifera leaf"
    // or "papaya plant" that don't parse as clean binomials.
    for (final p in all) {
      final sciLower = p.scientificName.toLowerCase();
      final sciGenus = sciLower.split(' ').first;
      if (target.contains(sciGenus)) return p;
      for (final c in p.commonNames) {
        final cLower = c.toLowerCase();
        if (target.contains(cLower) || cLower.contains(target)) return p;
      }
    }
    return null;
  }
}
