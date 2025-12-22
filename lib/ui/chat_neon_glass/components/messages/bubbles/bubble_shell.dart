import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../Models/ResponseModels/chat_history_response_model.dart';
import '../../../adapters/ui_message_status.dart';
import '../../../controllers/haptics_hooks.dart';
import '../../../controllers/sound_hooks.dart';
import '../../../state_machine/chat_state.dart';
import '../../../tokens/chat_tokens.dart';
import '../../../utils/render/neon_glow_paint.dart';

/// Bubble shell with rim, glass, text, timestamp, and retry affordance.
class BubbleShell extends StatefulWidget {
  final Message message;
  final String messageId;
  final DateTime timestamp;
  final UIMessageStatus status;
  final bool isOutgoing;
  final ChatTokens tokens;
  final Widget child;
  final double glowMultiplier; // suppression-aware multiplier
  final ChatUiState uiState;
  final double timestampOpacityMultiplier;
  final void Function(Message message)? onRetry;
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final double blurMultiplier; // for media thumb / content if needed
  final void Function(Message message)? onBlockUser;
  final void Function(Message message)? onReportUser;
  final double scrollOffset;
  final bool showTimestamp;
  final bool sameSenderPrev;
  final bool sameSenderNext;

  const BubbleShell({
    super.key,
    required this.message,
    required this.messageId,
    required this.timestamp,
    required this.status,
    required this.isOutgoing,
    required this.tokens,
    required this.child,
    this.glowMultiplier = 1.0,
    required this.uiState,
    required this.timestampOpacityMultiplier,
    this.onRetry,
    this.soundHooks,
    this.hapticsHooks,
    this.blurMultiplier = 1.0,
    this.onBlockUser,
    this.onReportUser,
    this.scrollOffset = 0,
    this.showTimestamp = true,
    this.sameSenderPrev = false,
    this.sameSenderNext = false,
  });

  @override
  State<BubbleShell> createState() => _BubbleShellState();
}

class _BubbleShellState extends State<BubbleShell> with TickerProviderStateMixin {
  late AnimationController _rimController;
  late Animation<double> _rimAnim;

  double _currentRimOpacity = 0;
  double _targetRimOpacity = 0;
  double _currentRimRadius = 0;
  double _targetRimRadius = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  double _pulseOpacityBoost = 0;
  double _pulseRadiusBoost = 0;

  late AnimationController _rippleController;
  late Animation<double> _rippleAnim;
  Color? _rippleColor;
  double _rippleProgress = 0.0;
  double _rippleOpacityBase = 0.0;

  UIMessageStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _rimController = AnimationController(
      vsync: this,
      duration: _rimDuration(),
    );
    _rimAnim = CurvedAnimation(
      parent: _rimController,
      curve: widget.tokens.motion.fade,
    )..addListener(_onRimTick);

    _pulseController = AnimationController(
      vsync: this,
      duration: widget.tokens.timing.deliveredPulse,
    );
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: widget.tokens.motion.sendRipple,
    )..addListener(_onPulseTick);

    _rippleController = AnimationController(
      vsync: this,
      duration: widget.tokens.timing.sendRipple,
    );
    _rippleAnim = CurvedAnimation(
      parent: _rippleController,
      curve: widget.tokens.motion.sendRipple,
    )..addListener(_onRippleTick);

    _recomputeRimTargets(first: true);
    _lastStatus = widget.status;
  }

  @override
  void didUpdateWidget(covariant BubbleShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uiState != widget.uiState ||
        oldWidget.glowMultiplier != widget.glowMultiplier ||
        oldWidget.status != widget.status ||
        oldWidget.isOutgoing != widget.isOutgoing) {
      _recomputeRimTargets(first: false);
    }

    if (_shouldPulse(_lastStatus, widget.status)) {
      _startPulse();
    }

    if (_shouldRipple(_lastStatus, widget.status)) {
      _startRipple(forRetry: _lastStatus == UIMessageStatus.failed);
    }

    if (_shouldSoundHook(_lastStatus, widget.status)) {
      _fireSoundHook(_lastStatus, widget.status);
    }
    if (_shouldHapticHook(_lastStatus, widget.status)) {
      _fireHapticHook(_lastStatus, widget.status);
    }

    _lastStatus = widget.status;
  }

  @override
  void dispose() {
    _rimController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _recomputeRimTargets({required bool first}) {
    final _RimState state = _deriveRimState(widget.uiState);
    final double baseOpacity = (widget.tokens.opacity.rimGlowActiveMin +
            widget.tokens.opacity.rimGlowActiveMax) /
        2;

    final double deletedMultiplier = state.isDeleted ? 0.0 : (state.deletedOpacityMul ?? 1.0);
    final double suppression = widget.glowMultiplier.clamp(0, 1);
    _targetRimOpacity = baseOpacity * suppression * deletedMultiplier;

    final double idleRadius = widget.tokens.glow.rimRadiusMin;
    final double activeRadius = widget.tokens.glow.activeRimRadiusMax;
    final double fastRadius = widget.tokens.glow.rimRadiusMin;
    _targetRimRadius = state.isDeleted
        ? idleRadius
        : state.mode == _RimMode.active
            ? activeRadius
            : state.mode == _RimMode.fast
                ? fastRadius
                : idleRadius;

    if (first) {
      _currentRimOpacity = _targetRimOpacity;
      _currentRimRadius = _targetRimRadius;
      setState(() {});
      return;
    }

    _rimController.reset();
    _rimController.forward();
  }

  void _onRimTick() {
    final double k = _rimAnim.value;
    setState(() {
      _currentRimOpacity = _lerp(_currentRimOpacity, _targetRimOpacity, k);
      _currentRimRadius = _lerp(_currentRimRadius, _targetRimRadius, k);
    });
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  void _startPulse() {
    if (widget.glowMultiplier <= 0) return;
    _pulseController.stop();
    _pulseController.reset();
    _pulseController.forward();
  }

  void _onPulseTick() {
    final double k = _pulseAnim.value;
    // Use small boosts to avoid overshoot.
    _pulseOpacityBoost = 0.4 * (1.0 - (k - 1).abs()); // peak near mid
    _pulseRadiusBoost = 0.15 * (1.0 - (k - 1).abs());
    setState(() {});
  }

  Duration _rimDuration() {
    final Duration min = widget.tokens.timing.timestampFadeMin;
    final Duration max = widget.tokens.timing.timestampFadeMax;
    return Duration(
      milliseconds: ((min.inMilliseconds + max.inMilliseconds) / 2).round(),
    );
  }

  void _startRipple({required bool forRetry}) {
    if (widget.glowMultiplier <= 0) return;
    if (widget.status == UIMessageStatus.deleted) return;
    _rippleColor = forRetry
        ? widget.tokens.colors.failedBubbleRim
        : (widget.isOutgoing
            ? widget.tokens.colors.outgoingBubbleStart
            : widget.tokens.colors.incomingBubbleStart);
    final double baseOpacity = (widget.tokens.opacity.rimGlowActiveMin +
            widget.tokens.opacity.rimGlowActiveMax) /
        2;
    _rippleOpacityBase = baseOpacity * widget.glowMultiplier;
    if (_rippleOpacityBase <= 0) return;
    _rippleController.stop();
    _rippleController.reset();
    _rippleController.forward();
  }

  void _onRippleTick() {
    _rippleProgress = _rippleAnim.value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutgoing = widget.isOutgoing;
    final bool isDeleted = widget.status == UIMessageStatus.deleted;
    final bool isFailed = widget.status == UIMessageStatus.failed;

    final double bubbleOpacityBase = (widget.tokens.opacity.bubbleBackgroundMin +
            widget.tokens.opacity.bubbleBackgroundMax) /
        2;
    final double bubbleOpacity =
        isDeleted ? widget.tokens.opacity.bubbleBackgroundMin : bubbleOpacityBase;

    // Padding using midpoints.
    final double padV = (widget.tokens.spacing.bubblePaddingVMin +
            widget.tokens.spacing.bubblePaddingVMax) /
        2;
    final double padH = (widget.tokens.spacing.bubblePaddingHMin +
            widget.tokens.spacing.bubblePaddingHMax) /
        2;

    // Max width: use the stricter (min) fraction to avoid overly wide bubbles.
    final double maxFraction = widget.tokens.spacing.bubbleMaxWidthFractionMin;

    final double blurMid =
        (widget.tokens.blur.microMin + widget.tokens.blur.microMax) / 2;
    final double blurReduction =
        widget.tokens.blur.microMin / widget.tokens.blur.microMax;
    final double blurSigma =
        isDeleted ? blurMid * blurReduction : blurMid;

    // Rim color selection precedence: deleted -> failed -> outgoing -> incoming
    final Color rimColor = isDeleted
        ? widget.tokens.colors.incomingBubbleStart
        : isFailed
            ? widget.tokens.colors.failedBubbleRim
            : isOutgoing
                ? widget.tokens.colors.outgoingBubbleStart
                : widget.tokens.colors.incomingBubbleStart;

    final bool showSentTick = isOutgoing;

    final double finalRimOpacity = _currentRimOpacity;
    final double finalRimRadius = _currentRimRadius;

    final NeonGlowPaintHelper glowHelper = const DefaultNeonGlowPaintHelper();
    final double rawOffset = widget.scrollOffset * 0.015;
    final double dx = (isOutgoing ? rawOffset : -rawOffset).clamp(-8.0, 8.0);
    final double dy = (-rawOffset).clamp(-12.0, 12.0);

    final double baseRadius = widget.tokens.radius.bubbleMax;
    final double tightRadius = baseRadius * 0.6;

    BorderRadius _groupedRadius() {
      if (widget.sameSenderPrev && widget.sameSenderNext) {
        // middle
        return BorderRadius.only(
          topLeft: Radius.circular(baseRadius * 0.75),
          topRight: Radius.circular(baseRadius * 0.75),
          bottomLeft: Radius.circular(baseRadius * 0.75),
          bottomRight: Radius.circular(baseRadius * 0.75),
        );
      }
      if (!widget.sameSenderPrev && widget.sameSenderNext) {
        // first
        return BorderRadius.only(
          topLeft: Radius.circular(baseRadius),
          topRight: Radius.circular(baseRadius),
          bottomLeft: Radius.circular(baseRadius * 0.85),
          bottomRight: Radius.circular(isOutgoing ? tightRadius : baseRadius * 0.85),
        );
      }
      if (widget.sameSenderPrev && !widget.sameSenderNext) {
        // last
        return BorderRadius.only(
          topLeft: Radius.circular(baseRadius * 0.85),
          topRight: Radius.circular(isOutgoing ? tightRadius : baseRadius * 0.85),
          bottomLeft: Radius.circular(baseRadius),
          bottomRight: Radius.circular(baseRadius),
        );
      }
      return BorderRadius.circular(baseRadius);
    }

    final BorderRadius radius = _groupedRadius();

    final double blurSigmaScaled =
        (blurSigma * 1.25) * widget.blurMultiplier.clamp(0.65, 1.3);
    final double screenWidth = MediaQuery.of(context).size.width;

    final bool isImage = widget.message.imagePath != null &&
        (widget.message.imagePath?.isNotEmpty ?? false);

    double _estimateTextWidth() {
      final String text =
          widget.message.message?.trim().isNotEmpty == true ? widget.message.message!.trim() : ' ';
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            height: 1.25,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: screenWidth);
      return tp.size.width;
    }

    double _resolveMaxWidth() {
      final double cap = screenWidth * 0.82;
      if (isImage) return cap;
      // account for text width + padding + timestamp/tick row
      final double estimated = _estimateTextWidth() + 5 + 5 + 20;
      final double min = 120;
      return estimated.clamp(min, cap);
    }

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // max width scales with text length but capped for readability
            maxWidth: _resolveMaxWidth(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: rimColor.withOpacity(0.55 * widget.glowMultiplier),
                        blurRadius: 24,
                        spreadRadius: 3.5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: blurSigmaScaled,
                        sigmaY: blurSigmaScaled,
                      ),
                      child: CustomPaint(
                        painter: _RimPainter(
                          color: rimColor,
                          opacity: finalRimOpacity,
                          glowHelper: glowHelper,
                          radius: widget.tokens.radius.bubbleMax * 1.05,
                          rimSize: finalRimRadius * 1.1,
                          pulseOpacityBoost: _pulseOpacityBoost,
                          pulseRadiusBoost: _pulseRadiusBoost,
                          rippleColor: _rippleColor,
                          rippleProgress: _rippleProgress,
                          rippleOpacityBase: _rippleOpacityBase,
                          rippleSuppression: widget.glowMultiplier,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                        decoration: BoxDecoration(
                          borderRadius: radius,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: isOutgoing
                                  ? const [
                                      Color(0xFFff4dd2),
                                      Color(0xFFa32bff),
                                    ]
                                  : const [
                                      Color(0xFF4d9bff),
                                      Color(0xFF6c2bff),
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isOutgoing
                                        ? Colors.pinkAccent.withOpacity(0.4)
                                        : Colors.blueAccent.withOpacity(0.35)),
                                blurRadius: 22,
                                spreadRadius: -4,
                                offset: const Offset(0, 0),
                              ),
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.22 * widget.blurMultiplier),
                                blurRadius: widget.tokens.shadows.bubbleBlur * 1.3,
                                offset: Offset(0, widget.tokens.shadows.bubbleYOffset),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 18,
                                spreadRadius: -3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.26 * widget.blurMultiplier),
                                  blurRadius: 12 * widget.blurMultiplier,
                                  spreadRadius: -4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: isOutgoing
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Opacity(
                                      opacity: isDeleted ? 0.6 : 1.0,
                                      child: widget.child,
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      mainAxisAlignment: isOutgoing
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (widget.showTimestamp) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6, bottom: 2),
                                            child: Text(
                                              _formatTime(widget.timestamp),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                height: 1.1,
                                                color: Colors.white70,
                                              ).copyWith(
                                                color:
                                                    Colors.white.withOpacity(0.75),
                                              ),
                                            ),
                                          ),
                                          if (showSentTick) ...[
                                            const SizedBox(width: 4),
                                            _StatusTick(status: widget.status),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                if (isFailed && !isDeleted && widget.onRetry != null)
                                  Positioned(
                                    left: (widget.tokens.spacing.timestampPaddingFromEdgeMin +
                                            widget.tokens.spacing.timestampPaddingFromEdgeMax) /
                                        2,
                                    bottom: (widget.tokens.spacing.timestampPaddingFromEdgeMin +
                                            widget.tokens.spacing.timestampPaddingFromEdgeMax) /
                                        2,
                                    child: _RetryButton(
                                      color: widget.tokens.colors.failedBubbleRim,
                                      onTap: () {
                                        if (widget.status == UIMessageStatus.failed) {
                                          widget.onRetry?.call(widget.message);
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime ts) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(ts.hour)}:${two(ts.minute)}';
  }

  _RimState _deriveRimState(ChatUiState state) {
    final bool isDeleted = widget.status == UIMessageStatus.deleted;
    if (isDeleted) {
      return const _RimState(mode: _RimMode.idle, isDeleted: true, deletedOpacityMul: 0.0);
    }
    if (state.activeMessageId != null && state.activeMessageId == widget.messageId) {
      return const _RimState(mode: _RimMode.active, isDeleted: false, deletedOpacityMul: 1.0);
    }
    if (state.scrollPhase == ChatScrollPhase.fast) {
      return const _RimState(mode: _RimMode.fast, isDeleted: false, deletedOpacityMul: 1.0);
    }
    return const _RimState(mode: _RimMode.idle, isDeleted: false, deletedOpacityMul: 1.0);
  }

  bool _shouldRipple(UIMessageStatus? prev, UIMessageStatus next) {
    if (widget.glowMultiplier <= 0) return false;
    if (widget.status == UIMessageStatus.deleted) return false;
    if (prev == null) return false;
    if (prev == next) return false;
    // Send ripple on pending->sent; retry ripple on failed->pending.
    if (prev == UIMessageStatus.pending && next == UIMessageStatus.sent) {
      return true;
    }
    if (prev == UIMessageStatus.failed && next == UIMessageStatus.pending) {
      return true;
    }
    return false;
  }

  bool _shouldSoundHook(UIMessageStatus? prev, UIMessageStatus next) {
    if (widget.status == UIMessageStatus.deleted) return false;
    if (prev == null || prev == next) return false;
    return true;
  }

  bool _shouldHapticHook(UIMessageStatus? prev, UIMessageStatus next) {
    if (widget.status == UIMessageStatus.deleted) return false;
    if (prev == null || prev == next) return false;
    return true;
  }

  void _fireSoundHook(UIMessageStatus? prev, UIMessageStatus next) {
    final hooks = widget.soundHooks;
    if (hooks == null) return;
    // This bubble is now driven by the legacy backend `Message` model.
    // Sound hooks in this neon layer currently accept `UIMessage`, so we no-op
    // here to avoid introducing any parallel UI message models.
  }

  void _fireHapticHook(UIMessageStatus? prev, UIMessageStatus next) {
    final hooks = widget.hapticsHooks;
    if (hooks == null) return;
    // See comment in `_fireSoundHook` – no-op (no parallel UI message models).
  }

  bool _shouldPulse(UIMessageStatus? prev, UIMessageStatus next) {
    if (widget.glowMultiplier <= 0) return false;
    if (widget.status == UIMessageStatus.failed ||
        widget.status == UIMessageStatus.deleted) {
      return false;
    }
    if (prev == null) return false;
    if (prev == next) return false;
    // Pulse on delivery transitions.
    final transitions = <UIMessageStatus, Set<UIMessageStatus>>{
      UIMessageStatus.pending: {UIMessageStatus.sent},
      UIMessageStatus.sent: {UIMessageStatus.delivered},
      UIMessageStatus.delivered: {UIMessageStatus.seen},
    };
    return transitions[prev]?.contains(next) ?? false;
  }

  Future<void> _showContextMenu(BuildContext context) async {
    if (widget.onBlockUser == null && widget.onReportUser == null) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final RelativeRect rect = RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + box.size.width,
      position.dy + box.size.height,
    );

    final selection = await showMenu<String>(
      context: context,
      position: rect,
      items: [
        if (widget.onBlockUser != null)
          const PopupMenuItem<String>(
            value: 'block',
            child: Text('Block User'),
          ),
        if (widget.onReportUser != null)
          const PopupMenuItem<String>(
            value: 'report',
            child: Text('Report User'),
          ),
      ],
    );

    if (selection == 'block') {
      widget.onBlockUser?.call(widget.message);
    } else if (selection == 'report') {
      widget.onReportUser?.call(widget.message);
    }
  }
}

class _StatusTick extends StatelessWidget {
  final UIMessageStatus status;
  const _StatusTick({required this.status});

  @override
  Widget build(BuildContext context) {
    final IconData? icon = switch (status) {
      // User preference: show a tick even while pending (instead of a clock/watch).
      UIMessageStatus.pending => Icons.check,
      UIMessageStatus.sent => Icons.check,
      UIMessageStatus.delivered => Icons.done_all,
      UIMessageStatus.seen => Icons.done_all,
      UIMessageStatus.failed => Icons.error_outline,
      UIMessageStatus.deleted => null,
    };

    if (icon == null) return const SizedBox.shrink();

    final Color c = switch (status) {
      UIMessageStatus.seen => Colors.lightBlueAccent.withOpacity(0.9),
      UIMessageStatus.failed => Colors.redAccent.withOpacity(0.9),
      UIMessageStatus.pending => Colors.white70.withOpacity(0.65),
      _ => Colors.white70,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        icon,
        key: ValueKey<String>('tick_${status.name}'),
        size: 10,
        color: c,
      ),
    );
  }
}

class _RimPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final NeonGlowPaintHelper glowHelper;
  final double radius;
  final double rimSize;
  final double pulseOpacityBoost;
  final double pulseRadiusBoost;
  final Color? rippleColor;
  final double rippleProgress;
  final double rippleOpacityBase;
  final double rippleSuppression;

  const _RimPainter({
    required this.color,
    required this.opacity,
    required this.glowHelper,
    required this.radius,
    required this.rimSize,
    required this.pulseOpacityBoost,
    required this.pulseRadiusBoost,
    required this.rippleColor,
    required this.rippleProgress,
    required this.rippleOpacityBase,
    required this.rippleSuppression,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final double deflate = (rimSize / 8).clamp(0.5, 6.0);

    final double boostedOpacity = (opacity * (1.0 + pulseOpacityBoost)).clamp(0, 1);

    final Paint stroke = glowHelper.rimStrokePaint(color, boostedOpacity * 1.1);
    canvas.drawRRect(rrect.deflate(deflate * 0.6), stroke);

    final Paint glow = glowHelper.rimGlowPaint(color, opacity);
    final double pulseDeflate = deflate / (1.0 + pulseRadiusBoost).clamp(1.0, 1.5);
    canvas.drawRRect(rrect.deflate(pulseDeflate), glow);

    // Ripple overlay
    if (rippleColor != null && rippleProgress > 0 && rippleSuppression > 0) {
      final double rp = rippleProgress.clamp(0, 1);
      final double maxRadius = (size.shortestSide * 0.8).clamp(0, size.shortestSide);
      final double radiusRipple = maxRadius * rp;
      final double rippleOpacity =
          (rippleOpacityBase * (1 - rp) * rippleSuppression).clamp(0, 1);
      final Paint ripplePaint = Paint()
        ..color = rippleColor!.withOpacity(rippleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(size.center(Offset.zero), radiusRipple, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RimPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.rimSize != rimSize ||
        oldDelegate.pulseOpacityBoost != pulseOpacityBoost ||
        oldDelegate.pulseRadiusBoost != pulseRadiusBoost ||
        oldDelegate.rippleColor != rippleColor ||
        oldDelegate.rippleProgress != rippleProgress ||
        oldDelegate.rippleOpacityBase != rippleOpacityBase ||
        oldDelegate.rippleSuppression != rippleSuppression;
  }
}

class _RetryButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _RetryButton({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Icon(
              Icons.refresh,
              size: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

enum _RimMode { idle, active, fast }

class _RimState {
  final _RimMode mode;
  final bool isDeleted;
  final double? deletedOpacityMul;
  const _RimState({
    required this.mode,
    required this.isDeleted,
    required this.deletedOpacityMul,
  });
}
