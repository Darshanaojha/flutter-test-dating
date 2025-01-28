class TransactionResponseModel {
  bool success;
  Payload? payload;  // Nullable Payload
  Error? error;  // Nullable Error

  TransactionResponseModel({
    required this.success,
    this.payload,
    this.error,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionResponseModel(
      success: json['success'] ?? false,  // Default to false if not present
      payload: json['payload'] != null ? Payload.fromJson(json['payload']) : null,  // Nullable Payload
      error: json['error'] != null ? Error.fromJson(json['error']) : null,  // Nullable Error
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(),  // Nullable Payload
      'error': error?.toJson(),  // Nullable Error
    };
  }
}

class Payload {
  Transaction? transaction;  // Nullable Transaction

  Payload({this.transaction});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      transaction: json['transaction'] != null ? Transaction.fromJson(json['transaction']) : null,  // Nullable Transaction
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction': transaction?.toJson(),  // Nullable Transaction
    };
  }
}

class Transaction {
  String? userId;  // Nullable String
  String? orderId;  // Nullable String
  String? packageId;  // Nullable String
  String? type;  // Nullable String
  String? razorpayOrderId;  // Nullable String
  String? razorpayPaymentId;  // Nullable String
  String? paymentStatus;  // Nullable String
  String? paymentMethod;  // Nullable String
  String? amount;  // Nullable String
  String? message;  // Nullable String
  String? updated;  // Nullable String

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
      userId: json['user_id'],  // Nullable String
      orderId: json['order_id'],  // Nullable String
      packageId: json['package_id'],  // Nullable String
      type: json['type'],  // Nullable String
      razorpayOrderId: json['razorpay_order_id'],  // Nullable String
      razorpayPaymentId: json['razorpay_payment_id'],  // Nullable String
      paymentStatus: json['payment_status'],  // Nullable String
      paymentMethod: json['payment_method'],  // Nullable String
      amount: json['amount'],  // Nullable String
      message: json['message'],  // Nullable String
      updated: json['updated'],  // Nullable String
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
  String? code;  // Nullable String
  String? message;  // Nullable String

  Error({
    this.code,
    this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code']?.toString(),  // Nullable String (handles null safely)
      message: json['message'],  // Nullable String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
