class AiAnalysisResult {
  final String category;
  final String subCategory;
  final String intent;
  final String suggestedPriority;
  final String suggestedTeam;
  final double confidence; // e.g. 0.92 = 92%
  final String suggestedSolution;
  final bool canAutoResolve;
  final bool isSensitive;
  final String? sensitivityReason;

  AiAnalysisResult({
    required this.category,
    required this.subCategory,
    required this.intent,
    required this.suggestedPriority,
    required this.suggestedTeam,
    required this.confidence,
    required this.suggestedSolution,
    required this.canAutoResolve,
    this.isSensitive = false,
    this.sensitivityReason,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResult(
      category: json['category']?.toString() ?? 'General',
      subCategory: json['subCategory']?.toString() ?? 'General Query',
      intent: json['intent']?.toString() ?? 'Support assistance',
      suggestedPriority: json['suggestedPriority']?.toString() ?? 'MEDIUM',
      suggestedTeam: json['suggestedTeam']?.toString() ?? 'Support Team',
      confidence: json['confidence'] is num ? (json['confidence'] as num).toDouble() : double.tryParse(json['confidence']?.toString() ?? '0.85') ?? 0.85,
      suggestedSolution: json['suggestedSolution']?.toString() ?? '',
      canAutoResolve: json['canAutoResolve'] == true,
      isSensitive: json['isSensitive'] == true,
      sensitivityReason: json['sensitivityReason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'subCategory': subCategory,
      'intent': intent,
      'suggestedPriority': suggestedPriority,
      'suggestedTeam': suggestedTeam,
      'confidence': confidence,
      'suggestedSolution': suggestedSolution,
      'canAutoResolve': canAutoResolve,
      'isSensitive': isSensitive,
      'sensitivityReason': sensitivityReason,
    };
  }
}
