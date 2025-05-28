import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class LocalizationService extends GetxService {
  // Desteklenen diller
  static final List<Locale> supportedLocales = [
    const Locale('tr', 'TR'), // Türkçe
    const Locale('en', 'US'), // İngilizce
    const Locale('es', 'ES'), // İspanyolca
    const Locale('de', 'DE'), // Almanca
  ];
  
  // Dil isim eşleştirmeleri
  static final Map<String, String> languageNames = {
    'tr_TR': 'Türkçe',
    'en_US': 'English',
    'es_ES': 'Español',
    'de_DE': 'Deutsch',
  };
  
  // Varsayılan dil
  static const Locale fallbackLocale = Locale('tr', 'TR');
  
  // Mevcut dil
  Rx<Locale> currentLocale = fallbackLocale.obs;
  
  // Servis başlatma metodu
  Future<LocalizationService> init() async {
    await loadSavedLanguage();
    return this;
  }
  
  // Kaydedilmiş dili yükle
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.languageKey);
    
    if (languageCode != null) {
      final parts = languageCode.split('_');
      if (parts.length == 2) {
        currentLocale.value = Locale(parts[0], parts[1]);
        Get.updateLocale(currentLocale.value);
      }
    } else {
      // Sistem dilini al
      final systemLocale = Get.deviceLocale;
      if (systemLocale != null && isSupported(systemLocale)) {
        currentLocale.value = systemLocale;
        Get.updateLocale(systemLocale);
      }
    }
  }
  
  // Dili değiştir
  Future<void> changeLanguage(String languageCode, String countryCode) async {
    final locale = Locale(languageCode, countryCode);
    if (isSupported(locale)) {
      currentLocale.value = locale;
      Get.updateLocale(locale);
      
      // Dil tercihini kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.languageKey, 
        '${locale.languageCode}_${locale.countryCode}'
      );
    }
  }
  
  // Dil destekleniyor mu kontrol et
  bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) => 
      supportedLocale.languageCode == locale.languageCode && 
      supportedLocale.countryCode == locale.countryCode
    );
  }
  
  // Kullanıcı arayüzünde dili değiştirmek için
  void switchLanguage(String localeKey) {
    final parts = localeKey.split('_');
    if (parts.length == 2) {
      changeLanguage(parts[0], parts[1]);
    }
  }
  
  // Geçerli dil adını al
  String getCurrentLanguageName() {
    final localeKey = '${currentLocale.value.languageCode}_${currentLocale.value.countryCode}';
    return languageNames[localeKey] ?? languageNames['tr_TR']!;
  }
} 