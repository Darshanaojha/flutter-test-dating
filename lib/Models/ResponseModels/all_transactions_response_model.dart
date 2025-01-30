class AllTransactionsResponseModel {
  bool success;
  Payload payload;
  Error error;

  AllTransactionsResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create an instance from JSON
  factory AllTransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    return AllTransactionsResponseModel(
      success: json['success'] ?? false, // Default to false if success is null
      payload: Payload.fromJson(json['payload'] ?? {}),
      error: Error.fromJson(json['error'] ?? {}),
    );
  }
}

class Payload {
  List<Transaction> transactions;

  Payload({required this.transactions});

  // Factory constructor to create a list of transactions from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    var transactionsJson = json['transactions'] as List? ?? [];
    List<Transaction> transactionsList = transactionsJson
        .map((transactionJson) => Transaction.fromJson(transactionJson))
        .toList();
    return Payload(transactions: transactionsList);
  }
}

class Transaction {
  String id;
  String userId;
  String orderId;
  String packageId;
  String type;
  String? razorpayOrderId; // Nullable field
  String? razorpayPaymentId; // Nullable field
  String paymentStatus;
  String? paymentMethod; // Nullable field
  String amount;
  String message;
  String created;
  String updated;

  Transaction({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.packageId,
    required this.type,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.paymentStatus,
    this.paymentMethod,
    required this.amount,
    required this.message,
    required this.created,
    required this.updated,
  });

  // Factory constructor to create a transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '', // Default to empty string if id is null
      userId: json['user_id'] ?? '', // Default to empty string if user_id is null
      orderId: json['order_id'] ?? '', // Default to empty string if order_id is null
      packageId: json['package_id'] ?? '', // Default to empty string if package_id is null
      type: json['type'] ?? '', // Default to empty string if type is null
      razorpayOrderId: json['razorpay_order_id'], // Nullable
      razorpayPaymentId: json['razorpay_payment_id'], // Nullable
      paymentStatus: json['payment_status'] ?? '', // Default to empty string if payment_status is null
      paymentMethod: json['payment_method'], // Nullable
      amount: json['amount'] ?? '', // Default to empty string if amount is null
      message: json['message'] ?? '', // Default to empty string if message is null
      created: json['created'] ?? '', // Default to empty string if created is null
      updated: json['updated'] ?? '', // Default to empty string if updated is null
    );
  }
}

class Error {
  int code;
  String message;

  Error({
    required this.code,
    required this.message,
  });

  // Factory constructor to create an Error object from JSON
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] ?? 0, // Default to 0 if code is null
      message: json['message'] ?? '', // Default to empty string if message is null
    );
  }
}
