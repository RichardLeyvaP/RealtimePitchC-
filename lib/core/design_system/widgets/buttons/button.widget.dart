import 'package:singing_app/core/design_system/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:singing_app/core/design_system/widgets/buttons/core_button.widget.dart';
import 'package:singing_app/core/design_system/widgets/indicators/loading_indicator.widget.dart';
import 'package:singing_app/core/design_system/widgets/texts/text.widget.dart';

class UIButton extends StatelessWidget {
  const UIButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.width,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderColor,
    this.leadingIconPath,
    this.elevation = 0,
    this.height = 56,
    this.trailingIconPath,
    this.fontSize = 16,
    this.horizontalPadding = 2,
    this.textColor = Colors.white,
  });

  final Color color;
  final Color textColor;
  final String text;
  final bool isLoading;
  final double fontSize;
  final double horizontalPadding;
  final String? leadingIconPath;
  final String? trailingIconPath;
  final bool isDisabled;
  final double? width;
  final double elevation;
  final double height;
  final Color? borderColor;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.7 : 1,
      child: IgnorePointer(
        ignoring: isLoading || isDisabled,
        child: UICoreButton(
          onPressed: onPressed,
          child: Container(
            height: height,
            width: width,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: borderColor != null
                  ? Border.all(
                      width: 1.5,
                      color: borderColor ?? color,
                    )
                  : null,
              color: color,
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isLoading ? 0 : 1,
                  child: UIText(
                    text,
                    maxLines: 1,
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isLoading) ...[
                  UILoadingIndicator(
                    size: height * 0.5,
                    verticalPadding: 0,
                    color: textColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
