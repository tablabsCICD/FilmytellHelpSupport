import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/kanban_provider.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/kanban_column.dart';

class KanbanScreen extends StatelessWidget {
  final Function(SupportTicket) onSelectTicket;

  const KanbanScreen({
    super.key,
    required this.onSelectTicket,
  });

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final kanbanProvider = Provider.of<KanbanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar & Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Kanban Board',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Drag & drop tickets across 8 stages to trigger audit history & lifecycle transitions',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),

                // Kanban Quick Filters
                Row(
                  children: [
                    // Team Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: kanbanProvider.teamFilter ?? 'All Teams',
                          dropdownColor: colorScheme.surface,
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                          items: ['All Teams', ...AppConstants.allTeams]
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (val) {
                            kanbanProvider.setTeamFilter(val == 'All Teams' ? null : val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Priority Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: kanbanProvider.priorityFilter ?? 'All Priorities',
                          dropdownColor: colorScheme.surface,
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                          items: ['All Priorities', ...AppConstants.allPriorities]
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (val) {
                            kanbanProvider.setPriorityFilter(val == 'All Priorities' ? null : val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Horizontal Scrollable Kanban Columns
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.allStatuses.length,
                itemBuilder: (context, index) {
                  final status = AppConstants.allStatuses[index];
                  final columnTickets = kanbanProvider.getTicketsForColumn(status);

                  return KanbanColumn(
                    status: status,
                    tickets: columnTickets,
                    onTicketTap: (ticket) {
                      ticketProvider.selectTicket(ticket);
                      onSelectTicket(ticket);
                    },
                    onTicketDropped: (ticket, targetStatus) async {
                      final success = await kanbanProvider.moveTicket(ticket, targetStatus, currentUser);
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${ticket.ticketNumber} moved to ${AppConstants.statusTitle(targetStatus)}'),
                              backgroundColor: AppColors.slaOk,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(kanbanProvider.errorMessage ?? 'Status transition not allowed'),
                              backgroundColor: AppColors.slaBreached,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
