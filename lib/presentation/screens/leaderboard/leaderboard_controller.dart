import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../infrastructure/services/storage/storage_service.dart';

class LeaderboardController extends GetxController {
  // Servisler
  final StorageService _storage = Get.find<StorageService>();
  
  // Kategoriler ve oyunlar
  final RxList<String> gameCategories = <String>[
    'reflex_games',
    'puzzle_games',
    'arcade_games',
    'strategy_games',
    'educational_games',
    'physics_games',
    'rhythm_games',
  ].obs;
  
  // Seçilen kategori
  final RxString selectedCategory = 'reflex_games'.obs;
  
  // Oyunların skoru
  final RxMap<String, List<Map<String, dynamic>>> gameScores = <String, List<Map<String, dynamic>>>{}.obs;
  
  // Yükleniyor durumu
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadGameScores();
  }
  
  // Kategori değiştirme
  void changeCategory(String category) {
    selectedCategory.value = category;
  }
  
  // Tüm oyunların skorlarını yükle
  Future<void> loadGameScores() async {
    isLoading.value = true;
    
    // Refleks oyunları
    final reflexGames = ['rapid_tap', 'reaction_test', 'color_match'];
    final reflexScores = await _loadCategoryScores(reflexGames);
    gameScores['reflex_games'] = reflexScores;
    
    // Bulmaca oyunları
    final puzzleGames = ['number_puzzle', 'word_hunt', 'memory_cards'];
    final puzzleScores = await _loadCategoryScores(puzzleGames);
    gameScores['puzzle_games'] = puzzleScores;
    
    // Arcade oyunları
    final arcadeGames = ['snake', 'space_shooter', 'bounce_ball'];
    final arcadeScores = await _loadCategoryScores(arcadeGames);
    gameScores['arcade_games'] = arcadeScores;
    
    // Strateji oyunları
    final strategyGames = ['mini_chess', 'tic_tac_toe', 'connect_four'];
    final strategyScores = await _loadCategoryScores(strategyGames);
    gameScores['strategy_games'] = strategyScores;
    
    // Eğitici oyunlar
    final educationalGames = ['math_race', 'flag_quiz', 'word_learning'];
    final educationalScores = await _loadCategoryScores(educationalGames);
    gameScores['educational_games'] = educationalScores;
    
    // Fizik tabanlı oyunlar
    final physicsGames = ['angry_birds', 'cut_the_rope', 'doodle_jump'];
    final physicsScores = await _loadCategoryScores(physicsGames);
    gameScores['physics_games'] = physicsScores;
    
    // Ritim oyunları
    final rhythmGames = ['music_notes', 'piano_tiles'];
    final rhythmScores = await _loadCategoryScores(rhythmGames);
    gameScores['rhythm_games'] = rhythmScores;
    
    isLoading.value = false;
  }
  
  // Kategori skorlarını yükle
  Future<List<Map<String, dynamic>>> _loadCategoryScores(List<String> games) async {
    List<Map<String, dynamic>> categoryScores = [];
    
    for (final game in games) {
      final score = _storage.getInt('profile_highscore_$game', defaultValue: 0);
      final lastPlayed = _storage.getString('profile_lastplayed_$game', defaultValue: '');
      
      if (score > 0) {
        categoryScores.add({
          'game': game,
          'score': score,
          'lastPlayed': lastPlayed,
        });
      }
    }
    
    // Skora göre sırala (yüksekten düşüğe)
    categoryScores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    
    return categoryScores;
  }
  
  // Oyun adını getir
  String getGameName(String gameKey) {
    switch (gameKey) {
      // Refleks oyunları
      case 'rapid_tap': return 'Hızlı Tıklama Yarışı';
      case 'reaction_test': return 'Tepki Testi';
      case 'color_match': return 'Renk Eşleştirme';
      
      // Bulmaca oyunları
      case 'number_puzzle': return 'Sayı Bulmaca';
      case 'word_hunt': return 'Kelime Avı';
      case 'memory_cards': return 'Hafıza Kartları';
      
      // Arcade oyunları
      case 'snake': return 'Snake (Yılan)';
      case 'space_shooter': return 'Space Shooter';
      case 'bounce_ball': return 'Bounce Ball';
      
      // Strateji oyunları
      case 'mini_chess': return 'Mini Satranç';
      case 'tic_tac_toe': return 'Tic Tac Toe';
      case 'connect_four': return 'Connect Four';
      
      // Eğitici oyunlar
      case 'math_race': return 'Matematik Yarışı';
      case 'flag_quiz': return 'Bayrak Bilmece';
      case 'word_learning': return 'Kelime Öğrenme';
      
      // Fizik tabanlı oyunlar
      case 'angry_birds': return 'Angry Birds Benzeri';
      case 'cut_the_rope': return 'Cut the Rope Tarzı';
      case 'doodle_jump': return 'Doodle Jump Benzeri';
      
      // Ritim oyunları
      case 'music_notes': return 'Müzik Notaları';
      case 'piano_tiles': return 'Piano Tiles';
      
      default: return gameKey.tr;
    }
  }
  
  // Oyun ikonu getir
  IconData getGameIcon(String gameKey) {
    switch (gameKey) {
      // Refleks oyunları
      case 'rapid_tap': return Icons.touch_app;
      case 'reaction_test': return Icons.speed;
      case 'color_match': return Icons.palette;
      
      // Bulmaca oyunları
      case 'number_puzzle': return Icons.grid_on;
      case 'word_hunt': return Icons.search;
      case 'memory_cards': return Icons.flip;
      
      // Arcade oyunları
      case 'snake': return Icons.gesture;
      case 'space_shooter': return Icons.flight;
      case 'bounce_ball': return Icons.circle;
      
      // Strateji oyunları
      case 'mini_chess': return Icons.grain;
      case 'tic_tac_toe': return Icons.grid_3x3;
      case 'connect_four': return Icons.grid_4x4;
      
      // Eğitici oyunlar
      case 'math_race': return Icons.calculate;
      case 'flag_quiz': return Icons.flag;
      case 'word_learning': return Icons.translate;
      
      // Fizik tabanlı oyunlar
      case 'angry_birds': return Icons.filter_tilt_shift;
      case 'cut_the_rope': return Icons.content_cut;
      case 'doodle_jump': return Icons.arrow_upward;
      
      // Ritim oyunları
      case 'music_notes': return Icons.music_note;
      case 'piano_tiles': return Icons.piano;
      
      default: return Icons.games;
    }
  }
  
  // Kategori ikonu getir
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'reflex_games': return Icons.flash_on;
      case 'puzzle_games': return Icons.extension;
      case 'arcade_games': return Icons.sports_esports;
      case 'strategy_games': return Icons.psychology;
      case 'educational_games': return Icons.school;
      case 'physics_games': return Icons.science;
      case 'rhythm_games': return Icons.music_note;
      default: return Icons.games;
    }
  }
} 