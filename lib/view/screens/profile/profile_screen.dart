import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/view/base/bottom_navigation_bar.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';
import 'package:magic_games/view/screens/profile/widgets/profile_option_section_widget.dart';
import 'package:magic_games/view/screens/profile/widgets/profile_summary_card_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (final ProfileController controller) {
          return Scaffold(
            backgroundColor: AppColors.screenGgColor,
            bottomNavigationBar: BottomNavigation(selectedIndex: 1),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.space(16),
                  vertical: AppResponsive.space(14),
                ),
                child: Column(
                  children: [
                    Gap(AppResponsive.value(5, tablet: 8)),
                    ProfileSummaryCardWidget(
                      playerName: controller.playerName,
                      playerType: controller.playerType,
                      description: controller.description,
                      stats: controller.stats,
                      onEditTap: controller.onEditTap,
                      onLogoutTap: controller.onLogoutTap,
                    ),
                    Gap(AppResponsive.space(24)),
                    ...controller.optionSections.expand(
                      (final section) => <Widget>[
                        ProfileOptionSectionWidget(section: section),
                        Gap(AppResponsive.space(22)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
