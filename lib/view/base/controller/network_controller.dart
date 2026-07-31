import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/connection.dart';
import 'package:magic_games/view/base/offline_retry_dialog.dart';

class NetworkController extends GetxController implements GetxService {
  static const Duration _resumeNetworkGracePeriod = Duration(seconds: 2);
  static const Duration _networkStatusPollInterval = Duration(seconds: 5);

  final RxBool isConnected = true.obs;

  final Completer<void> _startupCheckCompleter = Completer<void>();
  StreamSubscription<InternetStatus>? _connectionSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _shouldRouteToHomeOnReconnect = false;
  bool _isOfflineDialogVisible = false;
  bool _shouldRecheckConnectionAfterResume = false;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  DateTime? _lastResumedAt;
  Timer? _resumeConnectionTimer;
  Timer? _networkStatusPollTimer;
  bool _isPollingConnection = false;

  bool get shouldBlockStartupNavigation =>
      _shouldRouteToHomeOnReconnect && !isConnected.value;

  Future<void> get startupCheckCompleted => _startupCheckCompleter.future;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _appLifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    if (_appLifecycleState == AppLifecycleState.resumed) {
      _lastResumedAt = DateTime.now();
    }
    _listenToNetworkChanges();
    _startConnectionPolling();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runStartupCheck());
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _connectivitySubscription?.cancel();
    _connectionSubscription?.cancel();
    _resumeConnectionTimer?.cancel();
    _networkStatusPollTimer?.cancel();
    super.onClose();
  }

  Future<bool> _checkNetworkAccess() async {
    final List<ConnectivityResult> results =
        await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return false;
    }
    return ConnectionUtils.isNetworkConnected();
  }

  Future<void> _runStartupCheck() async {
    final bool connected = await _checkNetworkAccess();
    isConnected.value = connected;

    if (!connected) {
      _shouldRouteToHomeOnReconnect = true;
      unawaited(_showOfflineDialogIfNeeded());
    }

    if (!_startupCheckCompleter.isCompleted) {
      _startupCheckCompleter.complete();
    }
  }

  void _listenToNetworkChanges() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) async {
      final bool hasHardwareConnection =
          !results.contains(ConnectivityResult.none) && results.isNotEmpty;

      if (!hasHardwareConnection) {
        unawaited(_handleNetworkStatusChange(false));
      } else {
        final bool connected = await _checkNetworkAccess();
        unawaited(_handleNetworkStatusChange(connected));
      }
    });

    _connectionSubscription = ConnectionUtils.onStatusChange.listen((status) {
      unawaited(_handleNetworkStatusChange(status == InternetStatus.connected));
    });
  }

  void _startConnectionPolling() {
    _networkStatusPollTimer?.cancel();
    _networkStatusPollTimer = Timer.periodic(_networkStatusPollInterval, (_) {
      unawaited(_pollConnectionStatus());
    });
  }

  Future<void> _pollConnectionStatus() async {
    if (_isPollingConnection) {
      return;
    }

    _isPollingConnection = true;
    try {
      final bool connected = await _checkNetworkAccess();
      if (connected == isConnected.value &&
          (connected || _isOfflineDialogVisible)) {
        return;
      }

      await _handleNetworkStatusChange(connected);
    } finally {
      _isPollingConnection = false;
    }
  }

  Future<void> _handleNetworkStatusChange(bool streamConnected) async {
    final bool wasConnected = isConnected.value;
    isConnected.value = streamConnected;

    if (streamConnected) {
      _shouldRecheckConnectionAfterResume = false;
      await _handleConnectionRestored();
      return;
    }

    if (_shouldSuppressOfflineDialog) {
      _shouldRecheckConnectionAfterResume = true;
      _scheduleResumeConnectionCheck();
      return;
    }

    if (wasConnected || !_isOfflineDialogVisible) {
      await _showOfflineDialogIfNeeded(skipConnectionCheck: true);
    }
  }

  Future<void> _showOfflineDialogIfNeeded({
    bool skipConnectionCheck = false,
  }) async {
    if (_isOfflineDialogVisible) {
      return;
    }

    if (!skipConnectionCheck) {
      final bool connected = await _checkNetworkAccess();
      if (connected) {
        isConnected.value = true;
        return;
      }
    }

    if (Get.context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          _showOfflineDialogIfNeeded(skipConnectionCheck: skipConnectionCheck),
        );
      });
      return;
    }

    _isOfflineDialogVisible = true;

    await showOfflineRetryDialog(
      onRetry: () async {
        final bool connected = await _checkNetworkAccess();
        if (connected) {
          await _handleConnectionRestored();
        }
        return connected;
      },
    );

    _isOfflineDialogVisible = false;

    final bool stillConnected = await _checkNetworkAccess();
    isConnected.value = stillConnected;
    if (stillConnected) {
      await _handleConnectionRestored();
    }
  }

  Future<void> _handleConnectionRestored() async {
    await _closeOfflineDialogIfNeeded();

    if (_shouldRouteToHomeOnReconnect) {
      _shouldRouteToHomeOnReconnect = false;
      await Get.offAllNamed(RouteHelper.home);
    }
  }

  Future<void> _closeOfflineDialogIfNeeded() async {
    if (_isOfflineDialogVisible && (Get.isDialogOpen ?? false)) {
      Get.back<void>();
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  bool get _shouldSuppressOfflineDialog =>
      _appLifecycleState != AppLifecycleState.resumed ||
      _isWithinResumeGracePeriod;

  bool get _isWithinResumeGracePeriod {
    final DateTime? lastResumedAt = _lastResumedAt;
    if (lastResumedAt == null) {
      return false;
    }

    return DateTime.now().difference(lastResumedAt) < _resumeNetworkGracePeriod;
  }

  void _scheduleResumeConnectionCheck() {
    _resumeConnectionTimer?.cancel();
    if (!_shouldRecheckConnectionAfterResume ||
        _appLifecycleState != AppLifecycleState.resumed) {
      return;
    }

    // Give the OS a moment to restore networking after unlock/resume.
    _resumeConnectionTimer = Timer(_resumeNetworkGracePeriod, () {
      unawaited(_runResumeConnectionCheck());
    });
  }

  Future<void> _runResumeConnectionCheck() async {
    if (_appLifecycleState != AppLifecycleState.resumed) {
      return;
    }

    _shouldRecheckConnectionAfterResume = false;
    final bool connected = await _checkNetworkAccess();
    final bool wasConnected = isConnected.value;
    isConnected.value = connected;

    if (connected) {
      await _handleConnectionRestored();
      return;
    }

    if (wasConnected || !_isOfflineDialogVisible) {
      await _showOfflineDialogIfNeeded();
    }
  }

  late final WidgetsBindingObserver _lifecycleObserver =
      _NetworkLifecycleObserver(this);

  void _handleAppLifecycleStateChanged(AppLifecycleState state) {
    _appLifecycleState = state;

    if (state == AppLifecycleState.resumed) {
      _lastResumedAt = DateTime.now();
      _scheduleResumeConnectionCheck();
      return;
    }

    _resumeConnectionTimer?.cancel();
  }
}

class _NetworkLifecycleObserver with WidgetsBindingObserver {
  _NetworkLifecycleObserver(this._controller);

  final NetworkController _controller;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller._handleAppLifecycleStateChanged(state);
  }
}
