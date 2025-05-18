class AddUserToContentResponse {
  final bool success;
  final String message;
  final List<UserContentRelation> data;

  AddUserToContentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddUserToContentResponse.fromJson(Map<String, dynamic> json) {
    return AddUserToContentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => UserContentRelation.fromJson(e ?? {}))
              .toList() ??
          [],
    );
  }
}

class UserContentRelation {
  final String id;
  final String contentId;
  final String userId;
  final int status;
  final String createdAt;
  final String updatedAt;

  UserContentRelation({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserContentRelation.fromJson(Map<String, dynamic> json) {
    return UserContentRelation(
      id: json['id'] ?? '',
      contentId: json['contentId'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
