import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/services/google_leaderboard_service.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';

import '../../gen/assets.gen.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({this.selectedIndex, super.key});

  final int? selectedIndex;

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            offset: Offset(2, 0),
            color: AppColors.color040120.withValues(alpha: .18),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppResponsive.space(24)),
          topRight: Radius.circular(AppResponsive.space(24)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.themeColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.color752DEA,
          unselectedItemColor: AppColors.colorA7A4B5,
          showUnselectedLabels: true,
          currentIndex: selectedIndex ?? 0,
          selectedLabelStyle: poppinsW500.copyWith(
            fontSize: AppResponsive.font(14),
            color: AppColors.color752DEA,
          ),
          unselectedLabelStyle: poppinsW500.copyWith(
            fontSize: AppResponsive.font(14),
            color: AppColors.colorA7A4B5,
          ),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.svg.icHome, height: 22, width: 22),
              activeIcon: SvgPicture.asset(
                Assets.svg.icHomeSelecetd,
                height: 22,
                width: 22,
              ),
              label: 'Home'.tr,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.svg.icVip, height: 22, width: 22),
              activeIcon: SvgPicture.asset(
                Assets.svg.icVip,
                height: 22,
                width: 22,
              ),
              label: 'VIP'.tr,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                Assets.svg.icLeaderboard,
                height: 22,
                width: 22,
              ),
              activeIcon: SvgPicture.asset(
                Assets.svg.icLeaderboardSelected,
                height: 22,
                width: 22,
              ),
              label: 'Leaderboard'.tr,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                Assets.svg.icProfile,
                height: 22,
                width: 22,
              ),
              activeIcon: SvgPicture.asset(
                Assets.svg.icProfileSelected,
                height: 22,
                width: 22,
              ),
              label: 'Profile'.tr,
            ),
          ],
          onTap: (final int index) async {
            switch (index) {
              case 0:
                if (Get.currentRoute != RouteHelper.home) {
                  Get.offAndToNamed(RouteHelper.home);
                }
                break;
              case 1:
                if (Get.currentRoute != RouteHelper.vip) {
                  Get.offAndToNamed(RouteHelper.vip);
                }
                break;
              case 2:
                await GoogleLeaderboardService.instance.showLeaderboard();
                break;
              default:
                if (Get.currentRoute != RouteHelper.profile) {
                  Get.offAndToNamed(RouteHelper.profile);
                }
                break;
            }
          },
        ),
      ),
    );
  }
}
