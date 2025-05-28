import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Game modes
enum GameMode {
  classic,  // Play until you miss a tile
  arcade,   // Play for 60 seconds, speed increases
  zen       // Relaxed mode, no miss penalty
}

// Tile class to represent a piano tile
class PianoTile {
  final int id;
  final int column;
  double position; // 0.0 at top, 1.0 at bottom
  bool isHit = false;
  bool isActive = true;
  
  PianoTile({
    required this.id,
    required this.column,
    this.position = 0.0,
  });
}

class PianoTilesController extends GetxController {
  // Game state
  bool isGameStarted = false;
  bool isGamePaused = false;
  bool isGameOver = false;
  
  // Score tracking
  int tilesTapped = 0;
  int highScore = 0;
  int comboCount = 0;
  int maxCombo = 0;
  
  // Game parameters
  GameMode gameMode = GameMode.classic;
  int columnCount = 4;
  double tileSpeed = 0.006; // How fast tiles move down, increases with difficulty
  double baseTileSpeed = 0.006; // Starting speed
  double speedMultiplier = 1.0; // Increases as more tiles are tapped
  double speedIncreaseRate = 0.005; // How much speed increases per tap
  
  // Game objects
  List<PianoTile> tiles = [];
  int tileIdCounter = 0;
  int lastTileColumn = -1; // To avoid consecutive tiles in same column
  
  // Game timer
  Timer? gameTimer;
  Timer? arcadeModeTimer;
  int arcadeModeTimeLeft = 60; // 60 seconds for arcade mode
  
  // Tile generation parameters
  double minGapBetweenTiles = 0.2; // Minimum gap between consecutive tiles
  double tileHeight = 0.2; // Tile height as percentage of screen height
  
  // Sound feedback
  List<String> pianoNotes = [
    'C', 'D', 'E', 'F', 'G', 'A', 'B',
  ];
  
  // Random generator
  final Random random = Random();
  
  // Initialize controller
  void initGame() {
    resetGame();
  }
  
  // Reset game state
  void resetGame() {
    // Reset game state
    isGameStarted = false;
    isGamePaused = false;
    isGameOver = false;
    
    // Reset score
    tilesTapped = 0;
    comboCount = 0;
    maxCombo = 0;
    
    // Reset tiles
    tiles.clear();
    tileIdCounter = 0;
    lastTileColumn = -1;
    
    // Reset timers
    gameTimer?.cancel();
    gameTimer = null;
    arcadeModeTimer?.cancel();
    arcadeModeTimer = null;
    arcadeModeTimeLeft = 60;
    
    // Reset speed
    tileSpeed = baseTileSpeed;
    speedMultiplier = 1.0;
    
    update();
  }
  
  // Set game mode
  void setGameMode(GameMode mode) {
    gameMode = mode;
    
    // Adjust parameters based on mode
    switch (mode) {
      case GameMode.classic:
        baseTileSpeed = 0.006;
        speedIncreaseRate = 0.005;
        break;
      case GameMode.arcade:
        baseTileSpeed = 0.008;
        speedIncreaseRate = 0.003;
        break;
      case GameMode.zen:
        baseTileSpeed = 0.004;
        speedIncreaseRate = 0.001;
        break;
    }
    
    tileSpeed = baseTileSpeed;
    update();
  }
  
  // Start the game
  void startGame() {
    if (isGameStarted) return;
    
    resetGame();
    isGameStarted = true;
    
    // Generate initial tiles
    _addTile();
    
    // Start game loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!isGamePaused && !isGameOver) {
        _updateGame();
        update();
      }
    });
    
    // Start arcade mode timer if applicable
    if (gameMode == GameMode.arcade) {
      arcadeModeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!isGamePaused && !isGameOver) {
          arcadeModeTimeLeft--;
          
          if (arcadeModeTimeLeft <= 0) {
            endGame();
          }
          
          update();
        }
      });
    }
    
    update();
  }
  
  // Pause game
  void pauseGame() {
    isGamePaused = true;
    update();
  }
  
  // Resume game
  void resumeGame() {
    isGamePaused = false;
    update();
  }
  
  // End game
  void endGame() {
    isGameOver = true;
    gameTimer?.cancel();
    gameTimer = null;
    arcadeModeTimer?.cancel();
    arcadeModeTimer = null;
    
    // Update high score
    if (tilesTapped > highScore) {
      highScore = tilesTapped;
      // TODO: Save high score
    }
    
    update();
  }
  
  // Update game state
  void _updateGame() {
    // Update tile positions
    for (final tile in tiles) {
      if (tile.isActive) {
        tile.position += tileSpeed * speedMultiplier;
        
        // Check if tile was missed
        if (tile.position > 1.0 + tileHeight / 2) {
          tile.isActive = false;
          
          // Game over if a tile is missed in classic mode
          if (gameMode == GameMode.classic) {
            endGame();
            return;
          } else if (gameMode == GameMode.arcade) {
            // In arcade mode, just reset combo
            comboCount = 0;
          }
        }
      }
    }
    
    // Add new tiles
    bool shouldAddTile = tiles.isEmpty || 
      tiles.last.position > minGapBetweenTiles + tileHeight;
    
    if (shouldAddTile) {
      _addTile();
    }
    
    // Clean up offscreen tiles
    tiles.removeWhere((tile) => 
      tile.position > 1.2 && !tile.isActive);
  }
  
  // Add a new tile
  void _addTile() {
    // Choose column
    int column;
    do {
      column = random.nextInt(columnCount);
    } while (column == lastTileColumn && columnCount > 1);
    
    lastTileColumn = column;
    
    // Create new tile
    final tile = PianoTile(
      id: tileIdCounter++,
      column: column,
      position: -tileHeight, // Start just above the screen
    );
    
    tiles.add(tile);
  }
  
  // Handle tap on a column
  void tapColumn(int column) {
    if (!isGameStarted || isGamePaused || isGameOver) return;
    
    // Find the lowest (closest to bottom) active, unhit tile in this column
    PianoTile? tappedTile;
    
    for (final tile in tiles.reversed) {
      if (tile.isActive && !tile.isHit && tile.column == column && tile.position > 0) {
        tappedTile = tile;
        break;
      }
    }
    
    if (tappedTile != null) {
      // Tile hit
      tappedTile.isHit = true;
      tilesTapped++;
      comboCount++;
      
      // Update max combo
      if (comboCount > maxCombo) {
        maxCombo = comboCount;
      }
      
      // Increase speed in classic and arcade modes
      if (gameMode != GameMode.zen) {
        speedMultiplier += speedIncreaseRate;
      }
      
      // Play note - TODO: implement sound
      final noteIndex = tilesTapped % pianoNotes.length;
      final note = pianoNotes[noteIndex];
      // TODO: Play sound for note
      
    } else {
      // Tapped empty column - game over in classic mode
      if (gameMode == GameMode.classic) {
        endGame();
      } else if (gameMode == GameMode.arcade) {
        // Reset combo in arcade mode
        comboCount = 0;
      }
    }
    
    update();
  }
  
  // Controller cleanup
  @override
  void onClose() {
    gameTimer?.cancel();
    arcadeModeTimer?.cancel();
    super.onClose();
  }
} 