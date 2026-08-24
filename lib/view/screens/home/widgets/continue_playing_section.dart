import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/section_view_all_screen.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_with_banner.dart';

class ContinuePlayingSection extends StatelessWidget {
  const ContinuePlayingSection({
    super.key,
    required this.games,
    required this.requiresSubscriptionForGame,
    required this.onGameTap,
  });

  final List<Games> games;
  final bool Function(Games game) requiresSubscriptionForGame;
  final void Function(Games game, bool isSubscribe) onGameTap;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue Playing'.tr,
                        style: poppinsW600.copyWith(
                          fontSize: AppResponsive.font(20),
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jump back into your recently played favorites.'.tr,
                        style: poppinsW300.copyWith(
                          fontSize: AppResponsive.font(14),
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _openViewAll,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'View All'.tr,
                      style: poppinsW500.copyWith(
                        fontSize: AppResponsive.font(14),
                        color: AppColors.color8752FF,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: AppResponsive.value(165, tablet: 225),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: games.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final Games game = games[index];
                final bool requiresSubscription =
                    requiresSubscriptionForGame(game);

                return GameIconWithBanner(
                  game: game,
                  requiresSubscription: requiresSubscription,
                  activeActionLabel: 'Continue',
                  onTap: (final bool isSubscribe) {
                    onGameTap(game, isSubscribe);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openViewAll() {
    Get.to(
      () => SectionViewAllScreen(
        title: 'Continue Playing'.tr,
        subtitle: 'Jump back into your recently played favorites.'.tr,
        layoutType: HomeSectionLayoutType.iconWithBanner,
        activeActionLabel: 'Continue',
        games: games,
      ),
    );
  }
}
