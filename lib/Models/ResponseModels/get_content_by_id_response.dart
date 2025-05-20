class CreatorContentByIdResponse {
  final bool success;
  final String message;
  final List<CreatorContentById> data;

  CreatorContentByIdResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorContentByIdResponse.fromJson(Map<String, dynamic> json) {
    return CreatorContentByIdResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => CreatorContentById.fromJson(e))
          .toList(),
    );
  }
}

class CreatorContentById {
  final String id;
  final String creatorId;
  final int type;
  final String contentTitle;
  final String contentDescription;
  final String contentName;
  final int status;
  final DateTime? updated;
  final DateTime? created;
  final double actualAmount;
  final double offeredDiscount;
  final int contentCut;

  CreatorContentById({
    required this.id,
    required this.creatorId,
    required this.type,
    required this.contentTitle,
    required this.contentDescription,
    required this.contentName,
    required this.status,
    required this.updated,
    required this.created,
    required this.actualAmount,
    required this.offeredDiscount,
    required this.contentCut,
  });

  factory CreatorContentById.fromJson(Map<String, dynamic> json) {
    return CreatorContentById(
      id: json['id'] ?? '',
      creatorId: json['creatorId'] ?? '',
      type: json['type'] ?? 0,
      contentTitle: json['contentTitle'] ?? '',
      contentDescription: json['contentDescription'] ?? '',
      contentName: json['contentName'] ?? '',
      status: json['status'] ?? 0,
      updated:
          json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
      created:
          json['created'] != null ? DateTime.tryParse(json['created']) : null,
      actualAmount: (json['actualAmount'] as num?)?.toDouble() ?? 0.0,
      offeredDiscount: (json['offeredDiscount'] as num?)?.toDouble() ?? 0.0,
      contentCut: json['contentCut'] ?? 0,
    );
  }
}
