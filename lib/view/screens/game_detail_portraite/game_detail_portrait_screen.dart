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
import 'package:magic_games/view/screens/game_detail/widgets/game_exit_overlay.dart';
import 'package:magic_games/view/screens/game_detail_portraite/controller/game_detail_portrait_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameDetailPortraitScreen extends StatelessWidget {
  const GameDetailPortraitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.themeColor,
        body: GetBuilder<GameDetailPortraitController>(
          init: GameDetailPortraitController(),
          builder: (final GameDetailPortraitController controller) {
            final bool shouldShowBanner =
                controller.isBannerVisible && !controller.isExitOverlayVisible;
            final bool shouldShowTopBanner =
                shouldShowBanner && controller.isBannerAlignedTop;
            final bool shouldShowBottomBanner =
                shouldShowBanner && !controller.isBannerAlignedTop;
            final bool shouldShowExitButton =
                controller.isExitButtonVisible &&
                !controller.isExitOverlayVisible;
            const double exitStripHeight = 32;

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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) {
                          return;
                        }

                        controller.syncBannerViewport(width: viewportWidth);
                      });

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
                                        Assets.png.icLoadingScreen.image(
                                          width: AppResponsive.space(300),
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

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Column(
                            children: [
                              Gap(AppResponsive.value(10)),
                              if (shouldShowExitButton)
                                SizedBox(
                                  height: exitStripHeight,
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: _ExitButton(
                                        onTap: controller.showExitOverlay,
                                      ),
                                    ),
                                  ),
                                ),
                              if (shouldShowTopBanner)
                                Center(
                                  child: SizedBox(
                                    width: controller.bannerAd!.size.width
                                        .toDouble(),
                                    height: controller.bannerHeight,
                                    child: AdWidget(ad: controller.bannerAd!),
                                  ),
                                ),
                              Gap(AppResponsive.value(10)),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: shouldShowExitButton
                                        ? 0
                                        : safeArea.top,
                                    right: safeArea.right,
                                    bottom: shouldShowBottomBanner
                                        ? AppResponsive.value(
                                            5,
                                            tablet: 8,
                                            largeTablet: 12,
                                          )
                                        : safeArea.bottom,
                                    left: safeArea.left,
                                  ),
                                  child: webViewContent,
                                ),
                              ),
                              if (shouldShowBottomBanner)
                                Padding(
                                  // Portrait system navigation bars can overlay
                                  // the window (for example Vivo's three-button
                                  // mode). Keep the ad above that inset.
                                  padding: EdgeInsets.only(
                                    bottom: safeArea.bottom,
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: controller.bannerAd!.size.width
                                          .toDouble(),
                                      height: controller.bannerHeight,
                                      child: AdWidget(ad: controller.bannerAd!),
                                    ),
                                  ),
                                ),
                            ],
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
  const _ExitButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          color: AppColors.color5820CB,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppColors.color7433F9, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(Assets.svg.icExit, height: 20, width: 20),
            const Gap(5),
            Text(
              'Exit'.tr,
              style: poppinsW500.copyWith(fontSize: 15, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
