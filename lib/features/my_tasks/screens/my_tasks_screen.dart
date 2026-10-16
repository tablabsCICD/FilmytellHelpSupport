import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/sla_calculator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/sla_badge.dart';
import '../../../core/widgets/delegation_chain_widget.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';

class MyTasksScreen extends StatefulWidget {
  final Function(SupportTicket) onSelectTicket;

  const MyTasksScreen({super.key, required this.onSelectTicket});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  String _taskFilter = 'All'; // All, Direct Assigned, Delegated to Me, Completed, Overdue

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentSession = authProvider.currentSession;
    final currentUserName = currentSession?.name ?? '';
    final currentUserId = currentSession?.userId;
    final colorScheme = Theme.of(context).colorScheme;

    // Find all tasks related to the current user (either primary owner, current assignee, or involved in delegation)
    final userTickets = ticketProvider.allTickets.where((t) {
      final isAssignee = (currentUserName.isNotEmpty && t.currentAssignee == currentUserName) ||
          (currentUserId != null && t.currentAssigneeId == currentUserId);
      final isOwner = (currentUserName.isNotEmpty && t.ticketOwner == currentUserName) ||
          (currentUserId != null && t.ticketOwnerId == currentUserId);
      final isDelegatorOrDelegatee = t.delegations.any((d) =>
          (currentUserName.isNotEmpty && (d.toUserName == currentUserName || d.fromUserName == currentUserName)) ||
          (currentUserId != null && (d.assignedToUserId == currentUserId || d.assignedFromUserId == currentUserId)));

      if (!isAssignee && !isOwner && !isDelegatorOrDelegatee) return false;

      switch (_taskFilter) {
        case 'Direct Assigned':
          return t.currentAssignee == currentUserName && t.delegationLevel == 0;
        case 'Delegated to Me':
          return t.currentAssignee == currentUserName && t.delegationLevel > 0;
        case 'Completed':
          return t.status == AppConstants.statusResolved || t.status == AppConstants.statusClosed;
        case 'Overdue':
          if (t.status == AppConstants.statusResolved || t.status == AppConstants.statusClosed) return false;
          return SlaCalculator.getSlaInfo(t.createdAt, t.priority, t.status).isBreached;
        case 'All':
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Switch Active User Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Active Tasks & Delegations ($currentUserName)',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dedicated workspace for personal workload, delegated action items, and turnaround deadlines',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Viewing as: $currentUserName (${authProvider.currentSession?.role ?? 'Admin'})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Tabs
            Wrap(
              spacing: 8,
              children: ['All', 'Direct Assigned', 'Delegated to Me', 'Completed', 'Overdue'].map((f) {
                final isSelected = _taskFilter == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: isSelected,
                  selectedColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (_) => setState(() => _taskFilter = f),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Content List
            Expanded(
              child: userTickets.isEmpty
                  ? EmptyStateWidget(
                      title: 'No tasks under "$_taskFilter"',
                      message: 'You have no assigned or delegated tasks matching this filter.',
                      icon: Icons.task_alt_outlined,
                    )
                  : ListView.builder(
                      itemCount: userTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = userTickets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              ticketProvider.selectTicket(ticket);
                              widget.onSelectTicket(ticket);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            ticket.ticketNumber,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                          ),
                                          const SizedBox(width: 8),
                                          PriorityBadge(priority: ticket.priority, isSmall: true),
                                          const SizedBox(width: 8),
                                          StatusBadge(status: ticket.status, isSmall: true),
                                        ],
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
                                  const SizedBox(height: 10),
                                  Text(
                                    ticket.title,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ticket.description,
                                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Divider(height: 20, color: colorScheme.outlineVariant),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      DelegationChainWidget(ticket: ticket),
                                      Row(
                                        children: [
                                          if (ticket.delegationLevel > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Delegated by ${ticket.delegatedFrom ?? ticket.ticketOwner}',
                                                style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.arrow_forward_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
