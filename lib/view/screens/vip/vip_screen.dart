import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/base/bottom_navigation_bar.dart';
import 'package:magic_games/view/base/common_button.dart';
import 'package:magic_games/view/screens/vip/controller/vip_controller.dart';
import 'package:magic_games/view/screens/vip/widgets/offer_benefit_row.dart';
import 'package:magic_games/view/screens/vip/widgets/plan_price_widget.dart';

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: GetBuilder<VipController>(
        init: VipController(Get.find<SharedPreferenceHelper>()),
        builder: (final VipController controller) {
          return Scaffold(
            backgroundColor: AppColors.screenGgColor,
            bottomNavigationBar: BottomNavigation(selectedIndex: 2),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Gap(AppResponsive.value(5, tablet: 8)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      Assets.png.icHomeHeader.path,
                                      height: AppResponsive.value(
                                        35,
                                        tablet: 70,
                                      ),
                                      width: AppResponsive.value(
                                        140,
                                        tablet: 200,
                                      ),
                                    ),
                                    Gap(AppResponsive.space(40)),
                                    Text(
                                      'Upgrade to VIP'.tr,
                                      style: poppinsW700.copyWith(
                                        fontSize: AppResponsive.font(18),
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Gap(AppResponsive.space(5)),
                                    Text(
                                      'Get ultimate gaming experience with ultimate access and zero ads.'
                                          .tr,
                                      style: poppinsW300.copyWith(
                                        fontSize: AppResponsive.font(12),
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 5),
                              ),
                              Expanded(
                                flex: 1,
                                child: Image.asset(
                                  Assets.png.icVipShield.path,
                                  height: AppResponsive.value(200, tablet: 280),
                                  width: AppResponsive.value(200, tablet: 280),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SparkIcon(1),
                              Text(
                                'VIP Members Benefits',
                                style: poppinsW700.copyWith(
                                  fontSize: AppResponsive.font(18),
                                  color: AppColors.colorED2EAA,
                                ),
                              ),
                              _SparkIcon(2),
                            ],
                          ),
                          Gap(AppResponsive.space(10)),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: AppResponsive.space(5),
                            ),
                            padding: EdgeInsets.all(AppResponsive.space(16)),
                            decoration: BoxDecoration(
                              color: AppColors.color0F0939,
                              borderRadius: BorderRadius.circular(
                                AppResponsive.space(10),
                              ),
                              border: Border.all(
                                width: 1,
                                color: AppColors.color1F1653,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OfferBenefitRow(
                                  prefixIcon: Assets.png.icNoAds.path,
                                  name: 'Remove All Ads',
                                  desc:
                                      'Enjoy uninterrupted gaming with zero ads.',
                                  suffixIcon: Assets.png.icTick.path,
                                ),
                                Gap(AppResponsive.space(10)),
                                Divider(
                                  thickness: 1,
                                  color: AppColors.color211557,
                                ),
                                Gap(AppResponsive.space(10)),
                                OfferBenefitRow(
                                  prefixIcon: Assets.png.icUnlock.path,
                                  name: 'Unlock All Games',
                                  desc:
                                      'Get Full access to 100+ games and all Future Releases.',
                                  suffixIcon: Assets.png.icTick.path,
                                ),
                              ],
                            ),
                          ),
                          Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SparkIcon(1),
                              Text(
                                'Choose your Plan',
                                style: poppinsW700.copyWith(
                                  fontSize: 18,
                                  color: AppColors.colorED2EAA,
                                ),
                              ),
                              _SparkIcon(2),
                            ],
                          ),
                          Gap(AppResponsive.space(10)),
                          PlanPriceWidget(
                            controller: controller,
                          ).paddingSymmetric(
                            horizontal: AppResponsive.space(5),
                          ),
                          if (controller.hasPremiumAccess) ...[
                            Gap(AppResponsive.space(14)),
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: AppResponsive.space(5),
                              ),
                              padding: EdgeInsets.all(AppResponsive.space(12)),
                              decoration: BoxDecoration(
                                color: AppColors.color0F0939,
                                borderRadius: BorderRadius.circular(
                                  AppResponsive.space(10),
                                ),
                                border: Border.all(
                                  width: 1,
                                  color: AppColors.colorF5BD48,
                                ),
                              ),
                              child: Text(
                                'Premium access is already active on this device.',
                                style: poppinsW500.copyWith(
                                  fontSize: AppResponsive.font(14),
                                  color: AppColors.colorF5BD48,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  CommonButton(
                    onPressed: controller.canStartPurchase
                        ? controller.startPurchase
                        : null,
                    btnText: controller.purchaseButtonLabel,
                    btnBgColor: AppColors.colorF5BD48,
                    btnTxtColor: AppColors.black,
                    height: AppResponsive.space(45),
                  ),
                  Gap(AppResponsive.space(4)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.svg.icShield,
                        height: AppResponsive.space(15),
                        width: AppResponsive.space(15),
                      ),
                      Gap(AppResponsive.space(5)),
                      Expanded(
                        child: Text(
                          controller.selectedPlanNote,
                          style: poppinsW400.copyWith(
                            fontSize: AppResponsive.font(14),
                            color: AppColors.color9794B0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: controller.isRestoring
                        ? null
                        : controller.restorePurchases,
                    child: Text(
                      controller.isRestoring
                          ? 'Restoring purchases...'
                          : 'Restore Purchases',
                      style: poppinsW500.copyWith(
                        fontSize: AppResponsive.font(14),
                        color: AppColors.colorF5BD48,
                      ),
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 10),
            ),
          );
        },
      ),
    );
  }
}

class _SparkIcon extends StatelessWidget {
  const _SparkIcon(this.flag);

  final int flag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (flag == 1) ...[
          Container(
            width: AppResponsive.space(50),
            height: 1,
            color: AppColors.color211557,
          ),
          SvgPicture.asset(
            Assets.svg.icStarWhite,
            height: AppResponsive.value(35, tablet: 45),
            width: AppResponsive.value(35, tablet: 45),
            colorFilter: ColorFilter.mode(
              AppColors.colorED2EAA,
              BlendMode.srcIn,
            ),
          ),
        ],
        if (flag == 2) ...[
          SvgPicture.asset(
            Assets.svg.icStarWhite,
            height: AppResponsive.value(35, tablet: 45),
            width: AppResponsive.value(35, tablet: 45),
            colorFilter: ColorFilter.mode(
              AppColors.colorED2EAA,
              BlendMode.srcIn,
            ),
          ),
          Container(
            width: AppResponsive.space(50),
            height: 1,
            color: AppColors.color211557,
          ),
        ],
      ],
    );
  }
}
