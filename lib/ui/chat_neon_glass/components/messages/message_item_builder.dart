import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../Models/ResponseModels/chat_history_response_model.dart';
import '../../tokens/chat_tokens.dart';
import 'bubbles/bubble_shell.dart';
import 'bubbles/bubble_media_thumb.dart';
import 'bubbles/bubble_text.dart';
import '../../state_machine/chat_state.dart';
import '../../adapters/ui_message_status.dart';
import '../../controllers/sound_hooks.dart';
import '../../controllers/haptics_hooks.dart';

class MessageItemBuilder extends StatefulWidget {
  final Message message;
  final String viewerId;
  final String bearerToken;
  final Future<void> Function(Message message)? onEdit;
  final Future<void> Function(Message message)? onDelete;
  final ChatTokens tokens;
  final ChatUiState uiState;
  final double timestampOpacityMultiplier;
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final double blurMultiplier;
  final double glowMultiplier;
  final double topPadding;
  final double scrollOffset;
  final bool showTimestamp;
  final bool sameSenderPrev;
  final bool sameSenderNext;

  const MessageItemBuilder({
    super.key,
    required this.message,
    required this.viewerId,
    required this.bearerToken,
    this.onEdit,
    this.onDelete,
    required this.tokens,
    required this.uiState,
    required this.timestampOpacityMultiplier,
    this.soundHooks,
    this.hapticsHooks,
    required this.blurMultiplier,
    required this.glowMultiplier,
    this.topPadding = 0,
    this.scrollOffset = 0,
    this.showTimestamp = true,
    this.sameSenderPrev = false,
    this.sameSenderNext = false,
  });

  @override
  State<MessageItemBuilder> createState() => _MessageItemBuilderState();
  }

class _MessageItemBuilderState extends State<MessageItemBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _appearController;
  late Animation<double> _fade;
  late Animation<double> _scale;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: widget.tokens.timing.fadeMediumMax,
    );
    _fade = CurvedAnimation(
      parent: _appearController,
      curve: widget.tokens.motion.fade,
    );
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: widget.tokens.motion.bubbleAppear,
      ),
    );
    _maybeAnimate();
  }

  @override
  void didUpdateWidget(covariant MessageItemBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id) {
      _hasAnimated = false;
      _maybeAnimate();
    }
  }

  void _maybeAnimate() {
    if (_hasAnimated) return;
    _appearController.forward();
    _hasAnimated = true;
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutgoing =
        widget.viewerId.isNotEmpty && widget.viewerId == widget.message.senderId;

    final UIMessageStatus status = _deriveStatus(
      status: widget.message.status,
      viewerId: widget.viewerId,
      senderId: widget.message.senderId,
      deletedBySender: widget.message.deletedBySender,
      deletedByReceiver: widget.message.deletedByReceiver,
    );
    final bool isFailed = status == UIMessageStatus.failed;
    final bool isDeleted = status == UIMessageStatus.deleted;

    final String? imagePath = widget.message.imagePath;
    final bool isImage = imagePath != null && imagePath.isNotEmpty;
    final double effectiveBlur = widget.uiState.scrollPhase == ChatScrollPhase.fast
        ? 0.0
        : widget.blurMultiplier;

    return Padding(
      padding: EdgeInsets.only(top: widget.topPadding, bottom: 0),
      child: GestureDetector(
        onLongPress: isOutgoing
            ? () => _showActions(context, widget.message)
            : null,
        child: AnimatedBuilder(
          animation: _appearController,
          builder: (context, child) {
            return Opacity(
              opacity: _fade.value,
              child: Transform.scale(
                scale: _scale.value,
                alignment: isOutgoing
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: child,
              ),
            );
          },
          child: BubbleShell(
            message: widget.message,
            messageId: widget.message.id ?? '',
            timestamp: _resolveTimestamp(widget.message),
            status: status,
            isOutgoing: isOutgoing,
            tokens: widget.tokens,
            uiState: widget.uiState,
            timestampOpacityMultiplier: widget.timestampOpacityMultiplier,
            soundHooks: widget.soundHooks,
            hapticsHooks: widget.hapticsHooks,
            scrollOffset: widget.scrollOffset,
            showTimestamp: widget.showTimestamp,
            sameSenderPrev: widget.sameSenderPrev,
            sameSenderNext: widget.sameSenderNext,
            child: Align(
              alignment: isOutgoing
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: isImage
                  ? BubbleMediaThumb(
                      imagePath: imagePath!,
                      bearerToken: widget.bearerToken,
                      sensitivity: widget.message.sensitivity ?? 'non-explicit',
                      tokens: widget.tokens,
                      isOutgoing: isOutgoing,
                      isFailed: isFailed,
                      isDeleted: isDeleted,
                      blurMultiplier: effectiveBlur,
                      messageId: widget.message.id,
                    )
                  : BubbleText(
                      text: widget.message.message,
                      status: status,
                      tokens: widget.tokens,
                      isImagePlaceholder: false,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, Message message) async {
    if (widget.onEdit == null && widget.onDelete == null) return;
    final bool hasImage =
        message.imagePath != null && message.imagePath!.isNotEmpty;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.35),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!hasImage)
                ListTile(
                        leading: const Icon(Icons.edit, color: Colors.white),
                        title: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                  onTap: () async {
                    Navigator.pop(context);
                    await widget.onEdit?.call(message);
                  },
                ),
              ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.white),
                      title: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                onTap: () async {
                  Navigator.pop(context);
                  await widget.onDelete?.call(message);
                },
              ),
            ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// STATUS MAPPING (same rules as neon adapter):
  /// 0=pending,1=sent,2=delivered,3=seen,4=failed; null->pending
  UIMessageStatus _mapStatusInt(int? status) {
    switch (status) {
      case 0:
        return UIMessageStatus.pending;
      case 1:
        return UIMessageStatus.sent;
      case 2:
        return UIMessageStatus.delivered;
      case 3:
        return UIMessageStatus.seen;
      case 4:
        return UIMessageStatus.failed;
      default:
        return UIMessageStatus.pending;
    }
  }

  UIMessageStatus _deriveStatus({
    required int status,
    required String viewerId,
    required String senderId,
    required int deletedBySender,
    required int deletedByReceiver,
  }) {
    final UIMessageStatus base = _mapStatusInt(status);
    final bool viewerIsSender = viewerId.isNotEmpty && viewerId == senderId;
    final bool deletedForViewer = viewerIsSender
        ? (deletedBySender != 0)
        : (deletedByReceiver != 0);

    if (!deletedForViewer) return base;
    if (base == UIMessageStatus.pending) return base;
    if (base == UIMessageStatus.failed) return base;
    return UIMessageStatus.deleted;
  }

  DateTime _resolveTimestamp(Message m) {
    DateTime? tryParseIso(String? s) {
      if (s == null) return null;
      final String v = s.trim();
      if (v.isEmpty) return null;
      try {
        final int? asInt = int.tryParse(v);
        if (asInt != null) {
          return DateTime.fromMillisecondsSinceEpoch(asInt);
        }
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }

    return tryParseIso(m.created) ??
        tryParseIso(m.timestamp) ??
        tryParseIso(m.updated) ??
        DateTime.now();
  }
}
