import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import '../../../../../infrastructure/services/audio/audio_service.dart';

class ReactionTestController extends GetxController {
  // Servisleri tanımla
  final StorageService storageService = Get.find<StorageService>();
  final AudioService audioService = Get.find<AudioService>();
  
  // Oyun durumu
  final RxBool isPlaying = false.obs;
  final RxBool isWaiting = false.obs;
  final RxBool isTooEarly = false.obs;
  final RxBool isReady = false.obs;
  final RxBool showResult = false.obs;
  
  // Zamanlayıcılar
  Timer? waitTimer;
  Timer? resultTimer;
  Timer? tooEarlyTimer;
  
  // Ölçümler
  final RxInt currentReactionTime = 0.obs;
  final RxInt bestReactionTime = 9999.obs;
  final RxInt averageReactionTime = 0.obs;
  final RxList<int> reactionTimes = <int>[].obs;
  
  // Zamanlama değişkenleri
  final random = Random();
  DateTime? greenLightTime;
  DateTime? tapTime;
  
  // Oyun renkleri
  final Rx<Color> backgroundColor = Colors.red.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBestTime();
  }
  
  // En iyi reaksiyon süresini yükle
  void _loadBestTime() {
    bestReactionTime.value = storageService.getInt('reaction_test_best_time', defaultValue: 9999);
  }
  
  // En iyi reaksiyon süresini kaydet
  void _saveBestTime() {
    if (currentReactionTime.value < bestReactionTime.value) {
      bestReactionTime.value = currentReactionTime.value;
      storageService.setInt('reaction_test_best_time', currentReactionTime.value);
    }
  }
  
  // Oyunu başlat
  void startGame() {
    if (isPlaying.value) return;
    
    // Durumu sıfırla
    isPlaying.value = true;
    isWaiting.value = true;
    isTooEarly.value = false;
    isReady.value = false;
    showResult.value = false;
    backgroundColor.value = Colors.red;
    
    // Rastgele 2-5 saniye sonra yeşil ışık göster
    final waitTime = 2000 + random.nextInt(3000);
    waitTimer = Timer(Duration(milliseconds: waitTime), () {
      if (!isPlaying.value) return;
      
      // Yeşil ışık
      isWaiting.value = false;
      isReady.value = true;
      backgroundColor.value = Colors.green;
      greenLightTime = DateTime.now();
      
      // Ses çal (ses servisi eklendiğinde aktifleştirilecek)
      // audioService.playSound('sounds/go.mp3');
    });
  }
  
  // Ekrana dokunma işlemi
  void onTap() {
    // Oyun başlamadıysa, başlat
    if (!isPlaying.value) {
      startGame();
      return;
    }
    
    // Erken tıklama
    if (isWaiting.value) {
      _handleEarlyTap();
      return;
    }
    
    // Yeşil ışık görününce tıklama
    if (isReady.value) {
      _handleCorrectTap();
      return;
    }
    
    // Diğer durumlarda oyunu yeniden başlat
    if (showResult.value || isTooEarly.value) {
      resetGame();
      startGame();
    }
  }
  
  // Erken tıklama durumu
  void _handleEarlyTap() {
    // Zamanlayıcıları temizle
    waitTimer?.cancel();
    
    // Erken tıklama durumunu göster
    isPlaying.value = false;
    isWaiting.value = false;
    isTooEarly.value = true;
    backgroundColor.value = Colors.orange;
    
    // Ses çal (ses servisi eklendiğinde aktifleştirilecek)
    // audioService.playSound('sounds/wrong.mp3');
    
    // 2 saniye sonra tekrar hazır ol
    tooEarlyTimer = Timer(const Duration(seconds: 2), () {
      isTooEarly.value = false;
      isPlaying.value = false;
    });
  }
  
  // Doğru tıklama durumu
  void _handleCorrectTap() {
    // Zamanı kaydet
    tapTime = DateTime.now();
    
    // Reaksiyon süresini hesapla (milisaniye cinsinden)
    final reactionTime = tapTime!.difference(greenLightTime!).inMilliseconds;
    currentReactionTime.value = reactionTime;
    
    // Sonuçları kaydet
    reactionTimes.add(reactionTime);
    _saveBestTime(); // En iyi süreyi kaydet
    
    // Ortalama hesapla
    if (reactionTimes.isNotEmpty) {
      int sum = 0;
      for (var time in reactionTimes) {
        sum += time;
      }
      averageReactionTime.value = sum ~/ reactionTimes.length;
    }
    
    // Durumu güncelle
    isReady.value = false;
    showResult.value = true;
    isPlaying.value = false;
    backgroundColor.value = Colors.blue;
    
    // Ses çal (ses servisi eklendiğinde aktifleştirilecek)
    // audioService.playSound('sounds/success.mp3');
  }
  
  // Oyunu sıfırla
  void resetGame() {
    waitTimer?.cancel();
    resultTimer?.cancel();
    tooEarlyTimer?.cancel();
    
    isPlaying.value = false;
    isWaiting.value = false;
    isTooEarly.value = false;
    isReady.value = false;
    showResult.value = false;
    
    backgroundColor.value = Colors.grey[200]!;
  }
  
  @override
  void onClose() {
    waitTimer?.cancel();
    resultTimer?.cancel();
    tooEarlyTimer?.cancel();
    super.onClose();
  }
} 