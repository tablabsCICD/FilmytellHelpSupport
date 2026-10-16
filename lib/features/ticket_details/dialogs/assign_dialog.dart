import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/team_provider.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';

class AssignDialog extends StatefulWidget {
  final SupportTicket ticket;

  const AssignDialog({super.key, required this.ticket});

  @override
  State<AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<AssignDialog> {
  late String _selectedTeam;
  String? _selectedMember;

  @override
  void initState() {
    super.initState();
    _selectedTeam = widget.ticket.team.isNotEmpty ? widget.ticket.team : AppConstants.teamSupport;
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final colorScheme = Theme.of(context).colorScheme;

    final teamMembers = teamProvider.members.where((m) => m.team == _selectedTeam && m.isAvailable).toList();
    if (_selectedMember == null && teamMembers.isNotEmpty) {
      _selectedMember = teamMembers.first.name;
    }

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign Support Ticket',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      Text(
                        'Route ${widget.ticket.ticketNumber} to the responsible team & lead',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: colorScheme.outlineVariant),

            // 1. Select Team
            Text('Responsible Team', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTeam,
                  isExpanded: true,
                  dropdownColor: colorScheme.surface,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  items: AppConstants.allTeams.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTeam = val;
                        final newMembers = teamProvider.members.where((m) => m.team == val && m.isAvailable).toList();
                        _selectedMember = newMembers.isNotEmpty ? newMembers.first.name : null;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Select Member
            Text('Assignee & Ticket Owner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            if (teamMembers.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.priorityUrgent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.priorityUrgent.withValues(alpha: 0.3)),
                ),
                child: const Text('No available members in this team.', style: TextStyle(fontSize: 12, color: AppColors.priorityUrgent)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMember,
                    isExpanded: true,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                    items: teamMembers.map((m) {
                      return DropdownMenuItem(
                        value: m.name,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(m.name),
                            Text(
                              '${m.role} • ${m.activeTicketsCount} active',
                              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMember = val);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _selectedMember == null
                      ? null
                      : () async {
                          await ticketProvider.assignTicket(
                            widget.ticket.ticketId,
                            _selectedTeam,
                            _selectedMember!,
                            currentUser,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ticket assigned to $_selectedMember ($_selectedTeam)'),
                                backgroundColor: AppColors.slaOk,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Confirm Assignment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
