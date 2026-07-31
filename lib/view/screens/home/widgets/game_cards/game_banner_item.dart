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

//BANNER
class GameBannerItem extends StatelessWidget {
  const GameBannerItem({
    super.key,
    required this.game,
    required this.requiresSubscription,
    this.onTap,
  });

  final Games game;
  final bool requiresSubscription;
  final Function(bool)? onTap;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = AppResponsive.value(130, tablet: 225);
    final double cardHeight = AppResponsive.value(150, tablet: 290);

    return SizedBox(
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
              height: cardHeight * 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const <double>[0.0, 0.5, 1.0],
                    colors: [
                      AppColors.color5543AE.withValues(alpha: 0),
                      AppColors.color0D0630.withValues(alpha: 0.5),
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
                  if (_hasText(game.badge))
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.space(8),
                          vertical: AppResponsive.space(4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.colorFF4D7E,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          game.badge!.trim(),
                          style: poppinsW700.copyWith(
                            fontSize: AppResponsive.font(10),
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: poppinsW600.copyWith(
                      fontSize: AppResponsive.font(11),
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
                  if (_hasText(game.rating)) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: AppResponsive.space(10),
                          color: AppColors.colorFFCC33,
                        ),
                        Gap(AppResponsive.space(2)),
                        Text(
                          game.rating!.trim(),
                          style: poppinsW500.copyWith(
                            fontSize: AppResponsive.font(10),
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Gap(AppResponsive.space(5)),
                  CommonButton(
                    height: AppResponsive.value(30, tablet: 35),
                    onPressed: () {
                      onTap?.call(requiresSubscription);
                    },
                    borderRadius: 5,
                    btnText: requiresSubscription
                        ? 'Subscribe'.tr
                        : 'Play Now'.tr,
                    icon: requiresSubscription
                        ? Assets.svg.icSubscribe
                        : Assets.svg.icPlay,
                    btnTxtColor: requiresSubscription
                        ? AppColors.color00002F
                        : AppColors.white,
                    btnBgColor: requiresSubscription
                        ? AppColors.colorF8AB0F
                        : AppColors.color5820CB,
                    style: poppinsW500.copyWith(
                      fontSize: AppResponsive.font(9, tablet: 13),
                      color: requiresSubscription
                          ? AppColors.color00002F
                          : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        borderRadius: 5,
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
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(image: image, fit: BoxFit.cover),
                ),
              ),
      errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
        width: cardWidth,
        height: cardHeight,
        borderRadius: 5,
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
}
