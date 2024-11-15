class SubGenderResponse {
  final bool success;
  final SubGenderPayload payload;
  final ApiError error;

  SubGenderResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create SubGenderResponse from JSON
  factory SubGenderResponse.fromJson(Map<String, dynamic> json) {
    return SubGenderResponse(
      success: json['success'],
      payload: SubGenderPayload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
    );
  }

  // Method to convert SubGenderResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class SubGenderPayload {
  final String msg;
  final List<SubGenderData> data;

  SubGenderPayload({
    required this.msg,
    required this.data,
  });

  // Factory constructor to create SubGenderPayload from JSON
  factory SubGenderPayload.fromJson(Map<String, dynamic> json) {
    var dataList = (json['data'] as List)
        .map((item) => SubGenderData.fromJson(item))
        .toList();

    return SubGenderPayload(
      msg: json['msg'],
      data: dataList,
    );
  }

  // Method to convert SubGenderPayload object to JSON
  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class SubGenderData {
  final String id;
  final String title;

  SubGenderData({
    required this.id,
    required this.title,
  });

  // Factory constructor to create SubGenderData from JSON
  factory SubGenderData.fromJson(Map<String, dynamic> json) {
    return SubGenderData(
      id: json['id'],
      title: json['title'],
    );
  }

  // Method to convert SubGenderData object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
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
      message: json['message'] ?? '',  // Default to an empty string if message is null
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
