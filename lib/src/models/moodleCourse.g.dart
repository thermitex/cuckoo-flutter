// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moodleCourse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodleCourse _$MoodleCourseFromJson(Map<String, dynamic> json) => MoodleCourse()
  ..id = json['id'] as num
  ..shortname = json['shortname'] as String
  ..fullname = json['fullname'] as String
  ..displayname = json['displayname'] as String
  ..idnumber = json['idnumber'] as String
  ..visible = json['visible'] as num
  ..summary = json['summary'] as String
  ..summaryformat = json['summaryformat'] as num
  ..format = json['format'] as String
  ..showgrades = json['showgrades'] as bool
  ..lang = json['lang'] as String
  ..enablecompletion = json['enablecompletion'] as bool?
  ..completionhascriteria = json['completionhascriteria'] as bool?
  ..completionusertracked = json['completionusertracked'] as bool?
  ..category = json['category'] as num?
  ..progress = json['progress'] as num?
  ..completed = json['completed'] as bool?
  ..startdate = json['startdate'] as num?
  ..enddate = json['enddate'] as num?
  ..marker = json['marker'] as num?
  ..lastaccess = json['lastaccess'] as num?
  ..isfavourite = json['isfavourite'] as bool
  ..hidden = json['hidden'] as bool
  ..overviewfiles = json['overviewfiles'] as List<dynamic>?
  ..showactivitydates = json['showactivitydates'] as bool?
  ..showcompletionconditions = json['showcompletionconditions'] as bool?
  ..timemodified = json['timemodified'] as num?
  ..colorHex = json['colorHex'] as String?;

Map<String, dynamic> _$MoodleCourseToJson(MoodleCourse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shortname': instance.shortname,
      'fullname': instance.fullname,
      'displayname': instance.displayname,
      'idnumber': instance.idnumber,
      'visible': instance.visible,
      'summary': instance.summary,
      'summaryformat': instance.summaryformat,
      'format': instance.format,
      'showgrades': instance.showgrades,
      'lang': instance.lang,
      'enablecompletion': instance.enablecompletion,
      'completionhascriteria': instance.completionhascriteria,
      'completionusertracked': instance.completionusertracked,
      'category': instance.category,
      'progress': instance.progress,
      'completed': instance.completed,
      'startdate': instance.startdate,
      'enddate': instance.enddate,
      'marker': instance.marker,
      'lastaccess': instance.lastaccess,
      'isfavourite': instance.isfavourite,
      'hidden': instance.hidden,
      'overviewfiles': instance.overviewfiles,
      'showactivitydates': instance.showactivitydates,
      'showcompletionconditions': instance.showcompletionconditions,
      'timemodified': instance.timemodified,
      'colorHex': instance.colorHex,
    };
