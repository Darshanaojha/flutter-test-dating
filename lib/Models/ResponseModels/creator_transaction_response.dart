class CreatorTransactionResponse {
  final bool success;
  final String message;
  final dynamic data;

  CreatorTransactionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreatorTransactionResponse.fromJson(Map<String, dynamic> json) {
    return CreatorTransactionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json.containsKey('data') ? json['data'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
