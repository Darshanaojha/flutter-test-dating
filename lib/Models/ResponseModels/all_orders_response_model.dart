class AllOrdersResponseModel {
  bool success;
  Payload payload;
  Error error;

  // Constructor
  AllOrdersResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create an instance from JSON
  factory AllOrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return AllOrdersResponseModel(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  // Method to convert AllOrdersResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  List<Order> orders;

  // Constructor
  Payload({required this.orders});

  // Factory constructor to create Payload instance from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    var ordersList = (json['orders'] as List)
        .map((orderJson) => Order.fromJson(orderJson))
        .toList();

    return Payload(orders: ordersList);
  }

  // Method to convert Payload to JSON
  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }
}

class Order {
  String id;
  String userId;
  String packageId;
  String type;
  String amount;
  String packageTitle;
  String packageCategoryId;
  String packageCategoryTitle;
  String packageCategoryDescription;
  String days;
  String actualAmount;
  String offerAmount;
  String unit;
  String? addonTitle;
  String? addonDuration;
  String? addonDurationUnit;
  String? addonAmount;
  String status;
  String created;
  String updated;

  // Constructor
  Order({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.type,
    required this.amount,
    required this.packageTitle,
    required this.packageCategoryId,
    required this.packageCategoryTitle,
    required this.packageCategoryDescription,
    required this.days,
    required this.actualAmount,
    required this.offerAmount,
    required this.unit,
    this.addonTitle,
    this.addonDuration,
    this.addonDurationUnit,
    this.addonAmount,
    required this.status,
    required this.created,
    required this.updated,
  });

  // Factory constructor to create an Order instance from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      packageId: json['package_id'],
      type: json['type'],
      amount: json['amount'],
      packageTitle: json['package_title'],
      packageCategoryId: json['package_category_id'],
      packageCategoryTitle: json['package_category_title'],
      packageCategoryDescription: json['package_category_description'],
      days: json['days'],
      actualAmount: json['actual_amount'],
      offerAmount: json['offer_amount'],
      unit: json['unit'],
      addonTitle: json['addon_title'],
      addonDuration: json['addon_duration'],
      addonDurationUnit: json['addon_duration_unit'],
      addonAmount: json['addon_amount'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  // Method to convert an Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'type': type,
      'amount': amount,
      'package_title': packageTitle,
      'package_category_id': packageCategoryId,
      'package_category_title': packageCategoryTitle,
      'package_category_description': packageCategoryDescription,
      'days': days,
      'actual_amount': actualAmount,
      'offer_amount': offerAmount,
      'unit': unit,
      'addon_title': addonTitle,
      'addon_duration': addonDuration,
      'addon_duration_unit': addonDurationUnit,
      'addon_amount': addonAmount,
      'status': status,
      'created': created,
      'updated': updated,
    };
  }
}

class Error {
  String code;
  String message;

  // Constructor
  Error({required this.code, required this.message});

  // Factory constructor to create Error instance from JSON
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'],
      message: json['message'],
    );
  }

  // Method to convert Error to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
