
class AllOrdersResponseModel {
  bool success;
  Payload payload;
  Error error;

  AllOrdersResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory AllOrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return AllOrdersResponseModel(
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
  List<Order> orders;

  Payload({required this.orders});

  factory Payload.fromJson(Map<String, dynamic> json) {
    var ordersList = (json['orders'] as List?)
            ?.map((orderJson) => Order.fromJson(orderJson))
            .toList() ??
        [];  // Default to an empty list if orders is null or empty.

    return Payload(orders: ordersList);
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }
}

class Order {
  String id;
  String razorpayOrderId;
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

  Order({
    required this.id,
    required this.razorpayOrderId,
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

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',  // Default to empty string if null
      razorpayOrderId: json['razorpay_order_id'] ?? '',  // Default to empty string if null
      userId: json['user_id'] ?? '',
      packageId: json['package_id'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount'] ?? '0.00',  // Default to '0.00' if null
      packageTitle: json['package_title'] ?? '',
      packageCategoryId: json['package_category_id'] ?? '',
      packageCategoryTitle: json['package_category_title'] ?? '',
      packageCategoryDescription: json['package_category_description'] ?? '',
      days: json['days'] ?? '',
      actualAmount: json['actual_amount'] ?? '0.00',  // Default to '0.00' if null
      offerAmount: json['offer_amount'] ?? '0.00',  // Default to '0.00' if null
      unit: json['unit'] ?? '',
      addonTitle: json['addon_title'] as String?,
      addonDuration: json['addon_duration'] as String?,
      addonDurationUnit: json['addon_duration_unit'] as String?,
      addonAmount: json['addon_amount'] as String?,
      status: json['status'] ?? '', 
      created: json['created'] ?? '', 
      updated: json['updated'] ?? '',  
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'razorpay_order_id': razorpayOrderId,
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
      'addon_title': addonTitle ?? '',
      'addon_duration': addonDuration ?? '',
      'addon_duration_unit': addonDurationUnit ?? '',
      'addon_amount': addonAmount ?? '',
      'status': status,
      'created': created,
      'updated': updated,
    };
  }
}

class Error {
  int code;
  String message;

  Error({required this.code, required this.message});

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
