import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionUtils {
  static final InternetConnection _statusChecker =
      InternetConnection.createInstance(
        checkInterval: const Duration(milliseconds: 600),
        useDefaultOptions: false,
        customCheckOptions: <InternetCheckOption>[
          InternetCheckOption(
            uri: Uri.parse('https://www.google.com/generate_204'),
            timeout: const Duration(milliseconds: 800),
          ),
        ],
      );

  static final InternetConnection _accessChecker =
      InternetConnection.createInstance(
        useDefaultOptions: false,
        customCheckOptions: <InternetCheckOption>[
          InternetCheckOption(
            uri: Uri.parse('https://captive.apple.com/hotspot-detect.html'),
            timeout: const Duration(milliseconds: 1500),
          ),
          InternetCheckOption(
            uri: Uri.parse('https://www.google.com/generate_204'),
            timeout: const Duration(milliseconds: 1500),
          ),
        ],
      );

  static Future<bool> isNetworkConnected() async {
    final InternetConnection checker = InternetConnection.createInstance(
      useDefaultOptions: false,
      customCheckOptions: <InternetCheckOption>[
        InternetCheckOption(
          uri: Uri.parse('https://captive.apple.com/hotspot-detect.html'),
          timeout: const Duration(seconds: 5),
        ),
      ],
    );
    return checker.hasInternetAccess;
  }

  static Stream<InternetStatus> get onStatusChange =>
      _statusChecker.onStatusChange;
}
