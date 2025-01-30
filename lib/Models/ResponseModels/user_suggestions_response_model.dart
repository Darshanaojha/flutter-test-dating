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

  Payload({
    required this.locationBase,
    required this.preferenceBase,
    required this.desireBase,
    required this.languageBase,
    required this.highlightedAccount,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      locationBase: _parseSuggestedUsers(json['location_base']),
      preferenceBase: _parseSuggestedUsers(json['preference_base']),
      desireBase: _parseSuggestedUsers(json['desire_base']),
      languageBase: _parseSuggestedUsers(json['language_base']),
      highlightedAccount: _parseSuggestedUsers(json['highlighted_account']),
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
  });

  factory SuggestedUser.fromJson(Map<String, dynamic> json) {
    return SuggestedUser(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      city: json['city'],
      address: json['address'],
      gender: json['gender'],
      subGender: json['sub_gender'],
      countryId: json['country_id'],
      password: json['password'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      otp: json['otp'],
      type: json['type'],
      dob: json['dob'],
      nickname: json['nickname'],
      interest: json['interest'],
      bio: json['bio'],
      emailAlerts: json['email_alerts'],
      lookingFor: json['looking_for'],
      username: json['username'],
      profileImage: json['profile_image'],
      userActiveStatus: json['user_active_status'],
      statusSetting: json['status_setting'],
      accountVerificationStatus: json['account_verification_status'],
      accountHighlightStatus: json['account_highlight_status'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      genderName: json['gender_name'],
      subGenderName: json['sub_gender_name'] ?? json['sub_gender_nm'],
      countryName: json['country_name'],
      images: [
        json['img1'] as String? ?? '',
        json['img2'] as String? ?? '',
        json['img3'] as String? ?? '',
        json['img4'] as String? ?? '',
        json['img5'] as String? ?? '',
        json['img6'] as String? ?? '',
      ].where((img) => img.isNotEmpty).toList(),
      preferenceId:
          json.containsKey('preference_id') ? json['preference_id'] : null,
      desiresId: json.containsKey('desires_id') ? json['desires_id'] : null,
      langId: json.containsKey('lang_id') ? json['lang_id'] : null,
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
      'lang_id': langId
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
