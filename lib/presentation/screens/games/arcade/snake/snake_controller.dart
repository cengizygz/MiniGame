import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import '../../../../../infrastructure/services/audio/audio_service.dart';
import 'snake_model.dart';

class SnakeController extends GetxController {
  // Services
  final StorageService _storage = Get.find<StorageService>();
  final AudioService _audioService = Get.find<AudioService>();
  
  // Game model
  late Rx<SnakeModel> gameModel;
  
  // Game timer
  Timer? _gameTimer;
  
  // High score
  final RxInt highScore = 0.obs;
  
  // Difficulty level
  final RxInt difficulty = 1.obs;
  
  // Game state
  final RxBool isPaused = false.obs;
  final RxBool isGameOver = false.obs;
  
  // Colors
  final snakeHeadColor = Colors.green.shade700;
  final snakeBodyColor = Colors.green.shade500;
  final foodColor = Colors.red;
  final boardColor = Colors.grey.shade200;
  final gridLineColor = Colors.grey.shade300;
  
  @override
  void onInit() {
    super.onInit();
    
    // Get high score
    highScore.value = _storage.getInt('snake_high_score', defaultValue: 0);
    
    // Initialize game model
    gameModel = SnakeModel(
      highScore: highScore.value,
      difficulty: difficulty.value,
    ).obs;
    
    // Start new game
    startNewGame();
    
    // Listen to game over state changes
    ever(isGameOver, _handleGameOver);
  }
  
  @override
  void onClose() {
    _gameTimer?.cancel();
    super.onClose();
  }
  
  // Start a new game
  void startNewGame() {
    // Cancel existing timer
    _gameTimer?.cancel();
    
    // Initialize game model
    gameModel.value = SnakeModel(
      highScore: highScore.value,
      difficulty: difficulty.value,
    );
    
    // Initialize game
    gameModel.value.initializeGame();
    
    // Reset game state
    isGameOver.value = false;
    isPaused.value = false;
    
    // Start game timer
    _startGameTimer();
    
    // Play game start sound
    _playSound('game_start');
    
    update();
  }
  
  // Set difficulty level
  void setDifficulty(int level) {
    if (level < 1) level = 1;
    if (level > 3) level = 3;
    
    difficulty.value = level;
    startNewGame();
  }
  
  // Start game timer
  void _startGameTimer() {
    _gameTimer?.cancel();
    
    _gameTimer = Timer.periodic(
      gameModel.value.getGameSpeed(),
      (timer) {
        if (!isPaused.value && !isGameOver.value) {
          final didEatFood = gameModel.value.updateSnake();
          
          if (didEatFood) {
            // Play eat sound
            _playSound('eat');
            
            // Update timer speed based on new score
            _updateGameSpeed();
          }
          
          if (gameModel.value.isGameOver) {
            isGameOver.value = true;
          }
          
          update();
        }
      },
    );
  }
  
  // Update game speed
  void _updateGameSpeed() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      gameModel.value.getGameSpeed(),
      (timer) {
        if (!isPaused.value && !isGameOver.value) {
          final didEatFood = gameModel.value.updateSnake();
          
          if (didEatFood) {
            // Play eat sound
            _playSound('eat');
            
            // Update timer speed based on new score
            _updateGameSpeed();
          }
          
          if (gameModel.value.isGameOver) {
            isGameOver.value = true;
          }
          
          update();
        }
      },
    );
  }
  
  // Pause/resume game
  void togglePause() {
    isPaused.value = !isPaused.value;
    
    if (isPaused.value) {
      _playSound('pause');
    } else {
      _playSound('resume');
    }
    
    update();
  }
  
  // Change snake direction
  void changeDirection(Direction direction) {
    if (isPaused.value || isGameOver.value) return;
    
    gameModel.value.changeDirection(direction);
    update();
  }
  
  // Handle game over
  void _handleGameOver(bool isOver) {
    if (isOver) {
      _saveHighScore();
      _gameTimer?.cancel();
      _playSound('game_over');
    }
  }
  
  void _saveHighScore() {
    if (gameModel.value.score > highScore.value) {
      highScore.value = gameModel.value.score;
      _storage.setInt('snake_high_score', gameModel.value.score);
    }
  }
  
  // Helper to play sound with fallback to generic sounds
  void _playSound(String soundName) {
    try {
      // Try to play game-specific sound first
      _audioService.playSound('sounds/snake/$soundName.mp3');
    } catch (e) {
      // Fallback to generic sounds
      try {
        _audioService.playSound('sounds/$soundName.mp3');
      } catch (e) {
        // If both fail, just print debug message
        debugPrint('Could not play sound: $soundName');
      }
    }
  }
  
  // Cell colors for UI
  Color getCellColor(int x, int y) {
    if (gameModel.value.isSnakeHead(x, y)) {
      return snakeHeadColor;
    } else if (gameModel.value.isSnake(x, y)) {
      return snakeBodyColor;
    } else if (gameModel.value.isFood(x, y)) {
      return foodColor;
    } else {
      return boardColor;
    }
  }
  
  // Helper for UI to check if a cell is the snake head
  bool isSnakeHead(int x, int y) {
    return gameModel.value.isSnakeHead(x, y);
  }
  
  // Get score
  int getScore() {
    return gameModel.value.score;
  }
  
  // Get snake length
  int getSnakeLength() {
    return gameModel.value.snakeLength;
  }
  
  // Get board width
  int getBoardWidth() {
    return gameModel.value.boardWidth;
  }
  
  // Get board height
  int getBoardHeight() {
    return gameModel.value.boardHeight;
  }
} 