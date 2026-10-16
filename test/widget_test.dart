import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmytell_help_support/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads and displays Filmytell brand on login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FilmytellSupportApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('FILMYTELL'), findsWidgets);
    expect(find.text('Sign In to Dashboard'), findsOneWidget);
  });
}
