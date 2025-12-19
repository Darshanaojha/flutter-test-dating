import 'package:flutter/material.dart';

/// Typography tokens for neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md` plus provided bubble
/// typography specs.
abstract interface class ChatTypographyTokens {
  double get timestampFontSizeMin;
  double get timestampFontSizeMax;

  TextStyle get bubbleTextPrimary;
  TextStyle get bubbleTextSecondary;
  TextStyle get bubbleDeletedText;
}

final class NeonChatTypography implements ChatTypographyTokens {
  static const NeonChatTypography instance = NeonChatTypography._();
  const NeonChatTypography._();

  @override
  double get timestampFontSizeMin => 10.0;

  @override
  double get timestampFontSizeMax => 11.0;

  @override
  TextStyle get bubbleTextPrimary => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.32,
        color: Color.fromRGBO(255, 255, 255, 0.92),
      );

  @override
  TextStyle get bubbleTextSecondary => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.32,
        color: Color.fromRGBO(255, 255, 255, 0.65),
      );

  @override
  TextStyle get bubbleDeletedText => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.32,
        color: Color.fromRGBO(255, 255, 255, 0.45),
      );
}
