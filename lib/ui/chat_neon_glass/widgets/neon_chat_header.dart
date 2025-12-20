import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class NeonChatHeader extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  const NeonChatHeader({
    super.key,
    required this.title,
    this.imageUrl,
    this.onReport,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double headerHeight = size.height * 0.095;
    const double avatarRadius = 18;

    CircleAvatar _buildAvatar() {
      final String? src = imageUrl;
      if (src == null || src.trim().isEmpty) {
        return const CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.white12,
          child: Icon(Icons.person, size: 18, color: Colors.white70),
        );
      }

      final String raw = src.trim();
      bool looksBase64() =>
          raw.length > 50 && (raw.startsWith('/9j/') || raw.startsWith('/iVB'));

      if (looksBase64()) {
        try {
          String clean = raw;
          if (clean.contains(',')) clean = clean.split(',').last.trim();
          final int rem = clean.length % 4;
          if (rem != 0) clean += '=' * (4 - rem);
          Uint8List bytes = base64Decode(clean);
          return CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.white12,
            child: ClipOval(
              child: Image.memory(
                bytes,
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                fit: BoxFit.cover,
              ),
            ),
          );
        } catch (_) {
          // fall through to URL/placeholder
        }
      }

      return CircleAvatar(
        radius: avatarRadius,
        backgroundColor: Colors.white12,
        child: ClipOval(
          child: Image.network(
            raw,
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person,
              size: 18,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }

    return Container(
      height: headerHeight,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + size.height * 0.01,
        left: size.width * 0.04,
        right: size.width * 0.04,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.05),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: size.height * 0.0015,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white.withOpacity(0.9),
              size: size.width * 0.05,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          _buildAvatar(),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          PopupMenuButton<String>(
            color: Colors.black87,
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withOpacity(0.9),
            ),
            onSelected: (value) {
              if (value == 'report') {
                onReport?.call();
              } else if (value == 'block') {
                onBlock?.call();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'report',
                child: Text('Report User'),
              ),
              PopupMenuItem(
                value: 'block',
                child: Text('Block User'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
