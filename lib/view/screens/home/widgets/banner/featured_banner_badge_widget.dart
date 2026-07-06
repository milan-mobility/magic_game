import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/widgets/home_image_placeholder_widget.dart';

class FeaturedBannerBadgeWidget extends StatelessWidget {
  const FeaturedBannerBadgeWidget({
    super.key,
    required this.badge,
    required this.categoryName,
  });

  final Featurebannerbagde? badge;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final String title = badge?.name?.trim().isNotEmpty == true
        ? badge!.name!.trim()
        : 'Featured Pick';

    return Row(
      children: [
        if (badge?.url != null && badge!.url!.trim().isNotEmpty)
          CachedNetworkImage(
            imageUrl: badge!.url!.imageUrl(),
            imageBuilder:
                (
                  final BuildContext context,
                  final ImageProvider<Object> imageProvider,
                ) => Container(
                  width: AppResponsive.space(40),
                  height: (40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            errorWidget: (_, __, ___) => HomeImagePlaceholderWidget(
              width: AppResponsive.space(40),
              height: AppResponsive.space(40),
              borderRadius: 10,
              iconSize: AppResponsive.space(18),
            ),
          ),
        if (badge?.url == null || badge!.url!.trim().isEmpty)
          HomeImagePlaceholderWidget(
            width: AppResponsive.space(40),
            height: AppResponsive.space(40),
            borderRadius: 10,
            iconSize: AppResponsive.space(18),
          ),
        Gap(AppResponsive.space(10)),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: poppinsW600.copyWith(
                  fontSize: AppResponsive.font(13),
                  color: AppColors.white,
                ),
              ),
              if (categoryName != null && categoryName!.trim().isNotEmpty)
                Text(
                  categoryName!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: poppinsW400.copyWith(
                    fontSize: AppResponsive.font(12),
                    color: AppColors.colorD5CCF2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
