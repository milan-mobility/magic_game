import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magic_games/di/get_di.dart';
import 'package:magic_games/helpers/ads/consent_manager.dart';
import 'package:magic_games/helpers/services/notification_service.dart';

import 'app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await init();
  NotificationService().setupInteractedMessage();

  // await ConsentManager.instance.resetForTesting(); //TODO development only for testing a consent
  await ConsentManager.instance.init(
    debugGeography:
        true, //TODO MAKE SURE YOU SHOULD HAVE TO MARK AS FALSE BEFORE YOU GO LIVE
    testDeviceIds: const <String>[
      '9F158A55589AAC6782B4FC31799463AC',
      '27A90922BF70C3EF357BF5E7465783A0',
    ], //TODO development only
  );

  final RequestConfiguration requestConfig = RequestConfiguration(
    testDeviceIds: <String>[
      '9F158A55589AAC6782B4FC31799463AC',
      '27A90922BF70C3EF357BF5E7465783A0',
    ], //TODO development only
    tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
  );
  await MobileAds.instance.updateRequestConfiguration(requestConfig);

  await MobileAds.instance.initialize();
  runApp(const MyApp());
}
