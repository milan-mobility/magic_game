import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/view/screens/splash/controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SplashController>(
        init: SplashController(Get.find()),
        builder: (final SplashController controller) {
          return SafeArea(child: Container());
        },
      ),
    );
  }
}
