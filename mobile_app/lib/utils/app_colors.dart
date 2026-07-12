import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Set by [ThemeProvider] on load/toggle. Read by every color getter below
  /// so screens automatically pick up the right palette on their next build.
  static bool dark = false;

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
  static const _backgroundLight     = Color(0xFFFFF8F5); // Warm off-white
  static const _backgroundDark      = Color(0xFF141110); // Warm-tinted charcoal
  static Color get background => dark ? _backgroundDark : _backgroundLight;

  static const _surfaceLight        = Color(0xFFFFFFFF); // Pure white
  static const _surfaceDark         = Color(0xFF221C19); // Elevated dark surface
  static Color get surface => dark ? _surfaceDark : _surfaceLight;

  static const _surfaceVariantLight = Color(0xFFFEF2EE); // Blush tint
  static const _surfaceVariantDark  = Color(0xFF2A2320);
  static Color get surfaceVariant => dark ? _surfaceVariantDark : _surfaceVariantLight;

  /// Card/sheet backgrounds that used to be a bare `Colors.white` literal.
  static Color get surfaceCard => surface;

  /// Hairline borders/dividers that used to be `Color(0xFFEEEEEE)` /
  /// `Colors.grey.shadeXXX` literals.
  static const _dividerLight = Color(0xFFEEEEEE);
  static const _dividerDark  = Color(0xFF3A322C);
  static Color get divider => dark ? _dividerDark : _dividerLight;

  /// Muted icons that used to be `Colors.grey.shade400/500` literals.
  static const _iconMutedLight = Color(0xFFBDBDBD);
  static const _iconMutedDark  = Color(0xFF7A716B);
  static Color get iconMuted => dark ? _iconMutedDark : _iconMutedLight;

  // ── Text ────────────────────────────────────────────────────────────────
  static const _textDarkLight   = Color(0xFF1A1A2E); // Deep navy
  static const _textDarkDark    = Color(0xFFF5F1EE); // Warm near-white
  static Color get textDark => dark ? _textDarkDark : _textDarkLight;

  static const _textMediumLight = Color(0xFF6B7280); // Cool gray
  static const _textMediumDark  = Color(0xFFB8AFA9); // Muted warm gray
  static Color get textMedium => dark ? _textMediumDark : _textMediumLight;

  static const textLight  = Colors.white; // used on colored/gradient surfaces in both modes

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
    BoxShadow(color: Colors.black.withOpacity(dark ? 0.24 : 0.06), blurRadius: 20, offset: const Offset(0, 6)),
    BoxShadow(color: Colors.black.withOpacity(dark ? 0.10 : 0.02), blurRadius: 4,  offset: const Offset(0, 1)),
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
