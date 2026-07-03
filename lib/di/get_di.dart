import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/api/dio_client.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/data/repositories/api_repo.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> init() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  // Initialize notifications asynchronously so it doesn't block the app startup (splash screen)

  Get.put(sharedPreferences);
  Get.put(SharedPreferenceHelper());
  Get.lazyPut(() => DioClient(Dio()));

  Get.lazyPut(() => ApiRepo(Get.find()), fenix: true);

  /*Get.put(
    NetworkController(),
    permanent: true,
  );*/
  Get.lazyPut(() => HomeController(Get.find()));
}
