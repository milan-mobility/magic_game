import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';

class AuthService extends GetxService {
  static const String _androidServerClientId =
      '833018092184-jmqs352l0fmplvudvdnnq7bpt7e2d42u.apps.googleusercontent.com';
  static const String _iosClientId =
      '833018092184-bl2qn1srqds6h3us3ec2pohqqnnlbj57.apps.googleusercontent.com';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final SharedPreferenceHelper _sharedPreferenceHelper =
      Get.find<SharedPreferenceHelper>();

  StreamSubscription<User?>? _authSubscription;
  bool _isGoogleInitialized = false;
  String? _lastGooglePhotoUrl;
  String? _lastGoogleDisplayName;

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isLoggedIn => currentUser != null;

  String? get currentDisplayName {
    final List<String?> candidates = <String?>[
      _lastGoogleDisplayName,
      _firebaseAuth.currentUser?.displayName,
      _providerDisplayName,
      _sharedPreferenceHelper.googleProfileDisplayName,
    ];

    for (final String? candidate in candidates) {
      final String? normalized = _normalizeValue(candidate);
      if (normalized != null) {
        return normalized;
      }
    }

    return null;
  }

  String? get currentPhotoUrl {
    final List<String?> candidates = <String?>[
      _lastGooglePhotoUrl,
      _firebaseAuth.currentUser?.photoURL,
      _providerPhotoUrl,
      _sharedPreferenceHelper.googleProfilePhotoUrl,
    ];

    for (final String? candidate in candidates) {
      final String? normalized = _normalizeValue(candidate);
      if (normalized != null) {
        return normalized;
      }
    }

    return null;
  }

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<AuthService> initialize() async {
    await _initializeGoogleSignIn();
    _lastGooglePhotoUrl = _sharedPreferenceHelper.googleProfilePhotoUrl;
    _lastGoogleDisplayName = _sharedPreferenceHelper.googleProfileDisplayName;
    await _sharedPreferenceHelper.saveIsLoggedIn(isLoggedIn);
    _authSubscription = _firebaseAuth.authStateChanges().listen((
      final User? user,
    ) {
      unawaited(_sharedPreferenceHelper.saveIsLoggedIn(user != null));
      if (user == null) {
        _lastGooglePhotoUrl = null;
        _lastGoogleDisplayName = null;
        unawaited(_sharedPreferenceHelper.saveGoogleProfilePhotoUrl(null));
        unawaited(_sharedPreferenceHelper.saveGoogleProfileDisplayName(null));
      }
    });
    return this;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return _firebaseAuth.signInWithPopup(GoogleAuthProvider());
    }

    await _initializeGoogleSignIn();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const AuthException(
        'Google Sign-In is not supported on this platform.',
      );
    }

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final String? idToken = googleUser.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw const AuthException(
        'Google Sign-In did not return an ID token. Please verify your Firebase Google Sign-In configuration.',
      );
    }

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final UserCredential userCredential = await _firebaseAuth
        .signInWithCredential(credential);
    await userCredential.user?.reload();
    _lastGooglePhotoUrl = _resolvePhotoUrl(
      googleUser: googleUser,
      userCredential: userCredential,
    );
    _lastGoogleDisplayName = _resolveDisplayName(
      googleUser: googleUser,
      userCredential: userCredential,
    );
    await _sharedPreferenceHelper.saveGoogleProfilePhotoUrl(
      _lastGooglePhotoUrl,
    );
    await _sharedPreferenceHelper.saveGoogleProfileDisplayName(
      _lastGoogleDisplayName,
    );
    return userCredential;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    _lastGooglePhotoUrl = null;
    _lastGoogleDisplayName = null;
    await _sharedPreferenceHelper.saveGoogleProfilePhotoUrl(null);
    await _sharedPreferenceHelper.saveGoogleProfileDisplayName(null);
    await _sharedPreferenceHelper.saveIsLoggedIn(false);
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_isGoogleInitialized || kIsWeb) {
      return;
    }

    await _googleSignIn.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? _iosClientId
          : null,
      serverClientId: _androidServerClientId,
    );
    _isGoogleInitialized = true;
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  String? get _providerPhotoUrl {
    for (final UserInfo provider in currentUser?.providerData ?? <UserInfo>[]) {
      final String? photoUrl = provider.photoURL?.trim();
      if (photoUrl != null && photoUrl.isNotEmpty) {
        return photoUrl;
      }
    }
    return null;
  }

  String? get _providerDisplayName {
    for (final UserInfo provider in currentUser?.providerData ?? <UserInfo>[]) {
      final String? displayName = provider.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        return displayName;
      }
    }
    return null;
  }

  String? _resolvePhotoUrl({
    required GoogleSignInAccount googleUser,
    required UserCredential userCredential,
  }) {
    final List<String?> candidates = <String?>[
      _firebaseAuth.currentUser?.photoURL,
      userCredential.user?.photoURL,
      _extractPhotoUrlFromProfile(userCredential.additionalUserInfo?.profile),
      _providerPhotoUrl,
      googleUser.photoUrl,
      _sharedPreferenceHelper.googleProfilePhotoUrl,
    ];

    for (final String? candidate in candidates) {
      final String? normalized = _normalizeValue(candidate);
      if (normalized != null) {
        return normalized;
      }
    }

    return null;
  }

  String? _resolveDisplayName({
    required GoogleSignInAccount googleUser,
    required UserCredential userCredential,
  }) {
    final List<String?> candidates = <String?>[
      googleUser.displayName,
      _firebaseAuth.currentUser?.displayName,
      userCredential.user?.displayName,
      _extractDisplayNameFromProfile(
        userCredential.additionalUserInfo?.profile,
      ),
      _providerDisplayName,
      _sharedPreferenceHelper.googleProfileDisplayName,
    ];

    for (final String? candidate in candidates) {
      final String? normalized = _normalizeValue(candidate);
      if (normalized != null) {
        return normalized;
      }
    }

    return null;
  }

  String? _extractPhotoUrlFromProfile(final Map<String, dynamic>? profile) {
    if (profile == null) {
      return null;
    }

    final Object? picture = profile['picture'];
    if (picture is String) {
      return picture;
    }

    if (picture is Map<Object?, Object?>) {
      final Object? data = picture['data'];
      if (data is Map<Object?, Object?>) {
        final Object? url = data['url'];
        if (url is String) {
          return url;
        }
      }
    }

    return null;
  }

  String? _extractDisplayNameFromProfile(final Map<String, dynamic>? profile) {
    if (profile == null) {
      return null;
    }

    final Object? name = profile['name'];
    if (name is String) {
      return name;
    }

    final Object? givenName = profile['given_name'];
    if (givenName is String) {
      return givenName;
    }

    return null;
  }

  String? _normalizeValue(final String? value) {
    if (value == null) {
      return null;
    }

    final String trimmedValue = value.trim();
    return trimmedValue.isEmpty ? null : trimmedValue;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
