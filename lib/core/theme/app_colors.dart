import 'package:flutter/material.dart';

/// Raw palette and the semantic colors screens actually read.
abstract final class AppColors {
  static const lightBackground = Color(0xFFF5F8FC);
  static const lightSurface = Color(0xFFE7EEF6);
  static const lightCard = Color(0xFFFDFEFF);
  static const lightText = Color(0xFF121826);
  static const lightMuted = Color(0xFF5C6B80);
  static const lightAccent = Color(0xFF0C6F80);
  static const lightSecondary = Color(0xFF4F46C8);
  static const lightOnAccent = Color(0xFFFFFFFF);
  static const lightSuccess = Color(0xFF0E8F62);
  static const lightWarning = Color(0xFFB7791F);
  static const lightError = Color(0xFFD64545);
  static const lightDisabled = Color(0xFFB7C2CE);
  static const lightBorder = Color(0xFFD5DEE8);
  static const lightOverlay = Color(0xB30B1220);
  static const lightHint = Color(0xFF1478B8);
  static const lightBlocked = Color(0xFFD4533C);

  static const darkBackground = Color(0xFF10192A);
  static const darkSurface = Color(0xFF070B12);
  static const darkCard = Color(0xFF161E2E);
  static const darkText = Color(0xFFF4F7FB);
  static const darkMuted = Color(0xFF93A0B4);
  static const darkAccent = Color(0xFF2ED4F5);
  static const darkSecondary = Color(0xFF8B7CFF);
  static const darkOnAccent = Color(0xFF04141C);
  static const darkSuccess = Color(0xFF3DDCB0);
  static const darkWarning = Color(0xFFF0B429);
  static const darkError = Color(0xFFFF6B7A);
  static const darkDisabled = Color(0xFF4C586C);
  static const darkBorder = Color(0xFF2A3548);
  static const darkOverlay = Color(0xD105080F);
  static const darkHint = Color(0xFF5AD0FF);
  static const darkBlocked = Color(0xFFFF6B6B);

  static const lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightBackground, lightSurface, Color(0xFFF3F7FB)],
  );

  static const darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, darkSurface, Color(0xFF0A1020)],
  );

  static const burst = [
    Color(0xFF2ED4F5),
    Color(0xFF8B7CFF),
    Color(0xFF3DDCB0),
    Color(0xFFF0B429),
    Color(0xFFFF6B7A),
    Color(0xFF7AA2FF),
    Color(0xFFE07AD4),
    Color(0xFF7DFFCF),
  ];
}

@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.secondary,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.error,
    required this.disabled,
    required this.border,
    required this.overlay,
    required this.hint,
    required this.blocked,
    required this.gradient,
    required this.orb,
  });

  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color secondary;
  final Color onAccent;
  final Color success;
  final Color warning;
  final Color error;
  final Color disabled;
  final Color border;
  final Color overlay;
  final Color hint;
  final Color blocked;
  final LinearGradient gradient;
  final Color orb;

  static const light = GameColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    card: AppColors.lightCard,
    textPrimary: AppColors.lightText,
    textSecondary: AppColors.lightMuted,
    accent: AppColors.lightAccent,
    secondary: AppColors.lightSecondary,
    onAccent: AppColors.lightOnAccent,
    success: AppColors.lightSuccess,
    warning: AppColors.lightWarning,
    error: AppColors.lightError,
    disabled: AppColors.lightDisabled,
    border: AppColors.lightBorder,
    overlay: AppColors.lightOverlay,
    hint: AppColors.lightHint,
    blocked: AppColors.lightBlocked,
    gradient: AppColors.lightGradient,
    orb: AppColors.lightAccent,
  );

  static const dark = GameColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    card: AppColors.darkCard,
    textPrimary: AppColors.darkText,
    textSecondary: AppColors.darkMuted,
    accent: AppColors.darkAccent,
    secondary: AppColors.darkSecondary,
    onAccent: AppColors.darkOnAccent,
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    error: AppColors.darkError,
    disabled: AppColors.darkDisabled,
    border: AppColors.darkBorder,
    overlay: AppColors.darkOverlay,
    hint: AppColors.darkHint,
    blocked: AppColors.darkBlocked,
    gradient: AppColors.darkGradient,
    orb: AppColors.darkAccent,
  );

  static GameColors of(BuildContext context) {
    final colors = Theme.of(context).extension<GameColors>();
    assert(colors != null, 'GameColors is missing from ThemeData.extensions');
    return colors ?? light;
  }

  @override
  GameColors copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? secondary,
    Color? onAccent,
    Color? success,
    Color? warning,
    Color? error,
    Color? disabled,
    Color? border,
    Color? overlay,
    Color? hint,
    Color? blocked,
    LinearGradient? gradient,
    Color? orb,
  }) {
    return GameColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      secondary: secondary ?? this.secondary,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      disabled: disabled ?? this.disabled,
      border: border ?? this.border,
      overlay: overlay ?? this.overlay,
      hint: hint ?? this.hint,
      blocked: blocked ?? this.blocked,
      gradient: gradient ?? this.gradient,
      orb: orb ?? this.orb,
    );
  }

  @override
  GameColors lerp(ThemeExtension<GameColors>? other, double t) {
    if (other is! GameColors) return this;
    return GameColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      blocked: Color.lerp(blocked, other.blocked, t)!,
      gradient: LinearGradient.lerp(gradient, other.gradient, t)!,
      orb: Color.lerp(orb, other.orb, t)!,
    );
  }
}
