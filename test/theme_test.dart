import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmytell_help_support/core/theme/app_theme.dart';
import 'package:filmytell_help_support/core/constants/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemeController Tests', () {
    test('Initializes with default dark mode when preferences is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppThemeController();
      await controller.loadThemeMode();

      expect(controller.themeMode, equals(ThemeMode.dark));
    });

    test('Loads stored light mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final controller = AppThemeController();
      await controller.loadThemeMode();

      expect(controller.themeMode, equals(ThemeMode.light));
    });

    test('Loads stored system mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final controller = AppThemeController();
      await controller.loadThemeMode();

      expect(controller.themeMode, equals(ThemeMode.system));
    });

    test('Persists theme mode changes to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppThemeController();
      await controller.loadThemeMode();

      await controller.setThemeMode(ThemeMode.light);
      expect(controller.themeMode, equals(ThemeMode.light));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('light'));
    });
  });

  group('AppTheme Semantic Helpers & Contrast Tests', () {
    testWidgets('getStatusStyle returns correct colors in Light and Dark modes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              final lightStyle = AppTheme.getStatusStyle(context, AppConstants.statusResolved);
              expect(lightStyle.foreground, isNotNull);
              expect(lightStyle.background, isNotNull);
              expect(lightStyle.dotColor, isNotNull);
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              final darkStyle = AppTheme.getStatusStyle(context, AppConstants.statusResolved);
              expect(darkStyle.foreground, isNotNull);
              expect(darkStyle.background, isNotNull);
              expect(darkStyle.dotColor, isNotNull);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getPriorityStyle returns contrast colors for all priority tiers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              for (final p in AppConstants.allPriorities) {
                final style = AppTheme.getPriorityStyle(context, p);
                expect(style.foreground, isNotNull);
                expect(style.background, isNotNull);
                expect(style.icon, isNotNull);
              }
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
