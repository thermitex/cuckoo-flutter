// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moodleCourseGrade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodleCourseGrade _$MoodleCourseGradeFromJson(Map<String, dynamic> json) =>
    MoodleCourseGrade()
      ..itemname = json['itemname'] as String
      ..weight = json['weight'] as String?
      ..grade = json['grade'] as String
      ..range = json['range'] as String
      ..feedback = json['feedback'] as String?
      ..percentage = json['percentage'] as String?
      ..contributiontocoursetotal =
          json['contributiontocoursetotal'] as String?;

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
