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
import 'package:cuckoo/src/routes/events/reminders/reminders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            color: CuckooColors.primary,
          ),
          onPressed: () => _openMorePanel()),
      CuckooAppBarActionItem(
          icon: const Icon(
            Icons.notifications_rounded,
            color: CuckooColors.primary,
            size: 20,
          ),
          backgroundColor: context.theme.secondaryBackground,
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
                color: context.theme.tertiaryBackground,
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
                color: CuckooColors.negativePrimary,
              ),
              onPressed: () => showMoodleConnectionErrorDetails(context)));
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

  /// Action routine for opening "more" panel.
  void _openMorePanel() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      backgroundColor: context.theme.popUpBackground,
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
                  customTextStyles: [CuckooTextStyles.body()],
                  initialLabelIndex: context
                          .settingsValue<int>(SettingsKey.eventGroupingType) ??
                      0,
                  dividerColor: Colors.transparent,
                  activeBgColor: const [CuckooColors.primary],
                  activeFgColor: Colors.white,
                  inactiveBgColor: context.theme.secondaryTransBg,
                  inactiveFgColor: context.theme.primaryText,
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
              Navigator.of(context, rootNavigator: true).pop();
              _startCreateEvent();
            },
          ),
        ]);
      },
    );
  }

  /// Start creating a new custom event.
  void _startCreateEvent() {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => CreateEventPage(MoodleEventExtension.custom()),
    ));
  }

  /// Build the event page according to the current state.
  Widget _buildEventPage() {
    if (context.loginStatusManager.isUserLoggedIn) {
      return Stack(
        children: [
          if (context.eventManager.events.isNotEmpty)
            const MoodleEventListView()
          else
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500.0),
                  child: CuckooFullPageView(
                    SvgPicture.asset(
                      'images/illus/page_celebrate.svg',
                      width: 300,
                      height: 300,
                    ),
                    darkModeImage: SvgPicture.asset(
                      'images/illus/dark/page_celebrate.svg',
                      width: 300,
                      height: 300,
                    ),
                    message: Constants.kEventsClearPrompt,
                    bottomOffset: 65.0,
                  ),
                ),
              ),
            ),
          // Add event button
          Positioned(
            right: 24.0,
            bottom: 24.0,
            child: SizedBox(
              width: 56.0,
              child: CuckooButton(
                sizeVariant: CuckooButtonSize.large,
                height: 56.0,
                borderRadius: 28.0,
                icon: Icons.add_rounded,
                action: () => _startCreateEvent(),
              ),
            ),
          )
        ],
      );
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
      backgroundColor: context.theme.primaryBackground,
      appBar: CuckooLargeAppBar(
        title: Constants.kEventsTitle,
        actionItems: _appBarActionItems(),
      ),
      body: SafeArea(child: _buildEventPage()),
    );
  }
}
