class UserSuggestionsResponseModel {
  final bool success;
  final Payload? payload;
  final Error error;

  UserSuggestionsResponseModel(
      {required this.success, this.payload, required this.error});

  factory UserSuggestionsResponseModel.fromJson(Map<String, dynamic> json) {
    return UserSuggestionsResponseModel(
      success: json['success'] as bool,
      payload: json['payload'] != null && (json['payload'] as Map).isNotEmpty
          ? Payload.fromJson(json['payload'])
          : null,
      error: Error.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  final String message;
  final List<User>? locationBase;
  final List<User>? preferenceBase;
  final List<User>? desireBase;

  Payload(
      {required this.message,
      this.locationBase,
      this.preferenceBase,
      this.desireBase});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'] as String,
      locationBase: (json['location_base'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      preferenceBase: (json['preference_base'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      desireBase: (json['desire_base'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'location_base': locationBase?.map((e) => e.toJson()).toList(),
      'preference_base': preferenceBase?.map((e) => e.toJson()).toList(),
      'desire_base': desireBase?.map((e) => e.toJson()).toList(),
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String city;
  final String address;
  final String gender;
  final String subGender;
  final String countryId;
  final String password;
  final String latitude;
  final String longitude;
  final String otp;
  final String type;
  final String dob;
  final String nickname;
  final String interest;
  final String bio;
  final String emailAlerts;
  final String lookingFor;
  final String username;
  final String status;
  final String created;
  final String updated;
  final double? distance;

  User({
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
    required this.status,
    required this.created,
    required this.updated,
    this.distance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      city: json['city'] as String,
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
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }

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
      'status': status,
      'created': created,
      'updated': updated,
      'distance': distance,
    };
  }
}

class Error {
  final int code;
  final String message;

  Error({required this.code, required this.message});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
