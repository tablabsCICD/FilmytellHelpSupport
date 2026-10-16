import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/support_ticket_model.dart';
import '../../../models/delegation_model.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';
import '../dialogs/delegate_dialog.dart';

class DelegationTimeline extends StatelessWidget {
  final SupportTicket ticket;

  const DelegationTimeline({super.key, required this.ticket});

  void _showCompleteTaskDialog(BuildContext context, DelegationNode del) {
    final notesController = TextEditingController();
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant)),
        title: Row(
          children: [
            const Icon(Icons.task_alt_rounded, color: AppColors.slaOk, size: 22),
            const SizedBox(width: 10),
            Text('Complete Delegated Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completing Level ${del.delegationLevel} task by ${del.toUserName}. Results will return through the delegation chain back to ${del.fromUserName}.',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text('Resolution / Completion Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: notesController,
              maxLines: 3,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Enter technical findings, patch details, or verification outcome...',
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (notesController.text.trim().isEmpty) return;
              await ticketProvider.completeDelegation(
                ticket.ticketId,
                del.id,
                notesController.text.trim(),
                currentUser,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Delegated task completed by ${del.toUserName}. Handed back to ${del.fromUserName}.'),
                    backgroundColor: AppColors.slaOk,
                  ),
                );
              }
            },
            child: const Text('Complete & Hand Back'),
          ),
        ],
      ),
    );
  }

  void _showReturnTaskDialog(BuildContext context, DelegationNode del) {
    final reasonController = TextEditingController();
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant)),
        title: Row(
          children: [
            const Icon(Icons.reply_rounded, color: AppColors.priorityHigh, size: 22),
            const SizedBox(width: 10),
            Text('Return Task to Delegator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Returning Level ${del.delegationLevel} task back to ${del.fromUserName}. Provide reason or required clarification.',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text('Return Reason / Inquiry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Explain why the task is being returned (e.g. missing logs, wrong team, insufficient info)...',
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.priorityHigh),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              await ticketProvider.returnTask(
                ticket.ticketId,
                del.taskId,
                reasonController.text.trim(),
                currentUser,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task returned to ${del.fromUserName}.'),
                    backgroundColor: AppColors.priorityHigh,
                  ),
                );
              }
            },
            child: const Text('Return Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    if (ticket.delegations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hub_outlined, size: 40, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'No Delegations Active',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Ticket is handled directly by Ticket Owner (${ticket.ticketOwner}).',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DelegateDialog(ticket: ticket),
                  );
                },
                icon: const Icon(Icons.alt_route_rounded, size: 16),
                label: const Text('Delegate First Task (A → B)'),
              ),
            ],
          ),
        ),
      );
    }

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.account_tree_rounded, color: AppColors.accent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Multi-Level Task Hierarchy (${ticket.delegations.length} Nodes)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.onSurface),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DelegateDialog(ticket: ticket),
                  );
                },
                icon: const Icon(Icons.add_road_rounded, size: 14),
                label: Text('Sub-Delegate (L${ticket.delegationLevel + 1})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Owner Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Primary Ticket Owner: ',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  ticket.ticketOwner,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                const Spacer(),
                Text(
                  'Current Active Assignee: ',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket.currentAssignee,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Delegation Chain Visualizer
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ticket.delegations.length,
            separatorBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(left: 20),
              height: 24,
              width: 2,
              color: colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final del = ticket.delegations[index];
              final isCompleted = del.status.toUpperCase() == AppConstants.taskCompleted ||
                  del.status.toLowerCase().contains('completed');
              final isReturned = del.status.toUpperCase() == AppConstants.taskReturned;
              final isPending = del.status.toUpperCase() == AppConstants.taskPending;

              Color nodeColor = AppColors.accent;
              if (isCompleted) {
                nodeColor = AppColors.slaOk;
              } else if (isReturned) {
                nodeColor = AppColors.priorityHigh;
              } else if (isPending) {
                nodeColor = AppColors.slaWarning;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Node Circle
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: nodeColor.withValues(alpha: 0.15),
                          border: Border.all(color: nodeColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            'L${del.delegationLevel}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: nodeColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Content Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCompleted ? colorScheme.surface : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCompleted ? colorScheme.outlineVariant : nodeColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${del.fromUserName} → ${del.toUserName}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: nodeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  del.status.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: nodeColor),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  del.reason,
                                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            del.instructions,
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                          if (del.dueAt != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.timer_outlined, size: 13, color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  'Target Due: ${DateFormatter.formatDateTime(del.dueAt)}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.priorityHigh),
                                ),
                              ],
                            ),
                          ],
                          if (del.completionNotes != null) ...[
                            Divider(height: 16, color: colorScheme.outlineVariant),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.slaOk.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.slaOk.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.slaOk),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Completed (${DateFormatter.timeAgo(del.completedAt)})',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slaOk),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    del.completionNotes!,
                                    style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (del.returnReason != null && del.returnReason!.isNotEmpty) ...[
                            Divider(height: 16, color: colorScheme.outlineVariant),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.priorityHigh.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.priorityHigh.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.priorityHigh),
                                      SizedBox(width: 6),
                                      Text(
                                        'Returned Task',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.priorityHigh),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    del.returnReason!,
                                    style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Delegated: ${DateFormatter.formatDateTime(del.delegatedAt)}',
                                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                              ),
                              if (!isCompleted)
                                Row(
                                  children: [
                                    if (isPending) ...[
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          await ticketProvider.startTask(ticket.ticketId, del.taskId);
                                        },
                                        icon: const Icon(Icons.play_arrow_rounded, size: 14),
                                        label: const Text('Start'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          textStyle: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    OutlinedButton.icon(
                                      onPressed: () => _showReturnTaskDialog(context, del),
                                      icon: const Icon(Icons.reply_rounded, size: 14, color: AppColors.priorityHigh),
                                      label: const Text('Return', style: TextStyle(color: AppColors.priorityHigh)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        textStyle: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _showCompleteTaskDialog(context, del),
                                      icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                                      label: const Text('Complete'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.slaOk,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        textStyle: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
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
