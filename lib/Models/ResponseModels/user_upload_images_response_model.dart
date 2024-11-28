class UserUploadImagesResponse {
  final bool success;
  final UserUploadImagesPayload? payload; // Making payload nullable
  final ApiError error;

  UserUploadImagesResponse({
    required this.success,
    this.payload, // payload can now be null
    required this.error,
  });

  // Factory constructor to create UserUploadImagesResponse from JSON
  factory UserUploadImagesResponse.fromJson(Map<String, dynamic> json) {
    return UserUploadImagesResponse(
      success: json['success'],
      payload: json['payload'] != null
          ? UserUploadImagesPayload.fromJson(json['payload'])
          : null, // Check if payload exists before deserializing
      error: ApiError.fromJson(json['error']),
    );
  }

  // Method to convert UserUploadImagesResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload':
          payload?.toJson(), // Convert payload to JSON only if it's not null
      'error': error.toJson(),
    };
  }
}

class UserUploadImagesPayload {
  final String message;
  final UserImageData? data; // Making data nullable

  UserUploadImagesPayload({
    required this.message,
    this.data, // data can be null
  });

  // Factory constructor to create UserUploadImagesPayload from JSON
  factory UserUploadImagesPayload.fromJson(Map<String, dynamic> json) {
    return UserUploadImagesPayload(
      message: json['message'],
      data: json['data'] != null
          ? UserImageData.fromJson(json['data'])
          : null, // Check if data exists before deserializing
    );
  }

  // Method to convert UserUploadImagesPayload object to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(), // Convert data to JSON only if it's not null
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

  // Factory constructor to create UserImageData from JSON
  factory UserImageData.fromJson(Map<String, dynamic> json) {
    return UserImageData(
      id: json['id'],
      userId: json['user_id'],
      img1: json['img1'] ?? '', // Default to empty string if no image
      img2: json['img2'] ?? '', // Default to empty string if no image
      img3: json['img3'] ?? '', // Default to empty string if no image
      img4: json['img4'] ?? '', // Default to empty string if no image
      img5: json['img5'] ?? '', // Default to empty string if no image
      img6: json['img6'] ?? '', // Default to empty string if no image
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  // Method to convert UserImageData object to JSON
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

  // Factory constructor to create ApiError from JSON
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message:
          json['message'] ?? '', // Default to empty string if message is null
    );
  }

  // Method to convert ApiError object to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
