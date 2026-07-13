import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/utility.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';

class ProfileController extends GetxController {
  final String playerName = 'Guest Player';
  final String playerType = 'Guest';
  final String description =
      'Play games, ear achievement and\nsave your progress';
  String appearanceLabel = 'Dark';
  String languageLabel = 'English';
  String appVersionLabel = '1.0.0';

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  final List<ProfileStatData> stats = const <ProfileStatData>[
    ProfileStatData(
      value: '24',
      label: 'Game Played',
      iconAsset: 'assets/svg/ic_total_game.svg',
    ),
    ProfileStatData(
      value: '128',
      label: 'Achievement',
      iconAsset: 'assets/svg/ic_profile_star.svg',
    ),
    ProfileStatData(
      value: '12',
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

  void onEditTap() {}

  void onLogoutTap() {}

  void onAppearanceTap() {
    appearanceLabel = appearanceLabel == 'Dark' ? 'Light' : 'Dark';
    update();
    showSuccessSnackBar(message: 'Appearance switched to $appearanceLabel.');
  }

  void onLanguageTap() {
    languageLabel = languageLabel == 'English' ? 'Hindi' : 'English';
    update();
    showSuccessSnackBar(message: 'Language changed to $languageLabel.');
  }

  void onHelpTap() {
    Utility.sendHelpSupportEmail();
  }

  void onFeedbackTap() {
    Utility.sendFeedbackEmail();
  }

  void onTermsTap() {
    Get.toNamed(
      RouteHelper.commonWebView,
      arguments: <String, String>{
        'title': 'Terms of service'.tr,
        'url':
            'https://oneupapps.oneupitsolution.com/onegameplus/privacy-policy.html',
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
