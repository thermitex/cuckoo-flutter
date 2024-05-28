import 'dart:async';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/common/widgets/login_required.dart';
import 'package:cuckoo/src/common/widgets/more_panel.dart';
import 'package:cuckoo/src/routes/events/create/create.dart';
import 'package:cuckoo/src/routes/events/events_list.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuckoo/src/routes/events/reminders/reminders.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:toggle_switch/toggle_switch.dart';

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
  void _openReminderPage() {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => const ReminderPage(),
    ));
  }

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
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      backgroundColor: context.cuckooTheme.popUpBackground,
      builder: (context) {
        return MorePanel(children: <MorePanelElement>[
          MorePanelElement(
            title: Constants.kMorePanelGrouping,
            icon: const Icon(Icons.view_stream_outlined),
            extendedView: Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: SizedBox(
                height: 35,
                width: double.infinity,
                child: ToggleSwitch(
                  minWidth: double.infinity,
                  customTextStyles: [TextStylePresets.body()],
                  initialLabelIndex: context
                          .settingsValue<int>(SettingsKey.eventGroupingType) ??
                      0,
                  dividerColor: Colors.transparent,
                  activeBgColor: const [ColorPresets.primary],
                  activeFgColor: Colors.white,
                  inactiveBgColor: context.cuckooTheme.secondaryTransBg,
                  inactiveFgColor: context.cuckooTheme.primaryText,
                  totalSwitches: 3,
                  radiusStyle: true,
                  cornerRadius: 10.0,
                  labels: const ['Time', 'Course', 'None'],
                  onToggle: (index) {
                    if (index != null) {
                      Settings().set<int>(SettingsKey.eventGroupingType, index);
                    }
                  },
                ),
              ),
            ),
          ),
          MorePanelElement(
            title: Constants.kMorePanelSync,
            icon: const Icon(Icons.sync_rounded),
            action: () {
              Moodle.fetchEvents(force: true);
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          MorePanelElement(
            title: Constants.kMorePanelAddEvent,
            icon: const Icon(Icons.add_rounded),
            action: () {
              Navigator.of(context, rootNavigator: true)
                ..pop()
                ..push(MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) =>
                      CreateEventPage(MoodleEventExtension.custom()),
                ));
            },
          ),
        ]);
      },
    );
  }

  /// Build the event page according to the current state.
  Widget _buildEventPage() {
    if (context.loginStatusManager.isUserLoggedIn) {
      return const MoodleEventListView();
    }
    return const LoginRequiredView();
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
