class AllTransactionsResponseModel {
  bool success;
  Payload payload;
  Error error;

  AllTransactionsResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory AllTransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    return AllTransactionsResponseModel(
      success: json['success'] ?? false, 
      payload: Payload.fromJson(json['payload']),
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
  List<Transaction> transactions;

  Payload({required this.transactions});

  factory Payload.fromJson(Map<String, dynamic> json) {
    var transactionsList = (json['transactions'] as List?)
            ?.map((transactionJson) => Transaction.fromJson(transactionJson))
            .toList() ??
        [];

    return Payload(transactions: transactionsList);
  }

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


  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      orderId: json['order_id'] ?? '',
      packageId: json['package_id'] ?? '',
      type: json['type'] ?? '',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      razorpayPaymentId: json['razorpay_payment_id'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      amount: _parseAmount(json['amount']),
      created: json['created']?.toString() ?? '', 
      updated: json['updated']?.toString() ?? '', 
    );
  }

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

  static String _parseAmount(dynamic amount) {
    if (amount == null) {
      return '0'; 
    } else if (amount is int) {
      return amount.toString();
    } else if (amount is double) {
      return amount.toStringAsFixed(2); 
    } else if (amount is String) {
      return amount; 
    }
    return '0'; 
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
      code: json['code'] ?? '',
      message: json['message'] ?? '',
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
