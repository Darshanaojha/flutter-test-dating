class TransactionResponseModel {
  bool success;
  Payload? payload;
  Error? error;

  TransactionResponseModel({
    required this.success,
    this.payload,
    this.error,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionResponseModel(
      success: json['success'] ?? false,
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(),
      'error': error?.toJson(),
    };
  }
}

class Payload {
  Transaction? transaction;

  Payload({this.transaction});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      transaction: json['transaction'] != null
          ? Transaction.fromJson(json['transaction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction': transaction?.toJson(),
    };
  }
}

class Transaction {
  String? userId;
  String? orderId;
  String? packageId;
  String? type;
  String? razorpayOrderId;
  String? razorpayPaymentId;
  String? paymentStatus;
  String? paymentMethod;
  String? amount;
  String? message;
  String? updated;

  Transaction({
    this.userId,
    this.orderId,
    this.packageId,
    this.type,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.paymentStatus,
    this.paymentMethod,
    this.amount,
    this.message,
    this.updated,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      userId: json['user_id'],
      orderId: json['order_id'],
      packageId: json['package_id'],
      type: json['type'],
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      amount: json['amount'],
      message: json['message'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'order_id': orderId,
      'package_id': packageId,
      'type': type,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'amount': amount,
      'message': message,
      'updated': updated,
    };
  }
}

class Error {
  String code;
  String message;

  Error({
    required this.code,
    required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code']?.toString() ?? '',
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
