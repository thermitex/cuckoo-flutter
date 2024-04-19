import 'package:flutter/material.dart';
import 'package:cuckoo/src/common/ui/ui.dart';

/// Shipshape custom themes.
class CuckooTheme {

  // Light color scheme
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light, 
    primary: ColorPresets.primary, 
    onPrimary: ColorPresets.white, 
    secondary: ColorPresets.secondary, 
    onSecondary: ColorPresets.white, 
    error: ColorPresets.negativePrimary, 
    onError: ColorPresets.white, 
    background: ColorPresets.lightPrimaryBackground, 
    onBackground: ColorPresets.black, 
    surface: ColorPresets.primary, 
    onSurface: ColorPresets.white,
  );

  // Dark color scheme
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark, 
    primary: ColorPresets.primary, 
    onPrimary: ColorPresets.white, 
    secondary: ColorPresets.secondary, 
    onSecondary: ColorPresets.black, 
    error: ColorPresets.negativePrimary, 
    onError: ColorPresets.white, 
    background: ColorPresets.darkPrimaryBackground, 
    onBackground: ColorPresets.white, 
    surface: ColorPresets.primary, 
    onSurface: ColorPresets.white,
  );

  // Common text scheme
  static final TextTheme _commonTextTheme = TextTheme(
    displayLarge: TextStylePresets.title(size: 30),
    displayMedium: TextStylePresets.title(size: 20),
    displaySmall: TextStylePresets.title(size: 16),
    titleLarge: TextStylePresets.body(size: 24, weight: FontWeight.bold),
    titleMedium: TextStylePresets.body(size: 20, weight: FontWeight.bold),
    titleSmall: TextStylePresets.body(size: 16, weight: FontWeight.bold),
    bodyLarge: TextStylePresets.body(size: 18),
    bodyMedium: TextStylePresets.body(size: 14),
    bodySmall: TextStylePresets.body(size: 12),
  );

  /// Light theme data.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: _commonTextTheme.apply(
      bodyColor: ColorPresets.lightPrimaryText,
      displayColor: ColorPresets.lightPrimaryText,
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
      bodyColor: ColorPresets.darkPrimaryText,
      displayColor: ColorPresets.darkPrimaryText,
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
  final Color tertiaryBackground;
  final Color popUpBackground;

  const CuckooThemeExtension.fromBrightness({Brightness brightness = Brightness.light})
    : primaryText = brightness == Brightness.light ? ColorPresets.lightPrimaryText : ColorPresets.darkPrimaryText,
      primaryInverseText = brightness == Brightness.light ? ColorPresets.lightPrimaryInverseText : ColorPresets.darkPrimaryInverseText,
      secondaryText = brightness == Brightness.light ? ColorPresets.lightSecondaryText : ColorPresets.darkSecondaryText,
      tertiaryText = brightness == Brightness.light ? ColorPresets.lightTertiaryText : ColorPresets.darkTertiaryText,
      quaternaryText = brightness == Brightness.light ? ColorPresets.lightQuaternaryText : ColorPresets.darkQuaternaryText,
      separator = brightness == Brightness.light ? ColorPresets.lightSeparator : ColorPresets.darkSeparator,
      primaryBackground = brightness == Brightness.light ? ColorPresets.lightPrimaryBackground : ColorPresets.darkPrimaryBackground,
      primaryInverseBackground = brightness == Brightness.light ? ColorPresets.lightPrimaryInverseBackground : ColorPresets.darkPrimaryInverseBackground,
      secondaryBackground = brightness == Brightness.light ? ColorPresets.lightSecondaryBackground : ColorPresets.darkSecondaryBackground,
      popUpBackground = brightness == Brightness.light ? ColorPresets.lightPrimaryBackground : ColorPresets.darkSecondaryBackground,
      tertiaryBackground = brightness == Brightness.light ? ColorPresets.lightTertiaryBackground : ColorPresets.darkTertiaryBackground;
  
  const CuckooThemeExtension({
    this.primaryText = ColorPresets.lightPrimaryText,
    this.primaryInverseText = ColorPresets.lightPrimaryInverseText,
    this.secondaryText = ColorPresets.lightSecondaryText,
    this.tertiaryText = ColorPresets.lightTertiaryText,
    this.quaternaryText = ColorPresets.lightQuaternaryText,
    this.separator = ColorPresets.lightSeparator,
    this.primaryBackground = ColorPresets.lightPrimaryBackground,
    this.primaryInverseBackground = ColorPresets.lightPrimaryInverseBackground,
    this.secondaryBackground = ColorPresets.lightSecondaryBackground,
    this.tertiaryBackground = ColorPresets.lightTertiaryBackground,
    this.popUpBackground = ColorPresets.lightPrimaryBackground,
  });

  @override
  ThemeExtension<CuckooThemeExtension> copyWith() {
    throw UnimplementedError();
  }
  
  @override
  ThemeExtension<CuckooThemeExtension> lerp(covariant ThemeExtension<CuckooThemeExtension>? other, double t) {
    if (other is! CuckooThemeExtension) {
      return this;
    }

    return CuckooThemeExtension(
      primaryText: Color.lerp(primaryText, other.primaryText, t) ?? Colors.white,
      primaryInverseText: Color.lerp(primaryInverseText, other.primaryInverseText, t) ?? Colors.white,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t) ?? Colors.white,
      tertiaryText: Color.lerp(tertiaryText, other.tertiaryText, t) ?? Colors.white,
      quaternaryText: Color.lerp(quaternaryText, other.quaternaryText, t) ?? Colors.white,
      separator: Color.lerp(separator, other.separator, t) ?? Colors.white,
      primaryBackground: Color.lerp(primaryBackground, other.primaryBackground, t) ?? Colors.white,
      primaryInverseBackground: Color.lerp(primaryInverseBackground, other.primaryInverseBackground, t) ?? Colors.white,
      secondaryBackground: Color.lerp(secondaryBackground, other.secondaryBackground, t) ?? Colors.white,
      tertiaryBackground: Color.lerp(tertiaryBackground, other.tertiaryBackground, t) ?? Colors.white,
      popUpBackground: Color.lerp(tertiaryBackground, other.tertiaryBackground, t) ?? Colors.white,
    );
  }
  
}