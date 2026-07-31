import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/base/common_button.dart';
import 'package:magic_games/view/screens/home/widgets/home_image_placeholder_widget.dart';

//ICONWITHBANNER
class GameIconWithBanner extends StatelessWidget {
  const GameIconWithBanner({
    super.key,
    required this.game,
    required this.requiresSubscription,
    this.activeActionLabel,
    this.actionMode = GameIconWithBannerActionMode.playOrSubscribe,
    this.onTap,
    this.onSecondaryTap,
  });

  final Games game;
  final bool requiresSubscription;
  final String? activeActionLabel;
  final GameIconWithBannerActionMode actionMode;
  final Function(bool)? onTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = AppResponsive.value(180, tablet: 300);
    final double cardHeight = AppResponsive.value(180, tablet: 300);

    return GestureDetector(
      onTap: actionMode == GameIconWithBannerActionMode.hourglassOnly
          ? null
          : _handlePrimaryTap,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(cardWidth, cardHeight),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: cardHeight * 1.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const <double>[0.0, 0.5, 1.0],
                      colors: [
                        AppColors.color5543AE.withValues(alpha: 0),
                        AppColors.color5543AE.withValues(alpha: 0.38),
                        AppColors.color0D0630.withValues(alpha: 1.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppResponsive.space(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _GameMiniThumb(iconUrl: game.icon),
                        Gap(AppResponsive.space(10)),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: poppinsW600.copyWith(
                                  fontSize: AppResponsive.value(10, tablet: 13),
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                game.categoryName ?? '',
                                style: poppinsW500.copyWith(
                                  fontSize: AppResponsive.font(9),
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gap(AppResponsive.space(12)),
                    actionMode == GameIconWithBannerActionMode.hourglassOnly
                        ? const _HourglassIndicator()
                        : Row(
                            children: [
                              Expanded(
                                child: CommonButton(
                                  height: AppResponsive.value(30, tablet: 35),
                                  onPressed: _handlePrimaryTap,
                                  borderRadius: 5,
                                  btnText: _buttonText,
                                  icon: _buttonIcon,
                                  btnTxtColor: _buttonTextColor,
                                  btnBgColor: _buttonBackgroundColor,
                                  style: poppinsW500.copyWith(
                                    fontSize: AppResponsive.font(9, tablet: 13),
                                    color: _buttonTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(final double cardWidth, final double cardHeight) {
    final String? imageUrl = _normalizedUrl(game.banner);
    if (imageUrl == null) {
      return HomeImagePlaceholderWidget(
        width: cardWidth,
        height: cardHeight,
        borderRadius: 15,
        iconSize: AppResponsive.space(34),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (final BuildContext context, final ImageProvider<Object> image) =>
              Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(image: image, fit: BoxFit.cover),
                ),
              ),
      errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
        width: cardWidth,
        height: cardHeight,
        borderRadius: 15,
        iconSize: AppResponsive.space(34),
      ),
    );
  }

  String? _normalizedUrl(final String? value) {
    if (!_hasText(value)) {
      return null;
    }

    return value!.imageUrl();
  }

  bool _hasText(final String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String get _displayTitle {
    if (_hasText(game.shortname)) {
      return game.shortname!.trim();
    }

    return game.name ?? '';
  }

  void _handlePrimaryTap() {
    if (actionMode == GameIconWithBannerActionMode.downloadOnly) {
      onSecondaryTap?.call();
      return;
    }

    onTap?.call(requiresSubscription);
  }

  String get _buttonText {
    if (actionMode == GameIconWithBannerActionMode.downloadOnly) {
      return 'Download'.tr;
    }

    if (requiresSubscription) {
      return 'Subscribe'.tr;
    }

    return (activeActionLabel ?? 'Play Now').tr;
  }

  String? get _buttonIcon {
    if (actionMode == GameIconWithBannerActionMode.downloadOnly) {
      return null;
    }

    return requiresSubscription ? Assets.svg.icSubscribe : Assets.svg.icPlay;
  }

  Color get _buttonTextColor {
    if (actionMode == GameIconWithBannerActionMode.downloadOnly) {
      return AppColors.white;
    }

    return requiresSubscription ? AppColors.color00002F : AppColors.white;
  }

  Color get _buttonBackgroundColor {
    if (actionMode == GameIconWithBannerActionMode.downloadOnly) {
      return AppColors.color5820CB;
    }

    return requiresSubscription ? AppColors.colorF8AB0F : AppColors.color5820CB;
  }
}

enum GameIconWithBannerActionMode {
  playOrSubscribe,
  downloadOnly,
  hourglassOnly,
}

class _HourglassIndicator extends StatelessWidget {
  const _HourglassIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppResponsive.value(30, tablet: 35),
      decoration: BoxDecoration(
        color: AppColors.color2A1B59.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppColors.color8752FF.withValues(alpha: 0.28),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.hourglass_empty_rounded,
        size: AppResponsive.value(18, tablet: 22),
        color: AppColors.white,
      ),
    );
  }
}

class _GameMiniThumb extends StatelessWidget {
  const _GameMiniThumb({required this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = iconUrl != null && iconUrl!.trim().isNotEmpty
        ? iconUrl!.imageUrl()
        : null;

    if (imageUrl == null) {
      return HomeImagePlaceholderWidget(
        width: AppResponsive.space(23),
        height: AppResponsive.space(23),
        borderRadius: 12,
        iconSize: AppResponsive.space(18),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (final BuildContext context, final ImageProvider<Object> image) =>
              Container(
                width: AppResponsive.value(30, tablet: 40),
                height: AppResponsive.value(30, tablet: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  image: DecorationImage(image: image, fit: BoxFit.cover),
                ),
              ),
      errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
        width: AppResponsive.space(23),
        height: AppResponsive.space(23),
        borderRadius: 5,
        iconSize: AppResponsive.space(23),
      ),
    );
  }
}
