import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/utils/app_enums.dart';
import 'package:magic_games/view/base/common_app_bar.dart';
import 'package:magic_games/view/base/common_button.dart';
import 'package:magic_games/view/screens/language/controller/language_controller.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GetBuilder<LanguageController>(
        init: LanguageController(),
        builder: (final LanguageController controller) {
          return Scaffold(
            backgroundColor: AppColors.screenGgColor,
            appBar: CommonAppbar(
              title: 'Choose your language'.tr,
              titleColor: AppColors.white,
              backgroundColor: AppColors.screenGgColor,
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.space(16),
                  AppResponsive.space(10),
                  AppResponsive.space(16),
                  AppResponsive.space(16),
                ),
                child: CommonButton(
                  btnText: 'Save Language'.tr,
                  btnBgColor: AppColors.color8752FF,
                  borderRadius: 18,
                  height: AppResponsive.value(54, tablet: 62),
                  onPressed: controller.saveLanguage,
                ),
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.space(16),
                  AppResponsive.space(12),
                  AppResponsive.space(16),
                  AppResponsive.space(24),
                ),
                itemCount: controller.languages.length,
                separatorBuilder:
                    (final BuildContext context, final int index) =>
                        Gap(AppResponsive.space(12)),
                itemBuilder: (final BuildContext context, final int index) {
                  final AppLanguages language = controller.languages[index];
                  return _LanguageTile(
                    language: language,
                    isSelected: controller.selectedLanguage == language,
                    onTap: () => controller.selectLanguage(language),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final AppLanguages language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppResponsive.space(18)),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.color2C175B : AppColors.color170B3B,
            borderRadius: BorderRadius.circular(AppResponsive.space(18)),
            border: Border.all(
              color: isSelected ? AppColors.color8752FF : AppColors.color1F1653,
              width: 1.4,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.space(16),
            vertical: AppResponsive.space(16),
          ),
          child: Row(
            children: [
              Container(
                width: AppResponsive.value(44, tablet: 52),
                height: AppResponsive.value(44, tablet: 52),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.color8752FF
                      : AppColors.color0F0939,
                  borderRadius: BorderRadius.circular(AppResponsive.space(14)),
                ),
                alignment: Alignment.center,
                child: Text(
                  language.badgeText,
                  style: poppinsW700.copyWith(
                    fontSize: AppResponsive.font(18),
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.space(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.title,
                      style: poppinsW600.copyWith(
                        fontSize: AppResponsive.font(15),
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: AppResponsive.space(4)),
                    Text(
                      language.nativeTitle,
                      style: poppinsW400.copyWith(
                        fontSize: AppResponsive.font(13),
                        color: AppColors.colorD5CCF2,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: AppResponsive.space(22),
                height: AppResponsive.space(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.color8752FF
                        : AppColors.colorA29DBD,
                    width: 2,
                  ),
                  color: isSelected
                      ? AppColors.color8752FF
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: AppResponsive.space(14),
                        color: AppColors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
