class CreatorByCreatorResponse {
  final bool success;
  final String message;
  final List<CreatorContents> data;

  CreatorByCreatorResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorByCreatorResponse.fromJson(Map<String, dynamic> json) {
    return CreatorByCreatorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => CreatorContents.fromJson(e ?? {}))
              .toList() ??
          [],
    );
  }
}

class CreatorContents {
  final String id;
  final String creatorId;
  final int type;
  final String contentTitle;
  final String contentDescription;
  final String contentName;
  final int status;
  final String updated;
  final String created;
  final double actualAmount;
  final double offeredDiscount;
  final int contentCut;

  CreatorContents({
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

  factory CreatorContents.fromJson(Map<String, dynamic> json) {
    return CreatorContents(
      id: json['id'] ?? '',
      creatorId: json['creatorId'] ?? '',
      type: json['type'] ?? 0,
      contentTitle: json['contentTitle'] ?? '',
      contentDescription: json['contentDescription'] ?? '',
      contentName: json['contentName'] ?? '',
      status: json['status'] ?? 0,
      updated: json['updated'] ?? '',
      created: json['created'] ?? '',
      actualAmount: (json['actualAmount'] ?? 0).toDouble(),
      offeredDiscount: (json['offeredDiscount'] ?? 0).toDouble(),
      contentCut: json['contentCut'] ?? 0,
    );
  }
}
