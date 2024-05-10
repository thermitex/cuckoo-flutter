import 'package:json_annotation/json_annotation.dart';

part 'moodleSiteFunction.g.dart';

@JsonSerializable()
class MoodleSiteFunction {
  MoodleSiteFunction();

  late String name;
  late String version;
  
  factory MoodleSiteFunction.fromJson(Map<String,dynamic> json) => _$MoodleSiteFunctionFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleSiteFunctionToJson(this);
}
