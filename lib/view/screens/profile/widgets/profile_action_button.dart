import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    super.key,
    required this.label,
    required this.iconAsset,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  final String label;
  final String iconAsset;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: AppResponsive.space(40),
        padding: EdgeInsets.symmetric(horizontal: AppResponsive.space(18)),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.color1F1653,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? AppColors.color2A1B59,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: AppResponsive.space(22),
              height: AppResponsive.space(22),
            ),
            Gap(AppResponsive.space(8)),
            Text(
              label,
              style: poppinsW600.copyWith(
                fontSize: AppResponsive.font(15),
                color: textColor ?? AppColors.colorFF4D7E,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
