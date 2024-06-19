import 'package:flutter/material.dart';
import 'package:cuckoo/src/common/ui/ui.dart';

/// Shipshape custom themes.
class CuckooTheme {
  // Light color scheme
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: CuckooColors.primary,
    onPrimary: CuckooColors.white,
    secondary: CuckooColors.secondary,
    onSecondary: CuckooColors.white,
    error: CuckooColors.negativePrimary,
    onError: CuckooColors.white,
    background: CuckooColors.lightPrimaryBackground,
    onBackground: CuckooColors.black,
    surface: CuckooColors.primary,
    onSurface: CuckooColors.white,
  );

  // Dark color scheme
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: CuckooColors.primary,
    onPrimary: CuckooColors.white,
    secondary: CuckooColors.secondary,
    onSecondary: CuckooColors.black,
    error: CuckooColors.negativePrimary,
    onError: CuckooColors.white,
    background: CuckooColors.darkPrimaryBackground,
    onBackground: CuckooColors.white,
    surface: CuckooColors.primary,
    onSurface: CuckooColors.white,
  );

  // Common text scheme
  static final TextTheme _commonTextTheme = TextTheme(
    displayLarge: CuckooTextStyles.title(size: 30),
    displayMedium: CuckooTextStyles.title(size: 20),
    displaySmall: CuckooTextStyles.title(size: 16),
    titleLarge: CuckooTextStyles.body(size: 24, weight: FontWeight.bold),
    titleMedium: CuckooTextStyles.body(size: 20, weight: FontWeight.bold),
    titleSmall: CuckooTextStyles.body(size: 16, weight: FontWeight.bold),
    bodyLarge: CuckooTextStyles.body(size: 18),
    bodyMedium: CuckooTextStyles.body(size: 14),
    bodySmall: CuckooTextStyles.body(size: 12),
  );

  /// Light theme data.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: _commonTextTheme.apply(
      bodyColor: CuckooColors.lightPrimaryText,
      displayColor: CuckooColors.lightPrimaryText,
    ),
    colorScheme: _lightColorScheme,
    extensions: const <ThemeExtension<dynamic>>[
      CuckooThemeExtension.fromBrightness(brightness: Brightness.light),
    ],
  );

  /// Dark theme data.
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: _commonTextTheme.apply(
      bodyColor: CuckooColors.darkPrimaryText,
      displayColor: CuckooColors.darkPrimaryText,
    ),
    colorScheme: _darkColorScheme,
    extensions: const <ThemeExtension<dynamic>>[
      CuckooThemeExtension.fromBrightness(brightness: Brightness.dark),
    ],
  );
}

/// Custom theme extension with multiple color support.
@immutable
class CuckooThemeExtension extends ThemeExtension<CuckooThemeExtension> {
  final Color primaryText;
  final Color primaryInverseText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color quaternaryText;
  final Color separator;
  final Color primaryBackground;
  final Color primaryInverseBackground;
  final Color secondaryBackground;
  final Color secondaryTransBg;
  final Color tertiaryBackground;
  final Color popUpBackground;

  const CuckooThemeExtension.fromBrightness(
      {Brightness brightness = Brightness.light})
      : primaryText = brightness == Brightness.light
            ? CuckooColors.lightPrimaryText
            : CuckooColors.darkPrimaryText,
        primaryInverseText = brightness == Brightness.light
            ? CuckooColors.lightPrimaryInverseText
            : CuckooColors.darkPrimaryInverseText,
        secondaryText = brightness == Brightness.light
            ? CuckooColors.lightSecondaryText
            : CuckooColors.darkSecondaryText,
        tertiaryText = brightness == Brightness.light
            ? CuckooColors.lightTertiaryText
            : CuckooColors.darkTertiaryText,
        quaternaryText = brightness == Brightness.light
            ? CuckooColors.lightQuaternaryText
            : CuckooColors.darkQuaternaryText,
        separator = brightness == Brightness.light
            ? CuckooColors.lightSeparator
            : CuckooColors.darkSeparator,
        primaryBackground = brightness == Brightness.light
            ? CuckooColors.lightPrimaryBackground
            : CuckooColors.darkPrimaryBackground,
        primaryInverseBackground = brightness == Brightness.light
            ? CuckooColors.lightPrimaryInverseBackground
            : CuckooColors.darkPrimaryInverseBackground,
        secondaryBackground = brightness == Brightness.light
            ? CuckooColors.lightSecondaryBackground
            : CuckooColors.darkSecondaryBackground,
        secondaryTransBg = brightness == Brightness.light
            ? CuckooColors.lightSecondaryTransBg
            : CuckooColors.darkSecondaryTransBg,
        popUpBackground = brightness == Brightness.light
            ? CuckooColors.lightPrimaryBackground
            : CuckooColors.darkSecondaryBackground,
        tertiaryBackground = brightness == Brightness.light
            ? CuckooColors.lightTertiaryBackground
            : CuckooColors.darkTertiaryBackground;

  const CuckooThemeExtension({
    this.primaryText = CuckooColors.lightPrimaryText,
    this.primaryInverseText = CuckooColors.lightPrimaryInverseText,
    this.secondaryText = CuckooColors.lightSecondaryText,
    this.tertiaryText = CuckooColors.lightTertiaryText,
    this.quaternaryText = CuckooColors.lightQuaternaryText,
    this.separator = CuckooColors.lightSeparator,
    this.primaryBackground = CuckooColors.lightPrimaryBackground,
    this.primaryInverseBackground = CuckooColors.lightPrimaryInverseBackground,
    this.secondaryBackground = CuckooColors.lightSecondaryBackground,
    this.tertiaryBackground = CuckooColors.lightTertiaryBackground,
    this.popUpBackground = CuckooColors.lightPrimaryBackground,
    this.secondaryTransBg = CuckooColors.lightSecondaryTransBg,
  });

  @override
  ThemeExtension<CuckooThemeExtension> copyWith() {
    throw UnimplementedError();
  }

  @override
  ThemeExtension<CuckooThemeExtension> lerp(
      covariant ThemeExtension<CuckooThemeExtension>? other, double t) {
    if (other is! CuckooThemeExtension) {
      return this;
    }

    return CuckooThemeExtension(
      primaryText:
          Color.lerp(primaryText, other.primaryText, t) ?? Colors.white,
      primaryInverseText:
          Color.lerp(primaryInverseText, other.primaryInverseText, t) ??
              Colors.white,
      secondaryText:
          Color.lerp(secondaryText, other.secondaryText, t) ?? Colors.white,
      tertiaryText:
          Color.lerp(tertiaryText, other.tertiaryText, t) ?? Colors.white,
      quaternaryText:
          Color.lerp(quaternaryText, other.quaternaryText, t) ?? Colors.white,
      separator: Color.lerp(separator, other.separator, t) ?? Colors.white,
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t) ??
              Colors.white,
      primaryInverseBackground: Color.lerp(
              primaryInverseBackground, other.primaryInverseBackground, t) ??
          Colors.white,
      secondaryBackground:
          Color.lerp(secondaryBackground, other.secondaryBackground, t) ??
              Colors.white,
      secondaryTransBg:
          Color.lerp(secondaryTransBg, other.secondaryTransBg, t) ??
              Colors.white,
      tertiaryBackground:
          Color.lerp(tertiaryBackground, other.tertiaryBackground, t) ??
              Colors.white,
      popUpBackground:
          Color.lerp(tertiaryBackground, other.tertiaryBackground, t) ??
              Colors.white,
    );
  }
}
