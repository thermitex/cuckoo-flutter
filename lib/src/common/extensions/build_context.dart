import 'dart:io';

import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/reminders.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:flutter/material.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:provider/provider.dart';

extension BuildContextExtensions on BuildContext {
  /// Check if dark mode is currently enabled.
  bool get isDarkMode {
    final theme = settingsValue<int>(SettingsKey.themeMode) ?? 0;
    if (theme == 0) {
      final brightness = MediaQuery.of(this).platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return theme == 2;
    }
  }

  // Push a new route based on the current platform.
  Future<T?> platformDependentPush<T>({required WidgetBuilder builder}) {
    return Navigator.of(this, rootNavigator: Platform.isAndroid)
        .push(MaterialPageRoute(
      fullscreenDialog: Platform.isAndroid,
      builder: (context) => builder(context),
    ));
  }

  /// Shortcut for getting current theme.
  ThemeData get theme => Theme.of(this);

  /// Shortcut for getting current text theme.
  TextTheme get textTheme => theme.textTheme;

  /// Shortcut for getting current color scheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get Shipshape specific theme.
  CuckooThemeExtension get cuckooTheme =>
      Theme.of(this).extension<CuckooThemeExtension>()!;

  /// Shortcut for getting navigator.
  NavigatorState get navigator => Navigator.of(this);

  /// Shortcut for obtaining root scaffold.
  ScaffoldState get rootScaffold =>
      findRootAncestorStateOfType<ScaffoldState>()!;

  /// Moodle login status manager.
  MoodleLoginStatusManager get loginStatusManager =>
      watch<MoodleLoginStatusManager>();

  /// Moodle courses manager.
  MoodleCourseManager get courseManager => watch<MoodleCourseManager>();

  /// Moodle events manager.
  MoodleEventManager get eventManager => watch<MoodleEventManager>();

  /// Settings notifier.
  @Deprecated('Use settingsValue')
  Settings get settings => watch<Settings>();

  /// Reminders notifier
  Reminders get reminders => watch<Reminders>();

  /// Watch a specific settings key.
  T? settingsValue<T>(String key) =>
      select<Settings, T?>((settings) => settings.get<T>(key));
}
