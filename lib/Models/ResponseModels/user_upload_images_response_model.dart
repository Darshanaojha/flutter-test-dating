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
    UserUploadImagesPayload? payloadData;
    if (json['payload'] != null && json['payload'] is Map<String, dynamic>) {
      try {
        payloadData = UserUploadImagesPayload.fromJson(json['payload'] as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing UserUploadImagesPayload: $e');
        payloadData = null;
      }
    }
    
    ApiError errorData;
    if (json['error'] != null && json['error'] is Map<String, dynamic>) {
      try {
        errorData = ApiError.fromJson(json['error'] as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing ApiError: $e');
        errorData = ApiError(code: -1, message: 'Error parsing response');
      }
    } else {
      errorData = ApiError(code: -1, message: 'Error field missing or invalid');
    }
    
    return UserUploadImagesResponse(
      success: json['success'] ?? false,
      payload: payloadData,
      error: errorData,
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

class UserUploadImagesPayload {
  final String message;
  final UserImageData? data;

  UserUploadImagesPayload({
    required this.message,
    this.data,
  });

  factory UserUploadImagesPayload.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    UserImageData? userImageData;
    if (dataJson is Map<String, dynamic>) {
      try {
        userImageData = UserImageData.fromJson(dataJson);
      } catch (e) {
        print('Error parsing UserImageData: $e');
        userImageData = null;
      }
    } else {
      userImageData = null;
    }
    return UserUploadImagesPayload(
      message: json['message']?.toString() ?? '',
      data: userImageData,
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
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      img1: json['img1']?.toString() ?? '',
      img2: json['img2']?.toString() ?? '',
      img3: json['img3']?.toString() ?? '',
      img4: json['img4']?.toString() ?? '',
      img5: json['img5']?.toString() ?? '',
      img6: json['img6']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      created: json['created']?.toString() ?? '',
      updated: json['updated']?.toString() ?? '',
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
      imageList.add('');
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
    int errorCode = 0;
    if (json['code'] != null) {
      if (json['code'] is int) {
        errorCode = json['code'] as int;
      } else if (json['code'] is String) {
        errorCode = int.tryParse(json['code'] as String) ?? 0;
      }
    }
    return ApiError(
      code: errorCode,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
