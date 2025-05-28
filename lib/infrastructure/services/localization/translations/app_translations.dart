import 'package:get/get.dart';
import 'tr_tr.dart';
import 'en_us.dart';
import 'es_es.dart';
import 'de_de.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'tr_TR': trTR,
    'en_US': enUS,
    'es_ES': esES,
    'de_DE': deDE,
  };
} 