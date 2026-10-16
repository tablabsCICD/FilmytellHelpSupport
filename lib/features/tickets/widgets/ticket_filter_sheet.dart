import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/ticket_provider.dart';

class TicketFilterSheet extends StatelessWidget {
  const TicketFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Filter Support Tickets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ticketProvider.clearAllFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset All', style: TextStyle(color: AppColors.priorityUrgent)),
                ),
              ],
            ),
            Divider(height: 24, color: colorScheme.outlineVariant),

            // 1. Status Filter
            Text('Ticket Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', ...AppConstants.allStatuses].map((status) {
                final isSelected = (ticketProvider.filterStatus == null && status == 'All') || ticketProvider.filterStatus == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide(color: isSelected ? AppColors.primary : colorScheme.outlineVariant),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : colorScheme.onSurface,
                  ),
                  onSelected: (_) {
                    ticketProvider.setFilterStatus(status == 'All' ? null : status);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 2. Priority Filter
            Text('Priority Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', ...AppConstants.allPriorities].map((p) {
                final isSelected = (ticketProvider.filterPriority == null && p == 'All') || ticketProvider.filterPriority == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  selectedColor: AppColors.accent.withValues(alpha: 0.2),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide(color: isSelected ? AppColors.accent : colorScheme.outlineVariant),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.accent : colorScheme.onSurface,
                  ),
                  onSelected: (_) {
                    ticketProvider.setFilterPriority(p == 'All' ? null : p);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 3. Team Filter
            Text('Assigned Team', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', ...AppConstants.allTeams].map((team) {
                final isSelected = (ticketProvider.filterTeam == null && team == 'All') || ticketProvider.filterTeam == team;
                return ChoiceChip(
                  label: Text(team),
                  selected: isSelected,
                  selectedColor: AppColors.teamSupport.withValues(alpha: 0.2),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide(color: isSelected ? AppColors.teamSupport : colorScheme.outlineVariant),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.teamSupport : colorScheme.onSurface,
                  ),
                  onSelected: (_) {
                    ticketProvider.setFilterTeam(team == 'All' ? null : team);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Source Filter
            Text('Portal Source', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', ...AppConstants.allSources].map((source) {
                final isSelected = (ticketProvider.filterSource == null && source == 'All') || ticketProvider.filterSource == source;
                return ChoiceChip(
                  label: Text(source),
                  selected: isSelected,
                  selectedColor: AppColors.accent.withValues(alpha: 0.2),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide(color: isSelected ? AppColors.accent : colorScheme.outlineVariant),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.accent : colorScheme.onSurface,
                  ),
                  onSelected: (_) {
                    ticketProvider.setFilterSource(source == 'All' ? null : source);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Apply Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
