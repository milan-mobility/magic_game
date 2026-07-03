import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magic_games/helpers/ads/ads_helper.dart';
import 'package:magic_games/helpers/ads/consent_manager.dart';

class AdService {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  static Future<void> preloadInterstitial() async {
    final AdRequest request = await ConsentManager.instance.getAdRequest();
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (final InterstitialAd ad) {
          _interstitialAd = ad;
          debugPrint('Interstitial ad pre-loaded');
        },
        onAdFailedToLoad: (final LoadAdError error) {
          _interstitialAd = null;
          debugPrint('Failed to pre-load interstitial: $error');
        },
      ),
    );
  }

  static Future<void> preloadRewardedAd() async {
    final AdRequest request = await ConsentManager.instance.getAdRequest();
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (final RewardedAd ad) {
          _rewardedAd = ad;
          debugPrint('Rewarded ad pre-loaded');
        },
        onAdFailedToLoad: (final LoadAdError error) {
          _rewardedAd = null;
          debugPrint('Failed to pre-load rewarded ad: $error');
        },
      ),
    );
  }

  /// Returns [true] if the ad was shown, [false] if not ready yet.
  /// [onDismissed] fires when the user closes the ad.
  static bool showInterstitial({VoidCallback? onDismissed}) {
    if (_interstitialAd == null) {
      debugPrint('Interstitial not ready yet, reloading...');
      preloadInterstitial();
      return false;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null; // clear before show to avoid double-use

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (final InterstitialAd ad) {
        ad.dispose();
        onDismissed?.call();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent:
          (final InterstitialAd ad, final AdError error) {
            ad.dispose();
            debugPrint('Interstitial failed to show: $error');
            onDismissed?.call(); // unblock the message handler
            preloadInterstitial();
          },
    );

    ad.show();
    return true;
  }

  /// Returns [true] if the ad was shown, [false] if not ready yet.
  /// [onDismissed] fires when the user closes the rewarded ad.
  static bool showRewardedAd({VoidCallback? onDismissed}) {
    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not ready yet, reloading...');
      preloadRewardedAd();
      return false;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null; // clear before show to avoid double-use

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (final RewardedAd ad) {
        ad.dispose();
        onDismissed?.call();
        preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent:
          (final RewardedAd ad, final AdError error) {
            ad.dispose();
            debugPrint('Rewarded ad failed to show: $error');
            onDismissed?.call(); // unblock the message handler
            preloadRewardedAd();
          },
    );

    ad.show(onUserEarnedReward: (final AdWithoutView ad, final RewardItem reward) {});
    return true;
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
