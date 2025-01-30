class UserProfileResponse {
  final bool success;
  final Payload payload;
  final Error error;

  UserProfileResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  final List<UserData> data;
  final List<UserDesire> desires;
  final List<UserPreferences> preferences;
  final List<UserLang> lang;

  Payload({
    required this.data,
    required this.desires,
    required this.preferences,
    required this.lang,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      data: (json['data'] as List)
          .map((item) => UserData.fromJson(item))
          .toList(),
      desires: (json['desires'] as List)
          .map((item) => UserDesire.fromJson(item))
          .toList(),
      preferences: (json['preferences'] as List)
          .map((item) => UserPreferences.fromJson(item))
          .toList(),
      lang: (json['lang'] as List)
          .map((item) => UserLang.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'desires': desires.map((item) => item.toJson()).toList(),
      'preferences': preferences.map((item) => item.toJson()).toList(),
      'lang': lang.map((item) => item.toJson()).toList(),
    };
  }
}
       
class UserData {
  String id;
  String name;
  String email;
  String mobile;
  String city;
  String address;
  String gender;
  String subGender;
  String countryId;
  String password;
  String latitude;
  String longitude;
  String otp;
  String type;
  String dob;
  String nickname;
  String interest;
  String bio;
  String emailAlerts;
  String lookingFor;
  String username;
  String profileImage;
  String userActiveStatus;
  String statusSetting;
  String accountVerificationStatus;
  String accountHighlightStatus;
  String status;
  String created;
  String updated;
  String genderName;
  String subGenderName;
  
  // New fields
  String lastSeen;         // The user's last seen time
  String packageStatus;    // Package status (1 for active, etc.)
  String minimumAge;       // Minimum age for the user
  String maximumAge;       // Maximum age for the user
  String rangeKm;          // Range in kilometers

  // Constructor
  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.city,
    required this.address,
    required this.gender,
    required this.subGender,
    required this.countryId,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.otp,
    required this.type,
    required this.dob,
    required this.nickname,
    required this.interest,
    required this.bio,
    required this.emailAlerts,
    required this.lookingFor,
    required this.username,
    required this.profileImage,
    required this.userActiveStatus,
    required this.statusSetting,
    required this.accountVerificationStatus,
    required this.accountHighlightStatus,
    required this.status,
    required this.created,
    required this.updated,
    required this.genderName,
    required this.subGenderName,
    // New fields in the constructor
    required this.lastSeen,
    required this.packageStatus,
    required this.minimumAge,
    required this.maximumAge,
    required this.rangeKm,
  });

  // Factory method for creating an instance from JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      subGender: json['sub_gender'] ?? '',
      countryId: json['country_id'] ?? '',
      password: json['password'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      otp: json['otp'] ?? '0',
      type: json['type'] ?? '3',
      dob: json['dob'] ?? '',
      nickname: json['nickname'] ?? '',
      interest: json['interest'] ?? '',
      bio: json['bio'] ?? '',
      emailAlerts: json['email_alerts'] ?? '1',
      lookingFor: json['looking_for'] ?? '1',
      username: json['username'] ?? '',
      profileImage: json['profile_image'] ?? '',
      userActiveStatus: json['user_active_status'] ?? '1',
      statusSetting: json['status_setting'] ?? '1',
      accountVerificationStatus: json['account_verification_status'] ?? '1',
      accountHighlightStatus: json['account_highlight_status'] ?? '0',
      status: json['status'] ?? '1',
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
      genderName: json['gender_name'] ?? 'male',
      subGenderName: json['sub_gender_nm'] ?? 'other',
      // New fields with their default values if not provided
      lastSeen: json['last_seen'] ?? '',
      packageStatus: json['package_status'] ?? '1',
      minimumAge: json['minimumAge'] ?? '18',
      maximumAge: json['maximumAge'] ?? '100',
      rangeKm: json['rangeKm'] ?? '500',
    );
  }

  // Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'sub_gender_nm': subGenderName,
      'last_seen': lastSeen,
      'package_status': packageStatus,
      'minimumAge': minimumAge,
      'maximumAge': maximumAge,
      'rangeKm': rangeKm,
    };
  }
}


class UserDesire {
  String desiresId;
  String title;

  UserDesire({
    required this.desiresId,
    required this.title,
  });

  factory UserDesire.fromJson(Map<String, dynamic> json) {
    return UserDesire(
      desiresId: json['desires_id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desires_id': desiresId,
      'title': title,
    };
  }
}

class UserPreferences {
  String preferenceId;
  String title;

  UserPreferences({
    required this.preferenceId,
    required this.title,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferenceId: json['preference_id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preference_id': preferenceId,
      'title': title,
    };
  }
}

class UserLang {
   String langId;
   String title;

  UserLang({
    required this.langId,
    required this.title,
  });

  factory UserLang.fromJson(Map<String, dynamic> json) {
    return UserLang(
      langId: json['lang_id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lang_id': langId,
      'title': title,
    };
  }
}

class Error {
   int code;
   String message;

  Error({
    required this.code,
    required this.message,
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
