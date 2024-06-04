import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/events/events_list.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarFormat _calendarFormat;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay,
      {bool enforce = false}) {
    if (!isSameDay(_selectedDay, selectedDay) || enforce) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  DaysOfWeekStyle _daysOfWeekStyle() {
    return DaysOfWeekStyle(
      weekdayStyle: TextStylePresets.body(),
      weekendStyle: TextStylePresets.body()
          .copyWith(color: context.cuckooTheme.secondaryText),
    );
  }

  HeaderStyle _headerStyle() {
    return HeaderStyle(
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            border: const Border.fromBorderSide(
                BorderSide(color: ColorPresets.primary))),
        titleTextStyle:
            TextStylePresets.body(size: 17.0, weight: FontWeight.w600));
  }

  CalendarBuilders<MoodleEvent> _builders() {
    const colorStops = [
      Color.fromARGB(175, 76, 175, 79),
      Colors.yellow,
      Colors.red,
      Colors.deepPurple
    ];
    const maxWl = 4.5;
    Color workloadColor(DateTime day) {
      DateTime now = DateTime.now();
      if (day.isBefore(DateTime(now.year, now.month, now.day))) {
        return context.cuckooTheme.tertiaryBackground;
      }
      final wl = context.eventManager.workloadOnDate(day, maxWl: maxWl);
      if (wl < 0.0001) return context.cuckooTheme.tertiaryBackground;
      final stopInterval = maxWl / (colorStops.length - 1);
      final i = (wl ~/ stopInterval).clamp(0, colorStops.length - 2);
      return Color.lerp(colorStops[i], colorStops[i + 1],
          (wl - i * stopInterval) / stopInterval)!;
    }
    Gradient indicatorGradient(DateTime day) {
      final prev = workloadColor(DateTime(day.year, day.month, day.day - 1));
      final curr = workloadColor(day);
      final next = workloadColor(DateTime(day.year, day.month, day.day + 1));

      return LinearGradient(
        colors: [Color.lerp(prev, curr, 0.5)!, curr, curr, Color.lerp(curr, next, 0.5)!],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.2, 0.8, 1.0],
      );
    }

    LayoutBuilder calendarDayBuilder(DateTime day,
        {Color? color, TextStyle? textStyle, bool showIndicator = true}) {
      bool isFirst = day.day == 1;
      bool isLast = DateTime(day.year, day.month, day.day + 1).day == 1;
      return LayoutBuilder(builder: (context, constraints) {
        return Stack(children: [
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Center(
                child: Text(day.day.toString(), style: textStyle),
              ),
            ),
          ),
          if (showIndicator)
            Positioned(
              bottom: 0.0,
              child: Container(
                width: constraints.maxWidth,
                height: 4.5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: isFirst ? const Radius.circular(3.0) : Radius.zero,
                      right: isLast ? const Radius.circular(3.0) : Radius.zero,
                    ),
                    gradient: indicatorGradient(day)),
              ),
            ),
        ]);
      });
    }

    return CalendarBuilders<MoodleEvent>(
      markerBuilder: (context, day, events) {
        if (events.isEmpty) {
          return const SizedBox.shrink();
        }
        return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: events.length.clamp(0, 3),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(top: 27),
                padding: const EdgeInsets.all(1),
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSameDay(day, _selectedDay)
                          ? Colors.white
                          : (events[index].color ??
                              context.cuckooTheme.tertiaryText)),
                ),
              );
            });
      },
      defaultBuilder: (context, day, focusedDay) {
        return calendarDayBuilder(day,
            textStyle: TextStylePresets.body().copyWith(
                color: (day.weekday == DateTime.sunday ||
                        day.weekday == DateTime.saturday)
                    ? context.cuckooTheme.secondaryText
                    : context.cuckooTheme.primaryText));
      },
      todayBuilder: (context, day, focusedDay) {
        return calendarDayBuilder(day,
            color: ColorPresets.primary.withAlpha(context.isDarkMode ? 50 : 25),
            textStyle:
                TextStylePresets.body().copyWith(color: ColorPresets.primary));
      },
      selectedBuilder: (context, day, focusedDay) {
        return calendarDayBuilder(day,
            color: day.month == focusedDay.month
                ? ColorPresets.primary
                : context.cuckooTheme.tertiaryBackground,
            showIndicator: day.month == focusedDay.month,
            textStyle:
                TextStylePresets.body(size: 16.0, weight: FontWeight.w500)
                    .copyWith(color: Colors.white));
      },
      outsideBuilder: (context, day, focusedDay) {
        return calendarDayBuilder(day,
            showIndicator: false,
            textStyle: TextStylePresets.body()
                .copyWith(color: context.cuckooTheme.tertiaryText));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _calendarFormat = CalendarFormat
        .values[Settings().get<int>(SettingsKey.calendarFormat) ?? 0];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: CuckooLargeAppBar(
        title: Constants.kCalendarTitle,
        actionItems: [
          CuckooAppBarActionItem(
            icon: const Icon(
              Icons.today_rounded,
              color: ColorPresets.primary,
              size: 20,
            ),
            backgroundColor: context.cuckooTheme.secondaryBackground,
            backgroundPadding: const EdgeInsets.all(5.0),
            onPressed: () => _onDaySelected(today, today, enforce: true),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: [
              TableCalendar<MoodleEvent>(
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                firstDay: DateTime(today.year, today.month - 1, 1),
                lastDay: DateTime(today.year + 1, today.month, today.day),
                calendarFormat: _calendarFormat,
                onDaySelected: _onDaySelected,
                daysOfWeekStyle: _daysOfWeekStyle(),
                headerStyle: _headerStyle(),
                calendarBuilders: _builders(),
                pageJumpingEnabled: true,
                eventLoader: (day) => context.eventManager.eventsforDate(day),
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    Settings().set<int>(
                        SettingsKey.calendarFormat, format.index,
                        notify: false);
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 18.0),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final events =
                        context.eventManager.eventsforDate(_selectedDay);
                    if (events.isEmpty) {
                      // In case there are no events
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 25),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_available_rounded, color: context.cuckooTheme.tertiaryText, size: 50,),
                              const SizedBox(height: 10.0),
                              Text(
                                Constants.kCalendarNoEventsFound,
                                style: TextStylePresets.body().copyWith(
                                    color: context.cuckooTheme.secondaryText),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: events.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0 || index == events.length + 1) {
                          return const SizedBox(height: 8.0);
                        }
                        return MoodleEventListTile(
                          events[index - 1],
                          displayDeadline: false,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 7.0);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
