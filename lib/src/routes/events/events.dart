import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constant.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  /// Build app bar action items.
  List<CuckooAppBarActionItem> _appBarActionItems() {
    return <CuckooAppBarActionItem>[
      CuckooAppBarActionItem(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: ColorPresets.primary,
          ),
          onPressed: () => _openMorePanel()),
      CuckooAppBarActionItem(
          icon: const Icon(
            Icons.notifications_rounded,
            color: ColorPresets.primary,
            size: 20,
          ),
          backgroundColor: context.cuckooTheme.secondaryBackground,
          backgroundPadding: const EdgeInsets.all(5.0),
          onPressed: () => _openReminderPage()),
    ];
  }

  /// Action routine for opening reminder page.
  void _openReminderPage() {}

  /// Action routine for opening "more" panel.
  void _openMorePanel() {
    Moodle.logout();
  }

  /// Show a view to prompt user for logging in.
  Widget _loginRequiredView() {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500.0),
        child: CuckooFullPageView(
          SvgPicture.asset(
            'images/illus/page_intro.svg',
            width: 300,
            height: 300,
          ),
          darkModeImage: SvgPicture.asset(
            'images/illus/dark/page_intro.svg',
            width: 300,
            height: 300,
          ),
          message: Constants.kEventsRequireLoginPrompt,
          buttons: [
            CuckooButton(
              text: Constants.kLoginMoodleButton,
              action: () => Moodle.startAuth(),
            )
          ],
          bottomOffset: 65.0,
        ),
      )),
    );
  }

  /// The main view to show event list.
  Widget _eventMainView() {
    return const Placeholder();
  }

  /// Build the event page according to the current state.
  Widget _buildEventPage() {
    if (context.loginStatusManager.isUserLoggedIn) {
      return _eventMainView();
    }
    return _loginRequiredView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: CuckooLargeAppBar(
        title: Constants.kEventsTitle,
        actionItems: _appBarActionItems(),
      ),
      body: SafeArea(child: _buildEventPage()),
    );
  }
}
