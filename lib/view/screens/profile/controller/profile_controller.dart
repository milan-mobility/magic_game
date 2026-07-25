import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/services/auth_service.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/utility.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';
import 'package:magic_games/view/screens/profile/widgets/profile_edit_dialog.dart';
import 'package:path_provider/path_provider.dart';

class ProfileController extends GetxController {
  static const List<String> builtInAvatarAssetPaths = <String>[
    'assets/png/profile_pic/ic_profile_1.png',
    'assets/png/profile_pic/ic_profile_2.png',
    'assets/png/profile_pic/ic_profile_3.png',
    'assets/png/profile_pic/ic_profile_4.png',
    'assets/png/profile_pic/ic_profile_5.png',
    'assets/png/profile_pic/ic_profile_6.png',
    'assets/png/profile_pic/ic_profile_7.png',
  ];

  final SharedPreferenceHelper _sharedPreferenceHelper =
      Get.find<SharedPreferenceHelper>();
  final AuthService _authService = Get.find<AuthService>();
  StreamSubscription<User?>? _authSubscription;

  String playerName = 'Guest Player';
  String playerType = 'Guest';
  String description = 'Play games, earn achievements and\nsave your progress';
  String appearanceLabel = 'Dark';
  String languageLabel = 'English';
  String appVersionLabel = '1.0.0';
  bool isLoggedIn = false;
  bool isAuthActionInProgress = false;
  String? avatarAssetPath = builtInAvatarAssetPaths.first;
  String? avatarFilePath;
  String? avatarImageUrl;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedLanguage();
    _loadAppVersion();
    _syncAuthState();
    _authSubscription = _authService.authStateChanges().listen((final User? _) {
      _syncAuthState();
    });
  }

  List<ProfileStatData> get stats => <ProfileStatData>[
    const ProfileStatData(
      value: '24', //show total game played.
      label: 'Game Played',
      iconAsset: 'assets/svg/ic_total_game.svg',
    ),
    ProfileStatData(
      value: _sharedPreferenceHelper.favoriteGamesCount.toString(),
      label: 'Achievement',
      iconAsset: 'assets/svg/ic_profile_star.svg',
    ),
    ProfileStatData(
      value: _sharedPreferenceHelper.favoriteGamesCount.toString(),
      label: 'Favorites',
      iconAsset: 'assets/svg/ic_fvrt.svg',
    ),
  ];

  List<ProfileOptionSectionData> get optionSections =>
      <ProfileOptionSectionData>[
        ProfileOptionSectionData(
          title: 'Preferences',
          items: <ProfileOptionItemData>[
            // ProfileOptionItemData(
            //   title: 'Appearance',
            //   subtitle: 'Choose your theme',
            //   iconAsset: 'assets/svg/ic_star.svg',
            //   valueText: appearanceLabel,
            //   valueStyle: ProfileOptionValueStyle.badge,
            //   onTap: onAppearanceTap,
            // ),
            ProfileOptionItemData(
              title: 'Language',
              subtitle: 'Change app language',
              iconAsset: 'assets/svg/ic_language.svg',
              valueText: languageLabel,
              onTap: onLanguageTap,
            ),
          ],
        ),
        ProfileOptionSectionData(
          title: 'Support',
          items: <ProfileOptionItemData>[
            ProfileOptionItemData(
              title: 'Help & Support',
              subtitle: 'Get help and contact us',
              iconAsset: 'assets/svg/ic_help.svg',
              onTap: onHelpTap,
            ),
            ProfileOptionItemData(
              title: 'Feedback',
              subtitle: 'Share your thoughts',
              iconAsset: 'assets/svg/ic_feedback.svg',
              onTap: onFeedbackTap,
            ),
          ],
        ),
        ProfileOptionSectionData(
          title: 'About',
          items: <ProfileOptionItemData>[
            ProfileOptionItemData(
              title: 'Terms of service',
              subtitle: 'Review the app usage terms',
              iconAsset: 'assets/svg/ic_terms.svg',
              onTap: onTermsTap,
            ),
            ProfileOptionItemData(
              title: 'Privacy Policy',
              subtitle: 'Learn how your data is handled',
              iconAsset: 'assets/svg/ic_privacy.svg',
              onTap: onPrivacyTap,
            ),
            ProfileOptionItemData(
              title: 'App Version',
              subtitle: 'Current installed release',
              iconAsset: 'assets/svg/ic_app_version.svg',
              valueText: appVersionLabel,
            ),
          ],
        ),
      ];

  Future<void> onEditTap() async {
    final ProfileEditResult? result = await showProfileEditDialog(
      initialName: _initialDialogName,
      avatarAssetPaths: builtInAvatarAssetPaths,
      initialSelectedAssetPath: _dialogInitialAvatarAssetPath,
      initialSelectedFilePath: avatarFilePath,
    );

    if (result == null) {
      return;
    }

    await _saveProfileChanges(result);
  }

  String get actionButtonLabel {
    if (isAuthActionInProgress) {
      return isLoggedIn ? 'Logging out...'.tr : 'Signing in...'.tr;
    }
    return isLoggedIn ? 'Log out'.tr : 'Log in with Google'.tr;
  }

  Future<void> onLoginTap() async {
    if (isAuthActionInProgress) {
      return;
    }

    isAuthActionInProgress = true;
    update();

    try {
      await _authService.signInWithGoogle();
      _syncAuthState();
      showSuccessSnackBar(message: 'Signed in successfully.'.tr);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      showErrorSnackBar(
        message: e.description ?? 'Google sign-in failed. Please try again.'.tr,
      );
    } on FirebaseAuthException catch (e) {
      showErrorSnackBar(
        message:
            e.message ?? 'Unable to sign in right now. Please try again.'.tr,
      );
    } on AuthException catch (e) {
      showErrorSnackBar(message: e.message);
    } catch (_) {
      showErrorSnackBar(
        message:
            'Unable to sign in right now. Please verify your Firebase Google Sign-In setup.'
                .tr,
      );
    } finally {
      isAuthActionInProgress = false;
      update();
    }
  }

  Future<void> onLogoutTap() async {
    if (isAuthActionInProgress) {
      return;
    }

    isAuthActionInProgress = true;
    update();

    try {
      await _authService.signOut();
      _syncAuthState();
      showSuccessSnackBar(message: 'Logged out successfully.'.tr);
    } on FirebaseAuthException catch (e) {
      showErrorSnackBar(
        message:
            e.message ?? 'Unable to log out right now. Please try again.'.tr,
      );
    } catch (_) {
      showErrorSnackBar(
        message: 'Unable to log out right now. Please try again.'.tr,
      );
    } finally {
      isAuthActionInProgress = false;
      update();
    }
  }

  void onAppearanceTap() {
    appearanceLabel = appearanceLabel == 'Dark' ? 'Light' : 'Dark';
    update();
    showSuccessSnackBar(
      message: 'Appearance switched to'.trParams(<String, String>{
        'value': appearanceLabel.tr,
      }),
    );
  }

  Future<void> onLanguageTap() async {
    final dynamic result = await Get.toNamed(RouteHelper.language);
    if (result == true) {
      _loadSelectedLanguage();
      showSuccessSnackBar(
        message: 'Language changed to'.trParams(<String, String>{
          'value': languageLabel,
        }),
      );
    }
  }

  void onHelpTap() {
    Utility.sendHelpSupportEmail(
      userId: _authService.currentUser?.uid ?? '',
      userEmail: isLoggedIn ? (_authService.currentUser?.email ?? '') : '',
      userName: isLoggedIn ? playerName : '',
    );
  }

  void onFeedbackTap() {
    Utility.sendFeedbackEmail(
      userId: _authService.currentUser?.uid ?? '',
      userEmail: isLoggedIn ? (_authService.currentUser?.email ?? '') : '',
      userName: isLoggedIn ? playerName : '',
    );
  }

  void onTermsTap() {
    Get.toNamed(
      RouteHelper.commonWebView,
      arguments: <String, String>{
        'title': 'Terms of service'.tr,
        'url':
            'https://oneupapps.oneupitsolution.com/onegameplus/terms-of-use.html',
      },
    );
  }

  void onPrivacyTap() {
    Get.toNamed(
      RouteHelper.commonWebView,
      arguments: <String, String>{
        'title': 'Privacy Policy'.tr,
        'url':
            'https://oneupapps.oneupitsolution.com/onegameplus/privacy-policy.html',
      },
    );
  }

  void onVersionTap() {}

  Future<void> _loadAppVersion() async {
    appVersionLabel = await Utility.getPackageInfo();
    update();
  }

  void _loadSelectedLanguage() {
    languageLabel = _sharedPreferenceHelper.selectedLanguage.nativeTitle;
    update();
  }

  void _syncAuthState() {
    final User? user = _authService.currentUser;
    isLoggedIn = user != null;
    playerName = _resolvePlayerName();
    playerType = isLoggedIn ? 'Player'.tr : 'Guest'.tr;
    description = 'Play games, earn achievements and\nsave your progress'.tr;
    avatarImageUrl = _normalizedValue(_authService.currentPhotoUrl);
    avatarAssetPath = _normalizedValue(
      _sharedPreferenceHelper.profileAvatarAssetPath,
    );
    avatarFilePath = _resolveStoredAvatarFilePath();
    update();
  }

  String _resolvePlayerName() {
    final String? googleName = _normalizedValue(
      _authService.currentDisplayName,
    );
    if (googleName != null) {
      return googleName;
    }

    final String? storedName = _normalizedValue(
      _sharedPreferenceHelper.profileName,
    );
    if (storedName != null) {
      return storedName;
    }

    return 'Guest Player';
  }

  String get _initialDialogName {
    final String? storedName = _normalizedValue(
      _sharedPreferenceHelper.profileName,
    );
    if (storedName != null) {
      return storedName;
    }

    return isLoggedIn ? playerName : '';
  }

  String? get _dialogInitialAvatarAssetPath {
    if (avatarAssetPath != null) {
      return avatarAssetPath;
    }

    return avatarFilePath == null && avatarImageUrl == null
        ? builtInAvatarAssetPaths.first
        : null;
  }

  String? _resolveStoredAvatarFilePath() {
    final String? storedPath = _normalizedValue(
      _sharedPreferenceHelper.profileAvatarFilePath,
    );
    if (storedPath == null) {
      return null;
    }

    if (!File(storedPath).existsSync()) {
      unawaited(_sharedPreferenceHelper.saveProfileAvatarFilePath(null));
      return null;
    }

    return storedPath;
  }

  Future<void> _saveProfileChanges(final ProfileEditResult result) async {
    await _sharedPreferenceHelper.saveProfileName(result.name);

    if (_normalizedValue(result.selectedFilePath) != null) {
      final String persistedFilePath = await _persistAvatarFile(
        result.selectedFilePath!,
      );
      await _sharedPreferenceHelper.saveProfileAvatarFilePath(
        persistedFilePath,
      );
      await _sharedPreferenceHelper.saveProfileAvatarAssetPath(null);
    } else {
      await _deleteStoredAvatarFileIfNeeded();
      await _sharedPreferenceHelper.saveProfileAvatarFilePath(null);
      await _sharedPreferenceHelper.saveProfileAvatarAssetPath(
        result.selectedAssetPath,
      );
    }

    _syncAuthState();
    showSuccessSnackBar(message: 'Profile updated successfully.'.tr);
  }

  Future<String> _persistAvatarFile(final String sourcePath) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final Directory profileDirectory = Directory(
      '${directory.path}/profile_images',
    );

    if (!profileDirectory.existsSync()) {
      await profileDirectory.create(recursive: true);
    }

    await _deleteStoredAvatarFileIfNeeded();

    final String extension = _extractFileExtension(sourcePath);
    final String targetPath =
        '${profileDirectory.path}/selected_profile_avatar_${DateTime.now().millisecondsSinceEpoch}$extension';

    final File sourceFile = File(sourcePath);
    if (sourceFile.path == targetPath) {
      return targetPath;
    }

    final File savedFile = await sourceFile.copy(targetPath);
    return savedFile.path;
  }

  Future<void> _deleteStoredAvatarFileIfNeeded() async {
    final String? existingFilePath = _normalizedValue(
      _sharedPreferenceHelper.profileAvatarFilePath,
    );
    if (existingFilePath == null) {
      return;
    }

    final File existingFile = File(existingFilePath);
    if (await existingFile.exists()) {
      await existingFile.delete();
    }
  }

  String _extractFileExtension(final String filePath) {
    final String fileName = filePath.split('/').last;
    final int extensionIndex = fileName.lastIndexOf('.');
    if (extensionIndex == -1) {
      return '.png';
    }

    return fileName.substring(extensionIndex);
  }

  String? _normalizedValue(final String? value) {
    if (value == null) {
      return null;
    }

    final String trimmedValue = value.trim();
    return trimmedValue.isEmpty ? null : trimmedValue;
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}

class ProfileStatData {
  const ProfileStatData({
    required this.value,
    required this.label,
    required this.iconAsset,
  });

  final String value;
  final String label;
  final String iconAsset;
}

class ProfileOptionSectionData {
  const ProfileOptionSectionData({required this.title, required this.items});

  final String title;
  final List<ProfileOptionItemData> items;
}

class ProfileOptionItemData {
  const ProfileOptionItemData({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    this.valueText,
    this.valueStyle = ProfileOptionValueStyle.text,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final String? valueText;
  final ProfileOptionValueStyle valueStyle;
  final VoidCallback? onTap;
}

enum ProfileOptionValueStyle { text, badge }
