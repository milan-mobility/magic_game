import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/view/screens/game_detail/controller/game_detail_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<GameDetailController>(
        init: GameDetailController(),
        builder: (final GameDetailController controller) {
          return SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
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
    );
  }
}
