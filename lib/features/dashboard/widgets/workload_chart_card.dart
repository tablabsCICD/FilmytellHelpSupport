import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/team_member_model.dart';

class WorkloadChartCard extends StatelessWidget {
  final List<TeamMember> teamMembers;

  const WorkloadChartCard({
    super.key,
    required this.teamMembers,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Team Workload & Capacity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '${teamMembers.where((m) => m.isAvailable).length} Active Staff',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teamMembers.take(5).length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = teamMembers[index];
              final workload = member.workloadPercentage;
              Color barColor = AppColors.slaOk;
              if (workload > 75) {
                barColor = AppColors.priorityUrgent;
              } else if (workload > 50) {
                barColor = AppColors.priorityMedium;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            member.name,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${member.team == 'Support Team' ? 'Support' : 'Tech'})',
                            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Text(
                        '${member.activeTicketsCount} tickets (${workload.toInt()}%)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (workload / 100).clamp(0.05, 1.0),
                      backgroundColor: colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
