import 'package:json_annotation/json_annotation.dart';
import "moodleSiteFunction.dart";
part 'moodleSiteInfo.g.dart';

@JsonSerializable()
class MoodleSiteInfo {
  MoodleSiteInfo();

  late String sitename;
  late String username;
  late String firstname;
  late String lastname;
  late String fullname;
  late String lang;
  late num userid;
  late String siteurl;
  late String userpictureurl;
  late List<MoodleSiteFunction> functions;
  late num downloadfiles;
  late num uploadfiles;
  late String release;
  late String version;
  late String mobilecssurl;
  late List advancedfeatures;
  late bool usercanmanageownfiles;
  late num userquota;
  late num usermaxuploadfilesize;
  late num userhomepage;
  late String userprivateaccesskey;
  late num siteid;
  late String sitecalendartype;
  late String usercalendartype;
  late bool userissiteadmin;
  late String theme;
  late num limitconcurrentlogins;
  
  factory MoodleSiteInfo.fromJson(Map<String,dynamic> json) => _$MoodleSiteInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MoodleSiteInfoToJson(this);
}
