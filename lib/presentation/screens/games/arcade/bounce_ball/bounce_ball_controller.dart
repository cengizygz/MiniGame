import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import '../../../../../infrastructure/services/audio/audio_service.dart';
import 'bounce_ball_model.dart';

class BounceBallController extends GetxController {
  // Services
  final StorageService _storage = Get.find<StorageService>();
  final AudioService _audioService = Get.find<AudioService>();
  
  // Game state
  final RxBool isGameStarted = false.obs;
  final RxBool isPaused = false.obs;
  final RxBool isGameOver = false.obs;
  
  // Game model
  late BounceBallModel gameModel;
  
  // Basic stats
  final RxInt score = 0.obs;
  final RxInt lives = 3.obs;
  final RxInt level = 1.obs;
  final RxInt highScore = 0.obs;
  final RxInt difficulty = 1.obs;
  
  // Game timer
  Timer? _gameTimer;
  final int _frameRate = 60; // frames per second
  
  // Screen dimensions
  double screenWidth = 0;
  double screenHeight = 0;
  
  // Game objects
  Offset ballPosition = Offset.zero;
  double ballRadius = 10;
  Offset ballDirection = const Offset(1, -1); // Initial direction
  double ballSpeed = 5.0;
  
  Offset paddlePosition = Offset.zero;
  double paddleWidth = 100;
  double paddleHeight = 20;
  
  // List of bricks
  List<Map<String, dynamic>> bricks = [];
  
  // Power-ups
  List<Map<String, dynamic>> activePowerUps = [];
  Map<String, Timer> powerUpTimers = {};
  
  @override
  void onInit() {
    super.onInit();
    
    // Load high score
    highScore.value = _storage.getInt('profile_highscore_bounce_ball', defaultValue: 0);
    
    // Initialize game model
    gameModel = BounceBallModel();
  }
  
  @override
  void onClose() {
    // Cancel game timer
    _gameTimer?.cancel();
    
    // Cancel all power-up timers
    for (final timer in powerUpTimers.values) {
      timer.cancel();
    }
    
    super.onClose();
  }
  
  // Set screen dimensions
  void setScreenDimensions(double width, double height) {
    screenWidth = width;
    screenHeight = height;
    
    // Initialize object positions
    _initializePositions();
  }
  
  // Initialize object positions
  void _initializePositions() {
    // Position paddle at the bottom center
    paddlePosition = Offset(screenWidth / 2, screenHeight - 40);
    
    // Position ball just above the paddle
    ballPosition = Offset(paddlePosition.dx, paddlePosition.dy - paddleHeight / 2 - ballRadius - 5);
    
    // Initialize paddle size based on difficulty
    _adjustPaddleSize();
  }
  
  // Adjust paddle size based on difficulty
  void _adjustPaddleSize() {
    switch (difficulty.value) {
      case 1: // Easy
        paddleWidth = 120;
        break;
      case 2: // Medium
        paddleWidth = 100;
        break;
      case 3: // Hard
        paddleWidth = 80;
        break;
    }
  }
  
  // Start a new game
  void startNewGame() {
    // Reset game state
    isGameStarted.value = false;
    isPaused.value = false;
    isGameOver.value = false;
    
    // Reset stats
    score.value = 0;
    lives.value = 3;
    level.value = 1;
    
    // Reset ball speed
    _resetBallSpeed();
    
    // Reset positions
    _initializePositions();
    
    // Generate bricks
    _generateBricks();
    
    // Clear power-ups
    activePowerUps.clear();
    
    // Cancel existing timers
    _gameTimer?.cancel();
    for (final timer in powerUpTimers.values) {
      timer.cancel();
    }
    powerUpTimers.clear();
    
    // Play start sound
    _playSound('game_start');
    
    update();
  }
  
  // Start ball movement (when player taps the screen)
  void startBall() {
    if (isGameStarted.value || isPaused.value || isGameOver.value) return;
    
    isGameStarted.value = true;
    
    // Random initial direction (between -30 and 30 degrees)
    final random = Random();
    final angle = -pi / 2 + (random.nextDouble() - 0.5) * pi / 3;
    ballDirection = Offset(cos(angle), sin(angle));
    
    // Start game loop
    _startGameLoop();
    
    // Play sound
    _playSound('bounce');
    
    update();
  }
  
  // Set difficulty level
  void setDifficulty(int level) {
    difficulty.value = level;
    _resetBallSpeed();
    _adjustPaddleSize();
    update();
  }
  
  // Reset ball speed based on difficulty and level
  void _resetBallSpeed() {
    // Base speed
    double baseSpeed;
    switch (difficulty.value) {
      case 1: // Easy
        baseSpeed = 4.0;
        break;
      case 2: // Medium
        baseSpeed = 5.0;
        break;
      case 3: // Hard
        baseSpeed = 6.0;
        break;
      default:
        baseSpeed = 5.0;
    }
    
    // Add level bonus
    ballSpeed = baseSpeed + (level.value - 1) * 0.5;
  }
  
  // Generate brick layout
  void _generateBricks() {
    bricks.clear();
    
    final brickWidth = screenWidth / 8;
    final brickHeight = 25.0;
    final maxStrength = min(level.value, 4);
    final rows = min(4 + level.value, 10);
    
    final random = Random();
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < 8; col++) {
        // Skip some bricks for visual appeal
        if (random.nextDouble() < 0.1) continue;
        
        final strength = random.nextInt(maxStrength) + 1;
        
        bricks.add({
          'rect': Rect.fromLTWH(
            col * brickWidth,
            row * brickHeight + 50, // Start 50px from top
            brickWidth,
            brickHeight,
          ),
          'strength': strength,
        });
      }
    }
  }
  
  // Move paddle based on user input
  void movePaddle(double delta) {
    // Update paddle position
    paddlePosition = Offset(
      paddlePosition.dx + delta,
      paddlePosition.dy,
    );
    
    // Boundary check
    if (paddlePosition.dx - paddleWidth / 2 < 0) {
      paddlePosition = Offset(paddleWidth / 2, paddlePosition.dy);
    } else if (paddlePosition.dx + paddleWidth / 2 > screenWidth) {
      paddlePosition = Offset(screenWidth - paddleWidth / 2, paddlePosition.dy);
    }
    
    // Move ball with paddle if game not started
    if (!isGameStarted.value) {
      ballPosition = Offset(paddlePosition.dx, ballPosition.dy);
    }
    
    update();
  }
  
  // Toggle pause state
  void togglePause() {
    isPaused.value = !isPaused.value;
    
    if (isPaused.value) {
      _gameTimer?.cancel();
      _playSound('pause');
    } else {
      _startGameLoop();
      _playSound('resume');
    }
    
    update();
  }
  
  // Start the game loop
  void _startGameLoop() {
    // Cancel existing timer
    _gameTimer?.cancel();
    
    // Calculate frame duration
    final frameDuration = Duration(milliseconds: (1000 / _frameRate).round());
    
    // Start new timer
    _gameTimer = Timer.periodic(frameDuration, (timer) {
      if (!isGameStarted.value || isPaused.value || isGameOver.value) return;
      
      _updateGame();
      update();
    });
  }
  
  // Update game state each frame
  void _updateGame() {
    // Move ball
    final newPosition = ballPosition + ballDirection * ballSpeed;
    
    // Handle wall collisions
    bool collided = false;
    var newDirection = ballDirection;
    
    // Left/Right wall collisions
    if (newPosition.dx - ballRadius < 0 || newPosition.dx + ballRadius > screenWidth) {
      newDirection = Offset(-newDirection.dx, newDirection.dy);
      collided = true;
    }
    
    // Top wall collision
    if (newPosition.dy - ballRadius < 0) {
      newDirection = Offset(newDirection.dx, -newDirection.dy);
      collided = true;
    }
    
    // Bottom wall = losing a life
    if (newPosition.dy + ballRadius > screenHeight) {
      _loseLife();
      return;
    }
    
    // Paddle collision
    final paddleRect = Rect.fromCenter(
      center: paddlePosition,
      width: paddleWidth,
      height: paddleHeight,
    );
    
    if (newPosition.dy + ballRadius > paddleRect.top &&
        newPosition.dy - ballRadius < paddleRect.bottom &&
        newPosition.dx + ballRadius > paddleRect.left &&
        newPosition.dx - ballRadius < paddleRect.right) {
      
      // Calculate bounce angle based on where the ball hit the paddle
      final relativeIntersectX = newPosition.dx - paddlePosition.dx;
      final normalizedIntersect = relativeIntersectX / (paddleWidth / 2);
      final bounceAngle = normalizedIntersect * (pi / 3); // Max 60 degree angle
      
      newDirection = Offset(sin(bounceAngle), -cos(bounceAngle));
      collided = true;
      
      // Slight speed increase with each paddle hit
      ballSpeed = min(ballSpeed + 0.05, 10.0);
    }
    
    // Brick collisions
    bool brickHit = false;
    for (int i = 0; i < bricks.length; i++) {
      final brick = bricks[i];
      final strength = brick['strength'] as int;
      
      // Skip already destroyed bricks
      if (strength <= 0) continue;
      
      final brickRect = brick['rect'] as Rect;
      
      // Check if ball collides with brick
      if (_checkBallBrickCollision(newPosition, brickRect)) {
        brickHit = true;
        
        // Determine bounce direction
        // Simplified approach - check which side is closer
        final ballCenter = ballPosition;
        final brickCenter = brickRect.center;
        
        // Calculate distances to each edge
        final dLeft = (ballCenter.dx - brickRect.left).abs();
        final dRight = (ballCenter.dx - brickRect.right).abs();
        final dTop = (ballCenter.dy - brickRect.top).abs();
        final dBottom = (ballCenter.dy - brickRect.bottom).abs();
        
        // Find minimum distance
        final minDist = [dLeft, dRight, dTop, dBottom].reduce(min);
        
        // Bounce based on which side was hit
        if (minDist == dLeft || minDist == dRight) {
          // Left or right hit
          newDirection = Offset(-newDirection.dx, newDirection.dy);
        } else {
          // Top or bottom hit
          newDirection = Offset(newDirection.dx, -newDirection.dy);
        }
        
        // Decrease brick strength
        bricks[i]['strength'] = strength - 1;
        
        // Add score
        score.value += 10 * strength;
        
        // Check for potential power-up spawn
        if (strength == 1) {
          _trySpawnPowerUp(brickRect.center);
        }
        
        // Play sound
        _playSound('hit');
        
        // Only handle one brick collision per frame
        break;
      }
    }
    
    // Play collision sound
    if (collided && !brickHit) {
      _playSound('bounce');
    }
    
    // Update ball position and direction
    ballPosition = newPosition;
    ballDirection = newDirection.normalized(); // Ensure unit vector
    
    // Update power-ups
    _updatePowerUps();
    
    // Check for level completion
    if (_checkLevelComplete()) {
      _advanceToNextLevel();
    }
  }
  
  // Check if ball collides with a brick
  bool _checkBallBrickCollision(Offset ballPos, Rect brickRect) {
    // Find the closest point on the rectangle to the ball
    final closestX = ballPos.dx.clamp(brickRect.left, brickRect.right);
    final closestY = ballPos.dy.clamp(brickRect.top, brickRect.bottom);
    
    // Calculate distance from closest point to ball center
    final distanceX = ballPos.dx - closestX;
    final distanceY = ballPos.dy - closestY;
    final distanceSquared = distanceX * distanceX + distanceY * distanceY;
    
    // If distance is less than ball radius, there's a collision
    return distanceSquared <= ballRadius * ballRadius;
  }
  
  // Try to spawn a power-up from a destroyed brick
  void _trySpawnPowerUp(Offset position) {
    final random = Random();
    
    // 15% chance to spawn a power-up
    if (random.nextDouble() < 0.15) {
      final powerUpTypes = [
        'expand',   // Expand paddle
        'shrink',   // Shrink paddle
        'slow',     // Slow ball
        'fast',     // Speed up ball
        'multiball', // Add extra ball (not implemented)
        'extralife', // Extra life
      ];
      
      final type = powerUpTypes[random.nextInt(powerUpTypes.length)];
      
      activePowerUps.add({
        'position': position,
        'type': type,
        'velocity': Offset(0, 2.0), // Move downward
        'size': 20.0,
        'active': false,
      });
    }
  }
  
  // Update power-ups (movement and collection)
  void _updatePowerUps() {
    for (int i = activePowerUps.length - 1; i >= 0; i--) {
      final powerUp = activePowerUps[i];
      
      // Skip already activated power-ups
      if (powerUp['active'] == true) continue;
      
      // Move power-up down
      final position = powerUp['position'] as Offset;
      final velocity = powerUp['velocity'] as Offset;
      final size = powerUp['size'] as double;
      
      final newPosition = position + velocity;
      powerUp['position'] = newPosition;
      
      // Check if power-up is collected by paddle
      final paddleRect = Rect.fromCenter(
        center: paddlePosition,
        width: paddleWidth,
        height: paddleHeight,
      );
      
      final powerUpRect = Rect.fromCenter(
        center: newPosition,
        width: size,
        height: size * 1.5,
      );
      
      if (paddleRect.overlaps(powerUpRect)) {
        // Activate power-up
        _activatePowerUp(powerUp['type'] as String);
        
        // Mark as collected
        powerUp['active'] = true;
        
        // Play sound
        _playSound('powerup');
      }
      
      // Remove if off screen
      if (newPosition.dy - size > screenHeight) {
        activePowerUps.removeAt(i);
      }
    }
    
    // Remove collected power-ups
    activePowerUps.removeWhere((powerUp) => powerUp['active'] == true);
  }
  
  // Activate a power-up
  void _activatePowerUp(String type) {
    switch (type) {
      case 'expand':
        // Expand paddle
        paddleWidth = min(paddleWidth * 1.5, screenWidth * 0.8);
        
        // Cancel existing timer
        powerUpTimers['paddleSize']?.cancel();
        
        // Set timer to reset
        powerUpTimers['paddleSize'] = Timer(const Duration(seconds: 15), () {
          _adjustPaddleSize();
          update();
        });
        break;
        
      case 'shrink':
        // Shrink paddle (only if not already too small)
        if (paddleWidth > 40) {
          paddleWidth = max(paddleWidth * 0.7, 40);
        }
        
        // Cancel existing timer
        powerUpTimers['paddleSize']?.cancel();
        
        // Set timer to reset
        powerUpTimers['paddleSize'] = Timer(const Duration(seconds: 10), () {
          _adjustPaddleSize();
          update();
        });
        break;
        
      case 'slow':
        // Slow down ball
        ballSpeed = max(ballSpeed * 0.7, 2.0);
        
        // Cancel existing timer
        powerUpTimers['ballSpeed']?.cancel();
        
        // Set timer to reset
        powerUpTimers['ballSpeed'] = Timer(const Duration(seconds: 10), () {
          _resetBallSpeed();
          update();
        });
        break;
        
      case 'fast':
        // Speed up ball
        ballSpeed = min(ballSpeed * 1.3, 12.0);
        
        // Cancel existing timer
        powerUpTimers['ballSpeed']?.cancel();
        
        // Set timer to reset
        powerUpTimers['ballSpeed'] = Timer(const Duration(seconds: 8), () {
          _resetBallSpeed();
          update();
        });
        break;
        
      case 'multiball':
        // Not implemented in this version
        // Would require tracking multiple balls
        break;
        
      case 'extralife':
        // Add extra life
        lives.value = min(lives.value + 1, 5);
        break;
    }
  }
  
  // Lose a life
  void _loseLife() {
    lives.value--;
    
    // Play sound
    _playSound('life_lost');
    
    // Game over check
    if (lives.value <= 0) {
      _gameOver();
      return;
    }
    
    // Reset ball and paddle
    isGameStarted.value = false;
    _initializePositions();
    
    update();
  }
  
  // Check if level is complete (all bricks destroyed)
  bool _checkLevelComplete() {
    return bricks.every((brick) => brick['strength'] <= 0);
  }
  
  // Advance to next level
  void _advanceToNextLevel() {
    // Increment level
    level.value++;
    
    // Bonus points for completing level
    score.value += 100 * level.value;
    
    // Reset ball and paddle
    isGameStarted.value = false;
    _initializePositions();
    
    // Generate new brick layout
    _generateBricks();
    
    // Clear power-ups
    activePowerUps.clear();
    
    // Cancel power-up timers
    for (final timer in powerUpTimers.values) {
      timer.cancel();
    }
    powerUpTimers.clear();
    
    // Play sound
    _playSound('level_complete');
    
    update();
  }
  
  // Game over
  void _gameOver() {
    isGameOver.value = true;
    isGameStarted.value = false;
    
    // Cancel game timer
    _gameTimer?.cancel();
    
    // Save score
    _saveScore();
    
    // Play sound
    _playSound('game_over');
    
    update();
  }
  
  // Save score
  void _saveScore() {
    // Save to leaderboard
    _storage.saveGameResult('bounce_ball', score.value);
    
    // Update high score if needed
    if (score.value > highScore.value) {
      highScore.value = score.value;
      _storage.setInt('profile_highscore_bounce_ball', score.value);
    }
  }
  
  // Play sound with fallback
  void _playSound(String soundName) {
    try {
      // Try game-specific sound
      _audioService.playSound('sounds/bounce_ball/$soundName.mp3');
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
}

// Extension for vector normalization
extension OffsetExtension on Offset {
  Offset normalized() {
    final magnitude = distance;
    if (magnitude == 0) return Offset.zero;
    return Offset(dx / magnitude, dy / magnitude);
  }
} 