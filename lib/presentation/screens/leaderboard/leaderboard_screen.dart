import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import 'leaderboard_controller.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('leaderboard'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Kategori seçimi
          _buildCategorySelector(context, controller),
          
          // Skor listesi
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              final categoryScores = controller.gameScores[controller.selectedCategory.value];
              
              if (categoryScores == null || categoryScores.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_scores_yet'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'play_games_to_see_scores'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return _buildScoreList(context, controller, categoryScores);
            }),
          ),
        ],
      ),
    );
  }
  
  // Kategori seçici
  Widget _buildCategorySelector(BuildContext context, LeaderboardController controller) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: List.generate(
            controller.gameCategories.length,
            (index) {
              final category = controller.gameCategories[index];
              
              return Obx(() {
                final isSelected = controller.selectedCategory.value == category;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.changeCategory(category),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.getCategoryIcon(category),
                              size: 18,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.tr,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
  
  // Skor listesi
  Widget _buildScoreList(
    BuildContext context,
    LeaderboardController controller,
    List<Map<String, dynamic>> scores,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final scoreData = scores[index];
        final gameKey = scoreData['game'] as String;
        final score = scoreData['score'] as int;
        final lastPlayed = scoreData['lastPlayed'] as String? ?? '';
        
        // Madalya renkleri (ilk 3)
        Color? medalColor;
        if (index == 0) {
          medalColor = Colors.amber; // Altın
        } else if (index == 1) medalColor = Colors.blueGrey.shade300; // Gümüş
        else if (index == 2) medalColor = Colors.brown.shade300; // Bronz
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: _getScoreColor(index),
                  radius: 24,
                  child: Icon(
                    controller.getGameIcon(gameKey),
                    color: Colors.white,
                  ),
                ),
                if (medalColor != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: medalColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              controller.getGameName(gameKey),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: lastPlayed.isNotEmpty
                ? Text('${'last_played'.tr}: $lastPlayed')
                : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                score.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Skora göre renk belirleme
  Color _getScoreColor(int index) {
    switch (index) {
      case 0: return Colors.amber.shade700; // 1. sıra 
      case 1: return Colors.blueGrey; // 2. sıra
      case 2: return Colors.brown; // 3. sıra
      default: 
        // Diğer sıralar (rastgele renkler)
        final colors = [
          Colors.blue, Colors.red, Colors.green,
          Colors.purple, Colors.teal, Colors.indigo
        ];
        return colors[index % colors.length];
    }
  }
} 