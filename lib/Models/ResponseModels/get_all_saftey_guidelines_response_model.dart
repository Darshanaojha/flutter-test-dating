
class SafetyGuideline {
  final String id;
  final String title;
  final String description;

  SafetyGuideline({
    required this.id,
    required this.title,
    required this.description,
  });

  factory SafetyGuideline.fromJson(Map<String, dynamic> json) {
    return SafetyGuideline(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}


class Payload {
  final String msg;
  final List<SafetyGuideline> data;

  Payload({
    required this.msg,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      msg: json['msg'],
      data: (json['data'] as List)
          .map((item) => SafetyGuideline.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data.map((guideline) => guideline.toJson()).toList(),
    };
  }
}

class Error {
  final int code;
  final String message;

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

class SafetyGuidelinesResponse {
  final bool success;
  final Payload payload;
  final Error error;

  SafetyGuidelinesResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory SafetyGuidelinesResponse.fromJson(Map<String, dynamic> json) {
    return SafetyGuidelinesResponse(
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
