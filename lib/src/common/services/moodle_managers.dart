part of 'moodle.dart';

/// Manager for Moodle login status.
///
/// Use context.watch to subscribe the login status and get the status through
/// `isUserLoggedIn` getter.
class MoodleLoginStatusManager with ChangeNotifier {
  late bool _loggedIn;

  // ---------------------Context Watch Interfaces Start---------------------
  // ONLY use the methods below when you are interacting with the manager
  // outside `moodle.dart` using `context.loginStatusManager`.

  /// Check if the user has logged in.
  bool get isUserLoggedIn => _loggedIn;

  // ----------------------Context Watch Interfaces End----------------------

  /// This will be maintained by `Moodle` class only. Do not call it
  /// elsewhere.
  set status(bool status) {
    if (_loggedIn != status) {
      _loggedIn = status;
      notifyListeners();
    }
  }
}

/// Manager for Moodle courses.
///
/// Use context.watch to subscribe the courses add the get the courses through
/// defined interfaces.
class MoodleCourseManager with ChangeNotifier {
  /// Where the courses are stored in memory.
  List<MoodleCourse> _courses = [];

  /// Mapping of courseId -> MoodleCourse for faster access through ID.
  Map<num, MoodleCourse> _courseMap = {};

  // ---------------------Context Watch Interfaces Start---------------------
  // ONLY use the methods below when you are interacting with the manager
  // outside `moodle.dart` using `context.eventManager`.

  /// Enrolled courses of current Moodle user.
  ///
  /// Most likely this method doesn't need to be called. Use other interfaces
  /// which are more convenient instead.
  List<MoodleCourse> get courses => _courses;

  // ----------------------Context Watch Interfaces End----------------------

  /// This will be maintained by `Moodle` class ONLY. DO NOT manually set the
  /// courses elsewhere. Any custom rules go to `Moodle` class.
  set courses(List<MoodleCourse> courses) {
    if (courses.length < _courses.length - 5 ||
        courses.isEmpty && _courses.isNotEmpty) {
      // That doesn't quite make sense, could be an error
      // Reject change
      return;
    }
    // Check existing course map for consistent coloring
    for (final course in courses) {
      final existingCourse = _courseMap[course.id];
      if (existingCourse != null) {
        course.colorHex = existingCourse.colorHex;
      }
    }
    _courses = courses;
    _generateCourseMap();
    notifyListeners();
  }

  /// Remove all courses without notification.
  ///
  /// For `Moodle` use ONLY. DO NOT call it elsewhere.
  void _clearAllCourses() {
    _courses = [];
  }

  /// Obtain a list containing IDs of all courses.
  ///
  /// For `Moodle` use ONLY. DO NOT call it elsewhere.
  List<String> _allCourseIds() {
    return _courses.map((course) => course.id.toString()).toList();
  }

  /// Generate course map for faster random access.
  void _generateCourseMap() {
    _courseMap = {};
    for (final course in _courses) {
      _courseMap[course.id] = course;
      // Assign a new color if a course does not have one
      if (ColorRegistry().colorForCourse(course) == null &&
          course.colorHex == null) {
        ColorRegistry().assignColorForCourse(course);
      }
    }
  }
}

/// Manager for Moodle events.
///
/// Use context.watch to subscribe the events add the get the events through
/// defined interfaces.
class MoodleEventManager with ChangeNotifier {
  /// Where the events are stored in memory.
  List<MoodleEvent> _events = [];

  /// Current manager status.
  MoodleManagerStatus _status = MoodleManagerStatus.idle;

  /// Mapping of eventId -> MoodleEvent for faster access through ID.
  Map<num, MoodleEvent> _eventMap = {};

  /// Cache for holding sorted events.
  Map<MoodleEventGroupingType, GroupedMoodleEvents> _groupedEventsCache = {};

  // ---------------------Context Watch Interfaces Start---------------------
  // ONLY use the methods below when you are interacting with the manager
  // outside `moodle.dart` using `context.eventManager`.

  /// Unsorted events of current Moodle user.
  ///
  /// Most likely this method doesn't need to be called. Use other interfaces
  /// which are more convenient instead.
  List<MoodleEvent> get events => _events;

  /// Get the current status of the event manager.
  ///
  /// Used for showing loading indicator / error on the page.
  MoodleManagerStatus get status => _status;

  /// Notify all event subscribers to rebuold their views.
  ///
  /// Used for asking the views to call `groupedEvents` once in order to sync
  /// any possible updates.
  void rebuildNow() => _notifyManually();

  /// Grouped events given a grouping type.
  ///
  /// If the events are grouped by course, they are first sorted by course in
  /// alphabetical order, then by time.
  GroupedMoodleEvents groupedEvents({
    MoodleEventGroupingType groupBy = MoodleEventGroupingType.byTime,
  }) {
    if (_groupedEventsCache[groupBy] != null) {
      return _groupedEventsCache[groupBy]!;
    }
    var sortedEvents = _events.toList();
    GroupedMoodleEvents events = {};

    // Define sort rules
    int compareTime(MoodleEvent a, MoodleEvent b) =>
        a.timestart.compareTo(b.timestart);
    int compareCourseId(MoodleEvent a, MoodleEvent b) =>
        (a.course?.fullname ?? 'z').compareTo(b.course?.fullname ?? 'z');
    final compareCourse = compareCourseId.then(compareTime);

    if (groupBy == MoodleEventGroupingType.byTime) {
      // Sort by time
      sortedEvents.sort(compareTime);
      // Then do grouping
      String getCategory(num remainingEpoch) {
        if (remainingEpoch < 7 * 86400) {
          return Constants.kEventInOneWeekGroupName;
        } else if (remainingEpoch < 30 * 86400) {
          return Constants.kEventInOneMonthGroupName;
        }
        return Constants.kEventAfterOneMonthGroupName;
      }

      if (sortedEvents.isNotEmpty) {
        for (final event in sortedEvents) {
          if (event.expired && !kDebugMode) continue;
          final category = getCategory(event.remainingTime);
          if (events[category] == null) {
            events[category] = [event];
          } else {
            events[category]!.add(event);
          }
        }
      }
    } else if (groupBy == MoodleEventGroupingType.byCourse) {
      // Sort by course, then by time
      sortedEvents.sort(compareCourse);
      // Then do grouping
      if (sortedEvents.isNotEmpty) {
        for (final event in sortedEvents) {
          if (event.expired && !kDebugMode) continue;
          final code = event.course?.courseCode ?? 'OTHERS';
          if (events[code] == null) {
            events[code] = [event];
          } else {
            events[code]!.add(event);
          }
        }
      }
    } else {
      throw Exception('Grouping type not recognized.');
    }

    // Caching
    _groupedEventsCache[groupBy] = events;
    return events;
  }

  // ----------------------Context Watch Interfaces End----------------------

  /// Timestamp where events are last updated.
  /// Not preserved in storage.
  DateTime? _eventsLastUpdated;

  /// This will be maintained by `Moodle` class ONLY. DO NOT manually set the
  /// events elsewhere. Any custom rules go to `Moodle` class.
  set events(List<MoodleEvent> events) {
    _events = events;
    _eventsUpdated();
  }

  /// This will be maintained by `Moodle` class ONLY. DO NOT manually set the
  /// events elsewhere. Any custom rules go to `Moodle` class.
  set status(MoodleManagerStatus status) {
    _status = status;
    notifyListeners();
  }

  /// Clear events except for custom events.
  ///
  /// For `Moodle` use ONLY. DO NOT call it elsewhere.
  void _clearEventsExceptCustom() {
    _events.removeWhere((event) => event.eventtype != MoodleEventTypes.custom);
    _eventsUpdated(notify: false);
  }

  /// Merge the new events with the current events.
  /// The custom events should remain in the list.
  ///
  /// For `Moodle` use ONLY. DO NOT call it elsewhere.
  void _mergeEvents(List<MoodleEvent> others, {bool notify = true}) {
    var mergedEvents = _events
        .where((event) =>
            event.eventtype == MoodleEventTypes.custom && !event.expired)
        .toList();
    for (var event in others) {
      if (event.expired && !kDebugMode) continue;
      final existingEvent = _eventMap[event.id];
      if (existingEvent != null) {
        event
          ..completed = existingEvent.completed
          ..cmid = existingEvent.cmid
          ..url = existingEvent.url;
      }
      // Crop event name
      if (event.eventtype == MoodleEventTypes.due &&
          event.name.endsWith('is due')) {
        event.name = event.name.replaceAll('is due', '').trim();
      }
      // Deal with strange chars
      event.name = event.name.replaceAll('&amp;', '&');
      mergedEvents.add(event);
    }
    _events = mergedEvents;
    _eventsUpdated(notify: notify);
  }

  /// Event has been updated.
  void _eventsUpdated({bool notify = true}) {
    _generateEventMap();
    _groupedEventsCache = {};
    if (notify) notifyListeners();
  }

  /// Manually notify.
  void _notifyManually() {
    notifyListeners();
  }

  /// Generate event map for faster random access.
  void _generateEventMap() {
    _eventMap = {};
    for (final event in _events) {
      _eventMap[event.id] = event;
    }
  }
}
