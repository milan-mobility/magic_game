import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magic_games/di/get_di.dart';
import 'package:magic_games/helpers/services/notification_service.dart';

import 'app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterLocalization.instance.ensureInitialized();

  await Firebase.initializeApp();

  await init();
  NotificationService().setupInteractedMessage();

  await MobileAds.instance.initialize();
  runApp(const MyApp());
}
