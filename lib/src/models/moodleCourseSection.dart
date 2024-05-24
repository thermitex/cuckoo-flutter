import 'package:json_annotation/json_annotation.dart';
import "moodleCourseModule.dart";
part 'moodleCourseSection.g.dart';

@JsonSerializable()
class MoodleCourseSection {
  MoodleCourseSection();

  late num id;
  late String name;
  late num visible;
  late String summary;
  late num summaryformat;
  late num section;
  late num hiddenbynumsections;
  bool? uservisible;
  late List<MoodleCourseModule> modules;

  factory MoodleCourseSection.fromJson(Map<String, dynamic> json) =>
      _$MoodleCourseSectionFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleCourseSectionToJson(this);
}
