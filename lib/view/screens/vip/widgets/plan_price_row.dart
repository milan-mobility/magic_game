import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

class PlanPriceRow extends StatelessWidget {
  const PlanPriceRow({
    super.key,
    this.discount,
    this.badgeName,
    required this.planDuration,
    required this.price,
  });

  final String? badgeName;
  final String planDuration;
  final double price;
  final String? discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppResponsive.space(10)),
      decoration: BoxDecoration(
        color: AppColors.color0F0939,
        borderRadius: BorderRadius.circular(AppResponsive.space(10)),
        border: Border.all(width: 1, color: AppColors.color1F1653),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badgeName != null)
            Container(
              padding: EdgeInsets.symmetric(
                vertical: AppResponsive.space(2),
                horizontal: AppResponsive.space(5),
              ),
              decoration: BoxDecoration(
                color: AppColors.colorFF4D7E,
                borderRadius: BorderRadius.circular(AppResponsive.space(5)),
              ),
              child: Text(
                badgeName ?? '',
                style: poppinsW300.copyWith(
                  fontSize: AppResponsive.font(12),
                  color: AppColors.white,
                ),
              ),
            ),
          if (badgeName != null) Gap(AppResponsive.space(5)),
          Row(
            children: [
              Text(
                planDuration,
                style: poppinsW600.copyWith(
                  fontSize: AppResponsive.font(18),
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              if (discount != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppResponsive.space(3),
                    horizontal: AppResponsive.space(5),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.color1A0B53,
                    borderRadius: BorderRadius.circular(AppResponsive.space(5)),
                  ),
                  child: Text(
                    discount ?? '',
                    style: poppinsW300.copyWith(
                      fontSize: AppResponsive.font(12),
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Text(
                '$price',
                style: poppinsW700.copyWith(
                  fontSize: AppResponsive.font(25),
                  color: AppColors.colorFF4D7E,
                ),
              ),
              Text(
                '/ $planDuration',
                style: poppinsW300.copyWith(
                  fontSize: AppResponsive.font(12),
                  color: AppColors.colorA29DBD,
                ),
              ),
            ],
          ),
          Gap(AppResponsive.space(10)),
          Row(
            children: [
              SvgPicture.asset(
                Assets.svg.icTickRight,
                height: AppResponsive.space(20),
                width: AppResponsive.space(20),
              ),
              Gap(AppResponsive.space(5)),
              Text(
                'Billed $planDuration',
                style: poppinsW500.copyWith(
                  fontSize: AppResponsive.font(14),
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
