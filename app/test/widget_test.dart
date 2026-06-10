import 'package:flutter_test/flutter_test.dart';
import 'package:farodeck_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows Farodeck auth screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FarodeckApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('FARODECK'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
