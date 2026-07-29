import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/view/base/common_app_bar.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_collection_item.dart';
import 'package:magic_games/view/screens/search_games/widgets/search_game_list_item_widget.dart';

class SectionViewAllScreen extends GetView<HomeController> {
  const SectionViewAllScreen({
    super.key,
    required this.title,
    required this.layoutType,
    this.showHourglassIndicator = false,
    this.subtitle,
    this.activeActionLabel,
    this.games = const <Games>[],
    this.collections = const <HomeCollectionCardData>[],
  });

  final String title;
  final String? subtitle;
  final HomeSectionLayoutType layoutType;
  final bool showHourglassIndicator;
  final String? activeActionLabel;
  final List<Games> games;
  final List<HomeCollectionCardData> collections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenGgColor,
      appBar: CommonAppbar(
        backgroundColor: AppColors.screenGgColor,
        titleColor: Colors.white,
        title: title,
      ),
      body: SafeArea(
        top: false,
        child: layoutType == HomeSectionLayoutType.collection
            ? _buildCollectionView()
            : _buildGameListView(),
      ),
    );
  }

  Widget _buildGameListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      itemCount: games.length + (_hasSubtitle ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        if (_hasSubtitle) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle!.trim(),
                style: poppinsW300.copyWith(
                  fontSize: AppResponsive.font(14),
                  color: AppColors.white,
                ),
              ),
            );
          }

          index -= 1;
        }

        final Games game = games[index];
        return SearchGameListItemWidget(
          game: game,
          showHourglassAction: showHourglassIndicator,
          showInstallAction: _shouldShowInstall(game),
          showPlayAction: _shouldShowPlay(game),
          showSubscribeAction: _shouldShowSubscribe(game),
          onTap: () => controller.openGame(game),
          onInstallTap: () => controller.openStoreForGame(game),
          onPlayTap: () =>
              _openGame(game, controller.requiresSubscriptionForGame(game)),
          onSubscribeTap: _openVip,
        );
      },
    );
  }

  Widget _buildCollectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasSubtitle) ...[
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
            children: collections
                .map(
                  (final HomeCollectionCardData collection) =>
                      GameCollectionItem(
                        title: collection.title,
                        subtitle: collection.subtitle,
                        imageUrl: collection.imageUrl,
                        leadingLabel: collection.leadingLabel,
                        onTap: () =>
                            controller.openCollectionSearch(collection),
                      ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  bool get _hasSubtitle {
    return subtitle != null && subtitle!.trim().isNotEmpty;
  }

  bool _shouldShowInstall(final Games game) {
    if (layoutType == HomeSectionLayoutType.iconWithBannerDownload) {
      return game.install == true;
    }

    if (controller.requiresSubscriptionForGame(game)) {
      return false;
    }

    return game.install == true;
  }

  bool _shouldShowPlay(final Games game) {
    if (layoutType == HomeSectionLayoutType.iconWithBannerDownload) {
      return false;
    }

    if (controller.requiresSubscriptionForGame(game)) {
      return false;
    }

    return game.play == true;
  }

  bool _shouldShowSubscribe(final Games game) {
    if (layoutType == HomeSectionLayoutType.iconWithBannerDownload) {
      return false;
    }

    return controller.requiresSubscriptionForGame(game);
  }

  void _openVip() {
    Get.offAllNamed(RouteHelper.vip);
  }

  void _openGame(final Games game, final bool isSubscribe) {
    if (isSubscribe) {
      _openVip();
      return;
    }

    controller.openGame(game);
  }
}
