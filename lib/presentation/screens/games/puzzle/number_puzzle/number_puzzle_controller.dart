import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import '../../../../../infrastructure/services/audio/audio_service.dart';
import 'number_puzzle_model.dart';
import 'number_puzzle_screen.dart';

class NumberPuzzleController extends GetxController {
  // Servisler
  final StorageService _storage = Get.find<StorageService>();
  final AudioService _audioService = Get.find<AudioService>();
  
  // Oyun modeli
  late Rx<NumberPuzzleModel> gameModel;
  
  // Yüksek skor
  final RxInt highScore = 0.obs;
  
  // Oyun durumu
  final RxBool isGameOver = false.obs;
  final RxBool hasWon = false.obs;
  final RxBool continueAfterWin = false.obs;
  
  // Animasyon kontrolü için
  final RxBool isAnimating = false.obs;
  
  // Hücre renkleri
  final Map<int, Color> tileColors = {
    0: Colors.grey.shade200,
    2: Colors.amber.shade100,
    4: Colors.amber.shade200,
    8: Colors.orange.shade300,
    16: Colors.orange.shade400,
    32: Colors.deepOrange.shade300,
    64: Colors.deepOrange.shade400,
    128: Colors.red.shade300,
    256: Colors.red.shade400,
    512: Colors.pink.shade300,
    1024: Colors.pink.shade400,
    2048: Colors.purple.shade400,
    4096: Colors.purple.shade500,
    8192: Colors.blue.shade500,
  };

  @override
  void onInit() {
    super.onInit();
    
    // Yüksek skoru al
    highScore.value = _storage.getInt('profile_highscore_number_puzzle', defaultValue: 0);
    
    // Oyun modelini oluştur
    gameModel = NumberPuzzleModel(
      highScore: highScore.value,
    ).obs;
    
    // Oyun tahtasını başlat
    resetGame();
    
    // Oyun durumu değişimlerini dinle
    ever(isGameOver, _handleGameOver);
    ever(hasWon, _handleGameWin);
  }
  
  // Oyunu yeniden başlat
  void resetGame() {
    gameModel.value.resetBoard();
    isGameOver.value = false;
    hasWon.value = false;
    continueAfterWin.value = false;
    update();
  }
  
  // Yön tuşlarıyla oyunu kontrol et
  void handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (isAnimating.value || isGameOver.value || (hasWon.value && !continueAfterWin.value)) {
        return;
      }
      
      bool moved = false;
      
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        moved = _move(0); // Sol
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        moved = _move(1); // Sağ
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        moved = _move(2); // Yukarı
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        moved = _move(3); // Aşağı
      }
      
      if (moved) {
        _checkGameState();
      }
    }
  }
  
  // Kaydırma hareketiyle yön belirleme
  void handleSwipe(DragEndDetails details) {
    if (isAnimating.value || isGameOver.value || (hasWon.value && !continueAfterWin.value)) {
      return;
    }
    
    bool moved = false;
    
    // Hız vektörünün x ve y bileşenleri
    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;
    
    // Yatay hareket yataydan daha güçlüyse
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        moved = _move(1); // Sağ
      } else {
        moved = _move(0); // Sol
      }
    } else {
      if (dy > 0) {
        moved = _move(3); // Aşağı
      } else {
        moved = _move(2); // Yukarı
      }
    }
    
    if (moved) {
      _checkGameState();
    }
  }
  
  // Hamle yap
  bool _move(int direction) {
    isAnimating.value = true;
    
    final moved = gameModel.value.move(direction);
    
    if (moved) {
      _audioService.playSfx('tile_move');
    }
    
    // Kısa bir gecikmeyle animasyon durumunu güncelle
    Future.delayed(const Duration(milliseconds: 150), () {
      isAnimating.value = false;
      update();
    });
    
    return moved;
  }
  
  // Oyun durumunu kontrol et
  void _checkGameState() {
    final model = gameModel.value;
    
    // Oyun kazanıldı mı?
    if (model.hasWon && !hasWon.value) {
      hasWon.value = true;
      _audioService.playSfx('win');
      _saveScore();
    }
    
    // Oyun bitti mi?
    if (model.isGameOver && !isGameOver.value) {
      isGameOver.value = true;
      _audioService.playSfx('game_over');
      _saveScore();
    }
  }
  
  // Skoru kaydet
  void _saveScore() {
    final score = gameModel.value.score;
    
    // Profil ve skor tablosu için kaydet
    _storage.saveGameResult('number_puzzle', score);
    
    // Yüksek skoru güncelle ve kaydet
    if (score > highScore.value) {
      highScore.value = score;
      _storage.setInt('profile_highscore_number_puzzle', score);
      update(); // UI'ı güncelle
    }
  }
  
  // Oyuna devam et (2048'e ulaşıldıktan sonra)
  void continueGame() {
    continueAfterWin.value = true;
    Get.back(); // Diyalogu kapat
    update();
  }
  
  // Oyun bittiğinde çağrılır
  void _handleGameOver(bool gameOver) {
    if (gameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // Diyalogu göster
        Get.dialog(
          GameOverDialog(
            isWin: false,
            score: gameModel.value.score,
            onRestart: () {
              Get.back(); // Diyalogu kapat
              resetGame();
            },
          ),
          barrierDismissible: false,
        );
      });
    }
  }
  
  // Oyun kazanıldığında çağrılır
  void _handleGameWin(bool win) {
    if (win && !continueAfterWin.value) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // Diyalogu göster
        Get.dialog(
          GameOverDialog(
            isWin: true,
            score: gameModel.value.score,
            onRestart: () {
              Get.back(); // Diyalogu kapat
              resetGame();
            },
            onContinue: continueGame,
          ),
          barrierDismissible: false,
        );
      });
    }
  }
  
  // Hücre rengi
  Color getTileColor(int value) {
    return tileColors[value] ?? Colors.purple.shade700;
  }
  
  // Hücre yazı boyutu
  double getTileFontSize(int value) {
    if (value < 100) return 32;
    if (value < 1000) return 28;
    if (value < 10000) return 24;
    return 18;
  }
} 