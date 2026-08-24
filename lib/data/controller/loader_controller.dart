import 'package:get/get.dart';

class LoaderController extends GetxController implements GetxService {
  final RxBool isLoading = false.obs;

  void show() {
    if (!isLoading.value) isLoading.value = true;
  }

  void hide() => isLoading.value = false;
}
