import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../infrastructure/services/audio/audio_service.dart';
import '../../../infrastructure/services/localization/localization_service.dart';
import '../../../infrastructure/services/storage/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioService audioService = Get.find<AudioService>();
    final LocalizationService localizationService = Get.find<LocalizationService>();
    final StorageService storageService = Get.find<StorageService>();
    
    // Tema durumu
    final isDarkMode = storageService.getBool(AppConstants.themeKey, defaultValue: false);
    final isDarkModeRx = isDarkMode.obs;
    
    // FPS ve çözünürlük durumları
    final fps = storageService.getInt(AppConstants.fpsKey, defaultValue: AppConstants.defaultFps).obs;
    final resolution = storageService.getString(
      AppConstants.resolutionKey, 
      defaultValue: AppConstants.defaultResolution
    ).obs;
    
    // Çözünürlük seçenekleri
    final resolutionOptions = ['Low', 'Medium', 'HD', 'Full HD'].obs;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ses Ayarları Başlığı
            Text(
              'sound_settings'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            
            // Müzik Ayarı
            Obx(() => SwitchListTile(
              title: Text('music'.tr),
              value: audioService.isMusicEnabled,
              onChanged: (value) => audioService.toggleMusic(),
            )),
            
            // Ses Efektleri Ayarı
            Obx(() => SwitchListTile(
              title: Text('sound_effects'.tr),
              value: audioService.isSoundEnabled,
              onChanged: (value) => audioService.toggleSound(),
            )),
            
            // Müzik Seviyesi
            Obx(() => ListTile(
              title: Text('music_volume'.tr),
              subtitle: Slider(
                value: audioService.musicVolume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) => audioService.setMusicVolume(value),
              ),
            )),
            
            // Ses Efekti Seviyesi
            Obx(() => ListTile(
              title: Text('sound_volume'.tr),
              subtitle: Slider(
                value: audioService.soundVolume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) => audioService.setSoundVolume(value),
              ),
            )),
            
            const SizedBox(height: 24),
            
            // Görsel Ayarlar
            Text(
              'graphics'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            
            // Tema Ayarı
            Obx(() => SwitchListTile(
              title: Text('theme'.tr),
              subtitle: Text(isDarkModeRx.value ? 'dark'.tr : 'light'.tr),
              value: isDarkModeRx.value,
              onChanged: (value) {
                isDarkModeRx.value = value;
                storageService.setBool(AppConstants.themeKey, value);
                Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            )),
            
            // FPS Ayarı
            Obx(() => ListTile(
              title: Text('fps'.tr),
              subtitle: Slider(
                value: fps.value.toDouble(),
                min: 30,
                max: 120,
                divisions: 3,
                label: fps.value.toString(),
                onChanged: (value) {
                  fps.value = value.toInt();
                  storageService.setInt(AppConstants.fpsKey, value.toInt());
                },
              ),
              trailing: Text('${fps.value} FPS'),
            )),
            
            // Çözünürlük Ayarı
            Obx(() => ListTile(
              title: Text('resolution'.tr),
              subtitle: DropdownButton<String>(
                value: resolution.value,
                isExpanded: true,
                items: resolutionOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    resolution.value = newValue;
                    storageService.setString(AppConstants.resolutionKey, newValue);
                  }
                },
              ),
            )),
            
            const SizedBox(height: 24),
            
            // Dil Ayarları
            Text(
              'language'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            
            // Dil Seçenekleri
            ListTile(
              title: const Text('Türkçe'),
              trailing: Radio<String>(
                value: 'tr_TR',
                groupValue: '${localizationService.currentLocale.value.languageCode}_${localizationService.currentLocale.value.countryCode}',
                onChanged: (value) {
                  if (value != null) {
                    localizationService.switchLanguage(value);
                  }
                },
              ),
              onTap: () => localizationService.switchLanguage('tr_TR'),
            ),
            
            ListTile(
              title: const Text('English'),
              trailing: Radio<String>(
                value: 'en_US',
                groupValue: '${localizationService.currentLocale.value.languageCode}_${localizationService.currentLocale.value.countryCode}',
                onChanged: (value) {
                  if (value != null) {
                    localizationService.switchLanguage(value);
                  }
                },
              ),
              onTap: () => localizationService.switchLanguage('en_US'),
            ),
            
            ListTile(
              title: const Text('Español'),
              trailing: Radio<String>(
                value: 'es_ES',
                groupValue: '${localizationService.currentLocale.value.languageCode}_${localizationService.currentLocale.value.countryCode}',
                onChanged: (value) {
                  if (value != null) {
                    localizationService.switchLanguage(value);
                  }
                },
              ),
              onTap: () => localizationService.switchLanguage('es_ES'),
            ),
            
            ListTile(
              title: const Text('Deutsch'),
              trailing: Radio<String>(
                value: 'de_DE',
                groupValue: '${localizationService.currentLocale.value.languageCode}_${localizationService.currentLocale.value.countryCode}',
                onChanged: (value) {
                  if (value != null) {
                    localizationService.switchLanguage(value);
                  }
                },
              ),
              onTap: () => localizationService.switchLanguage('de_DE'),
            ),
            
            const SizedBox(height: 32),
            
            // Uygulama bilgileri
            Center(
              child: Column(
                children: [
                  Text('app_name'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Versiyon: ${AppConstants.appVersion}'),
                  const SizedBox(height: 8),
                  const Text('© 2025 Tüm Hakları Saklıdır'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 