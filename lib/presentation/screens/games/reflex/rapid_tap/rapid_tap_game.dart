import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/services/audio/audio_service.dart';
import 'rapid_tap_controller.dart';

class RapidTapGame extends StatefulWidget {
  const RapidTapGame({super.key});

  @override
  State<RapidTapGame> createState() => _RapidTapGameState();
}

class _RapidTapGameState extends State<RapidTapGame> with WidgetsBindingObserver {
  late RapidTapController controller;
  final random = Random();
  late AudioService audioService;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(RapidTapController());
    audioService = Get.find<AudioService>();
    
    // Otomatik olarak oyunu başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<RapidTapController>();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      controller.pauseGame();
    }
  }
  
  void _showInstructions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hızlı Tıklama Yarışı', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nasıl Oynanır:'),
              SizedBox(height: 8),
              Text('1. Rastgele beliren dairelere hızlıca tıkla'),
              Text('2. Her doğru tıklama için puan kazan'),
              Text('3. Kaçırdığın hedefler için puan kaybedersin'),
              Text('4. Süre bittiğinde oyun sona erer'),
              SizedBox(height: 16),
              Text('Hazır mısın?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.startGame();
              },
              child: Text('BAŞLA'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.isPlaying.value) {
          controller.pauseGame();
          final result = await _showExitConfirmation();
          if (result == false) {
            controller.resumeGame();
            return false;
          }
        }
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('rapid_tap'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (controller.isPlaying.value) {
                controller.pauseGame();
                _showExitConfirmation().then((exit) {
                  if (exit) {
                    Navigator.of(context).pop();
                  } else {
                    controller.resumeGame();
                  }
                });
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            Obx(() => controller.isPlaying.value
              ? IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {
                    controller.pauseGame();
                    _showPauseMenu();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    if (controller.gameEnded.value) {
                      controller.resetGame();
                    }
                    controller.startGame();
                  },
                ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Skor ve süre paneli
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Skor:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Obx(() => Text(
                          '${controller.score.value}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        )),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Süre:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Obx(() => Text(
                          '${controller.remainingTime.value}s',
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: controller.remainingTime.value <= 10 ? Colors.red : Colors.black,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Oyun alanı
              Expanded(
                child: Stack(
                  children: [
                    // Arka plan
                    Container(color: Colors.white),
                    
                    // Hedefler
                    Obx(() => Stack(
                      children: controller.targets.map((target) {
                        return Positioned(
                          left: target.x,
                          top: target.y,
                          child: GestureDetector(
                            onTap: () {
                              if (controller.isPlaying.value) {
                                controller.hitTarget(target);
                                // Ses dosyasınız olmadığı için, burayı şimdilik yorum satırı yapıyorum
                                // audioService.playSound('sounds/tap_sound.mp3');
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: target.size,
                              height: target.size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getTargetColor(target.points),
                              ),
                              child: Center(
                                child: Text(
                                  '+${target.points}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                    
                    // Oyun sonu ekranı
                    Obx(() => controller.gameEnded.value
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'OYUN BİTTİ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Skorunuz: ${controller.score.value}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  'En Yüksek Skor: ${controller.highScore.value}',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.resetGame();
                                    controller.startGame();
                                  },
                                  child: const Text('Tekrar Oyna'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()
                    ),
                    
                    // Duraklama ekranı
                    Obx(() => controller.isPaused.value && !controller.gameEnded.value
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'DURAKLATILDI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.resumeGame();
                                  },
                                  child: const Text('Devam Et'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getTargetColor(int points) {
    switch (points) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.purple;
    }
  }
  
  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış'),
        content: const Text('Oyundan çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  void _showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Oyun Duraklatıldı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skor: ${controller.score.value}'),
            Text('Kalan Süre: ${controller.remainingTime.value} saniye'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.back(); // Oyundan çık
            },
            child: const Text('Çıkış'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.resumeGame();
            },
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }
} 