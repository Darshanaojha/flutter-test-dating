import 'dart:convert';


class BlockUserResponseModel {
  bool success;
  Payload payload;
  Error error;

  BlockUserResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory BlockUserResponseModel.fromJson(Map<String, dynamic> json) {
    return BlockUserResponseModel(
      success: json['success'] ?? false,
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

  static BlockUserResponseModel fromJsonString(String str) {
    return BlockUserResponseModel.fromJson(json.decode(str));
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}

class Payload {
  String message;

  Payload({required this.message});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class Error {
  int code;
  String message;

  Error({required this.code, required this.message});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] ?? 0,
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

