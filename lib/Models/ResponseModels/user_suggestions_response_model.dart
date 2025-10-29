class UserSuggestionsResponseModel {
  final bool success;
  final Payload? payload;
  final Error? error;

  UserSuggestionsResponseModel({
    required this.success,
    this.payload,
    this.error,
  });

  factory UserSuggestionsResponseModel.fromJson(Map<String, dynamic> json) {
    return UserSuggestionsResponseModel(
      success: json['success'],
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(),
      'error': error?.toJson(),
    };
  }
}

class Payload {
  final List<SuggestedUser> locationBase;
  final List<SuggestedUser> preferenceBase;
  final List<SuggestedUser> desireBase;
  final List<SuggestedUser> languageBase;
  final List<SuggestedUser> highlightedAccount;
  final List<SuggestedUser> hookup;

  Payload({
    required this.locationBase,
    required this.preferenceBase,
    required this.desireBase,
    required this.languageBase,
    required this.highlightedAccount,
    required this.hookup,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      locationBase: _parseSuggestedUsers(json['location_base']),
      preferenceBase: _parseSuggestedUsers(json['preference_base']),
      desireBase: _parseSuggestedUsers(json['desire_base']),
      languageBase: _parseSuggestedUsers(json['language_base']),
      highlightedAccount: _parseSuggestedUsers(json['highlighted_account']),
      hookup: _parseSuggestedUsers(json['hook_up']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_base': locationBase.isNotEmpty
          ? locationBase.map((e) => e.toJson()).toList()
          : [],
      'preference_base': preferenceBase.isNotEmpty
          ? preferenceBase.map((e) => e.toJson()).toList()
          : [],
      'desire_base': desireBase.isNotEmpty
          ? desireBase.map((e) => e.toJson()).toList()
          : [],
      'language_base': languageBase.isNotEmpty
          ? languageBase.map((e) => e.toJson()).toList()
          : [],
      'highlighted_account': highlightedAccount.isNotEmpty
          ? highlightedAccount.map((e) => e.toJson()).toList()
          : [],
      'hook_up':
          hookup.isNotEmpty ? hookup.map((e) => e.toJson()).toList() : [],
    };
  }

  // Helper function to handle null/empty lists for SuggestedUser
  static List<SuggestedUser> _parseSuggestedUsers(dynamic jsonList) {
    if (jsonList == null) return [];
    return List<SuggestedUser>.from(
        (jsonList as List).map((item) => SuggestedUser.fromJson(item)));
  }
}

class SuggestedUser {
  final String? id;
  final String? userId;
  final String? name;
  final String? email;
  final String? mobile;
  final String? city;
  final String? address;
  final String? gender;
  final String? subGender;
  final String? countryId;
  final String? password;
  final String? latitude;
  final String? longitude;
  final String? otp;
  final String? type;
  final String? dob;
  final String? nickname;
  final String? interest;
  final String? bio;
  final String? emailAlerts;
  final String? lookingFor;
  final String? username;
  final String? profileImage;
  final String? userActiveStatus;
  final String? statusSetting;
  final String? accountVerificationStatus;
  final String? accountHighlightStatus;
  final String? status;
  final String? created;
  final String? updated;
  final String? genderName;
  final String? subGenderName;
  final String? countryName;
  final List<String> images;
  final String? preferenceId;
  final String? desiresId;
  final String? langId;
  final String? countryCode;
  final String? points;
  final String? firstTranDone;
  final String? lastSeen;
  final String? packageStatus;
  final String? minimumAge;
  final String? maximumAge;
  final String? rangeKm;
  final String? version;
  final String? banned;
  final String? hookupStatus;
  final String? incognativeMode;
  final String? moodId;
  final String? creator;
  final double? distance;

  SuggestedUser({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.mobile,
    this.city,
    this.address,
    this.gender,
    this.subGender,
    this.countryId,
    this.password,
    this.latitude,
    this.longitude,
    this.otp,
    this.type,
    this.dob,
    this.nickname,
    this.interest,
    this.bio,
    this.emailAlerts,
    this.lookingFor,
    this.username,
    this.profileImage,
    this.userActiveStatus,
    this.statusSetting,
    this.accountVerificationStatus,
    this.accountHighlightStatus,
    this.status,
    this.created,
    this.updated,
    this.genderName,
    this.subGenderName,
    this.countryName,
    this.images = const [],
    this.preferenceId,
    this.desiresId,
    this.langId,
    this.countryCode,
    this.points,
    this.firstTranDone,
    this.lastSeen,
    this.packageStatus,
    this.minimumAge,
    this.maximumAge,
    this.rangeKm,
    this.version,
    this.banned,
    this.hookupStatus,
    this.incognativeMode,
    this.moodId,
    this.creator,
    this.distance,
  });

  factory SuggestedUser.fromJson(Map<String, dynamic> json) {
    String? _parseString(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is String) {
        return value;
      }
      return value.toString();
    }

    return SuggestedUser(
      id: _parseString(json['id']),
      userId: _parseString(json['user_id']),
      name: _parseString(json['name']),
      email: _parseString(json['email']),
      mobile: _parseString(json['mobile']),
      city: _parseString(json['city']),
      address: _parseString(json['address']),
      gender: _parseString(json['gender']),
      subGender: _parseString(json['sub_gender']),
      countryId: _parseString(json['country_id']),
      password: _parseString(json['password']),
      latitude: _parseString(json['latitude']),
      longitude: _parseString(json['longitude']),
      otp: _parseString(json['otp']),
      type: _parseString(json['type']),
      dob: _parseString(json['dob']),
      nickname: _parseString(json['nickname']),
      interest: _parseString(json['interest']),
      bio: _parseString(json['bio']),
      emailAlerts: _parseString(json['email_alerts']),
      lookingFor: _parseString(json['looking_for']),
      username: _parseString(json['username']),
      profileImage: _parseString(json['profile_image']),
      userActiveStatus: _parseString(json['user_active_status']),
      statusSetting: _parseString(json['status_setting']),
      accountVerificationStatus: _parseString(json['account_verification_status']),
      accountHighlightStatus: _parseString(json['account_highlight_status']),
      status: _parseString(json['status']),
      created: _parseString(json['created']),
      updated: _parseString(json['updated']),
      genderName: _parseString(json['gender_name']),
      subGenderName: _parseString(json['sub_gender_name'] ?? json['sub_gender_nm']),
      countryName: _parseString(json['country_name']),
      images: [
        _parseString(json['img1']) ?? '',
        _parseString(json['img2']) ?? '',
        _parseString(json['img3']) ?? '',
        _parseString(json['img4']) ?? '',
        _parseString(json['img5']) ?? '',
        _parseString(json['img6']) ?? '',
      ].where((img) => img.isNotEmpty).toList(),
      preferenceId:
          json.containsKey('preference_id') ? _parseString(json['preference_id']) : null,
      desiresId: json.containsKey('desires_id') ? _parseString(json['desires_id']) : null,
      langId: json.containsKey('lang_id') ? _parseString(json['lang_id']) : null,
      countryCode: _parseString(json['country_code']),
      points: _parseString(json['points']),
      firstTranDone: _parseString(json['first_tran_done']),
      lastSeen: _parseString(json['last_seen']),
      packageStatus: _parseString(json['package_status']),
      minimumAge: _parseString(json['minimumAge']),
      maximumAge: _parseString(json['maximumAge']),
      rangeKm: _parseString(json['rangeKm']),
      version: _parseString(json['version']),
      banned: _parseString(json['banned']),
      hookupStatus: _parseString(json['hookup_status']),
      incognativeMode: _parseString(json['incognative_mode']),
      moodId: _parseString(json['mood_id']),
      creator: _parseString(json['creator']),
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'city': city,
      'address': address,
      'gender': gender,
      'sub_gender': subGender,
      'country_id': countryId,
      'password': password,
      'latitude': latitude,
      'longitude': longitude,
      'otp': otp,
      'type': type,
      'dob': dob,
      'nickname': nickname,
      'interest': interest,
      'bio': bio,
      'email_alerts': emailAlerts,
      'looking_for': lookingFor,
      'username': username,
      'profile_image': profileImage,
      'user_active_status': userActiveStatus,
      'status_setting': statusSetting,
      'account_verification_status': accountVerificationStatus,
      'account_highlight_status': accountHighlightStatus,
      'status': status,
      'created': created,
      'updated': updated,
      'gender_name': genderName,
      'sub_gender_name': subGenderName,
      'country_name': countryName,
      'images': images,
      'preference_id': preferenceId,
      'lang_id': langId,
      'country_code': countryCode,
      'points': points,
      'first_tran_done': firstTranDone,
      'last_seen': lastSeen,
      'package_status': packageStatus,
      'minimumAge': minimumAge,
      'maximumAge': maximumAge,
      'rangeKm': rangeKm,
      'version': version,
      'banned': banned,
      'hookup_status': hookupStatus,
      'incognative_mode': incognativeMode,
      'mood_id': moodId,
      'creator': creator,
      'distance': distance,
    };
  }
}

class Error {
  final int code;
  final String? message;

  Error({
    required this.code,
    this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
