import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/routes/route_helper.dart';

class SplashController extends GetxController {
  SplashController(this.sharedPref);

  final SharedPreferenceHelper sharedPref;

  @override
  void onInit() {
    super.onInit();
    _moveScreen();
  }

  Future<void> _moveScreen() async {
    await Future.delayed(Duration(milliseconds: 2000));

    Get.offAllNamed(
      sharedPref.isIntroDone ? RouteHelper.home : RouteHelper.welcomeScreen,
    );
  }
}
