import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/sla_calculator.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/delegation_chain_widget.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/team_provider.dart';
import '../../../providers/reports_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/sla_alert_card.dart';
import '../widgets/workload_chart_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  final Function(SupportTicket) onSelectTicket;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
    required this.onSelectTicket,
  });

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final teamProvider = Provider.of<TeamProvider>(context);
    final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    if (ticketProvider.isLoading && ticketProvider.allTickets.isEmpty) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              LoadingShimmer(height: 120),
              SizedBox(height: 16),
              LoadingShimmer(height: 200),
            ],
          ),
        ),
      );
    }

    final breachedOrWarningTickets = ticketProvider.allTickets.where((t) {
      if (t.status == AppConstants.statusResolved ||
          t.status == AppConstants.statusClosed) {
        return false;
      }
      final sla = SlaCalculator.getSlaInfo(t.createdAt, t.priority, t.status);
      return sla.isBreached || sla.status == SlaStatus.warning;
    }).toList();

    final recentTickets = ticketProvider.allTickets.take(6).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ticketProvider.loadTickets(forceRefresh: true);
          await teamProvider.loadMembers(forceRefresh: true);
          await reportsProvider.loadServerSummary();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Operations Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Centralized overview of tickets, SLA health, team capacity & delegation pipeline',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => onNavigateTab(2), // Kanban
                        icon: const Icon(Icons.view_kanban_outlined, size: 16),
                        label: const Text('Open Kanban'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => onNavigateTab(1), // All Tickets
                        icon: const Icon(Icons.list_alt_rounded, size: 16),
                        label: const Text('View All Tickets'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Metric Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200
                      ? 4
                      : (constraints.maxWidth > 700 ? 4 : 2);

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: constraints.maxWidth > 1200
                        ? 2.4
                        : (constraints.maxWidth > 700 ? 2.2 : 2.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      MetricCard(
                        title: 'TOTAL TICKETS',
                        count: (reportsProvider.serverSummary?.totalTickets ?? ticketProvider.totalTicketsCount).toString(),
                        icon: Icons.confirmation_number_outlined,
                        color: AppColors.accent,
                        subtitle: 'Centralized API Pipeline',
                        onTap: () => onNavigateTab(1),
                      ),
                      MetricCard(
                        title: 'NEW TICKETS',
                        count: (reportsProvider.serverSummary?.ticketsByStatus['NEW'] ?? ticketProvider.newTicketsCount).toString(),
                        icon: Icons.mark_email_unread_outlined,
                        color: AppColors.statusNew,
                        subtitle: 'Awaiting initial review',
                        onTap: () {
                          ticketProvider.setFilterStatus(
                            AppConstants.statusNew,
                          );
                          onNavigateTab(1);
                        },
                      ),
                      MetricCard(
                        title: 'IN PROGRESS',
                        count: (reportsProvider.serverSummary?.ticketsByStatus['IN_PROGRESS'] ?? ticketProvider.inProgressCount).toString(),
                        icon: Icons.cached_rounded,
                        color: AppColors.statusInProgress,
                        subtitle: 'Active staff & delegation tasks',
                        onTap: () {
                          ticketProvider.setFilterStatus(
                            AppConstants.statusInProgress,
                          );
                          onNavigateTab(1);
                        },
                      ),
                      MetricCard(
                        title: 'URGENT PRIORITY',
                        count: (reportsProvider.serverSummary?.ticketsByPriority['URGENT'] ?? ticketProvider.urgentCount).toString(),
                        icon: Icons.emergency_rounded,
                        color: AppColors.priorityUrgent,
                        subtitle: 'Critical attention required',
                        onTap: () {
                          ticketProvider.setFilterPriority(
                            AppConstants.priorityUrgent,
                          );
                          onNavigateTab(1);
                        },
                      ),
                      MetricCard(
                        title: 'PENDING USER',
                        count: (reportsProvider.serverSummary?.ticketsByStatus['PENDING_USER'] ?? ticketProvider.pendingUserCount).toString(),
                        icon: Icons.hourglass_top_rounded,
                        color: AppColors.statusPendingUser,
                        subtitle: 'Waiting on user reply / OTP',
                        onTap: () {
                          ticketProvider.setFilterStatus(
                            AppConstants.statusPendingUser,
                          );
                          onNavigateTab(1);
                        },
                      ),
                      MetricCard(
                        title: 'RESOLVED',
                        count: (reportsProvider.serverSummary?.ticketsByStatus['RESOLVED'] ?? ticketProvider.resolvedCount).toString(),
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.statusResolved,
                        subtitle: 'Completed successfully',
                        onTap: () {
                          ticketProvider.setFilterStatus(
                            AppConstants.statusResolved,
                          );
                          onNavigateTab(1);
                        },
                      ),
                      MetricCard(
                        title: 'SLA BREACHES',
                        count: (reportsProvider.serverSummary?.slaBreachedTickets ?? ticketProvider.slaBreachedCount).toString(),
                        icon: Icons.timer_off_outlined,
                        color: AppColors.slaBreached,
                        subtitle: 'Overdue resolution window',
                      ),
                      MetricCard(
                        title: 'CLOSED ARCHIVE',
                        count: (reportsProvider.serverSummary?.ticketsByStatus['CLOSED'] ?? ticketProvider.closedCount).toString(),
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.statusClosed,
                        subtitle: 'Archived tickets',
                        onTap: () {
                          ticketProvider.setFilterStatus(
                            AppConstants.statusClosed,
                          );
                          onNavigateTab(1);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Middle Section: SLA Alerts + Workload Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SlaAlertCard(
                            breachedOrWarningTickets: breachedOrWarningTickets,
                            onTicketTap: (ticket) {
                              ticketProvider.selectTicket(ticket);
                              onSelectTicket(ticket);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: WorkloadChartCard(
                            teamMembers: teamProvider.members,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        SlaAlertCard(
                          breachedOrWarningTickets: breachedOrWarningTickets,
                          onTicketTap: (ticket) {
                            ticketProvider.selectTicket(ticket);
                            onSelectTicket(ticket);
                          },
                        ),
                        const SizedBox(height: 16),
                        WorkloadChartCard(teamMembers: teamProvider.members),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // Bottom Section: Recent Tickets & Delegation Activity
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.history_rounded,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recent Tickets Pipeline',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => onNavigateTab(1),
                              child: const Text('View All →'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (recentTickets.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 36,
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No tickets found in pipeline.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentTickets.length,
                            separatorBuilder: (c, i) => Divider(
                              height: 16,
                              color: colorScheme.outlineVariant,
                            ),
                            itemBuilder: (context, index) {
                              final ticket = recentTickets[index];
                              return InkWell(
                                onTap: () {
                                  ticketProvider.selectTicket(ticket);
                                  onSelectTicket(ticket);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: colorScheme.outlineVariant,
                                          ),
                                        ),
                                        child: Text(
                                          ticket.ticketNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ticket.title,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  '${(ticket.customerName != null && ticket.customerName!.isNotEmpty) ? ticket.customerName : "Customer"} • ${ticket.category} • ',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormatter.timeAgo(
                                                    ticket.createdAt,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      DelegationChainWidget(ticket: ticket),
                                      const SizedBox(width: 12),
                                      PriorityBadge(
                                        priority: ticket.priority,
                                        isSmall: true,
                                      ),
                                      const SizedBox(width: 8),
                                      StatusBadge(
                                        status: ticket.status,
                                        isSmall: true,
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
