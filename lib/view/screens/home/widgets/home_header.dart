import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/view/base/common_text_field.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (final HomeController controller) {
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
                child: SizedBox(
                  height: AppResponsive.value(50, tablet: 60),
                  child: CommonTextField(
                    controller: controller.txtSearch,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    fillColor: AppColors.color170B3B,
                    hintText: 'Search Games, categories'.tr,
                    prefixIcon: SvgPicture.asset(Assets.svg.icSearch),
                  ),
                ),
              ),
              Gap(AppResponsive.space(10)),
              Image.asset(Assets.png.icProfileIcon.path),
            ],
          ),
        ).paddingSymmetric(horizontal: AppResponsive.space(10));
      },
    );
  }
}
