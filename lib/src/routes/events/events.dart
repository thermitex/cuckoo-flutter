import 'dart:async';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/error_panel.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/routes/events/events_list.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  /// Rebuild events at midnight to show potential date changes.
  Timer? rebuildTimer;

  /// Build app bar action items.
  List<CuckooAppBarActionItem> _appBarActionItems() {
    var updateStatus = context.eventManager.status;
    var actionItems = <CuckooAppBarActionItem>[
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
    if (updateStatus == MoodleManagerStatus.updating) {
      // Show a loading indicator
      actionItems.insert(
          0,
          CuckooAppBarActionItem(
            icon: SizedBox(
              height: 20,
              width: 20,
              child: Center(
                  child: CircularProgressIndicator(
                color: context.cuckooTheme.tertiaryBackground,
                strokeWidth: 3.0,
              )),
            ),
            backgroundPadding: const EdgeInsets.all(5.0),
          ));
    } else if (updateStatus == MoodleManagerStatus.error) {
      actionItems.insert(
          0,
          CuckooAppBarActionItem(
              icon: const Icon(
                Icons.warning_rounded,
                color: ColorPresets.negativePrimary,
              ),
              onPressed: () => _showErrorDetails()));
    }
    return actionItems;
  }

  /// Action routine for opening reminder page.
  void _openReminderPage() {}

  /// Action routine for error.
  void _showErrorDetails() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none) && mounted) {
      // No internet connection
      ErrorPanel(
        title: Constants.kNoConnectivityErr,
        description: Constants.kNoConnectivityErrDesc,
        buttons: [
          CuckooButton(
            text: Constants.kTryAgain,
            icon: Symbols.refresh_rounded,
            action: () {
              Navigator.of(context, rootNavigator: true).pop();
              Moodle.fetchEvents(force: true);
            },
          )
        ],
      ).show(context);
    } else if (mounted) {
      // Invalid session / connected but no internet
      ErrorPanel(
        title: Constants.kSessionInvalidErr,
        description: Constants.kSessionInvalidErrDesc,
        buttons: [
          CuckooButton(
            text: Constants.kLoginMoodleButton,
            icon: Symbols.login_rounded,
            action: () {
              Navigator.of(context, rootNavigator: true).pop();
              Moodle.startAuth(force: true);
            },
          ),
          CuckooButton(
            text: Constants.kTryAgain,
            icon: Symbols.refresh_rounded,
            style: CuckooButtonStyle.secondary,
            action: () {
              Navigator.of(context, rootNavigator: true).pop();
              Moodle.fetchEvents(force: true);
            },
          )
        ],
      ).show(context);
    }
  }

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

  /// Build the event page according to the current state.
  Widget _buildEventPage() {
    if (context.loginStatusManager.isUserLoggedIn) {
      return const MoodleEventListView();
    }
    return _loginRequiredView();
  }

  @override
  void initState() {
    // Set up rebuild timer
    final now = DateTime.now();
    final secsTillMidnight =
        (60 - now.second) + (59 - now.minute) * 60 + (23 - now.hour) * 3600;
    Future.delayed(Duration(seconds: secsTillMidnight), () {
      Moodle().eventManager.rebuildNow();
      rebuildTimer = Timer.periodic(const Duration(days: 1),
          (timer) => Moodle().eventManager.rebuildNow());
    });
    super.initState();
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
