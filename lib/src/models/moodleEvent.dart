import 'package:json_annotation/json_annotation.dart';

part 'moodleEvent.g.dart';

@JsonSerializable()
class MoodleEvent {
  MoodleEvent();

  late num id;
  late String name;
  late String description;
  num? format;
  num? courseid;
  String? categoryid;
  String? groupid;
  num? userid;
  String? repeatid;
  String? modulename;
  num? instance;
  late String eventtype;
  late num timestart;
  num? timeduration;
  num? visible;
  num? sequence;
  num? timemodified;
  String? subscriptionid;
  bool? completed;
  num? cmid;
  bool? hascompletion;
  num? state;
  String? url;
  
  factory MoodleEvent.fromJson(Map<String,dynamic> json) => _$MoodleEventFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleEventToJson(this);
}
