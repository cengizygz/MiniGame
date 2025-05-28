import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Platform types
enum PlatformType {
  normal,
  moving,
  breakable,
  vanishing
}

// Power-up types
enum PowerUpType {
  spring,
  jetpack,
  shield,
  coin
}

// Platform class for game objects
class GamePlatform {
  final int id;
  Offset position;
  final double width;
  final PlatformType type;
  bool isActive = true;
  Color color;
  double speed = 0.0; // For moving platforms
  bool isMovingRight = true; // Direction for moving platforms
  
  GamePlatform({
    required this.id,
    required this.position,
    required this.width,
    required this.type,
    required this.color,
  });
  
  // Update platform state (for moving, breakable, etc.)
  void update(Size screenSize) {
    if (!isActive) return;
    
    switch (type) {
      case PlatformType.moving:
        // Move horizontally
        if (isMovingRight) {
          position = Offset(position.dx + speed, position.dy);
          if (position.dx + width / 2 > screenSize.width) {
            isMovingRight = false;
          }
        } else {
          position = Offset(position.dx - speed, position.dy);
          if (position.dx - width / 2 < 0) {
            isMovingRight = true;
          }
        }
        break;
      default:
        break;
    }
  }
}

// Power-up class
class PowerUp {
  final PowerUpType type;
  Offset position;
  bool isCollected = false;
  final double size;
  
  PowerUp({
    required this.type,
    required this.position,
    required this.size,
  });
}

// Obstacle class
class Obstacle {
  Offset position;
  final double size;
  
  Obstacle({
    required this.position,
    required this.size,
  });
}

class DoodleJumpController extends GetxController {
  // Game state
  bool isGameRunning = false;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;
  
  // Player properties
  Offset playerPosition = const Offset(0, 0);
  double playerSize = 40.0;
  Offset playerVelocity = const Offset(0, 0);
  bool hasShield = false;
  bool hasJetpack = false;
  double jetpackTime = 0.0;
  
  // Physics parameters
  final double gravity = 0.4;
  final double jumpVelocity = -15.0;
  final double moveSpeed = 3.0;
  final double platformWidth = 70.0;
  
  // Game objects
  List<GamePlatform> platforms = [];
  List<PowerUp> powerUps = [];
  List<Obstacle> obstacles = [];
  
  // Screen dimensions
  late Size screenSize;
  
  // Camera (viewport) offset for scrolling effect
  double cameraOffset = 0.0;
  
  // Random generator
  final Random random = Random();
  
  // Game loop timer
  Timer? gameTimer;
  
  // Controls
  double horizontalControl = 0.0; // -1 to 1 for left/right
  
  // Initialize controller
  void initGame(Size size) {
    screenSize = size;
    resetGame();
  }
  
  // Start the game
  void startGame() {
    if (isGameRunning) return;
    
    isGameRunning = true;
    isGameOver = false;
    
    // Start game loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (isGameRunning) {
        updateGame();
        update();
      }
    });
    
    update();
  }
  
  // Reset the game
  void resetGame() {
    // Reset player
    playerPosition = Offset(screenSize.width / 2, screenSize.height - 100);
    playerVelocity = Offset(0, jumpVelocity); // Initial jump
    hasShield = false;
    hasJetpack = false;
    jetpackTime = 0.0;
    
    // Reset game state
    score = 0;
    isGameOver = false;
    cameraOffset = 0.0;
    
    // Clear game objects
    platforms.clear();
    powerUps.clear();
    obstacles.clear();
    
    // Create initial platforms
    _generateInitialPlatforms();
    
    update();
  }
  
  // Pause the game
  void pauseGame() {
    isGameRunning = false;
    update();
  }
  
  // Resume the game
  void resumeGame() {
    isGameRunning = true;
    update();
  }
  
  // End the game
  void endGame() {
    isGameRunning = false;
    gameTimer?.cancel();
    gameTimer = null;
    
    // Check high score
    if (score > highScore) {
      highScore = score;
      // TODO: Save score
    }
    
    isGameOver = true;
    update();
  }
  
  // Generate initial platforms
  void _generateInitialPlatforms() {
    // Add starting platform
    platforms.add(GamePlatform(
      id: 0,
      position: Offset(screenSize.width / 2, screenSize.height - 30),
      width: platformWidth * 1.5,
      type: PlatformType.normal,
      color: Colors.green,
    ));
    
    // Generate more platforms
    for (int i = 1; i < 15; i++) {
      _addPlatform(screenSize.height - 130 - i * 100.0);
    }
  }
  
  // Add a new platform at specified height
  void _addPlatform(double height) {
    final id = platforms.length;
    final double x = random.nextDouble() * (screenSize.width - platformWidth) + platformWidth / 2;
    
    // Determine platform type (with probabilities)
    PlatformType type;
    final typeRoll = random.nextDouble();
    
    if (typeRoll < 0.7) {
      // 70% chance for normal platform
      type = PlatformType.normal;
    } else if (typeRoll < 0.85) {
      // 15% chance for moving platform
      type = PlatformType.moving;
    } else if (typeRoll < 0.95) {
      // 10% chance for breakable platform
      type = PlatformType.breakable;
    } else {
      // 5% chance for vanishing platform
      type = PlatformType.vanishing;
    }
    
    // Set color based on type
    Color color;
    switch (type) {
      case PlatformType.normal:
        color = Colors.green;
        break;
      case PlatformType.moving:
        color = Colors.blue;
        break;
      case PlatformType.breakable:
        color = Colors.orange;
        break;
      case PlatformType.vanishing:
        color = Colors.purple;
        break;
    }
    
    // Create platform
    final platform = GamePlatform(
      id: id,
      position: Offset(x, height),
      width: platformWidth,
      type: type,
      color: color,
    );
    
    // Set speed for moving platforms
    if (type == PlatformType.moving) {
      platform.speed = 1.0 + random.nextDouble() * 1.5;
    }
    
    platforms.add(platform);
    
    // Occasionally add power-ups
    if (random.nextDouble() < 0.15) {
      _addPowerUp(Offset(x, height - 25));
    }
    
    // Occasionally add obstacles at higher scores
    if (score > 1000 && random.nextDouble() < 0.1) {
      _addObstacle(Offset(x + random.nextDouble() * 100 - 50, height - 40));
    }
  }
  
  // Add a power-up
  void _addPowerUp(Offset position) {
    // Determine power-up type
    PowerUpType type;
    final typeRoll = random.nextDouble();
    
    if (typeRoll < 0.4) {
      type = PowerUpType.spring;
    } else if (typeRoll < 0.7) {
      type = PowerUpType.coin;
    } else if (typeRoll < 0.9) {
      type = PowerUpType.shield;
    } else {
      type = PowerUpType.jetpack;
    }
    
    powerUps.add(PowerUp(
      type: type,
      position: position,
      size: 20.0,
    ));
  }
  
  // Add an obstacle
  void _addObstacle(Offset position) {
    obstacles.add(Obstacle(
      position: position,
      size: 30.0,
    ));
  }
  
  // Update the game state
  void updateGame() {
    if (!isGameRunning) return;
    
    // Apply horizontal control (from accelerometer or touch)
    playerVelocity = Offset(horizontalControl * moveSpeed, playerVelocity.dy);
    
    // Apply gravity unless jetpack is active
    if (hasJetpack) {
      playerVelocity = Offset(playerVelocity.dx, -12.0); // Constant upward velocity
      
      // Decrease jetpack time
      jetpackTime -= 0.016; // ~16ms per frame
      if (jetpackTime <= 0) {
        hasJetpack = false;
      }
    } else {
      playerVelocity = Offset(playerVelocity.dx, playerVelocity.dy + gravity);
    }
    
    // Update player position
    playerPosition = Offset(
      playerPosition.dx + playerVelocity.dx,
      playerPosition.dy + playerVelocity.dy,
    );
    
    // Wrap around screen horizontally
    if (playerPosition.dx < 0) {
      playerPosition = Offset(screenSize.width, playerPosition.dy);
    } else if (playerPosition.dx > screenSize.width) {
      playerPosition = Offset(0, playerPosition.dy);
    }
    
    // Check for platform collisions (when falling)
    if (playerVelocity.dy > 0) {
      for (var platform in platforms) {
        if (!platform.isActive) continue;
        
        // Check if player is within platform width
        final bool horizontalOverlap = 
            (playerPosition.dx + playerSize / 4 > platform.position.dx - platform.width / 2) &&
            (playerPosition.dx - playerSize / 4 < platform.position.dx + platform.width / 2);
        
        // Check if player just passed through the platform
        final bool verticalOverlap =
            (playerPosition.dy + playerSize / 2 > platform.position.dy - 5) &&
            (playerPosition.dy + playerSize / 2 < platform.position.dy + 5);
        
        if (horizontalOverlap && verticalOverlap) {
          // Handle different platform types
          switch (platform.type) {
            case PlatformType.normal:
            case PlatformType.moving:
              // Normal bounce
              playerVelocity = Offset(playerVelocity.dx, jumpVelocity);
              break;
            case PlatformType.breakable:
              // Break after jump
              playerVelocity = Offset(playerVelocity.dx, jumpVelocity);
              platform.isActive = false;
              break;
            case PlatformType.vanishing:
              // Vanish after a short delay
              playerVelocity = Offset(playerVelocity.dx, jumpVelocity);
              Future.delayed(const Duration(milliseconds: 200), () {
                platform.isActive = false;
                update();
              });
              break;
          }
        }
      }
    }
    
    // Update platforms
    for (var platform in platforms) {
      platform.update(screenSize);
    }
    
    // Check for power-up collisions
    for (var powerUp in powerUps) {
      if (powerUp.isCollected) continue;
      
      // Check if player touches power-up
      final double distance = (powerUp.position - playerPosition).distance;
      if (distance < (playerSize + powerUp.size) / 2) {
        powerUp.isCollected = true;
        
        // Apply power-up effect
        switch (powerUp.type) {
          case PowerUpType.spring:
            // Extra high jump
            playerVelocity = Offset(playerVelocity.dx, jumpVelocity * 1.5);
            break;
          case PowerUpType.jetpack:
            // Temporary jetpack
            hasJetpack = true;
            jetpackTime = 3.0; // 3 seconds
            break;
          case PowerUpType.shield:
            // Temporary shield
            hasShield = true;
            Future.delayed(const Duration(seconds: 5), () {
              hasShield = false;
              update();
            });
            break;
          case PowerUpType.coin:
            // Bonus points
            score += 50;
            break;
        }
      }
    }
    
    // Check for obstacle collisions
    if (!hasShield) {
      for (var obstacle in obstacles) {
        final double distance = (obstacle.position - playerPosition).distance;
        if (distance < (playerSize + obstacle.size) / 2) {
          // Hit an obstacle, game over
          endGame();
          return;
        }
      }
    }
    
    // Camera follows player when moving up
    if (playerPosition.dy < screenSize.height / 2) {
      // Move everything down
      final double difference = screenSize.height / 2 - playerPosition.dy;
      cameraOffset += difference;
      
      // Update player position to stay in middle
      playerPosition = Offset(playerPosition.dx, screenSize.height / 2);
      
      // Move platforms and other objects down
      for (var platform in platforms) {
        platform.position = Offset(platform.position.dx, platform.position.dy + difference);
      }
      
      for (var powerUp in powerUps) {
        powerUp.position = Offset(powerUp.position.dx, powerUp.position.dy + difference);
      }
      
      for (var obstacle in obstacles) {
        obstacle.position = Offset(obstacle.position.dx, obstacle.position.dy + difference);
      }
      
      // Update score based on height
      score = (cameraOffset / 10).round();
    }
    
    // Remove off-screen platforms and add new ones
    platforms.removeWhere((platform) => platform.position.dy > screenSize.height + 50);
    powerUps.removeWhere((powerUp) => powerUp.position.dy > screenSize.height + 50);
    obstacles.removeWhere((obstacle) => obstacle.position.dy > screenSize.height + 50);
    
    // Add new platforms as needed
    while (platforms.isNotEmpty && 
           platforms.map((p) => p.position.dy).reduce(min) > 0) {
      // Find highest platform
      double highestPlatformY = platforms.map((p) => p.position.dy).reduce(min);
      _addPlatform(highestPlatformY - random.nextDouble() * 50 - 50);
    }
    
    // Check if player fell off screen
    if (playerPosition.dy > screenSize.height + 100) {
      endGame();
    }
  }
  
  // Control player horizontal movement
  void setHorizontalControl(double value) {
    horizontalControl = value.clamp(-1.0, 1.0);
  }
  
  // Controller cleanup
  @override
  void onClose() {
    gameTimer?.cancel();
    gameTimer = null;
    super.onClose();
  }
} 