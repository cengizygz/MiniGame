import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context, controller),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: GetX<ProfileController>(
          builder: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profil Kartı
              _buildProfileCard(context, controller),
              
              const SizedBox(height: 24),
              
              // İstatistikler
              _buildStatsSection(context, controller),
              
              const SizedBox(height: 24),
              
              // Yüksek Skorlar
              _buildHighScoresSection(context, controller),
              
              const SizedBox(height: 24),
              
              // Favori Oyunlar
              _buildFavoriteGamesSection(context, controller),
            ],
          ),
        ),
      ),
    );
  }
  
  // Profil Kartı
  Widget _buildProfileCard(BuildContext context, ProfileController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: _getAvatarColor(controller.avatarUrl.value),
              child: Text(
                controller.username.value.isNotEmpty
                    ? controller.username.value[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Kullanıcı Adı
            Text(
              controller.username.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Misafir Durumu
            if (controller.isGuestUser.value)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'guest_account'.tr,
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  // İstatistikler Bölümü
  Widget _buildStatsSection(BuildContext context, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'statistics'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        const SizedBox(height: 8),
        
        // İstatistik Kartları
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          children: [
            _buildStatCard(
              context,
              icon: Icons.sports_esports,
              title: 'games_played'.tr,
              value: controller.totalGamesPlayed.value.toString(),
              color: Colors.blue,
            ),
            _buildStatCard(
              context,
              icon: Icons.emoji_events,
              title: 'wins'.tr,
              value: controller.totalWins.value.toString(),
              color: Colors.amber,
            ),
            _buildStatCard(
              context,
              icon: Icons.star,
              title: 'total_score'.tr,
              value: controller.totalScore.value.toString(),
              color: Colors.purple,
            ),
            _buildStatCard(
              context,
              icon: Icons.military_tech,
              title: 'achievements'.tr,
              value: '${controller.achievementsUnlocked.value}/10',
              color: Colors.teal,
            ),
          ],
        ),
      ],
    );
  }
  
  // Yüksek Skorlar Bölümü
  Widget _buildHighScoresSection(BuildContext context, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'high_scores'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        const SizedBox(height: 8),
        
        if (controller.highScores.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'no_high_scores'.tr,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.highScores.length,
            itemBuilder: (context, index) {
              final entry = controller.highScores.entries.elementAt(index);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getGameIconColor(entry.key),
                  child: Icon(
                    _getGameIcon(entry.key),
                    color: Colors.white,
                  ),
                ),
                title: Text(_getGameName(entry.key)),
                subtitle: Text('high_score'.tr),
                trailing: Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
  
  // Favori Oyunlar Bölümü
  Widget _buildFavoriteGamesSection(BuildContext context, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'favorite_games'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        const SizedBox(height: 8),
        
        if (controller.favoriteGames.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'no_favorite_games'.tr,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.favoriteGames.length,
            itemBuilder: (context, index) {
              final gameName = controller.favoriteGames[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getGameIconColor(gameName),
                  child: Icon(
                    _getGameIcon(gameName),
                    color: Colors.white,
                  ),
                ),
                title: Text(_getGameName(gameName)),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => controller.toggleFavoriteGame(gameName),
                ),
              );
            },
          ),
      ],
    );
  }
  
  // İstatistik Kartı Widget
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Profil düzenleme diyalogu
  void _showEditProfileDialog(BuildContext context, ProfileController controller) {
    final TextEditingController textController = TextEditingController(text: controller.username.value);
    int selectedAvatarIndex = int.tryParse(controller.avatarUrl.value.split('_').last) ?? 1;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('edit_profile'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'username'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('select_avatar'.tr),
              const SizedBox(height: 8),
              
              // Avatar seçimi
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  6,
                  (index) {
                    final avatarIndex = index + 1;
                    return GestureDetector(
                      onTap: () {
                        selectedAvatarIndex = avatarIndex;
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: _getAvatarColor('avatar_$avatarIndex'),
                        child: selectedAvatarIndex == avatarIndex
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                controller.updateUsername(textController.text);
                controller.updateAvatar(selectedAvatarIndex);
                Navigator.of(context).pop();
              },
              child: Text('save'.tr),
            ),
          ],
        );
      },
    );
  }
  
  // Avatar rengi belirleme yardımcısı
  Color _getAvatarColor(String avatarId) {
    final int index = int.tryParse(avatarId.split('_').last) ?? 1;
    
    switch (index) {
      case 1: return Colors.blue;
      case 2: return Colors.red;
      case 3: return Colors.green;
      case 4: return Colors.purple;
      case 5: return Colors.orange;
      case 6: return Colors.teal;
      default: return Colors.grey;
    }
  }
  
  // Oyun adını getir
  String _getGameName(String gameKey) {
    switch (gameKey) {
      case 'rapid_tap': return 'Hızlı Tıklama Yarışı';
      case 'reaction_test': return 'Tepki Testi';
      case 'color_match': return 'Renk Eşleştirme';
      default: return gameKey.tr;
    }
  }
  
  // Oyun ikonunu getir
  IconData _getGameIcon(String gameKey) {
    switch (gameKey) {
      case 'rapid_tap': return Icons.touch_app;
      case 'reaction_test': return Icons.speed;
      case 'color_match': return Icons.palette;
      default: return Icons.games;
    }
  }
  
  // Oyun ikonu rengini getir
  Color _getGameIconColor(String gameKey) {
    switch (gameKey) {
      case 'rapid_tap': return Colors.red;
      case 'reaction_test': return Colors.green;
      case 'color_match': return Colors.blue;
      default: return Colors.grey;
    }
  }
} 