import 'package:dio/dio.dart';
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
  Get.lazyPut(() => DioClient(Dio(), Get.find()));

  Get.lazyPut(() => ApiRepo(Get.find(), Get.find()), fenix: true);

  Get.put(NetworkController(), permanent: true);
  Get.lazyPut(() => HomeController(Get.find()));
}
