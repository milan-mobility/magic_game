import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/view/base/bottom_navigation_bar.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/banner/featured_banner_widget.dart';
import 'package:magic_games/view/screens/home/widgets/category/home_category_list_widget.dart';
import 'package:magic_games/view/screens/home/widgets/home_header.dart';
import 'package:magic_games/view/screens/home/widgets/sections/section_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.screenGgColor,
        bottomNavigationBar: BottomNavigation(selectedIndex: 0),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.gameModel.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = controller.homeCategories;
            final featuredBanners = controller.featuredBanners;
            final sections = controller.homeSections;

            return Column(
              children: [
                const SizedBox(height: 12),
                HomeHeader(
                  onSearchTap: () {
                    Get.toNamed(
                      RouteHelper.searchGames,
                      arguments: {
                        'categories': categories,
                        'games': controller.allGames,
                      },
                    );
                  },
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  HomeCategoryListWidget(
                    categories: categories,
                    selectedCategoryId: controller.selectedCategoryId.value,
                    onCategoryTap: controller.selectCategory,
                  ),
                ],
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 12),
                    children: [
                      if (featuredBanners.isNotEmpty) ...[
                        FeaturedBannerWidget(
                          banners: featuredBanners,
                          onBannerTap: (game) {
                            Get.toNamed(
                              RouteHelper.gameDetail,
                              arguments: <String, dynamic>{'game': game},
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (sections.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 48,
                          ),
                          child: Text(
                            'No sections available right now.'.tr,
                            style: poppinsW500.copyWith(
                              fontSize: AppResponsive.font(16),
                              color: AppColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...sections.map(
                          (final homeSection) => SectionWidget(
                            key: ValueKey<String>(homeSection.id),
                            title: homeSection.title,
                            subtitle: homeSection.subtitle,
                            layoutType: homeSection.layoutType,
                            games: homeSection.games,
                            collections: homeSection.collections,
                            onGameTap: (game) {
                              Get.toNamed(
                                RouteHelper.gameDetail,
                                arguments: <String, dynamic>{'game': game},
                              );
                            },
                            onGameStoreTap: controller.openStoreForGame,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
