import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import '../../../../../infrastructure/services/audio/audio_service.dart';
import 'word_hunt_model.dart';

class WordHuntController extends GetxController {
  // Servisler
  final StorageService _storage = Get.find<StorageService>();
  final AudioService _audioService = Get.find<AudioService>();
  
  // Oyun modeli
  late Rx<WordHuntModel> gameModel;
  
  // Yüksek skor
  final RxInt highScore = 0.obs;
  
  // Oyun durumu
  final RxBool isGameOver = false.obs;
  final RxBool isGameWon = false.obs;
  
  // Kalan süre
  final RxInt remainingTime = 0.obs;
  
  // Seçilen harfler
  final RxList<List<int>> selectedCells = <List<int>>[].obs;
  final RxString currentWord = ''.obs;
  
  // Zorluk seviyesi
  final RxInt difficulty = 1.obs;
  
  // Zamanlayıcı
  Timer? _timer;
  
  // Hücre renkleri
  final Map<String, Color> cellColors = {
    'default': Colors.white,
    'selected': Colors.blue.shade200,
    'found': Colors.green.shade200,
  };

  @override
  void onInit() {
    super.onInit();
    
    // Yüksek skoru al
    highScore.value = _storage.getInt('profile_highscore_word_hunt', defaultValue: 0);
    
    // Oyun modelini oluştur
    gameModel = WordHuntModel(
      highScore: highScore.value,
      difficulty: difficulty.value,
    ).obs;
    
    // Oyun tahtasını başlat
    resetGame();
    
    // Oyun durumu değişimlerini dinle
    ever(isGameOver, _handleGameOver);
    ever(isGameWon, _handleGameWin);
  }
  
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
  
  // Oyunu yeniden başlat
  void resetGame() {
    // Zamanlayıcıyı durdur
    _timer?.cancel();
    
    // Oyun modelini sıfırla
    gameModel.value.resetGame();
    
    // Reaktif değişkenleri güncelle
    isGameOver.value = false;
    isGameWon.value = false;
    remainingTime.value = gameModel.value.remainingTime;
    selectedCells.clear();
    currentWord.value = '';
    
    // Zamanlayıcıyı başlat
    _startTimer();
    
    // UI'ı güncelle
    update();
  }
  
  // Zamanlayıcıyı başlat
  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (gameModel.value.decrementTime()) {
          remainingTime.value = gameModel.value.remainingTime;
          
          if (gameModel.value.isGameOver) {
            isGameOver.value = true;
            timer.cancel();
          }
        } else {
          timer.cancel();
        }
      },
    );
  }
  
  // Hücre seçimi
  void selectCell(int row, int col) {
    if (isGameOver.value || isGameWon.value) return;
    
    final cell = [row, col];
    
    // Hücre zaten seçiliyse veya bitişik değilse işlem yapma
    if (selectedCells.contains(cell) || !_isAdjacentToLastSelectedCell(row, col)) {
      return;
    }
    
    // Hücreyi seçilenlere ekle
    selectedCells.add(cell);
    
    // Kelimeyi güncelle
    currentWord.value = _buildWordFromSelectedCells();
    
    // Ses efekti çal
    _audioService.playSfx('cell_select');
    
    update();
  }
  
  // Son seçilen hücreye bitişik mi
  bool _isAdjacentToLastSelectedCell(int row, int col) {
    if (selectedCells.isEmpty) return true;
    
    final lastCell = selectedCells.last;
    final lastRow = lastCell[0];
    final lastCol = lastCell[1];
    
    // Dikey, yatay veya çapraz komşuluk kontrolü
    return (row - lastRow).abs() <= 1 && (col - lastCol).abs() <= 1;
  }
  
  // Seçilen hücrelerden kelime oluştur
  String _buildWordFromSelectedCells() {
    String word = '';
    
    for (final cell in selectedCells) {
      final row = cell[0];
      final col = cell[1];
      word += gameModel.value.grid[row][col];
    }
    
    return word;
  }
  
  // Kelime gönderimi
  void submitWord() {
    if (currentWord.value.length < 3 || isGameOver.value) {
      // 3 harften kısa kelimeler geçersiz
      clearSelection();
      return;
    }
    
    final wordFound = gameModel.value.findWord(currentWord.value);
    
    if (wordFound) {
      // Kelime bulundu
      _audioService.playSfx('word_found');
      
      // Oyun kazanıldı kontrolü
      if (gameModel.value.isGameWon) {
        isGameWon.value = true;
      }
    } else {
      // Geçersiz kelime
      _audioService.playSfx('word_invalid');
    }
    
    // Seçimi temizle
    clearSelection();
    
    update();
  }
  
  // Seçimi temizle
  void clearSelection() {
    selectedCells.clear();
    currentWord.value = '';
    update();
  }
  
  // Zorluk seviyesini değiştir
  void setDifficulty(int newDifficulty) {
    difficulty.value = newDifficulty;
    resetGame();
  }
  
  // Oyun bittiğinde çağrılır
  void _handleGameOver(bool gameOver) {
    if (gameOver && !isGameWon.value) {
      _audioService.playSfx('game_over');
      _saveScore();
    }
  }
  
  // Oyun kazanıldığında çağrılır
  void _handleGameWin(bool win) {
    if (win) {
      _audioService.playSfx('win');
      _saveScore();
    }
  }
  
  // Skoru kaydet
  void _saveScore() {
    final score = gameModel.value.score;
    
    // Profil ve skor tablosu için kaydet
    _storage.saveGameResult('word_hunt', score);
    
    // Yüksek skoru güncelle
    if (score > highScore.value) {
      highScore.value = score;
      _storage.setInt('profile_highscore_word_hunt', score);
    }
  }
  
  // Hücre arkaplan rengi
  Color getCellBackgroundColor(int row, int col) {
    final cell = [row, col];
    
    // Seçiliyse mavi
    if (selectedCells.contains(cell)) {
      return cellColors['selected']!;
    }
    
    // Standart hücre rengi
    return cellColors['default']!;
  }
  
  // Harf yazı rengi
  Color getCellTextColor(int row, int col) {
    return Colors.black87;
  }
  
  // Bulunan kelimeler listesini al
  List<String> getFoundWordsList() {
    return gameModel.value.foundWords;
  }
  
  // Gizli kelimeler listesini al (ipucu için)
  List<String> getHiddenWords() {
    return gameModel.value.hiddenWords;
  }
  
  // Kalan kelimelerin sayısını al
  int getRemainingWordsCount() {
    return gameModel.value.hiddenWords.length - gameModel.value.foundWords.length;
  }
  
  // İpucu gösterme (bir kelimeyi işaretle)
  void showHint() {
    if (isGameOver.value || isGameWon.value || gameModel.value.score < 50) return;
    
    // Henüz bulunmamış kelimeler
    final remainingWords = gameModel.value.hiddenWords
        .where((word) => !gameModel.value.foundWords.contains(word))
        .toList();
    
    if (remainingWords.isEmpty) return;
    
    // Rastgele bir kelime seç
    final randomWord = remainingWords[gameModel.value.foundWords.hashCode % remainingWords.length];
    
    // İpucu için puan düş
    gameModel.value.score -= 50;
    
    // İpucu gösterme işlemleri burada olacak
    // Gerçek oyun mantığında, seçilen kelimenin birkaç harfini gösterme
    // veya pozisyonunu grid üzerinde vurgulama gibi işlemler yapılabilir
    
    _audioService.playSfx('hint');
    
    update();
  }
} 