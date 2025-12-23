import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Controllers/controller.dart';
import '../../../../Models/RequestModels/delete_message_request_model.dart';
import '../../../../Models/RequestModels/edit_message_request_model.dart';
import '../../../../Models/ResponseModels/chat_history_response_model.dart';
import '../../controllers/haptics_hooks.dart';
import '../../controllers/sound_hooks.dart';
import '../../state_machine/chat_events.dart';
import '../../state_machine/chat_state.dart';
import '../../state_machine/chat_state_machine.dart';
import '../../tokens/chat_tokens.dart';
import '../../utils/perf/scroll_velocity_tracker.dart';
import 'message_item_builder.dart';
import '../../../../widgets/frosted_dialog.dart';

/// Message list shell that renders the legacy GetX message list.
///
/// IMPORTANT:
/// - No parallel message models/list sources.
/// - UI only: consumes [Controller.messages] and renders.
class NeonMessageList extends StatefulWidget {
  final Controller controller;
  final ScrollController scrollController;
  final String viewerId;
  final String bearerToken;
  // final String peerId;
  final String peerId;

  final ChatTokens tokens;
  final ChatStateMachine stateMachine;
  final ScrollVelocityTracker velocityTracker;
  final ValueChanged<double> onScrollOffset;
  final ChatUiState uiState;
  final double timestampOpacityMultiplier;
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final double blurMultiplier;
  final double glowMultiplier;
  final bool isPeerTyping;

  const NeonMessageList({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.viewerId,
    required this.bearerToken,
    required this.peerId,
    // required this.peerId,
    required this.tokens,
    required this.stateMachine,
    required this.velocityTracker,
    required this.onScrollOffset,
    required this.uiState,
    required this.timestampOpacityMultiplier,
    this.soundHooks,
    this.hapticsHooks,
    required this.blurMultiplier,
    required this.glowMultiplier,
    required this.isPeerTyping,
  });

  @override
  State<NeonMessageList> createState() => _NeonMessageListState();
}

class _NeonMessageListState extends State<NeonMessageList> {
  double _scrollOffsetPx = 0.0;
  Worker? _messagesWorker;
  int _lastMessageCount = 0;
  bool _suppressAutoScroll = false;

  @override
  void initState() {
    super.initState();
    _lastMessageCount = widget.controller.messages.length;
    widget.scrollController.addListener(_onScroll);
    _messagesWorker = ever(widget.controller.messages, (_) {
      final int newCount = widget.controller.messages.length;
      if (!_suppressAutoScroll && newCount > _lastMessageCount) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!widget.scrollController.hasClients) return;
          final position = widget.scrollController.position;
          final double min = position.minScrollExtent;
          final double max = position.maxScrollExtent;
          widget.scrollController.jumpTo(max.clamp(min, max));
        });
      }
      _lastMessageCount = newCount;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.scrollController.hasClients) return;
      final position = widget.scrollController.position;
      final double min = position.minScrollExtent;
      final double max = position.maxScrollExtent;
      widget.scrollController.jumpTo(max.clamp(min, max));
    });
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final double offset = widget.scrollController.position.pixels;
    _scrollOffsetPx = offset;
    final Duration now = Duration(
      microseconds: DateTime.now().microsecondsSinceEpoch,
    );
    widget.onScrollOffset(offset);
    widget.velocityTracker.onScrollOffset(
      offsetPixels: offset,
      timestamp: now,
    );
    widget.stateMachine.dispatch(
      ChatScrollVelocityChanged(widget.velocityTracker.pixelsPerSecond),
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _messagesWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;
    final double gap = MediaQuery.of(context).size.height * 0.006;
    final double bottomPad = math.max(12, (0.02 * h));

    return Obx(() {
      final List<Message> messages = List<Message>.from(
        widget.controller.messages.where((m) {
          final bool viewerIsSender =
              widget.viewerId.isNotEmpty && widget.viewerId == m.senderId;
          final bool deletedForViewer = viewerIsSender
              ? (m.deletedBySender != 0)
              : (m.deletedByReceiver != 0);
          if (deletedForViewer) return false;
          if (m.status == 4) return false; // server-side deleted/failed
          return true;
        }),
      )
        ..sort((a, b) {
          DateTime? pa = _tryParseDate(a.created ?? a.timestamp);
          DateTime? pb = _tryParseDate(b.created ?? b.timestamp);
          if (pa != null && pb != null) return pa.compareTo(pb);
          if (pa != null) return -1;
          if (pb != null) return 1;
          return (a.id ?? '').compareTo(b.id ?? '');
        });
      return ListView.builder(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(
          widget.tokens.spacing.l,
          widget.tokens.spacing.m,
          widget.tokens.spacing.l,
          bottomPad,
        ),
        itemCount: messages.length,
              itemBuilder: (context, index) {
          final Message msg = messages[index];
          final bool sameSenderPrev = index > 0 &&
              messages[index - 1].senderId == msg.senderId;
          final bool sameSenderNext = index + 1 < messages.length &&
              messages[index + 1].senderId == msg.senderId;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index > 0) SizedBox(height: gap),
              MessageItemBuilder(
            message: msg,
            viewerId: widget.viewerId,
            bearerToken: widget.bearerToken,
            tokens: widget.tokens,
            uiState: widget.uiState,
            timestampOpacityMultiplier: widget.timestampOpacityMultiplier,
            soundHooks: widget.soundHooks,
            hapticsHooks: widget.hapticsHooks,
            blurMultiplier: widget.blurMultiplier,
            glowMultiplier: widget.glowMultiplier,
            scrollOffset: _scrollOffsetPx % 2000.0,
            showTimestamp: true,
            sameSenderPrev: sameSenderPrev,
            sameSenderNext: sameSenderNext,
            onEdit: (m) => _editMessage(context, m),
            onDelete: (m) => _deleteMessage(context, m),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _editMessage(BuildContext context, Message message) async {
    if (message.id == null || message.id!.isEmpty) return;
    String? result;
    await showFrostedTextInputDialog(
      context: context,
      title: 'Edit message',
      hintText: 'Update message',
      initialValue: message.message ?? '',
      confirmText: 'Save',
      cancelText: 'Cancel',
      onConfirm: (editedText) {
        result = editedText.trim();
      },
    );
    if (result?.isEmpty ?? true) return;
    final String editedText = result!;

    final req = EditMessageRequest(
      message: editedText,
      messageId: message.id!,
      messageType: message.messageType.toString(),
    );
    _suppressAutoScroll = true;
    // Optimistically update the local list so UI reflects immediately.
    final int idx =
        widget.controller.messages.indexWhere((m) => m.id == message.id);
    if (idx != -1) {
      final Message updated = widget.controller.messages[idx].copyWith(
        message: editedText,
      );
      widget.controller.messages[idx] = updated;
      widget.controller.messages.refresh();
    }
    await widget.controller.editMessage(req);
    await widget.controller.fetchChats(widget.peerId);
    widget.controller.messages.refresh(); // force rebuild even if count unchanged
    _suppressAutoScroll = false;
  }

  Future<void> _deleteMessage(BuildContext context, Message message) async {
    if (message.id == null || message.id!.isEmpty) return;
    bool confirmed = false;
    await showFrostedDialog(
      context: context,
      title: 'Delete message?',
      message: 'This will permanently delete this message.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () async {
        confirmed = true;
      },
    );
    if (!confirmed) return;

    final req = DeleteMessageRequest(messageIds: [message.id!]);
    _suppressAutoScroll = true;
    final double? offsetBefore = widget.scrollController.hasClients
        ? widget.scrollController.position.pixels
        : null;
    // Optimistically mark deleted in-place to avoid reordering.
    final int idx =
        widget.controller.messages.indexWhere((m) => m.id == message.id);
    if (idx != -1) {
      final Message marked = widget.controller.messages[idx].copyWith(
        deletedBySender: 1,
        deletedByReceiver: 1,
        status: 4, // failed/deleted state
      );
      widget.controller.messages[idx] = marked;
      widget.controller.messages.refresh();
    }
    await widget.controller.deleteMessage(req);
    await widget.controller.fetchChats(widget.peerId);
    // Remove any messages flagged as deleted or status=4 (failed/deleted) for this viewer after fetch.
    widget.controller.messages.removeWhere((m) {
      final bool viewerIsSender =
          widget.viewerId.isNotEmpty && widget.viewerId == m.senderId;
      final bool deletedForViewer = viewerIsSender
          ? (m.deletedBySender != 0)
          : (m.deletedByReceiver != 0);
      return deletedForViewer || m.status == 4;
    });
    widget.controller.messages.refresh(); // force rebuild
    _suppressAutoScroll = false;
    if (offsetBefore != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.scrollController.hasClients) return;
        final position = widget.scrollController.position;
        final double min = position.minScrollExtent;
        final double max = position.maxScrollExtent;
        final double target = offsetBefore.clamp(min, max);
        widget.scrollController.jumpTo(target);
      });
    }
  }

  DateTime? _tryParseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
