import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Colors {

  const Colors();

//  static const Color loginGradientStart = const Color(0xFFfbab66);
//  static const Color loginGradientEnd = const Color(0xFFf7418c);
  static const Color loginGradientStart = const Color(0xFF41c7af);
  static const Color loginGradientEnd = const Color(0xFF54e38e);
//  static const Color loginGradientStart = const Color(0xFF37474F);
//  static const Color loginGradientEnd = const Color(0xFF41c7af);
  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}