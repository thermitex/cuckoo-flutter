import 'dart:io';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/routes/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';

import 'settings_topbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: const SettingsTopBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsFirstLevelMenuItem(
                  icon: Symbols.settings_rounded,
                  text: Constants.kSettingsGeneral,
                  page: SettingsDetailPage(
                    Constants.kSettingsGeneral,
                    items: [
                      const SettingsItem(
                        SettingsKey.defaultTab,
                        type: SettingsItemType.choice,
                        choiceNames: [
                          Constants.kEventsTitle,
                          Constants.kCoursesTitle,
                          Constants.kCalendarTitle,
                        ],
                        defaultValue: 0,
                        label: Constants.kSettingsGeneralDefaultTab,
                        description: Constants.kSettingsGeneralDefaultTabDesc,
                      ),
                      const SettingsItem(
                        SettingsKey.themeMode,
                        type: SettingsItemType.choice,
                        choiceNames: [
                          'Follow System',
                          'Light',
                          'Dark',
                        ],
                        defaultValue: 0,
                        label: Constants.kSettingsGeneralTheme,
                      ),
                      SettingsItem(
                        SettingsKey.none,
                        type: SettingsItemType.action,
                        label: Constants.kSettingsGeneralClearCache,
                        action: () async {
                          CuckooFullScreenIndicator().startLoading(
                              message: Constants.kSettingsClearCacheLoading);
                          Directory dir = await getTemporaryDirectory();
                          dir.deleteSync(recursive: true);
                          dir.create();
                          CuckooFullScreenIndicator().stopLoading();
                          CuckooToast(Constants.kSettingsClearCachePrompt,
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                color: ColorPresets.positivePrimary,
                              )).show(delayInMillisec: 250, haptic: true);
                        },
                      ),
                    ],
                  )),
              const SettingsFirstLevelMenuItem(
                icon: Symbols.calendar_view_day_rounded,
                text: Constants.kEventsTitle,
                page: SettingsDetailPage(
                  Constants.kEventsTitle,
                  items: [
                    SettingsItem(
                      SettingsKey.deadlineDisplay,
                      type: SettingsItemType.choice,
                      choiceNames: [
                        'Date Only',
                        'Date + Time',
                        'Days Left',
                        'Detailed'
                      ],
                      defaultValue: 0,
                      label: Constants.kSettingsEventsDeadlineDisplay,
                      description: Constants.kSettingsEventsDeadlineDisplayDesc,
                    ),
                    SettingsItem(SettingsKey.syncCompletionStatus,
                        label: Constants.kSettingsEventsSyncCompletion,
                        description:
                            Constants.kSettingsEventsSyncCompletionDesc,
                        defaultValue: true),
                    SettingsItem(SettingsKey.greyOutCompleted,
                        label: Constants.kSettingsEventsGreyOutComleted,
                        description:
                            Constants.kSettingsEventsGreyOutComletedDesc,
                        defaultValue: true),
                    SettingsItem(SettingsKey.differentiateCustom,
                        label: Constants.kSettingsEventsDiffCustom,
                        description: Constants.kSettingsEventsDiffCustomDesc,
                        defaultValue: true),
                  ],
                ),
              ),
              SettingsFirstLevelMenuItem(
                icon: Symbols.notifications_rounded,
                text: 'Reminders',
              ),
              SettingsFirstLevelMenuItem(
                icon: Symbols.school_rounded,
                text: 'Courses',
              ),
              SettingsFirstLevelMenuItem(
                icon: Symbols.calendar_month_rounded,
                text: 'Calendar',
              ),
              SettingsFirstLevelMenuItem(
                icon: Symbols.info_rounded,
                text: 'About',
              ),
              SettingsFirstLevelMenuItem(
                icon: Symbols.favorite_rounded,
                text: 'Tip Jar',
              ),
              const SizedBox(height: 20.0),
              if (context.loginStatusManager.isUserLoggedIn)
                SettingsFirstLevelMenuItem(
                  icon: Symbols.logout_rounded,
                  text: 'Sign Out',
                  color: ColorPresets.negativePrimary,
                  action: () {
                    const CuckooDialog(
                        title: Constants.kLogOutConfirmation,
                        buttonTitles: [
                          Constants.kYes,
                          Constants.kCancel
                        ],
                        buttonStyles: [
                          CuckooButtonStyle.danger,
                          CuckooButtonStyle.secondary
                        ]).show(context).then((index) {
                      if (index != null && index == 0) {
                        Moodle.logout();
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsFirstLevelMenuItem extends StatelessWidget {
  const SettingsFirstLevelMenuItem(
      {super.key,
      required this.icon,
      required this.text,
      this.color,
      this.action,
      this.page});

  final IconData icon;

  final String text;

  final Color? color;

  final void Function()? action;

  final Widget? page;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (action != null) action!();
        if (page != null) {
          // Push a new page
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => page!),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            const SizedBox(width: 12.0),
            Icon(icon,
                color: color ?? context.cuckooTheme.primaryText, weight: 600),
            const SizedBox(width: 26.0),
            Text(text,
                style: TextStylePresets.body(
                        size: 15.0, weight: FontWeight.w600)
                    .copyWith(color: color ?? context.cuckooTheme.primaryText))
          ],
        ),
      ),
    );
  }
}
