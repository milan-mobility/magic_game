import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:magic_games/helpers/services/remote_config.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/view/base/offline_retry_dialog.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';

class NetworkController extends GetxController
    with WidgetsBindingObserver
    implements GetxService {
  final RxBool isConnected = true.obs;

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetConnection = InternetConnection();

  final Completer<void> _startupCheckCompleter = Completer<void>();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  StreamSubscription<InternetStatus>? _internetSubscription;

  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  Route<void>? _offlineDialogRoute;
  NavigatorState? _offlineDialogNavigator;

  bool _shouldRouteToHomeOnReconnect = false;
  bool _dialogPostFrameScheduled = false;
  bool _isDisposed = false;

  // Used to prevent an older async check from overriding a newer result.
  int _networkCheckVersion = 0;

  Future<void> get startupCheckCompleted => _startupCheckCompleter.future;

  bool get shouldBlockStartupNavigation =>
      _shouldRouteToHomeOnReconnect && !isConnected.value;

  bool get _isApplicationActive => _lifecycleState == AppLifecycleState.resumed;

  bool get _isOfflineDialogVisible => _offlineDialogRoute != null;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeNetworkController());
    });
  }

  Future<void> _initializeNetworkController() async {
    try {
      await _checkStartupConnection();

      if (_isApplicationActive) {
        _startNetworkListeners();

        // Check once more after registering listeners. This covers a network
        // change that happened between startup checking and listener setup.
        unawaited(_verifyInternetConnection());
      }
    } finally {
      if (!_startupCheckCompleter.isCompleted) {
        _startupCheckCompleter.complete();
      }
    }
  }

  Future<void> _checkStartupConnection() async {
    final bool connected = await _hasInternetAccess();

    if (_isDisposed) {
      return;
    }

    isConnected.value = connected;

    if (!connected) {
      _shouldRouteToHomeOnReconnect = true;

      if (_isApplicationActive) {
        unawaited(_showOfflineDialog());
      }
    }
  }

  void _startNetworkListeners() {
    _stopNetworkListeners();

    /*
     * connectivity_plus is used only as an immediate trigger.
     * Its value is not treated as the final internet status.
     */
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (_) {
        unawaited(_verifyInternetConnection());
      },
      onError: (_) {
        unawaited(_verifyInternetConnection());
      },
    );

    /*
     * Do not directly trust a potentially buffered status event after
     * resume. Trigger a fresh internet verification instead.
     */
    _internetSubscription = _internetConnection.onStatusChange.listen(
      (_) {
        unawaited(_verifyInternetConnection());
      },
      onError: (_) {
        unawaited(_verifyInternetConnection());
      },
    );
  }

  void _stopNetworkListeners() {
    final connectivitySubscription = _connectivitySubscription;
    final internetSubscription = _internetSubscription;

    _connectivitySubscription = null;
    _internetSubscription = null;

    if (connectivitySubscription != null) {
      unawaited(connectivitySubscription.cancel());
    }

    if (internetSubscription != null) {
      unawaited(internetSubscription.cancel());
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      return await _internetConnection.hasInternetAccess.timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );
    } catch (error, stackTrace) {
      debugPrint('Internet connection check failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _verifyInternetConnection() async {
    if (_isDisposed || !_isApplicationActive) {
      return;
    }

    final int currentCheckVersion = ++_networkCheckVersion;
    final bool connected = await _hasInternetAccess();

    /*
     * Ignore this result when another network check started after it.
     * This prevents an older "offline" result from overriding a newer
     * "connected" result.
     */
    if (_isDisposed ||
        !_isApplicationActive ||
        currentCheckVersion != _networkCheckVersion) {
      return;
    }

    await _applyConnectionStatus(connected);
  }

  Future<void> _applyConnectionStatus(bool connected) async {
    if (_isDisposed) {
      return;
    }

    final bool wasConnected = isConnected.value;
    isConnected.value = connected;

    if (connected) {
      _removeOfflineDialogImmediately();

      if (!wasConnected) {
        // The initial Remote Config fetch can fail while the app starts
        // offline. Refresh it before Home fetches its API data on reconnect.
        if (Get.isRegistered<RemoteConfigService>()) {
          await Get.find<RemoteConfigService>().refresh();
        }
      }

      bool navigatedToHome = false;
      if (_shouldRouteToHomeOnReconnect) {
        _shouldRouteToHomeOnReconnect = false;

        if (Get.currentRoute != RouteHelper.home) {
          await Get.offAllNamed(RouteHelper.home);
          navigatedToHome = true;
        }
      }

      if (!wasConnected &&
          !navigatedToHome &&
          Get.currentRoute == RouteHelper.home &&
          Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchGames();
      }

      return;
    }

    if (_isApplicationActive) {
      await _showOfflineDialog();
    }
  }

  Future<void> _showOfflineDialog() async {
    if (_isDisposed ||
        !_isApplicationActive ||
        isConnected.value ||
        _isOfflineDialogVisible) {
      return;
    }

    final BuildContext? context = Get.overlayContext ?? Get.context;

    if (context == null) {
      _scheduleOfflineDialogAfterFrame();
      return;
    }

    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);

    final RawDialogRoute<void> route = RawDialogRoute<void>(
      settings: const RouteSettings(name: '__offline_network_dialog__'),
      barrierDismissible: false,
      barrierColor: Colors.black54,
      barrierLabel: 'No internet connection',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return PopScope(
              canPop: false,
              child: OfflineRetryDialog(
                onRetry: () async {
                  await _verifyInternetConnection();
                  return isConnected.value;
                },
              ),
            );
          },
    );

    _offlineDialogRoute = route;
    _offlineDialogNavigator = navigator;

    try {
      await navigator.push<void>(route);
    } finally {
      /*
       * Do not clear a newer dialog route accidentally.
       */
      if (identical(_offlineDialogRoute, route)) {
        _offlineDialogRoute = null;
        _offlineDialogNavigator = null;
      }
    }
  }

  void _scheduleOfflineDialogAfterFrame() {
    if (_dialogPostFrameScheduled || _isDisposed) {
      return;
    }

    _dialogPostFrameScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dialogPostFrameScheduled = false;

      if (!_isDisposed && _isApplicationActive && !isConnected.value) {
        unawaited(_showOfflineDialog());
      }
    });
  }

  void _removeOfflineDialogImmediately() {
    final Route<void>? route = _offlineDialogRoute;
    final NavigatorState? navigator = _offlineDialogNavigator;

    if (route == null || navigator == null) {
      return;
    }

    _offlineDialogRoute = null;
    _offlineDialogNavigator = null;

    void removeRoute() {
      if (!navigator.mounted || !route.isActive) {
        return;
      }

      try {
        /*
         * This removes only the network dialog.
         * It does not close another dialog, page or game screen.
         */
        navigator.removeRoute<void>(route);
      } catch (error) {
        debugPrint('Unable to remove offline dialog: $error');
      }
    }

    try {
      removeRoute();
    } catch (_) {
      /*
       * Navigator can briefly be locked during another navigation operation.
       * Retry on the next frame in that case.
       */
      WidgetsBinding.instance.addPostFrameCallback((_) {
        removeRoute();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;

    if (state == AppLifecycleState.resumed) {
      /*
       * Restart subscriptions because a buffered stream may contain an old
       * status. Then always perform a fresh internet check.
       */
      _startNetworkListeners();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && _isApplicationActive) {
          unawaited(_verifyInternetConnection());
        }
      });

      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      /*
       * Invalidate any currently running network request.
       */
      _networkCheckVersion++;

      _stopNetworkListeners();

      /*
       * Remove the dialog while the app is backgrounded. On resume, a fresh
       * connection check decides whether it should be shown again.
       *
       * This prevents an incorrect offline dialog flash after unlocking.
       */
      _removeOfflineDialogImmediately();
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _networkCheckVersion++;

    WidgetsBinding.instance.removeObserver(this);

    _stopNetworkListeners();
    _removeOfflineDialogImmediately();

    if (!_startupCheckCompleter.isCompleted) {
      _startupCheckCompleter.complete();
    }

    super.onClose();
  }
}
