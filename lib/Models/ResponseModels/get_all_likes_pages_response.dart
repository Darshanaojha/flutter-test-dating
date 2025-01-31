class GetAllLikesResponse {
  bool success;
  Payload payload;
  Error error;

  GetAllLikesResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory GetAllLikesResponse.fromJson(Map<String, dynamic> json) {
    return GetAllLikesResponse(
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
  String message;
  List<LikeRequestPages> data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<LikeRequestPages> dataList =
        list.map((i) => LikeRequestPages.fromJson(i)).toList();

    return Payload(
      message: json['message'] ?? "",
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((i) => i.toJson()).toList(),
    };
  }
}

class LikeRequestPages {
  String id;
  String userId;
  String conectionId;
  String type;
  String status;
  String created;
  String updated;
  String? name;
  String? nickname;
  String? email;
  String profileImage;
  String dob;
  int likedByMe;
  String gender;
  String countryName;
  List<String> images;
  List<String> desires;
  List<String> preferences;

  LikeRequestPages({
    required this.id,
    required this.userId,
    required this.conectionId,
    required this.type,
    required this.status,
    required this.created,
    required this.updated,
    this.name,
    this.nickname,
    this.email,
    required this.profileImage,
    required this.dob,
    required this.likedByMe,
    required this.gender,
    required this.countryName,
    required this.images,
    required this.desires,
    required this.preferences,
  });

  factory LikeRequestPages.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    for (var i = 1; i <= 6; i++) {
      String imgKey = 'img$i';
      if (json[imgKey] != null && json[imgKey].isNotEmpty) {
        imagesList.add(json[imgKey]);
      }
    }

    List<String> desiresList = [];
    if (json['desires'] != null) {
      for (var desire in json['desires']) {
        desiresList.add(desire['title']);
      }
    }

    List<String> preferencesList = [];
    if (json['preferences'] != null) {
      for (var preference in json['preferences']) {
        preferencesList.add(preference['title']);
      }
    }

    return LikeRequestPages(
      id: json['id'],
      userId: json['user_id'],
      conectionId: json['conection_id'],
      type: json['type'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image'] ?? '',
      dob: json['DOB'] ?? '',
      likedByMe: json['likeed_by_me'] ?? 0,
      gender: json['gender'] ?? '',
      countryName: json['countryname'] ?? '',
      images: imagesList,
      desires: desiresList,
      preferences: preferencesList,
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
      'nickname': nickname,
      'email': email,
      'profile_image': profileImage,
      'DOB': dob,
      'likeed_by_me': likedByMe,
      'gender': gender,
      'countryname': countryName,
      'images': images,
      'desires': desires.map((d) => {'title': d}).toList(),
      'preferences': preferences.map((p) => {'title': p}).toList(),
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
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
