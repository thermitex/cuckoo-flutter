// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moodleCourseSection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodleCourseSection _$MoodleCourseSectionFromJson(Map<String, dynamic> json) =>
    MoodleCourseSection()
      ..id = json['id'] as num
      ..name = json['name'] as String
      ..visible = json['visible'] as num
      ..summary = json['summary'] as String
      ..summaryformat = json['summaryformat'] as num
      ..section = json['section'] as num
      ..hiddenbynumsections = json['hiddenbynumsections'] as num
      ..uservisible = json['uservisible'] as bool?
      ..modules = (json['modules'] as List<dynamic>)
          .map((e) => MoodleCourseModule.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$MoodleCourseSectionToJson(
        MoodleCourseSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'visible': instance.visible,
      'summary': instance.summary,
      'summaryformat': instance.summaryformat,
      'section': instance.section,
      'hiddenbynumsections': instance.hiddenbynumsections,
      'uservisible': instance.uservisible,
      'modules': instance.modules,
    };
