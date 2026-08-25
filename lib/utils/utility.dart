import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/extensions/list_extension.dart';
import 'package:magic_games/helpers/services/auth_service.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/app_constants.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Utility {
  static const String feedbackSupportEmail = 'support@oneupitsolution.com';

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

  static Future<List<String>> getPhotos({final bool isMultiple = true}) async {
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
        final XFile? image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          xFileList.add(image);
        }
      }
      if (xFileList.isNotNullOrEmpty()) {
        return images = xFileList.map((final XFile e) => e.path).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return images;
  }

  static Future<int> getAndroidOSVersion() async {
    final AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  static Future<String> getPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static Future<String> getDeviceModel() async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await deviceInfoPlugin.androidInfo;
        return androidInfo.model;
      }
      if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        return iosInfo.utsname.machine;
      }
    } catch (e) {
      debugPrint("EXCEPTION=>${e.toString()}");
    }
    return '';
  }

  static Future<String> getOperatingSystemVersion() async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release}'.trim();
      }
      if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        return 'iOS ${iosInfo.systemVersion}'.trim();
      }
    } catch (e) {
      debugPrint("EXCEPTION=>${e.toString()}");
    }
    return Platform.operatingSystem;
  }

  static void logout() {
    final SharedPreferenceHelper sharedPref =
        Get.find<SharedPreferenceHelper>();
    sharedPref.clear();
    Get.offAllNamed(RouteHelper.home);
  }

  static void moreGames({
    required final String androidUrl,
    required final String iOSUrl,
  }) {
    try {
      String appUrl = '';
      if (Platform.isAndroid) {
        appUrl = androidUrl;
      } else if (Platform.isIOS) {
        appUrl = iOSUrl;
      }
      final ShareParams params = ShareParams(
        title: 'Game'.tr,
        text: 'Game: @url'.trParams(<String, String>{'url': appUrl}),
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
            'https://play.google.com/store/apps/details?id=com.oneup.onegameplus&hl=en_IN';
      } else if (Platform.isIOS) {
        appUrl = 'https://apps.apple.com/app/idYOUR_APP_ID';
      }

      final ShareParams params = ShareParams(
        title: 'One Game+ – Multiple Games, Endless Fun!'.tr,
        text:
            '''
🎮 One Game+, endless fun!

Play a collection of fun and exciting games all in one app. Challenge yourself, beat your high scores, and discover your next favorite game!

🔥 Multiple games in one app
🏆 Challenge yourself & score higher
🎯 Quick, fun and easy to play
🎮 Something for everyone

Download One Game+ and start playing now:
$appUrl
''',
      );

      SharePlus.instance.share(params);
    } catch (e) {
      debugPrint('EXCEPTION=>${e.toString()}');
    }
  }

  static Future<void> reviewApp() async {
    if (Platform.isAndroid) {
      await InAppReview.instance.openStoreListing(
        appStoreId: 'com.oneup.onegameplus',
      );
    } else if (Platform.isIOS) {
      await InAppReview.instance.openStoreListing(appStoreId: '');
    }
  }

  static Future<void> sendEmail({
    required String email,
    String subject = '',
    String body = '',
  }) async {
    if (email.isEmpty) {
      showErrorSnackBar(message: 'Email address is not available'.tr);
      return;
    }

    final List<String> queryParts = <String>[];
    if (subject.trim().isNotEmpty) {
      queryParts.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body.trim().isNotEmpty) {
      queryParts.add('body=${Uri.encodeComponent(body)}');
    }

    final Uri emailUri = Uri.parse(
      'mailto:$email${queryParts.isEmpty ? '' : '?${queryParts.join('&')}'}',
    );

    try {
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        showErrorSnackBar(message: 'No email app found'.tr);
      }
    } catch (e) {
      showErrorSnackBar(message: 'No email app found'.tr);
    }
  }

  static Future<void> openUrl(final String url) async {
    final Uri emailUri = Uri.parse(url);

    try {
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        showErrorSnackBar(message: 'No email app found'.tr);
      }
    } catch (e) {
      showErrorSnackBar(message: 'No email app found'.tr);
    }
  }

  /// Opens a game's listing from either a complete store URL or its store ID.
  /// iOS game records contain the numeric App Store ID; Android records contain
  /// the Google Play package ID.
  static Future<bool> openGameStoreListing(final String storeUrl) async {
    final String value = storeUrl.trim();
    if (value.isEmpty) {
      return false;
    }

    final Uri? uri;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      uri = Uri.tryParse(value);
    } else if (GetPlatform.isIOS) {
      final String appStoreId = value.startsWith('id')
          ? value.substring(2)
          : value;
      uri = Uri.tryParse('https://apps.apple.com/app/id$appStoreId');
    } else {
      uri = Uri.tryParse(
        'https://play.google.com/store/apps/details?id=$value',
      );
    }

    if (uri == null) {
      return false;
    }

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> sendFeedbackEmail({
    String? gameName,
    String userId = '',
    String userEmail = '',
    String userName = '',
  }) async {
    final String country = _deviceCountryCode();
    final String appVersion = await getPackageInfo();
    final _EmailUserContext userContext = _resolveEmailUserContext(
      userId: userId,
      userEmail: userEmail,
      userName: userName,
    );

    await sendEmail(
      email: feedbackSupportEmail,
      subject: '${AppConstants.appName} Feedback'.tr,
      body: buildFeedbackEmailTemplate(
        gameName: gameName ?? AppConstants.appName,
        appVersion: appVersion,
        country: country,
        userId: userContext.userId,
        userEmail: userContext.userEmail,
        userName: userContext.userName,
      ),
    );
  }

  static String _deviceCountryCode() {
    final List<Locale> locales =
        WidgetsBinding.instance.platformDispatcher.locales;

    for (final Locale locale in locales) {
      final String? countryCode = locale.countryCode;
      if (countryCode != null && countryCode.isNotEmpty) {
        return countryCode.toUpperCase();
      }
    }

    return '';
  }

  static Future<void> sendHelpSupportEmail({
    String userId = '',
    String userEmail = '',
    String userName = '',
  }) async {
    final String country = _deviceCountryCode();
    final String deviceModel = await getDeviceModel();
    final String operatingSystem = await getOperatingSystemVersion();
    final _EmailUserContext userContext = _resolveEmailUserContext(
      userId: userId,
      userEmail: userEmail,
      userName: userName,
    );

    await sendEmail(
      email: feedbackSupportEmail,
      subject: '${AppConstants.appName} Help & Support'.tr,
      body: buildHelpSupportEmailTemplate(
        deviceModel: deviceModel,
        operatingSystem: operatingSystem,
        country: country,
        userId: userContext.userId,
        userEmail: userContext.userEmail,
        userName: userContext.userName,
      ),
    );
  }

  static Future<void> sendHelpSupportEmailFromEvent({
    String userId = '',
    String userEmail = '',
    String userName = '',
    String gameName = '',
  }) async {
    final String country = _deviceCountryCode();
    final String deviceModel = await getDeviceModel();
    final String operatingSystem = await getOperatingSystemVersion();
    final _EmailUserContext userContext = _resolveEmailUserContext(
      userId: userId,
      userEmail: userEmail,
      userName: userName,
    );

    await sendEmail(
      email: feedbackSupportEmail,
      subject:
          'Support ${AppConstants.appName} ${GetPlatform.isAndroid ? 'Android (Play)' : 'iOS'} - ${userContext.userId}'
              .tr,
      body: buildHelpSupportEmailTemplate(
        deviceModel: deviceModel,
        operatingSystem: operatingSystem,
        country: country,
        userId: userContext.userId,
        userEmail: userContext.userEmail,
        userName: userContext.userName,
        gameName: gameName,
      ),
    );
  }

  static String buildFeedbackEmailTemplate({
    required String gameName,
    required String appVersion,
    required String country,
    String userId = '',
    String userEmail = '',
    String userName = '',
  }) {
    final _EmailUserContext userContext = _resolveEmailUserContext(
      userId: userId,
      userEmail: userEmail,
      userName: userName,
    );
    final StringBuffer buffer = StringBuffer()
      ..writeln('Hello OneGame+ Team,'.tr)
      ..writeln()
      ..writeln('Thank you for creating OneGame+!'.tr)
      ..writeln()
      ..writeln(
        'I enjoy using your app and would like to share my feedback.'.tr,
      )
      ..writeln()
      ..writeln('${'Game Name:'.tr} $gameName')
      ..writeln('${'App Version:'.tr} $appVersion')
      ..writeln()
      ..writeln('My Feedback:'.tr)
      ..writeln()
      ..writeln('Please write your feedback, suggestions, or ideas here.'.tr)
      ..writeln()
      ..writeln('What I Like :'.tr)
      ..writeln()
      ..writeln()
      ..writeln('Suggestions for Improvement:'.tr)
      ..writeln()
      ..writeln()
      ..writeln('Feature Requests (Optional)'.tr)
      ..writeln()
      ..writeln()
      ..writeln(
        'Thank you for taking the time to read my feedback. I appreciate your efforts to improve OneGame+ and look forward to future updates.'
            .tr,
      )
      ..writeln()
      ..writeln('${'Country:'.tr} $country');

    if (userContext.userId.isNotEmpty) {
      buffer.writeln('${'User ID:'.tr} ${userContext.userId}');
    }

    if (userContext.userEmail.isNotEmpty) {
      buffer.writeln('${'Email:'.tr} ${userContext.userEmail}');
    }

    buffer
      ..writeln()
      ..writeln('Best regards,'.tr)
      ..writeln(userContext.userName.isEmpty ? '' : userContext.userName);

    return buffer.toString().trimRight();
  }

  static String buildHelpSupportEmailTemplate({
    required String deviceModel,
    required String operatingSystem,
    required String country,
    String userId = '',
    String userEmail = '',
    String userName = '',
    String gameName = '',
  }) {
    final _EmailUserContext userContext = _resolveEmailUserContext(
      userId: userId,
      userEmail: userEmail,
      userName: userName,
    );
    final StringBuffer buffer = StringBuffer()
      ..writeln('Hello OneGame+ Support Team,'.tr)
      ..writeln()
      ..writeln('Thank you for creating OneGame+!'.tr)
      ..writeln()
      ..writeln(
        'I need assistance with an issue in the app. Please find my details below.'
            .tr,
      )
      ..writeln()
      ..writeln('Issue Description:'.tr)
      ..writeln('<Please describe your issue here>'.tr)
      ..writeln()
      ..writeln(
        'If possible, please attach screenshots or screen recordings.'.tr,
      )
      ..writeln('${'Game Name:'.tr} $gameName')
      ..writeln('${'Device Model:'.tr} $deviceModel')
      ..writeln('${'Operating System:'.tr} $operatingSystem')
      ..writeln('${'Country:'.tr} $country');

    if (userContext.userId.isNotEmpty) {
      buffer.writeln('${'User ID:'.tr} ${userContext.userId}');
    }

    if (userContext.userEmail.isNotEmpty) {
      buffer.writeln('${'Email:'.tr} ${userContext.userEmail}');
    }

    buffer
      ..writeln()
      ..writeln('Thank you for your time and support.'.tr)
      ..writeln()
      ..writeln(userContext.userName.isEmpty ? '' : 'Best regards,'.tr)
      ..writeln(userContext.userName.isEmpty ? '' : userContext.userName);

    return buffer.toString().trimRight();
  }

  static Future<void> rateUs() async {
    if (Platform.isAndroid) {
      await InAppReview.instance.openStoreListing(
        appStoreId: 'com.oneup.onegameplus',
      );
    } else if (Platform.isIOS) {
      await InAppReview.instance.openStoreListing(appStoreId: '6788318469');
    }
  }

  static _EmailUserContext _resolveEmailUserContext({
    String userId = '',
    String userEmail = '',
    String userName = '',
  }) {
    String resolvedUserId = userId.trim();
    String resolvedUserEmail = userEmail.trim();
    String resolvedUserName = userName.trim();

    if (Get.isRegistered<AuthService>()) {
      final AuthService authService = Get.find<AuthService>();
      final bool isLoggedIn = authService.currentUser != null;

      if (isLoggedIn) {
        resolvedUserId = resolvedUserId.isNotEmpty
            ? resolvedUserId
            : (authService.currentUser?.uid ?? '').trim();
        resolvedUserEmail = resolvedUserEmail.isNotEmpty
            ? resolvedUserEmail
            : (authService.currentUser?.email ?? '').trim();
        resolvedUserName = resolvedUserName.isNotEmpty
            ? resolvedUserName
            : (authService.currentDisplayName ?? '').trim();
      }
    }

    return _EmailUserContext(
      userId: resolvedUserId,
      userEmail: resolvedUserEmail,
      userName: resolvedUserName,
    );
  }
}

class _EmailUserContext {
  const _EmailUserContext({
    required this.userId,
    required this.userEmail,
    required this.userName,
  });

  final String userId;
  final String userEmail;
  final String userName;
}
