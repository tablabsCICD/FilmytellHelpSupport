import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';
import '../core/theme/app_theme_controller.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  final AppThemeController themeController;

  AISettings _aiSettings = AISettings();
  bool _isLoading = false;

  SettingsProvider({
    SettingsRepository? repository,
    AppThemeController? themeController,
  })  : _repository = repository ?? SettingsRepository(),
        themeController = themeController ?? AppThemeController() {
    this.themeController.addListener(_onThemeChanged);
    loadSettings();
  }

  void _onThemeChanged() {
    notifyListeners();
  }

  AISettings get aiSettings => _aiSettings;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => themeController.themeMode;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _aiSettings = await _repository.getAiSettings();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAiSettings(AISettings newSettings) async {
    _aiSettings = newSettings;
    notifyListeners();
    await _repository.saveAiSettings(newSettings);
  }

  void setThemeMode(ThemeMode mode) {
    themeController.setThemeMode(mode);
  }

  void toggleTheme() {
    themeController.toggleTheme();
  }

  @override
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }
}
