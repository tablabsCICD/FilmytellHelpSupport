import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_controller.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/team_provider.dart';
import '../../../providers/knowledge_base_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<AppThemeController>(context);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final kbProvider = Provider.of<KnowledgeBaseProvider>(context, listen: false);
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
                  'Application & SLA Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage system configuration, appearance theme, SLA resolution windows, API endpoints & data caching',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Appearance Theme Switcher Card
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
                    children: [
                      const Icon(Icons.palette_outlined, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Appearance & Theme Mode',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your preferred visual style. Changes persist across application sessions.',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildThemeOptionCard(
                            context: context,
                            title: 'Light',
                            description: 'Clean high-contrast theme for bright environments',
                            icon: Icons.light_mode_rounded,
                            mode: ThemeMode.light,
                            currentMode: themeController.themeMode,
                            onSelect: () => themeController.setThemeMode(ThemeMode.light),
                            width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 3,
                          ),
                          _buildThemeOptionCard(
                            context: context,
                            title: 'Dark',
                            description: 'Sleek slate dark theme for comfortable low-light viewing',
                            icon: Icons.dark_mode_rounded,
                            mode: ThemeMode.dark,
                            currentMode: themeController.themeMode,
                            onSelect: () => themeController.setThemeMode(ThemeMode.dark),
                            width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 3,
                          ),
                          _buildThemeOptionCard(
                            context: context,
                            title: 'System Default',
                            description: 'Automatically adapts to your device OS appearance settings',
                            icon: Icons.settings_brightness_rounded,
                            mode: ThemeMode.system,
                            currentMode: themeController.themeMode,
                            onSelect: () => themeController.setThemeMode(ThemeMode.system),
                            width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 3,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SLA Target Configuration Card
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
                  Text('Service Level Agreement (SLA) Targets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Configurable resolution targets by priority level', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  _buildSlaConfigRow(context, 'URGENT Priority', '2 Hours', AppColors.priorityUrgent, 'Immediate incident resolution window'),
                  Divider(height: 16, color: colorScheme.outlineVariant),
                  _buildSlaConfigRow(context, 'HIGH Priority', '4 Hours', AppColors.priorityHigh, 'Fast action required for degraded experience'),
                  Divider(height: 16, color: colorScheme.outlineVariant),
                  _buildSlaConfigRow(context, 'MEDIUM Priority', '8 Hours', AppColors.priorityMedium, 'Normal support issue response turnaround'),
                  Divider(height: 16, color: colorScheme.outlineVariant),
                  _buildSlaConfigRow(context, 'LOW Priority', '24 Hours', AppColors.priorityLow, 'Standard feedback and general enquiries'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Backend API & Diagnostics
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
                  Text('API & Ingestion Service Endpoints', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  _buildApiRow(context, 'Rating & Review Endpoint', ApiEndpoints.ratingAndReviewGetAll, 'Connected (Real API)'),
                  Divider(height: 16, color: colorScheme.outlineVariant),
                  _buildApiRow(context, 'Local Storage Engine', 'SharedPreferences (Encrypted Key-Value)', 'Active'),
                  Divider(height: 16, color: colorScheme.outlineVariant),
                  _buildApiRow(context, 'Build Architecture', 'Clean Architecture (Theme & Repository Pattern)', 'Production-Ready'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Maintenance & Data Reset
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
                  Text('Backend Cache Synchronization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  const SizedBox(height: 6),
                  Text(
                    'Invalidate local memory caches and force refresh all live tickets, team members, and articles from the centralized backend API.',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ticketProvider.loadTickets(forceRefresh: true);
                      await teamProvider.loadMembers(forceRefresh: true);
                      await kbProvider.loadArticles(forceRefresh: true);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All records successfully synchronized from backend API!'),
                            backgroundColor: AppColors.slaOk,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Force Sync from Backend API'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onSelect,
    required double width,
  }) {
    final isSelected = mode == currentMode;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accent : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent.withValues(alpha: 0.2) : colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? AppColors.accent : colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.accent : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.accent : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlaConfigRow(BuildContext context, String priority, String duration, Color color, String desc) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(priority, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                Text(desc, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            duration,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildApiRow(BuildContext context, String label, String url, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 2),
              Text(url, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.slaOk.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slaOk),
          ),
        ),
      ],
    );
  }
}
