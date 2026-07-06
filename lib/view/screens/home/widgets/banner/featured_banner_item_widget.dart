import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
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
    required this.onTap,
  });

  final HomeFeaturedBannerData bannerData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final banner = bannerData.banner;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.color1C153F,
          borderRadius: BorderRadius.circular(AppResponsive.space(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.banner != null && banner.banner!.trim().isNotEmpty)
              CachedNetworkImage(
                imageUrl: banner.banner!.imageUrl(),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _bannerFallback(),
              )
            else
              _bannerFallback(),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1.0, 0.0),
                  radius: AppResponsive.isPhone ? 1.0 : 2.15,
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
                        style: poppinsW700.copyWith(
                          fontSize: AppResponsive.font(11),
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  Gap(AppResponsive.space(12)),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppResponsive.space(210),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: poppinsW700.copyWith(
                            fontSize: AppResponsive.font(22),
                            color: AppColors.white,
                            height: 1.05,
                          ),
                        ),
                        Gap(AppResponsive.space(6)),
                        if (_hasText(banner.categoryName) ||
                            _hasText(banner.category))
                          Text(
                            (banner.categoryName ?? banner.category ?? '')
                                .trim(),
                            style: poppinsW600.copyWith(
                              fontSize: AppResponsive.font(18),
                              color: AppColors.colorFF5C8A,
                            ),
                          ),
                        if (_hasText(banner.desc)) ...[
                          Gap(AppResponsive.space(6)),
                          Text(
                            banner.desc!.trim(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: poppinsW400.copyWith(
                              fontSize: AppResponsive.font(14),
                              color: AppColors.colorD5CCF2,
                            ),
                          ),
                        ],
                        Gap(AppResponsive.space(12)),
                        CommonButton(
                          height: AppResponsive.space(45),
                          width: AppResponsive.space(150),
                          btnText: 'Play Now',
                          onPressed: onTap,
                          icon: Assets.svg.icPlay,
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
                        subtitle: 'Rating',
                      ),
                      Container(
                        width: AppResponsive.space(1),
                        height: AppResponsive.space(38),
                        margin: EdgeInsets.symmetric(
                          horizontal: AppResponsive.space(12),
                        ),
                        color: AppColors.white.withOpacity(0.16),
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
}

class _BannerGameThumb extends StatelessWidget {
  const _BannerGameThumb({required this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: AppResponsive.space(40),
        height: AppResponsive.space(40),
        child: iconUrl == null || iconUrl!.trim().isEmpty
            ? HomeImagePlaceholderWidget(
                width: AppResponsive.space(40),
                height: AppResponsive.space(40),
                borderRadius: 12,
                iconSize: AppResponsive.space(18),
              )
            : CachedNetworkImage(
                imageUrl: iconUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => HomeImagePlaceholderWidget(
                  width: AppResponsive.space(40),
                  height: AppResponsive.space(40),
                  borderRadius: 12,
                  iconSize: AppResponsive.space(18),
                ),
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
          width: AppResponsive.space(18),
          height: (18),
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
                fontSize: AppResponsive.font(15),
                color: AppColors.white,
              ),
            ),
            Text(
              subtitle,
              style: poppinsW400.copyWith(
                fontSize: AppResponsive.font(12),
                color: AppColors.colorD5CCF2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
