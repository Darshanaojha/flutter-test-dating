import '../adapters/ui_message.dart';

/// Base event for the chat UI state machine.
sealed class ChatEvent {
  const ChatEvent();
}

/// Emitted when scroll velocity changes and may enter fast/settle.
final class ChatScrollVelocityChanged extends ChatEvent {
  final double pixelsPerSecond;
  const ChatScrollVelocityChanged(this.pixelsPerSecond);
}

/// Emitted when the input mode changes (idle/typing).
final class ChatInputModeChanged extends ChatEvent {
  final bool isTyping;
  const ChatInputModeChanged({required this.isTyping});
}

/// Emitted when a message is received/added/updated from backend.
final class ChatMessageUpdated extends ChatEvent {
  final UIMessage message;
  const ChatMessageUpdated(this.message);
}

/// Emitted when user long-presses a message bubble.
final class ChatMessageActivated extends ChatEvent {
  final String? messageId;
  const ChatMessageActivated(this.messageId);
}
