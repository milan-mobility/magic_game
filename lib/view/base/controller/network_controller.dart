import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/connection.dart';
import 'package:magic_games/view/base/offline_retry_dialog.dart';

class NetworkController extends GetxController implements GetxService {
  static const Duration _resumeNetworkGracePeriod = Duration(seconds: 2);

  final RxBool isConnected = true.obs;

  final Completer<void> _startupCheckCompleter = Completer<void>();
  StreamSubscription<InternetStatus>? _connectionSubscription;

  bool _shouldRouteToHomeOnReconnect = false;
  bool _isOfflineDialogVisible = false;
  bool _shouldRecheckConnectionAfterResume = false;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  DateTime? _lastResumedAt;
  Timer? _resumeConnectionTimer;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runStartupCheck());
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _connectionSubscription?.cancel();
    _resumeConnectionTimer?.cancel();
    super.onClose();
  }

  Future<void> _runStartupCheck() async {
    final bool connected = await ConnectionUtils.isNetworkConnected();
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
    _connectionSubscription = ConnectionUtils.onStatusChange.listen((status) {
      unawaited(_handleNetworkStatusChange(status == InternetStatus.connected));
    });
  }

  Future<void> _handleNetworkStatusChange(bool streamConnected) async {
    final bool connected = await ConnectionUtils.isNetworkConnected();
    final bool wasConnected = isConnected.value;
    isConnected.value = connected;

    if (connected) {
      _shouldRecheckConnectionAfterResume = false;
      await _handleConnectionRestored();
      return;
    }

    if (_shouldSuppressOfflineDialog) {
      _shouldRecheckConnectionAfterResume = true;
      _scheduleResumeConnectionCheck();
      return;
    }

    if (!streamConnected && (wasConnected || !_isOfflineDialogVisible)) {
      await _showOfflineDialogIfNeeded();
    }
  }

  Future<void> _showOfflineDialogIfNeeded() async {
    if (_isOfflineDialogVisible) {
      return;
    }

    final bool connected = await ConnectionUtils.isNetworkConnected();
    if (connected) {
      isConnected.value = true;
      return;
    }

    if (Get.context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_showOfflineDialogIfNeeded());
      });
      return;
    }

    _isOfflineDialogVisible = true;

    await showOfflineRetryDialog(
      onRetry: () async {
        final bool connected = await ConnectionUtils.isNetworkConnected();
        if (connected) {
          await _handleConnectionRestored();
        }
        return connected;
      },
    );

    _isOfflineDialogVisible = false;

    final bool stillConnected = await ConnectionUtils.isNetworkConnected();
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
    final bool connected = await ConnectionUtils.isNetworkConnected();
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
