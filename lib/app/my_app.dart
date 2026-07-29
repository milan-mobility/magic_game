import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/services/analytics_service.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/translations/app_translations.dart';
import 'package:magic_games/utils/app_constants.dart';
import 'package:magic_games/utils/app_enums.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_setWakelock(enabled: true));
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_setWakelock(enabled: true));
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_setWakelock(enabled: false));
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_setWakelock(enabled: false));
    super.dispose();
  }

  Future<void> _setWakelock({required final bool enabled}) {
    return WakelockPlus.toggle(enable: enabled);
  }

  @override
  Widget build(final BuildContext context) {
    final AnalyticsService analyticsService = Get.find<AnalyticsService>();
    final SharedPreferenceHelper sharedPref =
        Get.find<SharedPreferenceHelper>();
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
      translations: AppTranslation(),
      locale: sharedPref.selectedLanguage.locale,
      fallbackLocale: AppLanguages.english.locale,
      supportedLocales: AppLanguages.values
          .map((final AppLanguages language) => language.locale)
          .toList(),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }

  String buildMove() {
    final sharedPref = Get.find<SharedPreferenceHelper>();
    return sharedPref.isIntroDone
        ? RouteHelper.home
        : RouteHelper.welcomeScreen;
  }
}
