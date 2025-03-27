import 'package:flutter/material.dart';
import 'package:singing_app/core/design_system/theme/colors.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle mainTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Inter',
    color: AppColors.onBackground,
    wordSpacing: 1,
    height: 1.5,
  );
}
