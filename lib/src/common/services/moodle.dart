import 'dart:convert';
import 'dart:io';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/color_registry.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/global.dart';
import 'package:cuckoo/src/common/services/reminders.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

part 'moodle_extra.dart';
part 'moodle_managers.dart';

/// Domain name of HKU Moodle.
const String kHKUMoodleDomain = 'moodle.hku.hk';

/// The class for all Moodle services used in Cuckoo.
///
/// Cuckoo communicates with Moodle via web service token, which can be obtained
/// by calling mobile/launch.php endpoint on Moodle and faking itself to be the
/// official Moodle app. The web service token is binded with the logged in user
/// and therefore the user no longer needs to login every time. The token,
/// according to the document, should be available for 3 months.
class Moodle {
  // Instance variables

  /// Login status manager.
  late MoodleLoginStatusManager loginStatusManager;

  /// Course manager.
  late MoodleCourseManager courseManager;

  /// Event manager.
  late MoodleEventManager eventManager;

  /// Web service tokens used in calling Moodle service.
  String? _wstoken;
  String? _privatetoken;

  /// Moodle domain.
  String _domain = kHKUMoodleDomain;

  /// Auto login info.
  MoodleAutoLoginInfo? _autoLoginInfo;

  /// User ID of the Moodle user.
  String get _userId => _siteInfo.userid.toString();

  /// User name of the Moodle user.
  String get _username => _siteInfo.username;

  /// Site info for current Moodle user.
  late MoodleSiteInfo _siteInfo;

  /// Shared preference instance.
  late SharedPreferences _prefs;

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
  ///
  /// Keep this method synchronous.
  static void init() {
    final moodle = Moodle();
    moodle._prefs = Global.prefs;

    // Init notifiers
    moodle.loginStatusManager = MoodleLoginStatusManager();
    moodle.courseManager = MoodleCourseManager();
    moodle.eventManager = MoodleEventManager();

    // Load from storage
    moodle._load();

    // If the user already logged in, start fetching in background.
    if (isUserLoggedIn) {
      moodle._fetchSiteInfo();
      fetchEvents();
      fetchCourses();
    }
  }

  /// Logout current user and clear storage.
  static Future<void> logout() async {
    if (!isUserLoggedIn) return;
    final moodle = Moodle();
    moodle.loginStatusManager.status = false;
    moodle._wstoken = null;
    moodle._privatetoken = null;
    moodle._autoLoginInfo = null;
    moodle.courseManager._clearAllCourses();
    moodle.eventManager
      .._clearEventsExceptCustom()
      .._eventsLastUpdated = null;
    // Reset color registry
    ColorRegistry().resetAllMappings();
    // Clear storage
    for (String key in [
      MoodleStorageKeys.wstoken,
      MoodleStorageKeys.privatetoken,
      MoodleStorageKeys.autoLoginInfo,
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
  static Future<MoodleFunctionResponse> callFunction(String functionName,
      {List<MoodleFunctionSubrequest>? subrequests,
      Map<String, dynamic>? params,
      bool filter = true,
      bool fileUrl = true,
      String lang = 'en_us'}) {
    return Moodle()._callMoodleFunction(functionName,
        subrequests: subrequests,
        params: params,
        filter: filter,
        fileUrl: fileUrl,
        lang: lang);
  }

  // ------------Authentication Interfaces------------

  /// Start the authentication process.
  ///
  /// The authentication will open up the browser showing the SSO login page of
  /// the organization. Upon successful auth, a pair of tokens, [wstoken] and
  /// [privatetoken] will be returned through deep link.
  ///
  /// This method will check if a user has logged in. It will not prompt another
  /// authentication process if there is already a logged-in user unless `force`
  /// is set to true.
  static Future<bool> startAuth({bool force = false}) async {
    if (!force && isUserLoggedIn) return false;
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
  static Future<MoodleAuthStatus> handleAuthResult(String tokenString,
      {bool acceptIncompleteAuth = false}) async {
    final moodle = Moodle();
    try {
      if (!tokenString.startsWith('token')) return MoodleAuthStatus.ignore;
      // Eliminates formatter
      tokenString = tokenString.split('token=').last.trim();
      if (tokenString.length > 180 && tokenString.endsWith('#')) {
        tokenString = tokenString.substring(0, tokenString.length - 1);
      }
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

      // Obtain site info and auto login key
      await Future.wait([
        moodle._fetchSiteInfo(ignoreFail: false, saveNow: false),
        moodle._updateAutoLoginKey()
      ]);

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
    // Set login status to notify listeners
    moodle.loginStatusManager.status = true;
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
    moodle.courseManager.status = MoodleManagerStatus.updating;
    final response =
        await callFunction(MoodleFunctions.getEnrolledCourses, params: {
      'userid': moodle._userId,
      'returnusercount': 0,
    });
    if (response.fail) {
      moodle.courseManager.status = MoodleManagerStatus.error;
      return false;
    }
    try {
      moodle.courseManager.courses =
          (response.data as List).map((e) => MoodleCourse.fromJson(e)).toList();
    } catch (e) {
      moodle.courseManager.status = MoodleManagerStatus.error;
      return false;
    }
    if (saveNow) moodle._saveCourses();
    moodle.courseManager.status = MoodleManagerStatus.idle;
    return true;
  }

  /// Get the content of a course as a JSON object.
  ///
  /// The function will also record the view of the course, which refreshes the
  /// last accessed time at Moodle server.
  static Future<MoodleCourseContent?> getCourseContent(
      MoodleCourse course) async {
    final response =
        await callFunction(MoodleFunctions.callExternal, subrequests: [
      MoodleFunctionSubrequest(MoodleFunctions.getCourseContents, params: {
        "courseid": course.id,
        "options": [
          {"name": "excludemodules", "value": "0"},
          {"name": "excludecontents", "value": "0"},
          {"name": "includestealthmodules", "value": "1"}
        ]
      }),
      // Record course view in the same request
      MoodleFunctionSubrequest(MoodleFunctions.recordCourseView,
          params: {"courseid": course.id}),
    ]);
    if (response.fail || response.data == null) return null;
    final data = response.subResponseData<List>(0);
    if (data == null) return null;

    // Convert returned data to section model
    MoodleCourseContent? content;
    try {
      content = data
          .map((sec) =>
              MoodleCourseSection.fromJson(sec as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    // Update last accessed property locally first
    course.markAccess();
    // Cache contents
    course
      ..cachedContents = content
      ..cachedTime = DateTime.now().secondEpoch;
    Moodle()._saveCourses();
    return content;
  }

  /// Download a file associated with the course module.
  ///
  /// Returns the downloaded path if the download is successful and returns null
  /// otherwise.
  static Future<String?> downloadModuleFile(MoodleCourseModule module) async {
    final moodle = Moodle();
    // First check if module has downloadable file
    if (!module.hasDownloadableFile) return null;
    // Parse file Url
    final fileUrl = module.contents!.first['fileurl'] as String?;
    final fileName = module.contents!.first['filename'] as String?;
    if (fileUrl != null && fileName != null && moodle._privatetoken != null) {
      var downloadPath = (await getTemporaryDirectory()).path;
      downloadPath +=
          (downloadPath.endsWith('/') ? 'cuckoo/' : '/cuckoo/') + fileName;
      // First check if the file is already there
      if (File(downloadPath).existsSync()) return downloadPath;
      // Prepare url for download
      var fileUri = Uri.parse(fileUrl);
      final segs = fileUri.pathSegments.toList();
      // Update parts
      // As a mobile app, we are using token to access the file,
      // so we need to replace the original entry point with tokenpluginfile.php
      // and pass token as a path parameter
      segs[0] = 'tokenpluginfile.php';
      segs[1] = moodle._siteInfo.userprivateaccesskey;
      // Re-construct url
      fileUri = fileUri.replace(
        pathSegments: segs,
        queryParameters: {'forcedownload': '1', 'offline': '1'},
      );
      // Start file download
      try {
        await Dio().download(
          fileUri.toString(),
          downloadPath,
        );
      } catch (_) {
        return null;
      }
      // Return path
      return downloadPath;
    }
    return null;
  }

  /// Clear all cached contents for all courses.
  static void clearCourseCachedContents() {
    final moodle = Moodle();
    moodle.courseManager._clearCachedCourseContents();
    moodle._saveCourses();
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
    if (!force && moodle.eventManager._eventsLastUpdated != null) {
      final diff =
          DateTime.now().difference(moodle.eventManager._eventsLastUpdated!);
      if (diff.inSeconds < minSecsBetweenFetches) return true;
    }
    moodle.eventManager.status = MoodleManagerStatus.updating;
    // Obtain current timestamp
    var timeStart = DateTime.now().secondEpoch;
    if (kDebugMode) {
      // Go back custom days for ease of debugging
      timeStart = DateTime.now().subtract(const Duration(days: 0)).secondEpoch;
    }
    final response =
        await callFunction(MoodleFunctions.callExternal, subrequests: [
      MoodleFunctionSubrequest(MoodleFunctions.getCalendarEvents, params: {
        'options': {
          "userevents": "1",
          "siteevents": "1",
          "timestart": "$timeStart",
          "timeend": "0" // No time end
        },
        'events': {'courseids': moodle.courseManager._allCourseIds()}
      }),
    ]);
    final data = response.subResponseData<Map>(0);
    if (data == null) {
      moodle.eventManager.status = MoodleManagerStatus.error;
      return false;
    }
    try {
      final events =
          (data['events'] as List).map((e) => MoodleEvent.fromJson(e)).toList();
      moodle.eventManager._mergeEvents(events, notify: false);
    } catch (e) {
      moodle.eventManager.status = MoodleManagerStatus.error;
      return false;
    }
    await moodle._fetchEventDetailsAndCompletionStatus();
    moodle.eventManager._notifyManually();
    moodle.eventManager._eventsLastUpdated = DateTime.now();
    if (saveNow) moodle._saveEvents();
    moodle.eventManager.status = MoodleManagerStatus.idle;
    return true;
  }

  /// Sync completion status of the events to Moodle.
  ///
  /// This function will only work if the sync feature is turned on in Settings.
  /// When an event is marked/unmarked as completed, this function will post
  /// the update to Moodle as well. For the events do not have a Moodle
  /// completion status (e.g. not associated with course, custom events), the
  /// completion mark will remain unchanged.
  static Future<void> syncEventCompletion() {
    final moodle = Moodle();
    List<Future> requests = [];
    for (final event in moodle.eventManager._events) {
      // Check if event is eligible for syncing
      if (event.completed != null &&
          (event.hascompletion ?? false) &&
          event.cmid != null) {
        requests.add(callFunction(MoodleFunctions.callExternal, subrequests: [
          MoodleFunctionSubrequest(MoodleFunctions.updateCompletionStatus,
              params: {'cmid': event.cmid!, 'completed': event.completed})
        ]).then((response) {
          if (!response.fail) {
            // Reset mark flag
            // Possible situation here: completed flag is reset after the first
            // request completed but before the second request completed, so
            // second request may see a null completed flag after completion.
            // Leave it unhandled for now - default completed to false if null.
            // Integerity will be maintained once fetched from Moodle.
            event.state = (event.completed ?? false) ? 1 : 0;
            event.completed = null;
          }
        }));
      }
    }
    return Future.wait(requests).then((_) => moodle._saveEvents());
  }

  /// Get the course info associated with the event.
  ///
  /// Recommend to use the shortcut `event.course` instead.
  static MoodleCourse? courseForEvent(MoodleEvent event) {
    final moodle = Moodle();
    final courseId = event.courseid;
    if (courseId != null) {
      return moodle.courseManager._courseMap[courseId];
    }
    return null;
  }

  /// Add or update a custom event to the current event list.
  ///
  /// Custom events will maintain in the events list after merging.
  static void addCustomEvent(MoodleEvent event) {
    final moodle = Moodle();
    moodle.eventManager._addCustomEvent(event);
    moodle._saveEvents();
  }

  /// Remove a custom event from the current event list.
  static void removeCustomEvent(MoodleEvent event) {
    final moodle = Moodle();
    moodle.eventManager._removeCustomEvent(event);
    moodle._saveEvents();
  }

  // ------------Moodle Web Interfaces------------

  /// Open Moodle URL in an external browser with user auto logged in.
  ///
  /// Returns false if [privatetoken] is missing, or failed obtaining
  /// [autoLoginKey] to perform the login.
  static Future<bool> openMoodleUrl(String? url,
      {bool internal = false}) async {
    final moodle = Moodle();
    if (!isUserLoggedIn || url == null) return false;
    // Always request a new key
    // If fails, fallback to existing cached key if any
    CuckooFullScreenIndicator()
        .startLoading(message: Constants.kMoodleUrlOpenLoading);
    final hasKey = await moodle._updateAutoLoginKey();
    CuckooFullScreenIndicator().stopLoading();
    if (!hasKey) return false;
    // Construct url
    Uri finalUrl = moodle._buildMoodleUrl(
        entryPoint: 'admin/tool/mobile/autologin.php',
        params: {
          'userid': moodle._userId,
          'key': moodle._autoLoginInfo!.key,
          'urltogo': url
        });
    try {
      return await launchUrl(finalUrl,
          mode: internal
              ? LaunchMode.inAppBrowserView
              : LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  // ------------Private Utilities------------

  // ------------Internal Storage Utilities------------

  /// Load saved token and others from storage.
  void _load() {
    if (_wstoken != null) return;
    try {
      // Tokens and site info
      _wstoken = _prefs.getString(MoodleStorageKeys.wstoken);
      _privatetoken = _prefs.getString(MoodleStorageKeys.privatetoken);
      final autoLoginInfo = _prefs.getString(MoodleStorageKeys.autoLoginInfo);
      if (autoLoginInfo != null) {
        _autoLoginInfo =
            MoodleAutoLoginInfo.fromJson(jsonDecode(autoLoginInfo));
      }
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
        courseManager._courses = courses
            .map((course) => MoodleCourse.fromJson(jsonDecode(course)))
            .toList();
      }
      // Events
      final events = _prefs.getStringList(MoodleStorageKeys.events);
      if (events != null) {
        eventManager._events = events
            .map((event) => MoodleEvent.fromJson(jsonDecode(event)))
            .toList();
      }
    } catch (e) {
      // Reset upon error.
      _wstoken = null;
      _privatetoken = null;
      courseManager._courses = [];
      eventManager._events = [];
    }
    courseManager._generateCourseMap();
    eventManager._generateEventMap();
    loginStatusManager._loggedIn = _wstoken != null;
  }

  /// Save current token and others to storage.
  Future<void> _save() async {
    if (_wstoken == null) return;
    // Tokens and site info
    _prefs.setString(MoodleStorageKeys.wstoken, _wstoken!);
    _prefs.setString(
        MoodleStorageKeys.siteInfo, jsonEncode(_siteInfo.toJson()));
    if (_privatetoken != null) {
      _prefs.setString(MoodleStorageKeys.privatetoken, _privatetoken!);
    }
    // Courses
    _saveCourses();
    // Events
    _saveEvents();
  }

  /// Save courses only to local storage.
  Future<void> _saveCourses() async {
    _prefs.setStringList(
        MoodleStorageKeys.courses,
        courseManager.courses
            .map((course) => jsonEncode(course.toJson()))
            .toList());
  }

  /// Save events only to local storage.
  Future<void> _saveEvents() async {
    _prefs.setStringList(
        MoodleStorageKeys.events,
        eventManager.events
            .map((event) => jsonEncode(event.toJson()))
            .toList());
  }

  // ------------Request Utilities------------

  /// Build Moodle url according to params.
  Uri _buildMoodleUrl(
      {String? entryPoint, Map<String, String>? params, bool useHTTPS = true}) {
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
    return _buildMoodleUrl(entryPoint: 'admin/tool/mobile/launch.php', params: {
      'service': 'moodle_mobile_app',
      'passport': passport,
      'urlscheme': 'cuckoo'
    });
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
  String _buildMoodleFunctionBody(String functionName,
      {List<MoodleFunctionSubrequest>? subrequests,
      Map<String, dynamic>? params,
      bool filter = true,
      bool fileUrl = true,
      String lang = 'en_us'}) {
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
      bodyComponents
          .add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(valStr)}');
    });
    return bodyComponents.join('&');
  }

  /// Call a Moodle function on Moodle's web service.
  Future<MoodleFunctionResponse> _callMoodleFunction(String functionName,
      {List<MoodleFunctionSubrequest>? subrequests,
      Map<String, dynamic>? params,
      bool filter = true,
      bool fileUrl = true,
      String lang = 'en_us'}) {
    // Build URL and body
    final url = _buildMoodleFunctionUrl(functionName);
    final body = _buildMoodleFunctionBody(functionName,
        subrequests: subrequests,
        params: params,
        filter: filter,
        fileUrl: fileUrl,
        lang: lang);

    // Issue request
    return Dio()
        .postUri(url,
            data: body,
            options: Options(headers: {
              Headers.acceptHeader: 'application/json, text/plain, */*',
              Headers.contentTypeHeader: 'application/x-www-form-urlencoded',
              'host': _domain,
              'origin': 'moodleappfs://localhost',
              'user-agent': 'MoodleMobile 4.3.0 (43001)',
            }))
        .then((response) => MoodleFunctionResponse(response),
            onError: (e) => MoodleFunctionResponse.error());
  }

  // ------------Event Utilities------------

  /// Fetches the event details, including course module ID (cmid) and url, and
  /// syhcronizes the completion statuses of the events with Moodle.
  ///
  /// The event results returned by `MoodleFunctions.getCalendarEvents`
  /// are not complete - [cmid] and [url] are not returned in the result, but we
  /// need them to map the completion status and visit event details on external
  /// browser. So this function does two things:
  ///
  /// 1. Request to get more details for the events that do not currently have
  /// a url or cmid, and save it once the info is obtained;
  /// 2. Request to get the completion status of all activities of the courses
  /// that currently have at least one outstanding event, and map the status to
  /// the current existing events through [instance] or [cmid].
  ///
  /// As the requests do not depend on each other, they are fired in parallel in
  /// order to minimize loading time. This process could take significant amount
  /// of time if the user has many outstanding events and is the first fetch
  /// attempt, but the time needed becomes much better starting from the second
  /// fetch attempt.
  Future<void> _fetchEventDetailsAndCompletionStatus() async {
    // Maintain a list of requests to be fired at once
    var requests = <Future<MoodleFunctionResponse>>[];
    // Fetch event details
    // First check url fields of all events except custom
    final eventsToCheck = eventManager._events.where((event) =>
        event.eventtype != MoodleEventTypes.custom && event.url == null);
    // Add to request list
    for (final event in eventsToCheck) {
      requests.add(_callMoodleFunction(MoodleFunctions.getEventById,
          params: {'eventid': event.id}));
    }
    // Fetch completion status
    // Gather courses with outstanding events
    bool shouldCheckCompletion =
        Settings().get<bool>(SettingsKey.syncCompletionStatus) ?? true;
    if (shouldCheckCompletion) {
      final coursesToCheck = eventManager._events
          .where((event) => event.eventtype != MoodleEventTypes.custom)
          .map((event) => event.course)
          .toSet();
      // Add to request list
      for (final course in coursesToCheck) {
        if (course != null) {
          requests.add(_callMoodleFunction(MoodleFunctions.getCompletionStatus,
              params: {'userid': _userId, 'courseid': course.id}));
        }
      }
    }
    // Fire all requests and listen to reponses
    await Future.wait(requests).then((responses) {
      for (final response in responses) {
        if (!response.fail && response.data != null) {
          // Response will be a map anyways
          final data = response.data as Map;
          if (data['event'] != null) {
            // Handle event details
            final eventDetail = data['event'] as Map;
            final eventToUpdate = eventManager._eventMap[eventDetail['id']];
            if (eventToUpdate != null) {
              eventToUpdate.cmid = eventDetail['instance'];
              eventToUpdate.url = eventDetail['url'];
            }
          } else if (data['statuses'] != null) {
            // Handle completion status
            for (final Map activity in data['statuses'] as List) {
              for (final event in eventManager._events) {
                if (event.cmid == activity['cmid'] ||
                    event.cmid == null &&
                        event.instance == activity['instance']) {
                  // Sync completion
                  event.hascompletion = activity['hascompletion'];
                  event.state = activity['state'];
                }
              }
            }
          }
        }
      }
    });
  }

  // ------------Site info Utilities------------

  /// Fetch site info.
  Future<void> _fetchSiteInfo({
    bool ignoreFail = true,
    bool saveNow = true,
  }) async {
    final response = await callFunction(MoodleFunctions.getSiteInfo);
    if (response.fail) {
      if (!ignoreFail) throw Exception();
      return;
    }
    try {
      _siteInfo = MoodleSiteInfo.fromJson(response.data!);
    } catch (_) {
      if (!ignoreFail) throw Exception();
      return;
    }
    if (saveNow) _save();
  }

  // ------------Auto login Utilities------------

  /// Update the auto login key of Moodle.
  Future<bool> _updateAutoLoginKey() async {
    if (_privatetoken == null) return false;
    final response = await _callMoodleFunction(MoodleFunctions.getAutoLoginKey,
        params: {'privatetoken': _privatetoken});
    if (!response.fail && response.data != null) {
      final info = MoodleAutoLoginInfo();
      info
        ..key = response.data['key']
        ..lastRequested = DateTime.now().secondEpoch;
      _autoLoginInfo = info;
      _prefs.setString(
          MoodleStorageKeys.autoLoginInfo, jsonEncode(info.toJson()));
      return true;
    }
    // If fails, means that the key has not expired yet
    // In that case, use the previously saved key
    // Unless it has expired for sure
    if (_autoLoginInfo != null) {
      final secsElapsedFromLast =
          DateTime.now().secondEpoch - _autoLoginInfo!.lastRequested.toInt();
      if (secsElapsedFromLast > 600) return false;
      return true;
    }
    return false;
  }

  // Singleton configurations
  Moodle._internal();

  factory Moodle() => _instance;

  static final Moodle _instance = Moodle._internal();
}
