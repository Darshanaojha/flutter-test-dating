
class DeleteFavouriteResponse {
  bool success;
  String payload;
  Error error;

  DeleteFavouriteResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory DeleteFavouriteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteFavouriteResponse(
      success: json['success'],
      payload: json['payload'],
      error: Error.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload,
      'error': error.toJson(),
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
