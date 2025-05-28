import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/app_routes.dart';
import 'number_puzzle_controller.dart';

class NumberPuzzleScreen extends StatelessWidget {
  const NumberPuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NumberPuzzleController());
    
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: controller.handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text('number_puzzle'.tr),
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
                // Skor paneli
                _buildScorePanel(context, controller),
                
                const SizedBox(height: 24),
                
                // Oyun tahtası
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: controller.handleSwipe,
                    onVerticalDragEnd: controller.handleSwipe,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: GetBuilder<NumberPuzzleController>(
                          builder: (_) => GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: 16,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final row = index ~/ 4;
                              final col = index % 4;
                              final value = controller.gameModel.value.board[row][col];
                              
                              return _buildTile(context, controller, value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Yönergeler
                _buildInstructions(context),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Skor paneli
  Widget _buildScorePanel(BuildContext context, NumberPuzzleController controller) {
    return Row(
      children: [
        // Mevcut skor
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
        
        // Yüksek skor
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
                    'best'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    '${controller.highScore.value}',
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
      ],
    );
  }
  
  // Sayı karosu
  Widget _buildTile(BuildContext context, NumberPuzzleController controller, int value) {
    return Container(
      decoration: BoxDecoration(
        color: controller.getTileColor(value),
        borderRadius: BorderRadius.circular(8),
        boxShadow: value > 0 ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ] : null,
      ),
      child: Center(
        child: value > 0
            ? Text(
                '$value',
                style: TextStyle(
                  fontSize: controller.getTileFontSize(value),
                  fontWeight: FontWeight.bold,
                  color: value <= 4 ? Colors.grey.shade800 : Colors.white,
                ),
              )
            : null,
      ),
    );
  }
  
  // Yönergeler
  Widget _buildInstructions(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(Icons.swipe, size: 28),
                const SizedBox(height: 4),
                Text(
                  'swipe'.tr,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.keyboard_arrow_up, size: 28),
                const SizedBox(height: 4),
                Text(
                  'arrows'.tr,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.add_box_outlined, size: 28),
                const SizedBox(height: 4),
                Text(
                  'merge'.tr,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  '2048',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'target'.tr,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
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
                Text('number_puzzle_info_1'.tr),
                const SizedBox(height: 8),
                Text('number_puzzle_info_2'.tr),
                const SizedBox(height: 8),
                Text('number_puzzle_info_3'.tr),
                const SizedBox(height: 8),
                Text('number_puzzle_info_4'.tr),
                const SizedBox(height: 16),
                Text(
                  'tips'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('• ${'number_puzzle_tip_1'.tr}'),
                const SizedBox(height: 4),
                Text('• ${'number_puzzle_tip_2'.tr}'),
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

// Oyun kazanıldı/bitti diyalogları
class GameOverDialog extends StatelessWidget {
  final bool isWin;
  final int score;
  final VoidCallback onRestart;
  final VoidCallback? onContinue;
  
  const GameOverDialog({
    super.key,
    required this.isWin,
    required this.score,
    required this.onRestart,
    this.onContinue,
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
            isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 64,
            color: isWin ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isWin
                ? 'you_reached_2048'.tr
                : 'no_more_moves'.tr,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
        if (isWin && onContinue != null)
          TextButton(
            onPressed: onContinue,
            child: Text('continue'.tr),
          ),
      ],
    );
  }
} 