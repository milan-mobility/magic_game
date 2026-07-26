import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/pref_keys.dart';
import 'package:magic_games/utils/app_enums.dart';
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

  Future<void> savePremiumPlanKey(final String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _sharedPreference.remove(PrefKeys.premiumPlanKey);
      return;
    }

    await _sharedPreference.setString(PrefKeys.premiumPlanKey, value.trim());
  }

  String? get premiumPlanKey {
    return _sharedPreference.getString(PrefKeys.premiumPlanKey);
  }

  Future<void> saveSelectedVipPlanKey(final String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _sharedPreference.remove(PrefKeys.selectedVipPlanKey);
      return;
    }

    await _sharedPreference.setString(
      PrefKeys.selectedVipPlanKey,
      value.trim(),
    );
  }

  String? get selectedVipPlanKey {
    return _sharedPreference.getString(PrefKeys.selectedVipPlanKey);
  }

  Future<void> saveSelectedLanguageCode(final String value) async {
    await _sharedPreference.setString(PrefKeys.selectedLanguageCode, value);
  }

  String get selectedLanguageCode {
    return _sharedPreference.getString(PrefKeys.selectedLanguageCode) ??
        AppLanguages.english.languageCode;
  }

  AppLanguages get selectedLanguage {
    return AppLanguages.fromLanguageCode(selectedLanguageCode);
  }

  Future<void> saveProfileName(final String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _sharedPreference.remove(PrefKeys.profileName);
      return;
    }

    await _sharedPreference.setString(PrefKeys.profileName, value.trim());
  }

  String? get profileName {
    return _sharedPreference.getString(PrefKeys.profileName);
  }

  Future<void> saveProfileAvatarAssetPath(final String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _sharedPreference.remove(PrefKeys.profileAvatarAssetPath);
      return;
    }

    await _sharedPreference.setString(
      PrefKeys.profileAvatarAssetPath,
      value.trim(),
    );
  }

  String? get profileAvatarAssetPath {
    return _sharedPreference.getString(PrefKeys.profileAvatarAssetPath);
  }

  Future<void> saveProfileAvatarFilePath(final String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _sharedPreference.remove(PrefKeys.profileAvatarFilePath);
      return;
    }

    await _sharedPreference.setString(
      PrefKeys.profileAvatarFilePath,
      value.trim(),
    );
  }

  String? get profileAvatarFilePath {
    return _sharedPreference.getString(PrefKeys.profileAvatarFilePath);
  }

  Future<void> saveGoogleProfilePhotoUrl(final String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _sharedPreference.remove(PrefKeys.googleProfilePhotoUrl);
      return;
    }

    await _sharedPreference.setString(
      PrefKeys.googleProfilePhotoUrl,
      value.trim(),
    );
  }

  String? get googleProfilePhotoUrl {
    return _sharedPreference.getString(PrefKeys.googleProfilePhotoUrl);
  }

  Future<void> saveGoogleProfileDisplayName(final String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _sharedPreference.remove(PrefKeys.googleProfileDisplayName);
      return;
    }

    await _sharedPreference.setString(
      PrefKeys.googleProfileDisplayName,
      value.trim(),
    );
  }

  String? get googleProfileDisplayName {
    return _sharedPreference.getString(PrefKeys.googleProfileDisplayName);
  }

  Future<int> incrementFavoriteGamesCount() async {
    final int updatedCount = favoriteGamesCount + 1;
    await _sharedPreference.setInt(PrefKeys.favoriteEventCount, updatedCount);
    return updatedCount;
  }

  int get favoriteGamesCount {
    return _sharedPreference.getInt(PrefKeys.favoriteEventCount) ?? 0;
  }

  Future<void> saveRecentlyPlayedGameKeys(final List<String> values) async {
    await _sharedPreference.setStringList(
      PrefKeys.recentlyPlayedGameKeys,
      values,
    );
  }

  List<String> get recentlyPlayedGameKeys {
    return _sharedPreference.getStringList(PrefKeys.recentlyPlayedGameKeys) ??
        <String>[];
  }

  int get recentlyPlayedGamesCount => recentlyPlayedGameKeys.length;

  Future<List<String>> addRecentlyPlayedGameKey(
    final String value, {
    final int maxEntries = 12,
  }) async {
    final String trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return recentlyPlayedGameKeys;
    }

    final List<String> updatedValues = recentlyPlayedGameKeys
        .where((final String key) => key.trim() != trimmedValue)
        .toList();
    updatedValues.insert(0, trimmedValue);

    if (updatedValues.length > maxEntries) {
      updatedValues.removeRange(maxEntries, updatedValues.length);
    }

    await saveRecentlyPlayedGameKeys(updatedValues);
    return updatedValues;
  }

  Future<void> clear() async {
    final List<String> arrKeysToKeep = <String>[
      PrefKeys.favoriteEventCount,
      PrefKeys.recentlyPlayedGameKeys,
      PrefKeys.premiumProductId,
      PrefKeys.premiumPlanKey,
      PrefKeys.selectedVipPlanKey,
      PrefKeys.hasPremiumAccess,
      PrefKeys.profileName,
      PrefKeys.profileAvatarAssetPath,
      PrefKeys.profileAvatarFilePath,
    ];

    final Set<String> keys = _sharedPreference.getKeys();
    for (String key in keys.toList()) {
      if (!arrKeysToKeep.contains(key)) {
        _sharedPreference.remove(key);
      }
    }
  }
}
