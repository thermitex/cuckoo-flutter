import 'dart:io';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/reminders.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/events/reminders/reminder_detail.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  // Transparency of the title.
  double _titleTrans = 0.0;

  // If a permission warning should be displayed at the top.
  bool _shouldShowPermissionWarning = false;

  final title = Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      Constants.kReminderTitle,
      style: TextStylePresets.title(size: 30, weight: FontWeight.w600),
    ),
  );

  Widget _emptyReminderView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: CuckooFullPageView(
                SvgPicture.asset(
                  'images/illus/page_turn_on.svg',
                  width: 300,
                  height: 300,
                ),
                darkModeImage: SvgPicture.asset(
                  'images/illus/dark/page_turn_on.svg',
                  width: 300,
                  height: 300,
                ),
                message: Constants.kReminderIntroPrompt,
                buttons: [
                  CuckooButton(
                    text: Constants.kAddReminder,
                    icon: Symbols.add_circle_rounded,
                    action: () => _createNewReminder(),
                  )
                ],
                bottomOffset: 65.0,
              ),
            ),
          ),
        ))
      ],
    );
  }

  Widget _addReminderItem() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: SizedBox(
        width: double.infinity,
        height: 55.0,
        child: GestureDetector(
          onTap: () => _createNewReminder(),
          child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_circle_rounded, color: ColorPresets.primary),
            const SizedBox(width: 6.0),
            Text(
              Constants.kAddReminder,
              style: TextStylePresets.body(size: 13.0, weight: FontWeight.w500)
                  .copyWith(color: ColorPresets.primary),
            )
          ])),
        ),
      ),
    );
  }

  Widget _permissionWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      decoration: BoxDecoration(
          color: ColorPresets.warningTertiary,
          borderRadius: BorderRadius.circular(17.0),
          border: Border.all(color: ColorPresets.warningPrimary)),
      child: Text(
        Constants.kNotiPermissionWarning,
        style: TextStylePresets.body(weight: FontWeight.w500, size: 12)
            .copyWith(color: ColorPresets.warningPrimary),
      ),
    );
  }

  Widget _reminderTile(EventReminder reminder) {
    bool disabled = reminder.disabled ?? false;
    return GestureDetector(
      onTap: () => _enterDetailPage(reminder),
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(7.0),
        margin: const EdgeInsets.only(top: 7.0),
        decoration: BoxDecoration(
          color: context.cuckooTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(17.0),
        ),
        child: Row(children: [
          Container(
            height: double.infinity,
            width: 20,
            decoration: BoxDecoration(
              color: disabled
                  ? context.cuckooTheme.tertiaryText
                  : ColorPresets.primary,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Icon(
                disabled
                    ? Icons.notifications_off_rounded
                    : Icons.notifications_rounded,
                color: Colors.white,
                size: 18.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.title!,
                style: TextStylePresets.body(size: 15, weight: FontWeight.w600),
              ),
              Text(
                reminder.timingDescription,
                style: TextStylePresets.body(size: 12)
                    .copyWith(color: ColorPresets.primary),
              )
            ],
          )),
          Icon(
            Icons.chevron_right_rounded,
            color: context.cuckooTheme.tertiaryText,
          )
        ]),
      ),
    );
  }

  Widget _reminderListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        double trans =
            (scrollNotification.metrics.pixels - 30).clamp(0, 15) / 15;
        if (trans != _titleTrans) setState(() => _titleTrans = trans);
        return false;
      },
      child: ListView.builder(
          itemCount:
              Reminders().numReminders + (_shouldShowPermissionWarning ? 3 : 2),
          itemBuilder: (context, index) {
            if (index == 0) {
              // Title
              return title;
            }
            if (index == 1 && _shouldShowPermissionWarning) {
              // Warning
              return _permissionWarning();
            }
            if (index <=
                Reminders().numReminders +
                    (_shouldShowPermissionWarning ? 1 : 0)) {
              // Show reminder tiles
              return _reminderTile(Reminders().reminderAtIndex(
                  index - (_shouldShowPermissionWarning ? 2 : 1)));
            }
            return _addReminderItem();
          }),
    );
  }

  /// Start the process of creating a new reminder.
  void _createNewReminder() {
    _enterDetailPage(Reminders.create());
  }

  /// Entere detail page of a reminder
  void _enterDetailPage(EventReminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ReminderDetailPage(reminder)),
    );
  }

  void _checkNotificationPermission() async {
    if (Platform.isIOS) {
      final result = await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      setState(() => _shouldShowPermissionWarning = !(result ?? false));
    } else if (Platform.isAndroid) {
      final androidPlugin = FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!;
      var result =
          await androidPlugin.requestNotificationsPermission() ?? false;
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) {
        result &= await androidPlugin.requestExactAlarmsPermission() ?? false;
      }
      setState(() => _shouldShowPermissionWarning = !result);
    }
  }

  @override
  void initState() {
    super.initState();
    // Check notification permission
    _checkNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: CuckooAppBar(
        title: Constants.kReminderTitle,
        exitButtonStyle: ExitButtonStyle.close,
        titleTransparency: _titleTrans,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: context.reminders.isEmpty
            ? _emptyReminderView()
            : _reminderListView(),
      )),
    );
  }
}
