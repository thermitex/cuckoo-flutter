import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'common/ui/ui.dart';
import 'routes/root.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Cuckoo App definition.
///
/// Initialize tha app with the default light and dark color scheme, and
/// set Root widget as the app's home widget.
class CuckooApp extends StatelessWidget {
  const CuckooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FToastBuilder(),
      theme: CuckooTheme.light,
      darkTheme: CuckooTheme.dark,
      themeMode: ThemeMode
          .values[context.settingsValue<int>(SettingsKey.themeMode) ?? 0],
      home: const Root(),
      navigatorKey: navigatorKey,
    );
  }
}
