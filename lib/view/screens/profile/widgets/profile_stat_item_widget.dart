import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

class ProfileStatItemWidget extends StatelessWidget {
  const ProfileStatItemWidget({
    super.key,
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  final String iconAsset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: AppResponsive.space(15),
          height: AppResponsive.space(15),
        ),
        Gap(AppResponsive.space(8)),
        Text(
          value,
          style: poppinsW600.copyWith(
            fontSize: AppResponsive.font(16),
            color: AppColors.white,
          ),
        ),
        Gap(AppResponsive.space(2)),
        Text(
          label.tr,
          textAlign: TextAlign.center,
          style: poppinsW400.copyWith(
            fontSize: AppResponsive.font(12),
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}
