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
    List<LikeRequestPages> dataList = list.map((i) => LikeRequestPages.fromJson(i)).toList();

    return Payload(
      message: json['message'],
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
  String name;
  String nickname;
  String email;
  String profileImage;
  List<String> images;

  LikeRequestPages({
    required this.id,
    required this.userId,
    required this.conectionId,
    required this.type,
    required this.status,
    required this.created,
    required this.updated,
    required this.name,
    required this.nickname,
    required this.email,
    required this.profileImage,
    required this.images,
  });

  factory LikeRequestPages.fromJson(Map<String, dynamic> json) {
    var list = json['images'] as List;
    List<String> imagesList = List<String>.from(list);

    return LikeRequestPages(
      id: json['id'],
      userId: json['user_id'],
      conectionId: json['conection_id'],
      type: json['type'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      name: json['name'],
      nickname: json['nickname'],
      email: json['email'],
      profileImage: json['profile_image'],
      images: imagesList,
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
      'images': images,
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
