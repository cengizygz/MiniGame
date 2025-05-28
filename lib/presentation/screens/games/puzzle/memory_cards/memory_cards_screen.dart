import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'memory_cards_controller.dart';

class MemoryCardsScreen extends StatelessWidget {
  const MemoryCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemoryCardsController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('memory_cards'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.toNamed(AppRoutes.puzzleGames),
        ),
        actions: [
          // Yeniden başlat butonu
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.startNewGame,
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
              // Üst panel (skor, hamle sayısı, eşleşen çift sayısı)
              _buildInfoPanel(context, controller),
              
              const SizedBox(height: 8),
              
              // Zorluk seçimi
              _buildDifficultySelector(context, controller),
              
              const SizedBox(height: 16),
              
              // Oyun kartları
              Expanded(
                child: _buildCardGrid(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Üst bilgi paneli
  Widget _buildInfoPanel(BuildContext context, MemoryCardsController controller) {
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
                  GetBuilder<MemoryCardsController>(
                    builder: (_) => Text(
                      '${controller.gameModel.value.score}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Hamle sayısı
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
                    'moves'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GetBuilder<MemoryCardsController>(
                    builder: (_) => Text(
                      '${controller.getMoveCount()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Eşleşen çiftler
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
                    'pairs'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GetBuilder<MemoryCardsController>(
                    builder: (_) => Text(
                      '${controller.getMatchedPairs()}/${controller.getTotalPairs()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Zorluk seviyesi seçici
  Widget _buildDifficultySelector(BuildContext context, MemoryCardsController controller) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'difficulty'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Obx(() => SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: 1,
                  label: Text('easy'.tr),
                ),
                ButtonSegment<int>(
                  value: 2,
                  label: Text('medium'.tr),
                ),
                ButtonSegment<int>(
                  value: 3,
                  label: Text('hard'.tr),
                ),
              ],
              selected: {controller.difficulty.value},
              onSelectionChanged: (Set<int> newSelection) {
                controller.setDifficulty(newSelection.first);
              },
            )),
          ],
        ),
      ),
    );
  }
  
  // Oyun kartları grid'i
  Widget _buildCardGrid(BuildContext context, MemoryCardsController controller) {
    return GetBuilder<MemoryCardsController>(
      builder: (_) {
        final int cardCount = controller.getCardCount();
        final int crossAxisCount = _getCrossAxisCount(controller.difficulty.value);
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.8,
          ),
          itemCount: cardCount,
          itemBuilder: (context, index) {
            return _buildCard(context, controller, index);
          },
        );
      },
    );
  }
  
  // Zorluk seviyesine göre sütun sayısını belirle
  int _getCrossAxisCount(int difficulty) {
    switch (difficulty) {
      case 1: // Easy
        return 4; // 4x2 grid
      case 2: // Medium
        return 5; // 5x4 grid
      case 3: // Hard
        return 6; // 6x8 grid
      default:
        return 4;
    }
  }
  
  // Kart widget'ı
  Widget _buildCard(BuildContext context, MemoryCardsController controller, int index) {
    final isVisible = controller.shouldShowCardFront(index);
    
    return GestureDetector(
      onTap: () => controller.onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: controller.getCardColor(index),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isVisible ? 1.0 : 0.0,
            child: Text(
              controller.getCardSymbol(index),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                Text('memory_cards_info_1'.tr),
                const SizedBox(height: 8),
                Text('memory_cards_info_2'.tr),
                const SizedBox(height: 8),
                Text('memory_cards_info_3'.tr),
                const SizedBox(height: 16),
                Text(
                  'tips'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('• ${'memory_cards_tip_1'.tr}'),
                const SizedBox(height: 4),
                Text('• ${'memory_cards_tip_2'.tr}'),
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