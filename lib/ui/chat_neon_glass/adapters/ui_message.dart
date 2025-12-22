import 'package:flutter/foundation.dart';

import 'ui_message_status.dart';

/// UI-ready immutable message model.
///
/// Populated exclusively by [MessageAdapter] from [RawBackendMessage].
///
/// NOTE: This is a UI model; it must remain compatible with existing backend
/// schemas and should not require backend changes.
@immutable
class UIMessage {
  final String id;
  final DateTime timestamp;
  final UIMessageStatus status;

  /// True if this message should render as outgoing (right-aligned) bubble.
  final bool isOutgoing;

  /// Text payload (nullable for non-text messages).
  final String? text;

  /// Image URL/path payload (nullable for text messages).
  final String? imageUrl;

  const UIMessage({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.isOutgoing,
    this.text,
    this.imageUrl,
  });
}
