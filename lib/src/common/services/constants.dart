/// Constants used in Cuckoo.
class Constants {
  static const kEventsTitle = 'Events';
  static const kCoursesTitle = 'Courses';
  static const kCalendarTitle = 'Calendar';
  static const kReminderTitle = 'Reminders';
  static const kYes = 'Yes';
  static const kCancel = 'Cancel';
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
  static const kNoConnectivityErr =
      'It seems that you are not connected to the Internet.';
  static const kNoConnectivityErrDesc =
      'Connect to the Internet and try again by tapping on the button below.';
  static const kSessionInvalidErr =
      'We are having trouble connecting to Moodle.';
  static const kSessionInvalidErrDesc =
      'Your session may have expired or your Internet connection is unstable. Please try logging into Moodle again.';
  static const kTryAgain = 'Try Again';
  static const kEventDetailDueItem = 'DUE IN';
  static const kEventDetailDetailItem = 'DESCRIPTION';
  static const kMarkCompleteToast = 'Event Marked as Completed';
  static const kUnmarkCompleteToast = 'Event Unmarked as Completed';
  static const kMoodleUrlOpenLoading = 'Launching Moodle website...';
  static const kMorePanelGrouping = 'Group By';
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
  static const kReminderSavedPrompt = 'Reminder Saved';
  static const kReminderDeletedPrompt = 'Reminder Deleted';
  static const kReminderDeleteButton = 'Delete Reminder';
  static const kReminderDeletionDialogText =
      'Are you sure to delete this reminder?';
}
