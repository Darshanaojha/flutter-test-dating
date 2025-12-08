import 'package:dating_application/Models/ResponseModels/update_visibility_status_response_model.dart';
import 'package:dating_application/Models/ResponseModels/user_upload_images_response_model.dart';

class GetRejectionMessageModel {
  final bool success;
  final Payload payload;
  final ApiError error;

  GetRejectionMessageModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory GetRejectionMessageModel.fromJson(Map<String, dynamic> json) {
    return GetRejectionMessageModel(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload'] ?? {}),
      error: ApiError.fromJson(json['error'] ?? {}),
    );
  }
}

class Payload {
  final String message;
  final RejectionData? data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? RejectionData.fromJson(json['data'])
          : null,
    );
  }
}

class RejectionData {
  final String feedback;
  

  RejectionData({
    required this.feedback,
  });

  factory RejectionData.fromJson(Map<String, dynamic> json) {
    return RejectionData(
      feedback: json['feedback'] ?? '',
    );
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
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}