import 'package:get/get.dart';

import 'ar_SA/ar_sa_translations.dart';
import 'bn_BD/bn_bd_translations.dart';
import 'de_DE/de_de_translations.dart';
import 'en_US/en_us_translations.dart';
import 'es_ES/es_es_translations.dart';
import 'fr_FR/fr_fr_translations.dart';
import 'hi_IN/hi_in_translations.dart';
import 'id_ID/id_id_translations.dart';
import 'it_IT/it_it_translations.dart';
import 'ja_JP/ja_jp_translations.dart';
import 'ko_KR/ko_kr_translations.dart';
import 'nl_NL/nl_nl_translations.dart';
import 'pt_PT/pt_pt_translations.dart';
import 'ru_RU/ru_ru_translations.dart';
import 'th_TH/th_th_translations.dart';
import 'tr_TR/tr_tr_translations.dart';
import 'ur_PK/ur_pk_translations.dart';
import 'zh_CN/zh_cn_translations.dart';
import 'zh_TW/zh_tw_translations.dart';

Map<String, Map<String, String>> translations = <String, Map<String, String>>{
  'ar': arSa,
  'bn': bnBd,
  'de': deDe,
  'en': enUs,
  'es': esEs,
  'fr': frFr,
  'hi': hiIn,
  'id': idId,
  'it': itIt,
  'ja': jaJp,
  'ko': koKr,
  'nl': nlNl,
  'pt': ptPt,
  'ru': ruRu,
  'th': thTh,
  'tr': trTr,
  'ur': urPk,
  'zh_CN': zhCn,
  'zh_TW': zhTw,
};

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => translations;
}
