class OrderResponseModel {
  bool success;
  Payload payload;
  Error error;

  OrderResponseModel(
      {required this.success, required this.payload, required this.error});

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
        success: json['success'],
        payload: json['payload'],
        error: json['error']);
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'payload': payload, 'error': error};
  }
}

class Payload {
  String message;
  String orderId;
  String amount;

  Payload({required this.message, required this.orderId, required this.amount});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
        message: json['message'],
        orderId: json['order_id'],
        amount: json['amount']);
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'order_id': orderId, 'amount': amount};
  }
}

class Error {
  String code;
  String message;

  Error({required this.code, required this.message});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(code: json['code'], message: json['message']);
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message};
  }
}
