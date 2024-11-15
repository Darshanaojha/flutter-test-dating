// UserPreference Model
class UserPreference {
  final String id;
  final String title;

  UserPreference({
    required this.id,
    required this.title,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

// Payload Model
class Payload {
  final String msg;
  final List<UserPreference> data;

  Payload({
    required this.msg,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      msg: json['msg'],
      data: (json['data'] as List)
          .map((item) => UserPreference.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data.map((preference) => preference.toJson()).toList(),
    };
  }
}

// Error Model
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

// Full Response Model
class UserPreferencesResponse {
  final bool success;
  final Payload payload;
  final Error error;

  UserPreferencesResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory UserPreferencesResponse.fromJson(Map<String, dynamic> json) {
    return UserPreferencesResponse(
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
