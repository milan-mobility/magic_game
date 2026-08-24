import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/vip/controller/vip_controller.dart';
import 'package:magic_games/view/screens/vip/widgets/plan_price_row.dart';

class PlanPriceWidget extends StatelessWidget {
  const PlanPriceWidget({super.key, required this.controller});

  final VipController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingPlans) {
      return Container(
        padding: EdgeInsets.all(AppResponsive.space(18)),
        decoration: BoxDecoration(
          color: AppColors.color0F0939,
          borderRadius: BorderRadius.circular(AppResponsive.space(10)),
          border: Border.all(width: 1, color: AppColors.color1F1653),
        ),
        child: Row(
          children: [
            SizedBox(
              height: AppResponsive.space(20),
              width: AppResponsive.space(20),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            Gap(AppResponsive.space(12)),
            Expanded(
              child: Text(
                'Loading subscription plans...'.tr,
                style: poppinsW400.copyWith(
                  fontSize: AppResponsive.font(14),
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (controller.plans.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppResponsive.space(18)),
        decoration: BoxDecoration(
          color: AppColors.color0F0939,
          borderRadius: BorderRadius.circular(AppResponsive.space(10)),
          border: Border.all(width: 1, color: AppColors.color1F1653),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.storeMessage?.tr ??
                  'No plans are available right now.'.tr,
              style: poppinsW400.copyWith(
                fontSize: AppResponsive.font(14),
                color: AppColors.white,
              ),
            ),
            Gap(AppResponsive.space(12)),
            TextButton(
              onPressed: controller.loadPlans,
              child: Text(
                'Retry'.tr,
                style: poppinsW600.copyWith(
                  fontSize: AppResponsive.font(14),
                  color: AppColors.colorF5BD48,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final bool useSingleColumn =
            controller.plans.length == 1 || constraints.maxWidth < 420;
        final double itemWidth = useSingleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - AppResponsive.space(15)) / 2;

        return Wrap(
          spacing: AppResponsive.space(15),
          runSpacing: AppResponsive.space(15),
          children: controller.plans.map((final VipPlanData plan) {
            return SizedBox(
              width: itemWidth,
              child: PlanPriceRow(
                planDuration: plan.title,
                price: plan.displayPrice,
                priceSuffix: plan.periodSuffix,
                billedLabel: plan.billedLabel,
                badgeName: plan.badgeName,
                discount: plan.discountLabel,
                trialLabel: plan.trialLabel,
                description: plan.description,
                isSelected: controller.selectedPlan?.planId == plan.planId,
                isActive: controller.activePlan?.planId == plan.planId,
                onTap: controller.canSelectPlans
                    ? () => controller.selectPlan(plan.planId)
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
