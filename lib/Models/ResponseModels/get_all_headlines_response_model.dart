
class Headline {
  final String id;
  final String title;
  final String description;
  final String type;

  Headline({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });

  factory Headline.fromJson(Map<String, dynamic> json) {
    return Headline(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
    };
  }
}

class Payload {
  final String msg;
  final List<Headline> data;

  Payload({
    required this.msg,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      msg: json['msg'],
      data: (json['data'] as List)
          .map((item) => Headline.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data.map((headline) => headline.toJson()).toList(),
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


class HeadlinesResponse {
  final bool success;
  final Payload payload;
  final Error error;

  HeadlinesResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory HeadlinesResponse.fromJson(Map<String, dynamic> json) {
    return HeadlinesResponse(
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
