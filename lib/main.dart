import 'package:cuckoo/src/common/services/global.dart';
import 'package:flutter/material.dart';
import 'src/app.dart';

/// Entry point of Cuckoo App.
/// Do not modify this file.
void main() {
  Global.init().then((e) => runApp(const CuckooApp()));
}