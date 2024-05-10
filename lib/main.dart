import 'package:cuckoo/src/common/services/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';

/// Entry point of Cuckoo App.
/// Do not modify this file.
void main() {
  Global.init().then((_) => runApp(MultiProvider(
        providers: Global.notifierProviders,
        child: const CuckooApp(),
      )));
}
