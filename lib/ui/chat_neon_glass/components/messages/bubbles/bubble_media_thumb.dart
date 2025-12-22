import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dating_application/constants.dart';
import '../../../tokens/chat_tokens.dart';
import '../../media_viewer_fullscreen.dart';

/// Glass-styled media thumbnail for image bubbles.
class BubbleMediaThumb extends StatelessWidget {
  final String imagePath;
  final String bearerToken;
  final String sensitivity;
  final ChatTokens tokens;
  final bool isOutgoing;
  final bool isFailed;
  final bool isDeleted;
  final double blurMultiplier; // typically 0..1 based on fast scroll suppression
  final String? messageId; // For unique Hero tag

  const BubbleMediaThumb({
    super.key,
    required this.imagePath,
    required this.bearerToken,
    required this.sensitivity,
    required this.tokens,
    required this.isOutgoing,
    required this.isFailed,
    required this.isDeleted,
    required this.blurMultiplier,
    this.messageId,
  });

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double maxWidth = screen.width * 0.75;
    final double maxHeight = screen.height * 0.35;
    const double minWidth = 120;

    // Default aspect ratio 4:5 until image loads.
    const double fallbackAspect = 4 / 5;

    final double glassOpacity =
        (tokens.opacity.bubbleBackgroundMin + tokens.opacity.bubbleBackgroundMax) / 2;
    final double blurSigma =
        ((tokens.blur.microMin + tokens.blur.microMax) / 2) * blurMultiplier.clamp(0, 1);

    final Gradient tint = _tintGradient();

    final bool isSensitive = sensitivity.trim() != 'non-explicit';

    // Image bubbles are edge-to-edge, no padding
    // BubbleShell handles alignment and max width constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available width from parent (BubbleShell provides max 70% screen width)
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;
        
        // Calculate height based on aspect ratio, respecting max height
        final double imageHeight = min(
          availableHeight > 0 ? availableHeight : maxHeight,
          availableWidth / fallbackAspect,
        );
        
        return SizedBox(
          width: availableWidth,
          height: imageHeight,
          child: Stack(
            children: [
              // Backdrop blur layer
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white.withOpacity(glassOpacity),
                ),
              ),
              // Image content
              _SensitiveImageThumb(
                imagePath: imagePath,
                bearerToken: bearerToken,
                sensitivity: sensitivity,
                tokens: tokens,
                isDeleted: isDeleted,
                heroTag: messageId != null 
                    ? 'image_hero_${messageId}_${imagePath.hashCode}'
                    : 'image_hero_${imagePath.hashCode}',
                onOpen: (bytes, heroTag) => _openFullscreen(
                  context: context,
                  mediaUrl: imagePath,
                  isSensitive: isSensitive,
                  bytes: bytes,
                  heroTag: heroTag,
                ),
              ),
              // Gradient tint overlay
              if (!isDeleted)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(gradient: tint),
                    ),
                  ),
                ),
              // Deleted overlay
              if (isDeleted)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Gradient _tintGradient() {
    if (isFailed) {
      return LinearGradient(
        colors: [
          tokens.colors.failedBubbleRim.withOpacity(0.22),
          tokens.colors.failedBubbleInner.withOpacity(0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (isOutgoing) {
      return LinearGradient(
        colors: [
          tokens.colors.outgoingBubbleStart.withOpacity(0.18),
          tokens.colors.outgoingBubbleEnd.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [
        tokens.colors.incomingBubbleStart.withOpacity(0.18),
        tokens.colors.incomingBubbleEnd.withOpacity(0.10),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Future<void> _openFullscreen({
    required BuildContext context,
    required String mediaUrl,
    required bool isSensitive,
    required Uint8List bytes,
    required String heroTag,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaViewerFullscreen(
          mediaUrl: mediaUrl,
          isSensitive: isSensitive,
          initialBytes: bytes,
          heroTag: heroTag,
        ),
      ),
    );
  }
}

class _SensitiveImageThumb extends StatefulWidget {
  final String imagePath;
  final String bearerToken;
  final String sensitivity;
  final ChatTokens tokens;
  final bool isDeleted;
  final String heroTag;
  final void Function(Uint8List bytes, String heroTag) onOpen;

  const _SensitiveImageThumb({
    required this.imagePath,
    required this.bearerToken,
    required this.sensitivity,
    required this.tokens,
    required this.isDeleted,
    required this.heroTag,
    required this.onOpen,
  });

  @override
  State<_SensitiveImageThumb> createState() => _SensitiveImageThumbState();
}

class _SensitiveImageThumbState extends State<_SensitiveImageThumb> {
  bool _showBlur = true;
  late Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = _fetchBytes(widget.imagePath, widget.bearerToken);
  }

  @override
  void didUpdateWidget(covariant _SensitiveImageThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.bearerToken != widget.bearerToken) {
      _bytesFuture = _fetchBytes(widget.imagePath, widget.bearerToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _LoadingPlaceholder(tokens: widget.tokens);
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _FailurePlaceholder(tokens: widget.tokens);
        }

        final Uint8List bytes = snapshot.data!;
        final Widget baseImage = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );

        // Wrap image in Hero for smooth animation
        final Widget heroImage = Hero(
          tag: widget.heroTag,
          child: Material(
            color: Colors.transparent,
            child: baseImage,
          ),
        );

        final bool isSensitive = widget.sensitivity.trim() != 'non-explicit';
        final bool shouldObscure = isSensitive && _showBlur;

        if (shouldObscure) {
          return GestureDetector(
            onTap: () => setState(() => _showBlur = false),
            child: Stack(
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: heroImage,
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.10),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.60),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'View sensitive content',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: widget.isDeleted
              ? null
              : () => widget.onOpen(bytes, widget.heroTag),
          child: heroImage,
        );
      },
    );
  }

  Future<Uint8List> _fetchBytes(String imagePath, String bearerToken) async {
    // If imagePath is already a URL, try direct load without auth.
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      final http.Response resp = await http.get(Uri.parse(imagePath));
      if (resp.statusCode == 200) return resp.bodyBytes;
      throw Exception('Failed to load image');
    }

    final http.Response response = await http.get(
      Uri.parse('$springbooturl/ChatController/uploads/$imagePath'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }
    // Backend returns base64 string.
    return base64Decode(response.body);
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final ChatTokens tokens;
  const _LoadingPlaceholder({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tokens.colors.glassFill,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _FailurePlaceholder extends StatelessWidget {
  final ChatTokens tokens;
  const _FailurePlaceholder({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tokens.colors.glassFill,
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: tokens.colors.failedBubbleRim,
          size: 20,
        ),
      ),
    );
  }
}
