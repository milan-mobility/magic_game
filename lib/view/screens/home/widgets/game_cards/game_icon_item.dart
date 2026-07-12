import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/widgets/home_image_placeholder_widget.dart';

//ICON
class GameIconItem extends StatelessWidget {
  const GameIconItem({
    super.key,
    required this.game,
    required this.rank,
    this.onTap,
  });

  final Games game;
  final int rank;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double tileWidth = AppResponsive.value(100, tablet: 140);
    final double imageSize = AppResponsive.value(90, tablet: 140);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: tileWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(imageSize),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: AppResponsive.space(34),
                        height: AppResponsive.space(34),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.colorFFCC33,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '$rank',
                          style: poppinsW600.copyWith(
                            fontSize: AppResponsive.font(12),
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(AppResponsive.value(8, tablet: 10)),
            Text(
              game.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: poppinsW600.copyWith(
                fontSize: AppResponsive.font(10),
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(final double imageSize) {
    final String? imageUrl = _normalizedUrl(game.banner);
    if (imageUrl == null) {
      return HomeImagePlaceholderWidget(
        width: imageSize,
        height: imageSize,
        borderRadius: 5,
        iconSize: AppResponsive.space(26),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (final BuildContext context, final ImageProvider<Object> image) =>
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(image: image, fit: BoxFit.cover),
                ),
              ),
      errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
        width: imageSize,
        height: imageSize,
        borderRadius: 5,
        iconSize: AppResponsive.space(26),
      ),
    );
  }

  String? _normalizedUrl(final String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.imageUrl();
  }
}
