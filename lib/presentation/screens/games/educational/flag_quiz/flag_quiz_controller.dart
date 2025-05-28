import 'package:get/get.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

// Zorluk seviyesi
enum FlagQuizDifficulty {
  easy,
  medium,
  hard
}

// Bayrak soru modeli
class FlagQuestion {
  final String countryCode;
  final String countryName;
  final List<String> options;

  FlagQuestion({
    required this.countryCode,
    required this.countryName,
    required this.options,
  });
}

class FlagQuizController extends GetxController {
  // Temel değişkenler
  int score = 0;
  int highScore = 0;
  int questionsAnswered = 0;
  int correctAnswers = 0;
  
  // Mevcut soru
  FlagQuestion? currentQuestion;
  
  // Oyun süresi
  int timeLeft = 60; // saniye
  Timer? gameTimer;
  
  // Oyun ayarları
  FlagQuizDifficulty difficulty = FlagQuizDifficulty.medium;
  
  // Oyun durumu
  bool isGameRunning = false;
  bool isGameOver = false;
  
  // Random nesnesi
  final Random random = Random();
  
  // Animasyon durumu
  bool showCorrectAnimation = false;
  bool showWrongAnimation = false;
  
  // Ülke listeleri
  List<Map<String, String>> allCountries = [];
  List<Map<String, String>> easyCountries = [];
  List<Map<String, String>> mediumCountries = [];
  List<Map<String, String>> hardCountries = [];
  
  @override
  void onInit() {
    super.onInit();
    // Ülke listelerini oluştur
    _initializeCountries();
    // Yüksek skoru yükle
    loadHighScore();
  }
  
  @override
  void onClose() {
    gameTimer?.cancel();
    super.onClose();
  }
  
  // Ülke listelerini oluştur
  void _initializeCountries() {
    // Kolay düzeydeki popüler ve tanınmış ülkeler
    easyCountries = [
      {'code': 'tr', 'name': 'Türkiye'},
      {'code': 'us', 'name': 'Amerika Birleşik Devletleri'},
      {'code': 'gb', 'name': 'Birleşik Krallık'},
      {'code': 'de', 'name': 'Almanya'},
      {'code': 'fr', 'name': 'Fransa'},
      {'code': 'it', 'name': 'İtalya'},
      {'code': 'es', 'name': 'İspanya'},
      {'code': 'jp', 'name': 'Japonya'},
      {'code': 'cn', 'name': 'Çin'},
      {'code': 'ru', 'name': 'Rusya'},
      {'code': 'br', 'name': 'Brezilya'},
      {'code': 'ca', 'name': 'Kanada'},
      {'code': 'au', 'name': 'Avustralya'},
      {'code': 'in', 'name': 'Hindistan'},
      {'code': 'za', 'name': 'Güney Afrika'},
      {'code': 'mx', 'name': 'Meksika'},
      {'code': 'ar', 'name': 'Arjantin'},
      {'code': 'eg', 'name': 'Mısır'},
      {'code': 'gr', 'name': 'Yunanistan'},
      {'code': 'se', 'name': 'İsveç'},
    ];
    
    // Orta düzeydeki daha az bilinen ülkeler
    mediumCountries = [
      {'code': 'nl', 'name': 'Hollanda'},
      {'code': 'pt', 'name': 'Portekiz'},
      {'code': 'be', 'name': 'Belçika'},
      {'code': 'ch', 'name': 'İsviçre'},
      {'code': 'at', 'name': 'Avusturya'},
      {'code': 'pl', 'name': 'Polonya'},
      {'code': 'dk', 'name': 'Danimarka'},
      {'code': 'no', 'name': 'Norveç'},
      {'code': 'fi', 'name': 'Finlandiya'},
      {'code': 'ie', 'name': 'İrlanda'},
      {'code': 'nz', 'name': 'Yeni Zelanda'},
      {'code': 'sg', 'name': 'Singapur'},
      {'code': 'ua', 'name': 'Ukrayna'},
      {'code': 'cz', 'name': 'Çek Cumhuriyeti'},
      {'code': 'hu', 'name': 'Macaristan'},
      {'code': 'ro', 'name': 'Romanya'},
      {'code': 'kr', 'name': 'Güney Kore'},
      {'code': 'za', 'name': 'Güney Afrika'},
      {'code': 'th', 'name': 'Tayland'},
      {'code': 'id', 'name': 'Endonezya'},
    ];
    
    // Zor düzeydeki az bilinen ülkeler
    hardCountries = [
      {'code': 'az', 'name': 'Azerbaycan'},
      {'code': 'kz', 'name': 'Kazakistan'},
      {'code': 'qa', 'name': 'Katar'},
      {'code': 'uy', 'name': 'Uruguay'},
      {'code': 've', 'name': 'Venezuela'},
      {'code': 'pe', 'name': 'Peru'},
      {'code': 'cl', 'name': 'Şili'},
      {'code': 'co', 'name': 'Kolombiya'},
      {'code': 'ng', 'name': 'Nijerya'},
      {'code': 'et', 'name': 'Etiyopya'},
      {'code': 'ke', 'name': 'Kenya'},
      {'code': 'lk', 'name': 'Sri Lanka'},
      {'code': 'vn', 'name': 'Vietnam'},
      {'code': 'ph', 'name': 'Filipinler'},
      {'code': 'my', 'name': 'Malezya'},
      {'code': 'np', 'name': 'Nepal'},
      {'code': 'bd', 'name': 'Bangladeş'},
      {'code': 'pk', 'name': 'Pakistan'},
      {'code': 'ee', 'name': 'Estonya'},
      {'code': 'lv', 'name': 'Letonya'},
    ];
    
    // Tüm ülkeleri birleştir
    allCountries = [...easyCountries, ...mediumCountries, ...hardCountries];
  }
  
  // Yüksek skoru yükle
  void loadHighScore() async {
    // TODO: SharedPreferences ile yüksek skoru yükleme
    // Şimdilik 0 değeri atıyoruz
    highScore = 0;
    update();
  }
  
  // Yüksek skoru kaydet
  void saveHighScore() async {
    // TODO: SharedPreferences ile yüksek skoru kaydetme
    if (score > highScore) {
      highScore = score;
      update();
    }
  }
  
  // Oyunu başlat
  void startGame() {
    resetGame();
    isGameRunning = true;
    isGameOver = false;
    generateNewQuestion();
    startTimer();
    update();
  }
  
  // Oyunu sıfırla
  void resetGame() {
    score = 0;
    questionsAnswered = 0;
    correctAnswers = 0;
    timeLeft = 60;
    isGameRunning = false;
    isGameOver = false;
    currentQuestion = null;
    gameTimer?.cancel();
    update();
  }
  
  // Zorluk seviyesini değiştir
  void setDifficulty(FlagQuizDifficulty newDifficulty) {
    if (!isGameRunning) {
      difficulty = newDifficulty;
      update();
    }
  }
  
  // Zamanlayıcıyı başlat
  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
        update();
      } else {
        endGame();
      }
    });
  }
  
  // Oyunu bitir
  void endGame() {
    gameTimer?.cancel();
    isGameRunning = false;
    isGameOver = true;
    saveHighScore();
    update();
  }
  
  // Yeni soru oluştur
  void generateNewQuestion() {
    // Zorluk seviyesine göre ülke listesi seç
    List<Map<String, String>> currentCountries;
    
    switch (difficulty) {
      case FlagQuizDifficulty.easy:
        currentCountries = easyCountries;
        break;
      case FlagQuizDifficulty.medium:
        currentCountries = [...easyCountries, ...mediumCountries];
        break;
      case FlagQuizDifficulty.hard:
        currentCountries = allCountries;
        break;
    }
    
    // Rastgele bir ülke seç
    final randomIndex = random.nextInt(currentCountries.length);
    final correctCountry = currentCountries[randomIndex];
    
    // 3 yanlış seçenek oluştur
    List<String> options = [correctCountry['name']!];
    
    while (options.length < 4) {
      final randomCountryIndex = random.nextInt(allCountries.length);
      final randomCountryName = allCountries[randomCountryIndex]['name']!;
      
      // Aynı ülkeyi tekrar ekleme
      if (!options.contains(randomCountryName)) {
        options.add(randomCountryName);
      }
    }
    
    // Seçenekleri karıştır
    options.shuffle();
    
    // Soruyu oluştur
    currentQuestion = FlagQuestion(
      countryCode: correctCountry['code']!,
      countryName: correctCountry['name']!,
      options: options,
    );
    
    update();
  }
  
  // Cevabı kontrol et
  void checkAnswer(String selectedAnswer) {
    if (!isGameRunning || currentQuestion == null) return;
    
    questionsAnswered++;
    
    if (selectedAnswer == currentQuestion!.countryName) {
      // Doğru cevap
      correctAnswers++;
      
      // Zorluk seviyesine göre puan ekle
      switch (difficulty) {
        case FlagQuizDifficulty.easy:
          score += 5;
          break;
        case FlagQuizDifficulty.medium:
          score += 10;
          break;
        case FlagQuizDifficulty.hard:
          score += 15;
          break;
      }
      
      // Doğru animasyonu göster
      showCorrectAnimation = true;
      update();
      
      Future.delayed(const Duration(milliseconds: 500), () {
        showCorrectAnimation = false;
        // Yeni soru oluştur
        generateNewQuestion();
      });
    } else {
      // Yanlış cevap
      // Yanlış animasyonu göster
      showWrongAnimation = true;
      update();
      
      Future.delayed(const Duration(milliseconds: 500), () {
        showWrongAnimation = false;
        // Yeni soru oluştur
        generateNewQuestion();
      });
    }
  }
  
  // Doğruluk oranını hesapla
  double getAccuracy() {
    if (questionsAnswered == 0) return 0;
    return (correctAnswers / questionsAnswered) * 100;
  }
  
  // Bayrak asset path'ini oluştur
  String getFlagAssetPath(String countryCode) {
    return 'assets/flags/${countryCode.toLowerCase()}.png';
  }
} 