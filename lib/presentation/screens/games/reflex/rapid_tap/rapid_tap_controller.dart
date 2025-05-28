import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import 'target_model.dart';

class RapidTapController extends GetxController {
  // Oyun durumu
  final RxBool isPlaying = false.obs;
  final RxBool isPaused = false.obs;
  final RxBool gameEnded = false.obs;
  
  // Skor ve süre
  final RxInt score = 0.obs;
  final RxInt highScore = 0.obs;
  final RxInt remainingTime = 60.obs; // 60 saniye oyun süresi
  
  // Hedefler
  final RxList<TargetModel> targets = <TargetModel>[].obs;
  
  // Zamanlayıcılar
  Timer? gameTimer;
  Timer? targetSpawnTimer;
  
  // Rastgele sayı üreteci
  final random = Random();
  
  // Depolama servisi
  final StorageService storageService = Get.find<StorageService>();
  
  // Oyun alanı boyutları
  double gameWidth = 0;
  double gameHeight = 0;
  
  // Hedef oluşturma hızları (milisaniye)
  int minSpawnInterval = 800;
  int maxSpawnInterval = 1500;
  
  @override
  void onInit() {
    super.onInit();
    // En yüksek skoru yükle
    _loadHighScore();
    
    // Ekran boyutlarını al (varsayılan değerler)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(Get.context!).size;
      gameWidth = size.width;
      gameHeight = size.height - 160; // Üst panel için alan bırak
    });
  }
  
  void _loadHighScore() {
    highScore.value = storageService.getInt('rapid_tap_high_score', defaultValue: 0);
  }
  
  void _saveHighScore() {
    if (score.value > highScore.value) {
      highScore.value = score.value;
      storageService.setInt('rapid_tap_high_score', score.value);
    }
  }
  
  void startGame() {
    if (isPlaying.value) return;
    
    isPlaying.value = true;
    isPaused.value = false;
    gameEnded.value = false;
    
    // Oyun zamanını başlat
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        endGame();
      }
    });
    
    // Hedef oluşturmayı başlat
    _scheduleNextTarget();
  }
  
  void _scheduleNextTarget() {
    // Oyun bitmiş veya duraklatılmışsa hedef oluşturma
    if (!isPlaying.value || isPaused.value || gameEnded.value) return;
    
    // Rastgele bir süre sonra yeni hedef oluştur
    final spawnDelay = minSpawnInterval + random.nextInt(maxSpawnInterval - minSpawnInterval);
    targetSpawnTimer = Timer(Duration(milliseconds: spawnDelay), () {
      spawnTarget();
      _scheduleNextTarget();
    });
  }
  
  void spawnTarget() {
    if (!isPlaying.value || isPaused.value || gameEnded.value) return;
    
    // Hedef boyutu (30 - 80 piksel arası)
    final size = 30.0 + random.nextInt(50);
    
    // Hedef konumu (ekran sınırları içinde)
    final x = random.nextDouble() * (gameWidth - size);
    final y = random.nextDouble() * (gameHeight - size);
    
    // Hedef puanı (daha küçük hedefler daha fazla puan)
    int points;
    if (size < 40) {
      points = 5; // Çok küçük
    } else if (size < 50) {
      points = 3; // Küçük
    } else if (size < 60) {
      points = 2; // Orta
    } else {
      points = 1; // Büyük
    }
    
    // Görünme süresi (2-4 saniye arası)
    final lifespan = 2000 + random.nextInt(2000);
    
    // Hedefi oluştur
    final target = TargetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      x: x,
      y: y,
      size: size,
      points: points,
      createdAt: DateTime.now(),
    );
    
    // Hedefi listeye ekle
    targets.add(target);
    
    // Belirlenen süre sonra otomatik olarak hedefi yok et
    Timer(Duration(milliseconds: lifespan), () {
      if (targets.contains(target)) {
        targets.remove(target);
        
        // Eğer hedef vurulmadıysa puan kaybı
        if (isPlaying.value && !isPaused.value && !gameEnded.value) {
          score.value = max(0, score.value - 1);
        }
      }
    });
  }
  
  void hitTarget(TargetModel target) {
    if (!isPlaying.value || isPaused.value || gameEnded.value) return;
    
    // Eğer hedef hala aktifse
    if (targets.contains(target)) {
      // Puanı ekle
      score.value += target.points;
      
      // Hedefi kaldır
      targets.remove(target);
      
      // Oyun hızını artır (daha zorlayıcı hale getir)
      if (score.value > 50 && minSpawnInterval > 500) {
        minSpawnInterval = 500;
        maxSpawnInterval = 1000;
      } else if (score.value > 100 && minSpawnInterval > 300) {
        minSpawnInterval = 300;
        maxSpawnInterval = 700;
      }
    }
  }
  
  void pauseGame() {
    if (!isPlaying.value || gameEnded.value) return;
    
    isPlaying.value = false;
    isPaused.value = true;
    
    // Zamanlayıcıları durdur
    gameTimer?.cancel();
    targetSpawnTimer?.cancel();
  }
  
  void resumeGame() {
    if (!isPaused.value || gameEnded.value) return;
    
    isPlaying.value = true;
    isPaused.value = false;
    
    // Zamanlayıcıları yeniden başlat
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        endGame();
      }
    });
    
    // Hedef oluşturmayı yeniden başlat
    _scheduleNextTarget();
  }
  
  void endGame() {
    isPlaying.value = false;
    gameEnded.value = true;
    
    // Zamanlayıcıları temizle
    gameTimer?.cancel();
    targetSpawnTimer?.cancel();
    
    // Tüm hedefleri temizle
    targets.clear();
    
    // Yüksek skoru kaydet
    _saveHighScore();
  }
  
  void resetGame() {
    // Oyunu sıfırla
    score.value = 0;
    remainingTime.value = 60;
    targets.clear();
    gameEnded.value = false;
    isPaused.value = false;
    
    // Hedef oluşturma hızını sıfırla
    minSpawnInterval = 800;
    maxSpawnInterval = 1500;
    
    // Yüksek skoru yükle (eğer gerekiyorsa)
    _loadHighScore();
  }
  
  @override
  void onClose() {
    // Zamanlayıcıları temizle
    gameTimer?.cancel();
    targetSpawnTimer?.cancel();
    super.onClose();
  }
} 