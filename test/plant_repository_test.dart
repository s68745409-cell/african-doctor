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
    final p = await PlantRepository.instance.lookup('Moringa oleifera');
    expect(p, isNotNull);
    expect(p!.commonNames.first, 'Moringa');
  });

  test('Lookup is case insensitive', () async {
    final p =
        await PlantRepository.instance.lookup('aloe vera');
    expect(p, isNotNull);
    expect(p!.scientificName, 'Aloe vera');
  });

  test('Lookup falls back to genus match', () async {
    final p =
        await PlantRepository.instance.lookup('Aloe arborescens');
    expect(p, isNotNull);
    expect(p!.scientificName.startsWith('Aloe'), isTrue);
  });

  test('Lookup returns null for unknown species', () async {
    final p = await PlantRepository.instance.lookup('Quercus robur');
    expect(p, isNull);
  });
}
