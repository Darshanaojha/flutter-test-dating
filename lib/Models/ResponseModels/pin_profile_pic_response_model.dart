class PinProfilePicResponseModel {
  bool? success;
  Payload? payload;
  Error? error;

  PinProfilePicResponseModel({this.success, this.payload, this.error});


  factory PinProfilePicResponseModel.fromJson(Map<String, dynamic> json) {
    return PinProfilePicResponseModel(
      success: json['success'],
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }


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


  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'],
    );
  }

  
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

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
