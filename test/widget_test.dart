import 'package:flutter_test/flutter_test.dart';
import 'package:shiftat/main.dart';
import 'package:shiftat/features/onboarding/screens/splash_screen.dart';

void main() {
  testWidgets('Smoke test — boots to Splash Screen', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const ShiftatApp());
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });
}
