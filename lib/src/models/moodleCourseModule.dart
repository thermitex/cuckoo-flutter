import 'package:json_annotation/json_annotation.dart';

part 'moodleCourseModule.g.dart';

@JsonSerializable()
class MoodleCourseModule {
  MoodleCourseModule();

  late num id;
  String? url;
  late String name;
  num? instance;
  num? contextid;
  String? description;
  late num visible;
  late bool uservisible;
  num? visibleoncoursepage;
  String? modicon;
  String? modname;
  String? modplural;
  num? indent;
  String? customdata;
  num? downloadcontent;
  List? dates;
  List? contents;
  Map<String, dynamic>? contentsinfo;

  factory MoodleCourseModule.fromJson(Map<String, dynamic> json) =>
      _$MoodleCourseModuleFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleCourseModuleToJson(this);
}
