class GetAllLikesResponse {
  final bool success;
  final Payload payload;
  final Error error;

  GetAllLikesResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory method to create an instance from JSON
  factory GetAllLikesResponse.fromJson(Map<String, dynamic> json) {
    return GetAllLikesResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  final String message;
  final List<LikeRequestPages> data;

  Payload({
    required this.message,
    required this.data,
  });

  // Factory method to create an instance from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => LikeRequestPages.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((likeRequestPage) => likeRequestPage.toJson()).toList(),
    };
  }
}

class LikeRequestPages {
  final String id;
  final String userId;
  final String conectionId;
  final String type;
  final String status;
  final String created;
  final String updated;
  final String name;
  final int likeedByMe;
  final String nickname;
  final String email;
  final String dob;
  final String gender;
  final String countryName;
  final String profileImage;
  final List<String> images;
  final List<Desire> desires;
  final List<Preference> preferences;

  LikeRequestPages({
    required this.id,
    required this.userId,
    required this.conectionId,
    required this.type,
    required this.status,
    required this.created,
    required this.updated,
    required this.name,
    required this.likeedByMe,
    required this.nickname,
    required this.email,
    required this.dob,
    required this.gender,
    required this.countryName,
    required this.profileImage,
    required this.images,
    required this.desires,
    required this.preferences,
  });

  // Factory method to create an instance from JSON
  factory LikeRequestPages.fromJson(Map<String, dynamic> json) {
    return LikeRequestPages(
      id: json['id'],
      userId: json['user_id'],
      conectionId: json['conection_id'],
      type: json['type'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      name: json['name'],
      likeedByMe: json['likeed_by_me'],
      nickname: json['nickname'],
      email: json['email'],
      dob: json['DOB'],
      gender: json['gender'],
      countryName: json['countryname'],
      profileImage: json['profile_image'],
      images: List<String>.from(json['images'] ?? []), // Handle null values
      desires: (json['desires'] as List)
          .map((item) => Desire.fromJson(item))
          .toList(),
      preferences: (json['preferences'] as List)
          .map((item) => Preference.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'conection_id': conectionId,
      'type': type,
      'status': status,
      'created': created,
      'updated': updated,
      'name': name,
      'likeed_by_me': likeedByMe,
      'nickname': nickname,
      'email': email,
      'DOB': dob,
      'gender': gender,
      'countryname': countryName,
      'profile_image': profileImage,
      'images': images,
      'desires': desires.map((desire) => desire.toJson()).toList(),
      'preferences': preferences.map((preference) => preference.toJson()).toList(),
    };
  }
}

class Desire {
  final String desiresId;
  final String title;

  Desire({
    required this.desiresId,
    required this.title,
  });

  factory Desire.fromJson(Map<String, dynamic> json) {
    return Desire(
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

class Preference {
  final String preferenceId;
  final String title;

  Preference({
    required this.preferenceId,
    required this.title,
  });

  factory Preference.fromJson(Map<String, dynamic> json) {
    return Preference(
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

class Error {
  final int code;
  final String message;

  Error({
    required this.code,
    required this.message,
  });

  // Factory method to create an instance from JSON
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
