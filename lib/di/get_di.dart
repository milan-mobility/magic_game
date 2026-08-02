import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/api/dio_client.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/data/repositories/api_repo.dart';
import 'package:magic_games/helpers/services/analytics_service.dart';
import 'package:magic_games/helpers/services/auth_service.dart';
import 'package:magic_games/helpers/services/premium_access_service.dart';
import 'package:magic_games/helpers/services/remote_config.dart';
import 'package:magic_games/view/base/controller/network_controller.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> init() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  // Initialize notifications asynchronously so it doesn't block the app startup (splash screen)

  Get.put(sharedPreferences);
  Get.put(SharedPreferenceHelper());
  final AuthService authService = Get.put(AuthService(), permanent: true);
  await authService.initialize();
  final AnalyticsService analyticsService = Get.put(
    AnalyticsService(),
    permanent: true,
  );
  await analyticsService.initialize();
  final RemoteConfigService remoteConfigService = Get.put(
    RemoteConfigService(),
    permanent: true,
  );
  await remoteConfigService.initialize();
  Get.put(
    PremiumAccessService(Get.find<SharedPreferenceHelper>()),
    permanent: true,
  );
  Get.put(ProfileController(), permanent: true);
  Get.lazyPut(() => DioClient(Dio(), Get.find()));

  Get.lazyPut(() => ApiRepo(Get.find(), Get.find(), Get.find()), fenix: true);

  Get.put(NetworkController(), permanent: true);
  // Get.lazyPut(() => LoaderController());
  Get.lazyPut(() => HomeController(Get.find()));

  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..maskType = EasyLoadingMaskType.none
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..displayDuration = const Duration(seconds: 2)
    ..animationDuration = const Duration(milliseconds: 200);
}
