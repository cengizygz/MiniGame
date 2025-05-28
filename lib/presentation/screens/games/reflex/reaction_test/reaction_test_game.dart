import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reaction_test_controller.dart';

class ReactionTestGame extends StatefulWidget {
  const ReactionTestGame({super.key});

  @override
  State<ReactionTestGame> createState() => _ReactionTestGameState();
}

class _ReactionTestGameState extends State<ReactionTestGame> with WidgetsBindingObserver {
  late ReactionTestController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(ReactionTestController());
    
    // Oyun başlamadan önce talimatları göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<ReactionTestController>();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama arkaplanda ise oyunu sıfırla
    if (state == AppLifecycleState.paused) {
      controller.resetGame();
    }
  }
  
  void _showInstructions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tepki Testi', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Nasıl Oynanır:'),
              SizedBox(height: 8),
              Text('1. Ekrana dokunarak başla'),
              Text('2. Kırmızı ekran yeşile dönüştüğünde hızlıca dokun'),
              Text('3. Ekran kırmızıyken dokunma, erken hareket etmiş olursun'),
              Text('4. Reaksiyon süren milisaniye cinsinden gösterilecek'),
              SizedBox(height: 16),
              Text('Hazır mısın?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('BAŞLA'),
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
          controller.resetGame();
        }
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tepki Testi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (controller.isPlaying.value) {
                controller.resetGame();
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Üst panel - Skor ve istatistikler
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('En İyi Süre:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Obx(() => Text(
                          controller.bestReactionTime.value == 9999 
                              ? '--' 
                              : '${controller.bestReactionTime.value} ms',
                          style: const TextStyle(fontSize: 18),
                        )),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Ortalama:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Obx(() => Text(
                          controller.averageReactionTime.value == 0 
                              ? '--' 
                              : '${controller.averageReactionTime.value} ms',
                          style: const TextStyle(fontSize: 18),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Ana oyun alanı
              Expanded(
                child: Obx(() => GestureDetector(
                  onTap: () => controller.onTap(),
                  child: Container(
                    width: double.infinity,
                    color: controller.backgroundColor.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Beklerken
                        if (controller.isWaiting.value)
                          const Text(
                            'Bekle...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                        // Hazır olduğunda
                        if (controller.isReady.value)
                          const Text(
                            'DOKUN!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                        // Erken tıkladıysa
                        if (controller.isTooEarly.value)
                          Column(
                            children: const [
                              Text(
                                'Çok Erken!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Yeşil ışığı beklemeliydin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              SizedBox(height: 30),
                              Text(
                                'Tekrar başlamak için dokun',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        
                        // Sonuçlar
                        if (controller.showResult.value)
                          Column(
                            children: [
                              Text(
                                '${controller.currentReactionTime.value} ms',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                controller.currentReactionTime.value < 200 
                                    ? 'Harika!' 
                                    : controller.currentReactionTime.value < 300 
                                        ? 'İyi' 
                                        : 'Ortalama',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Tekrar denemek için dokun',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          
                        // Başlangıç durumu
                        if (!controller.isPlaying.value && 
                            !controller.isWaiting.value && 
                            !controller.isReady.value && 
                            !controller.isTooEarly.value && 
                            !controller.showResult.value)
                          Column(
                            children: const [
                              Text(
                                'Başlamak için dokun',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Ekran yeşil olduğunda tepki ver',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                )),
              ),
              
              // Alt panel - Açıklama
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey.shade200,
                child: Column(
                  children: [
                    const Text(
                      'Ortalama reaksiyon süresi:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 200 ms altı: Üstün'),
                    const Text('• 200-300 ms: Çok iyi'),
                    const Text('• 300-500 ms: Ortalama'),
                    const Text('• 500+ ms: Yavaş'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 