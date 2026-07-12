import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/ads/ads_services.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/utils/utility.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameDetailController extends GetxController {
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
        //Show toast
        Get.snackbar(
          'Event',
          message.message,
          backgroundColor: Colors.red,
          colorText: AppColors.white,
        );
        // String messageText='';
        // if(message.message.contains(':')){
        //   messageText = message.message.split(':').first;
        // }else {
        //   _handleWebMessage(message.message);
        // }
        _handleWebMessage(message.message);
      },
    );

    debugPrint("GAME URL=>${games?.gameurl}");
    webViewController.loadRequest(Uri.parse(games?.gameurl ?? ''));
  }

  void _handleWebMessage(final String message) {
    switch (message) {
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
        break;

      case 'addVibration':
        //VIBRATE DEVICE WHEN IT'S FIRE
        break;

      case 'openMailComposer':
        // game name,and send email on composer with text will be send by Tusar
        Utility.sendEmail(email: 'email');
        break;

      case 'moreGames':
        // Open play store url wil receive from Tusar
        // Android: https://play.google.com/store/apps/dev?id=6417410772580581502
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
        // showToastMessgae:https://www.facebook.com/icecreamfevercookinggame
        //show message whatever message comes in bottom of Screen.
        break;

      case 'openURL':
        // openURL:https://www.facebook.com/icecreamfevercookinggame
        // openURL:https://play.google.com/store/apps/dev?id=9213867137518194215
        break;

      default:
        debugPrint('Unknown message from JS: $message');
    }
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
    AdService.dispose();
    super.onClose();
  }
}
