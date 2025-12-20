import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Controllers/controller.dart';
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
  final ValueChanged<String>? onChanged;
  final Controller legacyController;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final String peerId;
  final bool isBlocked;
  final Future<void> Function({
    required String message,
    required String receiverId,
    File? image,
  }) onSendMessage;
  final Future<XFile?> Function()? pickImageFromGallery;

  const NeonInputBar({
    super.key,
    required this.tokens,
    required this.legacyController,
    required this.messageController,
    required this.scrollController,
    required this.peerId,
    required this.isBlocked,
    required this.onSendMessage,
    this.pickImageFromGallery,
    this.blurMultiplier = 1.0,
    this.glowMultiplier = 1.0,
    this.onChanged,
  });

  @override
  State<NeonInputBar> createState() => _NeonInputBarState();
}

class _NeonInputBarState extends State<NeonInputBar> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _isFocused = false;
  XFile? selectedImage;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_handleText);
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    widget.messageController.removeListener(_handleText);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleText() {
    final String value = widget.messageController.text;
    final bool next = value.trim().isNotEmpty;
    if (next != _hasText) {
      setState(() {
        _hasText = next;
      });
    }
    widget.onChanged?.call(value);
  }

  void _handleFocus() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  Future<void> _handleSend() async {
    if (widget.isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have blocked this user')),
      );
      return;
    }
    if (_isSending) return;
    final String rawText = widget.messageController.text.trim();
    if (rawText.isEmpty && selectedImage == null) return;
    // Legacy API expects a non-empty message field; use a single space placeholder
    // when sending image-only to keep the existing encrypt/send pipeline intact.
    final String outboundText =
        rawText.isNotEmpty ? rawText : (selectedImage != null ? ' ' : '');

    final int beforeCount = widget.legacyController.messages.length;

    setState(() => _isSending = true);
    try {
      await widget
          .onSendMessage(
            message: outboundText,
            receiverId: widget.peerId,
            image: selectedImage != null ? File(selectedImage!.path) : null,
          )
          .timeout(const Duration(seconds: 35));

      await widget
          .legacyController
          .fetchChats(widget.peerId)
          .timeout(const Duration(seconds: 15));

      // If the backend hasn't surfaced the new message yet, do one short retry
      // before clearing UI (prevents "sent but nothing happened" feeling).
      if (widget.legacyController.messages.length == beforeCount) {
        await Future.delayed(const Duration(milliseconds: 650));
        await widget
            .legacyController
            .fetchChats(widget.peerId)
            .timeout(const Duration(seconds: 15));
      }

      final bool didAdd = widget.legacyController.messages.length > beforeCount;
      if (!didAdd) {
        // Keep input + preview so user can retry if send failed / not returned yet.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Send may still be processing. Try again.')),
        );
        return;
      }

      widget.messageController.clear();
      setState(() {
        selectedImage = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.scrollController.hasClients) return;
        final position = widget.scrollController.position;
        final double min = position.minScrollExtent;
        final double max = position.maxScrollExtent;
        widget.scrollController.jumpTo(max.clamp(min, max));
      });
    } catch (e) {
      // Don't clear input/preview; allow retry.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send. ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _handleAttach() async {
    if (widget.isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have blocked this user')),
      );
      return;
    }
    if (_isSending) return;
    final picker = widget.pickImageFromGallery;
    if (picker == null) return;
    final XFile? picked = await picker();
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        selectedImage = picked;
      });
    }
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              // When an attachment preview is shown, allow the input bar to grow
              // so the preview + row can fit without RenderFlex overflow.
              constraints: BoxConstraints(
                minHeight: 56,
                maxHeight: selectedImage != null ? 180 : 120,
              ),
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
                    color: Colors.white.withOpacity(_isFocused ? 0.20 : 0.05),
                    blurRadius: _isFocused ? 22 : 8,
                    spreadRadius: _isFocused ? 3 : 1,
                    offset: const Offset(0, -3),
                  ),
                  BoxShadow(
                    color: widget.tokens.colors.glassStroke.withOpacity(glowOpacity),
                    blurRadius: widget.tokens.shadows.floatingBlur,
                    spreadRadius: 0,
                    offset: Offset(0, widget.tokens.shadows.floatingYOffset),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double rowMinHeight = 56; // matches input bar minHeight
                  const double desiredPreview = 64;
                  const double previewGap = 6;

                  final double available = constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : (selectedImage != null ? 180 : 120);
                  final double maxPreview = (available - rowMinHeight - previewGap)
                      .clamp(0.0, desiredPreview);
                  final bool showPreview = selectedImage != null && maxPreview >= 36;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showPreview)
                        Padding(
                          padding: const EdgeInsets.only(bottom: previewGap),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(selectedImage!.path),
                                  height: maxPreview,
                                  width: maxPreview,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _isSending
                                      ? null
                                      : () => setState(() => selectedImage = null),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.45),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                children: [
                  _GlassIconButton(
                    icon: Icons.attach_file,
                            onTap: _isSending ? null : _handleAttach,
                    tokens: widget.tokens,
                    glowMultiplier: widget.glowMultiplier,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 24),
                      child: TextField(
                                controller: widget.messageController,
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
                  Material(
                    color: Colors.transparent,
                    child: InkResponse(
                              onTap: (_hasText || selectedImage != null)
                                  ? (_isSending ? null : _handleSend)
                                  : null,
                      borderRadius: BorderRadius.circular(40),
                      radius: 26,
                      splashColor: Colors.white.withOpacity(0.25),
                      highlightColor: Colors.transparent,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            (widget.tokens.opacity.microGlassOpacityMin +
                                            widget.tokens.opacity
                                                .microGlassOpacityMax) /
                                2,
                          ),
                          border: Border.all(
                            color: widget.tokens.colors.glassStroke,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.tokens.colors.glassStroke
                                          .withOpacity(
                                        (_hasText || selectedImage != null)
                                            ? widget.glowMultiplier * glowOpacity
                                            : 0.0,
                                      ),
                                      blurRadius:
                                          widget.tokens.shadows.floatingBlur,
                              spreadRadius: 0,
                                      offset: Offset(0,
                                          widget.tokens.shadows.floatingYOffset),
                            ),
                          ],
                        ),
                        child: Icon(
                                  _isSending ? Icons.hourglass_top : Icons.send,
                                  color: (_hasText || selectedImage != null)
                              ? widget.tokens.colors.outgoingBubbleStart
                              : widget.tokens.colors.glassStroke,
                        ),
                      ),
                    ),
                  ),
                ],
                      ),
                    ],
                  );
                },
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
