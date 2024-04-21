// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moodleEvent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodleEvent _$MoodleEventFromJson(Map<String, dynamic> json) => MoodleEvent()
  ..id = json['id'] as num
  ..name = json['name'] as String
  ..description = json['description'] as String
  ..format = json['format'] as num?
  ..courseid = json['courseid'] as num?
  ..categoryid = json['categoryid'] as String?
  ..groupid = json['groupid'] as String?
  ..userid = json['userid'] as num?
  ..repeatid = json['repeatid'] as String?
  ..modulename = json['modulename'] as String?
  ..instance = json['instance'] as num?
  ..eventtype = json['eventtype'] as String
  ..timestart = json['timestart'] as num
  ..timeduration = json['timeduration'] as num?
  ..visible = json['visible'] as num?
  ..sequence = json['sequence'] as num?
  ..timemodified = json['timemodified'] as num?
  ..subscriptionid = json['subscriptionid'] as String?
  ..completed = json['completed'] as bool?;

Map<String, dynamic> _$MoodleEventToJson(MoodleEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'format': instance.format,
      'courseid': instance.courseid,
      'categoryid': instance.categoryid,
      'groupid': instance.groupid,
      'userid': instance.userid,
      'repeatid': instance.repeatid,
      'modulename': instance.modulename,
      'instance': instance.instance,
      'eventtype': instance.eventtype,
      'timestart': instance.timestart,
      'timeduration': instance.timeduration,
      'visible': instance.visible,
      'sequence': instance.sequence,
      'timemodified': instance.timemodified,
      'subscriptionid': instance.subscriptionid,
      'completed': instance.completed,
    };
