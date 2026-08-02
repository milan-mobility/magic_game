import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/controller/loader_controller.dart';

class Loader {
  static final LoaderController _controller = Get.find();

  // static void load(bool value) {
  //   if (value) {
  //     _controller.show();
  //   } else {
  //     _controller.hide();
  //   }
  // }

  static Future<void> load(final bool value) async {
    if (value) {
      await EasyLoading.show(
        status: 'Loading...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
      );
    } else {
      await EasyLoading.dismiss();
    }
  }
}
