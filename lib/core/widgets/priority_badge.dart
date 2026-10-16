import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool isSmall;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.getPriorityStyle(context, priority);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: style.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.foreground, size: isSmall ? 12 : 14),
          SizedBox(width: isSmall ? 3 : 5),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              color: style.foreground,
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
