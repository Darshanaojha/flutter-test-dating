class UserUploadImagesResponse {
  final bool success;
  final UserUploadImagesPayload? payload; 
  final ApiError error;

  UserUploadImagesResponse({
    required this.success,
    this.payload, 
    required this.error,
  });


  factory UserUploadImagesResponse.fromJson(Map<String, dynamic> json) {
    return UserUploadImagesResponse(
      success: json['success'],
      payload: json['payload'] != null
          ? UserUploadImagesPayload.fromJson(json['payload'])
          : null, 
      error: ApiError.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload':
          payload?.toJson(), 
      'error': error.toJson(),
    };
  }
}

class UserUploadImagesPayload {
  final String message;
  final UserImageData? data; 

  UserUploadImagesPayload({
    required this.message,
    this.data, 
  });

  factory UserUploadImagesPayload.fromJson(Map<String, dynamic> json) {
    return UserUploadImagesPayload(
      message: json['message'],
      data: json['data'] != null
          ? UserImageData.fromJson(json['data'])
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(), 
    };
  }
}

class UserImageData {
  final String id;
  final String userId;
  final String img1;
  final String img2;
  final String img3;
  final String img4;
  final String img5;
  final String img6;
  final String status;
  final String created;
  final String updated;

  UserImageData({
    required this.id,
    required this.userId,
    required this.img1,
    required this.img2,
    required this.img3,
    required this.img4,
    required this.img5,
    required this.img6,
    required this.status,
    required this.created,
    required this.updated,
  });


  factory UserImageData.fromJson(Map<String, dynamic> json) {
    return UserImageData(
      id: json['id'],
      userId: json['user_id'],
      img1: json['img1'] ?? '', 
      img2: json['img2'] ?? '',
      img3: json['img3'] ?? '', 
      img4: json['img4'] ?? '', 
      img5: json['img5'] ?? '',
      img6: json['img6'] ?? '',
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'img1': img1,
      'img2': img2,
      'img3': img3,
      'img4': img4,
      'img5': img5,
      'img6': img6,
      'status': status,
      'created': created,
      'updated': updated,
    };
  }

  List<String> get images {
    List<String> imageList = [img1, img2, img3, img4, img5, img6];
    imageList = imageList.where((image) => image.isNotEmpty).toList();
    while (imageList.length < 3) {
      imageList
          .add(''); 
    }
    return imageList.take(6).toList();
  }
}

class ApiError {
  final int code;
  final String message;

  ApiError({
    required this.code,
    required this.message,
  });


  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message:
          json['message'] ?? '', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
