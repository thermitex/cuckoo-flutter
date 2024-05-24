// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moodleCourseModule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodleCourseModule _$MoodleCourseModuleFromJson(Map<String, dynamic> json) =>
    MoodleCourseModule()
      ..id = json['id'] as num
      ..url = json['url'] as String?
      ..name = json['name'] as String
      ..instance = json['instance'] as num?
      ..contextid = json['contextid'] as num?
      ..description = json['description'] as String?
      ..visible = json['visible'] as num
      ..uservisible = json['uservisible'] as bool
      ..visibleoncoursepage = json['visibleoncoursepage'] as num?
      ..modicon = json['modicon'] as String?
      ..modname = json['modname'] as String?
      ..modplural = json['modplural'] as String?
      ..indent = json['indent'] as num?
      ..customdata = json['customdata'] as String?
      ..downloadcontent = json['downloadcontent'] as num?
      ..dates = json['dates'] as List<dynamic>?
      ..contents = json['contents'] as List<dynamic>?
      ..contentsinfo = json['contentsinfo'] as Map<String, dynamic>?;

Map<String, dynamic> _$MoodleCourseModuleToJson(MoodleCourseModule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'instance': instance.instance,
      'contextid': instance.contextid,
      'description': instance.description,
      'visible': instance.visible,
      'uservisible': instance.uservisible,
      'visibleoncoursepage': instance.visibleoncoursepage,
      'modicon': instance.modicon,
      'modname': instance.modname,
      'modplural': instance.modplural,
      'indent': instance.indent,
      'customdata': instance.customdata,
      'downloadcontent': instance.downloadcontent,
      'dates': instance.dates,
      'contents': instance.contents,
      'contentsinfo': instance.contentsinfo,
    };
