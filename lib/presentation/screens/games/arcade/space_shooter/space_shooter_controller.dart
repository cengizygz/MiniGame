import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import '../../../../../infrastructure/services/audio/audio_service.dart';
import 'space_shooter_model.dart';

class SpaceShooterController extends GetxController {
  // Services
  final StorageService _storage = Get.find<StorageService>();
  final AudioService _audioService = Get.find<AudioService>();
  
  // Game model
  late Rx<SpaceShooterModel> gameModel;
  
  // Game timer
  Timer? _gameTimer;
  final int _frameRate = 60; // frames per second
  
  // Screen dimensions
  late double screenWidth;
  late double screenHeight;
  
  // High score
  final RxInt highScore = 0.obs;
  
  // Difficulty level
  final RxInt difficulty = 1.obs;
  
  // Game state
  final RxBool isAutoFiring = true.obs; // Auto-firing enabled by default
  
  // Colors
  final spacecraftColor = Colors.blue.shade600;
  final projectileColor = Colors.yellow;
  final enemyColors = {
    'basic': Colors.red.shade400,
    'fast': Colors.purple.shade400,
    'tanky': Colors.brown.shade600,
  };
  final powerUpColors = {
    'weapon': Colors.orange,
    'health': Colors.green,
    'shield': Colors.blue.shade300,
  };
  
  @override
  void onInit() {
    super.onInit();
    
    // Get high score
    highScore.value = _storage.getInt('space_shooter_high_score', defaultValue: 0);
    
    // Screen dimensions will be set when the screen is built
    // Initialize with default values
    screenWidth = 400;
    screenHeight = 600;
    
    // Initialize game model with default screen size
    gameModel = SpaceShooterModel(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      highScore: highScore.value,
      difficulty: difficulty.value,
    ).obs;
  }
  
  @override
  void onClose() {
    _gameTimer?.cancel();
    super.onClose();
  }
  
  // Set screen dimensions
  void setScreenDimensions(double width, double height) {
    screenWidth = width;
    screenHeight = height;
    
    // Recreate game model with correct dimensions
    gameModel.value = SpaceShooterModel(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      highScore: highScore.value,
      difficulty: difficulty.value,
    );
  }
  
  // Start a new game
  void startNewGame() {
    // Cancel existing timer
    _gameTimer?.cancel();
    
    // Initialize game
    gameModel.value.initializeGame();
    
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
    gameModel.value.difficulty = level;
    
    update();
  }
  
  // Start game timer
  void _startGameTimer() {
    const frameInterval = Duration(milliseconds: 16); // ~60 FPS
    
    _gameTimer = Timer.periodic(
      frameInterval,
      (timer) {
        // Update game state
        gameModel.value.update();
        
        // Auto-fire if enabled
        if (isAutoFiring.value && !gameModel.value.isPaused && !gameModel.value.isGameOver) {
          gameModel.value.firePlayerWeapon();
          if (gameModel.value.player.canFire()) {
            _playSound('laser');
          }
        }
        
        // Check if game over
        if (gameModel.value.isGameOver) {
          _handleGameOver();
        }
        
        update();
      },
    );
  }
  
  // Handle game over
  void _handleGameOver() {
    _playSound('game_over');
    endGame();
  }
  
  void _saveHighScore() {
    if (gameModel.value.score > highScore.value) {
      highScore.value = gameModel.value.score;
      _storage.setInt('space_shooter_high_score', gameModel.value.score);
    }
  }
  
  void endGame() {
    _saveHighScore();
    isAutoFiring.value = false;
    _gameTimer?.cancel();
  }
  
  // Toggle pause
  void togglePause() {
    gameModel.value.isPaused = !gameModel.value.isPaused;
    
    if (gameModel.value.isPaused) {
      _playSound('pause');
    } else {
      _playSound('resume');
    }
    
    update();
  }
  
  // Toggle auto-firing
  void toggleAutoFire() {
    isAutoFiring.value = !isAutoFiring.value;
    update();
  }
  
  // Move player left
  void moveLeft(bool isMoving) {
    gameModel.value.player.isMovingLeft = isMoving;
    update();
  }
  
  // Move player right
  void moveRight(bool isMoving) {
    gameModel.value.player.isMovingRight = isMoving;
    update();
  }
  
  // Fire player weapon
  void fireWeapon() {
    if (gameModel.value.player.canFire() && 
        !gameModel.value.isPaused && 
        !gameModel.value.isGameOver) {
      gameModel.value.firePlayerWeapon();
      _playSound('laser');
    }
  }
  
  // Helper to play sound with fallback to generic sounds
  void _playSound(String soundName) {
    try {
      // Try to play game-specific sound first
      _audioService.playSound('sounds/space_shooter/$soundName.mp3');
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
  
  // Get player health
  int getPlayerHealth() {
    return gameModel.value.player.health;
  }
  
  // Get player max health
  int getPlayerMaxHealth() {
    return gameModel.value.player.maxHealth;
  }
  
  // Get weapon level
  int getWeaponLevel() {
    return gameModel.value.player.weaponLevel;
  }
  
  // Check if player is invincible
  bool isPlayerInvincible() {
    return gameModel.value.player.isInvincible;
  }
  
  // Get current level
  int getCurrentLevel() {
    return gameModel.value.level;
  }
  
  // Get current score
  int getScore() {
    return gameModel.value.score;
  }
  
  // Check if game is over
  bool isGameOver() {
    return gameModel.value.isGameOver;
  }
  
  // Check if game is paused
  bool isPaused() {
    return gameModel.value.isPaused;
  }
  
  // Get player position
  Rect getPlayerRect() {
    final player = gameModel.value.player;
    return Rect.fromLTWH(player.x, player.y, player.width, player.height);
  }
  
  // Get projectiles
  List<Rect> getProjectileRects() {
    return gameModel.value.projectiles.map((p) {
      return Rect.fromLTWH(p.x, p.y, p.width, p.height);
    }).toList();
  }
  
  // Get enemies
  List<Map<String, dynamic>> getEnemyData() {
    return gameModel.value.enemies.map((e) {
      return {
        'rect': Rect.fromLTWH(e.x, e.y, e.width, e.height),
        'type': e.type,
        'health': e.health,
      };
    }).toList();
  }
  
  // Get power-ups
  List<Map<String, dynamic>> getPowerUpData() {
    return gameModel.value.powerUps.map((p) {
      return {
        'rect': Rect.fromLTWH(p.x, p.y, p.width, p.height),
        'type': p.type,
      };
    }).toList();
  }
  
  // Get explosions
  List<Map<String, dynamic>> getExplosionData() {
    return gameModel.value.explosions.map((e) {
      return {
        'x': e.x,
        'y': e.y,
        'size': e.size,
        'phase': e.getPhase(),
      };
    }).toList();
  }
} 