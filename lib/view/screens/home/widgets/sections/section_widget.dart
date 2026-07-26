import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/section_view_all_screen.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_banner_item.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_collection_item.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_item.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_with_banner.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_with_icon.dart';

class SectionWidget extends StatelessWidget {
  const SectionWidget({
    super.key,
    required this.title,
    required this.layoutType,
    required this.games,
    required this.collections,
    required this.requiresSubscriptionForGame,
    this.subtitle,
    this.onGameTap,
    this.onGameStoreTap,
    this.onCollectionTap,
  });

  final String title;
  final String? subtitle;
  final HomeSectionLayoutType layoutType;
  final List<Games> games;
  final List<HomeCollectionCardData> collections;
  final bool Function(Games game) requiresSubscriptionForGame;
  final void Function(Games game, bool)? onGameTap;
  final void Function(Games game)? onGameStoreTap;
  final void Function(HomeCollectionCardData collection)? onCollectionTap;

  @override
  Widget build(BuildContext context) {
    if (layoutType == HomeSectionLayoutType.collection && collections.isEmpty) {
      return const SizedBox.shrink();
    }

    if (layoutType != HomeSectionLayoutType.collection && games.isEmpty) {
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
                        title,
                        style: poppinsW600.copyWith(
                          fontSize: AppResponsive.font(20),
                          color: AppColors.white,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: poppinsW300.copyWith(
                            fontSize: AppResponsive.font(14),
                            color: AppColors.white,
                          ),
                        ),
                      ],
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
            height: _sectionHeight(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: layoutType == HomeSectionLayoutType.collection
                  ? collections.length
                  : games.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) => _buildItem(index),
            ),
          ),
        ],
      ),
    );
  }

  double _sectionHeight() {
    switch (layoutType) {
      case HomeSectionLayoutType.banner:
        return AppResponsive.value(150, tablet: 290);
      case HomeSectionLayoutType.iconWithIcon:
        return AppResponsive.value(150, tablet: 290);
      case HomeSectionLayoutType.iconWithBanner:
        return AppResponsive.value(165, tablet: 225);
      case HomeSectionLayoutType.icon:
        return AppResponsive.value(130, tablet: 200);
      case HomeSectionLayoutType.collection:
        return AppResponsive.value(100, tablet: 200);
    }
  }

  Widget _buildItem(final int index) {
    switch (layoutType) {
      case HomeSectionLayoutType.banner:
        return GameBannerItem(
          game: games[index],
          requiresSubscription: requiresSubscriptionForGame(games[index]),
          onTap: (final bool isSubscribe) {
            onGameTap?.call(games[index], isSubscribe);
          },
        );
      case HomeSectionLayoutType.iconWithIcon:
        return GameIconWithIcon(
          game: games[index],
          requiresSubscription: requiresSubscriptionForGame(games[index]),
          onTap: (final bool isSubscribe) {
            onGameTap?.call(games[index], isSubscribe);
          },
        );
      case HomeSectionLayoutType.iconWithBanner:
        return GameIconWithBanner(
          game: games[index],
          requiresSubscription: requiresSubscriptionForGame(games[index]),
          onTap: (final bool isSubscribe) {
            onGameTap?.call(games[index], isSubscribe);
          },
          onSecondaryTap: () => onGameStoreTap?.call(games[index]),
        );
      case HomeSectionLayoutType.icon:
        return GameIconItem(
          game: games[index],
          rank: index + 1,
          requiresSubscription: requiresSubscriptionForGame(games[index]),
          onTap: (final bool isSubscribe) {
            onGameTap?.call(games[index], isSubscribe);
          },
        );
      case HomeSectionLayoutType.collection:
        final HomeCollectionCardData collection = collections[index];
        return GameCollectionItem(
          title: collection.title,
          subtitle: collection.subtitle,
          imageUrl: collection.imageUrl,
          leadingLabel: collection.leadingLabel,
          onTap: () => onCollectionTap?.call(collection),
        );
    }
  }

  void _openViewAll() {
    Get.to(
      () => SectionViewAllScreen(
        title: title,
        subtitle: subtitle,
        layoutType: layoutType,
        games: games,
        collections: collections,
      ),
    );
  }
}
