import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFFE50914); // Filmytell Cinematic Red
  static const Color primaryLight = Color(0xFFFF4D4D);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryContainerLight = Color(0xFFFFEBEB);
  static const Color primaryContainerDark = Color(0xFF3F0B0E);
  static const Color accent = Color(0xFF6366F1); // Indigo accent
  static const Color accentLight = Color(0xFF818CF8);
  static const Color accentDark = Color(0xFF4F46E5);

  // Light Theme Surfaces & Neutrals
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color bgSurfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color bgCardLight = Color(0xFFFFFFFF);
  static const Color bgCardHoverLight = Color(0xFFF1F5F9); // Slate 100
  static const Color bgSubtleLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtleLight = Color(0xFFCBD5E1); // Slate 300
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Dark Theme Surfaces & Neutrals
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color bgSurfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color bgCardDark = Color(0xFF1E293B);
  static const Color bgCardHoverDark = Color(0xFF334155); // Slate 700
  static const Color bgSubtleDark = Color(0xFF141E33);
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color borderSubtleDark = Color(0xFF475569); // Slate 600
  static const Color dividerDark = Color(0xFF334155);

  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textMutedLight = Color(0xFF64748B); // Slate 500
  static const Color textDisabledLight = Color(0xFF94A3B8); // Slate 400

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500
  static const Color textDisabledDark = Color(0xFF475569); // Slate 600

  // Status Colors
  static const Color statusNew = Color(0xFF3B82F6); // Blue
  static const Color statusAiAnalysis = Color(0xFF8B5CF6); // Purple
  static const Color statusAiResolved = Color(0xFF06B6D4); // Cyan
  static const Color statusAssigned = Color(0xFFF59E0B); // Amber
  static const Color statusInProgress = Color(0xFFF97316); // Orange
  static const Color statusPendingUser = Color(0xFFEC4899); // Pink
  static const Color statusResolved = Color(0xFF10B981); // Emerald Green
  static const Color statusClosed = Color(0xFF64748B); // Slate

  // Priority Colors
  static const Color priorityUrgent = Color(0xFFEF4444); // Red
  static const Color priorityHigh = Color(0xFFF97316); // Orange
  static const Color priorityMedium = Color(0xFFEAB308); // Yellow
  static const Color priorityLow = Color(0xFF10B981); // Green

  // SLA Status Colors
  static const Color slaOk = Color(0xFF10B981); // Green
  static const Color slaWarning = Color(0xFFF59E0B); // Amber
  static const Color slaBreached = Color(0xFFEF4444); // Red

  // Team Colors
  static const Color teamSupport = Color(0xFF3B82F6);
  static const Color teamTech = Color(0xFF8B5CF6);
}
