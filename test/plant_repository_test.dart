import 'package:flutter_test/flutter_test.dart';

import 'package:african_doctor/data/plant_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Seed dataset loads and every plant has required fields', () async {
    final plants = await PlantRepository.instance.loadAll();
    expect(plants, isNotEmpty);
    for (final p in plants) {
      expect(p.scientificName, isNotEmpty, reason: 'missing scientific_name');
      expect(p.primaryUse, isNotEmpty,
          reason: '${p.scientificName} has no primary_use');
      expect(p.warnings, isNotEmpty,
          reason: '${p.scientificName} has no warnings — safety critical');
      expect(p.preparation, isNotEmpty,
          reason: '${p.scientificName} has no preparation instructions');
    }
  });

  test('Lookup matches exact scientific name', () async {
    final match = await PlantRepository.instance.lookup('Moringa oleifera');
    expect(match.plant, isNotNull);
    expect(match.matchType, PlantMatchType.exactScientific);
    expect(match.plant!.commonNames.first, 'Moringa');
  });

  test('Lookup is case insensitive', () async {
    final match = await PlantRepository.instance.lookup('aloe vera');
    expect(match.plant, isNotNull);
    expect(match.matchType, PlantMatchType.exactScientific);
    expect(match.plant!.scientificName, 'Aloe vera');
  });

  test('Lookup does NOT silently fall back to a sibling species (safety)',
      () async {
    // Aloe arborescens is not in the seed DB. Returning Aloe vera would be a
    // safety bug — different Aloe species have different toxicity profiles.
    final match =
        await PlantRepository.instance.lookup('Aloe arborescens');
    expect(match.plant, isNull);
    expect(match.matchType, PlantMatchType.none);
  });

  test('Lookup returns none for unknown species', () async {
    final match = await PlantRepository.instance.lookup('Quercus robur');
    expect(match.plant, isNull);
    expect(match.matchType, PlantMatchType.none);
  });

  test('Lookup matches common name (Hugging Face label)', () async {
    final match = await PlantRepository.instance.lookup('Moringa');
    expect(match.plant, isNotNull);
    expect(match.matchType, PlantMatchType.exactCommonName);
    expect(match.plant!.scientificName, 'Moringa oleifera');
  });

  test('Lookup matches noisy HF labels that contain a full common name',
      () async {
    final match =
        await PlantRepository.instance.lookup('papaya plant leaf');
    expect(match.plant, isNotNull);
    expect(match.matchType, PlantMatchType.extendedExact);
    expect(match.plant!.scientificName, 'Carica papaya');
  });

  test('Lookup matches labels that contain the full binomial', () async {
    final match = await PlantRepository.instance
        .lookup('Moringa oleifera leaf (fresh)');
    expect(match.plant, isNotNull);
    expect(match.matchType, PlantMatchType.extendedExact);
    expect(match.plant!.scientificName, 'Moringa oleifera');
  });
}
