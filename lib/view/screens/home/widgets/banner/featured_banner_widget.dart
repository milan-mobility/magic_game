import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magic_games/helpers/cache/app_image_cache_manager.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/banner/featured_banner_badge_widget.dart';
import 'package:magic_games/view/screens/home/widgets/banner/featured_banner_item_widget.dart';

class FeaturedBannerWidget extends StatefulWidget {
  const FeaturedBannerWidget({
    super.key,
    required this.banners,
    required this.refreshToken,
    required this.requiresSubscriptionForGame,
    required this.onBannerTap,
  });

  final List<HomeFeaturedBannerData> banners;
  final int refreshToken;
  final bool Function(Games game) requiresSubscriptionForGame;
  final void Function(Games game, bool isSubscribe) onBannerTap;

  @override
  State<FeaturedBannerWidget> createState() => _FeaturedBannerWidgetState();
}

class _FeaturedBannerWidgetState extends State<FeaturedBannerWidget> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    _startAutoSlide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _precacheBannerImages(forceRefresh: false);
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.banners.length <= 1) {
      return;
    }

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients || widget.banners.isEmpty) {
        return;
      }

      final int nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant final FeaturedBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool didBannerCountChange =
        oldWidget.banners.length != widget.banners.length;
    final bool didRefreshTokenChange =
        oldWidget.refreshToken != widget.refreshToken;
    final bool didBannerUrlsChange = !_sameBannerUrls(
      oldWidget.banners,
      widget.banners,
    );

    if (didBannerCountChange) {
      _currentPage = 0;
      _startAutoSlide();
    }

    if (didBannerCountChange || didRefreshTokenChange || didBannerUrlsChange) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _precacheBannerImages(forceRefresh: didRefreshTokenChange);
      });
    }
  }

  Future<void> _precacheBannerImages({required bool forceRefresh}) async {
    for (final HomeFeaturedBannerData bannerData in widget.banners) {
      final String? bannerPath = bannerData.banner.banner?.trim();
      if (bannerPath == null || bannerPath.isEmpty) {
        continue;
      }

      final String imageUrl = buildFeaturedBannerImageUrl(bannerData);
      if (forceRefresh) {
        await AppImageCacheManager.removeImage(imageUrl);
      }
      await precacheImage(
        CachedNetworkImageProvider(
          imageUrl,
          cacheManager: AppImageCacheManager.instance,
        ),
        context,
      );

      final String? iconUrl = buildFeaturedBannerThumbIconUrl(
        bannerData.banner.icon,
      );
      if (iconUrl != null) {
        if (forceRefresh) {
          await AppImageCacheManager.removeImage(iconUrl);
        }
        await precacheImage(
          CachedNetworkImageProvider(
            iconUrl,
            cacheManager: AppImageCacheManager.instance,
          ),
          context,
        );
      }

      final String? badgeUrl = buildFeaturedBadgeImageUrl(bannerData.badge);
      if (badgeUrl != null) {
        if (forceRefresh) {
          await AppImageCacheManager.removeImage(badgeUrl);
        }
        await precacheImage(
          CachedNetworkImageProvider(
            badgeUrl,
            cacheManager: AppImageCacheManager.instance,
          ),
          context,
        );
      }
    }
  }

  bool _sameBannerUrls(
    final List<HomeFeaturedBannerData> previous,
    final List<HomeFeaturedBannerData> current,
  ) {
    if (previous.length != current.length) {
      return false;
    }

    for (int index = 0; index < previous.length; index++) {
      final String? previousPath = previous[index].banner.banner?.trim();
      final String? currentPath = current[index].banner.banner?.trim();
      if (previousPath != currentPath) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AppResponsive.value(190, tablet: 310),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (final int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (_, index) {
              final HomeFeaturedBannerData bannerData = widget.banners[index];
              return FeaturedBannerItemWidget(
                bannerData: bannerData,
                requiresSubscription: widget.requiresSubscriptionForGame(
                  bannerData.game,
                ),
                onTap: (final bool isSubscribe) =>
                    widget.onBannerTap(bannerData.game, isSubscribe),
              );
            },
          ),
          Positioned(
            bottom: AppResponsive.space(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(widget.banners.length, (index) {
                final bool isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                    horizontal: AppResponsive.space(3),
                  ),
                  width: isActive
                      ? AppResponsive.space(14)
                      : AppResponsive.space(5),
                  height: AppResponsive.space(5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.color6B35F5
                        : AppColors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(
                      AppResponsive.space(10),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
