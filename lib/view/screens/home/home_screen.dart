import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/featured_banner_widget.dart';
import 'package:magic_games/view/screens/home/widgets/section_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final model = controller.gameModel.value;
        if (model == null) return const SizedBox.shrink();

        final sections = (model.sections ?? [])
            .where((s) => s.games != null && s.games!.isNotEmpty)
            .toList();

        return ListView(
          children: [
            if (model.featuredBanner != null)
              FeaturedBannerWidget(game: model.featuredBanner!),
            const SizedBox(height: 24),
            ...sections.map(
              (section) => SectionWidget(
                section: section,
                onGameTap: (game) {
                  Get.toNamed(
                    RouteHelper.gameDetail,
                    arguments: {'game': game},
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
