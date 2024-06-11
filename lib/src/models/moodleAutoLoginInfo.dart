import 'package:json_annotation/json_annotation.dart';

part 'moodleAutoLoginInfo.g.dart';

@JsonSerializable()
class MoodleAutoLoginInfo {
  MoodleAutoLoginInfo();

  late String key;
  late num lastRequested;

  factory MoodleAutoLoginInfo.fromJson(Map<String, dynamic> json) =>
      _$MoodleAutoLoginInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleAutoLoginInfoToJson(this);
}
