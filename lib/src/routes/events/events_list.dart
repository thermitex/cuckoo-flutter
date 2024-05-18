import 'dart:math';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/events/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';

// Layout constants
const kGapBetweenEvents = 7.0;
const kEventHeaderHeight = 33.0;
const kEventTileHeight = 60.0;
const kGapBetweenSections = 5.0;
const kSidePaddings = 18.0;
const kEventTileBorderRadius = 12.0;
const kBottomOffset = 20.0;

/// Display stye of deadlines on the events page.
enum DeadlineDisplayStyle {
  date,
  dateAndTime,
  daysRemaining,
  daysRemainingAndTime,
}

class MoodleEventListView extends StatefulWidget {
  const MoodleEventListView({
    super.key,
  });

  @override
  State<MoodleEventListView> createState() => _MoodleEventListViewState();
}

class _MoodleEventListViewState extends State<MoodleEventListView> {
  late GroupedMoodleEvents events;

  Widget _contentForSection(int index) {
    List<MoodleEvent> sectionEvents = events.values.elementAt(index);
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: sectionEvents.length + 1,
      itemBuilder: (context, index) {
        if (index < sectionEvents.length) {
          return MoodleEventListTile(sectionEvents[index]);
        } else {
          return const SizedBox(height: kGapBetweenSections);
        }
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: kGapBetweenEvents);
      },
    );
  }

  Widget _headerForSection(int index, double stuckAmount) {
    return Container(
      height: kEventHeaderHeight,
      width: double.infinity,
      color: context.cuckooTheme.primaryBackground,
      child: Padding(
        padding:
            const EdgeInsetsDirectional.only(start: kSidePaddings + 2, top: 10),
        child: Text(
          events.keys.elementAt(index),
          style: TextStylePresets.body(size: 10.5).copyWith(
            fontWeight: FontWeight.w600,
            color: Color.lerp(context.cuckooTheme.secondaryText,
                ColorPresets.primary, stuckAmount),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Subscribe to grouped events
    events = context.eventManager.groupedEvents(
        groupBy: MoodleEventGroupingType.values[
            context.settingsValue<int>(SettingsKey.eventGroupingType) ??
                MoodleEventGroupingType.byTime.index]);

    return ListView.builder(
        itemCount: events.length + 1,
        itemBuilder: (context, index) {
          if (index < events.length) {
            return StickyHeaderBuilder(
              builder: (context, stuckAmount) {
                stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
                return _headerForSection(index, stuckAmount);
              },
              content: _contentForSection(index),
            );
          } else {
            return const SizedBox(height: kBottomOffset);
          }
        });
  }
}

class MoodleEventListTile extends StatelessWidget {
  const MoodleEventListTile(
    this.event, {
    super.key,
  });

  final MoodleEvent event;

  Color _eventTintColor(BuildContext context) {
    if (event.isCompleted) {
      return context.cuckooTheme.tertiaryText;
    }
    return event.color ?? context.cuckooTheme.tertiaryText;
  }

  Widget _eventContent(BuildContext context) {
    List<Widget> children = [];
    if (event.course != null) {
      children.add(Text(event.course!.courseCode,
          style: TextStylePresets.body(size: 10.5).copyWith(
              fontWeight: FontWeight.bold, color: _eventTintColor(context))));
    }
    children.add(Text(event.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStylePresets.body(size: 15, weight: FontWeight.normal)
            .copyWith(
                color: event.isCompleted
                    ? context.cuckooTheme.tertiaryText
                    : context.cuckooTheme.primaryText,
                decoration:
                    event.isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: context.cuckooTheme.tertiaryText)));
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _eventDeadline(BuildContext context) {
    String deadlineDisplay(DeadlineDisplayStyle style) {
      DateTime eventTime = event.time;
      final date = DateFormat.MMMd().format(eventTime);
      final time = DateFormat.Hm().format(eventTime);
      final daysRemaining = (event.remainingTime / 86400).floor().clamp(0, 999);
      final daysStr = daysRemaining == 0
          ? 'Today'
          : '$daysRemaining day${daysRemaining > 1 ? "s" : ""}';
      switch (style) {
        case DeadlineDisplayStyle.date:
          return date;
        case DeadlineDisplayStyle.dateAndTime:
          return '$date\n$time';
        case DeadlineDisplayStyle.daysRemaining:
          return daysStr;
        case DeadlineDisplayStyle.daysRemainingAndTime:
          return '$daysStr\n$time';
        default:
          return '';
      }
    }

    return GestureDetector(
      onTap: () => Settings().switchChoice(
          SettingsKey.deadlineDisplay, DeadlineDisplayStyle.values.length,
          defaultChoice: DeadlineDisplayStyle.daysRemainingAndTime.index),
      child: Container(
        width: 70.0,
        color: context.cuckooTheme.tertiaryBackground,
        child: Center(
            child: Text(
          deadlineDisplay(DeadlineDisplayStyle.values[
              context.settingsValue<int>(SettingsKey.deadlineDisplay) ??
                  DeadlineDisplayStyle.daysRemainingAndTime.index]),
          textAlign: TextAlign.center,
          style: TextStylePresets.body(size: 11).copyWith(
              fontWeight: FontWeight.w600,
              color: event.isCompleted
                  ? context.cuckooTheme.tertiaryText
                  : context.cuckooTheme.primaryText,
              height: 1.3),
        )),
      ),
    );
  }

  Future<void> _openEventDetails(BuildContext context) {
    return showModalBottomSheet<void>(
      constraints: BoxConstraints(
          // Takes at most 72% of the screen, can go up to 90% if less than 350
          maxHeight: max(MediaQuery.of(context).size.height * 0.72,
              min(350, MediaQuery.of(context).size.height * 0.9)),
          maxWidth: 650),
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      backgroundColor: context.cuckooTheme.popUpBackground,
      builder: (context) {
        return EventDetailView(event);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kEventTileHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSidePaddings),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kEventTileBorderRadius),
          child: GestureDetector(
            onTap: () => _openEventDetails(context),
            child: Container(
              color: context.cuckooTheme.secondaryBackground,
              child: Row(
                children: [
                  const SizedBox(width: 8.0),
                  Container(
                    height: kEventTileHeight - 2 * 8.0,
                    width: 10.0,
                    decoration: BoxDecoration(
                      color: _eventTintColor(context),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  const SizedBox(width: 9.0),
                  _eventContent(context),
                  const SizedBox(width: 9.0),
                  _eventDeadline(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
