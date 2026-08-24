import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  FirebaseAnalytics get instance => _analytics;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    await _analytics.logAppOpen();
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserId(String? userId) {
    return _analytics.setUserId(id: userId);
  }

  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  }) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClassOverride,
    );
  }
}
