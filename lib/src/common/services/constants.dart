import 'package:flutter/material.dart';

/// Constants used in Cuckoo.
class Constants {
  static const kEventsTitle = 'Events';
  static const kCoursesTitle = 'Courses';
  static const kCalendarTitle = 'Calendar';
  static const kReminderTitle = 'Reminders';
  static const kYes = 'Yes';
  static const kCancel = 'Cancel';
  static const kOK = 'OK';
  static const kEventsRequireLoginPrompt =
      'Hey there, would you mind connecting us to Moodle? Much appreciated.';
  static const kLoginMoodleButton = 'Log in to HKU Moodle';
  static const kLoginMoodleLoading = 'Setting you up for Cuckoo...';
  static const kEventInOneWeekGroupName = 'WITHIN A WEEK';
  static const kEventInOneMonthGroupName = 'WITHIN A MONTH';
  static const kEventAfterOneMonthGroupName = 'AFTER A MONTH';
  static const kMarkAsCompleted = 'Mark as Completed';
  static const kUnmarkAsCompleted = 'Unmark as Completed';
  static const kViewActivity = 'Check Event on Moodle';
  static const kEditCustomEvent = 'Edit Custom Event';
  static const kNoConnectivityErr =
      'It seems that you are not connected to the Internet.';
  static const kNoConnectivityErrDesc =
      'Connect to the Internet and try again by tapping on the button below.';
  static const kSessionInvalidErr =
      'We are having trouble connecting to Moodle.';
  static const kSessionInvalidErrDesc =
      'Your session may have expired or your Internet connection is unstable. Please try logging into Moodle again.';
  static const kAuthIncompleteDialog =
      'The login is not complete. Try restarting the app and log in again if this keeps happening.';
  static const kAuthTryAgainButton = 'Try Again in External Browser';
  static const kTryAgain = 'Try Again';
  static const kEventDetailDueItem = 'DUE IN';
  static const kEventDetailDetailItem = 'DESCRIPTION';
  static const kEventDetailReminderItem = 'REMINDERS';
  static const kEventDetailMutedRemindersCompleted =
      'Reminders are muted for completed events.';
  static const kEventDetailMutedRemindersCustom =
      'Reminders are muted for custom events.';
  static const kEventDetailNoReminders = 'No reminders applied to this event.';
  static const kMarkCompleteToast = 'Event Marked as Completed';
  static const kUnmarkCompleteToast = 'Event Unmarked as Completed';
  static const kMoodleUrlOpenLoading = 'Launching Moodle website...';
  static const kMorePanelGrouping = 'Group By';
  static const kMorePanelSorting = 'Sort By';
  static const kMorePanelFiltering = 'Filter By';
  static const kMorePanelSync = 'Sync With Moodle';
  static const kMorePanelAddEvent = 'Add Custom Event';
  static const kAddReminder = 'Add Reminder';
  static const kReminderIntroPrompt =
      'Afraid of missing deadlines? Adding a reminder is probably a good idea.';
  static const kNewReminderTitle = 'New Reminder';
  static const kAddNewRules = 'Add Rules';
  static const kRulesUpperLimitToast = 'Cannot add more than 8 rules';
  static const kRuleSubjectCourseCodeDesc =
      'Course code of a course composed of capital letters and numbers (e.g., “CAES1000”).';
  static const kRuleSubjectCourseNameDesc =
      'Full name of a course excluding the course code (e.g., “Core University English”).';
  static const kRuleSubjectEventTitleDesc =
      'Title of the event or Moodle assignment (e.g., “Assignment 1”).';
  static const kRuleActionContainsDesc =
      'Reminder will apply to events that contains the content, case-insensitive.';
  static const kRuleActionNotContainsDesc =
      'Reminder will apply to events that does not contain the content, case-insensitive.';
  static const kRuleActionMatchedDesc =
      'Reminder will apply to events that matches the content as a regular expression pattern.';
  static const kReminderSubjectChoices = [
    'Course Code',
    'Course Name',
    'Event Title',
  ];
  static const kReminderSubjectChoiceIcons = [
    Icons.data_array_rounded,
    Icons.school_rounded,
    Icons.event_rounded
  ];
  static const kReminderActionChoices = [
    'Contains',
    'Does Not Contain',
    'Matches'
  ];
  static const kReminderRelationChoices = ['AND', 'OR'];
  static const kReminderSavedPrompt = 'Reminder Saved';
  static const kReminderDeletedPrompt = 'Reminder Deleted';
  static const kCustomEventDeletedPrompt = 'Custom Event Deleted';
  static const kReminderDeleteButton = 'Delete Reminder';
  static const kCustomEventDeleteButton = 'Delete Custom Event';
  static const kReminderDeletionDialogText =
      'Are you sure to delete this reminder?';
  static const kCustomEventDeletionDialogText =
      'Are you sure to delete this custom event?';
  static const kCustomEventExpiredDialogText =
      'Cannot create a custom event with due date earlier than now.';
  static const kCreateEventPageTitle = 'New Custom Event';
  static const kCustomEventSavedPrompt = 'Custom Event Saved';
  static const kNoCoursesPrompt =
      'All the courses you have enrolled on Moodle will appear here.';
  static const kNoFavoriteCoursesPrompt =
      'Mark your courses as favorite and they will appear here.';
  static const kShowAllCoursesButton = 'Show All Courses';
  static const kSetCourseFavorite = 'Course Marked As Favorite';
  static const kUnsetCourseFavorite = 'Course Unmarked As Favorite';
  static const kCourseViewTypeDisplayTexts = ['Course Contents', 'Grades'];
  static const kCourseViewTypeIcons = [
    Icons.format_list_bulleted_rounded,
    Icons.assessment_outlined,
  ];
  static const kDownloadFileLoading = 'Downloading file...';
  static const kEventsClearPrompt =
      'Amazing! There are currently no upcoming events for you.';
  static const kCalendarNoEventsFound = 'No events found for the selected day.';
  static const kLogOutConfirmation =
      'Are you sure to sign out current Moodle account?';
  static const kSettingsGeneral = 'General';
  static const kSettingsGeneralDefaultTab = 'Default Tab';
  static const kSettingsGeneralDefaultTabDesc =
      'The default tab displayed every time Cuckoo is launched.';
  static const kSettingsGeneralTheme = 'App Theme';
  static const kSettingsGeneralClearCache = 'Clear Cache';
  static const kSettingsClearCacheLoading = 'Clearing cached files...';
  static const kSettingsClearCachePrompt = 'Cache Successfully Cleared';
  static const kSettingsEventsDeadlineDisplay = 'Deadline Display Format';
  static const kSettingsEventsDeadlineDisplayDesc =
      'How deadline is displayed at each row of the events list.';
  static const kSettingsEventsSyncCompletion = 'Sync Completion Status';
  static const kSettingsEventsSyncCompletionDesc =
      'Sync event completion status with Moodle, including fetching status from Moodle and updating status to Moodle.';
  static const kSettingsEventsGreyOutComleted = 'Grey Out Completed Events';
  static const kSettingsEventsGreyOutComletedDesc =
      'When this option is turned on, completed events will be greyed out in the event list with strikethrough.';
  static const kSettingsEventsDiffCustom = 'Differentiate Custom Events';
  static const kSettingsEventsDiffCustomDesc =
      'Add stripes to the custom events on the event list to differentiate them from Moodle events.';
  static const kSettingsCoursesOnlyResources = 'Only Display Resources';
  static const kSettingsCoursesOnlyResourcesDesc =
      'When this option is turned on, course detail page will only display course resources and hide other texts to avoid unexpected layout caused by rendering formatted content.';
  static const kSettingsCoursesOpenInBrowser =
      'Open Resource Modules in Browser';
  static const kSettingsCoursesOpenInBrowserDesc =
      'For course modules associated with a file, open the module in browser instead of directly download the associated file.';
  static const kSettingsCalendarShowWorkload = 'Show Workload Indicator';
  static const kSettingsCalendarShowWorkloadDesc =
      'Show workload indicator below each date in the calendar, where green represents lighter workload and red represents heavier workload.';
  static const kSettingsReminderIgnoreCompleted = 'Ignore Completed Events';
  static const kSettingsReminderIgnoreCompletedDesc =
      'When this option is turned on, reminders will not apply to events that are marked as completed.';
  static const kSettingsReminderIgnoreCustom = 'Ignore Custom Events';
  static const kSettingsReminderIgnoreCustomDesc =
      'When this option is turned on, reminders will not apply to custom events.';
  static const kSettingsAccountTitle =
      'You have successfully connected Cuckoo with Moodle.';
  static const kSettingsAccountDesc =
      'Cuckoo\'s connection with Moodle is safe and follows the standard procedure of service communication, without scraping or saving cookies from browser. ';
  static const kAboutOpenSourceTitle =
      'Cuckoo is now an open-source project written in Flutter.';
  static const kAboutOpenSourceDesc =
      'Feel free to contribute to Cuckoo and add more exciting features. Let me know if you would like to be a core dev. ';
  static const kLearnMore = 'Learn more';
  static const kAboutTitle = 'About';
  static const kTipTitle = 'Tip Jar';
  static const kAccountLearnMoreUrl = 'https://cuckoo-hku.xyz/safety';
  static const kCheckGithub = 'Check repo on Github';
  static const kAboutWebsiteTitle = 'Project Website';
  static const kAboutWebsiteUrl = 'https://cuckoo-hku.xyz';
  static const kAboutDiscordTitle = 'Discord Community';
  static const kAboutDiscordContent =
      'Join our Discord community to leave your thoughts and receive latest updates.';
  static const kAboutDiscordUrl = 'https://cuckoo-hku.xyz/discord';
  static const kAboutPrivacyTitle = 'Privacy Policy';
  static const kAboutPrivacyUrl = 'https://cuckoo-hku.xyz/privacy';
  static const kAboutSoftwareLicense = 'Software Licenses';
  static const kAboutSoftwareLicenseUrl = 'https://cuckoo-hku.xyz/license';
  static const kProjectGithubUrl =
      'https://github.com/thermitex/cuckoo-flutter';
  static const kProjectContributorsUrl =
      'https://github.com/thermitex/cuckoo-flutter/graphs/contributors';
  static const kTipJarTitle =
      'Donate any amount to help Cuckoo stay on App Store.';
  static const kTipJarSubtitle =
      'Although Cuckoo is a free app, it relies on your support so that it can be accessible to more users like you.';
  static const kIAPProductIDs = <String>{
    'cuckoo.small.tip',
    'cuckoo.medium.tip',
    'cuckoo.large.tip',
    'cuckoo.giant.tip'
  };
  static const kTipThankYouTitle =
      'Thank you for your tip! Your support means a lot to us.';
  static const kTipThankYouDesc =
      'We strive to constantly improve Cuckoo for a better user experience. Don\'t forget to join the Discord community to let us know how we can further improve.';
  static const kNotiPermissionWarning =
      'Cuckoo currently does not have the permission to display notifications, and therfore the reminders here may not work as expected. Please go to Settings and allow notifications from Cuckoo.';
}
