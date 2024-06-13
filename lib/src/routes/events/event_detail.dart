import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/reminders.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/events/create/create.dart';
import 'package:cuckoo/src/routes/events/reminders/reminder_detail.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView(this.event, {super.key});

  final MoodleEvent event;

  Widget _buildEventHeader(BuildContext context) {
    Color headerTint =
        event.color == null ? context.cuckooTheme.secondaryText : event.color!;
    Color? badgeForegroundColor = Color.lerp(
        context.cuckooTheme.popUpBackground,
        event.color == null
            ? context.cuckooTheme.popUpBackground
            : event.color!,
        0.15);
    bool canShowCustomBadge = event.eventtype == MoodleEventTypes.custom &&
        trueSettingsValue(SettingsKey.differentiateCustom);
    bool shouldShowTextHeader =
        event.course != null || (event.course == null && !canShowCustomBadge);

    return ConstrainedBox(
      constraints: BoxConstraints(
          minHeight:
              80 + ((canShowCustomBadge && shouldShowTextHeader) ? 20.0 : 0.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canShowCustomBadge)
            Container(
              margin: const EdgeInsets.only(bottom: 7.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: event.color == null
                    ? headerTint
                    : headerTint.withAlpha(200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_rounded,
                      size: 15, color: badgeForegroundColor),
                  const SizedBox(width: 4.0),
                  Text('Custom Event',
                      style: TextStylePresets.body(
                              size: 12, weight: FontWeight.w500)
                          .copyWith(color: badgeForegroundColor))
                ],
              ),
            ),
          if (shouldShowTextHeader)
            Text(
              event.course == null
                  ? (event.eventtype == MoodleEventTypes.user
                      ? 'Moodle User Event'
                      : 'Custom Event')
                  : event.course!.displayname,
              style: TextStylePresets.body(weight: FontWeight.w600)
                  .copyWith(color: headerTint),
            ),
          if (shouldShowTextHeader) const SizedBox(height: 3.0),
          Text(
            event.name,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStylePresets.body(size: 24, weight: FontWeight.bold)
                .copyWith(height: 1.35),
          )
        ],
      ),
    );
  }

  Widget _buildEventContent(BuildContext context) {
    final children = <Widget>[const SizedBox(height: 10.0)];

    // Add due item
    final remainingDays = (event.remainingTime / 86400).floor().clamp(0, 999);
    final remainingHours =
        (event.remainingTime / 3600).floor().clamp(0, 999) % 24;
    children.add(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Constants.kEventDetailDueItem,
          style: TextStylePresets.body(size: 10, weight: FontWeight.bold)
              .copyWith(color: context.cuckooTheme.secondaryText),
        ),
        const SizedBox(height: 1.5),
        Text(
          '$remainingDays ${remainingDays == 1 ? "day" : "days"} $remainingHours ${remainingHours == 1 ? "hour" : "hours"}',
          style: TextStylePresets.body(weight: FontWeight.bold)
              .copyWith(color: ColorPresets.primary),
        ),
        Text(
          '${DateFormat.Hm().format(event.time)}, ${DateFormat.yMMMd().format(event.time)}',
          style: TextStylePresets.body(),
        ),
      ],
    ));

    if (event.description.isNotEmpty) {
      // Add desc item
      children
        ..add(const SizedBox(height: 20.0))
        ..add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            Constants.kEventDetailDetailItem,
            style: TextStylePresets.body(size: 10, weight: FontWeight.bold)
                .copyWith(color: context.cuckooTheme.secondaryText),
          ),
          const SizedBox(height: 2.5),
          Html(
            data: event.description,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14.0),
              ),
              'p': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14.0),
              )
            },
          ),
        ]));
    }

    // Add reminder item
    final appliedReminders = Reminders().remindersAppliedToEvent(event);
    children
      ..add(const SizedBox(height: 20.0))
      ..add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Constants.kEventDetailReminderItem,
            style: TextStylePresets.body(size: 10, weight: FontWeight.bold)
                .copyWith(color: context.cuckooTheme.secondaryText),
          ),
          const SizedBox(height: 1.5),
          if (falseSettingsValue(SettingsKey.reminderIgnoreCustom) &&
              event.eventtype == MoodleEventTypes.custom)
            Text(
              Constants.kEventDetailMutedRemindersCustom,
              style: TextStylePresets.body()
                  .copyWith(color: context.cuckooTheme.tertiaryText),
            )
          else if (trueSettingsValue(SettingsKey.reminderIgnoreCompleted) &&
              event.isCompleted)
            Text(
              Constants.kEventDetailMutedRemindersCompleted,
              style: TextStylePresets.body()
                  .copyWith(color: context.cuckooTheme.tertiaryText),
            )
          else if (appliedReminders.isEmpty)
            Text(
              Constants.kEventDetailNoReminders,
              style: TextStylePresets.body()
                  .copyWith(color: context.cuckooTheme.tertiaryText),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(appliedReminders.length, (index) {
                final reminder = appliedReminders[index];
                return Builder(builder: (context) {
                  final reminderExpired = reminder.scheduleTimePassed(event);
                  final tint = reminderExpired
                      ? context.cuckooTheme.tertiaryText
                      : context.cuckooTheme.primaryText;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                        ..pop()
                        ..push(
                          MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => ReminderDetailPage(reminder,
                                  fullscreen: true)),
                        );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: RichText(
                          text: TextSpan(
                        style: TextStylePresets.body().copyWith(color: tint),
                        children: [
                          TextSpan(text: reminder.title ?? ''),
                          WidgetSpan(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              child: Icon(Icons.chevron_right_rounded,
                                  size: 16, color: tint),
                            ),
                          ),
                        ],
                      )),
                    ),
                  );
                });
              }),
            )
        ],
      ));

    // To avoid overlapping with fade out effect
    children.add(const SizedBox(height: 20.0));

    return Expanded(
        child: ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple,
            Colors.transparent,
            Colors.transparent,
            Colors.purple
          ],
          stops: [
            0.0,
            0.05,
            0.92,
            1.0
          ], // 10% purple, 80% transparent, 10% purple
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ));
  }

  Widget _buildEventActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CuckooButton(
          text: event.isCompleted
              ? Constants.kUnmarkAsCompleted
              : Constants.kMarkAsCompleted,
          icon: event.isCompleted
              ? Symbols.remove_done_rounded
              : Symbols.check_rounded,
          action: () => _toggleEventCompletion(context),
        ),
        const SizedBox(height: 10.0),
        if (event.eventtype != MoodleEventTypes.custom)
          CuckooButton(
            style: CuckooButtonStyle.secondary,
            text: Constants.kViewActivity,
            icon: Symbols.open_in_new_rounded,
            action: () => Moodle.openMoodleUrl(event.url),
          )
        else
          CuckooButton(
            style: CuckooButtonStyle.secondary,
            text: Constants.kEditCustomEvent,
            icon: Symbols.edit_document_rounded,
            action: () {
              Navigator.of(context, rootNavigator: true)
                ..pop()
                ..push(MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => CreateEventPage(event),
                ));
            },
          )
      ],
    );
  }

  void _toggleEventCompletion(BuildContext context) {
    // Close event details first
    Navigator.of(context, rootNavigator: true).pop();
    // Set completion
    bool cachedCompletion = event.isCompleted;
    event.completionMark = !cachedCompletion;
    // Reschedule reminders
    Reminders().rescheduleAll();
    // Show toast
    CuckooToast(
        cachedCompletion
            ? Constants.kUnmarkCompleteToast
            : Constants.kMarkCompleteToast,
        icon: Icon(
          cachedCompletion
              ? Icons.unpublished_rounded
              : Icons.check_circle_rounded,
          color: ColorPresets.positivePrimary,
        )).show(delayInMillisec: 250, haptic: true);
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(30.0));
    final gradient = event.color != null
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, -0.2),
            colors: [event.color!.withAlpha(50), Colors.transparent])
        : null;

    return ClipRRect(
        borderRadius: borderRadius,
        child: SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25.0),
            decoration: BoxDecoration(gradient: gradient),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventHeader(context),
                  const SizedBox(height: 18.0),
                  _buildEventContent(context),
                  const SizedBox(height: 20.0),
                  _buildEventActions(context)
                ],
              ),
            ),
          ),
        ));
  }
}
