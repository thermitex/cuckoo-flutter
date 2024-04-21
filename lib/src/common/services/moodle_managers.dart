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
    return _courses.map(
      (course) => course.id.toString()
    ).toList();
  }

  /// Generate course map for faster random access.
  void _generateCourseMap() {
    _courseMap = {};
    for (final course in _courses) {
      _courseMap[course.id] = course;
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

  /// Mapping of eventId -> MoodleEvent for faster access through ID.
  Map<num, MoodleEvent> _eventMap = {};

  /// Cache for holding sorted events.
  Map<MoodleEventSortingType, List<MoodleEvent>> _sortedEventsCache = {};

  // ---------------------Context Watch Interfaces Start---------------------
  // ONLY use the methods below when you are interacting with the manager
  // outside `moodle.dart` using `context.eventManager`.

  /// Unsorted events of current Moodle user.
  /// 
  /// Most likely this method doesn't need to be called. Use other interfaces
  /// which are more convenient instead.
  List<MoodleEvent> get events => _events;

  /// Sorted events given a sorting type.
  /// 
  /// If the events are sorted by course, they are first sorted by course in
  /// alphabetical order, then by time.
  List<MoodleEvent> sortedEvents({
    MoodleEventSortingType sortBy = MoodleEventSortingType.byTime
  }) {
    if (_sortedEventsCache[sortBy] != null) return _sortedEventsCache[sortBy]!;
    var events = _events.toList();

    int compareTime(MoodleEvent a, MoodleEvent b) =>
      b.timestart.compareTo(a.timestart);
    int compareCourseId(MoodleEvent a, MoodleEvent b) =>
      (a.course?.shortname ?? 'z').compareTo(b.course?.shortname ?? 'z');
    final compareCourse = compareCourseId.then(compareTime);

    if (sortBy == MoodleEventSortingType.byTime) {
      // Sort by time
      events.sort(compareTime);
    } else if (sortBy == MoodleEventSortingType.byCourse) {
      // Sort by course, then by time
      events.sort(compareCourse);
    }

    _sortedEventsCache[sortBy] = events;
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
  void _mergeEvents(List<MoodleEvent> others) {
    var mergedEvents = _events.where(
      (event) => event.eventtype == MoodleEventTypes.custom
    ).toList();
    for (var event in others) {
      final existingEvent = _eventMap[event.id];
      if (existingEvent != null) {
        event.completed = existingEvent.completed;
      }
      mergedEvents.add(event);
    }
    _events = mergedEvents;
    _eventsUpdated();
  }

  /// Event has been updated.
  void _eventsUpdated({bool notify = true}) {
    _generateEventMap();
    _sortedEventsCache = {};
    if (notify) notifyListeners();
  }

  /// Generate event map for faster random access.
  void _generateEventMap() {
    _eventMap = {};
    for (final event in _events) {
      _eventMap[event.id] = event;
    }
  }
}