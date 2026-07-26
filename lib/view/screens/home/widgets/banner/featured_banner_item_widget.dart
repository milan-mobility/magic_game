import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/base/common_button.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/banner/featured_banner_badge_widget.dart';
import 'package:magic_games/view/screens/home/widgets/home_image_placeholder_widget.dart';

class FeaturedBannerItemWidget extends StatelessWidget {
  const FeaturedBannerItemWidget({
    super.key,
    required this.bannerData,
    required this.requiresSubscription,
    required this.onTap,
  });

  final HomeFeaturedBannerData bannerData;
  final bool requiresSubscription;
  final ValueChanged<bool> onTap;

  @override
  Widget build(BuildContext context) {
    final banner = bannerData.banner;

    return GestureDetector(
      onTap: () => onTap(requiresSubscription),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.color1C153F,
          borderRadius: BorderRadius.circular(AppResponsive.space(8)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.banner != null && banner.banner!.trim().isNotEmpty)
              CachedNetworkImage(
                imageUrl: banner.banner!.imageUrl(),
                imageBuilder:
                    (
                      final BuildContext context,
                      final ImageProvider<Object> image,
                    ) => Container(
                      width: double.infinity,
                      height: AppResponsive.value(255, tablet: 350),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: image,
                          fit: AppResponsive.isPhone
                              ? BoxFit.cover
                              : BoxFit.cover,
                        ),
                      ),
                    ),
                errorWidget: (_, _, _) => _bannerFallback(),
              )
            else
              _bannerFallback(),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1.0, 0.0),
                  radius: AppResponsive.isPhone ? 1.15 : 2.15,
                  stops: const <double>[0.5, 0.81],
                  colors: [
                    AppColors.white.withValues(alpha: 0),
                    AppColors.color0D0630.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppResponsive.space(14),
                left: AppResponsive.space(12),
                right: AppResponsive.space(12),
                bottom: AppResponsive.space(35),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasText(banner.tag))
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.space(12),
                        vertical: AppResponsive.space(6),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.colorFF4D7E,
                        borderRadius: BorderRadius.circular(
                          AppResponsive.space(10),
                        ),
                      ),
                      child: Text(
                        banner.tag!.trim(),
                        style: poppinsW600.copyWith(
                          fontSize: AppResponsive.font(10),
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  Gap(AppResponsive.space(5)),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppResponsive.space(210),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: poppinsW600.copyWith(
                            fontSize: AppResponsive.font(14),
                            color: AppColors.white,
                          ),
                        ),
                        // if (_hasText(banner.categoryName) ||
                        //     _hasText(banner.category))
                        //   Text(
                        //     (banner.categoryName ?? banner.category ?? '')
                        //         .trim(),
                        //     style: poppinsW600.copyWith(
                        //       fontSize: AppResponsive.font(12),
                        //       color: AppColors.colorFF5C8A,
                        //     ),
                        //   ),
                        if (_hasText(banner.desc)) ...[
                          Text(
                            (banner.desc ?? ''),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: poppinsW500.copyWith(
                              fontSize: AppResponsive.font(10),
                              color: AppColors.colorD5CCF2,
                            ),
                          ),
                        ],
                        Gap(AppResponsive.space(8)),
                        CommonButton(
                          height: AppResponsive.space(30),
                          width: AppResponsive.space(120),
                          btnText: requiresSubscription
                              ? 'Subscribe'.tr
                              : 'Play Now'.tr,
                          onPressed: () => onTap(requiresSubscription),
                          fontSize: 12,
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
                            fontSize: AppResponsive.font(12),
                            color: requiresSubscription
                                ? AppColors.color00002F
                                : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(AppResponsive.space(12)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _BannerGameThumb(iconUrl: banner.icon?.imageUrl()),
                      Gap(AppResponsive.space(12)),
                      _BannerMetric(
                        icon: Assets.svg.icStar,
                        title: banner.rating ?? '--',
                        subtitle: 'Rating'.tr,
                      ),
                      Container(
                        width: AppResponsive.space(1),
                        height: AppResponsive.space(38),
                        margin: EdgeInsets.symmetric(
                          horizontal: AppResponsive.space(12),
                        ),
                        color: AppColors.white.withValues(alpha: 0.16),
                      ),
                      Expanded(
                        child: FeaturedBannerBadgeWidget(
                          badge: bannerData.badge,
                          categoryName: banner.categoryName ?? banner.category,
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
    );
  }

  bool _hasText(final String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Widget _bannerFallback() {
    return const HomeImagePlaceholderWidget(iconSize: 42, borderRadius: 30);
  }

  String get _displayTitle {
    final String? gameShortname = bannerData.game.shortname?.trim();
    if (gameShortname != null && gameShortname.isNotEmpty) {
      return gameShortname;
    }

    final String? bannerShortname = bannerData.banner.shortname?.trim();
    if (bannerShortname != null && bannerShortname.isNotEmpty) {
      return bannerShortname;
    }

    return bannerData.banner.name ?? '';
  }
}

class _BannerGameThumb extends StatelessWidget {
  const _BannerGameThumb({required this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: iconUrl == null || iconUrl!.trim().isEmpty
          ? HomeImagePlaceholderWidget(
              width: AppResponsive.space(25),
              height: AppResponsive.space(25),
              borderRadius: 3,
              iconSize: AppResponsive.space(18),
            )
          : CachedNetworkImage(
              imageUrl: iconUrl ?? '',
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
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
                width: AppResponsive.space(25),
                height: AppResponsive.space(25),
                borderRadius: 3,
                iconSize: AppResponsive.space(25),
              ),
            ),
    );
  }
}

class _BannerMetric extends StatelessWidget {
  const _BannerMetric({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: AppResponsive.space(12),
          height: AppResponsive.space(12),
          colorFilter: const ColorFilter.mode(
            AppColors.colorFFCC33,
            BlendMode.srcIn,
          ),
        ),
        Gap(AppResponsive.space(8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: poppinsW600.copyWith(
                fontSize: AppResponsive.font(10),
                color: AppColors.white,
              ),
            ),
            Text(
              subtitle,
              style: poppinsW400.copyWith(
                fontSize: AppResponsive.font(8),
                color: AppColors.colorD5CCF2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
