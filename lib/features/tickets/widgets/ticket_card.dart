import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/sla_badge.dart';
import '../../../core/widgets/delegation_chain_widget.dart';
import '../../../models/support_ticket_model.dart';

class TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Ticket #, Source, Priority & Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Text(
                          ticket.ticketNumber,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ticket.source,
                          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                      if (ticket.rating > 0) ...[
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${ticket.rating}/5',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      PriorityBadge(priority: ticket.priority, isSmall: true),
                      const SizedBox(width: 8),
                      StatusBadge(status: ticket.status, isSmall: true),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Description Preview
              Text(
                ticket.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Meta row: User ID, Content ID, Team
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 13, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(
                    'User: ${ticket.userId}',
                    style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.movie_outlined, size: 13, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(
                    'Content: ${ticket.contentId}',
                    style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.groups_outlined, size: 13, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(
                    ticket.team,
                    style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Divider(height: 20, color: colorScheme.outlineVariant),

              // Bottom Footer: Delegation Chain + Date & SLA Countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DelegationChainWidget(ticket: ticket),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Text(
                        DateFormatter.formatDateOnly(ticket.createdAt),
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}
