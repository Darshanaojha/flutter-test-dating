import 'package:flutter/material.dart';

import '../../../adapters/ui_message_status.dart';
import '../../../tokens/chat_tokens.dart';

/// Renders bubble text based on message status and content.
class BubbleText extends StatelessWidget {
  final String? text;
  final UIMessageStatus status;
  final ChatTokens tokens;
  final bool isImagePlaceholder;

  const BubbleText({
    super.key,
    required this.text,
    required this.status,
    required this.tokens,
    this.isImagePlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (status == UIMessageStatus.deleted) {
      return Text(
        'Message deleted',
        style: tokens.typography.bubbleDeletedText,
      );
    }

    // For now images remain as placeholder text.
    final String display = isImagePlaceholder ? '[image]' : (text ?? '');

    return Text(
      display,
      style: tokens.typography.bubbleTextPrimary,
    );
  }
}
