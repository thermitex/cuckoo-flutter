import 'package:cuckoo/src/common/services/global.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsKey {
  static const String deadlineDisplay = 'settings_deadline_display';
  static const String eventGroupingType = 'settings_event_grouping';
}

/// Settings service for Cuckoo.
class Settings with ChangeNotifier {
  /// Shared preference instance.
  late SharedPreferences _prefs;

  // A layer of cache.
  late Map<String, dynamic> _cache;

  /// Initialize Settings module.
  ///
  /// Keep this method synchronous.
  static void init() {
    final settings = Settings();
    settings._prefs = Global.prefs;
    settings._cache = {};
  }

  // ------------Common interfaces------------

  /// Get value for a settings key.
  ///
  /// To subscribe to a key change of `Settings`, use `context.settingsValue`.
  /// It is a handy shortcut to watch a specific key of the Settings service.
  /// NEVER watch the entire Settings, as it will generate unnecessary extra
  /// rebuilds, which can be costly.
  T? get<T>(String key) {
    T? cached = _cache[key] as T?;
    if (cached == null) {
      T? stored = _prefs.get(key) as T?;
      if (stored != null) _cache[key] = stored;
      return stored;
    }
    return cached;
  }

  /// Set value for a settings key.
  Future<bool> set<T>(String key, T value, {bool notify = true}) {
    if ([bool, int, double, String].contains(T)) {
      // Save to cache first
      _cache[key] = value;
      if (notify) notifyListeners();
      return _setValueForKey<T>(key, value);
    }
    throw Exception('Type not allowed');
  }

  /// Switch between choices.
  Future<bool> switchChoice(String key, int numChoices,
      {int defaultChoice = 0, bool notify = true}) {
    var choice = get<int>(key) ?? defaultChoice;
    choice = (choice + 1) % numChoices;
    return set<int>(key, choice, notify: notify);
  }

  /// Toggle boolean values.
  Future<bool> toggleValue(String key,
      {bool defaultValue = false, bool notify = true}) {
    var value = get<bool>(key) ?? defaultValue;
    value = !value;
    return set<bool>(key, value, notify: notify);
  }

  // ------------Private Utilities------------

  /// Save to storage asynchronously.
  Future<bool> _setValueForKey<T>(String key, T value) async {
    switch (T) {
      case const (bool):
        return await _prefs.setBool(key, value as bool);
      case const (int):
        return await _prefs.setInt(key, value as int);
      case const (double):
        return await _prefs.setDouble(key, value as double);
      case const (String):
        return await _prefs.setString(key, value as String);
    }
    return false;
  }

  // Singleton configurations
  Settings._internal();

  factory Settings() => _instance;

  static final Settings _instance = Settings._internal();
}
