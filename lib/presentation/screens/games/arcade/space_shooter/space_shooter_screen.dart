import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'space_shooter_controller.dart';

class SpaceShooterScreen extends StatelessWidget {
  const SpaceShooterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(SpaceShooterController());
    
    // Get screen dimensions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      // Use the width and available height for the game area
      final topPadding = MediaQuery.of(context).padding.top;
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      final appBarHeight = AppBar().preferredSize.height;
      
      final availableHeight = size.height - topPadding - bottomPadding - appBarHeight - 100; // Space for controls
      
      controller.setScreenDimensions(size.width, availableHeight);
      controller.startNewGame();
    });
    
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.arcadeGames);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('space_shooter'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.arcadeGames),
          ),
          actions: [
            // Difficulty selector
            GetBuilder<SpaceShooterController>(
              builder: (ctrl) => PopupMenuButton<int>(
                icon: const Icon(Icons.tune),
                tooltip: 'difficulty'.tr,
                onSelected: (int value) {
                  ctrl.setDifficulty(value);
                  ctrl.startNewGame();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text('easy'.tr),
                    enabled: ctrl.difficulty.value != 1,
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text('medium'.tr),
                    enabled: ctrl.difficulty.value != 2,
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Text('hard'.tr),
                    enabled: ctrl.difficulty.value != 3,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Game status bar
                _buildStatusBar(),
                
                // Game area
                Expanded(
                  child: _buildGameArea(),
                ),
                
                // Game controls
                _buildControls(),
              ],
            ),
            
            // Game over overlay
            GetBuilder<SpaceShooterController>(
              builder: (ctrl) {
                if (ctrl.isGameOver()) {
                  return _buildGameOverOverlay(context, ctrl);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            
            // Pause overlay
            GetBuilder<SpaceShooterController>(
              builder: (ctrl) {
                if (ctrl.isPaused() && !ctrl.isGameOver()) {
                  return _buildPauseOverlay(context, ctrl);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
        floatingActionButton: GetBuilder<SpaceShooterController>(
          builder: (ctrl) => FloatingActionButton(
            onPressed: () {
              if (ctrl.isGameOver()) {
                ctrl.startNewGame();
              } else {
                ctrl.togglePause();
              }
            },
            child: Icon(
              ctrl.isGameOver()
                  ? Icons.replay
                  : (ctrl.isPaused() ? Icons.play_arrow : Icons.pause),
            ),
          ),
        ),
      ),
    );
  }
  
  // Build the game status bar
  Widget _buildStatusBar() {
    return GetBuilder<SpaceShooterController>(
      builder: (ctrl) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score
              Text(
                '${ctrl.getScore()}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              
              // Level
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${'level'.tr} ${ctrl.getCurrentLevel()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              
              // Health
              Row(
                children: List.generate(
                  ctrl.getPlayerMaxHealth(),
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      Icons.favorite,
                      color: index < ctrl.getPlayerHealth()
                          ? Colors.red
                          : Colors.grey.shade300,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Build the game area
  Widget _buildGameArea() {
    return GetBuilder<SpaceShooterController>(
      builder: (ctrl) {
        return Container(
          color: Colors.black,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Move player based on drag direction
              if (details.delta.dx < 0) {
                // Left
                ctrl.moveLeft(true);
                ctrl.moveRight(false);
              } else if (details.delta.dx > 0) {
                // Right
                ctrl.moveLeft(false);
                ctrl.moveRight(true);
              }
            },
            onHorizontalDragEnd: (details) {
              // Stop movement when drag ends
              ctrl.moveLeft(false);
              ctrl.moveRight(false);
            },
            onTap: () {
              // Manual fire on tap (if auto-fire is disabled)
              if (!ctrl.isAutoFiring.value) {
                ctrl.fireWeapon();
              }
            },
            child: CustomPaint(
              painter: SpaceShooterPainter(
                playerRect: ctrl.getPlayerRect(),
                playerColor: ctrl.spacecraftColor,
                projectiles: ctrl.getProjectileRects(),
                projectileColor: ctrl.projectileColor,
                enemies: ctrl.getEnemyData(),
                enemyColors: ctrl.enemyColors,
                powerUps: ctrl.getPowerUpData(),
                powerUpColors: ctrl.powerUpColors,
                explosions: ctrl.getExplosionData(),
                isPlayerInvincible: ctrl.isPlayerInvincible(),
              ),
              child: Container(),
            ),
          ),
        );
      },
    );
  }
  
  // Build game controls
  Widget _buildControls() {
    return GetBuilder<SpaceShooterController>(
      builder: (ctrl) {
        return Container(
          height: 100,
          color: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              // Auto-fire toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('auto_fire'.tr),
                  Switch(
                    value: ctrl.isAutoFiring.value,
                    onChanged: (value) => ctrl.toggleAutoFire(),
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              
              // Movement controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left button
                  GestureDetector(
                    onLongPress: () => ctrl.moveLeft(true),
                    onLongPressUp: () => ctrl.moveLeft(false),
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.moveLeft(true);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          ctrl.moveLeft(false);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue.shade700,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  // Space between buttons
                  const SizedBox(width: 32),
                  
                  // Fire button (only shown if auto-fire is off)
                  if (!ctrl.isAutoFiring.value)
                    ElevatedButton(
                      onPressed: () => ctrl.fireWeapon(),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.red,
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                      ),
                    ),
                  
                  // Space between buttons
                  if (!ctrl.isAutoFiring.value)
                    const SizedBox(width: 32),
                  
                  // Right button
                  GestureDetector(
                    onLongPress: () => ctrl.moveRight(true),
                    onLongPressUp: () => ctrl.moveRight(false),
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.moveRight(true);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          ctrl.moveRight(false);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue.shade700,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Build game over overlay
  Widget _buildGameOverOverlay(BuildContext context, SpaceShooterController ctrl) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {}, // Boş bir onTap, arka planın tıklanabilir olmasını sağlar
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.rocket_launch,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'game_over'.tr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${'your_score'.tr}: ${ctrl.getScore()}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${'level'.tr}: ${ctrl.getCurrentLevel()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back),
                        label: Text('exit'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => ctrl.startNewGame(),
                        icon: const Icon(Icons.replay),
                        label: Text('play_again'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Build pause overlay
  Widget _buildPauseOverlay(BuildContext context, SpaceShooterController ctrl) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {}, // Boş bir onTap, arka planın tıklanabilir olmasını sağlar
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pause_circle_filled,
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  'game_paused'.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ctrl.togglePause(),
                  icon: const Icon(Icons.play_arrow),
                  label: Text('resume'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for rendering the game
class SpaceShooterPainter extends CustomPainter {
  final Rect playerRect;
  final Color playerColor;
  final List<Rect> projectiles;
  final Color projectileColor;
  final List<Map<String, dynamic>> enemies;
  final Map<String, Color> enemyColors;
  final List<Map<String, dynamic>> powerUps;
  final Map<String, Color> powerUpColors;
  final List<Map<String, dynamic>> explosions;
  final bool isPlayerInvincible;
  
  SpaceShooterPainter({
    required this.playerRect,
    required this.playerColor,
    required this.projectiles,
    required this.projectileColor,
    required this.enemies,
    required this.enemyColors,
    required this.powerUps,
    required this.powerUpColors,
    required this.explosions,
    required this.isPlayerInvincible,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw stars (background)
    _drawStars(canvas, size);
    
    // Draw player spacecraft
    _drawPlayer(canvas);
    
    // Draw projectiles
    _drawProjectiles(canvas);
    
    // Draw enemies
    _drawEnemies(canvas);
    
    // Draw power-ups
    _drawPowerUps(canvas);
    
    // Draw explosions
    _drawExplosions(canvas);
  }
  
  // Draw player spacecraft
  void _drawPlayer(Canvas canvas) {
    final paint = Paint()
      ..color = isPlayerInvincible ? playerColor.withOpacity(0.5) : playerColor;
    
    // Draw spacecraft body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        playerRect,
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Draw spacecraft details (cockpit)
    final cockpitPaint = Paint()
      ..color = Colors.lightBlue.shade300;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(playerRect.center.dx, playerRect.top + 20),
        width: 20,
        height: 30,
      ),
      cockpitPaint,
    );
    
    // Draw spacecraft wings
    final wingPaint = Paint()
      ..color = Colors.red.shade700;
    
    // Left wing
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          playerRect.left - 5,
          playerRect.center.dy,
          10,
          playerRect.height / 2,
        ),
        const Radius.circular(4),
      ),
      wingPaint,
    );
    
    // Right wing
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          playerRect.right - 5,
          playerRect.center.dy,
          10,
          playerRect.height / 2,
        ),
        const Radius.circular(4),
      ),
      wingPaint,
    );
    
    // Draw engine flame
    if (!isPlayerInvincible || (isPlayerInvincible && Random().nextBool())) {
      final flamePaint = Paint()
        ..color = Colors.orange;
      
      canvas.drawPath(
        Path()
          ..moveTo(playerRect.center.dx, playerRect.bottom)
          ..lineTo(playerRect.center.dx - 10, playerRect.bottom + 15)
          ..lineTo(playerRect.center.dx + 10, playerRect.bottom + 15)
          ..close(),
        flamePaint,
      );
    }
  }
  
  // Draw projectiles
  void _drawProjectiles(Canvas canvas) {
    final paint = Paint()
      ..color = projectileColor;
    
    for (final projectile in projectiles) {
      // Draw laser beam
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          projectile,
          const Radius.circular(2),
        ),
        paint,
      );
      
      // Draw glow effect
      final glowPaint = Paint()
        ..color = projectileColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: projectile.center,
            width: projectile.width + 4,
            height: projectile.height + 4,
          ),
          const Radius.circular(4),
        ),
        glowPaint,
      );
    }
  }
  
  // Draw enemies
  void _drawEnemies(Canvas canvas) {
    for (final enemy in enemies) {
      final rect = enemy['rect'] as Rect;
      final type = enemy['type'] as String;
      final health = enemy['health'] as int;
      
      final baseColor = enemyColors[type] ?? Colors.red;
      final paint = Paint()
        ..color = baseColor;
      
      switch (type) {
        case 'basic':
          // Draw basic enemy (triangle shape)
          final path = Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.bottom)
            ..lineTo(rect.left, rect.bottom)
            ..close();
          
          canvas.drawPath(path, paint);
          break;
          
        case 'fast':
          // Draw fast enemy (diamond shape)
          final path = Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.center.dy)
            ..lineTo(rect.center.dx, rect.bottom)
            ..lineTo(rect.left, rect.center.dy)
            ..close();
          
          canvas.drawPath(path, paint);
          break;
          
        case 'tanky':
          // Draw tanky enemy (hexagon shape)
          final path = Path();
          const sides = 6;
          const radius = 30.0;
          const startAngle = 0.0;
          
          for (int i = 0; i < sides; i++) {
            final angle = startAngle + i * (2 * pi / sides);
            final x = rect.center.dx + radius * cos(angle);
            final y = rect.center.dy + radius * sin(angle);
            
            if (i == 0) {
              path.moveTo(x, y);
            } else {
              path.lineTo(x, y);
            }
          }
          
          path.close();
          canvas.drawPath(path, paint);
          break;
          
        default:
          // Fallback to rectangle
          canvas.drawRect(rect, paint);
      }
      
      // Draw health indicator
      if (health > 1) {
        final healthBarWidth = rect.width * 0.8;
        final healthBarHeight = 4.0;
        final maxHealth = type == 'tanky' ? 3 : 2;
        final healthPercentage = health / maxHealth;
        
        // Background
        canvas.drawRect(
          Rect.fromLTWH(
            rect.center.dx - healthBarWidth / 2,
            rect.bottom + 5,
            healthBarWidth,
            healthBarHeight,
          ),
          Paint()..color = Colors.grey.shade800,
        );
        
        // Health
        canvas.drawRect(
          Rect.fromLTWH(
            rect.center.dx - healthBarWidth / 2,
            rect.bottom + 5,
            healthBarWidth * healthPercentage,
            healthBarHeight,
          ),
          Paint()..color = Colors.red,
        );
      }
    }
  }
  
  // Draw power-ups
  void _drawPowerUps(Canvas canvas) {
    for (final powerUp in powerUps) {
      final rect = powerUp['rect'] as Rect;
      final type = powerUp['type'] as String;
      
      final baseColor = powerUpColors[type] ?? Colors.yellow;
      final paint = Paint()
        ..color = baseColor;
      
      // Draw power-up circle
      canvas.drawCircle(
        rect.center,
        rect.width / 2,
        paint,
      );
      
      // Draw power-up icon
      final iconPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      switch (type) {
        case 'weapon':
          // Draw weapon icon (lightning bolt)
          final path = Path()
            ..moveTo(rect.center.dx, rect.top + 8)
            ..lineTo(rect.center.dx - 5, rect.center.dy)
            ..lineTo(rect.center.dx + 3, rect.center.dy)
            ..lineTo(rect.center.dx, rect.bottom - 8);
          
          canvas.drawPath(path, iconPaint);
          break;
          
        case 'health':
          // Draw health icon (plus)
          canvas.drawLine(
            Offset(rect.center.dx - 8, rect.center.dy),
            Offset(rect.center.dx + 8, rect.center.dy),
            iconPaint,
          );
          canvas.drawLine(
            Offset(rect.center.dx, rect.center.dy - 8),
            Offset(rect.center.dx, rect.center.dy + 8),
            iconPaint,
          );
          break;
          
        case 'shield':
          // Draw shield icon (circle)
          canvas.drawCircle(
            rect.center,
            rect.width / 3,
            iconPaint,
          );
          break;
      }
      
      // Draw glow effect
      final glowPaint = Paint()
        ..color = baseColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawCircle(
        rect.center,
        rect.width / 2 + 5,
        glowPaint,
      );
    }
  }
  
  // Draw explosions
  void _drawExplosions(Canvas canvas) {
    for (final explosion in explosions) {
      final x = explosion['x'] as double;
      final y = explosion['y'] as double;
      final size = explosion['size'] as double;
      final phase = explosion['phase'] as double;
      
      // Calculate explosion characteristics based on phase
      final radius = size * (1.0 - phase * 0.5);
      final opacity = 1.0 - phase;
      
      // Outer explosion
      final outerPaint = Paint()
        ..color = Colors.orange.withOpacity(opacity * 0.7)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        outerPaint,
      );
      
      // Inner explosion
      final innerPaint = Paint()
        ..color = Colors.yellow.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        radius * 0.6,
        innerPaint,
      );
      
      // Core
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        radius * 0.3,
        corePaint,
      );
    }
  }
  
  // Draw background stars
  void _drawStars(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent star pattern
    final numStars = 100;
    
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < numStars; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + random.nextDouble() * 1.5;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        starPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(SpaceShooterPainter oldDelegate) => true;
} 