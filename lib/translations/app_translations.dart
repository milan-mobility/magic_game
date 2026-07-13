import 'package:get/get.dart';

import 'en_US/en_us_translations.dart';

Map<String, Map<String, String>> translations = <String, Map<String, String>>{
  'en': enUs,
};

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => translations;
}
