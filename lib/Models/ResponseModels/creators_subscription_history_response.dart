class CreatorSubscriptionHistoryResponse {
  final bool success;
  final String message;
  final List<CreatorSubscriptionHistory> data;

  CreatorSubscriptionHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorSubscriptionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CreatorSubscriptionHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => CreatorSubscriptionHistory.fromJson(item))
          .toList(),
    );
  }
}

class CreatorSubscriptionHistory {
  final String id;
  final String userId;
  final String creatorId;
  final String packageId;
  final String subscriptionType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int status;
  final DateTime? created;
  final DateTime? updated;

  CreatorSubscriptionHistory({
    required this.id,
    required this.userId,
    required this.creatorId,
    required this.packageId,
    required this.subscriptionType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory CreatorSubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return CreatorSubscriptionHistory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      creatorId: json['creatorId'] ?? '',
      packageId: json['packageId'] ?? '',
      subscriptionType: json['subscriptionType'] ?? '',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      status: json['status'] ?? 0,
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
    );
  }
}
