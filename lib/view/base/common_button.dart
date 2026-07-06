import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/styles.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.btnText,
    required this.onPressed,
    this.btnBgColor,
    this.height,
    this.width,
    this.paddingHorizontal,
    this.borderRadius,
    this.btnTxtColor,
    this.side,
    this.icon,
    this.iconSpacing,
    this.style,
    this.fontSize,
  });

  final TextStyle? style;
  final double? fontSize;
  final double? height;
  final double? width;
  final String btnText;
  final VoidCallback? onPressed;
  final Color? btnBgColor;
  final double? paddingHorizontal;
  final double? borderRadius;
  final Color? btnTxtColor;
  final BorderSide? side;
  final String? icon;
  final double? iconSpacing;

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      height: height ?? 50,
      width: width ?? double.infinity,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: SvgPicture.asset(icon ?? '', height: 20, width: 20),
              label: Text(
                btnText,
                textAlign: TextAlign.center,
                style:
                    style ??
                    poppinsW500.copyWith(
                      fontSize: fontSize ?? 16,
                      color: Colors.white,
                    ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBgColor ?? AppColors.color5820CB,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
                  side:
                      side ??
                      BorderSide(
                        color: btnBgColor ?? AppColors.color5820CB,
                        width: 0.0,
                      ),
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBgColor ?? AppColors.color5820CB,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
                  side:
                      side ??
                      BorderSide(
                        color: btnBgColor ?? AppColors.color5820CB,
                        width: 0.0,
                      ),
                ),
              ),
              child: Text(
                btnText,
                textAlign: TextAlign.center,
                style:
                    style ??
                    poppinsW500.copyWith(
                      fontSize: fontSize ?? 16,
                      color: Colors.white,
                    ),
              ),
            ),
    );
  }
}
