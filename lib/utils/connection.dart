import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionUtils {
  static final InternetConnection _checker = InternetConnection.createInstance(
    useDefaultOptions: false,
    customCheckOptions: <InternetCheckOption>[
      InternetCheckOption(
        uri: Uri.parse('https://captive.apple.com/hotspot-detect.html'),
        timeout: const Duration(seconds: 5),
      ),
      InternetCheckOption(
        uri: Uri.parse('https://www.google.com/generate_204'),
        timeout: const Duration(seconds: 5),
      ),
      InternetCheckOption(
        uri: Uri.parse('https://cloudflare.com/cdn-cgi/trace'),
        timeout: const Duration(seconds: 5),
      ),
    ],
  );

  static Future<bool> isNetworkConnected() async {
    return _checker.hasInternetAccess;
  }

  static Stream<InternetStatus> get onStatusChange => _checker.onStatusChange;
}
