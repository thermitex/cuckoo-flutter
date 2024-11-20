part of 'moodle.dart';

/// Extension for Moodle class that provides debug functionalities.
///
/// Most functions in this class should be wrapped with a environment check.
/// Be careful when calling functions from this extension - most of them should
/// not be called in release.
extension MoodleDebugExtension on Moodle {
  /// Get a full set of debug information of current Moodle account.
  ///
  /// Returns a base64-encoded json string.
  String getDebugInfo(
      {bool includeSiteInfo = true,
      bool includeEvents = false,
      bool includeCourses = false}) {
    if (!Moodle.isUserLoggedIn) {
      return 'User not logged in';
    }
    final debugInfo = {};
    // Prepare basic info
    debugInfo.addAll({
      'wstoken': _wstoken,
      'privatetoken': _privatetoken,
      'domain': _domain
    });
    // Site info
    if (includeSiteInfo) {
      debugInfo['siteInfo'] = _siteInfo.toJson();
      for (final key in ['functions', 'advancedfeatures']) {
        debugInfo['siteInfo'].remove(key);
      }
    }
    // Events
    if (includeEvents) {
      debugInfo['events'] =
          eventManager.events.map((event) => event.toJson()).toList();
    }
    // Courses
    if (includeCourses) {
      debugInfo['courses'] = courseManager.courses.map((course) {
        course.cachedContents = null;
        return course.toJson();
      }).toList();
    }
    return base64.encode(utf8.encode(jsonEncode(debugInfo)));
  }

  /// Prompt a dialog box for logging in using tokens.
  ///
  /// Used in debug build ONLY.
  Future<bool?> promptForLoginWithTokens() {
    if (!kDebugMode) return Future(() => false);
    final controller = TextEditingController();
    return showDialog<bool>(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login with tokens'),
          content: TextField(
            decoration: const InputDecoration(hintText: "wstoken,privatetoken"),
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                final tokens = controller.text.split(',');
                if (tokens.length == 2) {
                  Navigator.pop(context, true);
                  loginWithTokens(tokens[0], tokens[1]);
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Login with a set of tokens instead of the normal SSO login process.
  ///
  /// Used in debug build ONLY.
  Future<void> loginWithTokens(wstoken, privatetoken) async {
    if (!kDebugMode || Moodle.isUserLoggedIn) return;
    CuckooFullScreenIndicator()
        .startLoading(message: Constants.kLoginMoodleLoading);
    final tokens = ['passport', wstoken, privatetoken];
    final tokenString = base64.encode(utf8.encode(tokens.join(':::')));
    Moodle.handleAuthResult('token=$tokenString').then((status) {
      CuckooFullScreenIndicator().stopLoading();
    });
  }
}
