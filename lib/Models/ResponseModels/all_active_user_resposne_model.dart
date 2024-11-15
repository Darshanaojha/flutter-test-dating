class AllActiveUsersResponse {
  final bool success;
  final AllActiveUsersPayload payload;
  final ApiError error;

  AllActiveUsersResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create AllActiveUsersResponse from JSON
  factory AllActiveUsersResponse.fromJson(Map<String, dynamic> json) {
    return AllActiveUsersResponse(
      success: json['success'],
      payload: AllActiveUsersPayload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
    );
  }

  // Method to convert AllActiveUsersResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class AllActiveUsersPayload {
  final String message;
  final List<UserDetails> data;

  AllActiveUsersPayload({
    required this.message,
    required this.data,
  });
  factory AllActiveUsersPayload.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<UserDetails> userList = list.map((i) => UserDetails.fromJson(i)).toList();
    
    return AllActiveUsersPayload(
      message: json['message'],
      data: userList,
    );
  }

  // Method to convert AllActiveUsersPayload object to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((user) => user.toJson()).toList(),
    };
  }
}

class UserDetails {
  final String id;
  final String name;
  final String nickname;
  final String dob;
  final String genderName;
  final String subGenderNm;

  UserDetails({
    required this.id,
    required this.name,
    required this.nickname,
    required this.dob,
    required this.genderName,
    required this.subGenderNm,
  });

  // Factory constructor to create UserDetails from JSON
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      name: json['name'],
      nickname: json['nickname'],
      dob: json['dob'],
      genderName: json['gender_name'],
      subGenderNm: json['sub_gender_nm'],
    );
  }

  // Method to convert UserDetails object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'dob': dob,
      'gender_name': genderName,
      'sub_gender_nm': subGenderNm,
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
      message: json['message'] ?? '', // Default to an empty string if message is null
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
