import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dating_application/constants.dart';
import '../../../tokens/chat_tokens.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double maxWidth = screen.width * tokens.spacing.bubbleMaxWidthFractionMin;
    final double maxHeight = screen.height * 0.5; // mid of 40–55%

    // Default aspect ratio 4:5 until image loads.
    const double fallbackAspect = 4 / 5;

    final double glassOpacity =
        (tokens.opacity.bubbleBackgroundMin + tokens.opacity.bubbleBackgroundMax) / 2;
    final double blurSigma =
        ((tokens.blur.microMin + tokens.blur.microMax) / 2) * blurMultiplier.clamp(0, 1);

    final Gradient tint = _tintGradient();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radius.bubbleMax),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                color: Colors.white.withOpacity(glassOpacity),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height =
                    min(constraints.maxHeight, width / fallbackAspect);
                return SizedBox(
                  width: width,
                  height: height,
                  child: _SensitiveImageThumb(
                    imagePath: imagePath,
                    bearerToken: bearerToken,
                    sensitivity: sensitivity,
                    tokens: tokens,
                    isDeleted: isDeleted,
                  ),
                );
              },
            ),
            // Tint overlay (suppressed if deleted)
            if (!isDeleted)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(gradient: tint),
                  ),
                ),
              ),
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
      ),
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
}

class _SensitiveImageThumb extends StatefulWidget {
  final String imagePath;
  final String bearerToken;
  final String sensitivity;
  final ChatTokens tokens;
  final bool isDeleted;

  const _SensitiveImageThumb({
    required this.imagePath,
    required this.bearerToken,
    required this.sensitivity,
    required this.tokens,
    required this.isDeleted,
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
        final Widget image = Image.memory(bytes, fit: BoxFit.cover);

        final bool isSensitive =
            widget.sensitivity.trim() != 'non-explicit' && _showBlur;

        if (isSensitive) {
          return GestureDetector(
            onTap: () => setState(() => _showBlur = false),
            child: Stack(
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: image,
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

        // Normal tap-to-view behavior (kept minimal to avoid changing logic).
        return GestureDetector(
          onTap: widget.isDeleted
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: InteractiveViewer(
                            child: Image.memory(bytes),
                          ),
                        ),
                      );
                    },
                  );
                },
          child: image,
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
