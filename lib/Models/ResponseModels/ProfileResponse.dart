class ProfileResponse {
  final bool success;
  final Payload payload;
  final Error error;

  ProfileResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] as bool,
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
  final List<dynamic> desires;
  final List<dynamic> preferences;

  Payload({
    required this.data,
    required this.desires,
    required this.preferences,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      data: (json['data'] as List)
          .map((item) => UserData.fromJson(item))
          .toList(),
      desires: json['desires'] ?? [],
      preferences: json['preferences'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((user) => user.toJson()).toList(),
      'desires': desires,
      'preferences': preferences,
    };
  }
}

class UserData {
   String id;
   String name;
   String email;
   String mobile;
   String city;
   String state;
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
   String status;
   String created;
   String updated;
   String genderName;
   String subGenderName;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.city,
    required this.state,
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
    required this.status,
    required this.created,
    required this.updated,
    required this.genderName,
    required this.subGenderName,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      city: json['city'] as String,
      state: json['state'] as String? ?? "",
      address: json['address'] as String,
      gender: json['gender'] as String,
      subGender: json['sub_gender'] as String,
      countryId: json['country_id'] as String,
      password: json['password'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      otp: json['otp'] as String,
      type: json['type'] as String,
      dob: json['dob'] as String,
      nickname: json['nickname'] as String,
      interest: json['interest'] as String,
      bio: json['bio'] as String,
      emailAlerts: json['email_alerts'] as String,
      lookingFor: json['looking_for'] as String,
      username: json['username'] as String,
      status: json['status'] as String,
      created: json['created'] as String,
      updated: json['updated'] as String,
      genderName: json['gender_name'] as String,
      subGenderName: json['sub_gender_nm'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'city': city,
      'state': state,
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
      'status': status,
      'created': created,
      'updated': updated,
      'gender_name': genderName,
      'sub_gender_nm': subGenderName,
    };
  }
}

class Error {
  final int code;
  final String message;

  Error({
    required this.code,
    required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] as int,
      message: json['message'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
