import 'dart:convert';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/global.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String kRemindersStorageKey = 'event_reminders';

/// Unit of the reminder timing.
class ReminderUnit {
  static const num seconds = 0;
  static const num minutes = 1;
  static const num hours = 2;
  static const num days = 3;
  static const num weeks = 4;
}

/// Relation of the reminder rule.
class ReminderRuleRelation {
  static const num and = 0;
  static const num or = 1;
}

/// Action of the reminder rule.
class ReminderRuleAction {
  static const num contains = 0;
  static const num doesNotContain = 1;
  static const num matches = 2;
}

/// Reminders service for Cuckoo.
class Reminders with ChangeNotifier {
  /// Shared preference instance.
  late SharedPreferences _prefs;

  /// List of reminders.
  late List<EventReminder> _reminders;

  /// Reminder map.
  late Map<num, EventReminder> _reminderMap;

  /// If timezone has been initialized.
  bool _tzInited = false;

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
      ..id = DateTime.now().secondEpoch
      ..rules = []
      ..scheduledNotifications = []
      ..amount = 30
      ..unit = ReminderUnit.minutes;
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
    await _scheduleNotification(reminder);
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
  Future<void> _scheduleNotification(EventReminder reminder) async {
    await _initTimezoneIfNeeded();
    reminder.scheduledNotifications.clear();
    var notificationId =
        (DateTime.now().secondEpoch + reminder.hashCode) & ((1 << 31) - 1);
    for (final event in Moodle().eventManager.events) {
      if (reminder.applicableToEvent(event)) {
        final content = event.course == null
            ? event.name
            : '${event.course!.courseCode} ${event.name}';
        // Check if scheduled time is earlier than now
        final time = reminder.scheduleTime(event);
        if (time.isBefore(tz.TZDateTime.now(tz.local))) continue;
        // Schedule the notification
        FlutterLocalNotificationsPlugin().zonedSchedule(
            notificationId,
            reminder.title!,
            content,
            time,
            const NotificationDetails(
                android: AndroidNotificationDetails(
              'reminder_noti',
              'Reminder notifications',
              importance: Importance.max,
              priority: Priority.high,
            )),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
        // Add id to reminder
        reminder.scheduledNotifications.add(notificationId++);
      }
    }
  }

  /// Cancel scheduled notifications for reminder.
  void _cancelNotification(EventReminder reminder) {
    for (final noti in reminder.scheduledNotifications) {
      FlutterLocalNotificationsPlugin().cancel(noti);
    }
  }

  /// Cancel all scheduled notifications.
  void _cancelAllNotifications() {
    FlutterLocalNotificationsPlugin().cancelAll();
  }

  /// Initialize timezone setup if needed.
  /// This function is lazily called and called once only.
  Future<void> _initTimezoneIfNeeded() async {
    if (_tzInited) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    _tzInited = true;
  }

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

  /// If the reminder can be applied to event.
  bool applicableToEvent(MoodleEvent event) {
    if (rules.isEmpty) return true;
    bool? ret;
    num relation = 0;
    // Evaluate sequentially
    for (final rule in rules) {
      final subject = [
        event.course?.courseCode,
        event.course?.fullname,
        event.name
      ][rule.subject.toInt()];
      late bool pass;
      if (subject == null) {
        pass = false;
      } else {
        final lowerSubject = subject.toLowerCase();
        final lowerPattern = rule.pattern.toLowerCase();
        switch (rule.action) {
          case ReminderRuleAction.contains:
            pass = lowerSubject.contains(lowerPattern);
            break;
          case ReminderRuleAction.doesNotContain:
            pass = !lowerSubject.contains(lowerPattern);
            break;
          case ReminderRuleAction.matches:
            pass = subject.contains(RegExp(rule.pattern));
            break;
          default:
            pass = false;
        }
      }
      if (ret == null) {
        ret = pass;
      } else {
        if (relation == ReminderRuleRelation.and) {
          ret &= pass;
        } else {
          ret |= pass;
        }
      }
      relation = rule.relationWithNext ?? 0;
    }
    bool r = ret!;
    // Event can't expire
    r &= !event.expired;
    // Ignore completed if required
    if (Settings().get<bool>(SettingsKey.reminderIgnoreCompleted) ?? true) {
      r &= !event.isCompleted;
    }
    // Ignore custom if required
    if (Settings().get<bool>(SettingsKey.reminderIgnoreCustom) ?? false) {
      r &= event.eventtype != MoodleEventTypes.custom;
    }
    return r;
  }

  /// Time to schedule notification of an event.
  tz.TZDateTime scheduleTime(MoodleEvent event) {
    var eventTime = tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.local, event.timestart.toInt() * 1000);
    // Consider relative timing
    switch (unit) {
      case ReminderUnit.seconds:
        eventTime = eventTime.add(Duration(seconds: -amount.toInt()));
        break;
      case ReminderUnit.minutes:
        eventTime = eventTime.add(Duration(minutes: -amount.toInt()));
        break;
      case ReminderUnit.hours:
        eventTime = eventTime.add(Duration(hours: -amount.toInt()));
        break;
      case ReminderUnit.days:
        eventTime = eventTime.add(Duration(days: -amount.toInt()));
        break;
      case ReminderUnit.weeks:
        eventTime = eventTime.add(Duration(days: -amount.toInt() * 7));
        break;
      default:
    }
    // Consider exact timing
    if (hour != null && min != null) {
      eventTime = eventTime.add(Duration(
          hours: hour!.toInt() - eventTime.hour,
          minutes: min!.toInt() - eventTime.minute));
    }
    return eventTime;
  }
}
