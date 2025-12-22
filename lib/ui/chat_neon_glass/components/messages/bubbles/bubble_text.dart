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
    const TextStyle neonStyle = TextStyle(
      fontSize: 16,
      color: Color.fromRGBO(255, 255, 255, 0.92),
      fontWeight: FontWeight.w400,
      height: 1.25,
      shadows: [
        Shadow(
          blurRadius: 6,
          offset: Offset.zero,
          color: Color.fromRGBO(255, 255, 255, 0.55),
        ),
        Shadow(
          blurRadius: 12,
          offset: Offset.zero,
          color: Color.fromRGBO(255, 255, 255, 0.25),
        ),
      ],
    );

    if (status == UIMessageStatus.deleted) {
      return Text(
        'Message deleted',
        style: tokens.typography.bubbleDeletedText,
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
        textWidthBasis: TextWidthBasis.parent,
        textAlign: TextAlign.start,
      );
    }

    // For now images remain as placeholder text.
    final String display = isImagePlaceholder ? '[image]' : (text ?? '');

    if (status == UIMessageStatus.failed) {
      final TextStyle base = neonStyle;
      final Color c = base.color ?? Colors.white;
      return Text(
        display,
        style: base.copyWith(color: c.withOpacity(c.opacity * 0.88)),
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
        textWidthBasis: TextWidthBasis.parent,
        textAlign: TextAlign.start,
      );
    }

    return Text(
      display,
      style: neonStyle,
      softWrap: true,
      maxLines: null,
      overflow: TextOverflow.visible,
      textWidthBasis: TextWidthBasis.parent,
      textAlign: TextAlign.start,
    );
  }
}
