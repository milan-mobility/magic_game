import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';
import 'package:magic_games/view/screens/profile/widgets/profile_avatar_widget.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (final ProfileController controller) {
        return SizedBox(
          height: AppResponsive.value(50, tablet: 80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: AppResponsive.value(80, tablet: 100),
                height: AppResponsive.value(50, tablet: 80),
                child: Image.asset(Assets.png.icHomeHeader.path),
              ),
              Gap(AppResponsive.space(10)),
              Expanded(
                child: InkWell(
                  onTap: () => onSearchTap.call(),
                  child: Container(
                    height: AppResponsive.value(50, tablet: 60),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppResponsive.space(27)),
                      ),
                      border: Border.all(
                        color: AppColors.color1C153F,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Search Games, categories'.tr,
                        style: poppinsW400.copyWith(
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.white.withValues(alpha: .5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Gap(AppResponsive.space(10)),
              InkWell(
                onTap: () {
                  if (Get.currentRoute != RouteHelper.profile) {
                    Get.offAndToNamed(RouteHelper.profile);
                  }
                },
                borderRadius: BorderRadius.circular(999),
                child: ProfileAvatarWidget(
                  size: AppResponsive.value(50, tablet: 60),
                  assetPath: controller.avatarAssetPath,
                  filePath: controller.avatarFilePath,
                  imageUrl: controller.avatarImageUrl,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
