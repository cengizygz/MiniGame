import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;
  
  // Servisi başlat
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  // String değeri kaydet
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  // String değeri al
  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }
  
  // Int değeri kaydet
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  // Int değeri al
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }
  
  // Double değeri kaydet
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }
  
  // Double değeri al
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }
  
  // Bool değeri kaydet
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  // Bool değeri al
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }
  
  // String listesi kaydet
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }
  
  // String listesi al
  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _prefs.getStringList(key) ?? defaultValue;
  }
  
  // Oyun skorunu ve son oynanma tarihini kaydet
  Future<void> saveGameResult(String gameKey, int score, {bool updateLastPlayed = true}) async {
    final currentScore = getInt('profile_highscore_$gameKey', defaultValue: 0);
    
    // Eğer yeni skor daha yüksekse, kaydet
    if (score > currentScore) {
      await setInt('profile_highscore_$gameKey', score);
    }
    
    // Son oynanma tarihini kaydet
    if (updateLastPlayed) {
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
      await setString('profile_lastplayed_$gameKey', dateStr);
    }
  }
  
  // Belirli bir anahtarı sil
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  // Tüm verileri temizle
  Future<bool> clear() async {
    return await _prefs.clear();
  }
  
  // Belirli bir anahtarın varlığını kontrol et
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
  
  // Tüm anahtarları al
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
} 