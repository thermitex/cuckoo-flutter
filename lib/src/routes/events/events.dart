import 'package:cuckoo/src/common/extensions/build_context.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  /// Build app bar action items.
  List<CuckooAppBarActionItem> _appBarActionItems(BuildContext context) {
    return <CuckooAppBarActionItem>[
      CuckooAppBarActionItem(
        icon: const Icon(
          Icons.more_horiz_rounded,
          color: ColorPresets.primary,
        ),
        onPressed: () => _openMorePanel()
      ),
      CuckooAppBarActionItem(
        icon: const Icon(
          Icons.notifications_rounded,
          color: ColorPresets.primary,
          size: 20,
        ),
        backgroundColor: context.cuckooTheme.secondaryBackground,
        backgroundPadding: const EdgeInsets.all(5.0),
        onPressed: () => _openReminderPage()
      ),
    ];
  }

  /// Action routine for opening reminder page.
  void _openReminderPage() {
    Moodle.startAuth();
  }

  /// Action routine for opening "more" panel.
  void _openMorePanel() {
    Moodle.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: CuckooLargeAppBar(
        title: 'Events',
        actionItems: _appBarActionItems(context),
      ),
      body: const Placeholder(),
    );
  }
}