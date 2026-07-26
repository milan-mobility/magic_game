import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/connection.dart';
import 'package:magic_games/view/base/offline_retry_dialog.dart';

class NetworkController extends GetxController implements GetxService {
  final RxBool isConnected = true.obs;

  final Completer<void> _startupCheckCompleter = Completer<void>();
  StreamSubscription<InternetStatus>? _connectionSubscription;

  bool _shouldRouteToHomeOnReconnect = false;
  bool _isOfflineDialogVisible = false;

  bool get shouldBlockStartupNavigation =>
      _shouldRouteToHomeOnReconnect && !isConnected.value;

  Future<void> get startupCheckCompleted => _startupCheckCompleter.future;

  @override
  void onInit() {
    super.onInit();
    _listenToNetworkChanges();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runStartupCheck());
    });
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
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

  Future<void> _handleNetworkStatusChange(bool connected) async {
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

  Future<void> _showOfflineDialogIfNeeded() async {
    if (_isOfflineDialogVisible) {
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
}
