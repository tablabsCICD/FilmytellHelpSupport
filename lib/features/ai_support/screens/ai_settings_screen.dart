import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';

class AiSettingsScreen extends StatelessWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.aiSettings;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistance & Auto-Resolution Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure AI triage, semantic sentiment confidence thresholds, auto-deflection and sensitive issue human escalation guardrails',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Master Switches
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Enable AI Ticket Triage & Intent Analysis', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    subtitle: Text('Automatically extract intent, suggest team assignment & assign priority for incoming reviews', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    value: settings.aiEnabled,
                    activeThumbColor: AppColors.statusAiAnalysis,
                    onChanged: (val) {
                      settingsProvider.updateAiSettings(settings.copyWith(aiEnabled: val));
                    },
                  ),
                  Divider(height: 20, color: colorScheme.outlineVariant),
                  SwitchListTile(
                    title: Text('Enable AI Auto-Resolution for FAQs', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    subtitle: Text('Directly respond to eligible low-risk how-to issues without waiting for human agent queue', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    value: settings.autoResolutionEnabled,
                    activeThumbColor: AppColors.statusAiAnalysis,
                    onChanged: (val) {
                      settingsProvider.updateAiSettings(settings.copyWith(autoResolutionEnabled: val));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Confidence Threshold Slider
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Minimum Confidence Threshold for Auto-Action',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.statusAiAnalysis.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(settings.confidenceThreshold * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.statusAiAnalysis, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Issues with semantic confidence below this target are automatically routed to human Support or Technical staff.',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: settings.confidenceThreshold,
                    min: 0.50,
                    max: 0.99,
                    divisions: 49,
                    activeColor: AppColors.statusAiAnalysis,
                    onChanged: (val) {
                      settingsProvider.updateAiSettings(settings.copyWith(confidenceThreshold: val));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Eligible Categories & Sensitive Escalation Guardrails
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eligible Categories for Auto-Response',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'FAQ',
                      'Login & Navigation',
                      'Playback & Buffering Guides',
                      'Known Error Code 6003',
                      'Feature Usage & Offline Downloads',
                    ].map((cat) {
                      return Chip(
                        label: Text(cat, style: TextStyle(fontSize: 12, color: colorScheme.onSurface)),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: const BorderSide(color: AppColors.statusAiAnalysis),
                        avatar: const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.statusAiAnalysis),
                      );
                    }).toList(),
                  ),
                  Divider(height: 24, color: colorScheme.outlineVariant),
                  const Text(
                    'Safety Guardrails: Strictly Human Escalated Categories',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.priorityUrgent),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sensitive topics such as duplicate payment deductions, refund demands, account ownership disputes, security leaks and legal notices are NEVER auto-closed and require authorized staff review.',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
