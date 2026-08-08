import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kickluck_mvp/features/generator/presentation/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home loads mock fixtures and enables Generate after selection',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen()),
    );

    expect(find.text('KICKLUCK'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Arsenal vs Chelsea'), findsOneWidget);
    expect(find.text('GENERATE'), findsOneWidget);

    await tester.tap(find.text('Arsenal vs Chelsea'));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'GENERATE'),
    );
    expect(button.onPressed, isNotNull);
  });
}
