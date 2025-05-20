class AddUserToCreatorResponse {
  final bool success;
  final String message;
  final List<CreatorSubscriptionData> data;

  AddUserToCreatorResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddUserToCreatorResponse.fromJson(Map<String, dynamic> json) {
    return AddUserToCreatorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => CreatorSubscriptionData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CreatorSubscriptionData {
  final String id;
  final String creatorId;
  final String userId;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CreatorSubscriptionData({
    required this.id,
    required this.creatorId,
    required this.userId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CreatorSubscriptionData.fromJson(Map<String, dynamic> json) {
    return CreatorSubscriptionData(
      id: json['id'] ?? '',
      creatorId: json['creatorId'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}
