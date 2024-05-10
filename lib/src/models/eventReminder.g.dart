// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eventReminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventReminder _$EventReminderFromJson(Map<String, dynamic> json) =>
    EventReminder()
      ..id = json['id'] as num
      ..title = json['title'] as String
      ..rules = (json['rules'] as List<dynamic>)
          .map((e) => EventReminderRule.fromJson(e as Map<String, dynamic>))
          .toList()
      ..scheduledNotifications = json['scheduledNotifications'] as List<num>
      ..amount = json['amount'] as num
      ..unit = json['unit'] as num
      ..hour = json['hour'] as num?
      ..min = json['min'] as num?
      ..disabled = json['disabled'] as bool?;

Map<String, dynamic> _$EventReminderToJson(EventReminder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'rules': instance.rules,
      'scheduledNotifications': instance.scheduledNotifications,
      'amount': instance.amount,
      'unit': instance.unit,
      'hour': instance.hour,
      'min': instance.min,
      'disabled': instance.disabled,
    };
