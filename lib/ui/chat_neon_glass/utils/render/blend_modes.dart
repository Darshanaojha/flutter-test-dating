import 'package:flutter/material.dart';

/// Blend mode helpers for neon/glow compositing.
///
/// Signatures only; no implementation yet.
abstract interface class ChatBlendModes {
  BlendMode get additive;
  BlendMode get screen;
  BlendMode get lighten;
}
