class SubscribedContentResponse {
  final bool success;
  final String message;
  final List<SubscribedContent> data;

  SubscribedContentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubscribedContentResponse.fromJson(Map<String, dynamic> json) {
    return SubscribedContentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => SubscribedContent.fromJson(item ?? {}))
              .toList() ??
          [],
    );
  }
}

class SubscribedContent {
  final String id;
  final String creatorId;
  final int type;
  final String contentTitle;
  final String contentDescription;
  final String contentName;

  SubscribedContent({
    required this.id,
    required this.creatorId,
    required this.type,
    required this.contentTitle,
    required this.contentDescription,
    required this.contentName,
  });

  factory SubscribedContent.fromJson(Map<String, dynamic> json) {
    return SubscribedContent(
      id: json['id'] ?? '',
      creatorId: json['creatorId'] ?? '',
      type: json['type'] ?? 0,
      contentTitle: json['contentTitle'] ?? '',
      contentDescription: json['contentDescription'] ?? '',
      contentName: json['contentName'] ?? '',
    );
  }
}
