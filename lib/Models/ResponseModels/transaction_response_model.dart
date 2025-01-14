class TransactionResponseModel {
  bool success;
  Payload payload;
  Error error;

  // Constructor
  TransactionResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor for converting JSON to TransactionResponseModel
  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionResponseModel(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  // Method to convert TransactionResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  Transaction transaction;

  // Constructor
  Payload({required this.transaction});

  // Factory constructor for converting JSON to Payload
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      transaction: Transaction.fromJson(json['transaction']),
    );
  }

  // Method to convert Payload to JSON
  Map<String, dynamic> toJson() {
    return {
      'transaction': transaction.toJson(),
    };
  }
}

class Transaction {
  String orderId;
  String packageId;
  String type;
  String razorpayOrderId;
  String razorpayPaymentId;
  String paymentStatus;
  String paymentMethod;
  String amount;
  String created;
  String updated;

  // Constructor
  Transaction({
    required this.orderId,
    required this.packageId,
    required this.type,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.amount,
    required this.created,
    required this.updated,
  });

  // Factory constructor for converting JSON to Transaction
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      orderId: json['order_id'],
      packageId: json['package_id'],
      type: json['type'],
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      amount: json['amount'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  // Method to convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'package_id': packageId,
      'type': type,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'amount': amount,
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

  // Factory constructor for converting JSON to Error
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
