import 'dart:convert';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

/// Domain name of HKU Moodle.
const String kHKUMoodleDomain = 'moodle.hku.hk';

/// Status of Moodle authentication.
enum MoodleAuthStatus { ignore, incomplete, fail, success }

/// Moodle storage keys.
class MoodleStorageKeys {
  static const wstoken = 'moodle_wstoken';
  static const privatetoken = 'moodle_privatetoken';
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
}

/// Types of Moodle events.
class MoodleEventTypes {
  static const due = 'due';
  static const user = 'user';
  static const custom = 'custom';
}

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
  MoodleFunctionResponse(this.response)
  : data = response.data;

  /// Raw Dio response.
  final Response response;

  /// Data shortcut.
  final dynamic data;

  /// If the Moodle function has failed.
  bool get fail {
    bool errStatus = (response.statusCode ?? 500) != 200;
    bool exceptionExists = data is Map && data?['exception'] == 'moodle_exception';
    return errStatus && exceptionExists;
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

/// The class for all Moodle services used in Cuckoo.
/// 
/// Cuckoo communicates with Moodle via web service token, which can be obtained
/// by calling mobile/launch.php endpoint on Moodle and faking itself to be the
/// official Moodle app. The web service token is binded with the logged in user
/// and therefore the user no longer needs to login every time. The token,
/// according to the document, should be available for 3 months.
class Moodle {

  // Instance variables

  /// Web service tokens used in calling Moodle service.
  String? _wstoken;
  String? _privatetoken;

  /// Moodle domain.
  String _domain = kHKUMoodleDomain;

  /// User ID of the Moodle user.
  String get _userId => _siteInfo.userid.toString();

  /// User name of the Moodle user.
  String get _username => _siteInfo.username;

  /// Site info for current Moodle user.
  late MoodleSiteInfo _siteInfo;

  /// Shared preference instance.
  late SharedPreferences _prefs;

  /// Enrolled courses of current Moodle user.
  List<MoodleCourse> _courses = [];

  /// Mapping of courseId -> MoodleCourse for faster access through ID.
  Map<num, MoodleCourse> _courseMap = {};

  /// Events of current Moodle user.
  List<MoodleEvent> _events = [];

  /// Timestamp where events are last updated.
  /// Not preserved in storage.
  DateTime? _eventsLastUpdated;

  // Static interfaces

  // ------------Common Interfaces------------

  /// Check if the user has already logged into Moodle.
  /// 
  /// Note that this property DOES NOT check if the connection is still valid.
  static bool get isUserLoggedIn => Moodle()._wstoken != null;

  /// Set domain of the Moodle.
  /// 
  /// Defaults to HKU Moodle. Note that when a domain changes, all configs
  /// should be reset. Recommend to do this ONLY in logged out status.
  static set domain(String domain) => Moodle()._domain = domain;

  /// Username of the current user.
  /// 
  /// DOES NOT check if the user is already logged in.
  static String get username => Moodle()._username;

  /// Full name of the current user.
  /// 
  /// DOES NOT check if the user is already logged in.
  static String get fullname => Moodle()._siteInfo.fullname;

  /// Profile picture URL of the current user.
  /// 
  /// DOES NOT check if the user is already logged in.
  static String get profilePicUrl => Moodle()._siteInfo.userpictureurl;

  /// Initialize Moodle service module.
  static Future<void> init() async {
    final moodle = Moodle();
    WidgetsFlutterBinding.ensureInitialized();
    moodle._prefs = await SharedPreferences.getInstance();
    await moodle._load();

    // If the user already logged in, get site info in the background again
    // to take any updates into consideration.
    if (isUserLoggedIn) {
      final response = await callFunction(MoodleFunctions.getSiteInfo);
      if (!response.fail) moodle._siteInfo = MoodleSiteInfo.fromJson(response.data!);
      moodle._save();
    }
  }

  /// Logout current user and clear storage.
  static Future<void> logout() async {
    if (!isUserLoggedIn) return;
    final moodle = Moodle();
    moodle._wstoken = null;
    moodle._privatetoken = null;
    moodle._courses = [];
    moodle._events = [];
    moodle._eventsLastUpdated = null;
    // Clear storage
    for (String key in [
      MoodleStorageKeys.wstoken,
      MoodleStorageKeys.privatetoken,
      MoodleStorageKeys.siteInfo,
      MoodleStorageKeys.courses,
      MoodleStorageKeys.events,
    ]) {
      await moodle._prefs.remove(key);
    }
  }

  /// Call a generic moodle function.
  /// 
  /// You should always use existing static interfaces first. If the function
  /// is not defined, first think if you need to define one before calling this
  /// interface. Not recommended to call outside `moodle.dart`.
  static Future<MoodleFunctionResponse> callFunction(
    String functionName, {
    List<MoodleFunctionSubrequest>? subrequests,
    Map<String, dynamic>? params,
    bool filter = true,
    bool fileUrl = true,
    String lang = 'en_us'
  }) {
    return Moodle()._callMoodleFunction(
      functionName,
      subrequests: subrequests,
      params: params,
      filter: filter,
      fileUrl: fileUrl,
      lang: lang
    );
  }

  // ------------Authentication Interfaces------------

  /// Start the authentication process.
  /// 
  /// The authentication will open up the browser showing the SSO login page of
  /// the organization. Upon successful auth, a pair of tokens, [wstoken] and
  /// [privatetoken] will be returned through deep link. 
  /// 
  /// This method will check if a user has logged in. It will not prompt another
  /// authentication process if there is already a logged-in user.
  static Future<bool> startAuth() async {
    if (isUserLoggedIn) return false;
    final authUrl = Moodle()._buildLaunchUrl();
    return await launchUrl(authUrl, mode: LaunchMode.externalApplication);
  }

  /// Handle the authentication result.
  /// 
  /// The result is a base64-encoded string, and has three parts:
  /// 
  /// siteid:::wstoken:::privatetoken
  /// 
  /// [siteid] is md5 encrypted with passport, which we will not verify in our
  /// app. [wstoken] and [privatetoken] will be saved for future use.
  /// 
  /// Under certain cases, [privatetoken] may not be included. By default this
  /// situation is not accepted and will return `MoodleAuthStatus.incomplete`.
  /// Change [acceptIncompleteAuth] to true to accept these cases.
  static Future<MoodleAuthStatus> handleAuthResult(
    String tokenString, 
    {bool acceptIncompleteAuth = false}
  ) async {
    final moodle = Moodle();
    if (isUserLoggedIn) return MoodleAuthStatus.ignore;
    try {
      if (!tokenString.startsWith('token')) return MoodleAuthStatus.ignore;
      // Eliminates formatter
      tokenString = tokenString.split('token=').last;
      // Decode from base64
      tokenString = utf8.decode(base64.decode(tokenString));
      // Split
      final tokens = tokenString.split(':::');
      String? privatetoken;
      if (tokens.length < 2) {
        // The authentication result is malformed. Discard.
        return MoodleAuthStatus.fail;
      } else if (tokens.length == 3) {
        // Includes private token
        privatetoken = tokens.last;
      }
      final wstoken = tokens[1];

      // Check if token has changed.
      // There is no point in updating everything again if tokens are the same.
      if (wstoken == moodle._wstoken) return MoodleAuthStatus.ignore;
      // Check if private token is not returned.
      if (privatetoken == null && !acceptIncompleteAuth) {
        return MoodleAuthStatus.incomplete;
      }
      // Update tokens
      moodle._wstoken = wstoken;
      moodle._privatetoken = privatetoken;
      
      // Obtain site info
      final response = await callFunction(MoodleFunctions.getSiteInfo);
      if (response.fail) throw Exception();
      moodle._siteInfo = MoodleSiteInfo.fromJson(response.data!);

      // Obtain course info first, before fetching events
      await fetchCourses(saveNow: false);
      
      // Then fetch events
      await fetchEvents(saveNow: false, force: true);

      // Save things down
      moodle._save();
    } catch (e) {
      moodle._wstoken = null;
      moodle._privatetoken = null;
      return MoodleAuthStatus.fail;
    }
    return MoodleAuthStatus.success;
  }

  // ------------Course Interfaces------------

  /// Fetch courses enrolled by the logged in user.
  /// 
  /// The fetched courses will be saved and can be access through static
  /// interface `courses`.
  /// 
  /// Returns true if successful, and false otherwise.
  static Future<bool> fetchCourses({bool saveNow = true}) async {
    final moodle = Moodle();
    if (!isUserLoggedIn) return false;
    final response = await callFunction(
      MoodleFunctions.getEnrolledCourses,
      params: {
        'userid': moodle._userId,
        'returnusercount': 0,
      }
    );
    if (response.fail) return false;
    try {
      moodle._courses = (response.data as List)
        .map((e) => MoodleCourse.fromJson(e)).toList();
    } catch (e) {
      return false;
    }
    moodle._generateCourseMap();
    if (saveNow) moodle._save();
    return true;
  }

  // ------------Event Interfaces------------

  /// Fetch events of the logged in user.
  static Future<bool> fetchEvents({
    bool saveNow = true,
    bool force = false,
    int minSecsBetweenFetches = 7200,
  }) async {
    final moodle = Moodle();
    if (!isUserLoggedIn) return false;
    // Check if fetches are too close
    if (!force && moodle._eventsLastUpdated != null) {
      final diff = DateTime.now().difference(moodle._eventsLastUpdated!);
      if (diff.inSeconds < minSecsBetweenFetches) return true;
    }
    // Obtain current timestamp
    final timeStart = DateTime.now().secondEpoch;
    final response = await callFunction(
      MoodleFunctions.callExternal,
      subrequests: [
        MoodleFunctionSubrequest(
          MoodleFunctions.getCalendarEvents,
          params: {
            'options': {
              "userevents": "1",
              "siteevents": "1",
              "timestart": "$timeStart",
              "timeend": "0"  // No time end
            },
            'events': {
              'courseids': moodle._allCourseIds()
            }
          }
        ),
      ]
    );
    final data = response.subResponseData<Map>(0);
    if (data == null) return false;
    try {
      final events = (data['events'] as List)
        .map((e) => MoodleEvent.fromJson(e)).toList();
      moodle._mergeEvents(events);
    } catch (e) {
      return false;
    }
    moodle._eventsLastUpdated = DateTime.now();
    if (saveNow) moodle._save();
    return true;
  }

  /// Get the course info associated with the event.
  static MoodleCourse? courseForEvent(MoodleEvent event) {
    final moodle = Moodle();
    final courseId = event.courseid;
    if (courseId != null) {
      return moodle._courseMap[courseId];
    }
    return null;
  }

  // ------------Private Utilities------------

  // ------------Internal Storage Utilities------------

  /// Load saved token and others from storage.
  Future<void> _load() async {
    if (_wstoken != null) return;
    try {
      // Tokens and site info
      _wstoken = _prefs.getString(MoodleStorageKeys.wstoken);
      _privatetoken = _prefs.getString(MoodleStorageKeys.privatetoken);
      final siteInfo = _prefs.getString(MoodleStorageKeys.siteInfo);
      if (siteInfo != null) {
        _siteInfo = MoodleSiteInfo.fromJson(jsonDecode(siteInfo));
      } else if (_wstoken != null) {
        // This is weird. Abort.
        throw Exception();
      }
      // Courses
      final courses = _prefs.getStringList(MoodleStorageKeys.courses);
      if (courses != null) {
        _courses = courses.map((course) => 
          MoodleCourse.fromJson(jsonDecode(course))).toList();
      }
      _generateCourseMap();
      // Events
      final events = _prefs.getStringList(MoodleStorageKeys.events);
      if (events != null) {
        _events = events.map((event) => 
          MoodleEvent.fromJson(jsonDecode(event))).toList();
      }
    } catch (e) {
      // Reset upon error.
      _wstoken = null;
      _privatetoken = null;
      _courses = [];
      _events = [];
    }
  }

  /// Save current token and others to storage.
  Future<void> _save() async {
    if (_wstoken == null) return;
    // Tokens and site info
    _prefs.setString(MoodleStorageKeys.wstoken, _wstoken!);
    _prefs.setString(MoodleStorageKeys.siteInfo, jsonEncode(_siteInfo.toJson()));
    if (_privatetoken != null) {
      _prefs.setString(MoodleStorageKeys.privatetoken, _privatetoken!);
    }
    // Courses
    _prefs.setStringList(
      MoodleStorageKeys.courses,
      _courses.map((course) => jsonEncode(course.toJson())).toList()
    );
    // Events
    _prefs.setStringList(
      MoodleStorageKeys.events,
      _events.map((event) => jsonEncode(event.toJson())).toList()
    );
  }

  // ------------Request Utilities------------

  /// Build Moodle url according to params.
  Uri _buildMoodleUrl({
    String? entryPoint, 
    Map<String, String>? params,
    bool useHTTPS = true
  }) {
    return Uri(
      scheme: useHTTPS ? 'https' : 'http',
      host: _domain,
      path: entryPoint,
      queryParameters: params,
    );
  }

  /// Build Moodle mobile launch URL.
  /// Used for authentication.
  Uri _buildLaunchUrl() {
    // Passport here does not affect the authentication, fixed to be 100
    const String passport = '100';
    return _buildMoodleUrl(
      entryPoint: 'admin/tool/mobile/launch.php',
      params: {
        'service': 'moodle_mobile_app',
        'passport': passport,
        'urlscheme': 'cuckoo'
      }
    );
  }

  /// Build URL for calling Moodle functions.
  Uri _buildMoodleFunctionUrl(String functionName) {
    return _buildMoodleUrl(
      entryPoint: 'webservice/rest/server.php',
      params: {
        'moodlewsrestformat': 'json',
        'wsfunction': functionName,
      },
    );
  }

  /// Build Moodle function body.
  String _buildMoodleFunctionBody(
    String functionName, {
    List<MoodleFunctionSubrequest>? subrequests,
    Map<String, dynamic>? params,
    bool filter = true,
    bool fileUrl = true,
    String lang = 'en_us'
  }) {
    var bodyParams = <String, dynamic>{
      'moodlewssettinglang': lang,
      'wsfunction': functionName,
      'wstoken': _wstoken!
    };
    if (params != null) bodyParams.addAll(params);
    if (subrequests == null) {
      bodyParams['moodlewssettingfilter'] = filter ? 'true' : 'false';
      bodyParams['moodlewssettingfileurl'] = fileUrl ? 'true' : 'false';
    } else {
      // Expand subrequests
      for (final (index, subrequest) in subrequests.indexed) {
        bodyParams.addAll(subrequest.bodyParamsWithIndex(index));
      }
    }

    // Convert to string
    var bodyComponents = <String>[];
    bodyParams.forEach((key, value) {
      final valStr = value is Map ? jsonEncode(value) : value.toString();
      bodyComponents.add(
        '${Uri.encodeComponent(key)}=${Uri.encodeComponent(valStr)}'
      );
    });
    return bodyComponents.join('&');
  }

  /// Call a Moodle function on Moodle's web service.
  Future<MoodleFunctionResponse> _callMoodleFunction(
    String functionName, {
    List<MoodleFunctionSubrequest>? subrequests,
    Map<String, dynamic>? params,
    bool filter = true,
    bool fileUrl = true,
    String lang = 'en_us'
  }) {
    // Build URL and body
    final url = _buildMoodleFunctionUrl(functionName);
    final body = _buildMoodleFunctionBody(
      functionName,
      subrequests: subrequests,
      params: params,
      filter: filter,
      fileUrl: fileUrl,
      lang: lang
    );

    // Issue request
    return Dio().postUri(
      url,
      data: body,
      options: Options(
        headers: {
          Headers.acceptHeader: 'application/json, text/plain, */*',
          Headers.contentTypeHeader: 'application/x-www-form-urlencoded',
          'host': _domain,
          'origin': 'moodleappfs://localhost',
          'user-agent': 'MoodleMobile 4.3.0 (43001)',
        }
      )
    ).then((response) => MoodleFunctionResponse(response));
  }

  // ------------Course Utilities------------

  /// Obtain a list containing IDs of all courses.
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

  // ------------Event Utilities------------

  /// Merge the new events with the current events.
  /// The custom events should remain in the list.
  void _mergeEvents(List<MoodleEvent> others) {
    // First delete all non-local events
    _events.removeWhere((event) => event.eventtype != MoodleEventTypes.custom);
    _events.addAll(others);
  }
  
  // Singleton configurations
  Moodle._internal();

  factory Moodle() => _instance;

  static final Moodle _instance = Moodle._internal();

}
