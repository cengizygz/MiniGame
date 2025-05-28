import 'dart:math';

// Player spacecraft model
class Spacecraft {
  // Position
  double x;
  double y;
  
  // Size
  double width;
  double height;
  
  // Speed and movement
  double speed;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  
  // Health and status
  int health;
  int maxHealth;
  bool isInvincible = false;
  int invincibilityTimer = 0;
  
  // Weapon properties
  int weaponLevel = 1;
  int weaponCooldown = 0;
  int weaponCooldownTime = 15; // frames
  
  Spacecraft({
    required this.x,
    required this.y,
    this.width = 60,
    this.height = 60,
    this.speed = 5.0,
    this.health = 3,
    this.maxHealth = 3,
  });
  
  // Update spacecraft position based on input
  void update(double screenWidth) {
    if (isMovingLeft) {
      x = max(0, x - speed);
    }
    if (isMovingRight) {
      x = min(screenWidth - width, x + speed);
    }
    
    // Decrease weapon cooldown
    if (weaponCooldown > 0) {
      weaponCooldown--;
    }
    
    // Decrease invincibility timer
    if (isInvincible && invincibilityTimer > 0) {
      invincibilityTimer--;
      if (invincibilityTimer <= 0) {
        isInvincible = false;
      }
    }
  }
  
  // Check if weapon can fire
  bool canFire() {
    return weaponCooldown <= 0;
  }
  
  // Fire weapon
  void fire() {
    weaponCooldown = weaponCooldownTime;
  }
  
  // Take damage
  bool takeDamage() {
    if (isInvincible) return false;
    
    health -= 1;
    
    // Make invincible briefly
    isInvincible = true;
    invincibilityTimer = 60; // frames of invincibility
    
    return health <= 0; // Return true if spacecraft is destroyed
  }
  
  // Power up weapon
  void powerUpWeapon() {
    weaponLevel = min(3, weaponLevel + 1);
  }
  
  // Heal spacecraft
  void heal() {
    health = min(maxHealth, health + 1);
  }
}

// Projectile model for player shots
class Projectile {
  double x;
  double y;
  double speed;
  double width;
  double height;
  int power;
  bool isActive = true;
  
  Projectile({
    required this.x,
    required this.y,
    this.speed = 8.0,
    this.width = 8,
    this.height = 20,
    this.power = 1,
  });
  
  // Update projectile position
  void update() {
    y -= speed; // Move upward
  }
  
  // Check if projectile is off screen
  bool isOffScreen() {
    return y < -height;
  }
}

// Enemy model
class Enemy {
  double x;
  double y;
  double speed;
  double width;
  double height;
  int health;
  int scoreValue;
  String type;
  bool isActive = true;
  
  // Movement patterns
  bool movesHorizontally;
  double horizontalSpeed;
  double horizontalLimit;
  late double initialX;
  
  Enemy({
    required this.x,
    required this.y,
    required this.type,
    this.speed = 2.0,
    this.width = 50,
    this.height = 50,
    this.health = 1,
    this.scoreValue = 10,
    this.movesHorizontally = false,
    this.horizontalSpeed = 1.0,
    this.horizontalLimit = 100.0,
  }) {
    initialX = x;
  }
  
  // Update enemy position
  void update() {
    y += speed; // Move downward
    
    // Horizontal movement if enabled
    if (movesHorizontally) {
      x += horizontalSpeed;
      
      // Change direction if reached limit
      if ((x - initialX).abs() > horizontalLimit) {
        horizontalSpeed *= -1;
      }
    }
  }
  
  // Take damage from projectile
  bool takeDamage(int damage) {
    health -= damage;
    return health <= 0;
  }
  
  // Check if enemy is off screen
  bool isOffScreen(double screenHeight) {
    return y > screenHeight;
  }
}

// Power-up model
class PowerUp {
  double x;
  double y;
  double speed;
  double width;
  double height;
  String type; // 'weapon', 'health', 'shield'
  bool isActive = true;
  
  PowerUp({
    required this.x,
    required this.y,
    required this.type,
    this.speed = 3.0,
    this.width = 30,
    this.height = 30,
  });
  
  // Update power-up position
  void update() {
    y += speed; // Move downward
  }
  
  // Check if power-up is off screen
  bool isOffScreen(double screenHeight) {
    return y > screenHeight;
  }
}

// Explosion animation
class Explosion {
  double x;
  double y;
  double size;
  int frameCount = 0;
  int maxFrames = 30;
  bool isActive = true;
  
  Explosion({
    required this.x,
    required this.y,
    this.size = 60,
  });
  
  // Update explosion animation
  void update() {
    frameCount++;
    if (frameCount >= maxFrames) {
      isActive = false;
    }
  }
  
  // Get current animation phase (0-1)
  double getPhase() {
    return frameCount / maxFrames;
  }
}

// Main game model
class SpaceShooterModel {
  // Game dimensions
  final double screenWidth;
  final double screenHeight;
  
  // Game state
  bool isGameOver = false;
  bool isPaused = false;
  int score = 0;
  int highScore;
  int difficulty;
  int level = 1;
  int enemiesDefeated = 0;
  
  // Game objects
  late Spacecraft player;
  List<Projectile> projectiles = [];
  List<Enemy> enemies = [];
  List<PowerUp> powerUps = [];
  List<Explosion> explosions = [];
  
  // Game timing
  int frameCount = 0;
  int enemySpawnRate = 60; // frames between enemy spawns
  int powerUpSpawnRate = 300; // frames between power-up spawns
  
  // Game difficulty settings
  int enemySpeedMultiplier = 1;
  
  // Constructor
  SpaceShooterModel({
    required this.screenWidth,
    required this.screenHeight,
    this.highScore = 0,
    this.difficulty = 1,
  });
  
  // Initialize game
  void initializeGame() {
    // Reset game state
    isGameOver = false;
    isPaused = false;
    score = 0;
    level = 1;
    enemiesDefeated = 0;
    frameCount = 0;
    
    // Clear game objects
    projectiles.clear();
    enemies.clear();
    powerUps.clear();
    explosions.clear();
    
    // Set difficulty-based parameters
    switch (difficulty) {
      case 1: // Easy
        enemySpawnRate = 80;
        powerUpSpawnRate = 250;
        enemySpeedMultiplier = 1;
        break;
      case 2: // Medium
        enemySpawnRate = 60;
        powerUpSpawnRate = 300;
        enemySpeedMultiplier = 2;
        break;
      case 3: // Hard
        enemySpawnRate = 40;
        powerUpSpawnRate = 350;
        enemySpeedMultiplier = 3;
        break;
      default:
        enemySpawnRate = 60;
        powerUpSpawnRate = 300;
        enemySpeedMultiplier = 1;
    }
    
    // Create player spacecraft
    player = Spacecraft(
      x: screenWidth / 2 - 30,
      y: screenHeight - 100,
    );
  }
  
  // Update game state for one frame
  void update() {
    if (isGameOver || isPaused) return;
    
    frameCount++;
    
    // Update player
    player.update(screenWidth);
    
    // Update projectiles
    for (int i = projectiles.length - 1; i >= 0; i--) {
      projectiles[i].update();
      
      // Remove off-screen projectiles
      if (projectiles[i].isOffScreen()) {
        projectiles.removeAt(i);
      }
    }
    
    // Update enemies
    for (int i = enemies.length - 1; i >= 0; i--) {
      enemies[i].update();
      
      // Check for collision with player
      if (_checkCollision(
        enemies[i].x, enemies[i].y, enemies[i].width, enemies[i].height,
        player.x, player.y, player.width, player.height
      )) {
        // Player hit by enemy
        bool isDestroyed = player.takeDamage();
        
        // Create explosion
        explosions.add(Explosion(
          x: enemies[i].x + enemies[i].width / 2,
          y: enemies[i].y + enemies[i].height / 2,
        ));
        
        // Remove enemy
        enemies.removeAt(i);
        
        // Check if player is destroyed
        if (isDestroyed) {
          _handleGameOver();
        }
        
        continue;
      }
      
      // Check for collision with projectiles
      bool hitByProjectile = false;
      
      for (int j = projectiles.length - 1; j >= 0; j--) {
        if (_checkCollision(
          enemies[i].x, enemies[i].y, enemies[i].width, enemies[i].height,
          projectiles[j].x, projectiles[j].y, projectiles[j].width, projectiles[j].height
        )) {
          // Enemy hit by projectile
          bool isDestroyed = enemies[i].takeDamage(projectiles[j].power);
          
          // Remove projectile
          projectiles.removeAt(j);
          
          if (isDestroyed) {
            // Add score
            score += enemies[i].scoreValue;
            enemiesDefeated++;
            
            // Create explosion
            explosions.add(Explosion(
              x: enemies[i].x + enemies[i].width / 2,
              y: enemies[i].y + enemies[i].height / 2,
            ));
            
            // Chance to spawn power-up
            if (Random().nextDouble() < 0.1) {
              _spawnPowerUp(enemies[i].x, enemies[i].y);
            }
            
            // Remove enemy
            enemies.removeAt(i);
            hitByProjectile = true;
            break;
          }
        }
      }
      
      if (hitByProjectile) continue;
      
      // Remove off-screen enemies
      if (enemies[i].isOffScreen(screenHeight)) {
        enemies.removeAt(i);
      }
    }
    
    // Update power-ups
    for (int i = powerUps.length - 1; i >= 0; i--) {
      powerUps[i].update();
      
      // Check for collision with player
      if (_checkCollision(
        powerUps[i].x, powerUps[i].y, powerUps[i].width, powerUps[i].height,
        player.x, player.y, player.width, player.height
      )) {
        // Apply power-up effect
        _applyPowerUp(powerUps[i].type);
        
        // Remove power-up
        powerUps.removeAt(i);
        continue;
      }
      
      // Remove off-screen power-ups
      if (powerUps[i].isOffScreen(screenHeight)) {
        powerUps.removeAt(i);
      }
    }
    
    // Update explosions
    for (int i = explosions.length - 1; i >= 0; i--) {
      explosions[i].update();
      
      // Remove finished explosions
      if (!explosions[i].isActive) {
        explosions.removeAt(i);
      }
    }
    
    // Spawn enemies
    if (frameCount % enemySpawnRate == 0) {
      _spawnEnemy();
    }
    
    // Spawn power-ups
    if (frameCount % powerUpSpawnRate == 0) {
      double x = Random().nextDouble() * (screenWidth - 30);
      _spawnPowerUp(x, 0);
    }
    
    // Level up based on enemies defeated
    if (enemiesDefeated >= level * 10) {
      level++;
      enemySpawnRate = max(20, enemySpawnRate - 5);
    }
  }
  
  // Fire player weapon
  void firePlayerWeapon() {
    if (!player.canFire()) return;
    
    player.fire();
    
    // Create projectiles based on weapon level
    switch (player.weaponLevel) {
      case 1:
        // Single projectile
        projectiles.add(Projectile(
          x: player.x + player.width / 2 - 4,
          y: player.y,
        ));
        break;
      case 2:
        // Double projectile
        projectiles.add(Projectile(
          x: player.x + player.width / 4 - 4,
          y: player.y,
        ));
        projectiles.add(Projectile(
          x: player.x + player.width * 3/4 - 4,
          y: player.y,
        ));
        break;
      case 3:
        // Triple projectile
        projectiles.add(Projectile(
          x: player.x + player.width / 2 - 4,
          y: player.y,
        ));
        projectiles.add(Projectile(
          x: player.x + player.width / 4 - 4,
          y: player.y + 10,
        ));
        projectiles.add(Projectile(
          x: player.x + player.width * 3/4 - 4,
          y: player.y + 10,
        ));
        break;
    }
  }
  
  // Spawn a new enemy
  void _spawnEnemy() {
    // Random position
    double x = Random().nextDouble() * (screenWidth - 50);
    
    // Random enemy type
    List<String> enemyTypes = ['basic', 'fast', 'tanky'];
    String type = enemyTypes[Random().nextInt(enemyTypes.length)];
    
    Enemy enemy;
    
    switch (type) {
      case 'fast':
        enemy = Enemy(
          x: x,
          y: 0,
          type: type,
          speed: 3.0 * enemySpeedMultiplier,
          width: 40,
          height: 40,
          health: 1,
          scoreValue: 15,
          movesHorizontally: true,
          horizontalSpeed: 2.0,
          horizontalLimit: screenWidth / 4,
        );
        break;
      case 'tanky':
        enemy = Enemy(
          x: x,
          y: 0,
          type: type,
          speed: 1.0 * enemySpeedMultiplier,
          width: 60,
          height: 60,
          health: 3,
          scoreValue: 25,
          movesHorizontally: false,
        );
        break;
      case 'basic':
      default:
        enemy = Enemy(
          x: x,
          y: 0,
          type: type,
          speed: 2.0 * enemySpeedMultiplier,
          width: 50,
          height: 50,
          health: 2,
          scoreValue: 10,
          movesHorizontally: false,
        );
        break;
    }
    
    enemies.add(enemy);
  }
  
  // Spawn a power-up
  void _spawnPowerUp(double x, double y) {
    // Random power-up type
    List<String> powerUpTypes = ['weapon', 'health', 'shield'];
    String type = powerUpTypes[Random().nextInt(powerUpTypes.length)];
    
    powerUps.add(PowerUp(
      x: x,
      y: y,
      type: type,
    ));
  }
  
  // Apply power-up effect
  void _applyPowerUp(String type) {
    switch (type) {
      case 'weapon':
        player.powerUpWeapon();
        break;
      case 'health':
        player.heal();
        break;
      case 'shield':
        player.isInvincible = true;
        player.invincibilityTimer = 300; // Longer invincibility
        break;
    }
  }
  
  // Check collision between two rectangles
  bool _checkCollision(
    double x1, double y1, double w1, double h1,
    double x2, double y2, double w2, double h2
  ) {
    return (
      x1 < x2 + w2 &&
      x1 + w1 > x2 &&
      y1 < y2 + h2 &&
      y1 + h1 > y2
    );
  }
  
  // Handle game over
  void _handleGameOver() {
    isGameOver = true;
  }
} 