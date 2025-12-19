import 'package:flutter/material.dart';

import '../../../adapters/ui_message.dart';
import '../../../state_machine/chat_state.dart';
import '../../../tokens/chat_tokens.dart';

class BubbleTimestamp extends StatefulWidget {
  final UIMessage message;
  final ChatTokens tokens;
  final ChatUiState uiState;
  final double opacityMultiplier; // suppression-aware

  const BubbleTimestamp({
    super.key,
    required this.message,
    required this.tokens,
    required this.uiState,
    required this.opacityMultiplier,
  });

  @override
  State<BubbleTimestamp> createState() => _BubbleTimestampState();
}

class _BubbleTimestampState extends State<BubbleTimestamp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _t;

  double _currentOpacity = 1.0;
  double _targetOpacity = 1.0;
  double _currentDrift = 0.0;
  double _targetDrift = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _fadeDuration(),
    );
    _t = CurvedAnimation(
      parent: _controller,
      curve: widget.tokens.motion.fade,
    )..addListener(_onTick);
    _recomputeTargets(firstBuild: true);
  }

  @override
  void didUpdateWidget(covariant BubbleTimestamp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uiState != widget.uiState ||
        oldWidget.opacityMultiplier != widget.opacityMultiplier ||
        oldWidget.tokens != widget.tokens) {
      _recomputeTargets(firstBuild: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recomputeTargets({required bool firstBuild}) {
    final _TimestampState state = _deriveState(widget.uiState, widget.message);
    final double baseOpacity = state.baseOpacity(widget.tokens);
    _targetOpacity = (baseOpacity * widget.opacityMultiplier).clamp(0, 1);
    _targetDrift = state == _TimestampState.active
        ? widget.tokens.spacing.timestampDriftPx
        : 0.0;

    if (firstBuild) {
      _currentOpacity = _targetOpacity;
      _currentDrift = _targetDrift;
      setState(() {});
      return;
    }

    _controller.reset();
    _controller.forward();
  }

  void _onTick() {
    final double k = _t.value;
    setState(() {
      _currentOpacity = _lerp(_currentOpacity, _targetOpacity, k);
      _currentDrift = _lerp(_currentDrift, _targetDrift, k);
    });
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  Duration _fadeDuration() {
    final Duration min = widget.tokens.timing.timestampFadeMin;
    final Duration max = widget.tokens.timing.timestampFadeMax;
    return Duration(
      milliseconds: ((min.inMilliseconds + max.inMilliseconds) / 2).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _currentOpacity,
      child: Transform.translate(
        offset: Offset(0, -_currentDrift),
        child: Text(
          _formatTime(widget.message.timestamp),
          style: widget.tokens.typography.bubbleTextSecondary ??
              TextStyle(
                fontSize: widget.tokens.typography.timestampFontSizeMax,
                color: widget.tokens.colors.textSecondary,
              ),
        ),
      ),
    );
  }

  _TimestampState _deriveState(ChatUiState state, UIMessage message) {
    if (state.activeMessageId != null && state.activeMessageId == message.id) {
      return _TimestampState.active;
    }
    if (state.scrollPhase == ChatScrollPhase.fast) {
      return _TimestampState.fast;
    }
    return _TimestampState.idle;
  }

  String _formatTime(DateTime ts) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(ts.hour)}:${two(ts.minute)}';
  }
}

enum _TimestampState { idle, active, fast }

extension on _TimestampState {
  double baseOpacity(ChatTokens tokens) {
    switch (this) {
      case _TimestampState.active:
        return tokens.opacity.timestampActiveRecommended;
      case _TimestampState.fast:
        return tokens.opacity.timestampScrollMinRecommended;
      case _TimestampState.idle:
      default:
        return tokens.opacity.timestampIdleRecommended;
    }
  }
}
