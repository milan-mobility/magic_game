import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Utility {
  static bool checkIsNetworkUrl(final String url) {
    if (url.contains('http') || url.contains('https')) {
      return true;
    }
    return false;
  }

  static double getSafePadding({required final BuildContext context}) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return padding.bottom > 0 ? padding.bottom : 15;
  }

  static void hideKeyboard(final BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /*static Future<List<String>> getPhotos({final bool isMultiple = true}) async {
    List<String> images = <String>[];
    try {
      List<XFile> xFileList = <XFile>[];
      if (isMultiple) {
        xFileList = await ImagePicker().pickMultiImage(
          limit: 100,
          requestFullMetadata: true,
          imageQuality: 60,
        );
      } else {
        final XFile? image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          xFileList.add(image);
        }
      }
      if (xFileList.isNotNullOrEmpty()) {
        return images = xFileList
            .map(
              (final XFile e) => e.path,
            )
            .toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return images;
  }*/

  static Future<int> getAndroidOSVersion() async {
    final AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  static Future<String> getPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static void moreGames({required final String androidUrl,required final String iOSUrl}) {
    try {
      String appUrl = '';
      if (Platform.isAndroid) {
        appUrl = androidUrl;
      } else if (Platform.isIOS) {
        appUrl = iOSUrl;
      }
      final ShareParams params = ShareParams(
        title: 'Take control of your money with AccountPundit!',
        text:
            'Take control of your money with AccountPundit! Track income, expenses & budgets — all in one place. Download it free: $appUrl',
      );
      SharePlus.instance.share(params);
    } catch (e) {
      debugPrint("EXCEPTION=>${e.toString()}");
    }
  }

  static void shareApp() {
    try {
      String appUrl = '';
      if (Platform.isAndroid) {
        appUrl =
            'https://play.google.com/store/apps/details?id=com.zealouscommerce.accountpundit';
      } else if (Platform.isIOS) {
        appUrl = 'https://apps.apple.com/app/id6783215345';
      }
      final ShareParams params = ShareParams(
        title: 'Take control of your money with AccountPundit!',
        text:
            'Take control of your money with AccountPundit! Track income, expenses & budgets — all in one place. Download it free: $appUrl',
      );
      SharePlus.instance.share(params);
    } catch (e) {
      debugPrint("EXCEPTION=>${e.toString()}");
    }
  }

  static Future<void> reviewApp() async {
    if (Platform.isAndroid) {
      await InAppReview.instance.openStoreListing(
        appStoreId: 'com.zealouscommerce.accountpundit',
      );
    } else if (Platform.isIOS) {
      await InAppReview.instance.openStoreListing(appStoreId: '6783215345');
    }
  }

  static Future<void> sendEmail({
    required String email,
    String subject = '',
    String body = '',
  }) async {
    if (email.isEmpty) {
      showErrorSnackBar(message: 'Email address is not available');
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject, 'body': body},
    );

    try {
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        showErrorSnackBar(message: 'No email app found');
      }
    } catch (e) {
      showErrorSnackBar(message: 'No email app found');
    }
  }
}
