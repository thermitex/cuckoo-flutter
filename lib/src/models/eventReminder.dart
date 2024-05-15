import 'package:json_annotation/json_annotation.dart';
import "eventReminderRule.dart";
part 'eventReminder.g.dart';

@JsonSerializable()
class EventReminder {
  EventReminder();

  late num id;
  String? title;
  late List<EventReminderRule> rules;
  late List scheduledNotifications;
  late num amount;
  late num unit;
  num? hour;
  num? min;
  bool? disabled;

  factory EventReminder.fromJson(Map<String, dynamic> json) =>
      _$EventReminderFromJson(json);
  Map<String, dynamic> toJson() => _$EventReminderToJson(this);
}
