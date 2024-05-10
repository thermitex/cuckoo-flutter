import 'package:json_annotation/json_annotation.dart';

part 'moodleCourse.g.dart';

@JsonSerializable()
class MoodleCourse {
  MoodleCourse();

  late num id;
  late String shortname;
  late String fullname;
  late String displayname;
  late String idnumber;
  late num visible;
  late String summary;
  late num summaryformat;
  late String format;
  late bool showgrades;
  late String lang;
  bool? enablecompletion;
  bool? completionhascriteria;
  bool? completionusertracked;
  num? category;
  num? progress;
  bool? completed;
  num? startdate;
  num? enddate;
  num? marker;
  num? lastaccess;
  late bool isfavourite;
  late bool hidden;
  List? overviewfiles;
  bool? showactivitydates;
  bool? showcompletionconditions;
  num? timemodified;
  String? colorHex;
  
  factory MoodleCourse.fromJson(Map<String,dynamic> json) => _$MoodleCourseFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleCourseToJson(this);
}
