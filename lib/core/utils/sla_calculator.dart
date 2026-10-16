import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

enum SlaStatus { ok, warning, breached, completed }

class SlaCalculator {
  // Configurable prototype SLA hours
  static int getSlaHours(String priority) {
    switch (priority.toUpperCase()) {
      case AppConstants.priorityUrgent:
        return 2;
      case AppConstants.priorityHigh:
        return 4;
      case AppConstants.priorityMedium:
        return 8;
      case AppConstants.priorityLow:
      default:
        return 24;
    }
  }

  static DateTime calculateDueDate(DateTime createdAt, String priority) {
    final hours = getSlaHours(priority);
    return createdAt.add(Duration(hours: hours));
  }

  static SlaInfo getSlaInfo(DateTime createdAt, String priority, String status, {DateTime? resolvedAt}) {
    if (status == AppConstants.statusResolved || status == AppConstants.statusClosed) {
      final dueDate = calculateDueDate(createdAt, priority);
      final completionDate = resolvedAt ?? DateTime.now();
      final wasBreached = completionDate.isAfter(dueDate);
      return SlaInfo(
        status: SlaStatus.completed,
        remainingText: wasBreached ? 'Resolved (Breached)' : 'Resolved on time',
        color: wasBreached ? AppColors.slaBreached : AppColors.slaOk,
        isBreached: wasBreached,
        percentRemaining: 0,
      );
    }

    final dueDate = calculateDueDate(createdAt, priority);
    final now = DateTime.now();
    final totalDuration = dueDate.difference(createdAt).inMinutes;
    final remainingDuration = dueDate.difference(now).inMinutes;

    if (remainingDuration <= 0) {
      final breachedMins = -remainingDuration;
      final hours = breachedMins ~/ 60;
      final mins = breachedMins % 60;
      final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
      return SlaInfo(
        status: SlaStatus.breached,
        remainingText: 'SLA Breached by $timeStr',
        color: AppColors.slaBreached,
        isBreached: true,
        percentRemaining: 0.0,
      );
    } else {
      final hours = remainingDuration ~/ 60;
      final mins = remainingDuration % 60;
      final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
      final percent = (remainingDuration / totalDuration).clamp(0.0, 1.0);

      if (remainingDuration <= 60) {
        return SlaInfo(
          status: SlaStatus.warning,
          remainingText: '$timeStr remaining',
          color: AppColors.slaWarning,
          isBreached: false,
          percentRemaining: percent,
        );
      } else {
        return SlaInfo(
          status: SlaStatus.ok,
          remainingText: '$timeStr remaining',
          color: AppColors.slaOk,
          isBreached: false,
          percentRemaining: percent,
        );
      }
    }
  }
}

class SlaInfo {
  final SlaStatus status;
  final String remainingText;
  final Color color;
  final bool isBreached;
  final double percentRemaining;

  const SlaInfo({
    required this.status,
    required this.remainingText,
    required this.color,
    required this.isBreached,
    required this.percentRemaining,
  });
}
