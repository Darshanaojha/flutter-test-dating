class CreatorContentResponse {
  final bool success;
  final String message;
  final List<CreatorContent> data;

  CreatorContentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorContentResponse.fromJson(Map<String, dynamic> json) {
    return CreatorContentResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => CreatorContent.fromJson(item))
          .toList(),
    );
  }
}

class CreatorContent {
  final String id;
  final String creatorId;
  final int type;
  final String contentTitle;
  final String contentDescription;
  final String contentName;
  final int status;
  final DateTime updated;
  final DateTime created;
  final double actualAmount;
  final double offeredDiscount;
  final int contentCut;

  CreatorContent({
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

  factory CreatorContent.fromJson(Map<String, dynamic> json) {
    return CreatorContent(
      id: json['id'],
      creatorId: json['creatorId'],
      type: json['type'],
      contentTitle: json['contentTitle'],
      contentDescription: json['contentDescription'],
      contentName: json['contentName'],
      status: json['status'],
      updated: DateTime.parse(json['updated']),
      created: DateTime.parse(json['created']),
      actualAmount: (json['actualAmount'] as num).toDouble(),
      offeredDiscount: (json['offeredDiscount'] as num).toDouble(),
      contentCut: json['contentCut'],
    );
  }
}
