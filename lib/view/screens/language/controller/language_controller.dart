import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/utils/app_enums.dart';

class LanguageController extends GetxController {
  final SharedPreferenceHelper _sharedPreferenceHelper =
      Get.find<SharedPreferenceHelper>();

  late AppLanguages selectedLanguage;

  List<AppLanguages> get languages => AppLanguages.values;

  @override
  void onInit() {
    super.onInit();
    selectedLanguage = _sharedPreferenceHelper.selectedLanguage;
  }

  void selectLanguage(final AppLanguages language) {
    if (selectedLanguage == language) return;
    selectedLanguage = language;
    update();
  }

  Future<void> saveLanguage() async {
    await _sharedPreferenceHelper.saveSelectedLanguageCode(
      selectedLanguage.languageCode,
    );
    await Get.updateLocale(Locale(selectedLanguage.languageCode));
    Get.back(result: true);
  }
}
