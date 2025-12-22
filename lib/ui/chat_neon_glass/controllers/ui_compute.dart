import '../adapters/ui_message.dart';

/// Pure UI-side computations derived from [UIMessage] data.
///
/// IMPORTANT:
/// - No implementations here yet (signatures only).
/// - Must not call backend/APIs.
abstract interface class ChatUiCompute {
  List<UIMessage> sortByTimestamp(List<UIMessage> messages);

  /// Groups messages for rendering (e.g., date groups).
  Object groupForList(List<UIMessage> messages);
}
