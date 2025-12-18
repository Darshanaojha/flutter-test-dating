import '../adapters/ui_message.dart';

/// Haptic hooks for chat UI events.
///
/// IMPORTANT:
/// - Hooks only. Keep implementation minimal and UI-triggered.
/// - Do not add audio/video/voice features.
abstract interface class ChatHapticsHooks {
  void onSendMessage(UIMessage message);
  void onReceiveMessage(UIMessage message);
  void onLongPressMessage(UIMessage message);
  void onScrollBounce();
}
