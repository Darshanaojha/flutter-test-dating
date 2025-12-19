import 'package:flutter/material.dart';

import '../../adapters/ui_message.dart';
import '../../tokens/chat_tokens.dart';
import 'bubbles/bubble_shell.dart';
import 'bubbles/bubble_media_thumb.dart';
import 'bubbles/bubble_text.dart';
import '../../state_machine/chat_state.dart';
import '../../adapters/ui_message_status.dart';
import '../../controllers/sound_hooks.dart';
import '../../controllers/haptics_hooks.dart';
import '../../controllers/neon_chat_controller.dart';

/// Placeholder item builder for messages (no bubble visuals yet).
class MessageItemBuilder extends StatelessWidget {
  final UIMessage message;
  final ChatTokens tokens;
  final ChatUiState uiState;
  final double timestampOpacityMultiplier;
  final void Function(UIMessage message)? onRetry;
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final double blurMultiplier;
  final double glowMultiplier;
  final void Function(UIMessage message)? onBlockUser;
  final void Function(UIMessage message)? onReportUser;

  const MessageItemBuilder({
    super.key,
    required this.message,
    required this.tokens,
    required this.uiState,
    required this.timestampOpacityMultiplier,
    this.onRetry,
    this.soundHooks,
    this.hapticsHooks,
    required this.blurMultiplier,
    required this.glowMultiplier,
    this.onBlockUser,
    this.onReportUser,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImage = message.imageUrl != null && message.text == null;
    final bool isFailed = message.status == UIMessageStatus.failed;
    final bool isDeleted = message.status == UIMessageStatus.deleted;
    final double effectiveBlur =
        uiState.scrollPhase == ChatScrollPhase.fast ? 0.0 : blurMultiplier;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
      child: BubbleShell(
        message: message,
        tokens: tokens,
        uiState: uiState,
        timestampOpacityMultiplier: timestampOpacityMultiplier,
        onRetry: onRetry,
        soundHooks: soundHooks,
        hapticsHooks: hapticsHooks,
        onBlockUser: onBlockUser,
        onReportUser: onReportUser,
        child: Align(
          alignment:
              message.isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
          child: isImage
              ? BubbleMediaThumb(
                  imageUrl: message.imageUrl!,
                  tokens: tokens,
                  isOutgoing: message.isOutgoing,
                  isFailed: isFailed,
                  isDeleted: isDeleted,
                  blurMultiplier: effectiveBlur,
                )
              : BubbleText(
                  text: message.text,
                  status: message.status,
                  tokens: tokens,
                  isImagePlaceholder: false,
                ),
        ),
      ),
    );
  }
}
