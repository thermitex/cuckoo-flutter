import 'dart:io';

import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:live_activities/live_activities.dart';

class WidgetControl {
  late LiveActivities liveActivitiesPlugin;

  bool _liveActivitiesEnabled = false;

  /// For storing ID of current live activity.
  String? _latestLiveActivityId;

  /// ID of currently pinned event on lock screen.
  num? _pinnedEventId;

  /// If live activities are enabled for the current device.
  static bool get liveActivitesEnabled =>
      WidgetControl()._liveActivitiesEnabled;

  /// Initialize widget control module.
  ///
  /// Keep this method synchronous.
  static void init() {
    final control = WidgetControl();
    control.liveActivitiesPlugin = LiveActivities();
    control.liveActivitiesPlugin.areActivitiesEnabled().then((enabled) {
      if (enabled && Platform.isIOS) {
        control._liveActivitiesEnabled = true;
        control.liveActivitiesPlugin
            .init(appGroupId: Constants.kCuckooAppGroupId);
      }
    });
  }

  /// Pin an event to the lock screen as live activity.
  Future<void> pinEvent(MoodleEvent event) async {
    if (!_liveActivitiesEnabled) return;
    await liveActivitiesPlugin.endAllActivities();
    _latestLiveActivityId =
        await liveActivitiesPlugin.createActivity(event.contentForWidgets);
    _pinnedEventId = event.id;
  }

  /// Update pinned event on the lock screen.
  Future<void> updateIfNeeded() async {
    if (!_liveActivitiesEnabled) return;
    if (_latestLiveActivityId != null && _pinnedEventId != null) {
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
  }

  // Singleton configurations
  WidgetControl._internal();

  factory WidgetControl() => _instance;

  static final WidgetControl _instance = WidgetControl._internal();
}
