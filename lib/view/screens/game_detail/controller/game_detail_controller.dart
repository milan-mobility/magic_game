import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/ads/ads_services.dart';
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
    // Pre-load both ad types so they are ready when JS triggers them.
    AdService.preloadInterstitial();
    AdService.preloadRewardedAd();
    loadUrl();
  }

  void loadUrl() {
    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
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
    webViewController.loadRequest(
      Uri.parse(games?.gameurl ?? ''),
      // Uri.parse('https://oneupitsolution.com/magicgameplus/icecreamfever/'),
    );
  }

  void _handleWebMessage(final String message) {
    debugPrint('JS → Flutter: $message');
    switch (message) {
      case 'showInterstitial':
        if (_isShowingInterstitial) return;
        _isShowingInterstitial = true;
        _sendCallbackToJs('gamePause');
        final shownI = AdService.showInterstitial(
          onDismissed: () {
            _isShowingInterstitial = false;
            _sendCallbackToJs('gameResume');
            _sendCallbackToJs('interstitialClosed');
          },
        );
        if (!shownI) {
          _isShowingInterstitial = false;
          _sendCallbackToJs('gameResume');
        }
      case 'showRewardedPlus':
        if (_isShowingRewarded) return;
        _isShowingRewarded = true;
        _sendCallbackToJs('gamePause');
        final shownR = AdService.showRewardedAd(
          onDismissed: () {
            _isShowingRewarded = false;
            _sendCallbackToJs('gameResume');
            _sendCallbackToJs('rewardEarned');
          },
        );
        if (!shownR) {
          _isShowingRewarded = false;
          _sendCallbackToJs('gameResume');
        }
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
