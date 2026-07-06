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

//ICONWITHBANNER
class GameIconWithBanner extends StatelessWidget {
  const GameIconWithBanner({
    super.key,
    required this.game,
    this.onTap,
    this.onSecondaryTap,
  });

  final Games game;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = AppResponsive.value(250, tablet: 300);
    final double cardHeight = AppResponsive.value(250, tablet: 340);

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
                padding: EdgeInsets.all(AppResponsive.space(14)),
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
                                game.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: poppinsW600.copyWith(
                                  fontSize: AppResponsive.font(14),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gap(AppResponsive.space(12)),
                    Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            height: AppResponsive.space(35),
                            btnText: 'Play Now',
                            onPressed: onTap,
                            icon: Assets.svg.icPlay,
                            borderRadius: 10,
                            btnBgColor: AppColors.color5820CB,
                            style: poppinsW500.copyWith(
                              fontSize: AppResponsive.font(14),
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        Gap(AppResponsive.space(10)),
                        _SecondaryActionButton(onTap: onSecondaryTap ?? onTap),
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
        width: AppResponsive.space(44),
        height: AppResponsive.space(44),
        borderRadius: 12,
        iconSize: AppResponsive.space(18),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (final BuildContext context, final ImageProvider<Object> image) =>
              Container(
                width: AppResponsive.space(44),
                height: AppResponsive.space(44),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: image, fit: BoxFit.cover),
                ),
              ),
      errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
        width: AppResponsive.space(44),
        height: AppResponsive.space(44),
        borderRadius: 12,
        iconSize: AppResponsive.space(18),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: AppResponsive.space(28),
        height: AppResponsive.space(28),
        decoration: BoxDecoration(
          color: const Color(0xFFA98DFF),
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.file_download_outlined,
          color: AppColors.screenGgColor,
          size: AppResponsive.space(15),
        ),
      ),
    );
  }
}
