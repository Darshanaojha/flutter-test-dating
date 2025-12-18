import '../adapters/raw_backend_message.dart';

/// Bridge from existing backend/controller message streams into the UI layer.
///
/// Implementations must:
/// - Subscribe to existing realtime/socket updates.
/// - Preserve backend interfaces.
/// - Output backend messages wrapped as [RawBackendMessage].
abstract interface class MessageStreamBridge {
  Stream<List<RawBackendMessage>> watchConversationMessages();

  /// Optional: emits incremental message events (if existing backend provides it).
  Stream<RawBackendMessage> watchMessageEvents();
}

/// A bridge that listens to an existing GetX `RxList` of backend messages and
/// exposes a conversation-scoped stream of [RawBackendMessage].
///
/// This class **does not** modify the source list; it only observes it.
///
/// Filtering rule:
/// - A raw message is included if it matches (viewerId <-> peerId) either direction.
///
/// Supported message shapes:
/// - Backend `Message` model (has `senderId` / `receiverId` fields)
/// - `Map<String, dynamic>` with `sender_id`/`receiver_id` or camelCase variants
///
/// If sender/receiver cannot be resolved, the message is excluded to avoid
/// leaking other conversations into the UI.
class GetxConversationMessageStreamBridge implements MessageStreamBridge {
  final String viewerId;
  final String peerId;

  /// Any GetX RxList-like object with a `.stream` yielding a `List`.
  /// We intentionally keep this loosely typed to avoid importing backend models.
  final dynamic messagesRxList;

  const GetxConversationMessageStreamBridge({
    required this.viewerId,
    required this.peerId,
    required this.messagesRxList,
  });

  @override
  Stream<List<RawBackendMessage>> watchConversationMessages() {
    // RxList in GetX exposes `.stream`. We rely on that contract without
    // mutating the source.
    final Stream<dynamic> src = messagesRxList.stream as Stream<dynamic>;
    return src.map((dynamic list) {
      final Iterable<dynamic> items =
          list is Iterable ? list.cast<dynamic>() : const <dynamic>[];

      final List<RawBackendMessage> filtered = <RawBackendMessage>[];
      for (final dynamic item in items) {
        if (_matchesConversation(item)) {
          filtered.add(RawBackendMessage(item as Object));
        }
      }
      return List<RawBackendMessage>.unmodifiable(filtered);
    });
  }

  @override
  Stream<RawBackendMessage> watchMessageEvents() {
    // Not all existing backends provide incremental events separate from list
    // updates; list stream is the reliable source of truth.
    return const Stream<RawBackendMessage>.empty();
  }

  bool _matchesConversation(dynamic raw) {
    final String sender = _readSenderId(raw);
    final String receiver = _readReceiverId(raw);
    if (sender.isEmpty || receiver.isEmpty) return false;

    final bool forward = sender == viewerId && receiver == peerId;
    final bool backward = sender == peerId && receiver == viewerId;
    return forward || backward;
  }

  String _readSenderId(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return (raw['sender_id'] ?? raw['senderId'] ?? '').toString();
    }
    try {
      return (raw.senderId ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  String _readReceiverId(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return (raw['receiver_id'] ?? raw['receiverId'] ?? '').toString();
    }
    try {
      return (raw.receiverId ?? '').toString();
    } catch (_) {
      return '';
    }
  }
}
