import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'color_match_controller.dart';
import 'color_match_model.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> with WidgetsBindingObserver {
  late ColorMatchController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(ColorMatchController());
    
    // Oyun başlamadan önce talimatları göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<ColorMatchController>();
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
          title: const Text('Renk Eşleştirme', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Nasıl Oynanır:'),
              SizedBox(height: 8),
              Text('1. Renk dizisini dikkatlice izle'),
              Text('2. Renkler sırayla yanıp sönecek'),
              Text('3. Aynı sırayla renklere dokun'),
              Text('4. Her seviyede bir renk daha eklenir'),
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
          title: const Text('Renk Eşleştirme'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (controller.isPlaying.value) {
                controller.resetGame();
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (!controller.isShowingSequence.value) {
                  controller.resetGame();
                  controller.startGame();
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: GetX<ColorMatchController>(
            builder: (_) => Column(
              children: [
                // Üst panel - Skor ve seviye
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seviye:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${controller.level.value}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            controller.isShowingSequence.value
                                ? 'İzle...'
                                : controller.isPlayerTurn.value
                                    ? 'Sıra Sende!'
                                    : 'Hazır Ol',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.isPlayerTurn.value ? Colors.green : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Puan:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${controller.score.value}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Orta Alan - Durum mesajı
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    controller.gameOver.value
                        ? 'Oyun Bitti!'
                        : controller.isShowingSequence.value
                            ? 'Renk Dizisini İzle'
                            : controller.isPlayerTurn.value
                                ? 'Aynı Sırayla Renklere Dokun'
                                : 'Oyuna Başlamak İçin Hazır Ol',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: controller.gameOver.value
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                ),
                
                // Oyun Sonuç Ekranı
                if (controller.gameOver.value)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Oyun Bitti!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Puanın: ${controller.score.value}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Seviye: ${controller.level.value}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'En Yüksek Puan: ${controller.highScore.value}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            controller.resetGame();
                            controller.startGame();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text(
                            'Tekrar Oyna',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                
                // Renk Butonları Alanı
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: GameColors.allColors.length,
                      itemBuilder: (context, index) {
                        final color = GameColors.allColors[index];
                        final isHighlighted = controller.highlightedColorId.value == color.id;
                        
                        return _buildColorButton(
                          color: color,
                          isHighlighted: isHighlighted,
                          isEnabled: controller.isPlayerTurn.value && !controller.gameOver.value,
                        );
                      },
                    ),
                  ),
                ),
                
                // Yardım Metni
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    controller.isPlayerTurn.value
                        ? '${controller.playerSequence.length} / ${controller.sequence.length}'
                        : controller.gameOver.value
                            ? 'Yeniden oynamak için "Tekrar Oyna" düğmesine dokun'
                            : controller.isShowingSequence.value
                                ? 'Lütfen bekleyin...'
                                : 'Başlamak için hazır olun',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
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
  
  Widget _buildColorButton({
    required ColorModel color,
    required bool isHighlighted,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? () => controller.onColorTap(color) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isHighlighted ? color.color : color.color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2.0,
          ),
        ),
        child: Center(
          child: Text(
            color.name,
            style: TextStyle(
              color: _getContrastingTextColor(color.color),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
  
  // Kontrast metin rengi belirle (koyu arka plana açık metin, açık arka plana koyu metin)
  Color _getContrastingTextColor(Color backgroundColor) {
    // Renk parlaklığını hesapla
    final brightness = backgroundColor.computeLuminance();
    
    // Parlaklık 0.5'ten büyükse (açık renk) koyu metin, değilse açık metin döndür
    return brightness > 0.5 ? Colors.black : Colors.white;
  }
} 