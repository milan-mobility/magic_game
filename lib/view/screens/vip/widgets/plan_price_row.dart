import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

class PlanPriceRow extends StatelessWidget {
  const PlanPriceRow({
    super.key,
    this.discount,
    this.badgeName,
    this.trialLabel,
    this.description,
    this.isSelected = false,
    this.isActive = false,
    this.onTap,
    required this.planDuration,
    required this.price,
    required this.priceSuffix,
    required this.billedLabel,
  });

  final String? badgeName;
  final String planDuration;
  final String price;
  final String priceSuffix;
  final String billedLabel;
  final String? discount;
  final String? trialLabel;
  final String? description;
  final bool isSelected;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(AppResponsive.space(10)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.color1A0B53 : AppColors.color0F0939,
          borderRadius: BorderRadius.circular(AppResponsive.space(10)),
          border: Border.all(
            width: isSelected ? 1.5 : 1,
            color: isSelected ? AppColors.colorED2EAA : AppColors.color1F1653,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badgeName != null || isActive)
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppResponsive.space(2),
                  horizontal: AppResponsive.space(5),
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.colorF5BD48
                      : AppColors.colorFF4D7E,
                  borderRadius: BorderRadius.circular(AppResponsive.space(5)),
                ),
                child: Text(
                  (isActive ? 'Active' : (badgeName ?? '')).tr,
                  style: poppinsW300.copyWith(
                    fontSize: AppResponsive.font(12),
                    color: isActive ? AppColors.black : AppColors.white,
                  ),
                ),
              ),
            if (badgeName != null || isActive) Gap(AppResponsive.space(5)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    planDuration.tr,
                    style: poppinsW600.copyWith(
                      fontSize: AppResponsive.font(18),
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (discount != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: AppResponsive.space(3),
                      horizontal: AppResponsive.space(5),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.color211557,
                      borderRadius: BorderRadius.circular(
                        AppResponsive.space(5),
                      ),
                    ),
                    child: Text(
                      (discount ?? '').tr,
                      style: poppinsW300.copyWith(
                        fontSize: AppResponsive.font(12),
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
            if (trialLabel != null) ...[
              Gap(AppResponsive.space(4)),
              Text(
                (trialLabel ?? '').tr,
                style: poppinsW500.copyWith(
                  fontSize: AppResponsive.font(12),
                  color: AppColors.colorF5BD48,
                ),
              ),
            ],
            Gap(AppResponsive.space(4)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    price,
                    style: poppinsW700.copyWith(
                      fontSize: AppResponsive.font(25),
                      color: AppColors.colorFF4D7E,
                    ),
                  ),
                ),
                Gap(AppResponsive.space(4)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppResponsive.space(3)),
                    child: Text(
                      priceSuffix.tr,
                      style: poppinsW300.copyWith(
                        fontSize: AppResponsive.font(12),
                        color: AppColors.colorA29DBD,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Gap(AppResponsive.space(10)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSelected) ...[
                        SvgPicture.asset(
                          Assets.svg.icTickRight,
                          height: AppResponsive.space(20),
                          width: AppResponsive.space(20),
                        ),
                        Gap(AppResponsive.space(5)),
                      ],
                      Expanded(
                        child: Text(
                          billedLabel.tr,
                          style: poppinsW500.copyWith(
                            fontSize: AppResponsive.font(14),
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
