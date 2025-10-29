class SubscribedPackagesModel {
  bool success;
  Payload payload;
  Error error;

  SubscribedPackagesModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory SubscribedPackagesModel.fromJson(Map<String, dynamic> json) {
    return SubscribedPackagesModel(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload'] ?? {}),
      error: Error.fromJson(json['error'] ?? {}),
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
  List<PackageData> data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((package) => PackageData.fromJson(package))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((package) => package.toJson()).toList(),
    };
  }
}

class PackageData {
  String id;
  String userId;
  String packageCategoryId;
  String packageId;
  String days;
  String actualAmount;
  String offerAmount;
  String unit;
  String date;
  String status;
  String created;
  String updated;
  String packageTitle;

  PackageData({
    required this.id,
    required this.userId,
    required this.packageCategoryId,
    required this.packageId,
    required this.days,
    required this.actualAmount,
    required this.offerAmount,
    required this.unit,
    required this.date,
    required this.status,
    required this.created,
    required this.updated,
    required this.packageTitle,
  });

  factory PackageData.fromJson(Map<String, dynamic> json) {
    return PackageData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      packageCategoryId: json['package_category_id'] ?? '',
      packageId: json['package_id'] ?? '',
      days: json['days']?.toString() ?? '',
      actualAmount: json['actual_amount']?.toString() ?? '',
      offerAmount: json['offer_amount']?.toString() ?? '',
      unit: json['unit'] ?? '',
      date: json['date'] ?? '',
      status: json['status']?.toString() ?? '',
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
      packageTitle: json['package_title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_category_id': packageCategoryId,
      'package_id': packageId,
      'days': days,
      'actual_amount': actualAmount,
      'offer_amount': offerAmount,
      'unit': unit,
      'date': date,
      'status': status,
      'created': created,
      'updated': updated,
      'package_title': packageTitle,
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
      code: json['code'] ?? 0,
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
