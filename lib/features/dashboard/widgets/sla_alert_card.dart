import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/sla_calculator.dart';
import '../../../models/support_ticket_model.dart';
import '../../../core/widgets/priority_badge.dart';

class SlaAlertCard extends StatelessWidget {
  final List<SupportTicket> breachedOrWarningTickets;
  final Function(SupportTicket) onTicketTap;

  const SlaAlertCard({
    super.key,
    required this.breachedOrWarningTickets,
    required this.onTicketTap,
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.priorityUrgent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.priorityUrgent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SLA Alerts & Breaches',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.priorityUrgent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${breachedOrWarningTickets.length} Action Needed',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.priorityUrgent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (breachedOrWarningTickets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.slaOk, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'All tickets within safe SLA targets!',
                      style: TextStyle(color: AppColors.slaOk, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breachedOrWarningTickets.take(4).length,
              separatorBuilder: (c, i) => Divider(height: 12, color: colorScheme.outlineVariant),
              itemBuilder: (context, index) {
                final ticket = breachedOrWarningTickets[index];
                final slaInfo = SlaCalculator.getSlaInfo(ticket.createdAt, ticket.priority, ticket.status);

                return InkWell(
                  onTap: () => onTicketTap(ticket),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: slaInfo.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    ticket.ticketNumber,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PriorityBadge(priority: ticket.priority, isSmall: true),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ticket.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              slaInfo.remainingText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: slaInfo.color,
                              ),
                            ),
                            Text(
                              'Assignee: ${ticket.currentAssignee}',
                              style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
