import '../core/constants/app_constants.dart';
import '../services/storage_service.dart';

class AISettings {
  final bool aiEnabled;
  final bool autoResolutionEnabled;
  final double confidenceThreshold; // 0.0 to 1.0 (e.g. 0.85)
  final List<String> eligibleCategories;
  final bool escalateSensitiveIssues;

  AISettings({
    this.aiEnabled = true,
    this.autoResolutionEnabled = true,
    this.confidenceThreshold = 0.85,
    this.eligibleCategories = const [
      'FAQ',
      'Login/Navigation',
      'Playback & Buffering',
      'Known Error Messages',
      'Feature Usage / How-to',
    ],
    this.escalateSensitiveIssues = true,
  });

  AISettings copyWith({
    bool? aiEnabled,
    bool? autoResolutionEnabled,
    double? confidenceThreshold,
    List<String>? eligibleCategories,
    bool? escalateSensitiveIssues,
  }) {
    return AISettings(
      aiEnabled: aiEnabled ?? this.aiEnabled,
      autoResolutionEnabled: autoResolutionEnabled ?? this.autoResolutionEnabled,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      eligibleCategories: eligibleCategories ?? this.eligibleCategories,
      escalateSensitiveIssues: escalateSensitiveIssues ?? this.escalateSensitiveIssues,
    );
  }

  factory AISettings.fromJson(Map<String, dynamic> json) {
    return AISettings(
      aiEnabled: json['aiEnabled'] != false,
      autoResolutionEnabled: json['autoResolutionEnabled'] != false,
      confidenceThreshold: json['confidenceThreshold'] is num
          ? (json['confidenceThreshold'] as num).toDouble()
          : 0.85,
      eligibleCategories: (json['eligibleCategories'] as List?)?.map((e) => e.toString()).toList() ??
          [
            'FAQ',
            'Login/Navigation',
            'Playback & Buffering',
            'Known Error Messages',
            'Feature Usage / How-to',
          ],
      escalateSensitiveIssues: json['escalateSensitiveIssues'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiEnabled': aiEnabled,
      'autoResolutionEnabled': autoResolutionEnabled,
      'confidenceThreshold': confidenceThreshold,
      'eligibleCategories': eligibleCategories,
      'escalateSensitiveIssues': escalateSensitiveIssues,
    };
  }
}

class SettingsRepository {
  final StorageService _storageService;

  SettingsRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  Future<AISettings> getAiSettings() async {
    await _storageService.init();
    final json = _storageService.getJson(AppConstants.keyAiSettings);
    if (json != null && json is Map<String, dynamic>) {
      return AISettings.fromJson(json);
    }
    return AISettings();
  }

  Future<void> saveAiSettings(AISettings settings) async {
    await _storageService.setJson(AppConstants.keyAiSettings, settings.toJson());
  }
}
