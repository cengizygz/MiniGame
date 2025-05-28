import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'word_hunt_controller.dart';

class WordHuntScreen extends StatelessWidget {
  const WordHuntScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WordHuntController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('word_hunt'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.toNamed(AppRoutes.puzzleGames),
        ),
        actions: [
          // Yeniden başlat butonu
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetGame,
            tooltip: 'restart'.tr,
          ),
          // Bilgi butonu
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'how_to_play'.tr,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst panel (skor ve süre)
              _buildTopPanel(context, controller),
              
              const SizedBox(height: 16),
              
              // Harf tablosu
              Expanded(
                flex: 5,
                child: _buildLetterGrid(context, controller),
              ),
              
              const SizedBox(height: 16),
              
              // Mevcut kelime gösterimi
              _buildCurrentWordDisplay(context, controller),
              
              const SizedBox(height: 16),
              
              // Butonlar (gönder, temizle, ipucu)
              _buildActionButtons(context, controller),
              
              const SizedBox(height: 16),
              
              // Bulunan kelimeler listesi
              Expanded(
                flex: 3,
                child: _buildFoundWordsList(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Üst panel (skor ve süre)
  Widget _buildTopPanel(BuildContext context, WordHuntController controller) {
    return Row(
      children: [
        // Skor
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    'score'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    '${controller.gameModel.value.score}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Süre
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    'time'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final minutes = controller.remainingTime.value ~/ 60;
                    final seconds = controller.remainingTime.value % 60;
                    return Text(
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: controller.remainingTime.value < 30
                            ? Colors.red
                            : Colors.black,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Harf tablosu
  Widget _buildLetterGrid(BuildContext context, WordHuntController controller) {
    return GetBuilder<WordHuntController>(
      builder: (_) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: 64, // 8x8 grid
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            
            return GestureDetector(
              onTap: () => controller.selectCell(row, col),
              onPanStart: (details) => controller.selectCell(row, col),
              onPanUpdate: (details) {
                // Parmak sürükleme ile harf seçimi
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final width = box.size.width / 8;
                final height = box.size.height / 8;
                
                final newRow = (localPosition.dy / height).floor();
                final newCol = (localPosition.dx / width).floor();
                
                if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
                  controller.selectCell(newRow, newCol);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: controller.getCellBackgroundColor(row, col),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Center(
                  child: Text(
                    controller.gameModel.value.grid[row][col],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: controller.getCellTextColor(row, col),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  // Mevcut kelime gösterimi
  Widget _buildCurrentWordDisplay(BuildContext context, WordHuntController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Obx(() => Text(
          controller.currentWord.value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        )),
      ),
    );
  }
  
  // Aksiyon butonları
  Widget _buildActionButtons(BuildContext context, WordHuntController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Kelimeyi gönder
        ElevatedButton.icon(
          onPressed: controller.submitWord,
          icon: const Icon(Icons.send),
          label: Text('submit'.tr),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        
        // Seçimi temizle
        OutlinedButton.icon(
          onPressed: controller.clearSelection,
          icon: const Icon(Icons.clear),
          label: Text('clear'.tr),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        
        // İpucu
        IconButton(
          onPressed: controller.showHint,
          icon: const Icon(Icons.lightbulb_outline),
          tooltip: 'hint'.tr,
          style: IconButton.styleFrom(
            backgroundColor: Colors.amber.shade100,
          ),
        ),
      ],
    );
  }
  
  // Bulunan kelimeler listesi
  Widget _buildFoundWordsList(BuildContext context, WordHuntController controller) {
    return GetBuilder<WordHuntController>(
      builder: (_) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'found_words'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Bulunan / toplam kelime sayısı
                  Text(
                    '${controller.gameModel.value.foundWords.length}/${controller.gameModel.value.hiddenWords.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Bulunan kelimeler
              Expanded(
                child: controller.gameModel.value.foundWords.isEmpty
                    ? Center(
                        child: Text(
                          'no_words_found'.tr,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: controller.gameModel.value.foundWords
                            .map((word) => Chip(
                                  label: Text(word),
                                  backgroundColor: Colors.green.shade50,
                                  side: BorderSide(
                                    color: Colors.green.shade200,
                                  ),
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Oyun bilgisi ve kurallar diyalogu
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('how_to_play'.tr),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('word_hunt_info_1'.tr),
                const SizedBox(height: 8),
                Text('word_hunt_info_2'.tr),
                const SizedBox(height: 8),
                Text('word_hunt_info_3'.tr),
                const SizedBox(height: 16),
                Text(
                  'tips'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('• ${'word_hunt_tip_1'.tr}'),
                const SizedBox(height: 4),
                Text('• ${'word_hunt_tip_2'.tr}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('got_it'.tr),
            ),
          ],
        );
      },
    );
  }
}

// Oyun sonuç diyalogu
class GameResultDialog extends StatelessWidget {
  final bool isWin;
  final int score;
  final int foundWordsCount;
  final int totalWordsCount;
  final VoidCallback onRestart;
  
  const GameResultDialog({
    super.key,
    required this.isWin,
    required this.score,
    required this.foundWordsCount,
    required this.totalWordsCount,
    required this.onRestart,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isWin ? 'you_win'.tr : 'game_over'.tr,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWin ? Icons.emoji_events : Icons.access_time,
            size: 64,
            color: isWin ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isWin
                ? 'all_words_found'.tr
                : 'time_up'.tr,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '${'found_words_count'.tr}: $foundWordsCount/$totalWordsCount',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${'final_score'.tr}: $score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRestart,
          child: Text('play_again'.tr),
        ),
      ],
    );
  }
} 