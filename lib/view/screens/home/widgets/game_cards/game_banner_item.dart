import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
  const GameBannerItem({super.key, required this.game, this.onTap});

  final Games game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = AppResponsive.value(184, tablet: 214);
    final double cardHeight = AppResponsive.value(246, tablet: 290);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(cardWidth, cardHeight),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: cardHeight * 0.7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const <double>[0.0, 0.5, 1.0],
                      colors: [
                        AppColors.color5543AE.withValues(alpha: 0),
                        AppColors.color0D0630.withValues(alpha: 0.38),
                        AppColors.color0D0630.withValues(alpha: 1.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppResponsive.space(12)),
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
                      game.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: poppinsW600.copyWith(
                        fontSize: AppResponsive.font(15),
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      game.categoryName ?? '',
                      style: poppinsW500.copyWith(
                        fontSize: AppResponsive.font(12),
                        color: AppColors.white,
                      ),
                    ),
                    if (_hasText(game.rating)) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: AppResponsive.space(16),
                            color: AppColors.colorFFCC33,
                          ),
                          Gap(AppResponsive.space(4)),
                          Text(
                            game.rating!.trim(),
                            style: poppinsW500.copyWith(
                              fontSize: AppResponsive.font(12),
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                    Gap(AppResponsive.space(5)),
                    CommonButton(
                      height: AppResponsive.space(35),
                      btnText: 'Play Now',
                      onPressed: onTap,
                      icon: Assets.svg.icPlay,
                      borderRadius: 10,
                      style: poppinsW500.copyWith(
                        fontSize: AppResponsive.font(14),
                        color: AppColors.white,
                      ),
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
}
