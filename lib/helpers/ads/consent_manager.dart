// lib/helpers/ads/consent_manager.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentManager {
  ConsentManager._();
  static final ConsentManager instance = ConsentManager._();

  bool _ready = false;
  bool _hasInvokedConsentFlowComplete = false;

  /// Initialize consent flow. Call this at app startup BEFORE initializing MobileAds.
  /// Set [debugGeography] true and provide [testDeviceIds] only for local testing (remove in production).
  Future<void> init(
      {final bool debugGeography = false,
      final List<String>? testDeviceIds,
      final Future<void> Function()? onConsentFlowComplete}) async {
    if (_ready) return;

    final ConsentDebugSettings? debugSettings = debugGeography
        ? ConsentDebugSettings(
            debugGeography: DebugGeography.debugGeographyEea,
            testIdentifiers: testDeviceIds ?? <String>[],
          )
        : null;

    final ConsentRequestParameters params = ConsentRequestParameters(
      consentDebugSettings: debugSettings,
      tagForUnderAgeOfConsent: false,
    );

    final Completer<void> completer = Completer<void>();

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          // Consent info updated successfully
          // Load & show form if required (callback invoked even if form not required)
          ConsentForm.loadAndShowConsentFormIfRequired(
              (final FormError? loadError) async {
            if (loadError != null) {
              debugPrint('ConsentForm load/show error: ${loadError.message}');
            }

            try {} catch (e, st) {
              debugPrint('Failed to read consent status: $e\n$st');
            }

            await _notifyConsentFlowCompleted(onConsentFlowComplete);
            _ready = true;
            completer.complete();
          });
        },
        (final FormError error) {
          // Failed to update consent info — fallback to previous status or treat as unknown
          debugPrint('requestConsentInfoUpdate error: ${error.message}');
          // Try to read status from SDK (may be previous session); ignore errors
          ConsentInformation.instance
              .getConsentStatus()
              .then((final ConsentStatus s) {})
              .catchError((final _) {});
          unawaited(_notifyConsentFlowCompleted(onConsentFlowComplete));
          _ready = true;
          completer.complete();
        },
      );
    } catch (e, st) {
      debugPrint('Consent init exception: $e\n$st');
      unawaited(_notifyConsentFlowCompleted(onConsentFlowComplete));
      _ready = true;
      completer.complete();
    }

    return completer.future;
  }

  /// Returns an AdRequest that is configured according to the current consent (NPA if consent not obtained).
  Future<AdRequest> getAdRequest() async {
    try {
      final ConsentStatus status =
          await ConsentInformation.instance.getConsentStatus();
      final bool personalized = status == ConsentStatus.obtained;
      debugPrint('PERSONALIZED=>$personalized');
      return AdRequest(nonPersonalizedAds: !personalized);
    } catch (e) {
      debugPrint('getAdRequest: error reading consent status: $e');
      return const AdRequest(nonPersonalizedAds: true);
    }
  }

  /// Convenience check if SDK thinks it can request ads (call after requestConsentInfoUpdate()).
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  /// Show privacy options form (for Settings screen).
  Future<void> showPrivacyOptions() async {
    ConsentForm.showPrivacyOptionsForm((final FormError? error) {
      if (error != null) {
        debugPrint('showPrivacyOptionsForm error: ${error.message}');
      }
    });
  }

  /// Test helper — reset UMP state (testing only).
  Future<void> resetForTesting() async {
    ConsentInformation.instance.reset();
    _ready = false;
    _hasInvokedConsentFlowComplete = false;
  }

  Future<void> _notifyConsentFlowCompleted(
    final Future<void> Function()? onConsentFlowComplete,
  ) async {
    if (_hasInvokedConsentFlowComplete || onConsentFlowComplete == null) {
      return;
    }

    _hasInvokedConsentFlowComplete = true;

    try {
      await onConsentFlowComplete();
    } catch (e, st) {
      debugPrint('Consent flow completion callback failed: $e\n$st');
    }
  }
}
