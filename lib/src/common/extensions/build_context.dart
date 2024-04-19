import 'package:flutter/material.dart';
import 'package:cuckoo/src/common/ui/ui.dart';

extension BuildContextExtensions on BuildContext {
  /// Check if dark mode is currently enabled.
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Shortcut for getting current theme.
  ThemeData get theme => Theme.of(this);

  /// Shortcut for getting current text theme.
  TextTheme get textTheme => theme.textTheme;

  /// Shortcut for getting current color scheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get Shipshape specific theme.
  CuckooThemeExtension get cuckooTheme => Theme.of(this).extension<CuckooThemeExtension>()!;

  /// Shortcut for getting navigator.
  NavigatorState get navigator => Navigator.of(this);

  /// Shortcut for obtaining root scaffold;
  ScaffoldState get rootScaffold => findRootAncestorStateOfType<ScaffoldState>()!;

}