import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/base/common_text_field.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/home_image_placeholder_widget.dart';
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
                    _SearchCategoryWrapWidget(
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
                              'No games found.'.tr,
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

class _SearchCategoryWrapWidget extends StatelessWidget {
  const _SearchCategoryWrapWidget({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryTap,
  });

  final List<HomeCategoryData> categories;
  final String selectedCategoryId;
  final void Function(String categoryId) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: AppResponsive.space(10),
        runSpacing: AppResponsive.space(10),
        children: categories.map((final HomeCategoryData category) {
          return _SearchCategoryChip(
            category: category,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategoryTap(category.id),
          );
        }).toList(),
      ),
    );
  }
}

class _SearchCategoryChip extends StatelessWidget {
  const _SearchCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final HomeCategoryData category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.value(12, tablet: 16),
          vertical: AppResponsive.value(8, tablet: 10),
        ),
        decoration: BoxDecoration(
          color: AppColors.color0D0630,
          borderRadius: BorderRadius.circular(AppResponsive.space(18)),
          border: Border.all(
            color: isSelected ? AppColors.color8752FF : AppColors.color4B21CA,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                width: AppResponsive.space(22),
                height: AppResponsive.space(22),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: AppResponsive.space(15),
                  color: AppColors.color170B3B,
                ),
              )
            else
              _SearchCategoryIcon(iconUrl: category.iconUrl),
            SizedBox(width: AppResponsive.space(10)),
            Text(
              category.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: poppinsW500.copyWith(
                fontSize: AppResponsive.font(12),
                color: isSelected ? AppColors.white : AppColors.colorD5CCF2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCategoryIcon extends StatelessWidget {
  const _SearchCategoryIcon({required this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppResponsive.space(22),
      height: AppResponsive.space(22),
      child: iconUrl == null || iconUrl!.trim().isEmpty
          ? HomeImagePlaceholderWidget(
              width: AppResponsive.space(18),
              height: AppResponsive.space(18),
              iconSize: AppResponsive.space(12),
              isCircular: true,
            )
          : CachedNetworkImage(
              imageUrl: iconUrl!,
              width: AppResponsive.space(18),
              height: AppResponsive.space(18),
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
                width: AppResponsive.space(18),
                height: AppResponsive.space(18),
                iconSize: AppResponsive.space(12),
                isCircular: true,
              ),
            ),
    );
  }
}
