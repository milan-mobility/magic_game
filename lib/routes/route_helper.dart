import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/view/screens/common_webview/common_webview.dart';
import 'package:magic_games/view/screens/game_detail/game_detail_screen.dart';
import 'package:magic_games/view/screens/home/home_screen.dart';
import 'package:magic_games/view/screens/language/language_screen.dart';
import 'package:magic_games/view/screens/profile/profile_screen.dart';
import 'package:magic_games/view/screens/search_games/search_game_screen.dart';
import 'package:magic_games/view/screens/splash/splash_screen.dart';
import 'package:magic_games/view/screens/vip/vip_screen.dart';
import 'package:magic_games/view/screens/welcome_screen/welcome_screen.dart';

class RouteHelper {
  static const String splash = '/splash';
  static const String welcomeScreen = '/welcomeScreen';
  static const String home = '/home';
  static const String gameDetail = '/gameDetail';
  static const String searchGames = '/searchGames';
  static const String profile = '/profile';
  static const String language = '/language';
  static const String vip = '/vip';
  static const String commonWebView = '/commonWebView';

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
    GetPage<dynamic>(
      name: searchGames,
      page: () => getRoute(SearchGameScreen()),
    ),
    GetPage<dynamic>(name: profile, page: () => getRoute(ProfileScreen())),
    GetPage<dynamic>(name: language, page: () => getRoute(LanguageScreen())),
    GetPage<dynamic>(name: vip, page: () => getRoute(VipScreen())),
    GetPage<dynamic>(
      name: commonWebView,
      page: () => getRoute(CommonWebview()),
    ),
  ];

  static Widget getRoute(final Widget navigateTo) {
    return navigateTo;
  }
}
