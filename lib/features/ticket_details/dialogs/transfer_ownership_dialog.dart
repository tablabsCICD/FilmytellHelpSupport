import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/support_ticket_model.dart';
import '../../../providers/team_provider.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';

class TransferOwnershipDialog extends StatefulWidget {
  final SupportTicket ticket;

  const TransferOwnershipDialog({super.key, required this.ticket});

  @override
  State<TransferOwnershipDialog> createState() => _TransferOwnershipDialogState();
}

class _TransferOwnershipDialogState extends State<TransferOwnershipDialog> {
  String? _selectedOwner;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final colorScheme = Theme.of(context).colorScheme;

    final eligibleOwners = teamProvider.members
        .where((m) => m.isAvailable && m.name != widget.ticket.ticketOwner)
        .toList();

    if (_selectedOwner == null && eligibleOwners.isNotEmpty) {
      _selectedOwner = eligibleOwners.first.name;
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
                    color: AppColors.priorityUrgent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: AppColors.priorityUrgent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transfer Ticket Ownership',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      Text(
                        'Reassign primary legal & resolution responsibility for ${widget.ticket.ticketNumber}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: colorScheme.outlineVariant),

            // Warning Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.priorityUrgent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.priorityUrgent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.priorityUrgent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current Owner: "${widget.ticket.ticketOwner}". Transferring ownership is permanent and recorded in the audit trail.',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Select New Owner
            Text('Select New Ticket Owner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            if (eligibleOwners.isEmpty)
              const Text('No other members available for transfer.', style: TextStyle(fontSize: 12, color: AppColors.priorityUrgent))
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
                    value: _selectedOwner,
                    isExpanded: true,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                    items: eligibleOwners.map((m) {
                      return DropdownMenuItem(
                        value: m.name,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(m.name),
                            Text('${m.team} (${m.role})', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedOwner = val);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Transfer Reason
            Text('Reason for Transfer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'e.g. Lead escalation, change of domain responsibility...',
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
                  onPressed: _selectedOwner == null
                      ? null
                      : () async {
                          await ticketProvider.transferOwnership(
                            widget.ticket.ticketId,
                            _selectedOwner!,
                            currentUser,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ownership transferred to $_selectedOwner'),
                                backgroundColor: AppColors.slaOk,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Transfer Ownership'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
