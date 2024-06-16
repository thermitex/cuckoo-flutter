// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moodleCourseGrade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodleCourseGrade _$MoodleCourseGradeFromJson(Map<String, dynamic> json) =>
    MoodleCourseGrade()
      ..itemname = json['itemname']['content'] as String
      ..weight = (json['weight'] ?? const {})['content'] as String?
      ..grade = json['grade']['content'] as String
      ..range = json['range']['content'] as String
      ..feedback = (json['feedback'] ?? const {})['content'] as String?
      ..percentage = (json['percentage'] ?? const {})['content'] as String?
      ..contributiontocoursetotal =
          (json['contributiontocoursetotal'] ?? const {})['content'] as String?;

Map<String, dynamic> _$MoodleCourseGradeToJson(MoodleCourseGrade instance) =>
    <String, dynamic>{
      'itemname': instance.itemname,
      'weight': instance.weight,
      'grade': instance.grade,
      'range': instance.range,
      'feedback': instance.feedback,
      'percentage': instance.percentage,
      'contributiontocoursetotal': instance.contributiontocoursetotal,
    };
