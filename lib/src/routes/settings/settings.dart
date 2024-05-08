import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:flutter/material.dart';

import 'settings_topbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: const SettingsTopBar(),
      body: const Placeholder(),
    );
  }
}
