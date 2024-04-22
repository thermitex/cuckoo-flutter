import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The common global app service.
///
/// Global service initializes all the service modules included in the services
/// directory. It is initialized before the app is actually run, making sure
/// all the service modules are up before the first widget gets built.
class Global {
  /// The shared preferences instance to be used across the app.
  static late SharedPreferences prefs;

  /// Check if is release.
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  /// Init Global to execute boot tasks.
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    prefs = await SharedPreferences.getInstance();

    // Init service modules.
    Moodle.init();
  }
}
