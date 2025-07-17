class OrderResponseModel {
  bool success;
  Payload? payload; // Nullable Payload
  Error? error; // Nullable Error

  OrderResponseModel({
    required this.success,
    this.payload,
    this.error,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      success: json['success'] ?? false, // Defaulting to false if missing
      payload: json['payload'] != null
          ? Payload.fromJson(json['payload'])
          : null, // Nullable Payload
      error: json['error'] != null
          ? Error.fromJson(json['error'])
          : null, // Nullable Error
    );
  }

  // Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(), // Nullable Payload
      'error': error?.toJson(), // Nullable Error
    };
  }
}

class Payload {
  String? message; // Nullable
  int? orderId; // Nullable int
  String? amount; // Nullable String
  String? order; // Nullable String
  int? transactionId; // Nullable int

  Payload({
    this.message,
    this.orderId,
    this.amount,
    this.order,
    this.transactionId,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'], // Nullable string
      orderId: json['order_id'] != null
          ? int.tryParse(json['order_id'].toString())
          : null, // Nullable int
      amount: json['amount'], // Nullable String
      order: json['order'], // Nullable String
      transactionId: json['transactionId'] != null
          ? int.tryParse(json['transactionId'].toString())
          : null, // Nullable int
    );
  }

  // Method to convert Payload back to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'order_id': orderId, // Nullable int
      'amount': amount,
      'order': order,
      'transactionId': transactionId, // Nullable int
    };
  }
}

class Error {
  int? code; // Nullable int
  String? message; // Nullable String

  Error({
    this.code, // Nullable int
    this.message, // Nullable String
  });

  // Factory constructor to create Error from JSON
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'], // Nullable int
      message: json['message'], // Nullable String
    );
  }

  // Method to convert Error back to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
