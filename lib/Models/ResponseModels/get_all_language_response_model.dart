

class GetAllLanguagesResponse {
  final bool success;
  final Payload payload;
  final ErrorResponse error;

  GetAllLanguagesResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory GetAllLanguagesResponse.fromJson(Map<String, dynamic> json) {
    return GetAllLanguagesResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: ErrorResponse.fromJson(json['error']),
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

class Payload {
  final String msg;
  final List<Language> data;

  Payload({
    required this.msg,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Language> languages = list.map((e) => Language.fromJson(e)).toList();
    
    return Payload(
      msg: json['msg'],
      data: languages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Language {
  final String id;
  final String title;
  final String desc;
  final String status;
  final String created;
  final String updated;

  Language({
    required this.id,
    required this.title,
    required this.desc,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      title: json['title'],
      desc: json['desc'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'status': status,
      'created': created,
      'updated': updated,
    };
  }
}

class ErrorResponse {
  final int code;
  final String message;

  ErrorResponse({
    required this.code,
    required this.message,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
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
