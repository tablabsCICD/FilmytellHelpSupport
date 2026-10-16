import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'light_theme.dart';
import 'dark_theme.dart';
import '../constants/app_constants.dart';

export 'app_colors.dart';
export 'app_text_styles.dart';
export 'app_theme_controller.dart';

class StatusStyle {
  final Color background;
  final Color foreground;
  final Color border;
  final Color dotColor;

  const StatusStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.dotColor,
  });

  Color get color => foreground;
}

class PriorityStyle {
  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;

  const PriorityStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  Color get color => foreground;
}

class SlaStyle {
  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;

  const SlaStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  Color get color => foreground;
}

class AppTheme {
  static ThemeData get lightTheme => getLightTheme();
  static ThemeData get darkTheme => getDarkTheme();

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static StatusStyle getStatusStyle(BuildContext context, String status) {
    final dark = isDark(context);
    final upper = status.toUpperCase().trim();

    Color baseColor;
    Color lightText;
    Color darkText;

    switch (upper) {
      case AppConstants.statusNew:
        baseColor = AppColors.statusNew;
        lightText = const Color(0xFF1D4ED8); // Blue 700
        darkText = const Color(0xFF60A5FA);  // Blue 400
        break;
      case AppConstants.statusAiAnalysis:
        baseColor = AppColors.statusAiAnalysis;
        lightText = const Color(0xFF6D28D9); // Purple 700
        darkText = const Color(0xFFA78BFA);  // Purple 400
        break;
      case AppConstants.statusAiResolved:
        baseColor = AppColors.statusAiResolved;
        lightText = const Color(0xFF0E7490); // Cyan 700
        darkText = const Color(0xFF22D3EE);  // Cyan 400
        break;
      case AppConstants.statusAssigned:
        baseColor = AppColors.statusAssigned;
        lightText = const Color(0xFFB45309); // Amber 700
        darkText = const Color(0xFFFBBF24);  // Amber 400
        break;
      case AppConstants.statusInProgress:
        baseColor = AppColors.statusInProgress;
        lightText = const Color(0xFFC2410C); // Orange 700
        darkText = const Color(0xFFFB923C);  // Orange 400
        break;
      case AppConstants.statusPendingUser:
        baseColor = AppColors.statusPendingUser;
        lightText = const Color(0xFFBE185D); // Pink 700
        darkText = const Color(0xFFF472B6);  // Pink 400
        break;
      case AppConstants.statusResolved:
        baseColor = AppColors.statusResolved;
        lightText = const Color(0xFF047857); // Emerald 700
        darkText = const Color(0xFF34D399);  // Emerald 400
        break;
      case AppConstants.statusClosed:
        baseColor = AppColors.statusClosed;
        lightText = const Color(0xFF475569); // Slate 600
        darkText = const Color(0xFF94A3B8);  // Slate 400
        break;
      default:
        baseColor = AppColors.statusNew;
        lightText = const Color(0xFF1D4ED8);
        darkText = const Color(0xFF60A5FA);
    }

    if (dark) {
      return StatusStyle(
        background: baseColor.withValues(alpha: 0.18),
        foreground: darkText,
        border: baseColor.withValues(alpha: 0.45),
        dotColor: baseColor,
      );
    } else {
      return StatusStyle(
        background: baseColor.withValues(alpha: 0.10),
        foreground: lightText,
        border: baseColor.withValues(alpha: 0.30),
        dotColor: baseColor,
      );
    }
  }

  static PriorityStyle getPriorityStyle(BuildContext context, String priority) {
    final dark = isDark(context);
    final upper = priority.toUpperCase().trim();

    Color baseColor;
    Color lightText;
    Color darkText;
    IconData icon;

    switch (upper) {
      case AppConstants.priorityUrgent:
        baseColor = AppColors.priorityUrgent;
        lightText = const Color(0xFFB91C1C); // Red 700
        darkText = const Color(0xFFF87171);  // Red 400
        icon = Icons.emergency_rounded;
        break;
      case AppConstants.priorityHigh:
        baseColor = AppColors.priorityHigh;
        lightText = const Color(0xFFC2410C); // Orange 700
        darkText = const Color(0xFFFB923C);  // Orange 400
        icon = Icons.keyboard_double_arrow_up_rounded;
        break;
      case AppConstants.priorityMedium:
        baseColor = AppColors.priorityMedium;
        lightText = const Color(0xFFA16207); // Yellow 700
        darkText = const Color(0xFFFACC15);  // Yellow 400
        icon = Icons.drag_handle_rounded;
        break;
      case AppConstants.priorityLow:
        baseColor = AppColors.priorityLow;
        lightText = const Color(0xFF047857); // Green 700
        darkText = const Color(0xFF34D399);  // Green 400
        icon = Icons.keyboard_arrow_down_rounded;
        break;
      default:
        baseColor = AppColors.priorityLow;
        lightText = const Color(0xFF047857);
        darkText = const Color(0xFF34D399);
        icon = Icons.circle;
    }

    if (dark) {
      return PriorityStyle(
        background: baseColor.withValues(alpha: 0.18),
        foreground: darkText,
        border: baseColor.withValues(alpha: 0.45),
        icon: icon,
      );
    } else {
      return PriorityStyle(
        background: baseColor.withValues(alpha: 0.10),
        foreground: lightText,
        border: baseColor.withValues(alpha: 0.30),
        icon: icon,
      );
    }
  }

  static SlaStyle getSlaStyle(BuildContext context, String slaState) {
    final dark = isDark(context);
    final upper = slaState.toUpperCase().trim();

    Color baseColor;
    Color lightText;
    Color darkText;
    IconData icon;

    if (upper.contains('BREACH') || upper.contains('OVERDUE')) {
      baseColor = AppColors.slaBreached;
      lightText = const Color(0xFFB91C1C);
      darkText = const Color(0xFFF87171);
      icon = Icons.error_outline_rounded;
    } else if (upper.contains('WARN') || upper.contains('APPROACH') || upper.contains('DUE SOON')) {
      baseColor = AppColors.slaWarning;
      lightText = const Color(0xFFB45309);
      darkText = const Color(0xFFFBBF24);
      icon = Icons.warning_amber_rounded;
    } else {
      baseColor = AppColors.slaOk;
      lightText = const Color(0xFF047857);
      darkText = const Color(0xFF34D399);
      icon = Icons.check_circle_outline_rounded;
    }

    if (dark) {
      return SlaStyle(
        background: baseColor.withValues(alpha: 0.18),
        foreground: darkText,
        border: baseColor.withValues(alpha: 0.45),
        icon: icon,
      );
    } else {
      return SlaStyle(
        background: baseColor.withValues(alpha: 0.10),
        foreground: lightText,
        border: baseColor.withValues(alpha: 0.30),
        icon: icon,
      );
    }
  }
}
