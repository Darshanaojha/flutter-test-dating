import 'package:flutter/material.dart';

import '../../adapters/ui_message.dart';
import '../../state_machine/chat_events.dart';
import '../../state_machine/chat_state.dart';
import '../../state_machine/chat_state_machine.dart';
import '../../tokens/chat_tokens.dart';
import '../../utils/perf/scroll_velocity_tracker.dart';
import '../../controllers/neon_chat_controller.dart';
import '../../controllers/sound_hooks.dart';
import '../../controllers/haptics_hooks.dart';
import 'date_header.dart';
import 'message_grouping.dart';
import 'message_item_builder.dart';
import 'typing/typing_indicator.dart';

/// Message list shell with grouping and scroll velocity signaling.
class NeonMessageList extends StatefulWidget {
  final NeonChatController controller;
  final ChatTokens tokens;
  final ChatStateMachine stateMachine;
  final ScrollVelocityTracker velocityTracker;
  final ValueChanged<double> onScrollOffset;
  final ChatUiState uiState;
  final double timestampOpacityMultiplier;
  final void Function(UIMessage message)? onRetry;
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final double blurMultiplier;
  final double glowMultiplier;
  final bool isPeerTyping;
  final void Function(UIMessage message)? onBlockUser;
  final void Function(UIMessage message)? onReportUser;

  const NeonMessageList({
    super.key,
    required this.controller,
    required this.tokens,
    required this.stateMachine,
    required this.velocityTracker,
    required this.onScrollOffset,
    required this.uiState,
    required this.timestampOpacityMultiplier,
    this.onRetry,
    this.soundHooks,
    this.hapticsHooks,
    required this.blurMultiplier,
    required this.glowMultiplier,
    required this.isPeerTyping,
    this.onBlockUser,
    this.onReportUser,
  });

  @override
  State<NeonMessageList> createState() => _NeonMessageListState();
}

class _NeonMessageListState extends State<NeonMessageList> {
  final MessageGrouping _grouping = const MessageGrouping();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final double offset = _scrollController.position.pixels;
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UIMessage>>(
      stream: widget.controller.watchUiMessages(),
      builder: (context, snapshot) {
        final List<UIMessage> messages = snapshot.data ?? const <UIMessage>[];
        final Map<String, List<UIMessage>> grouped =
            _grouping.groupByDate(messages);
        final List<String> orderedKeys = grouped.keys.toList();
        final bool hasIncomingTail =
            messages.isNotEmpty && !messages.last.isOutgoing;
        final bool showTyping =
            widget.isPeerTyping && !hasIncomingTail;

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: widget.tokens.spacing.l,
            vertical: widget.tokens.spacing.m,
          ),
          itemCount: _countItems(grouped) + (showTyping ? 1 : 0),
          itemBuilder: (context, index) {
            return _buildItem(grouped, orderedKeys, index, showTyping);
          },
        );
      },
    );
  }

  int _countItems(Map<String, List<UIMessage>> grouped) {
    int count = 0;
    for (final entries in grouped.entries) {
      count += 1; // date header
      count += entries.value.length;
    }
    return count;
  }

  Widget _buildItem(
    Map<String, List<UIMessage>> grouped,
    List<String> keys,
    int index,
    bool showTyping,
  ) {
    int cursor = 0;
    for (final String key in keys) {
      final List<UIMessage> bucket = grouped[key]!;

      if (index == cursor) {
        // date header
        final DateTime date = bucket.first.timestamp;
        return DateHeader(date: date, tokens: widget.tokens);
      }
      cursor += 1;

      final int localIndex = index - cursor;
      if (localIndex < bucket.length) {
        final UIMessage msg = bucket[localIndex];
        return MessageItemBuilder(
          message: msg,
          tokens: widget.tokens,
          uiState: widget.uiState,
          timestampOpacityMultiplier: widget.timestampOpacityMultiplier,
          onRetry: widget.onRetry,
          soundHooks: widget.soundHooks,
          hapticsHooks: widget.hapticsHooks,
          blurMultiplier: widget.blurMultiplier,
          glowMultiplier: widget.glowMultiplier,
          onBlockUser: widget.onBlockUser,
          onReportUser: widget.onReportUser,
        );
      }
      cursor += bucket.length;
    }

    // Typing footer
    if (showTyping && index == cursor) {
      return Padding(
        padding: EdgeInsets.only(
          top: widget.tokens.spacing.s,
          left: widget.tokens.spacing.l,
          right: widget.tokens.spacing.l,
          bottom: widget.tokens.spacing.m,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TypingIndicator(
            tokens: widget.tokens,
            glowMultiplier: widget.glowMultiplier,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
