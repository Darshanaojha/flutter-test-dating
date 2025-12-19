import 'dart:ui';

import 'package:flutter/material.dart';

import '../../tokens/chat_tokens.dart';

/// Neon glass input bar with attach + send.
///
/// - Blur scales with [blurMultiplier] (suppression-aware).
/// - Glow scales with [glowMultiplier].
/// - Disables send when text is empty.
class NeonInputBar extends StatefulWidget {
  final ChatTokens tokens;
  final double blurMultiplier;
  final double glowMultiplier;
  final VoidCallback? onAttach;
  final ValueChanged<String>? onSend;
  final ValueChanged<String>? onChanged;

  const NeonInputBar({
    super.key,
    required this.tokens,
    this.blurMultiplier = 1.0,
    this.glowMultiplier = 1.0,
    this.onAttach,
    this.onSend,
    this.onChanged,
  });

  @override
  State<NeonInputBar> createState() => _NeonInputBarState();
}

class _NeonInputBarState extends State<NeonInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleText);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleText);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleText() {
    final String value = _controller.text;
    final bool next = value.trim().isNotEmpty;
    if (next != _hasText) {
      setState(() {
        _hasText = next;
      });
    }
    widget.onChanged?.call(value);
  }

  void _handleSend() {
    if (!_hasText) return;
    final String value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onSend?.call(value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final double padH = widget.tokens.spacing.l;
    final double padV = widget.tokens.spacing.s;

    final double blurSigma = ((widget.tokens.blur.microMin + widget.tokens.blur.microMax) / 2) *
        widget.blurMultiplier.clamp(0, 1);

    final double glowOpacity =
        ((widget.tokens.opacity.rimGlowIdleMin + widget.tokens.opacity.rimGlowIdleMax) / 2) *
            widget.glowMultiplier.clamp(0, 1);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(padH, padV, padH, widget.tokens.spacing.m),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.tokens.radius.inputBarMax),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.tokens.spacing.m,
                vertical: widget.tokens.spacing.s,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  (widget.tokens.opacity.microGlassOpacityMin +
                          widget.tokens.opacity.microGlassOpacityMax) /
                      2,
                ),
                borderRadius: BorderRadius.circular(widget.tokens.radius.inputBarMax),
                border: Border.all(
                  color: widget.tokens.colors.glassStroke,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.tokens.colors.glassStroke.withOpacity(glowOpacity),
                    blurRadius: widget.tokens.shadows.floatingBlur,
                    spreadRadius: 0,
                    offset: Offset(0, widget.tokens.shadows.floatingYOffset),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _GlassIconButton(
                    icon: Icons.attach_file,
                    onTap: widget.onAttach,
                    tokens: widget.tokens,
                    glowMultiplier: widget.glowMultiplier,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 24),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 4,
                        style: widget.tokens.typography.bubbleTextPrimary,
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GlassIconButton(
                    icon: Icons.send,
                    onTap: _hasText ? _handleSend : null,
                    tokens: widget.tokens,
                    glowMultiplier: _hasText ? widget.glowMultiplier : 0.0,
                    color: _hasText
                        ? widget.tokens.colors.outgoingBubbleStart
                        : widget.tokens.colors.glassStroke,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ChatTokens tokens;
  final double glowMultiplier;
  final Color? color;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    required this.tokens,
    required this.glowMultiplier,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final double glowOpacity =
        ((tokens.opacity.rimGlowIdleMin + tokens.opacity.rimGlowIdleMax) / 2) *
            glowMultiplier.clamp(0, 1);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            (tokens.opacity.microGlassOpacityMin + tokens.opacity.microGlassOpacityMax) / 2,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: tokens.colors.glassStroke,
          ),
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: (color ?? tokens.colors.glassStroke).withOpacity(glowOpacity),
                blurRadius: tokens.shadows.bubbleBlur,
                spreadRadius: 0,
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: (color ?? tokens.colors.textSecondary).withOpacity(enabled ? 1 : 0.5),
        ),
      ),
    );
  }
}
