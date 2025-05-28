import 'package:get/get.dart';
import '../../../infrastructure/services/storage/storage_service.dart';

class ProfileController extends GetxController {
  // Servisler
  final StorageService _storage = Get.find<StorageService>();
  
  // Kullanıcı bilgileri
  final RxString username = "".obs;
  final RxString avatarUrl = "".obs;
  final RxBool isGuestUser = true.obs;
  
  // İstatistikler
  final RxInt totalGamesPlayed = 0.obs;
  final RxInt totalWins = 0.obs;
  final RxInt totalScore = 0.obs;
  final RxInt achievementsUnlocked = 0.obs;
  
  // Kişisel en yüksek skorlar
  final RxMap<String, int> highScores = <String, int>{}.obs;
  
  // Favori oyunlar
  final RxList<String> favoriteGames = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadStats();
    _loadHighScores();
    _loadFavoriteGames();
  }
  
  // Kullanıcı adını güncelle
  void updateUsername(String newUsername) {
    if (newUsername.isEmpty) return;
    
    username.value = newUsername;
    _storage.setString('profile_username', newUsername);
  }
  
  // Avatar güncelle (şimdilik sadece renk seçimi)
  void updateAvatar(int avatarIndex) {
    avatarUrl.value = 'avatar_$avatarIndex';
    _storage.setString('profile_avatar', avatarUrl.value);
  }
  
  // Oyunu favorilere ekle/çıkar
  void toggleFavoriteGame(String gameName) {
    if (favoriteGames.contains(gameName)) {
      favoriteGames.remove(gameName);
    } else {
      favoriteGames.add(gameName);
    }
    
    _storage.setStringList('profile_favorite_games', favoriteGames);
  }
  
  // Oyun oynandığında istatistik güncelle
  void updateGameStats(String gameName, int score, bool isWin) {
    // Toplam oyun sayısını güncelle
    totalGamesPlayed.value++;
    _storage.setInt('profile_total_games', totalGamesPlayed.value);
    
    // Kazanma durumunda
    if (isWin) {
      totalWins.value++;
      _storage.setInt('profile_total_wins', totalWins.value);
    }
    
    // Toplam skoru güncelle
    totalScore.value += score;
    _storage.setInt('profile_total_score', totalScore.value);
    
    // Yeni storage metodu ile skor güncelleme
    _storage.saveGameResult(gameName, score);
    
    // Yüksek skoru kontrol et ve güncelle (UI için)
    if (!highScores.containsKey(gameName) || score > highScores[gameName]!) {
      highScores[gameName] = score;
    }
  }
  
  // Kullanıcı verilerini yükle
  void _loadUserData() {
    final storedUsername = _storage.getString('profile_username', defaultValue: "");
    final storedAvatar = _storage.getString('profile_avatar', defaultValue: "avatar_1");
    
    if (storedUsername.isNotEmpty) {
      username.value = storedUsername;
      isGuestUser.value = false;
    } else {
      username.value = "Misafir";
      isGuestUser.value = true;
    }
    
    avatarUrl.value = storedAvatar;
  }
  
  // İstatistikleri yükle
  void _loadStats() {
    totalGamesPlayed.value = _storage.getInt('profile_total_games', defaultValue: 0);
    totalWins.value = _storage.getInt('profile_total_wins', defaultValue: 0);
    totalScore.value = _storage.getInt('profile_total_score', defaultValue: 0);
    achievementsUnlocked.value = _storage.getInt('profile_achievements', defaultValue: 0);
  }
  
  // Yüksek skorları yükle
  void _loadHighScores() {
    // Tüm oyunların yüksek skorlarını al
    final gameNames = [
      'rapid_tap', 'reaction_test', 'color_match',
      // Diğer oyunlar eklendikçe buraya eklenecek
    ];
    
    for (final game in gameNames) {
      final score = _storage.getInt('profile_highscore_$game', defaultValue: 0);
      if (score > 0) {
        highScores[game] = score;
      }
    }
  }
  
  // Favori oyunları yükle
  void _loadFavoriteGames() {
    final savedFavorites = _storage.getStringList('profile_favorite_games', defaultValue: []);
    favoriteGames.assignAll(savedFavorites);
  }
  
  // Başarım kilidini aç
  void unlockAchievement(String achievementId) {
    // Başarımlar sistemi kurulduğunda burada başarım kilidi açılacak
    achievementsUnlocked.value++;
    _storage.setInt('profile_achievements', achievementsUnlocked.value);
  }
} 