import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_routes.dart';
import 'infrastructure/services/ad/ad_service.dart';
import 'infrastructure/services/audio/audio_service.dart';
import 'infrastructure/services/localization/localization_service.dart';
import 'infrastructure/services/localization/translations/app_translations.dart';
import 'infrastructure/services/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Google Mobile Ads SDK başlat
  MobileAds.instance.initialize();
  
  // Servisleri başlat
  await initServices();
  
  runApp(const MainApp());
}

// Servisleri başlatma fonksiyonu
Future<void> initServices() async {
  // Depolama servisi
  await Get.putAsync(() => StorageService().init());
  
  // Audio servisi
  await Get.putAsync(() => AudioService().init());
  
  // Dil servisi
  await Get.putAsync(() => LocalizationService().init());
  
  // Reklam servisi
  await Get.putAsync(() => AdService().init());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dil servisi bağlantısı
    final localizationService = Get.find<LocalizationService>();
    
    // Depolama servisinden tema ayarını al
    final storageService = Get.find<StorageService>();
    final isDarkMode = storageService.getBool(AppConstants.themeKey, defaultValue: false);
    
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Uygulama başlangıç rotası
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
      
      // Dil desteği
      locale: localizationService.currentLocale.value,
      fallbackLocale: LocalizationService.fallbackLocale,
      translations: AppTranslations(),
      
      // Flutter yerelleştirme desteği
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
    );
  }
}
