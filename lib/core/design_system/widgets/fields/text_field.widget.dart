import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:singing_app/core/design_system/theme/colors.dart';
import 'package:singing_app/core/design_system/widgets/buttons/core_button.widget.dart';

class UITextField extends StatefulWidget {
  const UITextField({
    required this.controller,
    required this.label,
    required this.isRequired,
    this.autofocus = false,
    this.whiteBackground = false,
    this.showErrorText = true,
    this.keyboardType = TextInputType.text,
    this.toMatchController,
    this.inputFormatters,
    this.onChanged,
    this.radius = 12,
    this.trailingIcon,
    this.prefixIcon,
    this.initialValue,
    this.isDisabled = false,
    this.primaryColor = AppColors.primary,
    this.maxLength = 70,
    this.isPassword = false,
    this.isEmail = false,
    this.obscureText = false,
    this.hint,
    this.onPressedTailingIcon,
    super.key,
  });

  final String label;
  final TextInputType keyboardType;
  final bool isRequired;
  final bool isEmail;
  final double radius;
  final bool isDisabled;
  final TextEditingController controller;
  final bool whiteBackground;
  final bool isPassword;
  final Widget? trailingIcon;
  final Widget? prefixIcon;
  final String? initialValue;
  final TextEditingController? toMatchController;
  final Color primaryColor;
  final String? hint;
  final bool showErrorText;
  final bool autofocus;
  final int maxLength;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final Function()? onPressedTailingIcon;

  @override
  UITextFieldState createState() => UITextFieldState();
}

class UITextFieldState extends State<UITextField> {
  String currentValue = '';
  bool _isPassword = false;

  @override
  void initState() {
    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
    }

    currentValue = widget.controller.text;
    _isPassword = widget.isPassword;

    super.initState();
  }

  bool hasFocus = false;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isDisabled,
      child: SizedBox(
        width: double.infinity,
        child: FocusScope(
          child: Focus(
            onFocusChange: (bool focus) {
              setState(() {
                hasFocus = focus;
              });
            },
            child: TextFormField(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onBackground,
              ),
              inputFormatters: widget.inputFormatters,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.isEmail || widget.isPassword
                  ? TextCapitalization.none
                  : TextCapitalization.sentences,
              maxLength: widget.maxLength,
              onChanged: (String val) {
                setState(() {
                  currentValue = val;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(val.trim());
                }
              },
              cursorColor: widget.primaryColor,
              validator: (String? value) {
                if (value != null) {
                  value = value.trim();
                  if (value.isEmpty && widget.isRequired) {
                    return 'This field should not be empty';
                  }

                  if (widget.isPassword && value.length < 6) {
                    return 'Short Password';
                  }
                  if (widget.toMatchController != null &&
                      widget.toMatchController!.text.trim() != value) {
                    if (widget.isPassword) {
                      return "Passwords don't match";
                    }
                    return "Values don't match";
                  }
                }
                return null;
              },
              obscureText: _isPassword || widget.obscureText,
              autofocus: widget.autofocus,
              decoration: InputDecoration(
                errorStyle: TextStyle(
                  height: widget.showErrorText ? 1.3 : 0.1,
                  fontSize: widget.showErrorText ? 14 : 0.1,
                  color: AppColors.red,
                ),
                labelStyle: const TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(97, 202, 255, .8),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(widget.radius),
                  ),
                  borderSide: const BorderSide(
                    width: 1.5,
                    color: AppColors.dark1,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(widget.radius),
                  ),
                  borderSide: const BorderSide(
                    width: 1.5,
                    color: AppColors.red,
                  ),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIconConstraints: const BoxConstraints(maxHeight: 26),
                suffixIconConstraints: const BoxConstraints(maxHeight: 26),
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon == null ? 8 : 10),
                  child: widget.prefixIcon,
                ),
                suffixIcon: widget.isDisabled && widget.trailingIcon == null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.lock_outline,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                      )
                    : widget.isPassword
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: UICoreButton(
                              requestFocus: false,
                              onPressed: () {
                                setState(() {
                                  _isPassword = !_isPassword;
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Icon(
                                  !_isPassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  size: 22,
                                  color: Colors.grey..withValues(alpha: .8),
                                ),
                              ),
                            ),
                          )
                        : widget.trailingIcon != null
                            ? UICoreButton(
                                requestFocus: false,
                                onPressed: () =>
                                    widget.onPressedTailingIcon != null
                                        ? widget.onPressedTailingIcon!()
                                        : null,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 7),
                                  child: widget.trailingIcon,
                                ),
                              )
                            : null,
                counter: const Offstage(),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(widget.radius)),
                ),
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(widget.radius)),
                  borderSide: BorderSide(
                    width: 1.5,
                    color: widget.primaryColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(widget.radius)),
                  borderSide: const BorderSide(
                    width: 1.5,
                    color: AppColors.border,
                  ),
                ),
                fillColor: currentValue.isEmpty
                    ? AppColors.border
                    : AppColors.background,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                hintText: widget.hint ?? widget.label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
