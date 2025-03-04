import 'package:flutter/material.dart';

Map<int, Color> color = {
  50: const Color.fromRGBO(136, 14, 79, .1),
  100: const Color.fromRGBO(136, 14, 79, .2),
  200: const Color.fromRGBO(136, 14, 79, .3),
  300: const Color.fromRGBO(136, 14, 79, .4),
  400: const Color.fromRGBO(136, 14, 79, .5),
  500: const Color.fromRGBO(136, 14, 79, .6),
  600: const Color.fromRGBO(136, 14, 79, .7),
  700: const Color.fromRGBO(136, 14, 79, .8),
  800: const Color.fromRGBO(136, 14, 79, .9),
  900: const Color.fromRGBO(136, 14, 79, 1),
};

class AppColors extends ThemeExtension<AppColors> {
  final Color? background;
  final Color? text;
  final Color? primaryText;
  final Color? errorText;
  final Color? green;

  const AppColors({
    required this.background,
    required this.text,
    required this.primaryText,
    required this.errorText,
    required this.green,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? text,
    Color? primaryText,
    Color? errorText,
    Color? green,
  }) {
    return AppColors(
      background: background ?? this.background,
      text: text ?? this.text,
      primaryText: primaryText ?? this.primaryText,
      errorText: errorText ?? this.errorText,
      green: green ?? this.green,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      background: Color.lerp(background, other.background, t),
      text: Color.lerp(text, other.text, t),
      primaryText: Color.lerp(primaryText, other.primaryText, t),
      errorText: Color.lerp(errorText, other.errorText, t),
      green: Color.lerp(green, other.green, t),
    );
  }
}
