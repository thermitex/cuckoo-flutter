import 'package:flutter/material.dart';

/// A series of text style presets to be used conveniently.
class ColorPresets {

  // ******* Universal *******

  static const Color primary = Color.fromARGB(255, 88, 108, 245);
  static const Color secondary = Color.fromARGB(255, 193, 91, 202);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static const Color negativePrimary = Color.fromARGB(255, 255, 91, 91);
  static const Color negativeTertiary = Color.fromARGB(26, 255, 91, 91);
  static const Color positivePrimary = primary;
  static const Color positiveTertiary = Color.fromARGB(26, 152, 202, 91);

  // ******* Light *******

  // Primary
  static const Color lightPrimaryText = black;
  static const Color lightPrimaryInverseText = white;
  static const Color lightPrimaryBackground = white;
  static const Color lightPrimaryInverseBackground = black;

  // Secondary
  static const Color lightSecondaryText = Color.fromARGB(153, 60, 60, 67);
  static const Color lightSecondaryBackground = Color.fromARGB(255, 242, 242, 247);

  // Tertiary
  static const Color lightTertiaryText = Color.fromARGB(77, 60, 60, 67);
  static const Color lightTertiaryBackground = Color.fromARGB(255, 226, 226, 231);

  // Quaternary
  static const Color lightQuaternaryText = Color.fromARGB(46, 60, 60, 67);

  // Others
  static const Color lightSeparator = Color.fromARGB(74, 60, 60, 67);

  // ******* Dark *******

  // Primary
  static const Color darkPrimaryText = white;
  static const Color darkPrimaryInverseText = black;
  static const Color darkPrimaryBackground = black;
  static const Color darkPrimaryInverseBackground = white;

  // Secondary
  static const Color darkSecondaryText = Color.fromARGB(153, 235, 235, 245);
  static const Color darkSecondaryBackground = Color.fromARGB(255, 28, 28, 30);

  // Tertiary
  static const Color darkTertiaryText = Color.fromARGB(77, 235, 235, 245);
  static const Color darkTertiaryBackground = Color.fromARGB(255, 44, 44, 46);

  // Quaternary
  static const Color darkQuaternaryText = Color.fromARGB(46, 235, 235, 245);

  // Others
  static const Color darkSeparator = Color.fromARGB(153, 84, 84, 88);

}
