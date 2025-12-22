import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fullscreen image viewer with Hero animation, pinch zoom, and sensitive content handling.
class MediaViewerFullscreen extends StatefulWidget {
  final String mediaUrl;
  final bool isSensitive;
  final Uint8List? initialBytes;
  final String heroTag; // Unique tag for Hero animation

  const MediaViewerFullscreen({
    super.key,
    required this.mediaUrl,
    required this.isSensitive,
    this.initialBytes,
    required this.heroTag,
  });

  @override
  State<MediaViewerFullscreen> createState() => _MediaViewerFullscreenState();
}

class _MediaViewerFullscreenState extends State<MediaViewerFullscreen> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isSensitive;
    // Hide system UI overlays for true fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Build base image widget
    final Widget baseImage = widget.initialBytes != null
        ? Image.memory(
            widget.initialBytes!,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            width: screenSize.width,
            height: screenSize.height,
          )
        : Image.network(
            widget.mediaUrl,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            width: screenSize.width,
            height: screenSize.height,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white70,
                  size: 72,
                ),
              );
            },
          );

    // Wrap image with Hero for smooth animation
    final Widget heroImage = Hero(
      tag: widget.heroTag,
      child: Material(
        color: Colors.transparent,
        child: baseImage,
      ),
    );

    // Handle sensitive content overlay
    final Widget displayed = _obscured
        ? Stack(
            children: [
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: heroImage,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.22),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _obscured = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.70),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 0.8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x663366ff),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Text(
                        'View sensitive content',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : heroImage;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SafeArea(
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_obscured) {
            setState(() => _obscured = false);
            return;
          }
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: InteractiveViewer(
            maxScale: 5.0,
            minScale: 0.8,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: Center(
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: displayed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

