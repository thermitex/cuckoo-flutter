import 'package:json_annotation/json_annotation.dart';

part 'moodleCourseGrade.g.dart';

@JsonSerializable()
class MoodleCourseGrade {
  MoodleCourseGrade();

  late String itemname;
  String? weight;
  late String grade;
  late String range;
  String? feedback;
  String? percentage;
  String? contributiontocoursetotal;

  factory MoodleCourseGrade.fromJson(Map<String, dynamic> json) =>
      _$MoodleCourseGradeFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleCourseGradeToJson(this);
}
