import 'dart:io';

import 'package:get/get_utils/src/platform/platform.dart';
import 'package:magic_games/utils/app_constants.dart';

class AdHelper {
  static String get interstitialAdUnitId {
    if (GetPlatform.isAndroid) {
      return AppConstants.interstitialAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.interstitialIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (GetPlatform.isAndroid) {
      return AppConstants.rewardAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.rewardIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
