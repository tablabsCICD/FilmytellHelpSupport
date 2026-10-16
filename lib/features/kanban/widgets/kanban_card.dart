import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/sla_badge.dart';
import '../../../core/widgets/delegation_chain_widget.dart';
import '../../../models/support_ticket_model.dart';

class KanbanCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const KanbanCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket # + Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.ticketNumber,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  PriorityBadge(priority: ticket.priority, isSmall: true),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                ticket.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Assignee & Delegation
              DelegationChainWidget(ticket: ticket),
              const SizedBox(height: 8),

              // Team Tag
              Row(
                children: [
                  Icon(Icons.groups_outlined, size: 12, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.team,
                      style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(height: 14, color: colorScheme.outlineVariant),

              // Created date + SLA badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormatter.timeAgo(ticket.createdAt),
                    style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                  ),
                  SlaBadge(
                    createdAt: ticket.createdAt,
                    priority: ticket.priority,
                    status: ticket.status,
                    resolvedAt: ticket.resolvedAt,
                    isSmall: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
