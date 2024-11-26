class FAQResponseModel {
  bool success;
  Payload payload;
  Error error;

  FAQResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory FAQResponseModel.fromJson(Map<String, dynamic> json) {
    return FAQResponseModel(
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

class Payload {
  String message;
  List<FAQItem> data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<FAQItem> faqList = list.map((i) => FAQItem.fromJson(i)).toList();

    return Payload(
      message: json['message'],
      data: faqList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((i) => i.toJson()).toList(),
    };
  }
}

class FAQItem {
  String id;
  String question;
  String ans;
  String status;
  String created;
  String updated;

  FAQItem({
    required this.id,
    required this.question,
    required this.ans,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id'],
      question: json['question'],
      ans: json['ans'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'ans': ans,
      'status': status,
      'created': created,
      'updated': updated,
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
