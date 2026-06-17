import 'package:flutter/material.dart';

class OnboardingStyle {
  static const primaryPink = Color(0xFFE91E8C);
  static const babyPink = Color(0xFFFFF0F5);
  static const softPink = Color(0xFFFCE4EC);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFCE4EC),
      Color(0xFFFFF0F5),
    ],
  );

  // Koi box nahi, koi shadow nahi — seedha transparent image
  static Widget roundedImage(String path) {
    return Image.asset(
      path,
      width: 280,
      height: 280,
      fit: BoxFit.contain,
    );
  }
}
