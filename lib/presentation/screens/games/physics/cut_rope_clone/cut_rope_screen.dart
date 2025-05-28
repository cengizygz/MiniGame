import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'cut_rope_controller.dart';
import 'dart:math' as math;

class CutRopeScreen extends StatelessWidget {
  const CutRopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(CutRopeController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('cut_rope_clone'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Level info
            GetBuilder<CutRopeController>(
              builder: (ctrl) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'level'.tr + ': ${ctrl.currentLevel}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            
            // Restart button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.resetLevel(),
              tooltip: 'restart'.tr,
            ),
            
            // Pause/resume button
            GetBuilder<CutRopeController>(
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
              child: GetBuilder<CutRopeController>(
                builder: (ctrl) {
                  if (!ctrl.isGameRunning && !ctrl.isGameOver && !ctrl.levelCompleted) {
                    // Game start screen
                    return _buildStartScreen(context);
                  } else if (ctrl.isGameOver) {
                    // Game over screen
                    return _buildGameOverScreen(context);
                  } else if (ctrl.levelCompleted) {
                    // Level completed screen
                    return _buildLevelCompletedScreen(context);
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
    return GetBuilder<CutRopeController>(
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
              // Score
              Column(
                children: [
                  Text(
                    'score'.tr,
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
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              // Stars collected
              Column(
                children: [
                  Text(
                    'stars_collected'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(3, (index) {
                        return Icon(
                          Icons.star,
                          color: index < ctrl.starsCollected 
                              ? Colors.amber 
                              : Colors.grey.shade400,
                          size: 20,
                        );
                      }),
                    ],
                  ),
                ],
              ),
              
              // High score
              Column(
                children: [
                  Text(
                    'high_score'.tr,
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
                      color: Colors.amber,
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
            Icons.cut,
            size: 100,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            'cut_rope_clone'.tr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'cut_rope_desc'.tr,
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
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Get.find<CutRopeController>().startGame();
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
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'cut_rope_rules'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          _buildRuleItem(context, 'cut_rope_rule_1'.tr),
          _buildRuleItem(context, 'cut_rope_rule_2'.tr),
          _buildRuleItem(context, 'cut_rope_rule_3'.tr),
          _buildRuleItem(context, 'cut_rope_rule_4'.tr),
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
            color: Colors.green.shade600,
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
      onPanStart: (details) {
        Get.find<CutRopeController>().onTouchStart(details.localPosition);
      },
      onPanUpdate: (details) {
        Get.find<CutRopeController>().onTouchMove(details.localPosition);
      },
      onPanEnd: (_) {
        Get.find<CutRopeController>().onTouchEnd();
      },
      child: Container(
        color: Colors.lightBlue.shade50, // Sky background
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background decorations
            Positioned(
              top: 30,
              left: 40,
              child: _buildCloud(60, Colors.white.withOpacity(0.8)),
            ),
            
            Positioned(
              top: 70,
              right: 60,
              child: _buildCloud(80, Colors.white.withOpacity(0.7)),
            ),
            
            // Game objects
            GetBuilder<CutRopeController>(
              builder: (ctrl) {
                List<Widget> gameObjectWidgets = [];
                
                // Draw ropes
                for (var rope in ctrl.ropes) {
                  if (rope.isCut) continue;
                  
                  // Calculate rope end position
                  double ropeEndX = rope.anchorPoint.dx + math.sin(rope.angle) * rope.length;
                  double ropeEndY = rope.anchorPoint.dy + math.cos(rope.angle) * rope.length;
                  
                  // Add rope
                  gameObjectWidgets.add(
                    CustomPaint(
                      painter: RopePainter(
                        start: rope.anchorPoint,
                        end: Offset(ropeEndX, ropeEndY),
                        color: Colors.brown.shade800,
                        strokeWidth: 5,
                      ),
                    ),
                  );
                  
                  // Add anchor point
                  gameObjectWidgets.add(
                    Positioned(
                      left: rope.anchorPoint.dx - 5,
                      top: rope.anchorPoint.dy - 5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade700,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }
                
                // Draw stars
                for (var star in ctrl.stars) {
                  if (star.isCollected) continue;
                  
                  gameObjectWidgets.add(
                    Positioned(
                      left: star.position.dx - star.size / 2,
                      top: star.position.dy - star.size / 2,
                      child: Container(
                        width: star.size,
                        height: star.size,
                        child: const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  );
                }
                
                // Draw obstacles
                for (var obstacle in ctrl.obstacles) {
                  Widget obstacleWidget;
                  
                  switch (obstacle.type) {
                    case ObjectType.spikes:
                      obstacleWidget = CustomPaint(
                        size: Size(obstacle.size, obstacle.size),
                        painter: SpikesPainter(),
                      );
                      break;
                    case ObjectType.bubble:
                      obstacleWidget = Container(
                        width: obstacle.size,
                        height: obstacle.size,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_upward,
                            color: Colors.blue,
                          ),
                        ),
                      );
                      break;
                    case ObjectType.airCushion:
                      obstacleWidget = Container(
                        width: obstacle.size,
                        height: obstacle.size,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.air,
                            color: Colors.purple,
                          ),
                        ),
                      );
                      break;
                    default:
                      obstacleWidget = Container(
                        width: obstacle.size,
                        height: obstacle.size,
                        color: Colors.red,
                      );
                  }
                  
                  gameObjectWidgets.add(
                    Positioned(
                      left: obstacle.position.dx - obstacle.size / 2,
                      top: obstacle.position.dy - obstacle.size / 2,
                      child: obstacleWidget,
                    ),
                  );
                }
                
                // Draw creature
                if (ctrl.creature != null) {
                  gameObjectWidgets.add(
                    Positioned(
                      left: ctrl.creature!.position.dx - ctrl.creature!.size / 2,
                      top: ctrl.creature!.position.dy - ctrl.creature!.size / 2,
                      child: Container(
                        width: ctrl.creature!.size,
                        height: ctrl.creature!.size,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.face,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                // Draw candy
                if (ctrl.candy != null) {
                  gameObjectWidgets.add(
                    Positioned(
                      left: ctrl.candy!.position.dx - ctrl.candy!.size / 2,
                      top: ctrl.candy!.position.dy - ctrl.candy!.size / 2,
                      child: Container(
                        width: ctrl.candy!.size,
                        height: ctrl.candy!.size,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }
                
                // Draw cut path
                if (ctrl.cutPath.isNotEmpty) {
                  gameObjectWidgets.add(
                    CustomPaint(
                      painter: CutPathPainter(
                        points: ctrl.cutPath,
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  );
                }
                
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
              GetBuilder<CutRopeController>(
                builder: (ctrl) => Column(
                  children: [
                    Text(
                      '${'final_score'.tr}: ${ctrl.score}',
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
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Get.find<CutRopeController>().resetLevel();
                      Get.find<CutRopeController>().resumeGame();
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
  
  // Level completed screen
  Widget _buildLevelCompletedScreen(BuildContext context) {
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
                'level_completed'.tr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              GetBuilder<CutRopeController>(
                builder: (ctrl) => Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(3, (index) {
                          return Icon(
                            Icons.star,
                            color: index < ctrl.starsCollected 
                                ? Colors.amber 
                                : Colors.grey.shade400,
                            size: 30,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${'level_score'.tr}: ${ctrl.score}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'next_level_soon'.tr,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Rope painter
class RopePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  
  RopePainter({
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(start, end, paint);
  }
  
  @override
  bool shouldRepaint(covariant RopePainter oldDelegate) {
    return start != oldDelegate.start || 
           end != oldDelegate.end || 
           color != oldDelegate.color || 
           strokeWidth != oldDelegate.strokeWidth;
  }
}

// Cut path painter
class CutPathPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  
  CutPathPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CutPathPainter oldDelegate) {
    return points != oldDelegate.points || 
           color != oldDelegate.color || 
           strokeWidth != oldDelegate.strokeWidth;
  }
}

// Spikes painter
class SpikesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Draw triangular spikes
    final spikeCount = 5;
    final spikeWidth = size.width / spikeCount;
    
    for (int i = 0; i < spikeCount; i++) {
      final startX = i * spikeWidth;
      final middleX = startX + spikeWidth / 2;
      final endX = startX + spikeWidth;
      
      path.moveTo(startX, size.height);
      path.lineTo(middleX, 0);
      path.lineTo(endX, size.height);
      path.close();
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
} 