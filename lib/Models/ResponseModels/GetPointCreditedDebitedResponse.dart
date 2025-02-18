
class GetPointCreditedDebitedResponse {
  bool success;
  PointsPayload payload;
  PointsError error;

  GetPointCreditedDebitedResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

   factory GetPointCreditedDebitedResponse.fromJson(Map<String, dynamic> json) {
    return GetPointCreditedDebitedResponse(
      success: json['success'],
      payload: PointsPayload.fromJson(json['payload']),
      error: PointsError.fromJson(json['error']),
    );
  }
  Map<String, dynamic> tojson() {
    return {'success': success, 'payload': payload, 'error': error};
  }
}

class PointsPayload {
  final List<CreditDebitHistory> creditdebithistory;

  PointsPayload({required this.creditdebithistory});

  factory PointsPayload.fromJson(Map<String, dynamic>? json) {
    return PointsPayload(
      creditdebithistory: (json?['credit_debit_history'] as List?)
              ?.map((e) => CreditDebitHistory.fromJson(e))
              .toList() ??
          [], 
    );
  }

  Map<String, dynamic> tojson(){
    return {
     'credit_debit_history':creditdebithistory,
    };
  }
}

class CreditDebitHistory {
  final String credited;
  final String debited;

  CreditDebitHistory({required this.credited, required this.debited});

  factory CreditDebitHistory.fromJson(Map<String, dynamic>? json) {
    // Fallback to default values if points or amount are missing
    return CreditDebitHistory(
      credited: json?['credited'] ?? '0',
      debited: json?['debited'] ?? '0',
    );
  }
  Map<String, dynamic> tojson(){
    return {
      'credited': credited,
      'debited': debited,
    };
  }
}

class PointsError {
  int code;
  String message;

  PointsError({required this.code, required this.message});

  factory PointsError.fromJson(Map<String, dynamic> json) {
    return PointsError(code: json['code'] ?? 0, message: json['message'] ?? '');
  }

  Map<String, dynamic> tojson() {
    return {
      'code': code,
      'message': message,
    };
  }
}


