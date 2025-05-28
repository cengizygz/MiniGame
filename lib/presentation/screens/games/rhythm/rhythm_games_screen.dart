import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/widgets/game_category_card.dart';

class RhythmGamesScreen extends StatelessWidget {
  const RhythmGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('rhythm_games'.tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'rhythm_games_desc'.tr,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Music Notes Game
                  GameCategoryCard(
                    title: 'music_notes'.tr,
                    description: 'music_notes_desc'.tr,
                    icon: Icons.music_note,
                    color: Colors.purple,
                    onTap: () => Get.toNamed(AppRoutes.musicNotes),
                  ),
                  
                  // Piano Tiles Game
                  GameCategoryCard(
                    title: 'piano_tiles'.tr,
                    description: 'piano_tiles_desc'.tr,
                    icon: Icons.piano,
                    color: Colors.indigo,
                    onTap: () => Get.toNamed(AppRoutes.pianoTiles),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 