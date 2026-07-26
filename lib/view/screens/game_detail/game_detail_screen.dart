import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/game_detail/controller/game_detail_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: GetBuilder<GameDetailController>(
            init: GameDetailController(),
            builder: (final GameDetailController controller) {
              final bool isLandscape =
                  MediaQuery.of(context).orientation == Orientation.landscape;
              return SafeArea(
                bottom: false,
                left: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.color5820CB,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: AppColors.color7433F9,
                                width: 1.0,
                              ),
                            ),
                            child: isLandscape
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        Assets.svg.icExit,
                                        height: 10,
                                        width: 10,
                                      ),
                                      Gap(4),
                                      Text(
                                        'Exit'.tr,
                                        style: poppinsW500.copyWith(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        Assets.svg.icExit,
                                        height: 20,
                                        width: 20,
                                      ),
                                      Gap(5),
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
                    ),
                    Gap(5),
                    Expanded(
                      child: WebViewWidget(
                        controller: controller.webViewController,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
