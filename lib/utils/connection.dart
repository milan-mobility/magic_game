import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionUtils {
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
}
