import 'package:flutter/material.dart';
import '../../models/support_ticket_model.dart';

class DelegationChainWidget extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback? onTap;

  const DelegationChainWidget({
    super.key,
    required this.ticket,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (ticket.delegations.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline_rounded, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            'Owner: ',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            ticket.ticketOwner,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          ),
        ],
      );
    }

    // Build chain items: e.g. Owner -> B -> C
    final List<String> chain = [ticket.ticketOwner];
    for (var del in ticket.delegations.reversed) {
      if (!chain.contains(del.toUserName)) {
        chain.add(del.toUserName);
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.alt_route_rounded, size: 14, color: colorScheme.secondary),
            const SizedBox(width: 6),
            ...List.generate(chain.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.arrow_forward_rounded, size: 12, color: colorScheme.secondary),
                );
              }
              final userIndex = index ~/ 2;
              final userName = chain[userIndex];
              final isCurrent = userName == ticket.currentAssignee;

              return Text(
                userName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? colorScheme.secondary : colorScheme.onSurfaceVariant,
                ),
              );
            }),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'L${ticket.delegationLevel}',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
