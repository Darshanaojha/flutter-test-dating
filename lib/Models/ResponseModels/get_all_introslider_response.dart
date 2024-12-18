import 'dart:convert';

class IntroSliderResponse {
  bool? success;
  Payload? payload;
  Error? error;

  IntroSliderResponse({this.success, this.payload, this.error});

  // From JSON constructor
  factory IntroSliderResponse.fromJson(Map<String, dynamic> json) {
    return IntroSliderResponse(
      success: json['success'],
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(),
      'error': error?.toJson(),
    };
  }
}

class Payload {
  String? msg;
  List<SliderData>? data;

  Payload({this.msg, this.data});

  // From JSON constructor
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      msg: json['msg'],
      data: json['data'] != null
          ? List<SliderData>.from(
              json['data'].map((x) => SliderData.fromJson(x)))
          : [],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class SliderData {
  String? id;
  String? title;
  String? image;
  String? status;
  String? created;
  String? updated;

  SliderData({
    this.id,
    this.title,
    this.image,
    this.status,
    this.created,
    this.updated,
  });

  // From JSON constructor
  factory SliderData.fromJson(Map<String, dynamic> json) {
    return SliderData(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'status': status,
      'created': created,
      'updated': updated,
    };
  }
}

class Error {
  int? code;
  String? message;

  Error({this.code, this.message});

  // From JSON constructor
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'],
      message: json['message'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
