import 'dart:io';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:home_widget/home_widget.dart';
import 'package:live_activities/live_activities.dart';

/// Control module for widget extensions, including iOS live activities, home
/// screen widgets, and lock screen widgets.
class WidgetControl {
  late LiveActivities liveActivitiesPlugin;

  bool _liveActivitiesEnabled = false;
  bool _homeWidgetEnabled = false;

  /// For storing ID of current live activity.
  String? _latestLiveActivityId;

  /// ID of currently pinned event on lock screen.
  num? _pinnedEventId;

  /// If live activities are enabled for the current device.
  static bool get liveActivitesEnabled =>
      WidgetControl()._liveActivitiesEnabled;

  /// If home screen widgets are enabled for the current device.
  static bool get homeWidgetEnabled => WidgetControl()._homeWidgetEnabled;

  /// Initialize widget control module.
  ///
  /// Keep this method synchronous.
  static void init() {
    final control = WidgetControl();
    // Live activity availability
    control.liveActivitiesPlugin = LiveActivities();
    control.liveActivitiesPlugin.areActivitiesEnabled().then((enabled) {
      if (enabled && Platform.isIOS) {
        control._liveActivitiesEnabled = true;
        control.liveActivitiesPlugin
            .init(appGroupId: Constants.kCuckooAppGroupId);
      }
    });
    // Home screen widget availability
    if (Platform.isIOS) {
      // Check if version larger than 14.0
      DeviceInfoPlugin().iosInfo.then((info) {
        if (info.systemVersion.compareTo('14') > 0) {
          control._homeWidgetEnabled = true;
          HomeWidget.setAppGroupId(Constants.kCuckooAppGroupId);
        }
      });
    }
  }

  /// Pin an event to the lock screen as live activity.
  Future<void> pinEventToLockScreen(MoodleEvent event) async {
    if (!_liveActivitiesEnabled) return;
    await liveActivitiesPlugin.endAllActivities();
    _latestLiveActivityId =
        await liveActivitiesPlugin.createActivity(event.contentForWidgets);
    _pinnedEventId = event.id;
  }

  /// Update external widgets to reflect potential event changes.
  ///
  /// This method will be called when events have been modified.
  Future<void> updateIfNeeded() async {
    if (_liveActivitiesEnabled) {
      final activeLiveActivityId =
          (await liveActivitiesPlugin.getAllActivitiesIds()).firstOrNull;
      // Clear storage if live activity has been cleared by user
      if (activeLiveActivityId == null) {
        _latestLiveActivityId = null;
        _pinnedEventId = null;
      }
      if (_latestLiveActivityId == activeLiveActivityId &&
          _pinnedEventId != null) {
        final event = Moodle().eventManager.eventForId(_pinnedEventId!);
        if (event != null && !event.isCompleted) {
          await liveActivitiesPlugin.updateActivity(
              _latestLiveActivityId!, event.contentForWidgets);
        } else {
          await liveActivitiesPlugin.endAllActivities();
          _latestLiveActivityId = null;
          _pinnedEventId = null;
        }
      }
      // Auto create pin
      else if (activeLiveActivityId == null &&
          falseSettingsValue(SettingsKey.autoPinEvent)) {
        // Check latest event
        final event = Moodle().eventManager.nextEvent();
        if (event != null &&
            _pinnedEventId != event.id &&
            event.remainingTime < 86400) {
          pinEventToLockScreen(event);
        }
      }
    }

    if (_homeWidgetEnabled) {
      final event = Moodle().eventManager.nextEvent();
      if (event != null) {
        HomeWidget.saveWidgetData<bool>('hasEvent', true);
        event.contentForWidgets.forEach((key, value) {
          HomeWidget.saveWidgetData(key, value);
        });
      } else {
        HomeWidget.saveWidgetData<bool>('hasEvent', false);
      }
      HomeWidget.updateWidget(iOSName: 'CuckooUpcomingEventWidget');
    }
  }

  // Singleton configurations
  WidgetControl._internal();

  factory WidgetControl() => _instance;

  static final WidgetControl _instance = WidgetControl._internal();
}

extension MoodleEventWidgetExtension on MoodleEvent {
  /// Content map for sharing info to widgets.
  Map<String, dynamic> get contentForWidgets => {
        'eventId': id,
        'courseCode': course?.courseCode ?? '',
        'courseColorHex': color?.toHex(includeAlpha: false) ?? '#ffffff',
        'eventTitle': name,
        'eventDueDate': timestart,
        'currentDate': DateTime.now().secondEpoch,
      };
}
