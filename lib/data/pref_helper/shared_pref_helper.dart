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

  Future<void> saveFcmToken(final String fcmToken) async {
    await _sharedPreference.setString(PrefKeys.fcmToken, fcmToken);
  }

  String? get fcmToken {
    return _sharedPreference.getString(PrefKeys.fcmToken);
  }

  Future<void> saveBadge(final int value) async {
    await _sharedPreference.setInt(PrefKeys.badgeCount, value);
  }

  int get getBadge {
    return _sharedPreference.getInt(PrefKeys.badgeCount) ?? 0;
  }

  Future<void> savePremiumAccess(final bool value) async {
    await _sharedPreference.setBool(PrefKeys.hasPremiumAccess, value);
  }

  bool get hasPremiumAccess {
    return _sharedPreference.getBool(PrefKeys.hasPremiumAccess) ?? false;
  }

  Future<void> savePremiumProductId(final String? value) async {
    if (value == null || value.isEmpty) {
      await _sharedPreference.remove(PrefKeys.premiumProductId);
      return;
    }

    await _sharedPreference.setString(PrefKeys.premiumProductId, value);
  }

  String? get premiumProductId {
    return _sharedPreference.getString(PrefKeys.premiumProductId);
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
