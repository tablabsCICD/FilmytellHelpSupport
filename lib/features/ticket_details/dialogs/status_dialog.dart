import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';

class StatusDialog extends StatefulWidget {
  final SupportTicket ticket;
  final bool isPriorityChange;

  const StatusDialog({
    super.key,
    required this.ticket,
    this.isPriorityChange = false,
  });

  @override
  State<StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  late String _selectedValue;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.isPriorityChange ? widget.ticket.priority : widget.ticket.status;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final colorScheme = Theme.of(context).colorScheme;

    final options = widget.isPriorityChange ? AppConstants.allPriorities : AppConstants.allStatuses;
    final title = widget.isPriorityChange ? 'Change Priority Level' : 'Update Ticket Status';

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isPriorityChange ? AppColors.priorityUrgent.withValues(alpha: 0.15) : AppColors.statusNew.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.isPriorityChange ? Icons.flag_rounded : Icons.sync_alt_rounded,
                    color: widget.isPriorityChange ? AppColors.priorityUrgent : AppColors.statusNew,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      Text(
                        'Ticket: ${widget.ticket.ticketNumber}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: colorScheme.outlineVariant),

            // Select Dropdown
            Text(
              widget.isPriorityChange ? 'Select Priority' : 'Select Status',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
            ),
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
                  value: _selectedValue,
                  isExpanded: true,
                  dropdownColor: colorScheme.surface,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedValue = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes / Reason
            Text('Reason / Resolution Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Enter reason for this modification or resolution notes...',
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (widget.isPriorityChange) {
                      await ticketProvider.updateTicketPriority(
                        widget.ticket.ticketId,
                        _selectedValue,
                        currentUser,
                      );
                    } else {
                      await ticketProvider.updateTicketStatus(
                        widget.ticket.ticketId,
                        _selectedValue,
                        currentUser,
                        notes: _notesController.text.trim(),
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.isPriorityChange
                                ? 'Priority updated to $_selectedValue'
                                : 'Status updated to $_selectedValue',
                          ),
                          backgroundColor: AppColors.slaOk,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
