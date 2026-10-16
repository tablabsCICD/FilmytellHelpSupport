import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/priority_helper.dart';
import '../../../providers/reports_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<ReportsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics, SLA & Operations Reports',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Key performance indicators for SLA compliance, delegation depth, turnaround time & AI deflection',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top KPI Metrics
            LayoutBuilder(
              builder: (context, constraints) {
                final count = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: count,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildKpiCard(
                      context,
                      'SLA COMPLIANCE',
                      '${reportsProvider.slaComplianceRate.toStringAsFixed(1)}%',
                      Icons.verified_outlined,
                      AppColors.slaOk,
                      'Target benchmark: 90%',
                    ),
                    _buildKpiCard(
                      context,
                      'AVG TURNAROUND',
                      '${reportsProvider.averageTurnaroundHours}h',
                      Icons.av_timer_outlined,
                      AppColors.accent,
                      'Median resolution speed',
                    ),
                    _buildKpiCard(
                      context,
                      'DELEGATION EVENTS',
                      '${reportsProvider.totalDelegationEvents}',
                      Icons.account_tree_outlined,
                      AppColors.statusInProgress,
                      '${reportsProvider.totalDelegatedTickets} tickets escalated',
                    ),
                    _buildKpiCard(
                      context,
                      'AI DEFLECTION RATE',
                      '${reportsProvider.aiResolutionRate.toStringAsFixed(1)}%',
                      Icons.smart_toy_outlined,
                      AppColors.statusAiAnalysis,
                      'Assisted & auto-resolved',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Middle Charts Section: Status Distribution + Priority Breakdown
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 850) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildStatusDistributionCard(context, reportsProvider)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPriorityDistributionCard(context, reportsProvider)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildStatusDistributionCard(context, reportsProvider),
                      const SizedBox(height: 16),
                      _buildPriorityDistributionCard(context, reportsProvider),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Delegation Depth & Team Load Breakdown
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 850) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDelegationDepthCard(context, reportsProvider)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTeamWorkloadCard(context, reportsProvider)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDelegationDepthCard(context, reportsProvider),
                      const SizedBox(height: 16),
                      _buildTeamWorkloadCard(context, reportsProvider),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String val, IconData icon, Color color, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildStatusDistributionCard(BuildContext context, ReportsProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusMap = provider.statusDistribution;
    final total = statusMap.values.fold(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ticket Volume by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          ...statusMap.entries.map((entry) {
            final statusStyle = AppTheme.getStatusStyle(context, entry.key);
            final color = statusStyle.dotColor;
            final percent = total > 0 ? entry.value / total : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(entry.key, style: TextStyle(fontSize: 12, color: colorScheme.onSurface)),
                        ],
                      ),
                      Text('${entry.value} (${(percent * 100).toInt()}%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriorityDistributionCard(BuildContext context, ReportsProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityMap = provider.priorityDistribution;
    final total = priorityMap.values.fold(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ticket Distribution by Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          ...priorityMap.entries.map((entry) {
            final priorityStyle = AppTheme.getPriorityStyle(context, entry.key);
            final color = priorityStyle.color;
            final percent = total > 0 ? entry.value / total : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(PriorityHelper.getPriorityIcon(entry.key), size: 14, color: color),
                          const SizedBox(width: 8),
                          Text(entry.key, style: TextStyle(fontSize: 12, color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text('${entry.value} tickets (${(percent * 100).toInt()}%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDelegationDepthCard(BuildContext context, ReportsProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final depthMap = provider.delegationDepthDistribution;
    final total = depthMap.values.fold(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delegation Chain Depth (A → B → C)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          ...depthMap.entries.map((entry) {
            final percent = total > 0 ? entry.value / total : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: TextStyle(fontSize: 12, color: colorScheme.onSurface)),
                      Text('${entry.value} (${(percent * 100).toInt()}%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: colorScheme.outlineVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTeamWorkloadCard(BuildContext context, ReportsProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final teamMap = provider.teamDistribution;
    final total = teamMap.values.fold(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Volume Split: Support vs Tech Desks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          ...teamMap.entries.map((entry) {
            final isTech = entry.key == AppConstants.teamTechnical;
            final color = isTech ? AppColors.teamTech : AppColors.teamSupport;
            final percent = total > 0 ? entry.value / total : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: TextStyle(fontSize: 12, color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                      Text('${entry.value} (${(percent * 100).toInt()}%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
