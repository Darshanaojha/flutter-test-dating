class UpdateStatusResponse {
  final bool? status;
  final String? message;
  final List<dynamic>? data;

  UpdateStatusResponse({
    this.status,
    this.message,
    this.data,
  });

  factory UpdateStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateStatusResponse(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}
