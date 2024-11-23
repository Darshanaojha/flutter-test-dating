class LikedByResponseModel {
  bool? success;
  Payload? payload;
  Error? error;

  LikedByResponseModel({this.success, this.payload, this.error});

  // Factory method to create a ResponseModel instance from JSON
  factory LikedByResponseModel.fromJson(Map<String, dynamic> json) {
    return LikedByResponseModel(
      success: json['success'],
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  // Method to convert a ResponseModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(),
      'error': error?.toJson(),
    };
  }
}

class Payload {
  String? message;

  Payload({this.message});

  // Factory method to create a Payload instance from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'],
    );
  }

  // Method to convert a Payload instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class Error {
  int? code;
  String? message;

  Error({this.code, this.message});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'],
      message: json['message'],
    );
  }

  // Method to convert an ErrorDetails instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
