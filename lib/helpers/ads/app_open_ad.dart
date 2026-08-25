import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magic_games/helpers/ads/consent_manager.dart';
import 'package:magic_games/helpers/services/premium_access_service.dart';

/// Loads and presents an App Open Ad when its public methods are called.
///
/// This service is deliberately not registered or invoked anywhere. Call
/// [load] and [showIfAvailable] from the desired app lifecycle point when the
/// placement is ready to be enabled.
class AppOpenAdService {
  AppOpenAdService._();

  static const String _androidTestAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _iosTestAdUnitId =
      'ca-app-pub-3940256099942544/5575463023';
  static const Duration _maxAdAge = Duration(hours: 4);

  static AppOpenAd? _ad;
  static DateTime? _loadedAt;
  static bool _isLoading = false;
  static bool _isShowing = false;

  static bool get isAdAvailable =>
      _ad != null &&
      _loadedAt != null &&
      DateTime.now().difference(_loadedAt!) < _maxAdAge;

  static bool get _shouldSuppressAds {
    return Get.isRegistered<PremiumAccessService>() &&
        Get.find<PremiumAccessService>().hasPremiumAccess;
  }

  static String get _adUnitId {
    if (Platform.isAndroid) {
      return _androidTestAdUnitId;
    }
    if (Platform.isIOS) {
      return _iosTestAdUnitId;
    }

    throw UnsupportedError('App Open Ads are unsupported on this platform.');
  }

  static Future<void> load() async {
    if (_isLoading || isAdAvailable) {
      return;
    }

    if (_shouldSuppressAds || (!Platform.isAndroid && !Platform.isIOS)) {
      dispose();
      return;
    }

    _disposeAd();
    _isLoading = true;
    final AdRequest request = await ConsentManager.instance.getAdRequest();

    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: request,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (final AppOpenAd ad) {
          _isLoading = false;
          _ad = ad;
          _loadedAt = DateTime.now();
          debugPrint('App Open Ad loaded.');
        },
        onAdFailedToLoad: (final LoadAdError error) {
          _isLoading = false;
          _loadedAt = null;
          debugPrint('App Open Ad failed to load: $error');
        },
      ),
    );
  }

  /// Shows a previously loaded ad and returns whether one was presented.
  static bool showIfAvailable({final VoidCallback? onDismissed}) {
    if (_isShowing || !isAdAvailable || _shouldSuppressAds) {
      if (_shouldSuppressAds) {
        dispose();
      }
      return false;
    }

    final AppOpenAd ad = _ad!;
    _ad = null;
    _loadedAt = null;
    _isShowing = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (final AppOpenAd ad) {
        ad.dispose();
        _isShowing = false;
        onDismissed?.call();
        load();
      },
      onAdFailedToShowFullScreenContent:
          (final AppOpenAd ad, final AdError error) {
            ad.dispose();
            _isShowing = false;
            debugPrint('App Open Ad failed to show: $error');
            onDismissed?.call();
            load();
          },
    );
    ad.show();
    return true;
  }

  static void dispose() {
    _disposeAd();
    _isLoading = false;
  }

  static void _disposeAd() {
    _ad?.dispose();
    _ad = null;
    _loadedAt = null;
  }
}
