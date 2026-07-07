import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/view/screens/game_detail/game_detail_screen.dart';
import 'package:magic_games/view/screens/home/home_screen.dart';
import 'package:magic_games/view/screens/splash/splash_screen.dart';
import 'package:magic_games/view/screens/welcome_screen/welcome_screen.dart';

class RouteHelper {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String gameDetail = '/gameDetail';
  static const String welcomeScreen = '/welcomeScreen';

  static List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(name: splash, page: () => getRoute(SplashScreen())),
    GetPage<dynamic>(
      name: welcomeScreen,
      page: () => getRoute(WelcomeScreen()),
    ),
    GetPage<dynamic>(name: home, page: () => getRoute(HomeScreen())),
    GetPage<dynamic>(
      name: gameDetail,
      page: () => getRoute(GameDetailScreen()),
    ),
  ];

  static Widget getRoute(final Widget navigateTo) {
    return navigateTo;
  }
}
