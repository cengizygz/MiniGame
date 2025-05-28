import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class AudioService extends GetxService {
  late AudioPlayer musicPlayer;
  late AudioPlayer soundPlayer;
  
  final RxBool _isMusicEnabled = true.obs;
  final RxBool _isSoundEnabled = true.obs;
  final RxDouble _musicVolume = 0.7.obs;
  final RxDouble _soundVolume = 1.0.obs;
  
  bool get isMusicEnabled => _isMusicEnabled.value;
  bool get isSoundEnabled => _isSoundEnabled.value;
  double get musicVolume => _musicVolume.value;
  double get soundVolume => _soundVolume.value;
  
  // Ses dosyaları için önbellek
  final Map<String, AudioCache> _audioCache = {};
  
  // Servis başlatma metodu
  Future<AudioService> init() async {
    musicPlayer = AudioPlayer();
    soundPlayer = AudioPlayer();
    
    // Döngü modunda müzik çalmak için
    musicPlayer.onPlayerComplete.listen((event) {
      if (isMusicEnabled) {
        musicPlayer.resume(); // Müzik bittiğinde tekrar başlat
      }
    });
    
    await loadSettings();
    
    return this;
  }
  
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicEnabled.value = prefs.getBool(AppConstants.musicKey) ?? AppConstants.defaultMusicEnabled;
    _isSoundEnabled.value = prefs.getBool(AppConstants.soundKey) ?? AppConstants.defaultSoundEnabled;
    
    // Ses seviyesini ayarla
    await musicPlayer.setVolume(_isMusicEnabled.value ? _musicVolume.value : 0);
    await soundPlayer.setVolume(_isSoundEnabled.value ? _soundVolume.value : 0);
  }
  
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.musicKey, _isMusicEnabled.value);
    await prefs.setBool(AppConstants.soundKey, _isSoundEnabled.value);
  }
  
  Future<void> playMusic(String assetPath) async {
    if (!isMusicEnabled) return;
    
    try {
      await musicPlayer.stop();
      final source = AssetSource(assetPath);
      await musicPlayer.play(source);
      await musicPlayer.setVolume(_musicVolume.value);
    } catch (e) {
      // Müzik dosyası bulunamadı veya çalınamadı, sessizce devam et
      debugPrint('Müzik dosyası çalınamadı: $assetPath - $e');
    }
  }
  
  Future<void> pauseMusic() async {
    await musicPlayer.pause();
  }
  
  Future<void> resumeMusic() async {
    if (!isMusicEnabled) return;
    await musicPlayer.resume();
  }
  
  Future<void> stopMusic() async {
    await musicPlayer.stop();
  }
  
  Future<void> playSound(String assetPath) async {
    if (!isSoundEnabled) return;
    
    try {
      final source = AssetSource(assetPath);
      await soundPlayer.play(source);
      await soundPlayer.setVolume(_soundVolume.value);
    } catch (e) {
      // Ses dosyası bulunamadı veya çalınamadı, sessizce devam et
      debugPrint('Ses dosyası çalınamadı: $assetPath - $e');
    }
  }
  
  // Ses efektleri için kısa yol metodu (mini oyunlar için)
  Future<void> playSfx(String sfxName) async {
    if (!isSoundEnabled) return;
    
    try {
      // Dosya uzantısını otomatik olarak ekle
      final assetPath = 'sounds/$sfxName.mp3';
      
      final source = AssetSource(assetPath);
      await soundPlayer.play(source);
      await soundPlayer.setVolume(_soundVolume.value);
    } catch (e) {
      // Ses dosyası bulunamadı veya çalınamadı, sessizce devam et
      debugPrint('Ses dosyası çalınamadı: $sfxName - $e');
    }
  }
  
  Future<void> toggleMusic() async {
    _isMusicEnabled.value = !_isMusicEnabled.value;
    await musicPlayer.setVolume(_isMusicEnabled.value ? _musicVolume.value : 0);
    await saveSettings();
  }
  
  Future<void> toggleSound() async {
    _isSoundEnabled.value = !_isSoundEnabled.value;
    await soundPlayer.setVolume(_isSoundEnabled.value ? _soundVolume.value : 0);
    await saveSettings();
  }
  
  Future<void> setMusicVolume(double volume) async {
    _musicVolume.value = volume;
    if (_isMusicEnabled.value) {
      await musicPlayer.setVolume(volume);
    }
  }
  
  Future<void> setSoundVolume(double volume) async {
    _soundVolume.value = volume;
    if (_isSoundEnabled.value) {
      await soundPlayer.setVolume(volume);
    }
  }
  
  @override
  void onClose() {
    musicPlayer.dispose();
    soundPlayer.dispose();
    _audioCache.clear();
    super.onClose();
  }
} 