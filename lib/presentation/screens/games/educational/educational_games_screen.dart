import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_routes.dart';

class EducationalGamesScreen extends StatelessWidget {
  const EducationalGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('educational_games'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Text(
              'select_game'.tr,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Oyun listesi
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  // Matematik Yarışı
                  _buildGameCard(
                    context,
                    title: 'Matematik Yarışı',
                    description: 'Hızlı matematik problemleri',
                    icon: Icons.calculate,
                    color: Colors.green,
                    onTap: () => Get.toNamed(AppRoutes.mathRace),
                    isAvailable: true,
                  ),
                  
                  // Bayrak Bilmece
                  _buildGameCard(
                    context,
                    title: 'Bayrak Bilmece',
                    description: 'Ülke bayraklarını tanıma',
                    icon: Icons.flag,
                    color: Colors.red,
                    onTap: () => Get.toNamed(AppRoutes.flagQuiz),
                    isAvailable: true,
                  ),
                  
                  // Kelime Öğrenme
                  _buildGameCard(
                    context,
                    title: 'Kelime Öğrenme',
                    description: 'İngilizce kelime öğrenme oyunu',
                    icon: Icons.translate,
                    color: Colors.blue,
                    onTap: () => Get.toNamed(AppRoutes.wordLearning),
                    isAvailable: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isAvailable,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isAvailable
            ? onTap
            : () {
                // Eğer oyun henüz geliştirilemediyse bilgi mesajı göster
                Get.snackbar(
                  'info'.tr,
                  'Bu oyun yakında eklenecek!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isAvailable) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'coming_soon'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 