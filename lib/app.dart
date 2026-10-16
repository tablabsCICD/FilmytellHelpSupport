import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/kanban_provider.dart';
import 'providers/team_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/knowledge_base_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/settings_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/main_shell_screen.dart';

class FilmytellSupportApp extends StatelessWidget {
  const FilmytellSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppThemeController()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProxyProvider<TicketProvider, KanbanProvider>(
          create: (context) => KanbanProvider(Provider.of<TicketProvider>(context, listen: false)),
          update: (context, ticketProvider, previous) => previous ?? KanbanProvider(ticketProvider),
        ),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProxyProvider<TicketProvider, ReportsProvider>(
          create: (context) => ReportsProvider(Provider.of<TicketProvider>(context, listen: false)),
          update: (context, ticketProvider, previous) => previous ?? ReportsProvider(ticketProvider),
        ),
        ChangeNotifierProvider(create: (_) => KnowledgeBaseProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..loadNotifications()),
        ChangeNotifierProxyProvider<AppThemeController, SettingsProvider>(
          create: (context) => SettingsProvider(
            themeController: Provider.of<AppThemeController>(context, listen: false),
          ),
          update: (context, themeCtrl, previous) => previous ?? SettingsProvider(themeController: themeCtrl),
        ),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isLoading) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (authProvider.isAuthenticated) {
                  return const MainShellScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
