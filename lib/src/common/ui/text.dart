import 'dart:io';

import 'package:flutter/material.dart';

/// A series of text style presets to be used conveniently.
class CuckooTextStyles {
  /// Font family name for large titles.
  /// Only used where most emphasis is required.
  static const String _titleFontFamily = 'Montserrat';

  /// Font family name for body texts and normal titles.
  /// Only applicable to Android.
  static const String _bodyFontFamily = 'Inter';

  // Easier constructors:
  /// Text style for titles.
  static TextStyle title(
      {double size = 20, FontWeight weight = FontWeight.bold, Color? color}) {
    return TextStyle(
      fontFamily: _titleFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  /// Text style for body.
  static TextStyle body(
      {double size = 14,
      FontWeight weight = FontWeight.normal,
      Color? color,
      double? height}) {
    return TextStyle(
        fontFamily:
            Platform.isAndroid ? _bodyFontFamily : 'CupertinoSystemText',
        fontSize: size,
        fontWeight: weight,
        letterSpacing: Platform.isIOS ? 0 : null,
        color: color,
        height: height);
  }

  /// Text style for pop up displays.
  static TextStyle popUpDisplayBody(
          {FontWeight weight = FontWeight.normal, Color? color}) =>
      body(size: 14.5, weight: weight, color: color);

  /// Text style for text fields.
  static TextStyle textFieldBody({Color? color}) =>
      body(size: 15.5, color: color);
}
