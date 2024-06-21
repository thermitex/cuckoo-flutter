import 'dart:io';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/reminders.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/routes/settings/settings_about.dart';
import 'package:cuckoo/src/routes/settings/settings_account.dart';
import 'package:cuckoo/src/routes/settings/settings_page.dart';
import 'package:cuckoo/src/routes/settings/settings_tip.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'settings_topbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _moodleAccountBar(BuildContext context) {
    Widget accessory() {
      if (context.loginStatusManager.isUserLoggedIn) {
        if (context.eventManager.status == MoodleManagerStatus.idle) {
          return const Icon(
            Icons.check_circle_rounded,
            color: CuckooColors.positivePrimary,
          );
        } else if (context.eventManager.status ==
            MoodleManagerStatus.updating) {
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: SizedBox(
              height: 20,
              width: 20,
              child: Center(
                  child: CircularProgressIndicator(
                color: context.theme.quaternaryText,
                strokeWidth: 3.0,
              )),
            ),
          );
        } else if (context.eventManager.status == MoodleManagerStatus.error) {
          return const Icon(
            Icons.warning_rounded,
            color: CuckooColors.negativePrimary,
          );
        }
      }
      return Icon(
        Icons.login_rounded,
        color: context.theme.secondaryText,
      );
    }

    void accountAction() {
      if (Moodle().loginStatusManager.isUserLoggedIn) {
        if (Moodle().eventManager.status == MoodleManagerStatus.idle) {
          context.platformDependentPush(
              builder: (context) => const SettingsAccountPage());
        } else if (Moodle().eventManager.status == MoodleManagerStatus.error) {
          showMoodleConnectionErrorDetails(context);
        }
      }
      Moodle.startAuth();
    }

    return GestureDetector(
      onTap: () => accountAction(),
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 65.0,
        decoration: BoxDecoration(
          color: context.theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                context.loginStatusManager.isUserLoggedIn
                    ? 'Moodle Account'
                    : Constants.kLoginMoodleButton,
                style:
                    CuckooTextStyles.body(size: 15.0, weight: FontWeight.w600),
              )),
              accessory()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryBackground,
      appBar: const SettingsTopBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8.0),
              _moodleAccountBar(context),
              const SizedBox(height: 15.0),
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
                          // Clean downloads
                          Directory dir = await getTemporaryDirectory();
                          Directory cacheDir = Directory('${dir.path}/cuckoo');
                          cacheDir.deleteSync(recursive: true);
                          cacheDir.create();
                          // Clean course cached contents
                          Moodle.clearCourseCachedContents();
                          CuckooFullScreenIndicator().stopLoading();
                          CuckooToast(Constants.kSettingsClearCachePrompt,
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                color: CuckooColors.positivePrimary,
                              )).show();
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
                text: Constants.kReminderTitle,
                page: SettingsDetailPage(Constants.kReminderTitle, items: [
                  SettingsItem(SettingsKey.reminderIgnoreCompleted,
                      label: Constants.kSettingsReminderIgnoreCompleted,
                      description:
                          Constants.kSettingsReminderIgnoreCompletedDesc,
                      defaultValue: true,
                      onChanged: (_) => Reminders().rescheduleAll()),
                  SettingsItem(SettingsKey.reminderIgnoreCustom,
                      label: Constants.kSettingsReminderIgnoreCustom,
                      description: Constants.kSettingsReminderIgnoreCustomDesc,
                      defaultValue: false,
                      onChanged: (_) => Reminders().rescheduleAll()),
                ]),
              ),
              const SettingsFirstLevelMenuItem(
                icon: Symbols.school_rounded,
                text: Constants.kCoursesTitle,
                page: SettingsDetailPage(Constants.kCoursesTitle, items: [
                  SettingsItem(SettingsKey.onlyShowResourcesInCourses,
                      label: Constants.kSettingsCoursesOnlyResources,
                      description: Constants.kSettingsCoursesOnlyResourcesDesc,
                      defaultValue: true),
                  SettingsItem(SettingsKey.openResourceInBrowser,
                      label: Constants.kSettingsCoursesOpenInBrowser,
                      description: Constants.kSettingsCoursesOpenInBrowserDesc,
                      defaultValue: false),
                ]),
              ),
              const SettingsFirstLevelMenuItem(
                icon: Symbols.calendar_month_rounded,
                text: Constants.kCalendarTitle,
                page: SettingsDetailPage(Constants.kCalendarTitle, items: [
                  SettingsItem(SettingsKey.showWorkloadIndicator,
                      label: Constants.kSettingsCalendarShowWorkload,
                      description: Constants.kSettingsCalendarShowWorkloadDesc,
                      defaultValue: true),
                ]),
              ),
              SettingsFirstLevelMenuItem(
                icon: Symbols.info_rounded,
                text: Constants.kAboutTitle,
                action: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => SettingsAboutPage(
                      version: packageInfo.version,
                    ),
                  ));
                },
              ),

              /// Keep tip jar within iOS for now
              if (Platform.isIOS)
                SettingsFirstLevelMenuItem(
                  icon: Symbols.favorite_rounded,
                  text: Constants.kTipTitle,
                  action: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const SettingsTipPage(),
                    ));
                  },
                ),
              const SizedBox(height: 20.0),
              if (context.loginStatusManager.isUserLoggedIn)
                SettingsFirstLevelMenuItem(
                  icon: Symbols.logout_rounded,
                  text: 'Sign Out',
                  color: CuckooColors.negativePrimary,
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
          context.platformDependentPush(builder: (context) => page!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            const SizedBox(width: 12.0),
            Icon(icon, color: color ?? context.theme.primaryText, weight: 600),
            const SizedBox(width: 26.0),
            Text(text,
                style: CuckooTextStyles.body(
                    size: 15.0,
                    weight: FontWeight.w600,
                    color: color ?? context.theme.primaryText))
          ],
        ),
      ),
    );
  }
}
