class OrderResponseModel {
  bool success;
  Payload payload;
  Error error;

  OrderResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {


    // Safely parsing each field with null checks if necessary
    return OrderResponseModel(
      success: json['success'] ?? false, // Default to false if success is not provided
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
  String orderId;
  String amount;

  Payload({
    required this.message,
    required this.orderId,
    required this.amount,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'].toString(), // Default empty string if message is null
      orderId: json['order_id'].toString(), // Default empty string if order_id is null
      amount: json['amount'].toString(), // Default '0.0' if amount is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'order_id': orderId,
      'amount': amount,
    };
  }
}

class Error {
  String code; // Changed to int
  String message;

  Error({
    required this.code,
    required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'].toString(), // Default to 0 if code is null or missing
      message: json['message'].toString(), // Default to empty string if message is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
