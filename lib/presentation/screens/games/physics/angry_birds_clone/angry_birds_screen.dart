import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'angry_birds_controller.dart';
import 'dart:math' as math;

class AngryBirdsScreen extends StatelessWidget {
  const AngryBirdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    final controller = Get.put(AngryBirdsController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('angry_birds_clone'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Seviye info
            GetBuilder<AngryBirdsController>(
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
            
            // Yeniden başlatma butonu
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.startGame(),
              tooltip: 'restart'.tr,
            ),
            
            // Pause/resume butonu
            GetBuilder<AngryBirdsController>(
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
            // Üst bilgi alanı
            _buildInfoBar(),
            
            // Ana oyun alanı
            Expanded(
              child: GetBuilder<AngryBirdsController>(
                builder: (ctrl) {
                  if (!ctrl.isGameRunning && !ctrl.isGameOver && !ctrl.levelCompleted) {
                    // Oyun başlamadan önce başlangıç ekranı
                    return _buildStartScreen(context);
                  } else if (ctrl.isGameOver) {
                    // Oyun bitti ekranı
                    return _buildGameOverScreen(context);
                  } else if (ctrl.levelCompleted) {
                    // Seviye tamamlandı ekranı
                    return _buildLevelCompletedScreen(context);
                  } else {
                    // Oyun alanı
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
  
  // Üst bilgi çubuğu
  Widget _buildInfoBar() {
    return GetBuilder<AngryBirdsController>(
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
              // Skor
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
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              
              // Kuş sayısı
              Column(
                children: [
                  Text(
                    'birds_remaining'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: List.generate(ctrl.birdsRemaining + (ctrl.currentBird != null ? 1 : 0), (index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(Icons.flutter_dash, color: Colors.red, size: 20),
                      );
                    }),
                  ),
                ],
              ),
              
              // Yüksek skor
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
  
  // Başlangıç ekranı
  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flutter_dash,
            size: 100,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            'angry_birds_clone'.tr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'angry_birds_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Get.find<AngryBirdsController>().startGame();
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
  
  // Oyun alanı
  Widget _buildGameArea(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        Get.find<AngryBirdsController>().startAiming(details.localPosition);
      },
      onPanUpdate: (details) {
        Get.find<AngryBirdsController>().updateAiming(details.localPosition);
      },
      onPanEnd: (_) {
        Get.find<AngryBirdsController>().launchBird();
      },
      child: Container(
        color: Colors.lightBlue.shade100, // Gökyüzü rengi
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Zemin
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                color: Colors.brown.shade300,
              ),
            ),
            
            // Bulutlar (dekoratif)
            Positioned(
              top: 50,
              left: 100,
              child: _buildCloud(60, Colors.white.withOpacity(0.8)),
            ),
            
            Positioned(
              top: 100,
              right: 80,
              child: _buildCloud(80, Colors.white.withOpacity(0.7)),
            ),
            
            // Oyun nesneleri
            GetBuilder<AngryBirdsController>(
              builder: (ctrl) {
                List<Widget> gameObjectWidgets = [];
                
                // Kamera ofseti ile pozisyonları ayarla
                double offsetX = -ctrl.cameraOffset;
                
                // Sapan
                gameObjectWidgets.add(
                  Positioned(
                    left: ctrl.slingPosition.dx + offsetX,
                    top: ctrl.slingPosition.dy - 50,
                    child: Image.asset(
                      'assets/images/slingshot.png',
                      width: 50,
                      height: 70,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 70,
                        color: Colors.brown.shade700,
                      ),
                    ),
                  ),
                );
                
                // Sapan ipi (geri)
                if (ctrl.isAiming && ctrl.touchPosition != null) {
                  gameObjectWidgets.add(
                    CustomPaint(
                      painter: SlingshotRubberPainter(
                        start: Offset(ctrl.slingPosition.dx + offsetX, ctrl.slingPosition.dy),
                        end: Offset(ctrl.touchPosition!.dx, ctrl.touchPosition!.dy),
                        color: Colors.brown.shade900,
                        strokeWidth: 4,
                      ),
                    ),
                  );
                }
                
                // Mevcut kuş
                if (ctrl.currentBird != null) {
                  double birdX = ctrl.currentBird!.position.dx + offsetX;
                  double birdY = ctrl.currentBird!.position.dy;
                  
                  gameObjectWidgets.add(
                    Positioned(
                      left: birdX - ctrl.currentBird!.size / 2,
                      top: birdY - ctrl.currentBird!.size / 2,
                      child: Transform.rotate(
                        angle: ctrl.currentBird!.rotation,
                        child: Container(
                          width: ctrl.currentBird!.size,
                          height: ctrl.currentBird!.size,
                          decoration: BoxDecoration(
                            color: ctrl.currentBird!.color,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.flutter_dash,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                // Diğer oyun nesneleri
                for (var obj in ctrl.gameObjects) {
                  if (obj.isDestroyed) continue;
                  
                  double objX = obj.position.dx + offsetX;
                  double objY = obj.position.dy;
                  
                  Widget objectWidget;
                  
                  // Nesne tipine göre görünüm oluştur
                  switch (obj.type) {
                    case ObjectType.pig:
                      objectWidget = Container(
                        width: obj.size,
                        height: obj.size,
                        decoration: BoxDecoration(
                          color: obj.color,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sentiment_very_satisfied,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                      break;
                    case ObjectType.wood:
                      objectWidget = Container(
                        width: obj.size,
                        height: obj.size,
                        decoration: BoxDecoration(
                          color: obj.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                      break;
                    case ObjectType.stone:
                      objectWidget = Container(
                        width: obj.size,
                        height: obj.size,
                        decoration: BoxDecoration(
                          color: obj.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                      break;
                    case ObjectType.glass:
                      objectWidget = Container(
                        width: obj.size,
                        height: obj.size,
                        decoration: BoxDecoration(
                          color: obj.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                      break;
                    default:
                      objectWidget = Container(
                        width: obj.size,
                        height: obj.size,
                        color: obj.color,
                      );
                  }
                  
                  gameObjectWidgets.add(
                    Positioned(
                      left: objX - obj.size / 2,
                      top: objY - obj.size / 2,
                      child: Transform.rotate(
                        angle: obj.rotation,
                        child: objectWidget,
                      ),
                    ),
                  );
                }
                
                // Sapan ipi (ön)
                if (ctrl.isAiming && ctrl.touchPosition != null) {
                  gameObjectWidgets.add(
                    CustomPaint(
                      painter: SlingshotRubberPainter(
                        start: Offset(ctrl.slingPosition.dx + 20 + offsetX, ctrl.slingPosition.dy),
                        end: Offset(ctrl.touchPosition!.dx, ctrl.touchPosition!.dy),
                        color: Colors.brown.shade900,
                        strokeWidth: 4,
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
  
  // Bulut widget'ı
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
  
  // Oyun bitti ekranı
  Widget _buildGameOverScreen(BuildContext context) {
    return Container(
      color: Colors.lightBlue.shade100.withOpacity(0.7),
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
              GetBuilder<AngryBirdsController>(
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
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Get.find<AngryBirdsController>().startGame();
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
  
  // Seviye tamamlandı ekranı
  Widget _buildLevelCompletedScreen(BuildContext context) {
    return Container(
      color: Colors.lightBlue.shade100.withOpacity(0.7),
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
              GetBuilder<AngryBirdsController>(
                builder: (ctrl) => Text(
                  '${'score'.tr}: ${ctrl.score}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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

// Sapan ipi için custom painter
class SlingshotRubberPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  
  SlingshotRubberPainter({
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
  bool shouldRepaint(covariant SlingshotRubberPainter oldDelegate) {
    return start != oldDelegate.start || 
           end != oldDelegate.end || 
           color != oldDelegate.color || 
           strokeWidth != oldDelegate.strokeWidth;
  }
} 