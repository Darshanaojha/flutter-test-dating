/// Aggregated tokens entrypoint for the neon–glass chat UI.
///
/// Import this file from UI widgets/components to access all token groups.
library;

import 'chat_blur.dart';
import 'chat_colors.dart';
import 'chat_glow.dart';
import 'chat_motion_curves.dart';
import 'chat_opacity.dart';
import 'chat_radius.dart';
import 'chat_shadows.dart';
import 'chat_spacing.dart';
import 'chat_timing.dart';
import 'chat_typography.dart';

export 'chat_blur.dart';
export 'chat_colors.dart';
export 'chat_glow.dart';
export 'chat_motion_curves.dart';
export 'chat_opacity.dart';
export 'chat_radius.dart';
export 'chat_shadows.dart';
export 'chat_spacing.dart';
export 'chat_timing.dart';
export 'chat_typography.dart';

abstract interface class ChatTokens {
  ChatColorTokens get colors;
  ChatOpacityTokens get opacity;
  ChatBlurTokens get blur;
  ChatGlowTokens get glow;
  ChatShadowTokens get shadows;
  ChatRadiusTokens get radius;
  ChatSpacingTokens get spacing;
  ChatTimingTokens get timing;
  ChatTypographyTokens get typography;
  ChatMotionCurves get motion;
}

/// Default token set for the neon–glass chat UI.
final class NeonChatTokens implements ChatTokens {
  static const NeonChatTokens instance = NeonChatTokens._();
  const NeonChatTokens._();

  @override
  ChatColorTokens get colors => NeonChatColors.instance;

  @override
  ChatOpacityTokens get opacity => NeonChatOpacity.instance;

  @override
  ChatBlurTokens get blur => NeonChatBlur.instance;

  @override
  ChatGlowTokens get glow => NeonChatGlow.instance;

  @override
  ChatShadowTokens get shadows => NeonChatShadows.instance;

  @override
  ChatRadiusTokens get radius => NeonChatRadius.instance;

  @override
  ChatSpacingTokens get spacing => NeonChatSpacing.instance;

  @override
  ChatTimingTokens get timing => NeonChatTiming.instance;

  @override
  ChatTypographyTokens get typography => NeonChatTypography.instance;

  @override
  ChatMotionCurves get motion => NeonChatMotionCurves.instance;
}
