import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_view_widget.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/ticket_provider.dart';
import '../widgets/ticket_card.dart';
import '../widgets/ticket_filter_sheet.dart';

class AllTicketsScreen extends StatelessWidget {
  final Function(SupportTicket) onSelectTicket;

  const AllTicketsScreen({
    super.key,
    required this.onSelectTicket,
  });

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    final bool hasActiveFilters = ticketProvider.filterStatus != null ||
        ticketProvider.filterPriority != null ||
        ticketProvider.filterTeam != null ||
        ticketProvider.filterSource != null;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ticketProvider.loadTickets(forceRefresh: true),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Support Tickets',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Showing ${ticketProvider.totalFilteredCount} matching tickets across channels',
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sync_rounded, color: AppColors.primary),
                        tooltip: 'Sync Admin Portal Tickets',
                        onPressed: () async {
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Synchronizing Admin Portal tickets...')),
                            );
                            final res = await ticketProvider.syncAdminPortalTickets();
                            final newCount = res['newTickets'] ?? 0;
                            final skipped = res['duplicatesSkipped'] ?? 0;
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Sync finished: $newCount new, $skipped duplicates skipped.')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Sync failed: $e')),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurfaceVariant),
                        tooltip: 'Refresh API & Local Cache',
                        onPressed: () => ticketProvider.loadTickets(forceRefresh: true),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search & Filter Controls Bar
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by Ticket #, Subject, Description, User ID, Team, Assignee...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: ticketProvider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => ticketProvider.setSearchQuery(''),
                              )
                            : null,
                      ),
                      onChanged: (val) => ticketProvider.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Filter Button
                  OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const TicketFilterSheet(),
                      );
                    },
                    icon: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: hasActiveFilters ? AppColors.primary : colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      hasActiveFilters ? 'Filters (Active)' : 'Filters',
                      style: TextStyle(
                        color: hasActiveFilters ? AppColors.primary : colorScheme.onSurfaceVariant,
                        fontWeight: hasActiveFilters ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Sort Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TicketSortBy>(
                        value: ticketProvider.sortBy,
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                        icon: Icon(Icons.sort_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                        items: const [
                          DropdownMenuItem(value: TicketSortBy.newest, child: Text('Newest First')),
                          DropdownMenuItem(value: TicketSortBy.oldest, child: Text('Oldest First')),
                          DropdownMenuItem(value: TicketSortBy.priorityHighToLow, child: Text('Priority High → Low')),
                          DropdownMenuItem(value: TicketSortBy.slaUrgent, child: Text('SLA Most Urgent')),
                        ],
                        onChanged: (val) {
                          if (val != null) ticketProvider.setSortBy(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Filters Pills (if any)
              if (hasActiveFilters) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (ticketProvider.filterStatus != null)
                      _buildFilterChip(context, 'Status: ${ticketProvider.filterStatus}', () => ticketProvider.setFilterStatus(null)),
                    if (ticketProvider.filterPriority != null)
                      _buildFilterChip(context, 'Priority: ${ticketProvider.filterPriority}', () => ticketProvider.setFilterPriority(null)),
                    if (ticketProvider.filterTeam != null)
                      _buildFilterChip(context, 'Team: ${ticketProvider.filterTeam}', () => ticketProvider.setFilterTeam(null)),
                    if (ticketProvider.filterSource != null)
                      _buildFilterChip(context, 'Source: ${ticketProvider.filterSource}', () => ticketProvider.setFilterSource(null)),
                    TextButton(
                      onPressed: () => ticketProvider.clearAllFilters(),
                      child: const Text('Clear All', style: TextStyle(fontSize: 12, color: AppColors.priorityUrgent)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Content Area: Loading / Error / Empty / List
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (ticketProvider.isLoading && ticketProvider.allTickets.isEmpty) {
                      return ListView.separated(
                        itemCount: 4,
                        separatorBuilder: (c, i) => const SizedBox(height: 12),
                        itemBuilder: (c, i) => const LoadingShimmer(height: 130),
                      );
                    }

                    if (ticketProvider.errorMessage != null && ticketProvider.allTickets.isEmpty) {
                      return ErrorViewWidget(
                        message: ticketProvider.errorMessage!,
                        onRetry: () => ticketProvider.loadTickets(forceRefresh: true),
                      );
                    }

                    if (ticketProvider.paginatedFilteredTickets.isEmpty) {
                      return EmptyStateWidget(
                        title: 'No matching tickets found',
                        message: 'Try adjusting your search terms or resetting active filters.',
                        buttonText: 'Reset Filters',
                        onButtonPressed: () => ticketProvider.clearAllFilters(),
                      );
                    }

                    return ListView.builder(
                      itemCount: ticketProvider.paginatedFilteredTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = ticketProvider.paginatedFilteredTickets[index];
                        return TicketCard(
                          ticket: ticket,
                          onTap: () {
                            ticketProvider.selectTicket(ticket);
                            onSelectTicket(ticket);
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Centralized Pagination Bar
              if (ticketProvider.totalPages > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page ${ticketProvider.currentPage + 1} of ${ticketProvider.totalPages} (${ticketProvider.totalFilteredCount} total items)',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.first_page_rounded, size: 20),
                            onPressed: ticketProvider.currentPage > 0
                                ? () => ticketProvider.setPage(0)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, size: 20),
                            onPressed: ticketProvider.currentPage > 0
                                ? () => ticketProvider.setPage(ticketProvider.currentPage - 1)
                                : null,
                          ),
                          ...List.generate(
                            ticketProvider.totalPages,
                            (index) {
                              // Display nearby page numbers only
                              if ((index - ticketProvider.currentPage).abs() > 2 && index != 0 && index != ticketProvider.totalPages - 1) {
                                return const SizedBox.shrink();
                              }
                              final isSelected = index == ticketProvider.currentPage;
                              return InkWell(
                                onTap: () => ticketProvider.setPage(index),
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, size: 20),
                            onPressed: ticketProvider.currentPage < ticketProvider.totalPages - 1
                                ? () => ticketProvider.setPage(ticketProvider.currentPage + 1)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page_rounded, size: 20),
                            onPressed: ticketProvider.currentPage < ticketProvider.totalPages - 1
                                ? () => ticketProvider.setPage(ticketProvider.totalPages - 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, VoidCallback onDeleted) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurface)),
      deleteIcon: Icon(Icons.close_rounded, size: 14, color: colorScheme.onSurfaceVariant),
      onDeleted: onDeleted,
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide(color: colorScheme.outlineVariant),
      visualDensity: VisualDensity.compact,
    );
  }
}
