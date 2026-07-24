import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/ads/ads_services.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/utils/utility.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameDetailController extends GetxController {
  final SharedPreferenceHelper _sharedPreferenceHelper =
      Get.find<SharedPreferenceHelper>();
  late WebViewController webViewController;
  bool _isShowingInterstitial = false;
  bool _isShowingRewarded = false;

  Games? games;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      games = Get.arguments['game'];
    }
    unawaited(_applyPreferredOrientation());
    webViewController = WebViewController();
    loadUrl();
  }

  void loadUrl() {
    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    webViewController.setOnConsoleMessage((JavaScriptConsoleMessage message) {
      debugPrint(
        '[WEBVIEW_JS]'
        '[${message.level.name.toUpperCase()}] '
        '${message.message}',
      );
    });
    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) {
          debugPrint('Page started: $url');
        },
        onPageFinished: (String url) async {
          debugPrint('Page finished: $url — notifying JS');
          try {
            await webViewController.runJavaScript(
              "if (typeof onFlutterReady === 'function') onFlutterReady();",
            );
          } catch (e) {
            debugPrint('onFlutterReady JS error: $e');
          }
        },
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );

    webViewController.addJavaScriptChannel(
      'FlutterChannel',
      onMessageReceived: (final JavaScriptMessage message) {
        _handleWebMessage(message.message);
      },
    );

    debugPrint("GAME URL=>${games?.gameurl}");
    webViewController.loadRequest(Uri.parse(games?.gameurl ?? ''));
  }

  void _handleWebMessage(final String message) {
    final _WebMessage webMessage = _parseWebMessage(message);

    switch (webMessage.command) {
      case 'loadInterstitial':
        AdService.preloadInterstitial();
        break;

      case 'loadRewardedAd':
        AdService.preloadRewardedAd();
        break;

      case 'gameStart':
        break;

      case 'showInterstitial':
        if (_isShowingInterstitial) return;
        _isShowingInterstitial = true;
        _sendCallbackToJs('GamePause');
        final shownI = AdService.showInterstitial(
          onDismissed: () {
            _isShowingInterstitial = false;
            _sendCallbackToJs('GameResume');
            _sendCallbackToJs('interstitialClosed');
          },
        );
        if (!shownI) {
          _isShowingInterstitial = false;
          _sendCallbackToJs('GameResume');
        }
        break;
      case 'showRewardedPlus':
        if (_isShowingRewarded) return;
        _isShowingRewarded = true;
        _sendCallbackToJs('GamePause');
        final shownR = AdService.showRewardedAd(
          onDismissed: () {
            _isShowingRewarded = false;
            _sendCallbackToJs('GameResume');
            _sendCallbackToJs('rewardEarned');
          },
        );
        if (!shownR) {
          _isShowingRewarded = false;
          _sendCallbackToJs('GameResume');
        }
        break;

      case 'sendFirebaseEvent':
        break;

      case 'addHeart':
        //Profile heart +1 increment always
        _addCurrentGameToFavorites();
        break;

      case 'addVibration':
        //VIBRATE DEVICE WHEN IT'S FIRE
        HapticFeedback.mediumImpact();
        break;

      case 'openMailComposer':
        Utility.sendFeedbackEmail();
        break;

      case 'moreGames':
        //iOS: Will be given
        Utility.moreGames(
          androidUrl:
              'https://play.google.com/store/apps/dev?id=6417410772580581502',
          iOSUrl: '',
        );
        break;

      case 'rateUs':
        // Current app rate us
        Utility.reviewApp();
        break;

      case 'shareApp':
        // Share this app
        Utility.shareApp();
        break;

      case 'showToastMessgae':
        _showToastMessage(webMessage.payload);
        break;

      case 'openURL':
        Utility.openUrl(webMessage.payload);
        break;

      default:
        debugPrint('Unknown message from JS: $message');
    }
  }

  _WebMessage _parseWebMessage(final String rawMessage) {
    final int separatorIndex = rawMessage.indexOf(':');
    if (separatorIndex == -1) {
      return _WebMessage(command: rawMessage.trim(), payload: '');
    }

    return _WebMessage(
      command: rawMessage.substring(0, separatorIndex).trim(),
      payload: rawMessage.substring(separatorIndex + 1).trim(),
    );
  }

  void _showToastMessage(final String message) {
    if (message.isEmpty) {
      return;
    }

    Get.closeAllSnackbars();
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: AppColors.themeColor,
        messageText: Text(
          message,
          style: poppinsW400.copyWith(
            fontSize: AppResponsive.font(15),
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        maxWidth: 500,
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.only(
          left: AppResponsive.space(10.0),
          right: AppResponsive.space(10.0),
          bottom: AppResponsive.space(30.0),
        ),
        borderRadius: AppResponsive.space(5),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.BOTTOM,
      ),
    );
  }

  Future<void> _addCurrentGameToFavorites() async {
    final String? favoriteGameKey = _favoriteGameKey;
    if (favoriteGameKey == null) {
      return;
    }

    await _sharedPreferenceHelper.addFavoriteGameKey(favoriteGameKey);

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().update();
    }
  }

  String? get _favoriteGameKey {
    if (games?.id != null) {
      return 'game_${games!.id}';
    }

    final String? gameUrl = games?.gameurl?.trim();
    if (gameUrl != null && gameUrl.isNotEmpty) {
      return gameUrl;
    }

    final String? gameName = games?.name?.trim();
    if (gameName != null && gameName.isNotEmpty) {
      return gameName;
    }

    return null;
  }

  Future<void> _sendCallbackToJs(final String event) async {
    debugPrint('Flutter → JS: $event');
    try {
      await webViewController.runJavaScript(
        "if (typeof onFlutterResponse === 'function') onFlutterResponse('$event');",
      );
    } catch (e) {
      debugPrint('JS callback error [$event]: $e');
    }
  }

  @override
  void onClose() {
    unawaited(_resetPreferredOrientation());
    AdService.dispose();
    super.onClose();
  }

  Future<void> _applyPreferredOrientation() async {
    final String orientation = games?.orientation?.trim().toLowerCase() ?? '';

    if (orientation == 'landscape') {
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      return;
    }

    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _resetPreferredOrientation() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }
}

class _WebMessage {
  const _WebMessage({required this.command, required this.payload});

  final String command;
  final String payload;
}
