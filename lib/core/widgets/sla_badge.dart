import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/sla_calculator.dart';

class SlaBadge extends StatelessWidget {
  final DateTime createdAt;
  final String priority;
  final String status;
  final DateTime? resolvedAt;
  final bool isSmall;

  const SlaBadge({
    super.key,
    required this.createdAt,
    required this.priority,
    required this.status,
    this.resolvedAt,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final slaInfo = SlaCalculator.getSlaInfo(
      createdAt,
      priority,
      status,
      resolvedAt: resolvedAt,
    );

    final style = AppTheme.getSlaStyle(
      context,
      slaInfo.isBreached
          ? 'BREACHED'
          : (slaInfo.status == SlaStatus.completed
              ? 'COMPLETED'
              : (slaInfo.status == SlaStatus.warning ? 'WARNING' : 'OK')),
    );

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
          Icon(
            slaInfo.isBreached
                ? Icons.warning_amber_rounded
                : (slaInfo.status == SlaStatus.completed
                    ? Icons.check_circle_outline_rounded
                    : Icons.timer_outlined),
            color: style.foreground,
            size: isSmall ? 12 : 14,
          ),
          SizedBox(width: isSmall ? 3 : 5),
          Text(
            slaInfo.remainingText,
            style: TextStyle(
              color: style.foreground,
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
