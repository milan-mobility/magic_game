import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/view/base/common_app_bar.dart';
import 'package:magic_games/view/screens/common_webview/controller/common_webview_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommonWebview extends StatelessWidget {
  const CommonWebview({super.key});

  @override
  Widget build(final BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GetBuilder<CommonWebviewController>(
        init: CommonWebviewController(),
        builder: (final CommonWebviewController controller) {
          return Scaffold(
            backgroundColor: AppColors.themeColor,
            resizeToAvoidBottomInset: false,
            extendBody: true,
            appBar: CommonAppbar(
              backgroundColor: Colors.white,
              title: controller.title ?? '',
              iconColor: AppColors.black,
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  controller.progress < 1.0 && controller.progress > 0.0
                      ? SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            value: controller.progress,
                            backgroundColor: Colors.grey,
                            color: AppColors.themeColor,
                          ),
                        )
                      : const SizedBox.shrink(),
                  Expanded(
                    child: WebViewWidget(
                      controller: controller.webViewController,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
