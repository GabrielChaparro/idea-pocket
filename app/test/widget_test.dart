import 'package:flutter_test/flutter_test.dart';
import 'package:ideapocket_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows IdeaPocket auth screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const IdeaPocketApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('IDEAPOCKET'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
