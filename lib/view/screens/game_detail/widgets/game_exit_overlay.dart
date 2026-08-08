import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_with_banner.dart';

class GameExitOverlay extends StatelessWidget {
  const GameExitOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.heroImageUrl,
    required this.backgroundImageUrl,
    required this.tags,
    required this.onBack,
    required this.onContinuePlaying,
    required this.onDownload,
    required this.recommendedGames,
    required this.requiresSubscriptionForGame,
    required this.onRecommendedTap,
    this.canDownload = true,
  });

  final String title;
  final String description;
  final String? heroImageUrl;
  final String? backgroundImageUrl;
  final List<String> tags;
  final VoidCallback onBack;
  final VoidCallback onContinuePlaying;
  final VoidCallback? onDownload;
  final List<Games> recommendedGames;
  final bool Function(Games game) requiresSubscriptionForGame;
  final void Function(Games game, bool isSubscribe) onRecommendedTap;
  final bool canDownload;

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double topInset = AppResponsive.space(88);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        color: AppColors.color040120.withValues(alpha: 0.95),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder:
                (final BuildContext context, final BoxConstraints constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 0,
                          bottom: AppResponsive.space(24),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _OverlayBackground(
                                  backgroundImageUrl: backgroundImageUrl,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: topInset,
                                  bottom: AppResponsive.space(20),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: isLandscape
                                      ? _LandscapeHeroSection(
                                          title: title,
                                          description: description,
                                          heroImageUrl: heroImageUrl,
                                          tags: tags,
                                          canDownload: canDownload,
                                          onContinuePlaying: onContinuePlaying,
                                          onDownload: onDownload,
                                          recommendedGames: recommendedGames,
                                          requiresSubscriptionForGame:
                                              requiresSubscriptionForGame,
                                          onRecommendedTap: onRecommendedTap,
                                        )
                                      : _PortraitHeroSection(
                                          title: title,
                                          description: description,
                                          heroImageUrl: heroImageUrl,
                                          tags: tags,
                                          canDownload: canDownload,
                                          onContinuePlaying: onContinuePlaying,
                                          onDownload: onDownload,
                                          recommendedGames: recommendedGames,
                                          requiresSubscriptionForGame:
                                              requiresSubscriptionForGame,
                                          onRecommendedTap: onRecommendedTap,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppResponsive.value(50, tablet: 65),
                        left: AppResponsive.value(12, tablet: 20),
                        child: _OverlayBackButton(onTap: onBack),
                      ),
                    ],
                  );
                },
          ),
        ),
      ),
    );
  }
}

class _OverlayBackground extends StatelessWidget {
  const _OverlayBackground({required this.backgroundImageUrl});

  final String? backgroundImageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (backgroundImageUrl != null && backgroundImageUrl!.isNotEmpty)
          Image.network(
            backgroundImageUrl!,
            fit: BoxFit.cover,
            errorBuilder:
                (
                  final BuildContext context,
                  final Object error,
                  final StackTrace? stackTrace,
                ) => const SizedBox.shrink(),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.color040120.withValues(alpha: 0.55),
                AppColors.color040120.withValues(alpha: 0.92),
                AppColors.color040120,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PortraitHeroSection extends StatelessWidget {
  const _PortraitHeroSection({
    required this.title,
    required this.description,
    required this.heroImageUrl,
    required this.tags,
    required this.canDownload,
    required this.onContinuePlaying,
    required this.onDownload,
    required this.recommendedGames,
    required this.requiresSubscriptionForGame,
    required this.onRecommendedTap,
  });

  final String title;
  final String description;
  final String? heroImageUrl;
  final List<String> tags;
  final bool canDownload;
  final VoidCallback onContinuePlaying;
  final VoidCallback? onDownload;
  final List<Games> recommendedGames;
  final bool Function(Games game) requiresSubscriptionForGame;
  final void Function(Games game, bool isSubscribe) onRecommendedTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _HeroArtwork(imageUrl: heroImageUrl)),
        Gap(AppResponsive.space(20)),
        _GameMetaBlock(title: title, description: description, tags: tags),
        Gap(AppResponsive.space(18)),
        _ActionRow(
          canDownload: canDownload,
          onContinuePlaying: onContinuePlaying,
          onDownload: onDownload,
        ),
        if (recommendedGames.isNotEmpty) ...[
          Gap(AppResponsive.space(24)),
          _RecommendedGamesSection(
            games: recommendedGames,
            requiresSubscriptionForGame: requiresSubscriptionForGame,
            onGameTap: onRecommendedTap,
          ),
        ],
      ],
    );
  }
}

class _LandscapeHeroSection extends StatelessWidget {
  const _LandscapeHeroSection({
    required this.title,
    required this.description,
    required this.heroImageUrl,
    required this.tags,
    required this.canDownload,
    required this.onContinuePlaying,
    required this.onDownload,
    required this.recommendedGames,
    required this.requiresSubscriptionForGame,
    required this.onRecommendedTap,
  });

  final String title;
  final String description;
  final String? heroImageUrl;
  final List<String> tags;
  final bool canDownload;
  final VoidCallback onContinuePlaying;
  final VoidCallback? onDownload;
  final List<Games> recommendedGames;
  final bool Function(Games game) requiresSubscriptionForGame;
  final void Function(Games game, bool isSubscribe) onRecommendedTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroArtwork(imageUrl: heroImageUrl, width: 280, height: 280),
        Gap(AppResponsive.space(24)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GameMetaBlock(
                title: title,
                description: description,
                tags: tags,
              ),
              Gap(AppResponsive.space(20)),
              _ActionRow(
                canDownload: canDownload,
                onContinuePlaying: onContinuePlaying,
                onDownload: onDownload,
                isLandscape: true,
              ),
              if (recommendedGames.isNotEmpty) ...[
                Gap(AppResponsive.space(24)),
                _RecommendedGamesSection(
                  games: recommendedGames,
                  requiresSubscriptionForGame: requiresSubscriptionForGame,
                  onGameTap: onRecommendedTap,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroArtwork extends StatelessWidget {
  const _HeroArtwork({this.imageUrl, this.width, this.height});

  final String? imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final double resolvedWidth =
        width ?? AppResponsive.value(260, tablet: 320, largeTablet: 360);
    final double resolvedHeight =
        height ?? AppResponsive.value(280, tablet: 340, largeTablet: 380);

    return Container(
      width: resolvedWidth,
      height: resolvedHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppResponsive.space(28)),
        border: Border.all(
          color: AppColors.color7433F9.withValues(alpha: 0.85),
          width: 1.4,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.color1A0B53, AppColors.color2C175B],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppResponsive.space(26)),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Container(
                color: AppColors.color170B3B,
                alignment: Alignment.center,
                child: Icon(
                  Icons.sports_esports_rounded,
                  color: AppColors.white.withValues(alpha: 0.9),
                  size: AppResponsive.value(72, tablet: 88),
                ),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      final BuildContext context,
                      final Object error,
                      final StackTrace? stackTrace,
                    ) => Container(
                      color: AppColors.color170B3B,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.sports_esports_rounded,
                        color: AppColors.white.withValues(alpha: 0.9),
                        size: AppResponsive.value(72, tablet: 88),
                      ),
                    ),
              ),
      ),
    );
  }
}

class _GameMetaBlock extends StatelessWidget {
  const _GameMetaBlock({
    required this.title,
    required this.description,
    required this.tags,
  });

  final String title;
  final String description;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: poppinsW700.copyWith(
            fontSize: AppResponsive.font(28),
            color: AppColors.white,
          ),
        ),
        if (tags.isNotEmpty) ...[
          Gap(AppResponsive.space(12)),
          Wrap(
            spacing: AppResponsive.space(10),
            runSpacing: AppResponsive.space(10),
            children: tags
                .map(
                  (final String tag) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.space(12),
                      vertical: AppResponsive.space(6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.color5820CB.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.space(14),
                      ),
                      border: Border.all(
                        color: AppColors.color8752FF.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: poppinsW500.copyWith(
                        fontSize: AppResponsive.font(13),
                        color: AppColors.colorD5CCF2,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        Gap(AppResponsive.space(22)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppResponsive.space(18)),
          decoration: BoxDecoration(
            color: AppColors.color1C153F.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppResponsive.space(22)),
            border: Border.all(
              color: AppColors.color7433F9.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About This Game'.tr,
                style: poppinsW600.copyWith(
                  fontSize: AppResponsive.font(18),
                  color: AppColors.white,
                ),
              ),
              Gap(AppResponsive.space(10)),
              Text(
                description,
                style: poppinsW400.copyWith(
                  fontSize: AppResponsive.font(15),
                  color: AppColors.colorD5CCF2,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.canDownload,
    required this.onContinuePlaying,
    required this.onDownload,
    this.isLandscape = false,
  });

  final bool canDownload;
  final VoidCallback onContinuePlaying;
  final VoidCallback? onDownload;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = <Widget>[
      Expanded(
        child: _OverlayActionButton(
          label: 'Continue Playing'.tr,
          icon: Icons.play_arrow_rounded,
          onTap: onContinuePlaying,
          isPrimary: true,
        ),
      ),
      Gap(AppResponsive.space(14)),
      Expanded(
        child: _OverlayActionButton(
          label: 'Download'.tr,
          icon: Icons.download_rounded,
          onTap: canDownload ? onDownload : null,
        ),
      ),
    ];

    if (isLandscape) {
      return Row(children: buttons);
    }

    return Row(children: buttons);
  }
}

class _OverlayActionButton extends StatelessWidget {
  const _OverlayActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.space(22)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          vertical: AppResponsive.space(16),
          horizontal: AppResponsive.space(18),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppResponsive.space(22)),
          gradient: isPrimary && isEnabled
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[AppColors.color8752FF, AppColors.color5820CB],
                )
              : null,
          color: isPrimary
              ? null
              : (isEnabled
                    ? AppColors.color2A1B59.withValues(alpha: 0.92)
                    : AppColors.color2A1B59.withValues(alpha: 0.45)),
          border: Border.all(
            color: isPrimary
                ? AppColors.color9B57FF
                : AppColors.color8752FF.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? AppColors.white
                  : AppColors.colorA7A4B5.withValues(alpha: 0.85),
              size: AppResponsive.value(24, tablet: 28),
            ),
            Gap(AppResponsive.space(8)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: poppinsW600.copyWith(
                  fontSize: AppResponsive.font(16),
                  color: isEnabled
                      ? AppColors.white
                      : AppColors.colorA7A4B5.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedGamesSection extends StatelessWidget {
  const _RecommendedGamesSection({
    required this.games,
    required this.requiresSubscriptionForGame,
    required this.onGameTap,
  });

  final List<Games> games;
  final bool Function(Games game) requiresSubscriptionForGame;
  final void Function(Games game, bool isSubscribe) onGameTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You May Like This'.tr,
          style: poppinsW600.copyWith(
            fontSize: AppResponsive.font(20),
            color: AppColors.white,
          ),
        ),
        Gap(AppResponsive.space(12)),
        SizedBox(
          height: AppResponsive.value(165, tablet: 225),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: games.length,
            separatorBuilder: (_, _) =>
                SizedBox(width: AppResponsive.space(12)),
            itemBuilder: (_, index) {
              final Games game = games[index];
              final bool requiresSubscription = requiresSubscriptionForGame(
                game,
              );

              return GameIconWithBanner(
                game: game,
                requiresSubscription: requiresSubscription,
                onTap: (final bool isSubscribe) {
                  onGameTap(game, isSubscribe);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OverlayBackButton extends StatelessWidget {
  const _OverlayBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.space(16)),
      child: Container(
        padding: EdgeInsets.all(AppResponsive.space(12)),
        decoration: BoxDecoration(
          color: AppColors.color170B3B.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(AppResponsive.space(16)),
          border: Border.all(
            color: AppColors.color9B57FF.withValues(alpha: 0.78),
            width: 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 25),
      ),
    );
  }
}
