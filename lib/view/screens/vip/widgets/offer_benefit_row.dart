import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

class OfferBenefitRow extends StatelessWidget {
  const OfferBenefitRow({
    super.key,
    required this.prefixIcon,
    required this.name,
    required this.desc,
    required this.suffixIcon,
  });

  final String prefixIcon;
  final String name;
  final String desc;
  final String suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          prefixIcon,
          height: AppResponsive.space(30),
          width: AppResponsive.space(30),
        ),
        Gap(AppResponsive.space(20)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.tr,
                style: poppinsW500.copyWith(
                  fontSize: AppResponsive.font(16),
                  color: AppColors.white,
                ),
              ),
              Text(
                desc.tr,
                style: poppinsW400.copyWith(
                  fontSize: AppResponsive.font(12),
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        Gap(AppResponsive.space(10)),
        Image.asset(
          suffixIcon,
          height: AppResponsive.space(30),
          width: AppResponsive.space(30),
        ),
      ],
    );
  }
}
