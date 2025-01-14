class AllTransactionsResponseModel {
  bool success;
  Payload payload;
  Error error;

  // Constructor
  AllTransactionsResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create an instance from JSON
  factory AllTransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    return AllTransactionsResponseModel(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  // Method to convert AllTransactionsResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  List<Transaction> transactions;

  // Constructor
  Payload({required this.transactions});

  // Factory constructor to create Payload instance from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    var transactionsList = (json['transactions'] as List)
        .map((transactionJson) => Transaction.fromJson(transactionJson))
        .toList();

    return Payload(transactions: transactionsList);
  }

  // Method to convert Payload to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }
}

class Transaction {
  String id;
  String userId;
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
    required this.id,
    required this.userId,
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

  // Factory constructor to create Transaction instance from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
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
      'id': id,
      'user_id': userId,
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
