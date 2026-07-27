import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/ads/ads_services.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/services/google_leaderboard_service.dart';
import 'package:magic_games/helpers/services/remote_config.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/utility.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameDetailController extends GetxController with WidgetsBindingObserver {
  final SharedPreferenceHelper _sharedPreferenceHelper =
      Get.find<SharedPreferenceHelper>();

  late WebViewController webViewController;
  bool _isShowingInterstitial = false;
  bool _isShowingRewarded = false;
  bool isExitOverlayVisible = false;
  Games? games;

  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  String? get _currentInterstitialAdUnitId =>
      _normalizedAdUnitId(games?.interstitialid);

  String? get _currentRewardedAdUnitId => _normalizedAdUnitId(games?.rewardid);

  String get gameTitle {
    final String? name = games?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'Game'.tr;
  }

  String get gameDescription {
    final String? description = games?.shortdesc?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }

    return 'Jump back in and keep playing this game.'.tr;
  }

  String? get heroImageUrl {
    final String? icon = games?.icon?.trim();
    if (icon != null && icon.isNotEmpty) {
      return icon.imageUrl();
    }

    final String? banner = games?.banner?.trim();
    if (banner != null && banner.isNotEmpty) {
      return banner.imageUrl();
    }

    return null;
  }

  String? get backgroundImageUrl {
    final String? banner = games?.banner?.trim();
    if (banner != null && banner.isNotEmpty) {
      return banner.imageUrl();
    }

    return heroImageUrl;
  }

  List<String> get gameTags {
    final String? categoryName = games?.categoryName?.trim();
    if (categoryName == null || categoryName.isEmpty) {
      return const <String>[];
    }

    final String primaryCategory = categoryName
        .split(',')
        .map((final String token) => token.trim())
        .firstWhere((final String token) => token.isNotEmpty, orElse: () => '');

    if (primaryCategory.isEmpty) {
      return const <String>[];
    }

    return <String>[primaryCategory];
  }

  bool get canDownloadCurrentGame {
    final String? storeUrl = games?.storeurl?.trim();
    return storeUrl != null && storeUrl.isNotEmpty;
  }

  List<Games> get recommendedGames {
    if (games == null || !Get.isRegistered<HomeController>()) {
      return const <Games>[];
    }

    final Set<String> currentCategories = <String>{
      ..._tokenizeCategoryValues(games?.category),
      ..._tokenizeCategoryValues(games?.categoryName),
    };
    if (currentCategories.isEmpty) {
      return const <Games>[];
    }

    final HomeController homeController = Get.find<HomeController>();
    final List<Games> matchedGames = homeController.allGames.where((
      final Games game,
    ) {
      if (_isSameGame(game, games)) {
        return false;
      }

      final Set<String> candidateCategories = <String>{
        ..._tokenizeCategoryValues(game.category),
        ..._tokenizeCategoryValues(game.categoryName),
      };

      return candidateCategories.any(currentCategories.contains);
    }).toList();

    return matchedGames.take(10).toList(growable: false);
  }

  bool requiresSubscriptionForGame(final Games game) {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>().requiresSubscriptionForGame(game);
    }

    return game.subscription ?? false;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    if (Get.arguments != null) {
      games = Get.arguments['game'];
    }
    _preloadGameAds();
    unawaited(_enterGameMode());
    webViewController = WebViewController();
    loadUrl();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_restoreImmersiveMode());
    }
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
          _scheduleImmersiveModeRestore();
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

  Future<void> showExitOverlay() async {
    if (isExitOverlayVisible) {
      return;
    }

    isExitOverlayVisible = true;
    update();
    await _applyExitOverlayOrientation();
    await _sendCallbackToJs('GamePause');
  }

  Future<void> hideExitOverlay() async {
    if (!isExitOverlayVisible) {
      return;
    }

    isExitOverlayVisible = false;
    update();
    await _applyPreferredOrientation();
    await _sendCallbackToJs('GameResume');
  }

  Future<bool> handleSystemBack() async {
    if (isExitOverlayVisible) {
      Get.back<void>();
      return false;
    }

    await showExitOverlay();
    return false;
  }

  Future<void> openCurrentGameStore() async {
    await _openStoreForGame(games);
  }

  void openRecommendedGame(final Games game, final bool isSubscribe) {
    if (isSubscribe) {
      Get.offAllNamed(RouteHelper.vip);
      return;
    }

    Get.toNamed(
      RouteHelper.gameDetail,
      arguments: <String, dynamic>{'game': game},
    );
  }

  Future<void> _handleWebMessage(final String message) async {
    final _WebMessage webMessage = _parseWebMessage(message);

    switch (webMessage.command) {
      case 'loadInterstitial':
        _logMissingAdIdIfNeeded(
          adType: 'interstitial',
          adUnitId: _currentInterstitialAdUnitId,
        );
        AdService.preloadInterstitial(adUnitId: _currentInterstitialAdUnitId);
        break;

      case 'loadRewardedAd':
        _logMissingAdIdIfNeeded(
          adType: 'rewarded',
          adUnitId: _currentRewardedAdUnitId,
        );
        AdService.preloadRewardedAd(adUnitId: _currentRewardedAdUnitId);
        break;

      case 'showInterstitial':
        _logMissingAdIdIfNeeded(
          adType: 'interstitial',
          adUnitId: _currentInterstitialAdUnitId,
        );

        if (_isShowingInterstitial) return;
        _isShowingInterstitial = true;
        _sendCallbackToJs('GamePause');
        final shownI = AdService.showInterstitial(
          adUnitId: _currentInterstitialAdUnitId,
          onDismissed: () {
            _isShowingInterstitial = false;
            _scheduleImmersiveModeRestore();
            _sendCallbackToJs('GameResume');
            _sendCallbackToJs('interstitialClosed');
          },
        );
        if (!shownI) {
          _isShowingInterstitial = false;
          _scheduleImmersiveModeRestore();
          _sendCallbackToJs('GameResume');
        }
        break;
      case 'showRewardedPlus':
        _logMissingAdIdIfNeeded(
          adType: 'rewarded',
          adUnitId: _currentRewardedAdUnitId,
        );

        if (_isShowingRewarded) return;
        _isShowingRewarded = true;
        _sendCallbackToJs('GamePause');
        final shownR = AdService.showRewardedAd(
          adUnitId: _currentRewardedAdUnitId,
          onDismissed: () {
            _isShowingRewarded = false;
            _scheduleImmersiveModeRestore();
            _sendCallbackToJs('GameResume');
            _sendCallbackToJs('rewardEarned');
          },
        );
        if (!shownR) {
          _isShowingRewarded = false;
          _scheduleImmersiveModeRestore();
          _sendCallbackToJs('GameResume');
        }
        break;

      case 'addHeart':
        await _addCurrentGameToFavorites();
        await GoogleLeaderboardService.instance.submitScore(
          _sharedPreferenceHelper.favoriteGamesCount,
        );
        break;

      case 'addVibration':
        HapticFeedback.mediumImpact();
        break;

      case 'moreGames':
        Utility.openUrl(
          GetPlatform.isAndroid
              ? _remoteConfigService.moreGameAndroid
              : _remoteConfigService.moreGameIOS,
        );
        break;

      case 'rateUs':
        Utility.reviewApp();
        break;

      case 'shareApp':
        Utility.shareApp();
        break;

      case 'showToastMessgae':
        _showToastMessage(webMessage.payload);
        break;

      case 'openURL':
        Utility.openUrl(webMessage.payload);
        break;

      case 'openMailComposerSupport':
      case 'openMailComposer':
        Utility.sendHelpSupportEmailFromEvent(gameName: games?.name ?? '');
        break;

      case 'gameStart':
        await _recordCurrentGameAsRecentlyPlayed();
        break;

      case 'googleLeaderBoard':
        await GoogleLeaderboardService.instance.showLeaderboard();
        break;

      case 'sendFirebaseEvent':
        fireFirebaseEvent(webMessage.payload);
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

  String? _normalizedAdUnitId(final String? adUnitId) {
    final String? trimmedAdUnitId = adUnitId?.trim();
    if (trimmedAdUnitId == null || trimmedAdUnitId.isEmpty) {
      return null;
    }

    return trimmedAdUnitId;
  }

  void _preloadGameAds() {
    _logMissingAdIdIfNeeded(
      adType: 'interstitial',
      adUnitId: _currentInterstitialAdUnitId,
    );
    _logMissingAdIdIfNeeded(
      adType: 'rewarded',
      adUnitId: _currentRewardedAdUnitId,
    );
    unawaited(
      AdService.preloadInterstitial(adUnitId: _currentInterstitialAdUnitId),
    );
    unawaited(AdService.preloadRewardedAd(adUnitId: _currentRewardedAdUnitId));
  }

  void _logMissingAdIdIfNeeded({
    required final String adType,
    required final String? adUnitId,
  }) {
    if (adUnitId != null) {
      return;
    }

    debugPrint(
      'Current game ${games?.id ?? 'unknown'} has no $adType ad id, falling back to the default ad unit id.',
    );
  }

  Future<void> _openStoreForGame(final Games? game) async {
    final String? storeUrl = game?.storeurl?.trim();
    if (storeUrl == null || storeUrl.isEmpty) {
      _showToastMessage('Store URL is not available for this game.'.tr);
      return;
    }

    if (GetPlatform.isIOS) {
      _showToastMessage(
        'Add the iOS store URL key for this game to enable redirection.'.tr,
      );
      return;
    }

    final String resolvedUrl = storeUrl.startsWith('http')
        ? storeUrl
        : 'https://play.google.com/store/apps/details?id=$storeUrl';
    await Utility.openUrl(resolvedUrl);
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
    await _sharedPreferenceHelper.incrementFavoriteGamesCount();

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().update();
    }
  }

  Future<void> fireFirebaseEvent(final String name) async {
    await FirebaseAnalytics.instance.logEvent(name: name);
  }

  Future<void> _recordCurrentGameAsRecentlyPlayed() async {
    if (games == null) {
      return;
    }

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().recordRecentlyPlayedGame(games!);
    } else {
      final String? gameKey = _recentlyPlayedKeyForGame;
      if (gameKey != null) {
        await _sharedPreferenceHelper.addRecentlyPlayedGameKey(gameKey);
      }
    }

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().update();
    }
  }

  String? get _recentlyPlayedKeyForGame {
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
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_restoreDefaultSystemUi());
    unawaited(_resetPreferredOrientation());
    AdService.dispose();
    super.onClose();
  }

  Future<void> _enterGameMode() async {
    await _restoreImmersiveMode();
    await _applyPreferredOrientation();
  }

  Future<void> _restoreImmersiveMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _scheduleImmersiveModeRestore() {
    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 300),
        _restoreImmersiveMode,
      ),
    );
  }

  Future<void> _restoreDefaultSystemUi() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _applyPreferredOrientation() async {
    final String orientation = games?.orientation?.trim().toLowerCase() ?? '';

    if (orientation == 'landscape') {
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await _restoreImmersiveMode();
      return;
    }

    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    await _restoreImmersiveMode();
  }

  Future<void> _resetPreferredOrientation() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _applyExitOverlayOrientation() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    await _restoreImmersiveMode();
  }

  Set<String> _tokenizeCategoryValues(final String? value) {
    final String? normalizedValue = value?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) {
      return const <String>{};
    }

    return normalizedValue
        .split(RegExp(r'[,|/]'))
        .map((final String item) => item.trim().toLowerCase())
        .where((final String item) => item.isNotEmpty)
        .toSet();
  }

  bool _isSameGame(final Games? first, final Games? second) {
    if (first == null || second == null) {
      return false;
    }

    if (first.id != null && second.id != null) {
      return first.id == second.id;
    }

    final String? firstUrl = first.gameurl?.trim();
    final String? secondUrl = second.gameurl?.trim();
    if (firstUrl != null &&
        secondUrl != null &&
        firstUrl.isNotEmpty &&
        secondUrl.isNotEmpty) {
      return firstUrl == secondUrl;
    }

    final String? firstName = first.name?.trim();
    final String? secondName = second.name?.trim();
    return firstName != null &&
        secondName != null &&
        firstName.isNotEmpty &&
        secondName.isNotEmpty &&
        firstName == secondName;
  }
}

class _WebMessage {
  const _WebMessage({required this.command, required this.payload});

  final String command;
  final String payload;
}
