import 'dart:convert';

import 'package:cuckoo/src/common/services/global.dart';
import 'package:cuckoo/src/models/eventReminder.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kRemindersStorageKey = 'event_reminders';

/// Unit of the reminder timing.
class ReminderUnit {
  static const num second = 0;
  static const num minute = 1;
  static const num hours = 2;
  static const num days = 3;
  static const num weeks = 4;
}

/// Relation of the reminder rule.
class ReminderRuleRelation {
  static const num and = 0;
  static const num or = 1;
}

/// Reminders service for Cuckoo.
class Reminders with ChangeNotifier {
  /// Shared preference instance.
  late SharedPreferences _prefs;

  /// List of reminders.
  late List<EventReminder> _reminders;

  /// Reminder map.
  late Map<num, EventReminder> _reminderMap;

  /// Initialize Settings module.
  ///
  /// Keep this method synchronous.
  static void init() {
    final reminders = Reminders();
    reminders._prefs = Global.prefs;
    reminders._load();
  }

  // ------------Common interfaces------------

  /// If there are no existing reminders.
  bool get isEmpty => _reminders.isEmpty;

  /// Number of reminders.
  int get numReminders => _reminders.length;

  // Get reminder at a specific index.
  EventReminder reminderAtIndex(int index) => _reminders[index];

  /// Create a new reminder for configuration.
  static EventReminder create() {
    final reminder = EventReminder();
    // Supplement necessary information
    reminder
      ..id = DateTime.now().millisecondsSinceEpoch
      ..rules = []
      ..scheduledNotifications = []
      ..amount = 30
      ..unit = ReminderUnit.minute;
    return reminder;
  }

  /// Add or update a reminder.
  Future<void> add(EventReminder reminder) async {
    // First check if there is an existing reminder
    final existingReminder = _reminderMap[reminder.id];
    if (existingReminder != null) {
      final index = _reminders.indexOf(existingReminder);
      _cancelNotification(existingReminder);
      _reminders.remove(existingReminder);
      _reminders.insert(index, reminder);
    } else {
      _reminders.add(reminder);
    }
    _scheduleNotification(reminder);
    _remindersChanged();
  }

  /// Remove a reminder.
  Future<void> remove(num id) async {
    final reminderToRemove = _reminderMap[id];
    if (reminderToRemove != null) {
      _cancelNotification(reminderToRemove);
      _reminders.remove(reminderToRemove);
      _remindersChanged();
    }
  }

  /// Reschedule notifications of all reminders.
  Future<void> rescheduleAll() async {
    _cancelAllNotifications();
    for (final reminder in _reminders) {
      _scheduleNotification(reminder);
    }
  }

  // ------------Private Utilities------------

  /// Load reminders from storage.
  void _load() {
    final reminders = _prefs.getStringList(kRemindersStorageKey);
    try {
      if (reminders != null) {
        _reminders = reminders
            .map((reminder) => EventReminder.fromJson(jsonDecode(reminder)))
            .toList();
      } else {
        _reminders = [];
      }
    } catch (_) {
      _reminders = [];
    }
    _generateReminderMap();
  }

  /// Save reminders to storage.
  void _save() {
    _prefs.setStringList(kRemindersStorageKey,
        _reminders.map((reminder) => jsonEncode(reminder.toJson())).toList());
  }

  /// Generate reminder map for faster access by id.
  void _generateReminderMap() {
    _reminderMap = {};
    for (final reminder in _reminders) {
      _reminderMap[reminder.id] = reminder;
    }
  }

  /// Called when reminders have changed.
  void _remindersChanged() {
    _save();
    _generateReminderMap();
    notifyListeners();
  }

  /// Schedule notifications for reminder.
  void _scheduleNotification(EventReminder reminder) {}

  /// Cancel scheduled notifications for reminder.
  void _cancelNotification(EventReminder reminder) {}

  /// Cancel all scheduled notifications.
  void _cancelAllNotifications() {}

  // Singleton configurations
  Reminders._internal();

  factory Reminders() => _instance;

  static final Reminders _instance = Reminders._internal();
}

extension EventReminderExtenson on EventReminder {
  /// Timing description to be shown in reminder list.
  String get timingDescription {
    final unitDesc = ['second', 'minute', 'hour', 'day', 'week'];
    var desc =
        '$amount ${unitDesc[unit.toInt()]}${amount > 1 ? "s" : ""} before due';
    if (hour != null && min != null) {
      desc += ' at $hour:${min.toString().padLeft(2, "0")}';
    }
    return desc;
  }
}
