import 'dart:convert';
import 'dart:math';

import 'package:cuckoo/src/common/services/global.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kColorRegistryMappingStorageKey = 'color_registry_mapping';

class ColorRegistry {
  /// Shared preference instance.
  late SharedPreferences _prefs;

  /// Mapping for course Id -> Color index.
  Map<String, dynamic> _courseColorMapping = {};

  final List<Color> _cuckooColors = const [
    Color.fromARGB(255, 88, 108, 245),
    Color.fromARGB(255, 21, 166, 218),
    Color.fromARGB(255, 67, 145, 255),
    Color.fromARGB(255, 16, 131, 218),
    Color.fromARGB(255, 92, 136, 255),
    Color.fromARGB(255, 44, 72, 255),
    Color.fromARGB(255, 103, 120, 228),
    Color.fromARGB(255, 127, 115, 252),
    Color.fromARGB(255, 105, 88, 255),
    Color.fromARGB(255, 153, 90, 255),
    Color.fromARGB(255, 179, 132, 255),
    Color.fromARGB(255, 210, 131, 255),
    Color.fromARGB(255, 164, 68, 220),
    Color.fromARGB(255, 180, 49, 255),
    Color.fromARGB(255, 202, 46, 210),
    Color.fromARGB(255, 238, 73, 247),
    Color.fromARGB(255, 226, 9, 194),
  ];

  /// Initialize Color registry module.
  ///
  /// Keep this method synchronous.
  static void init() {
    final registry = ColorRegistry();
    registry._prefs = Global.prefs;

    // Load map from prefs
    final storedMapping =
        Global.prefs.getString(kColorRegistryMappingStorageKey);
    if (storedMapping != null) {
      registry._courseColorMapping = jsonDecode(storedMapping);
    }
  }

  /// Assign a new color for the course.
  void assignColorForCourse(MoodleCourse course) {
    // Generate a random color index
    var colorIndex = Random().nextInt(_cuckooColors.length);
    if (_courseColorMapping.length < _cuckooColors.length) {
      // Avoid repeat as much as we can
      while (_courseColorMapping.values.contains(colorIndex)) {
        colorIndex = (colorIndex + 1) % _cuckooColors.length;
      }
    }

    // Record mapping and save
    _courseColorMapping[course.id.toString()] = colorIndex;
    _prefs.setString(
        kColorRegistryMappingStorageKey, jsonEncode(_courseColorMapping));
  }

  /// Color for a specific course.
  Color? colorForCourse(MoodleCourse course) {
    var index = _courseColorMapping[course.id.toString()] as num?;
    if (index != null) return _cuckooColors[index.toInt()];
    return null;
  }

  /// Reset all course-color mappings
  void resetAllMappings() {
    _courseColorMapping = {};
  }

  ColorRegistry._internal();

  factory ColorRegistry() => _instance;

  static final ColorRegistry _instance = ColorRegistry._internal();
}
