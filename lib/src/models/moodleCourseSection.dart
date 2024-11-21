import 'package:json_annotation/json_annotation.dart';
import "moodleCourseModule.dart";
part 'moodleCourseSection.g.dart';

@JsonSerializable()
class MoodleCourseSection {
  MoodleCourseSection();

  late num id;
  late String name;
  num? visible;
  late String summary;
  num? summaryformat;
  num? section;
  num? hiddenbynumsections;
  bool? uservisible;
  late List<MoodleCourseModule> modules;
  
  factory MoodleCourseSection.fromJson(Map<String,dynamic> json) => _$MoodleCourseSectionFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleCourseSectionToJson(this);
}
