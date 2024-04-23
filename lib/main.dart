import 'package:cuckoo/src/common/services/global.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';

/// Entry point of Cuckoo App.
/// Do not modify this file.
void main() {
  Global.init().then((_) => runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Moodle().loginStatusManager),
          ChangeNotifierProvider(create: (_) => Moodle().courseManager),
          ChangeNotifierProvider(create: (_) => Moodle().eventManager),
          ChangeNotifierProvider(create: (_) => Settings()),
        ],
        child: const CuckooApp(),
      )));
}
