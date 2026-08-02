import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/api/api_end_points.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/services/remote_config.dart';
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
        : 'Featured Pick'.tr;

    return Row(
      children: [
        if (badge?.url != null && badge!.url!.trim().isNotEmpty)
          CachedNetworkImage(
            imageUrl: _badgeImageUrl!,
            imageBuilder:
                (
                  final BuildContext context,
                  final ImageProvider<Object> imageProvider,
                ) => Container(
                  width: AppResponsive.space(25),
                  height: AppResponsive.space(25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
              width: AppResponsive.space(25),
              height: AppResponsive.space(25),
              borderRadius: 10,
              iconSize: AppResponsive.space(25),
            ),
          ),
        if (badge?.url == null || badge!.url!.trim().isEmpty)
          HomeImagePlaceholderWidget(
            width: AppResponsive.space(25),
            height: AppResponsive.space(25),
            borderRadius: 10,
            iconSize: AppResponsive.space(25),
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
                  fontSize: AppResponsive.font(10),
                  color: AppColors.white,
                ),
              ),
              if (categoryName != null && categoryName!.trim().isNotEmpty)
                Text(
                  categoryName!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: poppinsW400.copyWith(
                    fontSize: AppResponsive.font(8),
                    color: AppColors.colorD5CCF2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String? get _badgeImageUrl {
    final String? badgePath = badge?.url?.trim();
    if (badgePath == null || badgePath.isEmpty) {
      return null;
    }

    final String baseUrl = Get.isRegistered<RemoteConfigService>()
        ? Get.find<RemoteConfigService>().baseUrl
        : Endpoints.defaultBaseUrl;
    final String normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl
        : '$baseUrl/';

    return '$normalizedBaseUrl${badgePath.replaceFirst(RegExp(r'^/+'), '')}';
  }
}
