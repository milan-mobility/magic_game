import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/app_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.white,
        brightness: Brightness.light,
      ),
      initialRoute: RouteHelper.home,
      getPages: RouteHelper.routes,
      defaultTransition: Transition.noTransition,
      // builder: (context, child) {
      //   return MediaQuery.withNoTextScaling(child: GlobalLoader(child: child!));
      // },
    );
  }
}
