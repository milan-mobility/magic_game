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
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.themeColor,
        body: GetBuilder<GameDetailController>(
          init: GameDetailController(),
          builder: (final GameDetailController controller) {
            final bool isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;
            final double exitTopOffset =
                controller.isBannerVisible && controller.isBannerAlignedTop
                ? controller.bannerHeight + AppResponsive.space(12)
                : 8;

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
              child: SafeArea(
                bottom: false,
                left: false,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    WebViewWidget(controller: controller.webViewController),
                    if (controller.isBannerVisible)
                      Positioned(
                        top: controller.isBannerAlignedTop ? 0 : null,
                        bottom: controller.isBannerAlignedTop ? null : 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          top: controller.isBannerAlignedTop,
                          bottom: !controller.isBannerAlignedTop,
                          child: Center(
                            child: SizedBox(
                              width: controller.bannerAd!.size.width.toDouble(),
                              height:
                                  controller.bannerAd!.size.height.toDouble(),
                              child: AdWidget(ad: controller.bannerAd!),
                            ),
                          ),
                        ),
                      ),
                    if (controller.isGameLoading)
                      Positioned.fill(
                        child: ColoredBox(
                          color: AppColors.themeColor,
                          child: Center(
                            child: SpinKitThreeBounce(
                              color: AppColors.white,
                              size: AppResponsive.space(28),
                            ),
                          ),
                        ),
                      ),
                    if (!controller.isExitOverlayVisible)
                      Positioned(
                        top: exitTopOffset,
                        right: 8,
                        child: GestureDetector(
                          onTap: controller.showExitOverlay,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isLandscape ? 12 : 5,
                              horizontal: 5,
                            ),
                            margin: EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: AppColors.color5820CB,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: AppColors.color7433F9,
                                width: 1.0,
                              ),
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
                                      SvgPicture.asset(
                                        Assets.svg.icExit,
                                        height: 20,
                                        width: 20,
                                      ),
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
                        ),
                      ),
                    if (controller.isExitOverlayVisible)
                      Positioned.fill(
                        child: GameExitOverlay(
                          title: controller.gameTitle,
                          description: controller.gameDescription,
                          heroImageUrl: controller.heroImageUrl,
                          backgroundImageUrl: controller.backgroundImageUrl,
                          tags: controller.gameTags,
                          canDownload: controller.canDownloadCurrentGame,
                          recommendedGames: controller.recommendedGames,
                          requiresSubscriptionForGame:
                              controller.requiresSubscriptionForGame,
                          onRecommendedTap: controller.openRecommendedGame,
                          onBack: controller.closeGameDetailScreen,
                          onContinuePlaying: controller.hideExitOverlay,
                          onDownload: controller.canDownloadCurrentGame
                              ? controller.openCurrentGameStore
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
