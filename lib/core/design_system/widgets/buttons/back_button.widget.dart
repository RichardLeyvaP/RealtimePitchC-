import 'package:singing_app/core/design_system/widgets/buttons/core_button.widget.dart';
import 'package:flutter/material.dart';

class UIBackButton extends StatelessWidget {
  const UIBackButton({
    required this.color,
    this.onPressed,
    this.triggerReload,
    super.key,
  });

  final VoidCallback? onPressed;
  final Color color;
  final VoidCallback? triggerReload;

  @override
  Widget build(BuildContext context) {
    return UICoreButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Icon(
        Icons.close_rounded,
        color: color,
        size: 32,
      ),
    );
  }
}
