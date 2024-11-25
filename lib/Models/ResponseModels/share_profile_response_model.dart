
class ShareProfileResponseModel {
  final bool success;
  final Payload? payload;
  final Error error;

  ShareProfileResponseModel({
    required this.success,
    this.payload,
    required this.error,
  });

  factory ShareProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ShareProfileResponseModel(
      success: json['success'] as bool,
      payload: json['payload'] != null
          ? Payload.fromJson(json['payload'] as Map<String, dynamic>)
          : null,
      error: Error.fromJson(json['error'] as Map<String, dynamic>),
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
  final List<SharedUser> data;
  final List<Desire> desires;
  final List<Preference> preferences;
  final List<Language> lang;
  final ImageData img;

  Payload({
    required this.data,
    required this.desires,
    required this.preferences,
    required this.lang,
    required this.img,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      data: (json['data'] as List<dynamic>)
          .map((item) => SharedUser.fromJson(item as Map<String, dynamic>))
          .toList(),
      desires: (json['desires'] as List<dynamic>)
          .map((item) => Desire.fromJson(item as Map<String, dynamic>))
          .toList(),
      preferences: (json['preferences'] as List<dynamic>)
          .map((item) => Preference.fromJson(item as Map<String, dynamic>))
          .toList(),
      lang: (json['lang'] as List<dynamic>)
          .map((item) => Language.fromJson(item as Map<String, dynamic>))
          .toList(),
      img: ImageData.fromJson(json['img'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'desires': desires.map((item) => item.toJson()).toList(),
      'preferences': preferences.map((item) => item.toJson()).toList(),
      'lang': lang.map((item) => item.toJson()).toList(),
      'img': img.toJson(),
    };
  }
}

class SharedUser {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String city;
  final String address;
  final String gender;
  final String subGender;
  final String countryId;
  final String latitude;
  final String longitude;
  final String dob;
  final String nickname;
  final String interest;
  final String bio;
  final String username;
  final String profileImage;
  final String genderName;
  final String subGenderName;

  SharedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.city,
    required this.address,
    required this.gender,
    required this.subGender,
    required this.countryId,
    required this.latitude,
    required this.longitude,
    required this.dob,
    required this.nickname,
    required this.interest,
    required this.bio,
    required this.username,
    required this.profileImage,
    required this.genderName,
    required this.subGenderName,
  });

  factory SharedUser.fromJson(Map<String, dynamic> json) {
    return SharedUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      gender: json['gender'] as String,
      subGender: json['sub_gender'] as String,
      countryId: json['country_id'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      dob: json['dob'] as String,
      nickname: json['nickname'] as String,
      interest: json['interest'] as String,
      bio: json['bio'] as String,
      username: json['username'] as String,
      profileImage: json['profile_image'] as String,
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
      'address': address,
      'gender': gender,
      'sub_gender': subGender,
      'country_id': countryId,
      'latitude': latitude,
      'longitude': longitude,
      'dob': dob,
      'nickname': nickname,
      'interest': interest,
      'bio': bio,
      'username': username,
      'profile_image': profileImage,
      'gender_name': genderName,
      'sub_gender_nm': subGenderName,
    };
  }
}

class Desire {
  final String id;
  final String title;

  Desire({required this.id, required this.title});

  factory Desire.fromJson(Map<String, dynamic> json) {
    return Desire(
      id: json['desires_id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desires_id': id,
      'title': title,
    };
  }
}

class Preference {
  final String id;
  final String title;

  Preference({required this.id, required this.title});

  factory Preference.fromJson(Map<String, dynamic> json) {
    return Preference(
      id: json['preference_id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preference_id': id,
      'title': title,
    };
  }
}

class Language {
  final String id;
  final String userId;
  final String title;

  Language({required this.id, required this.userId, required this.title});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['lang_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lang_id': id,
      'user_id': userId,
      'title': title,
    };
  }
}

class ImageData {
  final String id;
  final String userId;
  final String img1;
  final String img2;
  final String img3;

  ImageData({
    required this.id,
    required this.userId,
    required this.img1,
    required this.img2,
    required this.img3,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      img1: json['img1'] as String,
      img2: json['img2'] as String,
      img3: json['img3'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'img1': img1,
      'img2': img2,
      'img3': img3,
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
