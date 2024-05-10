// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eventReminderRule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventReminderRule _$EventReminderRuleFromJson(Map<String, dynamic> json) =>
    EventReminderRule()
      ..subject = json['subject'] as num
      ..action = json['action'] as num
      ..pattern = json['pattern'] as String
      ..relationWithNext = json['relationWithNext'] as num?;

Map<String, dynamic> _$EventReminderRuleToJson(EventReminderRule instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'action': instance.action,
      'pattern': instance.pattern,
      'relationWithNext': instance.relationWithNext,
    };
