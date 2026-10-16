import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/support_ticket_model.dart';
import 'kanban_card.dart';

class KanbanColumn extends StatelessWidget {
  final String status;
  final List<SupportTicket> tickets;
  final Function(SupportTicket, String) onTicketDropped;
  final Function(SupportTicket) onTicketTap;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tickets,
    required this.onTicketDropped,
    required this.onTicketTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusStyle = AppTheme.getStatusStyle(context, status);
    final colorScheme = Theme.of(context).colorScheme;

    return DragTarget<SupportTicket>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onTicketDropped(details.data, status),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isHovered ? statusStyle.background : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered ? statusStyle.dotColor : colorScheme.outlineVariant,
              width: isHovered ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: statusStyle.dotColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusStyle.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: statusStyle.border),
                      ),
                      child: Text(
                        '${tickets.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusStyle.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cards List
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Text(
                          isHovered ? 'Drop ticket here' : 'No tickets',
                          style: TextStyle(
                            fontSize: 12,
                            color: isHovered ? statusStyle.foreground : colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];

                          return Draggable<SupportTicket>(
                            data: ticket,
                            feedback: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.transparent,
                              child: Container(
                                width: 280,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: KanbanCard(
                                  ticket: ticket,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: KanbanCard(
                                ticket: ticket,
                                onTap: () {},
                              ),
                            ),
                            child: KanbanCard(
                              ticket: ticket,
                              onTap: () => onTicketTap(ticket),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
