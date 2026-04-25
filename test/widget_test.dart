import 'package:flutter_test/flutter_test.dart';

import 'package:african_doctor/main.dart';

void main() {
  testWidgets('Disclaimer screen renders on first launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AfricanDoctorApp(showDisclaimer: true));
    await tester.pumpAndSettle();
    expect(find.text('African Doctor'), findsOneWidget);
    expect(find.text('I understand — continue'), findsOneWidget);
  });

  testWidgets('Home screen renders when disclaimer already accepted',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AfricanDoctorApp(showDisclaimer: false));
    await tester.pumpAndSettle();
    expect(find.text('Capture a leaf or tree'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
  });
}
