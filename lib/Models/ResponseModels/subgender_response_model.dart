class SubGenderResponse {
  final bool success;
  final SubGenderPayload payload;
  final ApiError error;

  SubGenderResponse({
    required this.success,
    required this.payload,
    required this.error,
  });


  factory SubGenderResponse.fromJson(Map<String, dynamic> json) {
    return SubGenderResponse(
      success: json['success'],
      payload: SubGenderPayload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
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

class SubGenderPayload {
  final String msg;
  final List<SubGenderData> data;

  SubGenderPayload({
    required this.msg,
    required this.data,
  });


  factory SubGenderPayload.fromJson(Map<String, dynamic> json) {
    var dataList = (json['data'] as List)
        .map((item) => SubGenderData.fromJson(item))
        .toList();

    return SubGenderPayload(
      msg: json['msg'],
      data: dataList,
    );
  }

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


  factory SubGenderData.fromJson(Map<String, dynamic> json) {
    return SubGenderData(
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

class ApiError {
  final int code;
  final String message;

  ApiError({
    required this.code,
    required this.message,
  });


  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
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
