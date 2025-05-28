import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'doodle_jump_controller.dart';
import 'dart:math' as math;

class DoodleJumpScreen extends StatelessWidget {
  const DoodleJumpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(DoodleJumpController());
    
    // Get screen size for game initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      controller.initGame(Size(size.width, size.height - 150)); // Account for app bar and info area
    });
    
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('doodle_jump_clone'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Restart button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.resetGame();
                controller.startGame();
              },
              tooltip: 'restart'.tr,
            ),
            
            // Pause/resume button
            GetBuilder<DoodleJumpController>(
              builder: (ctrl) => IconButton(
                icon: Icon(ctrl.isGameRunning ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (ctrl.isGameRunning) {
                    ctrl.pauseGame();
                  } else {
                    ctrl.resumeGame();
                  }
                },
                tooltip: ctrl.isGameRunning ? 'pause'.tr : 'resume'.tr,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Top info bar
            _buildInfoBar(),
            
            // Main game area
            Expanded(
              child: GetBuilder<DoodleJumpController>(
                builder: (ctrl) {
                  if (!ctrl.isGameRunning && !ctrl.isGameOver) {
                    // Game start screen
                    return _buildStartScreen(context);
                  } else if (ctrl.isGameOver) {
                    // Game over screen
                    return _buildGameOverScreen(context);
                  } else {
                    // Game area
                    return _buildGameArea(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Top info bar
  Widget _buildInfoBar() {
    return GetBuilder<DoodleJumpController>(
      builder: (ctrl) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Current height (score)
              Column(
                children: [
                  Text(
                    'height'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${ctrl.score}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              
              // Highest height
              Column(
                children: [
                  Text(
                    'highest'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${ctrl.highScore}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              
              // Status indicators
              Row(
                children: [
                  // Jetpack indicator
                  if (ctrl.hasJetpack)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.rocket, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'jetpack'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Shield indicator
                  if (ctrl.hasShield)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield, color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'shield'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
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
  
  // Start screen
  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_double_arrow_up,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'doodle_jump_clone'.tr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'doodle_jump_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildRules(context),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Get.find<DoodleJumpController>().startGame();
            },
            child: Text(
              'start'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Rules widget
  Widget _buildRules(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'doodle_jump_rules'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          _buildRuleItem(context, 'doodle_jump_rule_1'.tr),
          _buildRuleItem(context, 'doodle_jump_rule_2'.tr),
          _buildRuleItem(context, 'doodle_jump_rule_3'.tr),
          _buildRuleItem(context, 'doodle_jump_rule_4'.tr),
        ],
      ),
    );
  }
  
  // Rule item
  Widget _buildRuleItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Game area
  Widget _buildGameArea(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Get horizontal movement as normalized value (-1 to 1)
        final double deltaX = details.delta.dx / 10; // Adjust sensitivity
        Get.find<DoodleJumpController>().setHorizontalControl(deltaX);
      },
      onHorizontalDragEnd: (details) {
        // Reset control when touch ends
        Get.find<DoodleJumpController>().setHorizontalControl(0);
      },
      child: Container(
        color: Colors.lightBlue.shade50, // Sky background
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background clouds
            Positioned(
              top: 30,
              left: 40,
              child: _buildCloud(60, Colors.white.withOpacity(0.8)),
            ),
            
            Positioned(
              top: 120,
              right: 60,
              child: _buildCloud(80, Colors.white.withOpacity(0.7)),
            ),
            
            Positioned(
              top: 220,
              left: 120,
              child: _buildCloud(70, Colors.white.withOpacity(0.6)),
            ),
            
            // Game objects
            GetBuilder<DoodleJumpController>(
              builder: (ctrl) {
                List<Widget> gameObjectWidgets = [];
                
                // Draw platforms
                for (var platform in ctrl.platforms) {
                  if (!platform.isActive) continue;
                  
                  gameObjectWidgets.add(
                    Positioned(
                      left: platform.position.dx - platform.width / 2,
                      top: platform.position.dy - 5,
                      child: Container(
                        width: platform.width,
                        height: 10,
                        decoration: BoxDecoration(
                          color: platform.color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  );
                }
                
                // Draw power-ups
                for (var powerUp in ctrl.powerUps) {
                  if (powerUp.isCollected) continue;
                  
                  Widget powerUpWidget;
                  
                  switch (powerUp.type) {
                    case PowerUpType.spring:
                      powerUpWidget = Icon(
                        Icons.height,
                        color: Colors.orange,
                        size: powerUp.size,
                      );
                      break;
                    case PowerUpType.jetpack:
                      powerUpWidget = Icon(
                        Icons.rocket,
                        color: Colors.orange,
                        size: powerUp.size,
                      );
                      break;
                    case PowerUpType.shield:
                      powerUpWidget = Icon(
                        Icons.shield,
                        color: Colors.blue,
                        size: powerUp.size,
                      );
                      break;
                    case PowerUpType.coin:
                      powerUpWidget = Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: powerUp.size,
                      );
                      break;
                  }
                  
                  gameObjectWidgets.add(
                    Positioned(
                      left: powerUp.position.dx - powerUp.size / 2,
                      top: powerUp.position.dy - powerUp.size / 2,
                      child: powerUpWidget,
                    ),
                  );
                }
                
                // Draw obstacles
                for (var obstacle in ctrl.obstacles) {
                  gameObjectWidgets.add(
                    Positioned(
                      left: obstacle.position.dx - obstacle.size / 2,
                      top: obstacle.position.dy - obstacle.size / 2,
                      child: Container(
                        width: obstacle.size,
                        height: obstacle.size,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.dangerous,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                // Draw player
                Widget playerWidget = Container(
                  width: ctrl.playerSize,
                  height: ctrl.playerSize,
                  decoration: BoxDecoration(
                    color: ctrl.hasShield ? Colors.blue.shade300 : Colors.green,
                    shape: BoxShape.circle,
                    border: ctrl.hasShield
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Player face
                      const Center(
                        child: Icon(
                          Icons.face,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      
                      // Jetpack if active
                      if (ctrl.hasJetpack)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: CustomPaint(
                            size: Size(ctrl.playerSize, 20),
                            painter: JetpackFlamePainter(),
                          ),
                        ),
                    ],
                  ),
                );
                
                gameObjectWidgets.add(
                  Positioned(
                    left: ctrl.playerPosition.dx - ctrl.playerSize / 2,
                    top: ctrl.playerPosition.dy - ctrl.playerSize / 2,
                    child: playerWidget,
                  ),
                );
                
                // Control indicators (for debugging)
                /*gameObjectWidgets.add(
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Control: ${ctrl.horizontalControl.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );*/
                
                return Stack(children: gameObjectWidgets);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Cloud widget
  Widget _buildCloud(double size, Color color) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
  
  // Game over screen
  Widget _buildGameOverScreen(BuildContext context) {
    return Container(
      color: Colors.lightBlue.shade50.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'game_over'.tr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              GetBuilder<DoodleJumpController>(
                builder: (ctrl) => Column(
                  children: [
                    Text(
                      '${'height'.tr}: ${ctrl.score}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ctrl.score >= ctrl.highScore) 
                      Text(
                        'new_highscore'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Get.find<DoodleJumpController>().resetGame();
                      Get.find<DoodleJumpController>().startGame();
                    },
                    child: Text(
                      'play_again'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Get.toNamed(AppRoutes.physicsGames);
                    },
                    child: Text(
                      'back'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Jetpack flame painter
class JetpackFlamePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width * 0.3, 0);
    path.lineTo(size.width * 0.1, size.height);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    path.lineTo(size.width * 0.5, 0);
    path.close();
    
    final path2 = Path();
    path2.moveTo(size.width * 0.7, 0);
    path2.lineTo(size.width * 0.9, size.height);
    path2.lineTo(size.width * 0.5, size.height * 0.7);
    path2.lineTo(size.width * 0.5, 0);
    path2.close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
} 