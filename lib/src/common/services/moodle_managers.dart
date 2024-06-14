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

  /// Current manager status.
  MoodleManagerStatus _status = MoodleManagerStatus.idle;

  /// Mapping of courseId -> MoodleCourse for faster access through ID.
  Map<num, MoodleCourse> _courseMap = {};

  /// Cache for holding sorted events.
  Map<MoodleCourseSortingType, List<MoodleCourse>> _sortedCoursesCache = {};

  // ---------------------Context Watch Interfaces Start---------------------
  // ONLY use the methods below when you are interacting with the manager
  // outside `moodle.dart` using `context.eventManager`.

  /// Enrolled courses of current Moodle user.
  ///
  /// Most likely this method doesn't need to be called. Use other interfaces
  /// which are more convenient instead.
  List<MoodleCourse> get courses => _courses;

  /// Get the current status of the course manager.
  ///
  /// Used for showing loading indicator / error on the page.
  MoodleManagerStatus get status => _status;

  /// Sorted courses given a sorting type.
  List<MoodleCourse> sortedCourses(
      {MoodleCourseSortingType sortBy = MoodleCourseSortingType.byCourseCode,
      MoodleCourseFilteringType filterBy = MoodleCourseFilteringType.none,
      bool showFavoriteOnly = false}) {
    late List<MoodleCourse> sortedCourses;
    if (_sortedCoursesCache[sortBy] != null) {
      sortedCourses = _sortedCoursesCache[sortBy]!;
    } else {
      sortedCourses = _courses.toList();

      if (sortBy == MoodleCourseSortingType.byCourseCode) {
        sortedCourses.sort((a, b) => a.courseCode.compareTo(b.courseCode));
      } else if (sortBy == MoodleCourseSortingType.byLastAccessed) {
        sortedCourses
            .sort((a, b) => (b.lastaccess ?? -1).compareTo(a.lastaccess ?? -1));
      } else {
        throw Exception('Sorting type not recognized.');
      }

      // Caching
      _sortedCoursesCache[sortBy] = sortedCourses;
    }
    // Filtering
    if (showFavoriteOnly) {
      sortedCourses =
          sortedCourses.where((c) => c.customFavorite ?? false).toList();
    } else if (filterBy == MoodleCourseFilteringType.byLatestSemester) {
      int? latestYear, latestSemester;
      Map<num, List<int?>> coursesYearAndSemester = {};

      for (final course in sortedCourses) {
        int? year, sem;
        String? yearString, semString;

        // One semester course
        final oneSemesterGroups =
            RegExp(r'^(.*)_(\w{1,3})_(\d{4})$').firstMatch(course.idnumber);
        if (oneSemesterGroups != null) {
          yearString = oneSemesterGroups.group(3);
          semString = oneSemesterGroups.group(2)?[0];
        } else {
          // Full year course
          final fullYearGroups =
              RegExp(r'^(.*)_(\d{4})$').firstMatch(course.idnumber);
          if (fullYearGroups != null) yearString = fullYearGroups.group(2);
        }

        if (yearString != null) year = int.tryParse(yearString);
        if (semString != null) {
          // Special case for summer semester
          if (semString.toLowerCase() == "s") semString = "3";

          sem = int.tryParse(semString);
        }

        if (year != null) {
          coursesYearAndSemester[course.id] = [year, sem];

          if (latestYear == null || year > latestYear) {
            latestYear = year;
            latestSemester = sem;
          } else if (year == latestYear &&
              sem != null &&
              (latestSemester == null || sem > latestSemester)) {
            latestSemester = sem;
          }
        }
      }

      // TODO should this be cached ?
      if (latestYear != null) {
        sortedCourses = sortedCourses
            .where((c) =>
                coursesYearAndSemester.containsKey(c.id) &&
                coursesYearAndSemester[c.id]!.first == latestYear &&
                (coursesYearAndSemester[c.id]!.last == null ||
                    coursesYearAndSemester[c.id]!.last == latestSemester))
            .toList();
      }
    }

    return sortedCourses;
  }

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
    // Check existing course map for consistent coloring, cached contents,
    // and favorite status as well
    final currentTimestamp = DateTime.now().secondEpoch;
    for (final course in courses) {
      final existingCourse = _courseMap[course.id];
      if (existingCourse != null) {
        course
          ..colorHex = existingCourse.colorHex
          ..customFavorite = existingCourse.customFavorite
          ..cachedContents = existingCourse.cachedContents
          ..cachedTime = existingCourse.cachedTime;
        // Expire cache if needed
        if (course.cachedTime != null &&
            currentTimestamp - course.cachedTime!.toInt() > 7 * 86400) {
          course.cachedContents = null;
        }
      }
      course.fullname = course.fullname.htmlParsed;
      course.displayname = course.displayname.htmlParsed;
    }
    _courses = courses;
    _generateCourseMap();
    _sortedCoursesCache = {};
    notifyListeners();
  }

  /// This will be maintained by `Moodle` class ONLY. DO NOT manually set the
  /// events elsewhere. Any custom rules go to `Moodle` class.
  set status(MoodleManagerStatus status) {
    _status = status;
    notifyListeners();
  }

  /// Remove all courses without notification.
  ///
  /// For `Moodle` use ONLY. DO NOT call it elsewhere.
  void _clearAllCourses() {
    _courses = [];
    _generateCourseMap();
  }

  /// Clear all cached course contents.
  ///
  /// For `Moodle` use ONLY. DO NOT call it elsewhere.
  void _clearCachedCourseContents() {
    for (final course in courses) {
      course.cachedContents = null;
    }
  }

  /// Obtain a list containing IDs of all courses.
  ///
  /// For `Moodle` use ONLY. DO NOT call it elsewhere.
  List<String> _allCourseIds() {
    return _courses.map((course) => course.id.toString()).toList();
  }

  /// Manually notify.
  void _notifyManually({bool flushCache = false}) {
    if (flushCache) _sortedCoursesCache = {};
    notifyListeners();
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
  final Map<num, MoodleEvent> _eventMap = {};

  /// Cache of workload heatmap.
  final Map<int, double> _workloadCache = {};

  /// Cache for holding sorted events.
  final Map<MoodleEventGroupingType, GroupedMoodleEvents> _groupedEventsCache =
      {};

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
    } else if (groupBy == MoodleEventGroupingType.none) {
      sortedEvents.sort(compareTime);
      events['ALL EVENTS'] = sortedEvents;
    } else {
      throw Exception('Grouping type not recognized.');
    }

    // Caching
    _groupedEventsCache[groupBy] = events;
    return events;
  }

  /// Obtain events due on a specific date.
  ///
  /// Used for displaying events on calendar page.
  List<MoodleEvent> eventsforDate(DateTime date) =>
      events.where((event) => isSameDay(event.time, date)).toList();

  /// Obtain a number to evaluate the workload on a specific date.
  ///
  /// Used for displaying heatmap on calendar page.
  double workloadOnDate(DateTime date, {double maxWl = 4}) {
    final cacheKey = date.year * 366 + date.month * 31 + date.day;
    var cachedWl = _workloadCache[cacheKey];
    if (cachedWl != null) return cachedWl;

    double wl = 0;
    for (final event in events) {
      final daysLater = date.daysTo(event.time);
      if (daysLater < 0 || event.isCompleted) continue;
      if (daysLater > 60) break;
      wl += 0.2 * (1 / (daysLater + 1)) + 0.8 * (30 - daysLater) / 30;
    }
    wl = wl.clamp(0, maxWl);
    _workloadCache[cacheKey] = wl;
    return wl;
  }

  // ----------------------Context Watch Interfaces End----------------------

  /// Notify all event subscribers to rebuild their views.
  ///
  /// Used for asking the views to call `groupedEvents` once in order to sync
  /// any possible updates.
  void rebuildNow() => _notifyManually(flushCache: true);

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
      event.name = event.name.htmlParsed;
      mergedEvents.add(event);
    }
    _events = mergedEvents;
    _eventsUpdated(notify: notify);
  }

  /// Add a custom event in the events list.
  void _addCustomEvent(MoodleEvent event) {
    // Double check that the event is custom
    assert(event.eventtype == MoodleEventTypes.custom);
    // Check if existing
    _events.removeWhere((e) => e.id == event.id);
    _events.add(event);
    _eventsUpdated();
  }

  /// Remove a custom event from the events list.
  void _removeCustomEvent(MoodleEvent event) {
    _events.removeWhere((e) => e.id == event.id);
    _eventsUpdated();
  }

  /// Event has been updated.
  void _eventsUpdated({bool notify = true}) {
    _generateEventMap();
    _groupedEventsCache.clear();
    _workloadCache.clear();
    Reminders().rescheduleAll();
    if (notify) notifyListeners();
  }

  /// Manually notify.
  void _notifyManually({bool flushCache = false}) {
    if (flushCache) {
      _groupedEventsCache.clear();
      _workloadCache.clear();
    }
    notifyListeners();
  }

  /// Generate event map for faster random access.
  void _generateEventMap() {
    _eventMap.clear();
    for (final event in _events) {
      _eventMap[event.id] = event;
    }
  }
}
