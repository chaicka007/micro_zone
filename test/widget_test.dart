import 'package:flutter_test/flutter_test.dart';
import 'package:micro_zone/app/app.dart';

void main() {
  testWidgets('App smoke test — LoginScreen renders', (tester) async {
    await tester.pumpWidget(const MicroZoneApp());
    expect(find.text('MicroZone'), findsOneWidget);
  });
}
