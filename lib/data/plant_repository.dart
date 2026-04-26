import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/plant.dart';

/// How the seed-library entry was matched to the identifier's label.
/// Used by the UI to decide whether a species-substitution warning is
/// required before showing medicinal info.
enum PlantMatchType {
  /// Scientific binomial matched exactly (case-insensitive).
  exactScientific,

  /// One of the entry's common names matched exactly.
  exactCommonName,

  /// The identifier label was a verbose string (e.g. "Moringa oleifera
  /// leaf") that *contains* the full binomial or a full common name of
  /// the seed entry. Still safe — it's the same species with decoration.
  extendedExact,

  /// No seed entry matched. [PlantMatch.plant] is null.
  none,
}

/// Result of [PlantRepository.lookup].
class PlantMatch {
  const PlantMatch({required this.plant, required this.matchType});

  /// The matched entry, or null if [matchType] is [PlantMatchType.none].
  final Plant? plant;
  final PlantMatchType matchType;

  bool get isExact =>
      matchType == PlantMatchType.exactScientific ||
      matchType == PlantMatchType.exactCommonName ||
      matchType == PlantMatchType.extendedExact;

  static const PlantMatch notFound =
      PlantMatch(plant: null, matchType: PlantMatchType.none);
}

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

  /// Find the best matching seed entry for a label returned by the identifier.
  ///
  /// Safety: we deliberately do NOT fall back to same-genus or arbitrary
  /// substring matches. Different species in the same genus can have very
  /// different toxicity profiles (e.g. Prunus africana vs. Prunus
  /// serotina), so silently showing a sibling species' preparation
  /// instructions is dangerous. Only the following match as "the same
  /// plant":
  ///   1. Scientific binomial matches exactly (case-insensitive).
  ///   2. A common name matches exactly.
  ///   3. The label string *contains* the full binomial (e.g. HF may emit
  ///      "Moringa oleifera leaf" — still the same species).
  ///   4. The label string *contains* a full common name, AND that common
  ///      name is at least two characters long (avoids matching e.g. "aloe"
  ///      in an unrelated label).
  Future<PlantMatch> lookup(String scientificName) async {
    final all = await loadAll();
    final target = scientificName.toLowerCase().trim();
    if (target.isEmpty) return PlantMatch.notFound;

    // 1. Exact scientific name
    for (final p in all) {
      if (p.scientificName.toLowerCase() == target) {
        return PlantMatch(plant: p, matchType: PlantMatchType.exactScientific);
      }
    }
    // 2. Exact common name
    for (final p in all) {
      for (final c in p.commonNames) {
        if (c.toLowerCase() == target) {
          return PlantMatch(plant: p, matchType: PlantMatchType.exactCommonName);
        }
      }
    }
    // 3. Extended exact — label contains the full binomial.
    for (final p in all) {
      final sci = p.scientificName.toLowerCase();
      if (sci.contains(' ') && target.contains(sci)) {
        return PlantMatch(plant: p, matchType: PlantMatchType.extendedExact);
      }
    }
    // Ambiguity guard: if the label looks like its own binomial (two
    // alphabetic words) AND the first word is the genus of a seed entry
    // that we did NOT match in rule 3, do not fall through to common-name
    // containment — that would substitute a sibling species (e.g. "Aloe
    // arborescens" → Aloe vera). Return notFound instead.
    final words = target.split(RegExp(r'\s+'));
    final looksBinomial = words.length == 2 &&
        words.every((w) => RegExp(r'^[a-z][a-z-]+$').hasMatch(w));
    if (looksBinomial) {
      final genus = words.first;
      final anyGenusCandidate = all.any(
        (p) => p.scientificName.toLowerCase().startsWith('$genus '),
      );
      if (anyGenusCandidate) return PlantMatch.notFound;
    }
    // 4. Extended exact — label contains a full common name. Skipped for
    // binomial-shaped labels because the ambiguity guard above already
    // fired.
    for (final p in all) {
      for (final c in p.commonNames) {
        final cl = c.toLowerCase();
        if (cl.length >= 2 && target.contains(cl)) {
          return PlantMatch(plant: p, matchType: PlantMatchType.extendedExact);
        }
      }
    }
    return PlantMatch.notFound;
  }
}
