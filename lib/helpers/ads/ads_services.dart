import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magic_games/helpers/ads/ads_helper.dart';
import 'package:magic_games/helpers/ads/consent_manager.dart';
import 'package:magic_games/helpers/services/premium_access_service.dart';
import 'package:magic_games/helpers/services/remote_config.dart';

class AdService {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static String? _loadedInterstitialAdUnitId;
  static String? _loadedRewardedAdUnitId;
  static DateTime? _lastInterstitialShownAt;
  static bool _isInterstitialLoading = false;
  static bool _isRewardedLoading = false;
  static bool _pendingInterstitialShow = false;
  static String? _pendingInterstitialAdUnitId;
  static VoidCallback? _pendingInterstitialDismissed;

  static bool get _shouldSuppressAds {
    if (!Get.isRegistered<PremiumAccessService>()) {
      return false;
    }

    return Get.find<PremiumAccessService>().hasPremiumAccess;
  }

  static Future<void> preloadInterstitial({String? adUnitId}) async {
    debugPrint("MILAN ADD UNIT ID=> $adUnitId");
    if (_shouldSuppressAds) {
      _disposeInterstitial();
      return;
    }

    final String resolvedAdUnitId = AdHelper.resolveInterstitialAdUnitId(
      adUnitId,
    );
    if (_loadedInterstitialAdUnitId == resolvedAdUnitId &&
        (_interstitialAd != null || _isInterstitialLoading)) {
      return;
    }

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _loadedInterstitialAdUnitId = resolvedAdUnitId;
    _isInterstitialLoading = true;

    final AdRequest request = await ConsentManager.instance.getAdRequest();
    InterstitialAd.load(
      adUnitId: resolvedAdUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (final InterstitialAd ad) {
          _isInterstitialLoading = false;
          _interstitialAd = ad;
          debugPrint('Interstitial ad pre-loaded');
          _tryShowPendingInterstitial();
        },
        onAdFailedToLoad: (final LoadAdError error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          _loadedInterstitialAdUnitId = null;
          debugPrint('Failed to pre-load interstitial: $error');
          _clearPendingInterstitial(invokeDismissed: true);
        },
      ),
    );
  }

  static Future<void> preloadRewardedAd({String? adUnitId}) async {
    if (_shouldSuppressAds) {
      _disposeRewardedAd();
      return;
    }

    final String resolvedAdUnitId = AdHelper.resolveRewardedAdUnitId(adUnitId);
    if (_loadedRewardedAdUnitId == resolvedAdUnitId &&
        (_rewardedAd != null || _isRewardedLoading)) {
      return;
    }

    _rewardedAd?.dispose();
    _rewardedAd = null;
    _loadedRewardedAdUnitId = resolvedAdUnitId;
    _isRewardedLoading = true;

    final AdRequest request = await ConsentManager.instance.getAdRequest();
    RewardedAd.load(
      adUnitId: resolvedAdUnitId,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (final RewardedAd ad) {
          _isRewardedLoading = false;
          _rewardedAd = ad;
          debugPrint('Rewarded ad pre-loaded');
        },
        onAdFailedToLoad: (final LoadAdError error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
          _loadedRewardedAdUnitId = null;
          debugPrint('Failed to pre-load rewarded ad: $error');
        },
      ),
    );
  }

  /// Returns [true] if the ad was shown, [false] if not ready yet.
  /// [onDismissed] fires when the user closes the ad.
  static bool showInterstitial({String? adUnitId, VoidCallback? onDismissed}) {
    if (_shouldSuppressAds) {
      _disposeInterstitial();
      onDismissed?.call();
      return true;
    }

    if (!_canShowInterstitialNow) {
      debugPrint(
        'Interstitial skipped because ad interval has not elapsed yet',
      );
      onDismissed?.call();
      return true;
    }

    final String resolvedAdUnitId = AdHelper.resolveInterstitialAdUnitId(
      adUnitId,
    );
    if (_interstitialAd == null ||
        _loadedInterstitialAdUnitId != resolvedAdUnitId) {
      debugPrint('Interstitial not ready yet, reloading...');
      _pendingInterstitialShow = true;
      _pendingInterstitialAdUnitId = resolvedAdUnitId;
      _pendingInterstitialDismissed = onDismissed;
      preloadInterstitial(adUnitId: resolvedAdUnitId);
      return true;
    }

    _pendingInterstitialShow = false;
    _pendingInterstitialAdUnitId = null;
    _pendingInterstitialDismissed = null;

    final ad = _interstitialAd!;
    _interstitialAd = null; // clear before show to avoid double-use
    _loadedInterstitialAdUnitId = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (final InterstitialAd ad) {
        ad.dispose();
        onDismissed?.call();
        preloadInterstitial(adUnitId: resolvedAdUnitId);
      },
      onAdFailedToShowFullScreenContent:
          (final InterstitialAd ad, final AdError error) {
            ad.dispose();
            debugPrint('Interstitial failed to show: $error');
            onDismissed?.call(); // unblock the message handler
            preloadInterstitial(adUnitId: resolvedAdUnitId);
          },
    );

    _lastInterstitialShownAt = DateTime.now();
    ad.show();
    return true;
  }

  /// Returns [true] if the ad was shown, [false] if not ready yet.
  /// [onDismissed] fires when the user closes the rewarded ad.
  static bool showRewardedAd({String? adUnitId, VoidCallback? onDismissed}) {
    if (_shouldSuppressAds) {
      _disposeRewardedAd();
      onDismissed?.call();
      return true;
    }

    final String resolvedAdUnitId = AdHelper.resolveRewardedAdUnitId(adUnitId);
    if (_rewardedAd == null || _loadedRewardedAdUnitId != resolvedAdUnitId) {
      debugPrint('Rewarded ad not ready yet, reloading...');
      preloadRewardedAd(adUnitId: resolvedAdUnitId);
      return false;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null; // clear before show to avoid double-use
    _loadedRewardedAdUnitId = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (final RewardedAd ad) {
        ad.dispose();
        onDismissed?.call();
        preloadRewardedAd(adUnitId: resolvedAdUnitId);
      },
      onAdFailedToShowFullScreenContent:
          (final RewardedAd ad, final AdError error) {
            ad.dispose();
            debugPrint('Rewarded ad failed to show: $error');
            onDismissed?.call(); // unblock the message handler
            preloadRewardedAd(adUnitId: resolvedAdUnitId);
          },
    );

    ad.show(
      onUserEarnedReward: (final AdWithoutView ad, final RewardItem reward) {},
    );
    return true;
  }

  static void _disposeInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _loadedInterstitialAdUnitId = null;
    _isInterstitialLoading = false;
    _clearPendingInterstitial();
  }

  static void _disposeRewardedAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _loadedRewardedAdUnitId = null;
    _isRewardedLoading = false;
  }

  static bool get _canShowInterstitialNow {
    if (!Get.isRegistered<RemoteConfigService>()) {
      return true;
    }

    final int intervalInSeconds = Get.find<RemoteConfigService>().adInterval;
    if (intervalInSeconds <= 0) {
      return true;
    }

    if (_lastInterstitialShownAt == null) {
      return true;
    }

    final Duration elapsed = DateTime.now().difference(
      _lastInterstitialShownAt!,
    );
    return elapsed >= Duration(seconds: intervalInSeconds);
  }

  static void dispose() {
    _disposeInterstitial();
    _disposeRewardedAd();
  }

  static void _tryShowPendingInterstitial() {
    if (!_pendingInterstitialShow || _pendingInterstitialAdUnitId == null) {
      return;
    }

    if (_interstitialAd == null ||
        _loadedInterstitialAdUnitId != _pendingInterstitialAdUnitId) {
      return;
    }

    final VoidCallback? onDismissed = _pendingInterstitialDismissed;
    final String adUnitId = _pendingInterstitialAdUnitId!;
    _pendingInterstitialShow = false;
    _pendingInterstitialAdUnitId = null;
    _pendingInterstitialDismissed = null;

    showInterstitial(adUnitId: adUnitId, onDismissed: onDismissed);
  }

  static void _clearPendingInterstitial({bool invokeDismissed = false}) {
    final VoidCallback? onDismissed = _pendingInterstitialDismissed;
    _pendingInterstitialShow = false;
    _pendingInterstitialAdUnitId = null;
    _pendingInterstitialDismissed = null;

    if (invokeDismissed) {
      onDismissed?.call();
    }
  }
}
