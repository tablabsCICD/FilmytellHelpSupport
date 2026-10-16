import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/sla_badge.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';
import '../dialogs/assign_dialog.dart';
import '../dialogs/delegate_dialog.dart';
import '../dialogs/status_dialog.dart';
import '../dialogs/transfer_ownership_dialog.dart';
import '../../ai_support/dialogs/ai_analysis_dialog.dart';
import '../widgets/delegation_timeline.dart';
import '../widgets/ticket_history_list.dart';
import '../widgets/ticket_conversation_widget.dart';

class TicketDetailsScreen extends StatefulWidget {
  final SupportTicket ticket;
  final VoidCallback onBack;

  const TicketDetailsScreen({
    super.key,
    required this.ticket,
    required this.onBack,
  });

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final colorScheme = Theme.of(context).colorScheme;

    // Find the latest state of this ticket from the provider
    final currentTicket = ticketProvider.allTickets.firstWhere(
      (t) => t.ticketId == widget.ticket.ticketId,
      orElse: () => widget.ticket,
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation & Action Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Back to Tickets'),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Text(
                        currentTicket.ticketNumber,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PriorityBadge(priority: currentTicket.priority),
                    const SizedBox(width: 8),
                    StatusBadge(status: currentTicket.status),
                  ],
                ),

                // Quick Action Buttons
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AiAnalysisDialog(ticket: currentTicket),
                        );
                      },
                      icon: const Icon(Icons.smart_toy_outlined, size: 16, color: AppColors.statusAiAnalysis),
                      label: const Text('AI Analysis', style: TextStyle(color: AppColors.statusAiAnalysis)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AssignDialog(ticket: currentTicket),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: const Text('Assign'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => DelegateDialog(ticket: currentTicket),
                        );
                      },
                      icon: const Icon(Icons.alt_route_rounded, size: 16, color: AppColors.accent),
                      label: const Text('Delegate Task', style: TextStyle(color: AppColors.accent)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => StatusDialog(ticket: currentTicket),
                        );
                      },
                      icon: const Icon(Icons.sync_alt_rounded, size: 16),
                      label: const Text('Status'),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
                      color: colorScheme.surface,
                      onSelected: (action) {
                        if (action == 'priority') {
                          showDialog(context: context, builder: (_) => StatusDialog(ticket: currentTicket, isPriorityChange: true));
                        } else if (action == 'transfer') {
                          showDialog(context: context, builder: (_) => TransferOwnershipDialog(ticket: currentTicket));
                        } else if (action == 'resolve') {
                          ticketProvider.updateTicketStatus(currentTicket.ticketId, AppConstants.statusResolved, currentUser);
                        } else if (action == 'close') {
                          ticketProvider.updateTicketStatus(currentTicket.ticketId, AppConstants.statusClosed, currentUser);
                        } else if (action == 'reopen') {
                          ticketProvider.updateTicketStatus(currentTicket.ticketId, AppConstants.statusInProgress, currentUser, notes: 'Ticket reopened');
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'priority', child: Text('Change Priority')),
                        const PopupMenuItem(value: 'transfer', child: Text('Transfer Ownership')),
                        const PopupMenuDivider(),
                        if (currentTicket.status != AppConstants.statusResolved)
                          const PopupMenuItem(value: 'resolve', child: Text('Mark Resolved', style: TextStyle(color: AppColors.slaOk))),
                        if (currentTicket.status != AppConstants.statusClosed)
                          const PopupMenuItem(value: 'close', child: Text('Close Ticket', style: TextStyle(color: AppColors.statusClosed))),
                        if (currentTicket.status == AppConstants.statusClosed || currentTicket.status == AppConstants.statusResolved)
                          const PopupMenuItem(value: 'reopen', child: Text('Reopen Ticket', style: TextStyle(color: AppColors.statusInProgress))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Top Information Grid: Left = Ticket Info / Right = Support & Delegation Overview
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildTicketInfoCard(context, currentTicket)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildSupportMetaCard(context, currentTicket)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildTicketInfoCard(context, currentTicket),
                      const SizedBox(height: 16),
                      _buildSupportMetaCard(context, currentTicket),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Tabs Header
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                  left: BorderSide(color: colorScheme.outlineVariant),
                  right: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.forum_outlined, size: 18),
                    text: 'Conversations & Notes (${currentTicket.messages.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.alt_route_rounded, size: 18),
                    text: 'Delegation Timeline (${currentTicket.delegations.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.history_edu_rounded, size: 18),
                    text: 'Audit Trail / History (${currentTicket.history.length})',
                  ),
                ],
              ),
            ),

            // Tabs Content
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outlineVariant),
                  left: BorderSide(color: colorScheme.outlineVariant),
                  right: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, child) {
                  switch (_tabController.index) {
                    case 0:
                      return TicketConversationWidget(ticket: currentTicket);
                    case 1:
                      return DelegationTimeline(ticket: currentTicket);
                    case 2:
                    default:
                      return TicketHistoryList(history: currentTicket.history);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfoCard(BuildContext context, SupportTicket ticket) {
    final colorScheme = Theme.of(context).colorScheme;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Ticket Subject & Customer Description',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                ],
              ),
              if (ticket.rating > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${ticket.rating} Star Review',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Customer Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Text(
                  (ticket.customerName != null && ticket.customerName!.trim().isNotEmpty)
                      ? ticket.customerName!.trim()[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.customerName != null && ticket.customerName!.trim().isNotEmpty
                          ? ticket.customerName!
                          : (ticket.userId > 0 ? 'User #${ticket.userId}' : 'Customer'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    if ((ticket.customerEmail != null && ticket.customerEmail!.isNotEmpty) ||
                        (ticket.customerPhone != null && ticket.customerPhone!.isNotEmpty))
                      Text(
                        '${ticket.customerEmail ?? ""}${ticket.customerEmail != null && ticket.customerPhone != null ? " • " : ""}${ticket.customerPhone ?? ""}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          if (ticket.description.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ticket.description,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, height: 1.4),
            ),
          ],
          Divider(height: 24, color: colorScheme.outlineVariant),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ticket.customerName != null && ticket.customerName!.trim().isNotEmpty)
                _buildMetaPill(context, 'Customer', ticket.customerName!),
              if (ticket.userId > 0)
                _buildMetaPill(context, 'User ID', '#${ticket.userId}'),
              if (ticket.contentId > 0)
                _buildMetaPill(context, 'Content ID', '#${ticket.contentId}'),
              if (ticket.externalTicketId != null && ticket.externalTicketId!.isNotEmpty)
                _buildMetaPill(context, 'Admin Ticket ID', '#${ticket.externalTicketId}'),
              _buildMetaPill(context, 'Source Channel', ticket.source),
              _buildMetaPill(context, 'Created', DateFormatter.formatDateTime(ticket.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportMetaCard(BuildContext context, SupportTicket ticket) {
    final colorScheme = Theme.of(context).colorScheme;

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
          Row(
            children: [
              const Icon(Icons.hub_outlined, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Support Routing & Ownership',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (ticket.customerName != null && ticket.customerName!.trim().isNotEmpty) ...[
            _buildInfoRow(context, 'Customer Name', ticket.customerName!),
            Divider(height: 12, color: colorScheme.outlineVariant),
          ],
          if (ticket.customerEmail != null && ticket.customerEmail!.trim().isNotEmpty) ...[
            _buildInfoRow(context, 'Customer Email', ticket.customerEmail!),
            Divider(height: 12, color: colorScheme.outlineVariant),
          ],
          if (ticket.customerPhone != null && ticket.customerPhone!.trim().isNotEmpty) ...[
            _buildInfoRow(context, 'Customer Phone', ticket.customerPhone!),
            Divider(height: 12, color: colorScheme.outlineVariant),
          ],
          _buildInfoRow(context, 'Category', ticket.category),
          Divider(height: 12, color: colorScheme.outlineVariant),
          _buildInfoRow(context, 'Team', ticket.team),
          Divider(height: 12, color: colorScheme.outlineVariant),
          _buildInfoRow(context, 'Ticket Owner', ticket.ticketOwner, isHighlight: true),
          Divider(height: 12, color: colorScheme.outlineVariant),
          _buildInfoRow(context, 'Current Assignee', ticket.currentAssignee, isHighlight: true),
          Divider(height: 12, color: colorScheme.outlineVariant),
          _buildInfoRow(context, 'Delegation Level', 'Level ${ticket.delegationLevel} (${ticket.delegations.length} total tasks)'),
          Divider(height: 12, color: colorScheme.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SLA Target', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              SlaBadge(createdAt: ticket.createdAt, priority: ticket.priority, status: ticket.status, resolvedAt: ticket.resolvedAt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(BuildContext context, String label, String val) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        '$label: $val',
        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String val, {bool isHighlight = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        Text(
          val,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? AppColors.accent : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
