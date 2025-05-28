import 'dart:math';

enum Direction { up, right, down, left, none }

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  Position operator +(Position other) => Position(x + other.x, y + other.y);
}

class SnakeModel {
  // Game board dimensions
  final int boardWidth;
  final int boardHeight;
  
  // Snake properties
  List<Position> snakeBody;
  Direction direction;
  
  // Food position
  Position? food;
  
  // Game state
  int score;
  int highScore;
  bool isGameOver;
  
  // Difficulty level (1-3)
  int difficulty;
  
  // Konstruktor
  SnakeModel({
    this.boardWidth = 15,
    this.boardHeight = 20,
    this.highScore = 0,
    this.difficulty = 1,
  })  : snakeBody = [],
        direction = Direction.none,
        food = null,
        score = 0,
        isGameOver = false;
  
  // Initialize game
  void initializeGame() {
    // Reset snake to initial position (center of board)
    final centerX = boardWidth ~/ 2;
    final centerY = boardHeight ~/ 2;
    
    snakeBody = [
      Position(centerX, centerY),
      Position(centerX - 1, centerY),
      Position(centerX - 2, centerY),
    ];
    
    // Set initial direction
    direction = Direction.right;
    
    // Reset game state
    score = 0;
    isGameOver = false;
    
    // Generate food
    _generateFood();
  }
  
  // Generate new food on the board
  void _generateFood() {
    final random = Random();
    
    // Try to find an empty position for the food
    int maxAttempts = 100;
    bool foodPlaced = false;
    
    while (!foodPlaced && maxAttempts > 0) {
      final x = random.nextInt(boardWidth);
      final y = random.nextInt(boardHeight);
      
      final position = Position(x, y);
      
      // Check if position is empty (not occupied by snake)
      if (!snakeBody.contains(position)) {
        food = position;
        foodPlaced = true;
        break;
      }
      
      maxAttempts--;
    }
    
    // If we couldn't place food after max attempts, try again with simpler approach
    if (!foodPlaced) {
      List<Position> emptyPositions = [];
      
      for (int x = 0; x < boardWidth; x++) {
        for (int y = 0; y < boardHeight; y++) {
          final position = Position(x, y);
          if (!snakeBody.contains(position)) {
            emptyPositions.add(position);
          }
        }
      }
      
      if (emptyPositions.isNotEmpty) {
        food = emptyPositions[random.nextInt(emptyPositions.length)];
      }
    }
  }
  
  // Change snake direction
  void changeDirection(Direction newDirection) {
    // Prevent 180-degree turns (can't go directly opposite)
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    
    direction = newDirection;
  }
  
  // Update snake position based on current direction
  bool updateSnake() {
    if (isGameOver) return false;
    
    // Calculate new head position based on direction
    Position? newHead;
    
    switch (direction) {
      case Direction.up:
        newHead = Position(snakeBody.first.x, snakeBody.first.y - 1);
        break;
      case Direction.right:
        newHead = Position(snakeBody.first.x + 1, snakeBody.first.y);
        break;
      case Direction.down:
        newHead = Position(snakeBody.first.x, snakeBody.first.y + 1);
        break;
      case Direction.left:
        newHead = Position(snakeBody.first.x - 1, snakeBody.first.y);
        break;
      case Direction.none:
        return false; // No movement needed
    }
    
    // Check if game is over (collision with wall or self)
    if (_checkCollision(newHead)) {
      isGameOver = true;
      return false;
    }
    
    // Add new head
    snakeBody.insert(0, newHead);
    
    // Check if snake ate food
    bool didEatFood = food != null && newHead == food;
    
    if (didEatFood) {
      // Increase score
      score += _calculatePoints();
      
      // Generate new food
      _generateFood();
    } else {
      // Remove tail (snake only grows when eating food)
      snakeBody.removeLast();
    }
    
    return didEatFood;
  }
  
  // Check if position collides with wall or snake body
  bool _checkCollision(Position position) {
    // Check wall collision
    if (position.x < 0 || position.x >= boardWidth || 
        position.y < 0 || position.y >= boardHeight) {
      return true;
    }
    
    // Check self collision (skip head comparison)
    for (int i = 1; i < snakeBody.length; i++) {
      if (position == snakeBody[i]) {
        return true;
      }
    }
    
    return false;
  }
  
  // Calculate points based on difficulty level
  int _calculatePoints() {
    return 10 * difficulty;
  }
  
  // Get snake speed based on difficulty and current score
  Duration getGameSpeed() {
    // Base speed depending on difficulty (milliseconds per tick)
    int baseSpeed;
    switch (difficulty) {
      case 1:
        baseSpeed = 300; // Slower for easy
        break;
      case 2:
        baseSpeed = 250; // Medium speed
        break;
      case 3:
        baseSpeed = 200; // Faster for hard
        break;
      default:
        baseSpeed = 300;
    }
    
    // Increase speed based on score
    // For every 50 points, speed increases by 10%
    final speedMultiplier = 1.0 - min((score / 50) * 0.1, 0.5);
    
    return Duration(milliseconds: (baseSpeed * speedMultiplier).toInt());
  }
  
  // Get snake length
  int get snakeLength => snakeBody.length;
  
  // Get head position
  Position get head => snakeBody.first;
  
  // Check if position is food
  bool isFood(int x, int y) {
    return food?.x == x && food?.y == y;
  }
  
  // Check if position is snake
  bool isSnake(int x, int y) {
    return snakeBody.any((pos) => pos.x == x && pos.y == y);
  }
  
  // Check if position is snake head
  bool isSnakeHead(int x, int y) {
    return snakeBody.first.x == x && snakeBody.first.y == y;
  }
} 