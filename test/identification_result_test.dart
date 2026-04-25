import 'package:flutter_test/flutter_test.dart';

import 'package:african_doctor/models/identification_result.dart';

void main() {
  test('Parses a PlantNet result payload', () {
    final json = <String, dynamic>{
      'score': 0.92,
      'species': {
        'scientificNameWithoutAuthor': 'Moringa oleifera',
        'commonNames': ['Moringa', 'Drumstick tree'],
        'family': {'scientificNameWithoutAuthor': 'Moringaceae'},
        'genus': {'scientificNameWithoutAuthor': 'Moringa'},
      },
    };

    final result = IdentificationResult.fromPlantNetJson(json);

    expect(result.score, 0.92);
    expect(result.scorePercent, 92);
    expect(result.scientificName, 'Moringa oleifera');
    expect(result.commonNames, ['Moringa', 'Drumstick tree']);
    expect(result.family, 'Moringaceae');
    expect(result.genus, 'Moringa');
  });

  test('Falls back to defaults for missing fields', () {
    final result = IdentificationResult.fromPlantNetJson({});
    expect(result.score, 0.0);
    expect(result.scorePercent, 0);
    expect(result.scientificName, 'Unknown');
    expect(result.commonNames, isEmpty);
  });
}
