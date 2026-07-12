import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/base/common_text_field.dart';
import 'package:magic_games/view/screens/home/widgets/category/home_category_list_widget.dart';
import 'package:magic_games/view/screens/search_games/controller/search_game_controller.dart';
import 'package:magic_games/view/screens/search_games/widgets/search_game_list_item_widget.dart';

import '../../../gen/assets.gen.dart';

class SearchGameScreen extends StatelessWidget {
  const SearchGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: GetBuilder<SearchGameController>(
        init: SearchGameController(),
        builder: (final SearchGameController controller) {
          return Scaffold(
            backgroundColor: AppColors.screenGgColor,
            body: SafeArea(
              child: Column(
                children: [
                  Gap(AppResponsive.value(5, tablet: 8)),
                  SizedBox(
                    height: AppResponsive.value(40, tablet: 60),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: SvgPicture.asset(
                            Assets.svg.icBack,
                            height: AppResponsive.value(35, tablet: 45),
                          ),
                        ),
                        Gap(AppResponsive.value(10, tablet: 15)),
                        Expanded(
                          child: CommonTextField(
                            controller: controller.txtSearch,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            fillColor: AppColors.color170B3B,
                            hintText: 'Search Games, categories'.tr,
                            suffixIcon: SvgPicture.asset(
                              Assets.svg.icSearch,
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(20),
                  if (controller.categories.isNotEmpty) ...[
                    HomeCategoryListWidget(
                      categories: controller.categories,
                      selectedCategoryId: controller.selectedCategoryId,
                      onCategoryTap: controller.selectCategory,
                    ),
                  ],
                  Gap(AppResponsive.space(18)),
                  Expanded(
                    child: controller.filteredGames.isEmpty
                        ? Center(
                            child: Text(
                              'No games found.',
                              style: poppinsW500.copyWith(
                                fontSize: AppResponsive.font(16),
                                color: AppColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.only(
                              bottom: AppResponsive.space(16),
                            ),
                            itemCount: controller.filteredGames.length,
                            separatorBuilder: (_, _) =>
                                Gap(AppResponsive.space(10)),
                            itemBuilder: (_, index) {
                              final game = controller.filteredGames[index];
                              return SearchGameListItemWidget(
                                game: game,
                                showInstallAction: controller.shouldShowInstall(
                                  game,
                                ),
                                onTap: () => controller.openGame(game),
                                onActionTap: () =>
                                    controller.onPrimaryActionTap(game),
                              );
                            },
                          ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),
            ),
          );
        },
      ),
    );
  }
}
