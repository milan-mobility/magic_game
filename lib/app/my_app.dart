import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/services/analytics_service.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/app_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AnalyticsService analyticsService = Get.find<AnalyticsService>();
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.white,
        brightness: Brightness.light,
      ),
      initialRoute: buildMove(),
      getPages: RouteHelper.routes,
      navigatorObservers: <NavigatorObserver>[analyticsService.observer],
      defaultTransition: Transition.noTransition,
      // builder: (context, child) {
      //   return MediaQuery.withNoTextScaling(child: GlobalLoader(child: child!));
      // },
    );
  }

  String buildMove() {
    final sharedPref = Get.find<SharedPreferenceHelper>();
    return sharedPref.isIntroDone
        ? RouteHelper.home
        : RouteHelper.welcomeScreen;
  }
}
