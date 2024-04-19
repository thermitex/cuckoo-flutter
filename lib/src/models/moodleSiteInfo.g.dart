// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moodleSiteInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodleSiteInfo _$MoodleSiteInfoFromJson(Map<String, dynamic> json) =>
    MoodleSiteInfo()
      ..sitename = json['sitename'] as String
      ..username = json['username'] as String
      ..firstname = json['firstname'] as String
      ..lastname = json['lastname'] as String
      ..fullname = json['fullname'] as String
      ..lang = json['lang'] as String
      ..userid = json['userid'] as num
      ..siteurl = json['siteurl'] as String
      ..userpictureurl = json['userpictureurl'] as String
      ..functions = (json['functions'] as List<dynamic>)
          .map((e) => MoodleSiteFunction.fromJson(e as Map<String, dynamic>))
          .toList()
      ..downloadfiles = json['downloadfiles'] as num
      ..uploadfiles = json['uploadfiles'] as num
      ..release = json['release'] as String
      ..version = json['version'] as String
      ..mobilecssurl = json['mobilecssurl'] as String
      ..advancedfeatures = json['advancedfeatures'] as List<dynamic>
      ..usercanmanageownfiles = json['usercanmanageownfiles'] as bool
      ..userquota = json['userquota'] as num
      ..usermaxuploadfilesize = json['usermaxuploadfilesize'] as num
      ..userhomepage = json['userhomepage'] as num
      ..userprivateaccesskey = json['userprivateaccesskey'] as String
      ..siteid = json['siteid'] as num
      ..sitecalendartype = json['sitecalendartype'] as String
      ..usercalendartype = json['usercalendartype'] as String
      ..userissiteadmin = json['userissiteadmin'] as bool
      ..theme = json['theme'] as String
      ..limitconcurrentlogins = json['limitconcurrentlogins'] as num;

Map<String, dynamic> _$MoodleSiteInfoToJson(MoodleSiteInfo instance) =>
    <String, dynamic>{
      'sitename': instance.sitename,
      'username': instance.username,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'fullname': instance.fullname,
      'lang': instance.lang,
      'userid': instance.userid,
      'siteurl': instance.siteurl,
      'userpictureurl': instance.userpictureurl,
      'functions': instance.functions,
      'downloadfiles': instance.downloadfiles,
      'uploadfiles': instance.uploadfiles,
      'release': instance.release,
      'version': instance.version,
      'mobilecssurl': instance.mobilecssurl,
      'advancedfeatures': instance.advancedfeatures,
      'usercanmanageownfiles': instance.usercanmanageownfiles,
      'userquota': instance.userquota,
      'usermaxuploadfilesize': instance.usermaxuploadfilesize,
      'userhomepage': instance.userhomepage,
      'userprivateaccesskey': instance.userprivateaccesskey,
      'siteid': instance.siteid,
      'sitecalendartype': instance.sitecalendartype,
      'usercalendartype': instance.usercalendartype,
      'userissiteadmin': instance.userissiteadmin,
      'theme': instance.theme,
      'limitconcurrentlogins': instance.limitconcurrentlogins,
    };
