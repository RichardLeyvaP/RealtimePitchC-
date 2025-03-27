import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color.fromRGBO(55, 47, 182, 1);
  static const Color background = Colors.white;
  static const Color onBackground = Colors.black;
  static const Color blue = Color.fromRGBO(178, 187, 208, 1);
  static const Color lightGreen = Color.fromRGBO(216, 241, 202, 1);
  static const Color green = Color.fromRGBO(125, 209, 77, 1);
  static const Color darkGreen = Color.fromRGBO(94, 157, 58, 1);
  static const Color darkGreen2 = Color.fromRGBO(63, 105, 39, 1);
  static const Color purple = Color.fromRGBO(192, 60, 222, 1);
  static const Color red = Color.fromRGBO(216, 76, 16, 1);
  static const Color border = Color.fromRGBO(243, 245, 247, 1);
  static const Color borderSecondary = Color.fromRGBO(46, 46, 46, 1);
  static const Color gray = Color.fromRGBO(104, 100, 100, 1);
  static const Color text = Color.fromRGBO(225, 225, 225, 1);
  static const Color textDisabled = Color.fromRGBO(118, 118, 118, 1);
  static const Color white = Colors.white;
  static const Color black = Color.fromRGBO(17, 17, 17, 1);
  static const Color dark1 = Color.fromRGBO(67, 67, 67, 1);
  static const Color dark2 = Color.fromRGBO(71, 85, 126, 1);
  static const Color dark3 = Color.fromRGBO(100, 116, 139, 1);
  static const Color backgroundSecondary = Color.fromRGBO(3, 22, 76, 1);
  static MaterialColor primarySwatch = MaterialColor(
    // ignore: deprecated_member_use
    primary.value,
    const {
      50: primary,
      100: primary,
      200: primary,
      300: primary,
      400: primary,
      500: primary,
      600: primary,
      700: primary,
      800: primary,
      900: primary,
    },
  );
}
