class AppDetailsResponse {
  final bool success;
  final Payload? payload;
  final Error error;

  AppDetailsResponse({
    required this.success,
    this.payload,
    required this.error,
  });

  factory AppDetailsResponse.fromJson(Map<String, dynamic> json) {
    return AppDetailsResponse(
      success: json['success'],
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
      error: Error.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  final String msg;
  final AppDetailsData? data;

  Payload({
    required this.msg,
    this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      msg: json['msg'],
      data: json['data'] != null ? AppDetailsData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data?.toJson(),
    };
  }
}

class AppDetailsData {
  final String id;
  final String appName;
  final String logo;
  final String releaseDate;
  final String licenses;
  final String version;
  final String created;
  final String updated;

  AppDetailsData({
    required this.id,
    required this.appName,
    required this.logo,
    required this.releaseDate,
    required this.licenses,
    required this.version,
    required this.created,
    required this.updated,
  });

  factory AppDetailsData.fromJson(Map<String, dynamic> json) {
    return AppDetailsData(
      id: json['id'],
      appName: json['app_name'],
      logo: json['logo'],
      releaseDate: json['release_date'],
      licenses: json['licenses'],
      version: json['version'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_name': appName,
      'logo': logo,
      'release_date': releaseDate,
      'licenses': licenses,
      'version': version,
      'created': created,
      'updated': updated,
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
