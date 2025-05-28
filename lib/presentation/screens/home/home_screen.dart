import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/banner_ad_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner reklam
          const BannerAdWidget(),
          
          // Ana içerik
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ana başlık
                  Text(
                    'game_categories'.tr,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Kategori kartları
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildCategoryCard(context, AppRoutes.reflexGames, 'reflex_games'.tr, Colors.red),
                        _buildCategoryCard(context, AppRoutes.puzzleGames, 'puzzle_games'.tr, Colors.green),
                        _buildCategoryCard(context, AppRoutes.arcadeGames, 'arcade_games'.tr, Colors.blue),
                        _buildCategoryCard(context, AppRoutes.strategyGames, 'strategy_games'.tr, Colors.orange),
                        _buildCategoryCard(context, AppRoutes.educationalGames, 'educational_games'.tr, Colors.purple),
                        _buildCategoryCard(context, AppRoutes.physicsGames, 'physics_games'.tr, Colors.teal),
                        _buildCategoryCard(context, AppRoutes.rhythmGames, 'rhythm_games'.tr, Colors.pink),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0: // Ana Sayfa
              // Zaten ana sayfadayız
              break;
            case 1: // Skor Tablosu
              Get.toNamed(AppRoutes.leaderboard);
              break;
            case 2: // Ayarlar
              Get.toNamed(AppRoutes.settings);
              break;
            case 3: // Profil
              Get.toNamed(AppRoutes.profile);
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard),
            label: 'leaderboard'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'settings'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr,
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String routeName, String title, Color color) {
    return Card(
      elevation: 5,
      color: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Oyun kategorisine git
          if (Get.routeTree.routes.any((r) => r.name == routeName)) {
            Get.toNamed(routeName);
          } else {
            // Eğer rota henüz oluşturulmadıysa bilgi mesajı göster
            Get.snackbar(
              'info'.tr,
              'Bu kategori yakında eklenecek!',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(routeName),
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String routeName) {
    switch(routeName) {
      case AppRoutes.reflexGames:
        return Icons.flash_on;
      case AppRoutes.puzzleGames:
        return Icons.extension;
      case AppRoutes.arcadeGames:
        return Icons.sports_esports;
      case AppRoutes.strategyGames:
        return Icons.psychology;
      case AppRoutes.educationalGames:
        return Icons.school;
      case AppRoutes.physicsGames:
        return Icons.science;
      case AppRoutes.rhythmGames:
        return Icons.music_note;
      default:
        return Icons.games;
    }
  }
} 