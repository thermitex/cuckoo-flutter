import 'package:json_annotation/json_annotation.dart';

part 'eventReminderRule.g.dart';

@JsonSerializable()
class EventReminderRule {
  EventReminderRule();

  late num subject;
  late num action;
  late String pattern;
  num? relationWithNext;
  
  factory EventReminderRule.fromJson(Map<String,dynamic> json) => _$EventReminderRuleFromJson(json);
  Map<String, dynamic> toJson() => _$EventReminderRuleToJson(this);
}
