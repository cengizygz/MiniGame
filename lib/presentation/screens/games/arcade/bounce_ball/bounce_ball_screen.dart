import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'bounce_ball_controller.dart';

class BounceBallScreen extends StatelessWidget {
  const BounceBallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(BounceBallController());
    
    // Get screen dimensions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final topPadding = MediaQuery.of(context).padding.top;
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      final appBarHeight = AppBar().preferredSize.height;
      
      // Space for score bar
      final availableHeight = size.height - topPadding - bottomPadding - appBarHeight - 80;
      
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
          title: Text('bounce_ball'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.arcadeGames),
          ),
          actions: [
            // Difficulty selector
            GetBuilder<BounceBallController>(
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
        body: Column(
          children: [
            // Score & Level bar
            _buildScoreBar(),
            
            // Game area
            Expanded(
              child: _buildGameArea(),
            ),
          ],
        ),
        floatingActionButton: GetBuilder<BounceBallController>(
          builder: (ctrl) => FloatingActionButton(
            onPressed: () {
              if (ctrl.isGameOver.value) {
                ctrl.startNewGame();
              } else {
                ctrl.togglePause();
              }
            },
            child: Icon(
              ctrl.isGameOver.value
                  ? Icons.replay
                  : (ctrl.isPaused.value ? Icons.play_arrow : Icons.pause),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildScoreBar() {
    return GetBuilder<BounceBallController>(
      builder: (ctrl) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.blue.withOpacity(0.3), width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'score'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${ctrl.score.value}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              
              // Level
              Column(
                children: [
                  Text(
                    'level'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ctrl.level.value}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Lives
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'lives'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.favorite,
                          color: index < ctrl.lives.value ? Colors.red : Colors.grey.shade300,
                          size: 20,
                        ),
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
  
  Widget _buildGameArea() {
    return GetBuilder<BounceBallController>(
      builder: (ctrl) {
        return Stack(
          children: [
            // Game canvas
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (!ctrl.isPaused.value && !ctrl.isGameOver.value) {
                  ctrl.movePaddle(details.delta.dx);
                }
              },
              onTap: () {
                if (!ctrl.isGameStarted.value && !ctrl.isPaused.value && !ctrl.isGameOver.value) {
                  ctrl.startBall();
                }
              },
              child: Container(
                color: Colors.grey.shade100,
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: BounceBallPainter(
                    ballPosition: ctrl.ballPosition,
                    ballRadius: ctrl.ballRadius,
                    paddlePosition: ctrl.paddlePosition,
                    paddleWidth: ctrl.paddleWidth,
                    paddleHeight: ctrl.paddleHeight,
                    bricks: ctrl.bricks,
                    powerUps: ctrl.activePowerUps,
                  ),
                ),
              ),
            ),
            
            // Game start message
            if (!ctrl.isGameStarted.value && !ctrl.isGameOver.value && !ctrl.isPaused.value)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'tap_to_start'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // Game over overlay
            if (ctrl.isGameOver.value)
              _buildGameOverOverlay(ctrl),
            
            // Pause overlay
            if (ctrl.isPaused.value && !ctrl.isGameOver.value)
              _buildPauseOverlay(ctrl),
          ],
        );
      },
    );
  }
  
  Widget _buildGameOverOverlay(BounceBallController ctrl) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {},
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
                    Icons.sports_basketball,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'game_over'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${'your_score'.tr}: ${ctrl.score.value}',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '${'level'.tr}: ${ctrl.level.value}',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
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
  
  Widget _buildPauseOverlay(BounceBallController ctrl) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {},
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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

class BounceBallPainter extends CustomPainter {
  final Offset ballPosition;
  final double ballRadius;
  final Offset paddlePosition;
  final double paddleWidth;
  final double paddleHeight;
  final List<Map<String, dynamic>> bricks;
  final List<Map<String, dynamic>> powerUps;
  
  BounceBallPainter({
    required this.ballPosition,
    required this.ballRadius,
    required this.paddlePosition,
    required this.paddleWidth,
    required this.paddleHeight,
    required this.bricks,
    required this.powerUps,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid lines
    _drawGridLines(canvas, size);
    
    // Draw ball
    _drawBall(canvas);
    
    // Draw paddle
    _drawPaddle(canvas);
    
    // Draw bricks
    _drawBricks(canvas);
    
    // Draw power-ups
    _drawPowerUps(canvas);
  }
  
  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;
    
    // Vertical lines
    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    
    // Horizontal lines
    for (int i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }
  
  void _drawBall(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    // Draw ball
    canvas.drawCircle(ballPosition, ballRadius, paint);
    
    // Add gradient/shine effect
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.8,
      colors: [
        Colors.white.withOpacity(0.6),
        Colors.red.withOpacity(0.1),
      ],
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(
          center: ballPosition,
          radius: ballRadius,
        ),
      );
    
    canvas.drawCircle(ballPosition, ballRadius, gradientPaint);
  }
  
  void _drawPaddle(Canvas canvas) {
    // Paddle main body
    final paddleRect = Rect.fromCenter(
      center: paddlePosition,
      width: paddleWidth,
      height: paddleHeight,
    );
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        paddleRect.translate(0, 4),
        const Radius.circular(10),
      ),
      shadowPaint,
    );
    
    // Draw paddle with gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue.shade300,
        Colors.blue.shade700,
      ],
    );
    
    final paddlePaint = Paint()
      ..shader = gradient.createShader(paddleRect);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        paddleRect,
        const Radius.circular(10),
      ),
      paddlePaint,
    );
    
    // Add shine/highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          paddleRect.left + 5,
          paddleRect.top + 2,
          paddleRect.width - 10,
          paddleRect.height * 0.3,
        ),
        const Radius.circular(5),
      ),
      highlightPaint,
    );
  }
  
  void _drawBricks(Canvas canvas) {
    for (final brick in bricks) {
      final rect = brick['rect'] as Rect;
      final strength = brick['strength'] as int;
      
      // Skip destroyed bricks
      if (strength <= 0) continue;
      
      // Determine color based on strength
      Color brickColor;
      switch (strength) {
        case 1:
          brickColor = Colors.blue.shade400;
          break;
        case 2:
          brickColor = Colors.green.shade500;
          break;
        case 3:
          brickColor = Colors.orange;
          break;
        default:
          brickColor = Colors.red.shade700;
      }
      
      // Draw shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.translate(0, 2),
          const Radius.circular(4),
        ),
        shadowPaint,
      );
      
      // Draw brick
      final brickPaint = Paint()
        ..color = brickColor;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(4),
        ),
        brickPaint,
      );
      
      // Add highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + 2,
            rect.top + 2,
            rect.width - 4,
            rect.height * 0.3,
          ),
          const Radius.circular(2),
        ),
        highlightPaint,
      );
      
      // Add strength indicator for stronger bricks
      if (strength > 1) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: strength.toString(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            rect.center.dx - textPainter.width / 2,
            rect.center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }
  
  void _drawPowerUps(Canvas canvas) {
    for (final powerUp in powerUps) {
      final position = powerUp['position'] as Offset;
      final type = powerUp['type'] as String;
      final size = powerUp['size'] as double;
      
      // Determine color based on type
      Color color;
      IconData icon;
      
      switch (type) {
        case 'expand':
          color = Colors.blue;
          icon = Icons.width_wide;
          break;
        case 'shrink':
          color = Colors.red;
          icon = Icons.width_normal;
          break;
        case 'slow':
          color = Colors.green;
          icon = Icons.speed;
          break;
        case 'fast':
          color = Colors.orange;
          icon = Icons.flash_on;
          break;
        case 'multiball':
          color = Colors.purple;
          icon = Icons.bubble_chart;
          break;
        case 'extralife':
          color = Colors.pink;
          icon = Icons.favorite;
          break;
        default:
          color = Colors.yellow;
          icon = Icons.star;
      }
      
      // Draw power-up capsule
      final rect = Rect.fromCenter(
        center: position,
        width: size,
        height: size * 1.5,
      );
      
      // Shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.translate(0, 2),
          const Radius.circular(8),
        ),
        shadowPaint,
      );
      
      // Main capsule
      final capsulePaint = Paint()
        ..color = color.withOpacity(0.8);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(8),
        ),
        capsulePaint,
      );
      
      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.4);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + 3,
            rect.top + 3,
            rect.width - 6,
            rect.height * 0.4,
          ),
          const Radius.circular(6),
        ),
        highlightPaint,
      );
      
      // Draw icon (simplified)
      final iconPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      // Use simple shapes instead of icons
      switch (type) {
        case 'expand':
          // Horizontal line with outward arrows
          canvas.drawLine(
            Offset(position.dx - size * 0.3, position.dy),
            Offset(position.dx + size * 0.3, position.dy),
            iconPaint..strokeWidth = 2,
          );
          // Left arrow
          canvas.drawPath(
            Path()
              ..moveTo(position.dx - size * 0.3, position.dy)
              ..lineTo(position.dx - size * 0.4, position.dy - size * 0.1)
              ..lineTo(position.dx - size * 0.4, position.dy + size * 0.1)
              ..close(),
            iconPaint,
          );
          // Right arrow
          canvas.drawPath(
            Path()
              ..moveTo(position.dx + size * 0.3, position.dy)
              ..lineTo(position.dx + size * 0.4, position.dy - size * 0.1)
              ..lineTo(position.dx + size * 0.4, position.dy + size * 0.1)
              ..close(),
            iconPaint,
          );
          break;
          
        case 'shrink':
          // Horizontal line with inward arrows
          canvas.drawLine(
            Offset(position.dx - size * 0.3, position.dy),
            Offset(position.dx + size * 0.3, position.dy),
            iconPaint..strokeWidth = 2,
          );
          // Left arrow
          canvas.drawPath(
            Path()
              ..moveTo(position.dx - size * 0.3, position.dy)
              ..lineTo(position.dx - size * 0.2, position.dy - size * 0.1)
              ..lineTo(position.dx - size * 0.2, position.dy + size * 0.1)
              ..close(),
            iconPaint,
          );
          // Right arrow
          canvas.drawPath(
            Path()
              ..moveTo(position.dx + size * 0.3, position.dy)
              ..lineTo(position.dx + size * 0.2, position.dy - size * 0.1)
              ..lineTo(position.dx + size * 0.2, position.dy + size * 0.1)
              ..close(),
            iconPaint,
          );
          break;
          
        case 'slow':
          // Turtle-like symbol
          canvas.drawCircle(
            Offset(position.dx, position.dy),
            size * 0.25,
            iconPaint,
          );
          break;
          
        case 'fast':
          // Lightning bolt
          canvas.drawPath(
            Path()
              ..moveTo(position.dx, position.dy - size * 0.3)
              ..lineTo(position.dx - size * 0.15, position.dy)
              ..lineTo(position.dx, position.dy)
              ..lineTo(position.dx, position.dy + size * 0.3)
              ..lineTo(position.dx + size * 0.15, position.dy)
              ..lineTo(position.dx, position.dy)
              ..close(),
            iconPaint,
          );
          break;
          
        case 'multiball':
          // Multiple small circles
          canvas.drawCircle(
            Offset(position.dx - size * 0.15, position.dy - size * 0.15),
            size * 0.1,
            iconPaint,
          );
          canvas.drawCircle(
            Offset(position.dx + size * 0.15, position.dy - size * 0.15),
            size * 0.1,
            iconPaint,
          );
          canvas.drawCircle(
            Offset(position.dx, position.dy + size * 0.15),
            size * 0.1,
            iconPaint,
          );
          break;
          
        case 'extralife':
          // Heart shape
          canvas.drawPath(
            Path()
              ..moveTo(position.dx, position.dy + size * 0.1)
              ..cubicTo(
                position.dx + size * 0.25, position.dy - size * 0.3,
                position.dx + size * 0.4, position.dy, 
                position.dx, position.dy + size * 0.2,
              )
              ..cubicTo(
                position.dx - size * 0.4, position.dy,
                position.dx - size * 0.25, position.dy - size * 0.3,
                position.dx, position.dy + size * 0.1,
              ),
            iconPaint,
          );
          break;
          
        default:
          // Star
          canvas.drawCircle(
            position,
            size * 0.2,
            iconPaint,
          );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant BounceBallPainter oldDelegate) => true;
} 