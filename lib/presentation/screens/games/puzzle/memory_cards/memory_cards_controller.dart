import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import 'memory_cards_model.dart';

class MemoryCardsController extends GetxController {
  // Servisler
  final StorageService _storage = Get.find<StorageService>();
  
  // Oyun modeli
  final gameModel = MemoryCardsModel().obs;
  
  // Zorluk seviyesi
  final RxInt difficulty = 1.obs;
  
  // Oyun durumu
  final RxBool isGameOver = false.obs;
  
  // Timer (bekleme süresi için)
  Timer? _flipTimer;
  
  @override
  void onInit() {
    super.onInit();
    _loadHighScore();
    startNewGame();
  }
  
  @override
  void onClose() {
    _flipTimer?.cancel();
    super.onClose();
  }
  
  void _loadHighScore() {
    final highScore = _storage.getInt('memory_cards_high_score', defaultValue: 0);
    gameModel.value = gameModel.value.copyWith(highScore: highScore);
  }
  
  void _saveHighScore() {
    if (gameModel.value.score > gameModel.value.highScore) {
      _storage.setInt('memory_cards_high_score', gameModel.value.score);
      gameModel.value = gameModel.value.copyWith(highScore: gameModel.value.score);
    }
  }
  
  void setDifficulty(int newDifficulty) {
    difficulty.value = newDifficulty;
    startNewGame();
  }
  
  void startNewGame() {
    gameModel.value = MemoryCardsModel(
      difficulty: difficulty.value,
      highScore: gameModel.value.highScore,
    );
    gameModel.value.initializeGame();
    isGameOver.value = false;
    update();
  }
  
  void onCardTap(int index) {
    if (isGameOver.value) return;
    
    final success = gameModel.value.selectCard(index);
    if (success) {
      update();
      
      // İki kart seçildiyse kontrol et
      if (gameModel.value.selectedCardIndices.length == 2) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!gameModel.value.checkForMatch()) {
            gameModel.value.resetSelectedCards();
          }
          update();
          
          // Oyun bitti mi kontrol et
          if (gameModel.value.matchedPairs >= gameModel.value.totalPairs) {
            isGameOver.value = true;
            _saveHighScore();
          }
        });
      }
    }
  }
  
  // Kartın rengini al
  Color getCardColor(int index) {
    if (gameModel.value.cards[index].isMatched) {
      return Colors.green.withOpacity(0.3);
    }
    return gameModel.value.cards[index].isFlipped 
        ? Colors.white 
        : Colors.blue;
  }
  
  // Kartın sembolünü al
  String getCardSymbol(int index) {
    return gameModel.value.cards[index].symbol;
  }
  
  // Kartların sayısını al
  int getCardCount() {
    return gameModel.value.cards.length;
  }
  
  // Hamle sayısını al
  int getMoveCount() {
    return gameModel.value.moves;
  }
  
  // Toplam çift sayısını al
  int getTotalPairs() {
    return gameModel.value.totalPairs;
  }
  
  // Bulunan çift sayısını al
  int getMatchedPairs() {
    return gameModel.value.matchedPairs;
  }
  
  // Kartın ön yüzünü gösterme kontrolü
  bool shouldShowCardFront(int index) {
    return gameModel.value.cards[index].isFlipped ||
           gameModel.value.cards[index].isMatched;
  }
}