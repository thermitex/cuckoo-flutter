part of 'moodle.dart';

typedef GroupedMoodleEvents = Map<String, List<MoodleEvent>>;
typedef MoodleCourseContent = List<MoodleCourseSection>;

/// Status of Moodle authentication.
enum MoodleAuthStatus { ignore, incomplete, fail, success }

/// Moodle events grouping type.
enum MoodleEventGroupingType { byTime, byCourse, none }

/// Moodle courses sorting type.
enum MoodleCourseSortingType { byCourseCode, byLastAccessed }

/// Moodle courses filtering type.
enum MoodleCourseFilteringType { none, byLatestSemester }

/// Moodle storage keys.
class MoodleStorageKeys {
  static const wstoken = 'moodle_wstoken';
  static const privatetoken = 'moodle_privatetoken';
  static const autoLoginInfo = 'moodle_autologininfo';
  static const siteInfo = 'moodle_site_info';
  static const courses = 'moodle_courses';
  static const events = 'moodle_events';
}

/// Moodle function names.
class MoodleFunctions {
  static const getSiteInfo = 'core_webservice_get_site_info';
  static const getEnrolledCourses = 'core_enrol_get_users_courses';
  static const callExternal = 'tool_mobile_call_external_functions';
  static const getCalendarEvents = 'core_calendar_get_calendar_events';
  static const getEventById = 'core_calendar_get_calendar_event_by_id';
  static const getCompletionStatus =
      'core_completion_get_activities_completion_status';
  static const getAutoLoginKey = 'tool_mobile_get_autologin_key';
  static const updateCompletionStatus =
      'core_completion_update_activity_completion_status_manually';
  static const getCourseContents = 'core_course_get_contents';
  static const recordCourseView = 'core_course_view_course';
  static const getGradesTable = 'gradereport_user_get_grades_table';
}

/// Types of Moodle events.
class MoodleEventTypes {
  static const due = 'due';
  static const user = 'user';
  static const custom = 'custom';
}

/// Status of a Moodle manager.
enum MoodleManagerStatus { idle, updating, error }

/// Subrequest in a moodle function request.
/// However, in most cases, there is no need to use subrequests.
class MoodleFunctionSubrequest {
  MoodleFunctionSubrequest(
    this.functionName, {
    this.params,
    this.filter = true,
    this.fileUrl = true,
  });

  final String functionName;
  final Map<String, dynamic>? params;
  final bool filter;
  final bool fileUrl;

  /// Convert to string given the subrequest index.
  Map<String, String> bodyParamsWithIndex(int index) {
    return {
      'requests[$index][function]': functionName,
      'requests[$index][arguments]': jsonEncode(params ?? {}),
      'requests[$index][settingfilter]': filter ? "1" : "0",
      'requests[$index][settingfileurl]': fileUrl ? "1" : "0"
    };
  }
}

/// Moodle function call reponse wrapper.
class MoodleFunctionResponse {
  MoodleFunctionResponse(this.response) : data = response?.data;

  MoodleFunctionResponse.error()
      : response = null,
        data = null;

  /// Raw Dio response.
  final Response? response;

  /// Data shortcut.
  final dynamic data;

  /// If the Moodle function has failed.
  bool get fail {
    bool errStatus = (response?.statusCode ?? 500) != 200;
    bool exceptionExists =
        data is Map && data?['exception'] == 'moodle_exception';
    return errStatus || exceptionExists;
  }

  /// Get error code if any.
  String? get errCode => data?['errorcode'];

  /// Get error message if any.
  String? get errMessage => data?['message'];

  /// Get subresponse data at specific index.
  T? subResponseData<T>(int index, {bool requireJSONDecode = true}) {
    if (data is! Map<String, dynamic>) return null;
    final responses = data['responses'];
    if (responses is! List) return null;
    var subData = responses[index]['data'];
    if (requireJSONDecode) {
      try {
        subData = jsonDecode(subData);
      } catch (e) {
        return null;
      }
    }
    return subData as T;
  }
}

/// Shortcuts for Moodle event.
extension MoodleEventExtension on MoodleEvent {
  /// Course for Moodle event.
  MoodleCourse? get course => Moodle.courseForEvent(this);

  /// Remaining seconds for Moodle event.
  num get remainingTime => timestart - DateTime.now().secondEpoch;

  /// Get event time in DateTime object.
  DateTime get time =>
      DateTime.fromMillisecondsSinceEpoch(timestart.toInt() * 1000);

  /// If the event is marked as completed.
  bool get isCompleted =>
      completed ?? (state == null ? null : state! >= 1) ?? false;

  /// Mark event as completed.
  set completionMark(bool c) {
    completed = c;
    Moodle().eventManager._notifyManually(flushCache: true);
    Moodle()._saveEvents();
    bool shouldSync = trueSettingsValue(SettingsKey.syncCompletionStatus);
    if (shouldSync) Moodle.syncEventCompletion();
  }

  /// Event associated color.
  Color? get color => course?.color;

  /// If the event has expired.
  bool get expired => remainingTime < 0;

  /// A blank template for custom event.
  static MoodleEvent custom() {
    final event = MoodleEvent();
    event
      ..id = DateTime.now().secondEpoch
      ..name = ''
      ..description = ''
      ..timestart = DateTime.now().secondEpoch + 3600
      ..eventtype = MoodleEventTypes.custom
      ..hascompletion = false;
    return event;
  }
}

/// Shortcuts for Moodle course.
extension MoodleCourseExtension on MoodleCourse {
  /// Standard ABCDXXXX course code.
  String get courseCode => fullname.split(' ').first;

  /// Course name without course code.
  String get nameWithoutCode => fullname.split(' ').sublist(1).join(' ');

  /// Course assigned color.
  Color get color =>
      HexColor.fromHex(colorHex) ??
      ColorRegistry().colorForCourse(this) ??
      CuckooColors.primary;

  /// Set the course as favorite.
  set favoriteMark(bool fav) {
    customFavorite = fav;
    Moodle().courseManager._notifyManually();
    Moodle()._saveCourses();
  }

  /// Mark the access to the course.
  void markAccess() {
    lastaccess = DateTime.now().secondEpoch;
    Moodle().courseManager._notifyManually(flushCache: true);
  }
}

/// Shortcuts for Moodle Course Section
extension MoodleCourseSectionExtension on MoodleCourseSection {
  /// If a section is empty.
  bool get isEmpty => summary.isEmpty && modules.isEmpty;

  /// If a section is visible.
  bool get isVisible => visible == 1 && (uservisible ?? false);
}

/// Shortcuts for Moodle Module Section
extension MoodleCourseModuleExtension on MoodleCourseModule {
  /// If the module is associated with a downloadable file.
  bool get hasDownloadableFile =>
      (downloadcontent ?? 0) > 0 &&
      contents != null &&
      contentsinfo != null &&
      modname == 'resource';
}

/// Shortcuts for Moodle Course Grades
extension MoodleCourseGradeExtension on MoodleCourseGrade {
  /// Get the double value of the grade.
  double? get gradeValue => double.tryParse(grade);

  /// Get the grade string.
  String get gradeStr => gradeValue?.toStringAsFixed(1) ?? grade;

  /// Get both ends of the range.
  List<int>? get rangeEnds {
    final comps = range.split('&ndash;');
    if (comps.length == 2) {
      final ends = comps.map((c) => int.tryParse(c)).toList();
      if (ends.first != null && ends.last != null) {
        return [ends.first!, ends.last!];
      }
    }
    return null;
  }

  /// Parse the title of the grade.
  String get title {
    final document = parse(itemname);
    final titles = document.getElementsByClassName('gradeitemheader');
    if (titles.isNotEmpty) {
      return titles.first.text;
    }
    return 'Unkown Grade Item';
  }

  /// Get url of the grade.
  String? get itemUrl {
    final document = parse(itemname);
    final links = document.getElementsByTagName('a');
    if (links.isNotEmpty) {
      return links.first.attributes['href'];
    }
    return null;
  }
}
