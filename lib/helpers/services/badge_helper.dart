import 'package:flutter_new_badger/flutter_new_badger.dart';

class BadgeHelper {
  static Future<void> clear() async {
    FlutterNewBadger.removeBadge();
  }

  static Future<void> increment(int count) async {
    FlutterNewBadger.setBadge(count);
  }
}
