import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  final SharedPreferences _sharedPreference = Get.find<SharedPreferences>();

  Future<void> saveIsLoggedIn(final bool value) async {
    await _sharedPreference.setBool(PrefKeys.isLoggedIn, value);
  }

  bool get isLoggedIn {
    return _sharedPreference.getBool(PrefKeys.isLoggedIn) ?? false;
  }

  Future<void> saveIntroDone(final bool value) async {
    await _sharedPreference.setBool(PrefKeys.hasIntroDone, value);
  }

  bool get isIntroDone {
    return _sharedPreference.getBool(PrefKeys.hasIntroDone) ?? false;
  }

  Future<void> clear() async {
    final List<String> arrKeysToKeep = <String>[
      // PrefKeys.addTransactionGuide,
    ];

    final Set<String> keys = _sharedPreference.getKeys();
    for (String key in keys.toList()) {
      if (!arrKeysToKeep.contains(key)) {
        _sharedPreference.remove(key);
      }
    }
  }
}
