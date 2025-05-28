import 'package:get/get.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import '../../../../../infrastructure/services/ad/ad_service.dart';

// Zorluk seviyesi
enum MathDifficulty {
  easy,
  medium,
  hard
}

// İşlem türleri
enum OperationType {
  addition,
  subtraction,
  multiplication,
  division,
  mixed
}

// Matematik problemi modeli
class MathProblem {
  final String question;
  final int correctAnswer;
  final List<int> options;

  MathProblem({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}

class MathRaceController extends GetxController {
  // Mevcut problem
  MathProblem? currentProblem;
  
  // Oyun süresi
  int timeLeft = 60; // saniye
  Timer? gameTimer;
  
  // Oyun ayarları
  MathDifficulty difficulty = MathDifficulty.medium;
  OperationType operationType = OperationType.mixed;
  
  // Oyun durumu
  bool isGameRunning = false;
  bool isGameOver = false;
  
  // Random nesnesi
  final Random random = Random();
  
  // Animasyon durumu
  bool showCorrectAnimation = false;
  bool showWrongAnimation = false;
  
  // Oyun durumu
  final RxBool isPlaying = false.obs;
  final RxBool gameOver = false.obs;
  final RxBool isPaused = false.obs;
  
  // Skor ve seviye
  final RxInt score = 0.obs;
  final RxInt highScore = 0.obs;
  final RxInt level = 1.obs;
  final RxInt remainingTime = 60.obs; // 60 saniye oyun süresi
  final RxInt questionsAnswered = 0.obs;
  final RxInt correctAnswers = 0.obs;
  
  // Mevcut problem
  final RxString question = ''.obs;
  final RxInt answer = 0.obs;
  final RxList<int> options = <int>[].obs;
  
  // UI animasyonları
  final RxDouble carPosition = 0.1.obs;
  final RxDouble obstaclePosition = 1.0.obs;
  
  // İpucu
  final RxBool showingHint = false.obs;
  final RxInt hintCount = 0.obs;
  final RxInt correctOptionIndex = (-1).obs;
  
  // Servisler
  final StorageService _storage = Get.find<StorageService>();
  late final AdService adService;
  
  @override
  void onInit() {
    super.onInit();
    // Yüksek skoru yükle
    loadHighScore();
    // Reklam servisini bul
    adService = Get.find<AdService>();
  }
  
  @override
  void onClose() {
    gameTimer?.cancel();
    super.onClose();
  }
  
  // Yüksek skoru yükle
  void loadHighScore() async {
    highScore.value = _storage.getInt('math_race_high_score', defaultValue: 0);
    update();
  }
  
  // Oyunu başlat
  void startGame() {
    if (isPlaying.value) return;
    
    score.value = 0;
    level.value = 1;
    remainingTime.value = 60;
    questionsAnswered.value = 0;
    correctAnswers.value = 0;
    isPlaying.value = true;
    gameOver.value = false;
    isPaused.value = false;
    
    // İlk problemi oluştur
    generateProblem();
    
    // Zamanlayıcıları başlat
    startTimers();
  }
  
  // Zamanlayıcıları başlat
  void startTimers() {
    // Süre zamanlayıcısı
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused.value) return;
      
      remainingTime.value--;
      
      if (remainingTime.value <= 0) {
        endGame();
      }
    });
    
    // Engel zamanlayıcısı (araba animasyonu için)
    _startObstacleAnimation();
  }
  
  // Engel animasyonunu başlat
  void _startObstacleAnimation() {
    gameTimer?.cancel();
    
    // Engelin başlangıç konumu
    obstaclePosition.value = 1.0;
    
    // Zorluk seviyesine göre hız ayarla
    final speed = switch (difficulty) {
      MathDifficulty.easy => const Duration(milliseconds: 5000),
      MathDifficulty.medium => const Duration(milliseconds: 4000),
      MathDifficulty.hard => const Duration(milliseconds: 3000),
    };
    
    Timer.periodic(speed, (timer) {
      if (isPaused.value) return;
      
      // Engeli hareket ettir
      obstaclePosition.value -= 0.01;
      
      // Engel arabaya çarptı mı?
      if (obstaclePosition.value <= carPosition.value + 0.1 && 
          obstaclePosition.value >= carPosition.value - 0.1) {
        // Çarpışma kontrolü
        // Eğer doğru cevap verilmediyse, oyun biter
        if (correctOptionIndex.value != -1) {
          // Çarpışma oldu ve oyuncu doğru cevabı vermedi
          endGame();
        }
      }
      
      // Engel ekrandan çıktı mı?
      if (obstaclePosition.value < -0.2) {
        timer.cancel();
        
        // Yeni engel oluştur
        Future.delayed(const Duration(milliseconds: 500), () {
          if (isPlaying.value && !gameOver.value) {
            generateProblem();
            _startObstacleAnimation();
          }
        });
      }
    });
  }
  
  // Oyunu duraklat
  void pauseGame() {
    if (!isPlaying.value || gameOver.value) return;
    
    isPaused.value = true;
  }
  
  // Oyunu devam ettir
  void resumeGame() {
    if (!isPlaying.value || gameOver.value) return;
    
    isPaused.value = false;
  }
  
  // Oyunu sonlandır
  void endGame() {
    isPlaying.value = false;
    gameOver.value = true;
    
    gameTimer?.cancel();
    
    // Yüksek skor kontrolü
    if (score.value > highScore.value) {
      highScore.value = score.value;
      _storage.setInt('math_race_high_score', score.value);
    }
  }
  
  // Zorluk seviyesini değiştir
  void setDifficulty(MathDifficulty newDifficulty) {
    if (!isPlaying.value) {
      difficulty = newDifficulty;
      update();
    }
  }
  
  // İşlem türünü değiştir
  void setOperationType(OperationType newType) {
    if (!isPlaying.value) {
      operationType = newType;
      update();
    }
  }
  
  // Yeni matematik problemi oluştur
  void generateProblem() {
    final operators = ['+', '-', '*'];
    String operator;
    int num1, num2;
    
    // Zorluğa göre sayıları ayarla
    switch (difficulty) {
      case MathDifficulty.easy:
        num1 = random.nextInt(10) + 1; // 1-10
        num2 = random.nextInt(10) + 1; // 1-10
        operator = operators[random.nextInt(2)]; // Sadece + ve -
        break;
        
      case MathDifficulty.medium:
        num1 = random.nextInt(20) + 1; // 1-20
        num2 = random.nextInt(15) + 1; // 1-15
        operator = operators[random.nextInt(3)]; // +, - ve *
        break;
        
      case MathDifficulty.hard:
        num1 = random.nextInt(30) + 1; // 1-30
        num2 = random.nextInt(20) + 1; // 1-20
        operator = operators[random.nextInt(3)]; // +, - ve *
        
        // Çarpma için daha küçük sayılar
        if (operator == '*') {
          num1 = random.nextInt(12) + 1; // 1-12
          num2 = random.nextInt(10) + 1; // 1-10
        }
        break;
        
      default:
        num1 = random.nextInt(10) + 1;
        num2 = random.nextInt(10) + 1;
        operator = '+';
    }
    
    // Çıkarma işleminde ilk sayının büyük olmasını sağla
    if (operator == '-' && num1 < num2) {
      final temp = num1;
      num1 = num2;
      num2 = temp;
    }
    
    // Soruyu oluştur
    question.value = '$num1 $operator $num2 = ?';
    
    // Cevabı hesapla
    switch (operator) {
      case '+':
        answer.value = num1 + num2;
        break;
      case '-':
        answer.value = num1 - num2;
        break;
      case '*':
        answer.value = num1 * num2;
        break;
    }
    
    // Seçenekleri oluştur
    generateOptions();
    
    // İpucu göstergesini sıfırla
    correctOptionIndex.value = -1;
  }
  
  // Cevap seçeneklerini oluştur
  void generateOptions() {
    List<int> opts = [answer.value];
    
    // Doğru cevap civarında yanlış cevaplar oluştur
    while (opts.length < 4) {
      int offset = random.nextInt(10) + 1; // 1-10 arası fark
      
      // Pozitif veya negatif offset
      if (random.nextBool()) {
        offset = -offset;
      }
      
      final newOption = answer.value + offset;
      
      // Opsiyonun benzersiz ve pozitif olduğundan emin ol
      if (!opts.contains(newOption) && newOption > 0) {
        opts.add(newOption);
      }
    }
    
    // Seçenekleri karıştır
    opts.shuffle();
    options.value = opts;
  }
  
  // Seçeneğe tıklandığında
  void selectOption(int index) {
    if (!isPlaying.value || gameOver.value || isPaused.value) return;
    
    final selectedAnswer = options[index];
    
    // Her cevap için soru sayacını artır
    questionsAnswered.value++;
    
    if (selectedAnswer == answer.value) {
      // Doğru cevap
      correctAnswers.value++;
      score.value += level.value * 10;
      carPosition.value += 0.1;
      
      // Arabanın sınırlar içinde kalmasını sağla
      if (carPosition.value > 0.8) {
        carPosition.value = 0.8;
      }
      
      // Her 100 puanda seviye atla
      if (score.value >= level.value * 100) {
        level.value++;
        
        // Ek süre ver
        remainingTime.value += 10;
      }
    } else {
      // Yanlış cevap
      carPosition.value -= 0.1;
      
      // Arabanın sınırlar içinde kalmasını sağla
      if (carPosition.value < 0.1) {
        carPosition.value = 0.1;
      }
    }
    
    // Yeni problem oluştur
    generateProblem();
  }
  
  // İpucu iste
  void requestHint() {
    if (!isPlaying.value || gameOver.value || isPaused.value || correctOptionIndex.value >= 0) return;
    
    if (hintCount.value <= 0) {
      // İpucu hakkı yoksa reklam izlemeyi teklif et
      Get.dialog(
        AlertDialog(
          title: const Text('İpucu Yok'),
          content: const Text('İpucu kullanmak için reklam izlemek ister misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                showHintAdvert();
              },
              child: const Text('Reklam İzle'),
            ),
          ],
        ),
      );
      return;
    }
    
    // İpucu hakkını kullan
    hintCount.value--;
    
    // Doğru cevabı göster
    for (int i = 0; i < options.length; i++) {
      if (options[i] == answer.value) {
        correctOptionIndex.value = i;
        break;
      }
    }
    
    showingHint.value = true;
    update();
    
    // 3 saniye sonra ipucunu gizle
    Future.delayed(Duration(seconds: 3), () {
      showingHint.value = false;
      update();
    });
  }
  
  // Rewarded reklam gösterme
  void showHintAdvert() {
    if (adService.isRewardedAdReady.value) {
      adService.showRewardedAd(onUserEarnedReward: () {
        // Reklam izlendikten sonra ipucu hakkı ver
        hintCount.value += 3;
        Get.snackbar(
          'Ödül Kazandın!',
          '3 ipucu hakkı kazandın',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      });
    } else {
      Get.snackbar(
        'Reklam Hazır Değil',
        'Lütfen daha sonra tekrar deneyin',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Doğruluk oranını hesapla
  double getAccuracy() {
    if (questionsAnswered.value == 0) return 0;
    return (correctAnswers.value / questionsAnswered.value) * 100;
  }
} 