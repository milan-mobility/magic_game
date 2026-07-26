import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_banner_item.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_collection_item.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_item.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_with_banner.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_with_icon.dart';

class SectionViewAllScreen extends GetView<HomeController> {
  const SectionViewAllScreen({
    super.key,
    required this.title,
    required this.layoutType,
    this.subtitle,
    this.activeActionLabel,
    this.games = const <Games>[],
    this.collections = const <HomeCollectionCardData>[],
  });

  final String title;
  final String? subtitle;
  final HomeSectionLayoutType layoutType;
  final String? activeActionLabel;
  final List<Games> games;
  final List<HomeCollectionCardData> collections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenGgColor,
      appBar: AppBar(
        backgroundColor: AppColors.screenGgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: poppinsW600.copyWith(
            fontSize: AppResponsive.font(20),
            color: AppColors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    subtitle!.trim(),
                    style: poppinsW300.copyWith(
                      fontSize: AppResponsive.font(14),
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _items(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _items() {
    switch (layoutType) {
      case HomeSectionLayoutType.banner:
        return games
            .map(
              (final Games game) => GameBannerItem(
                game: game,
                requiresSubscription: controller.requiresSubscriptionForGame(game),
                onTap: (final bool isSubscribe) {
                  _openGame(game, isSubscribe);
                },
              ),
            )
            .toList();
      case HomeSectionLayoutType.iconWithIcon:
        return games
            .map(
              (final Games game) => GameIconWithIcon(
                game: game,
                requiresSubscription: controller.requiresSubscriptionForGame(game),
                onTap: (final bool isSubscribe) {
                  _openGame(game, isSubscribe);
                },
              ),
            )
            .toList();
      case HomeSectionLayoutType.iconWithBanner:
        return games
            .map(
              (final Games game) => GameIconWithBanner(
                game: game,
                requiresSubscription: controller.requiresSubscriptionForGame(game),
                activeActionLabel: activeActionLabel,
                onTap: (final bool isSubscribe) {
                  _openGame(game, isSubscribe);
                },
                onSecondaryTap: () => controller.openStoreForGame(game),
              ),
            )
            .toList();
      case HomeSectionLayoutType.icon:
        return games
            .asMap()
            .entries
            .map(
              (final MapEntry<int, Games> entry) => GameIconItem(
                game: entry.value,
                rank: entry.key + 1,
                requiresSubscription: controller.requiresSubscriptionForGame(
                  entry.value,
                ),
                onTap: (final bool isSubscribe) {
                  _openGame(entry.value, isSubscribe);
                },
              ),
            )
            .toList();
      case HomeSectionLayoutType.collection:
        return collections
            .map(
              (final HomeCollectionCardData collection) => GameCollectionItem(
                title: collection.title,
                subtitle: collection.subtitle,
                imageUrl: collection.imageUrl,
                leadingLabel: collection.leadingLabel,
              ),
            )
            .toList();
    }
  }

  void _openGame(final Games game, final bool isSubscribe) {
    if (isSubscribe) {
      Get.offAllNamed(RouteHelper.vip);
      return;
    }

    controller.openGame(game);
  }
}
