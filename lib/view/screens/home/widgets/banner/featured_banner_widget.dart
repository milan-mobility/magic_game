import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/banner/featured_banner_item_widget.dart';

class FeaturedBannerWidget extends StatefulWidget {
  const FeaturedBannerWidget({
    super.key,
    required this.banners,
    required this.requiresSubscriptionForGame,
    required this.onBannerTap,
  });

  final List<HomeFeaturedBannerData> banners;
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
    if (oldWidget.banners.length != widget.banners.length) {
      _currentPage = 0;
      _startAutoSlide();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AppResponsive.value(255, tablet: 350),
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
