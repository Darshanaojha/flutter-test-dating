class GetAllAddonsResponse {
  final bool success;
  final Payload payload;
  final Error error;

  GetAllAddonsResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory GetAllAddonsResponse.fromJson(Map<String, dynamic> json) {
    return GetAllAddonsResponse(
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
  final String msg;
  final List<Addon> data;

  Payload({
    required this.msg,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<Addon> addonList =
        dataList.map((addonJson) => Addon.fromJson(addonJson)).toList();

    return Payload(
      msg: json['msg'],
      data: addonList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data.map((addon) => addon.toJson()).toList(),
    };
  }
}

class Addon {
  final String id;
  final String title;
  final String duration;
  final String durationUnit;
  final String amount;
  final String status;
  final String created;
  final String updated;
  final List<AddonPoint> addonPoints;

  Addon({
    required this.id,
    required this.title,
    required this.duration,
    required this.durationUnit,
    required this.amount,
    required this.status,
    required this.created,
    required this.updated,
    required this.addonPoints,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    var addonPointsList = json['addonpoints'] as List;
    List<AddonPoint> points = addonPointsList
        .map((pointJson) => AddonPoint.fromJson(pointJson))
        .toList();

    return Addon(
      id: json['id'],
      title: json['title'],
      duration: json['duration'],
      durationUnit: json['duration_unit'],
      amount: json['amount'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      addonPoints: points,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'duration_unit': durationUnit,
      'amount': amount,
      'status': status,
      'created': created,
      'updated': updated,
      'addonpoints': addonPoints.map((point) => point.toJson()).toList(),
    };
  }
}

class AddonPoint {
  final String id;
  final String addOnId;
  final String title;
  final String status;
  final String created;
  final String updated;

  AddonPoint({
    required this.id,
    required this.addOnId,
    required this.title,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory AddonPoint.fromJson(Map<String, dynamic> json) {
    return AddonPoint(
      id: json['id'],
      addOnId: json['add_on_id'],
      title: json['title'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'add_on_id': addOnId,
      'title': title,
      'status': status,
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
