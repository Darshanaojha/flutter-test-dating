import 'raw_backend_message.dart';
import 'ui_message.dart';
import 'ui_message_status.dart';

/// Maps backend message objects into UI-ready [UIMessage] instances.
///
/// IMPORTANT:
/// - Must not change backend schemas.
/// - Must derive status/timestamps from existing backend fields.
/// - Keep all mapping logic isolated here.
abstract interface class MessageAdapter {
  UIMessage fromRaw(RawBackendMessage raw);

  List<UIMessage> fromRawList(Iterable<RawBackendMessage> raws);
}

/// Default adapter implementation for the existing chat backend models.
///
/// Supported raw inputs inside [RawBackendMessage.raw]:
/// - `Message` from `lib/Models/ResponseModels/chat_history_response_model.dart`
/// - `ChatMessageEntity` from `lib/Models/Entities/chat_message_entity.dart`
/// - `Map<String, dynamic>` (when messages arrive as decoded JSON)
///
/// Notes:
/// - Pure/deterministic mapping (no API calls).
/// - Viewer-relative deletion semantics (per-user delete).
/// - Does NOT decrypt message bodies (existing business logic remains unchanged).
final class DefaultMessageAdapter implements MessageAdapter {
  final String viewerId;

  const DefaultMessageAdapter({required this.viewerId});

  @override
  UIMessage fromRaw(RawBackendMessage raw) {
    final Object obj = raw.raw;

    if (obj is Map<String, dynamic>) {
      return _fromMap(obj);
    }

    // Avoid direct imports of backend model classes here to keep the UI-layer
    // decoupled; use `dynamic` access with field-name safety.
    return _fromDynamic(obj);
  }

  @override
  List<UIMessage> fromRawList(Iterable<RawBackendMessage> raws) {
    return raws.map(fromRaw).toList(growable: false);
  }

  UIMessage _fromMap(Map<String, dynamic> json) {
    final String senderId =
        (json['sender_id'] ?? json['senderId'] ?? '').toString();
    final String receiverId =
        (json['receiver_id'] ?? json['receiverId'] ?? '').toString();

    final String id = (json['id'] ?? '').toString().trim();

    final dynamic messageTypeRaw = json['message_type'] ?? json['messageType'];
    final dynamic statusRaw = json['status'];

    final int deletedBySender =
        _toInt(json['deleted_by_sender'] ?? json['deletedBySender']) ?? 0;
    final int deletedByReceiver =
        _toInt(json['deleted_by_receiver'] ?? json['deletedByReceiver']) ?? 0;

    final String? created = json['created']?.toString();
    final String? timestamp = json['timestamp']?.toString();
    final String? updated = json['updated']?.toString();

    final DateTime ts = _resolveTimestamp(
      created: created,
      timestamp: timestamp,
      updated: updated,
      epochMillis: null,
    );

    final UIMessageStatus baseStatus = _mapStatusInt(_toInt(statusRaw));

    final bool isOutgoing = viewerId.isNotEmpty && viewerId == senderId;
    final bool deletedForViewer = _isDeletedForViewer(
      viewerId: viewerId,
      senderId: senderId,
      deletedBySender: deletedBySender,
      deletedByReceiver: deletedByReceiver,
    );
    final UIMessageStatus status =
        _applyViewerDelete(baseStatus, deletedForViewer);

    final _Content content = _mapContent(
      messageType: messageTypeRaw,
      messageText: json['message']?.toString(),
      imagePath: (json['imagePath'] ?? json['image_path'])?.toString(),
      mediaUrl: json['mediaUrl']?.toString(),
    );

    final String finalId = id.isNotEmpty
        ? id
        : _fallbackId(
            senderId: senderId,
            receiverId: receiverId,
            timestamp: ts,
            messageType: messageTypeRaw,
          );

    return UIMessage(
      id: finalId,
      timestamp: ts,
      status: status,
      isOutgoing: isOutgoing,
      text: content.text,
      imageUrl: content.imageUrl,
    );
  }

  UIMessage _fromDynamic(Object obj) {
    final dynamic d = obj;

    final String senderId = (d.senderId ?? '').toString();
    final String receiverId = (d.receiverId ?? '').toString();

    final String id = (d.id ?? '').toString().trim();

    final dynamic messageTypeRaw = d.messageType;
    final int? statusInt = _toInt(d.status);

    final int deletedBySender = _toInt(d.deletedBySender) ?? 0;
    final int deletedByReceiver = _toInt(d.deletedByReceiver) ?? 0;

    final String? created = d.created?.toString();
    final String? timestamp = d.timestamp?.toString();
    final String? updated = d.updated?.toString();

    // Local entity case (ChatMessageEntity) uses epoch int timestamp.
    final int? epochMillis = _toInt(d.timestamp) != null &&
            (created == null && updated == null)
        ? _toInt(d.timestamp)
        : null;

    final DateTime ts = _resolveTimestamp(
      created: created,
      timestamp: timestamp,
      updated: updated,
      epochMillis: epochMillis,
    );

    UIMessageStatus baseStatus;
    if (statusInt != null) {
      baseStatus = _mapStatusInt(statusInt);
    } else {
      // Minimal safe inference for entity-like models.
      final bool isRead = (d.isRead == true);
      final bool isDelivered = (d.isDelivered == true);
      baseStatus = isRead
          ? UIMessageStatus.seen
          : (isDelivered ? UIMessageStatus.delivered : UIMessageStatus.sent);
    }

    final bool isOutgoing = viewerId.isNotEmpty && viewerId == senderId;
    final bool deletedForViewer = _isDeletedForViewer(
      viewerId: viewerId,
      senderId: senderId,
      deletedBySender: deletedBySender,
      deletedByReceiver: deletedByReceiver,
    );
    final UIMessageStatus status =
        _applyViewerDelete(baseStatus, deletedForViewer);

    final _Content content = _mapContent(
      messageType: messageTypeRaw,
      messageText: d.message?.toString(),
      imagePath: d.imagePath?.toString(),
      mediaUrl: d.mediaUrl?.toString(),
    );

    final String finalId = id.isNotEmpty
        ? id
        : _fallbackId(
            senderId: senderId,
            receiverId: receiverId,
            timestamp: ts,
            messageType: messageTypeRaw,
          );

    return UIMessage(
      id: finalId,
      timestamp: ts,
      status: status,
      isOutgoing: isOutgoing,
      text: content.text,
      imageUrl: content.imageUrl,
    );
  }

  /// STATUS MAPPING (exact rules):
  /// 0=pending,1=sent,2=delivered,3=seen,4=failed; null->pending
  UIMessageStatus _mapStatusInt(int? status) {
    switch (status) {
      case 0:
        return UIMessageStatus.pending;
      case 1:
        return UIMessageStatus.sent;
      case 2:
        return UIMessageStatus.delivered;
      case 3:
        return UIMessageStatus.seen;
      case 4:
        return UIMessageStatus.failed;
      default:
        return UIMessageStatus.pending;
    }
  }

  /// Apply viewer-relative delete semantics.
  ///
  /// IMPORTANT rule: deletion must NOT override failed/pending.
  UIMessageStatus _applyViewerDelete(
    UIMessageStatus base,
    bool deletedForViewer,
  ) {
    if (!deletedForViewer) return base;
    if (base == UIMessageStatus.pending) return base;
    if (base == UIMessageStatus.failed) return base;
    return UIMessageStatus.deleted;
  }

  bool _isDeletedForViewer({
    required String viewerId,
    required String senderId,
    required int deletedBySender,
    required int deletedByReceiver,
  }) {
    final bool viewerIsSender = viewerId.isNotEmpty && viewerId == senderId;
    if (viewerIsSender) return deletedBySender == 1;
    return deletedByReceiver == 1;
  }

  DateTime _resolveTimestamp({
    required String? created,
    required String? timestamp,
    required String? updated,
    required int? epochMillis,
  }) {
    // TIMESTAMP SOURCE + PARSING RULES (exact):
    // 1 created string
    // 2 timestamp string
    // 3 updated string
    // 4 else DateTime.now()
    //
    // If epoch int provided -> DateTime.fromMillisecondsSinceEpoch().
    // Parse ISO strings via DateTime.parse(); on failure -> now.
    if (created != null && created.trim().isNotEmpty) {
      final DateTime? parsed = _tryParseIso(created);
      if (parsed != null) return parsed;
      return DateTime.now();
    }

    if (timestamp != null && timestamp.trim().isNotEmpty) {
      // If timestamp is actually numeric epoch in string form, treat as epoch ms.
      final int? asInt = int.tryParse(timestamp.trim());
      if (asInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(asInt);
      }
      final DateTime? parsed = _tryParseIso(timestamp);
      if (parsed != null) return parsed;
      return DateTime.now();
    }

    if (updated != null && updated.trim().isNotEmpty) {
      final DateTime? parsed = _tryParseIso(updated);
      if (parsed != null) return parsed;
      return DateTime.now();
    }

    if (epochMillis != null) {
      return DateTime.fromMillisecondsSinceEpoch(epochMillis);
    }

    return DateTime.now();
  }

  DateTime? _tryParseIso(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  _Content _mapContent({
    required dynamic messageType,
    required String? messageText,
    required String? imagePath,
    required String? mediaUrl,
  }) {
    // MESSAGE TYPE RULES (exact):
    // Text: messageType == 1 or "text"
    // Image: messageType == 2 or "image"
    // Unsupported: text=null, imageUrl=null
    final int? mtInt = _toInt(messageType);
    final String? mtStr =
        messageType is String ? messageType.toLowerCase().trim() : null;

    final bool isText = mtInt == 1 || mtStr == 'text';
    final bool isImage = mtInt == 2 || mtStr == 'image';

    if (isText) {
      final String? t = (messageText != null && messageText.trim().isNotEmpty)
          ? messageText
          : null;
      return _Content(text: t, imageUrl: null);
    }

    if (isImage) {
      final String? url =
          (imagePath != null && imagePath.trim().isNotEmpty) ? imagePath : null;
      // For entity models, images may use `mediaUrl`.
      final String? entityUrl =
          (mediaUrl != null && mediaUrl.trim().isNotEmpty) ? mediaUrl : null;
      return _Content(text: null, imageUrl: url ?? entityUrl);
    }

    return const _Content(text: null, imageUrl: null);
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value.toString());
  }

  String _fallbackId({
    required String senderId,
    required String receiverId,
    required DateTime timestamp,
    required dynamic messageType,
  }) {
    // Deterministic fallback ID for malformed/missing backend IDs.
    final String mt = messageType?.toString() ?? '';
    return '${senderId}_${receiverId}_${timestamp.millisecondsSinceEpoch}_$mt';
  }
}

class _Content {
  final String? text;
  final String? imageUrl;
  const _Content({required this.text, required this.imageUrl});
}
