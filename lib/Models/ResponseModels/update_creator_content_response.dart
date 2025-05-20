class UpdateCreatorContentResponse {
  final bool success;
  final String message;
  final List<String> data;

  UpdateCreatorContentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UpdateCreatorContentResponse.fromJson(Map<String, dynamic> json) {
    return UpdateCreatorContentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
