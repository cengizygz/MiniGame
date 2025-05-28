import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../infrastructure/services/ad/ad_service.dart';

class ReflexGamesScreen extends StatelessWidget {
  const ReflexGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reklam servisine erişim
    final adService = Get.find<AdService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('reflex_games'.tr),
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
                  // Reaction Test
                  _buildGameCard(
                    context,
                    title: 'Reaction Test',
                    description: 'Refleksleri test etme',
                    icon: Icons.touch_app,
                    color: Colors.orange,
                    onTap: () {
                      // Önce bir interstitial reklam göster, sonra oyunu aç
                      if (adService.isInterstitialAdReady.value) {
                        adService.showInterstitialAd().then((_) {
                          // Reklam tamamlandıktan sonra oyun sayfasına git
                          Get.toNamed(AppRoutes.reactionTest);
                        });
                      } else {
                        // Reklam yoksa direkt oyunu aç
                        Get.toNamed(AppRoutes.reactionTest);
                      }
                    },
                    isAvailable: true, // Oyun artık kullanılabilir
                  ),
                  
                  // Color Match
                  _buildGameCard(
                    context,
                    title: 'Color Match',
                    description: 'Renk eşleştirme',
                    icon: Icons.color_lens,
                    color: Colors.purple,
                    onTap: () {
                      // Önce bir interstitial reklam göster, sonra oyunu aç
                      if (adService.isInterstitialAdReady.value) {
                        adService.showInterstitialAd().then((_) {
                          // Reklam tamamlandıktan sonra oyun sayfasına git
                          Get.toNamed(AppRoutes.colorMatch);
                        });
                      } else {
                        // Reklam yoksa direkt oyunu aç
                        Get.toNamed(AppRoutes.colorMatch);
                      }
                    },
                    isAvailable: true, // Oyun artık kullanılabilir
                  ),
                  
                  // Rapid Tap
                  _buildGameCard(
                    context,
                    title: 'Rapid Tap',
                    description: 'Hızlı tıklama',
                    icon: Icons.speed,
                    color: Colors.blue,
                    onTap: () {
                      // Önce bir interstitial reklam göster, sonra oyunu aç
                      if (adService.isInterstitialAdReady.value) {
                        adService.showInterstitialAd().then((_) {
                          // Reklam tamamlandıktan sonra oyun sayfasına git
                          Get.toNamed(AppRoutes.rapidTap);
                        });
                      } else {
                        // Reklam yoksa direkt oyunu aç
                        Get.toNamed(AppRoutes.rapidTap);
                      }
                    },
                    isAvailable: true, // Oyun artık kullanılabilir
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