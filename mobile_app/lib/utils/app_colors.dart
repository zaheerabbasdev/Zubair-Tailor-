import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────────────────────
  static const primary      = Color(0xFFC62828); // Rich Crimson
  static const primaryDark  = Color(0xFF8E0000); // Deep Crimson
  static const primaryLight = Color(0xFFEF5350); // Light Crimson

  // ── Accent ──────────────────────────────────────────────────────────────
  static const accent       = Color(0xFFF59E0B); // Warm Gold
  static const accentLight  = Color(0xFFFDE68A); // Light Gold

  // ── Secondary (kept for compatibility) ──────────────────────────────────
  static const secondary    = Color(0xFF1EA896); // Teal

  // ── Backgrounds ─────────────────────────────────────────────────────────
  static const background     = Color(0xFFFFF8F5); // Warm off-white
  static const surface        = Color(0xFFFFFFFF); // Pure white
  static const surfaceVariant = Color(0xFFFEF2EE); // Blush tint

  // ── Text ────────────────────────────────────────────────────────────────
  static const textDark   = Color(0xFF1A1A2E); // Deep navy
  static const textMedium = Color(0xFF6B7280); // Cool gray
  static const textLight  = Colors.white;

  // ── Status ──────────────────────────────────────────────────────────────
  static const statusPending     = Color(0xFFF59E0B); // Amber
  static const statusInProgress  = Color(0xFF3B82F6); // Blue
  static const statusReady       = Color(0xFF10B981); // Green
  static const statusDelivered   = Color(0xFF9CA3AF); // Gray

  // ── Gradients ───────────────────────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF8E0000), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGradient = LinearGradient(
    colors: [Color(0xFF8E0000), Color(0xFFC62828), Color(0xFF1A1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );

  // ── Shadows ─────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6)),
    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4,  offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(color: primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  // ── Helpers ─────────────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status) {
      case 'Pending':     return statusPending;
      case 'In Progress': return statusInProgress;
      case 'Ready':       return statusReady;
      case 'Delivered':   return statusDelivered;
      default:            return textMedium;
    }
  }
}
