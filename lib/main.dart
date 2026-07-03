import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magic_games/di/get_di.dart';

import 'app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  await MobileAds.instance.initialize();
  runApp(const MyApp());
}
