import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/game_detail/controller/game_detail_controller.dart';
import 'package:magic_games/view/screens/game_detail/widgets/game_exit_overlay.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.themeColor,
        body: GetBuilder<GameDetailController>(
          init: GameDetailController(),
          builder: (final GameDetailController controller) {
            final bool isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;
            final bool shouldShowBanner =
                controller.isBannerVisible && !controller.isExitOverlayVisible;
            final bool shouldShowTopBanner =
                shouldShowBanner && controller.isBannerAlignedTop;
            final bool shouldShowBottomBanner =
                shouldShowBanner && !controller.isBannerAlignedTop;
            final bool shouldShowExitButton =
                controller.isExitButtonVisible &&
                !controller.isExitOverlayVisible;
            final double exitStripHeight = isLandscape ? 52 : 32;
            final double landscapeExitRailWidth = 52;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              controller.preloadExitPreviewAssets(context);
            });

            return PopScope(
              canPop: false,
              onPopInvokedWithResult:
                  (final bool didPop, final Object? result) async {
                    if (didPop) {
                      return;
                    }

                    await controller.handleSystemBack();
                  },
              child: LayoutBuilder(
                builder:
                    (
                      final BuildContext context,
                      final BoxConstraints constraints,
                    ) {
                      final EdgeInsets safeArea = MediaQuery.paddingOf(context);
                      final double viewportWidth = constraints.maxWidth;
                      final Orientation viewportOrientation = MediaQuery.of(
                        context,
                      ).orientation;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) {
                          return;
                        }

                        controller.syncBannerViewport(
                          width: viewportWidth,
                          orientation: viewportOrientation,
                        );
                      });
                      final double landscapePreviewWidth =
                          (constraints.maxHeight * 0.7)
                              .clamp(260.0, 560.0)
                              .toDouble();

                      final Widget webViewContent = Stack(
                        fit: StackFit.expand,
                        children: [
                          WebViewWidget(
                            key: ValueKey(
                              'game_webview_${controller.webViewGeneration}',
                            ),
                            controller: controller.webViewController,
                          ),
                          if (controller.shouldShowLoadingOverlay)
                            Positioned.fill(
                              child: ColoredBox(
                                color: AppColors.themeColor,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppResponsive.space(24),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        (isLandscape
                                                ? Assets.png.landscapeGameLogo
                                                : Assets.png.icLoadingScreen)
                                            .image(
                                              width: isLandscape
                                                  ? landscapePreviewWidth
                                                  : AppResponsive.space(300),
                                              fit: BoxFit.contain,
                                            ),
                                        Gap(AppResponsive.space(28)),
                                        Text(
                                          'Loading...'.tr,
                                          style: poppinsW700.copyWith(
                                            fontSize: AppResponsive.space(26),
                                            color: AppColors.white,
                                          ),
                                        ),
                                        Gap(AppResponsive.space(18)),
                                        SpinKitThreeBounce(
                                          color: AppColors.white,
                                          size: AppResponsive.space(22),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );

                      final double topBannerHeight = shouldShowTopBanner
                          ? controller.bannerHeight
                          : 0;
                      final double bottomBannerHeight = shouldShowBottomBanner
                          ? controller.bannerHeight
                          : 0;
                      final double preferredPortraitExitTop =
                          topBannerHeight -
                          (shouldShowTopBanner
                              ? GetPlatform.isIOS
                                    ? -5
                                    : 20
                              : 0);
                      final double portraitExitTop =
                          preferredPortraitExitTop > safeArea.top
                          ? preferredPortraitExitTop
                          : safeArea.top;
                      final double gameContentTop = isLandscape
                          ? topBannerHeight
                          : topBannerHeight +
                                (shouldShowExitButton
                                    ? exitStripHeight -
                                          (shouldShowTopBanner
                                              ? GetPlatform.isIOS
                                                    ? -10
                                                    : 20
                                              : -5)
                                    : 0);
                      // In portrait, keep the interactive elements in a
                      // strict vertical order: exit strip, WebView, then ad.
                      // This prevents either native overlay from covering the
                      // game on Android or iOS. Landscape retains its current
                      // layout because it uses the right-side exit rail.
                      final double portraitWebViewTop = shouldShowExitButton
                          ? portraitExitTop + exitStripHeight
                          : safeArea.top;
                      final double minimumWebViewTop = isLandscape
                          ? gameContentTop
                          : (gameContentTop > portraitWebViewTop
                                ? gameContentTop
                                : portraitWebViewTop);
                      final double webViewTop = minimumWebViewTop > safeArea.top
                          ? minimumWebViewTop
                          : safeArea.top;
                      final double landscapeWebViewBottom =
                          bottomBannerHeight > safeArea.bottom
                          ? bottomBannerHeight
                          : safeArea.bottom;
                      final double webViewBottom = isLandscape
                          ? landscapeWebViewBottom
                          : controller.isBannerVisible
                          ? safeArea.bottom + (GetPlatform.isAndroid ? 90 : 30)
                          : safeArea.bottom +
                                bottomBannerHeight; //TODO safeArea.bottom +
                      final Widget gameContent = Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            top: webViewTop,
                            right: safeArea.right,
                            bottom: webViewBottom,
                            left: safeArea.left,
                            child: webViewContent,
                          ),
                          if (shouldShowTopBanner)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                width: controller.bannerAd!.size.width
                                    .toDouble(),
                                height: controller.bannerHeight,
                                child: AdWidget(ad: controller.bannerAd!),
                              ),
                            ),
                          if (shouldShowBottomBanner)
                            Positioned(
                              left: 0,
                              right: 0,
                              // Portrait system navigation bars can overlay
                              // the window (for example Vivo's three-button
                              // mode). Keep the ad above that inset.
                              bottom: isLandscape
                                  ? 0
                                  : 10, //TODO safeArea.bottom
                              child: SizedBox(
                                width: controller.bannerAd!.size.width
                                    .toDouble(),
                                height: controller.bannerHeight,
                                child: AdWidget(ad: controller.bannerAd!),
                              ),
                            ),
                        ],
                      );

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            right: isLandscape && shouldShowExitButton
                                ? landscapeExitRailWidth
                                : 0,
                            child: gameContent,
                          ),
                          if (isLandscape && shouldShowExitButton)
                            Positioned(
                              top: 0,
                              // Keep the exit action out of a landscape
                              // navigation bar or iPhone safe-area inset.
                              // The WebView's bounds stay unchanged.
                              right: safeArea.right,
                              bottom: 0,
                              width: landscapeExitRailWidth,
                              child: ColoredBox(
                                color: Colors.black,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: _ExitButton(
                                      isLandscape: true,
                                      onTap: controller.showExitOverlay,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (!isLandscape && shouldShowExitButton)
                            Positioned(
                              top: portraitExitTop,
                              left: 0,
                              right: 0,
                              height: exitStripHeight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: _ExitButton(
                                    isLandscape: false,
                                    onTap: controller.showExitOverlay,
                                  ),
                                ),
                              ),
                            ),
                          if (controller.isExitOverlayVisible)
                            Positioned.fill(
                              child: GameExitOverlay(
                                title: controller.gameTitle,
                                description: controller.gameDescription,
                                heroImageUrl: controller.heroImageUrl,
                                backgroundImageUrl:
                                    controller.backgroundImageUrl,
                                tags: controller.gameTags,
                                canDownload: controller.canDownloadCurrentGame,
                                recommendedGames: controller.recommendedGames,
                                requiresSubscriptionForGame:
                                    controller.requiresSubscriptionForGame,
                                onRecommendedTap:
                                    controller.openRecommendedGame,
                                onBack: controller.closeGameDetailScreen,
                                onContinuePlaying: controller.hideExitOverlay,
                                onDownload: controller.canDownloadCurrentGame
                                    ? controller.openCurrentGameStore
                                    : null,
                              ),
                            ),
                        ],
                      );
                    },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.isLandscape, required this.onTap});

  final bool isLandscape;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isLandscape ? 12 : 5,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: AppColors.color5820CB,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppColors.color7433F9, width: 1.0),
        ),
        child: isLandscape
            ? RotatedBox(
                quarterTurns: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Exit'.tr,
                      style: poppinsW500.copyWith(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(4),
                    RotatedBox(
                      quarterTurns: 1,
                      child: SvgPicture.asset(
                        Assets.svg.icExit,
                        height: 10,
                        width: 10,
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(Assets.svg.icExit, height: 20, width: 20),
                  const Gap(5),
                  Text(
                    'Exit'.tr,
                    style: poppinsW500.copyWith(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
