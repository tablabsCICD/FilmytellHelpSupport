import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class PriorityHelper {
  static Color getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case AppConstants.priorityUrgent:
        return AppColors.priorityUrgent;
      case AppConstants.priorityHigh:
        return AppColors.priorityHigh;
      case AppConstants.priorityMedium:
        return AppColors.priorityMedium;
      case AppConstants.priorityLow:
        return AppColors.priorityLow;
      default:
        return AppColors.priorityLow;
    }
  }

  static IconData getPriorityIcon(String priority) {
    switch (priority.toUpperCase()) {
      case AppConstants.priorityUrgent:
        return Icons.emergency_rounded;
      case AppConstants.priorityHigh:
        return Icons.keyboard_double_arrow_up_rounded;
      case AppConstants.priorityMedium:
        return Icons.drag_handle_rounded;
      case AppConstants.priorityLow:
        return Icons.keyboard_arrow_down_rounded;
      default:
        return Icons.circle;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case AppConstants.statusNew:
        return AppColors.statusNew;
      case AppConstants.statusAiAnalysis:
        return AppColors.statusAiAnalysis;
      case AppConstants.statusAiResolved:
        return AppColors.statusAiResolved;
      case AppConstants.statusAssigned:
        return AppColors.statusAssigned;
      case AppConstants.statusInProgress:
        return AppColors.statusInProgress;
      case AppConstants.statusPendingUser:
        return AppColors.statusPendingUser;
      case AppConstants.statusResolved:
        return AppColors.statusResolved;
      case AppConstants.statusClosed:
        return AppColors.statusClosed;
      default:
        return AppColors.statusNew;
    }
  }
}
