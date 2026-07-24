import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/services/premium_access_service.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/view/base/controller/network_controller.dart';

class SplashController extends GetxController {
  SplashController(this.sharedPref);

  final SharedPreferenceHelper sharedPref;

  @override
  void onInit() {
    super.onInit();
    _moveScreen();
  }

  Future<void> _moveScreen() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    final NetworkController networkController = Get.find<NetworkController>();
    await networkController.startupCheckCompleted;
    await Get.find<PremiumAccessService>().refreshPremiumAccess();

    if (networkController.shouldBlockStartupNavigation) {
      return;
    }

    Get.offAllNamed(
      sharedPref.isIntroDone ? RouteHelper.home : RouteHelper.welcomeScreen,
    );
  }
}
