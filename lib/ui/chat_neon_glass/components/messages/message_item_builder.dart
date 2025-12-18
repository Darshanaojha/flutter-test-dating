import 'package:flutter/material.dart';

import '../../adapters/ui_message.dart';
import '../../tokens/chat_tokens.dart';
import 'bubbles/bubble_shell.dart';
import 'bubbles/bubble_text.dart';

/// Placeholder item builder for messages (no bubble visuals yet).
class MessageItemBuilder extends StatelessWidget {
  final UIMessage message;
  final ChatTokens tokens;

  const MessageItemBuilder({
    super.key,
    required this.message,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
      child: BubbleShell(
        message: message,
        tokens: tokens,
        child: Align(
          alignment:
              message.isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
          child: BubbleText(
            text: message.text,
            status: message.status,
            tokens: tokens,
            isImagePlaceholder: message.imageUrl != null && message.text == null,
          ),
        ),
      ),
    );
  }
}
