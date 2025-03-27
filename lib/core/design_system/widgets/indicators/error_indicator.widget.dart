import 'package:flutter/material.dart';
import 'package:singing_app/core/design_system/theme/colors.dart';
import 'package:singing_app/core/design_system/widgets/buttons/button.widget.dart';
import 'package:singing_app/core/design_system/widgets/texts/text.widget.dart';

class UIErrorIndicator extends StatelessWidget {
  const UIErrorIndicator({
    this.onPressed,
    this.errorText,
    this.buttonWidth,
    this.buttonText,
    this.color = AppColors.primary,
    this.textColor,
    super.key,
  });

  final String? errorText;
  final VoidCallback? onPressed;
  final double? buttonWidth;
  final String? buttonText;
  final Color? textColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.all(20),
            child: Icon(
              Icons.error_outline_sharp,
              color: color,
              size: 90,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 270,
            alignment: Alignment.center,
            child: UIText(
              errorText ??
                  'Something went wrong, please check your internet connection.',
              textAlign: TextAlign.center,
              color: textColor ?? AppColors.onBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onPressed != null) ...[
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: UIButton(
                text: buttonText ?? 'Try Again',
                onPressed: onPressed!,
                width: buttonWidth,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
