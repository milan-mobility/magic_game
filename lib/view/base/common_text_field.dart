import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    this.style,
    this.prefixIconConstraints,
    this.border,
    this.prefixIcon,
    this.suffixIcon,
    this.borderColor,
    this.textInputAction,
    required this.controller,
    this.validator,
    this.readOnly,
    this.onTap,
    this.onChange,
    this.inputFormatter,
    this.keyboardType = TextInputType.text,
    this.maxLines,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign,
    this.enabled = true,
    this.disabledColor,
    this.onSubmitted,
    this.headerTitle,
    this.isObsecure = false,
    this.isPasswordVisible = false,
    this.onVisibilityToggle,
    this.onChangedToggle,
    this.suffixIconWidgetHeight,
    this.suffixIconWidgetWidth,
    this.suffixIconWidget,
    this.isPassword = false,
    this.focusNode,
    this.hintText,
    this.hintStyle,
    this.maxLength,
    this.prefixIconPadding,
    this.fillColor,
  });

  final Color? fillColor;
  final TextStyle? hintStyle;
  final String? hintText;
  final Widget? suffixIconWidget;
  final double? suffixIconWidgetWidth;
  final double? suffixIconWidgetHeight;
  final bool isObsecure;
  final bool isPasswordVisible;
  final bool enabled;
  final Color? disabledColor;
  final TextStyle? style;
  final BoxConstraints? prefixIconConstraints;
  final InputBorder? border;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? borderColor;
  final TextInputAction? textInputAction;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool? readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChange;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatter;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final TextAlign? textAlign;
  final String? headerTitle;
  final bool isPassword;
  final Function(bool)? onVisibilityToggle;
  final Function(bool)? onChangedToggle;
  final FocusNode? focusNode;
  final int? maxLength;
  final EdgeInsetsGeometry? prefixIconPadding;

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          enabled: enabled,
          obscureText: isObsecure,
          textAlign: textAlign ?? TextAlign.start,
          inputFormatters: inputFormatter,
          readOnly: readOnly ?? false,
          onTap: onTap,
          onTapOutside: (final PointerDownEvent event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onFieldSubmitted:
              onSubmitted ??
              (final String value) {
                switch (textInputAction) {
                  case TextInputAction.search:
                  case TextInputAction.done:
                    FocusScope.of(context).unfocus();
                    break;
                  case TextInputAction.next:
                    FocusScope.of(context).nextFocus();
                    break;
                  default:
                    FocusScope.of(context).unfocus();
                }
              },
          onChanged: onChange,
          controller: controller,
          cursorColor: Colors.white,
          cursorWidth: 1,
          maxLength: maxLength,
          maxLines: maxLines ?? 1,
          minLines: minLines ?? 1,
          textInputAction: textInputAction ?? TextInputAction.next,
          style:
              style ??
              poppinsW500.copyWith(
                fontSize: AppResponsive.font(16),
                color: AppColors.white,
              ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? AppColors.white,
            contentPadding: EdgeInsets.only(
              left: AppResponsive.space(15),
              top: AppResponsive.space(12),
              bottom: AppResponsive.value(9, tablet: 9),
            ),
            label: null,
            hintText: hintText ?? '',
            hintStyle:
                hintStyle ??
                poppinsW400.copyWith(
                  color: AppColors.white.withValues(alpha: .5),
                ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            prefixIconConstraints:
                prefixIconConstraints ??
                BoxConstraints(
                  maxHeight: AppResponsive.space(30),
                  maxWidth: AppResponsive.space(70),
                ),
            suffixIconConstraints:
                prefixIconConstraints ??
                BoxConstraints(
                  maxHeight: AppResponsive.space(40),
                  maxWidth: AppResponsive.space(70),
                ),
            border:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppResponsive.space(27)),
                  ),
                  borderSide: BorderSide(
                    color: borderColor ?? AppColors.color1C153F,
                    width: .5,
                  ),
                ),
            focusedBorder:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppResponsive.space(27)),
                  ),
                  borderSide: BorderSide(
                    color: borderColor ?? AppColors.color1C153F,
                    width: .5,
                  ),
                ),
            enabledBorder:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppResponsive.space(27)),
                  ),
                  borderSide: BorderSide(
                    color: borderColor ?? AppColors.color1C153F,
                    width: .5,
                  ),
                ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(AppResponsive.space(27)),
              ),
              borderSide: BorderSide(color: AppColors.color1C153F, width: .5),
            ),
            disabledBorder:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppResponsive.space(27)),
                  ),
                  borderSide: BorderSide(
                    color: borderColor ?? AppColors.color1C153F,
                    width: .5,
                  ),
                ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(
                      right: AppResponsive.space(15),
                      left: AppResponsive.space(15),
                    ),
                    child: prefixIcon,
                  )
                : null,
            suffixIcon: isPassword
                ? Padding(
                    padding:
                        prefixIconPadding ??
                        EdgeInsets.only(
                          left: AppResponsive.space(15),
                          right: AppResponsive.space(14),
                        ),
                    child: InkWell(
                      onTap: () => onVisibilityToggle!(!isPasswordVisible),
                      child: isPasswordVisible
                          ? Icon(
                              Icons.visibility,
                              size: AppResponsive.space(24),
                              color: AppColors.themeColor,
                            )
                          : Icon(
                              Icons.visibility_off,
                              size: AppResponsive.space(24),
                              color: AppColors.themeColor,
                            ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      onChangedToggle!(true);
                    },
                    child: SizedBox(
                      width: suffixIconWidgetWidth,
                      height: suffixIconWidgetHeight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: AppResponsive.space(14),
                        ),
                        child: suffixIcon,
                      ),
                    ),
                  ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
