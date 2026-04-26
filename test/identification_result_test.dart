import 'package:flutter_test/flutter_test.dart';

import 'package:african_doctor/models/identification_result.dart';

void main() {
  group('Hugging Face', () {
    test('Parses a Hugging Face image-classification item', () {
      final json = <String, dynamic>{
        'label': 'Moringa',
        'score': 0.87,
      };

      final result = IdentificationResult.fromHuggingFaceJson(json);

      expect(result.score, 0.87);
      expect(result.scorePercent, 87);
      expect(result.scientificName, 'Moringa');
      expect(result.commonNames, ['Moringa']);
    });

    test('Falls back to Unknown for a minimal HF payload', () {
      final result =
          IdentificationResult.fromHuggingFaceJson(<String, dynamic>{});
      expect(result.score, 0.0);
      expect(result.scientificName, 'Unknown');
    });
  });

  group('Plant.id', () {
    test('Parses a Plant.id v3 suggestion', () {
      final json = <String, dynamic>{
        'name': 'Moringa oleifera',
        'probability': 0.92,
        'details': {
          'common_names': ['Moringa', 'Drumstick tree'],
          'taxonomy': {
            'family': 'Moringaceae',
            'genus': 'Moringa',
          },
        },
      };

      final result = IdentificationResult.fromPlantIdJson(json);

      expect(result.score, 0.92);
      expect(result.scorePercent, 92);
      expect(result.scientificName, 'Moringa oleifera');
      expect(result.commonNames, ['Moringa', 'Drumstick tree']);
      expect(result.family, 'Moringaceae');
      expect(result.genus, 'Moringa');
    });
  });

  group('Pl@ntNet (legacy)', () {
    test('Parses a Pl@ntNet result payload', () {
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
      expect(result.scientificName, 'Moringa oleifera');
      expect(result.family, 'Moringaceae');
      expect(result.genus, 'Moringa');
    });
  });
}
