import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/team_provider.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';

class DelegateDialog extends StatefulWidget {
  final SupportTicket ticket;

  const DelegateDialog({super.key, required this.ticket});

  @override
  State<DelegateDialog> createState() => _DelegateDialogState();
}

class _DelegateDialogState extends State<DelegateDialog> {
  String? _selectedMember;
  String _selectedReason = AppConstants.delegationReasons.first;
  final _instructionsController = TextEditingController();
  DateTime? _dueDate;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final colorScheme = Theme.of(context).colorScheme;

    // List authorized members (excluding current assignee to prevent self-delegation loop)
    final authorizedMembers = teamProvider.members
        .where((m) => m.isAvailable && m.name != widget.ticket.currentAssignee)
        .toList();

    if (_selectedMember == null && authorizedMembers.isNotEmpty) {
      _selectedMember = authorizedMembers.first.name;
    }

    final currentLevel = widget.ticket.delegationLevel;
    final nextLevel = currentLevel + 1;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.alt_route_rounded, color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Delegate Task',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Level $nextLevel Delegation',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Ticket Owner: ${widget.ticket.ticketOwner} (Preserved)',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: colorScheme.outlineVariant),

              // Current Delegation Flow Preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hub_outlined, color: AppColors.accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active Chain: ${widget.ticket.ticketOwner} → ${widget.ticket.currentAssignee} → ${_selectedMember ?? "?"}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. Delegate To
              Text('Delegate To (Authorized Member)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              if (authorizedMembers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.priorityUrgent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('No other available team members found.', style: TextStyle(fontSize: 12, color: AppColors.priorityUrgent)),
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
                      items: authorizedMembers.map((m) {
                        return DropdownMenuItem(
                          value: m.name,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(m.name),
                              Text(
                                '${m.team} (${m.role})',
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
              const SizedBox(height: 16),

              // 2. Delegation Reason
              Text('Delegation Reason', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
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
                    value: _selectedReason,
                    isExpanded: true,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                    items: AppConstants.delegationReasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedReason = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Due Date (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Due Date & Target Time (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                  if (_dueDate != null)
                    TextButton(
                      onPressed: () => setState(() => _dueDate = null),
                      child: const Text('Clear', style: TextStyle(fontSize: 11, color: AppColors.priorityUrgent)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(hours: 4)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (pickedDate != null && context.mounted) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 18, minute: 0),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _dueDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Text(
                        _dueDate != null ? DateFormatter.formatDateTime(_dueDate) : 'No due date set (Click to select)',
                        style: TextStyle(
                          fontSize: 13,
                          color: _dueDate != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Instructions
              Text('Instructions & Context Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              TextField(
                controller: _instructionsController,
                maxLines: 3,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Enter specific requirements, log links, or instructions for the delegated member...',
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
                            final instructions = _instructionsController.text.trim().isNotEmpty
                                ? _instructionsController.text.trim()
                                : 'Assigned delegated investigation task.';

                            final targetMember = authorizedMembers.firstWhere(
                              (m) => m.name == _selectedMember,
                              orElse: () => authorizedMembers.first,
                            );

                            try {
                              await ticketProvider.delegateTask(
                                widget.ticket.ticketId,
                                toUserName: _selectedMember!,
                                reason: _selectedReason,
                                instructions: instructions,
                                dueAt: _dueDate,
                                performedBy: currentUser,
                                assignToUserId: targetMember.userIdInt,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Task successfully delegated to $_selectedMember (L$nextLevel)'),
                                    backgroundColor: AppColors.accent,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Delegation Failed: ${e.toString().replaceAll('Exception:', '').trim()}'),
                                    backgroundColor: AppColors.slaBreached,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Delegate Task'),
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
