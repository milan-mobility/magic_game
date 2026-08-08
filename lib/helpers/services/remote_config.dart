import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:magic_games/data/api/api_end_points.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const String baseUrlKey = 'baseurl';
  static const String secondaryBaseUrlKey = 'secondrybaseurl';
  static const String configPathKey = 'configpath';
  static const String adIntervalKey = 'adinterval';
  static const String appVersionKey = 'appversion';
  static const String languageKey = 'language';
  static const String moreGamesUrlAndroidKey = 'moregames';
  static const String moreGamesUrliOSKey = 'moregamesios';

  final FirebaseRemoteConfig _remoteConfig;
  String? _activeBaseUrlOverride;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults(<String, dynamic>{
        baseUrlKey: Endpoints.defaultBaseUrl,
        secondaryBaseUrlKey: Endpoints.defaultSecondaryBaseUrl,
        configPathKey: Endpoints.defaultConfigPath,
        adIntervalKey: 60,
        appVersionKey: 1,
        moreGamesUrlAndroidKey: Endpoints.moreGameAndroid,
        moreGamesUrliOSKey: Endpoints.moreGameIOS,
        languageKey:
            '{"en":"language/en.json","pt":"language/pt.json","de":"language/de.json","es":"language/es.json","fr":"language/fr.json","it":"language/it.json","ja":"language/ja.json","ko":"language/ko.json","nl":"language/nl.json","ru":"language/ru.json","zh-TW":"language/zh-TW.json","zh-CN":"language/zh-CN.json","th":"language/th.json","ar":"language/ar.json","tr":"language/tr.json","id":"language/id.json","bn":"language/bn.json","ur":"language/ur.json","hi":"language/hi.json"}',
      });

      await _remoteConfig.fetchAndActivate();
      _setupRealTimeUpdates();
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize Remote Config: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Refreshes the values used by API requests after connectivity is restored.
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _activeBaseUrlOverride = null;
    } catch (error, stackTrace) {
      debugPrint('Failed to refresh Remote Config: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _setupRealTimeUpdates() {
    _remoteConfig.onConfigUpdated.listen((_) async {
      await _remoteConfig.activate();
      _activeBaseUrlOverride = null;
      debugPrint('Remote Config updated instantly!');
    });
  }

  String get baseUrl =>
      _normalizeBaseUrl(_activeBaseUrlOverride ?? requestBaseUrls.first);

  String get imageBaseUrl => _normalizeBaseUrl(
    _remoteBaseUrl(baseUrlKey) ??
        _remoteOrDefaultSecondaryBaseUrl ??
        Endpoints.defaultBaseUrl,
  );

  String get secondaryBaseUrl => _normalizeBaseUrl(
    _platformAwareBaseUrl(
      getString(
        secondaryBaseUrlKey,
        fallback: Endpoints.defaultSecondaryBaseUrl,
      ),
    ),
  );

  List<String> get requestBaseUrls {
    final List<String?> candidates = <String?>[
      _remoteBaseUrl(baseUrlKey),
      _remoteOrDefaultSecondaryBaseUrl,
      Endpoints.defaultBaseUrl,
    ];

    final List<String> resolvedUrls = <String>[];
    for (final String? candidate in candidates) {
      final String? normalizedCandidate = _normalizedCandidateBaseUrl(
        candidate,
      );
      if (normalizedCandidate == null ||
          resolvedUrls.contains(normalizedCandidate)) {
        continue;
      }

      resolvedUrls.add(normalizedCandidate);
    }

    if (resolvedUrls.isEmpty) {
      return <String>[
        _normalizeBaseUrl(_platformAwareBaseUrl(Endpoints.defaultBaseUrl)),
      ];
    }

    return resolvedUrls;
  }

  void markWorkingBaseUrl(final String value) {
    final String? normalizedValue = _normalizedCandidateBaseUrl(value);
    if (normalizedValue == null) {
      return;
    }

    _activeBaseUrlOverride = normalizedValue;
  }

  String get configPath => _normalizeRelativePath(
    getString(configPathKey, fallback: Endpoints.defaultConfigPath),
  );

  int get adInterval => getInt(adIntervalKey, fallback: 60);

  int get appVersion => getInt(appVersionKey, fallback: 1);

  String get moreGameAndroid =>
      getString(moreGamesUrlAndroidKey, fallback: Endpoints.moreGameAndroid);

  String get moreGameIOS =>
      getString(moreGamesUrliOSKey, fallback: Endpoints.moreGameIOS);

  Map<String, String> get languageMap => getJsonMap(
    languageKey,
  ).map((String key, dynamic value) => MapEntry(key, value.toString()));

  String languagePath({String? languageCode}) {
    final Map<String, String> languages = languageMap;
    final String normalizedLanguageCode = (languageCode ?? '').trim();

    if (normalizedLanguageCode.isNotEmpty) {
      final String? exactMatch = languages[normalizedLanguageCode];
      if (exactMatch != null && exactMatch.isNotEmpty) {
        return _buildConfigPath(exactMatch);
      }

      final String primaryLanguageCode = normalizedLanguageCode
          .split(RegExp(r'[-_]'))
          .first;
      final String? primaryMatch = languages[primaryLanguageCode];
      if (primaryMatch != null && primaryMatch.isNotEmpty) {
        return _buildConfigPath(primaryMatch);
      }
    }

    final String? defaultLanguagePath = languages['en'];
    if (defaultLanguagePath != null && defaultLanguagePath.isNotEmpty) {
      return _buildConfigPath(defaultLanguagePath);
    }

    return Endpoints.defaultLanguagePath;
  }

  String getString(String key, {String fallback = ''}) {
    final String value = _remoteConfig.getString(key).trim();
    return value.isEmpty ? fallback : value;
  }

  bool getBool(String key, {bool fallback = false}) {
    final RemoteConfigValue value = _remoteConfig.getValue(key);
    if (value.asString().trim().isEmpty) {
      return fallback;
    }
    return value.asBool();
  }

  int getInt(String key, {int fallback = 0}) {
    final RemoteConfigValue value = _remoteConfig.getValue(key);
    if (value.asString().trim().isEmpty) {
      return fallback;
    }
    return value.asInt();
  }

  double getDouble(String key, {double fallback = 0}) {
    final RemoteConfigValue value = _remoteConfig.getValue(key);
    if (value.asString().trim().isEmpty) {
      return fallback;
    }
    return value.asDouble();
  }

  Map<String, dynamic> getJsonMap(String key) {
    final String rawValue = getString(key);
    if (rawValue.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final dynamic decodedValue = jsonDecode(rawValue);
      if (decodedValue is Map<String, dynamic>) {
        return decodedValue;
      }
      if (decodedValue is Map) {
        return decodedValue.map(
          (dynamic mapKey, dynamic value) => MapEntry(mapKey.toString(), value),
        );
      }
    } catch (error) {
      debugPrint('Failed to parse Remote Config key "$key": $error');
    }

    return <String, dynamic>{};
  }

  String? _remoteBaseUrl(final String key) {
    final RemoteConfigValue value = _remoteConfig.getValue(key);
    if (value.source != ValueSource.valueRemote) {
      return null;
    }

    return value.asString().trim();
  }

  String? get _remoteOrDefaultSecondaryBaseUrl {
    final RemoteConfigValue value = _remoteConfig.getValue(secondaryBaseUrlKey);
    final String resolvedValue = value.asString().trim();

    if (resolvedValue.isNotEmpty) {
      return resolvedValue;
    }

    return Endpoints.defaultSecondaryBaseUrl;
  }

  String? _normalizedCandidateBaseUrl(final String? value) {
    final String? trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return _normalizeBaseUrl(_platformAwareBaseUrl(trimmedValue));
  }

  String _normalizeBaseUrl(String value) {
    if (value.endsWith('/')) {
      return value;
    }
    return '$value/';
  }

  String _platformAwareBaseUrl(final String value) {
    final String normalizedValue = _normalizeBaseUrl(value.trim());
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return normalizedValue;
    }

    if (normalizedValue.contains('/ios/')) {
      return normalizedValue;
    }

    final Uri? uri = Uri.tryParse(normalizedValue);
    if (uri == null || !uri.hasAuthority) {
      return normalizedValue;
    }

    final List<String> pathSegments = uri.pathSegments.where((segment) {
      return segment.isNotEmpty;
    }).toList();

    if (pathSegments.isEmpty) {
      return normalizedValue;
    }

    pathSegments.insert(1, 'ios');
    return uri.replace(pathSegments: pathSegments).toString();
  }

  String _normalizeRelativePath(String value) {
    final String normalizedValue = value.trim().replaceAll(RegExp(r'^/+'), '');
    if (normalizedValue.isEmpty) {
      return '';
    }
    if (normalizedValue.endsWith('/')) {
      return normalizedValue;
    }
    return '$normalizedValue/';
  }

  String _buildConfigPath(String path) {
    final String normalizedPath = path.trim().replaceAll(RegExp(r'^/+'), '');
    if (normalizedPath.isEmpty) {
      return Endpoints.defaultLanguagePath;
    }
    if (normalizedPath.startsWith(configPath)) {
      return normalizedPath;
    }
    return '$configPath$normalizedPath';
  }
}
