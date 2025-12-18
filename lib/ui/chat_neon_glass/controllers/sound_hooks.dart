import '../adapters/ui_message.dart';

/// Sound hooks for chat UI events.
///
/// IMPORTANT:
/// - Hooks only. Do not implement audio playback systems here.
/// - Do not add any audio-message/voice/video features.
abstract interface class ChatSoundHooks {
  void onMessageSent(UIMessage message);
  void onMessageReceived(UIMessage message);
  void onMessageSeen(UIMessage message);
  void onMessageFailed(UIMessage message);
  void onOpenChat();
}
