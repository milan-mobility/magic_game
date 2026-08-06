import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/ads/ads_helper.dart';
import 'package:magic_games/helpers/ads/ads_services.dart';
import 'package:magic_games/helpers/ads/consent_manager.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/services/google_leaderboard_service.dart';
import 'package:magic_games/helpers/services/remote_config.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/connection.dart';
import 'package:magic_games/utils/message_constant.dart';
import 'package:magic_games/utils/utility.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameDetailController extends GetxController with WidgetsBindingObserver {
  final SharedPreferenceHelper _sharedPreferenceHelper =
      Get.find<SharedPreferenceHelper>();
  final Set<String> _preloadedExitPreviewImageUrls = <String>{};

  late WebViewController webViewController;
  bool _isShowingInterstitial = false;
  bool _isShowingRewarded = false;
  bool _isBannerRequestedVisible = false;
  bool _isBannerLoading = false;
  int? _bannerWidth;
  Orientation? _bannerOrientation;
  int? _loadedBannerWidth;
  Orientation? _loadedBannerOrientation;
  bool _isClosingScreen = false;
  bool isGameLoading = true;
  bool isExitOverlayVisible = false;
  Games? games;
  BannerAd? _bannerAd;
  _BannerAlignment _bannerAlignment = _BannerAlignment.top;

  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  String? get _currentInterstitialAdUnitId =>
      _normalizedAdUnitId(games?.interstitialid);

  String? get _currentRewardedAdUnitId => _normalizedAdUnitId(games?.rewardid);

  BannerAd? get bannerAd =>
      _isBannerRequestedVisible && !_isBannerLoading && _bannerAd != null
      ? _bannerAd
      : null;

  bool get isBannerVisible => bannerAd != null;

  bool get isBannerAlignedTop => _bannerAlignment == _BannerAlignment.top;

  bool get shouldShowLoadingOverlay => isGameLoading && !_isClosingScreen;

  double get bannerHeight => bannerAd?.size.height.toDouble() ?? 0;

  void syncBannerViewport({
    required final double width,
    required final Orientation orientation,
  }) {
    final int normalizedWidth = width.truncate();
    if (normalizedWidth <= 0) {
      return;
    }

    if (_bannerWidth == normalizedWidth && _bannerOrientation == orientation) {
      return;
    }

    _bannerWidth = normalizedWidth;
    _bannerOrientation = orientation;

    if (_isBannerRequestedVisible && !_hasBannerForCurrentViewport) {
      unawaited(_loadAdaptiveBanner());
    }
  }

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
    _configureWebView();
    loadUrl();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_restoreImmersiveMode());
    }
  }

  Future<void> loadUrl() async {
    try {
      _setGameLoading(true);
      final bool isInternetAvailable =
          await ConnectionUtils.isNetworkConnected();
      if (!isInternetAvailable) {
        _setGameLoading(false);
        showErrorSnackBar(
          title: MessageConstant.netWorkTitle,
          message: MessageConstant.networkError,
        );
        return;
      }

      final String? gameUrl = games?.gameurl?.trim();
      if (gameUrl == null || gameUrl.isEmpty) {
        _setGameLoading(false);
        _showToastMessage('Game URL is not available for this game.'.tr);
        return;
      }

      debugPrint("GAME URL=>$gameUrl");
      await webViewController.loadRequest(Uri.parse(gameUrl));
    } catch (e) {
      _setGameLoading(false);
    }
  }

  Future<void> showExitOverlay() async {
    if (isExitOverlayVisible) {
      return;
    }
    await _sendCallbackToJs('GamePause');

    isExitOverlayVisible = true;
    update();
    await _applyExitOverlayOrientation();
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
      await hideExitOverlay();
    }

    return false;
  }

  Future<void> openCurrentGameStore() async {
    await _openStoreForGame(games);
  }

  void openRecommendedGame(final Games game, final bool isSubscribe) {
    unawaited(_openRecommendedGame(game, isSubscribe));
  }

  Future<void> closeGameDetailScreen() async {
    _isClosingScreen = true;
    _setGameLoading(false);
    await _prepareForScreenExit(hideOverlay: false);
    Get.back<void>();
  }

  Future<void> _openRecommendedGame(
    final Games game,
    final bool isSubscribe,
  ) async {
    if (isSubscribe) {
      await _prepareForScreenExit();
      Get.offNamed(RouteHelper.vip);
      return;
    }

    if (_isSameGame(game, games)) {
      await hideExitOverlay();
      return;
    }

    _setGameLoading(true);
    games = game;
    isExitOverlayVisible = false;
    _isShowingInterstitial = false;
    _isShowingRewarded = false;
    _hideBanner(resetAlignment: true);
    update();

    _preloadGameAds();
    await _enterGameMode();
    await loadUrl();
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
          _showToastMessage(
            'Reward is currently unavailable. Please try again later.',
          );
          _scheduleImmersiveModeRestore();
          _sendCallbackToJs('GameResume');
        }
        break;

      case 'showBanner':
        await _showBanner();
        break;
      case 'hideBanner':
        _hideBanner();
        break;

      case 'setBannerAlign':
        _setBannerAlign(webMessage.payload);
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
        _setGameLoading(false);
        _sendCallbackToJs(
          'appLanguage:${Get.locale?.languageCode.toLowerCase() ?? ''}',
        );
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
    _disposeBannerAd();
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

  Future<void> _prepareForScreenExit({bool hideOverlay = true}) async {
    if (hideOverlay) {
      isExitOverlayVisible = false;
      update();
    }
    await _restoreDefaultSystemUi();
    await _resetPreferredOrientation();
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

  void _configureWebView() {
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
          _setGameLoading(false);
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
        onWebResourceError: (WebResourceError error) {
          _setGameLoading(false);
        },
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
  }

  void _setGameLoading(final bool value) {
    if (isGameLoading == value) {
      return;
    }

    isGameLoading = value;
    update();
  }

  void preloadExitPreviewAssets(final BuildContext context) {
    final Set<String> imageUrls = <String>{
      if (heroImageUrl != null && heroImageUrl!.trim().isNotEmpty)
        heroImageUrl!.trim(),
      if (backgroundImageUrl != null && backgroundImageUrl!.trim().isNotEmpty)
        backgroundImageUrl!.trim(),
    };

    for (final String imageUrl in imageUrls) {
      if (_preloadedExitPreviewImageUrls.contains(imageUrl)) {
        continue;
      }

      _preloadedExitPreviewImageUrls.add(imageUrl);
      unawaited(
        precacheImage(NetworkImage(imageUrl), context).catchError((
          final Object error,
          final StackTrace stackTrace,
        ) {
          _preloadedExitPreviewImageUrls.remove(imageUrl);
          debugPrint('Failed to preload exit preview image: $imageUrl');
        }),
      );
    }
  }

  Future<void> _showBanner() async {
    if (AdService.shouldSuppressAds) {
      _disposeBannerAd();
      update();
      return;
    }

    _isBannerRequestedVisible = true;

    if (_hasBannerForCurrentViewport) {
      update();
      return;
    }

    await _loadAdaptiveBanner();
  }

  bool get _hasBannerForCurrentViewport =>
      _bannerAd != null &&
      _loadedBannerWidth == _bannerWidth &&
      _loadedBannerOrientation == _bannerOrientation;

  Future<void> _loadAdaptiveBanner() async {
    if (_isBannerLoading || !_isBannerRequestedVisible) {
      return;
    }

    final int? bannerWidth = _bannerWidth;
    final Orientation? bannerOrientation = _bannerOrientation;
    if (bannerWidth == null || bannerOrientation == null || bannerWidth <= 0) {
      return;
    }

    _isBannerLoading = true;
    _loadedBannerWidth = null;
    _loadedBannerOrientation = null;
    _bannerAd?.dispose();
    _bannerAd = null;
    update();

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
          bannerOrientation,
          bannerWidth,
        );

    if (!_isBannerRequestedVisible) {
      _isBannerLoading = false;
      update();
      return;
    }

    if (size == null) {
      _isBannerLoading = false;
      _isBannerRequestedVisible = false;
      debugPrint('Unable to resolve anchored adaptive banner size.');
      update();
      return;
    }

    if (_bannerWidth != bannerWidth ||
        _bannerOrientation != bannerOrientation) {
      _isBannerLoading = false;
      update();
      unawaited(_loadAdaptiveBanner());
      return;
    }

    final AdRequest request = await ConsentManager.instance.getAdRequest();

    if (!_isBannerRequestedVisible) {
      _isBannerLoading = false;
      update();
      return;
    }

    final BannerAd banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: size,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (final Ad ad) {
          final BannerAd loadedBanner = ad as BannerAd;

          if (!_isBannerRequestedVisible ||
              _bannerWidth != bannerWidth ||
              _bannerOrientation != bannerOrientation) {
            _isBannerLoading = false;
            loadedBanner.dispose();
            update();
            if (_isBannerRequestedVisible) {
              unawaited(_loadAdaptiveBanner());
            }
            return;
          }

          _isBannerLoading = false;
          _bannerAd = loadedBanner;
          _loadedBannerWidth = bannerWidth;
          _loadedBannerOrientation = bannerOrientation;
          update();
        },
        onAdFailedToLoad: (final Ad ad, final LoadAdError error) {
          _isBannerLoading = false;
          ad.dispose();
          _bannerAd = null;
          _isBannerRequestedVisible = false;
          debugPrint('Banner ad failed to load: $error');
          update();
        },
      ),
    );

    banner.load();
  }

  void _hideBanner({bool resetAlignment = false}) {
    _isBannerRequestedVisible = false;
    if (resetAlignment) {
      _bannerAlignment = _BannerAlignment.top;
    }
    update();
  }

  void _setBannerAlign(final String rawValue) {
    final String alignment = rawValue.trim().toLowerCase();
    if (alignment == 'bottom' || alignment == 'botton') {
      _bannerAlignment = _BannerAlignment.bottom;
    } else {
      _bannerAlignment = _BannerAlignment.top;
    }
    update();
  }

  void _disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoading = false;
    _isBannerRequestedVisible = false;
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

enum _BannerAlignment { top, bottom }
