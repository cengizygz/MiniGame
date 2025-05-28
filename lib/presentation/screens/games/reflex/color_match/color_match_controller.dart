import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../../../../../infrastructure/services/storage/storage_service.dart';
import '../../../../../infrastructure/services/audio/audio_service.dart';
import 'color_match_model.dart';

class ColorMatchController extends GetxController {
  // Servisler
  final StorageService storageService = Get.find<StorageService>();
  final AudioService audioService = Get.find<AudioService>();
  
  // Oyun Durumu
  final RxBool isPlaying = false.obs;
  final RxBool isShowingSequence = false.obs;
  final RxBool isPlayerTurn = false.obs;
  final RxBool gameOver = false.obs;
  
  // Seviye ve Puan
  final RxInt level = 1.obs;
  final RxInt score = 0.obs;
  final RxInt highScore = 0.obs;
  
  // Renk Dizileri
  final RxList<ColorModel> sequence = <ColorModel>[].obs;
  final RxList<ColorModel> playerSequence = <ColorModel>[].obs;
  
  // Zamanlayıcılar
  Timer? sequenceTimer;
  Timer? pauseTimer;
  
  // Animasyon
  final RxInt highlightedColorId = 0.obs;
  
  // Oyun ayarları
  final Random random = Random();
  final int initialSequenceLength = 3; // Başlangıç seviyesi için renk sayısı
  final int sequenceShowDuration = 1000; // Her rengin gösterilme süresi (ms)
  
  @override
  void onInit() {
    super.onInit();
    _loadHighScore();
  }
  
  void _loadHighScore() {
    highScore.value = storageService.getInt('color_match_high_score', defaultValue: 0);
  }
  
  void _saveHighScore() {
    if (score.value > highScore.value) {
      highScore.value = score.value;
      storageService.setInt('color_match_high_score', score.value);
    }
  }
  
  // Oyunu başlat
  void startGame() {
    // Değişkenleri sıfırla
    level.value = 1;
    score.value = 0;
    sequence.clear();
    playerSequence.clear();
    
    // Oyun durumunu güncelle
    isPlaying.value = true;
    isShowingSequence.value = false;
    isPlayerTurn.value = false;
    gameOver.value = false;
    
    // İlk seviyeyi başlat
    startLevel();
  }
  
  // Yeni seviye başlat
  void startLevel() {
    // Yeni renk dizisi oluştur
    _generateSequence();
    
    // Kısa bir bekleme sonrası diziyi göster
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isPlaying.value) {
        _showSequence();
      }
    });
  }
  
  // Renk dizisi oluştur
  void _generateSequence() {
    // Mevcut diziyi koru ve yeni renk ekle
    if (level.value == 1) {
      // İlk seviyede başlangıç uzunluğunda bir dizi oluştur
      sequence.clear();
      for (int i = 0; i < initialSequenceLength; i++) {
        final randomColor = GameColors.allColors[random.nextInt(GameColors.allColors.length)];
        sequence.add(randomColor);
      }
    } else {
      // Sonraki seviyelerde mevcut diziye bir renk ekle
      final randomColor = GameColors.allColors[random.nextInt(GameColors.allColors.length)];
      sequence.add(randomColor);
    }
  }
  
  // Renk dizisini göster
  void _showSequence() {
    if (!isPlaying.value) return;
    
    isShowingSequence.value = true;
    isPlayerTurn.value = false;
    
    int index = 0;
    
    // Her rengi sırayla göster
    void showNextColor() {
      if (!isPlaying.value) return;
      
      if (index < sequence.length) {
        // Rengi vurgula
        highlightedColorId.value = sequence[index].id;
        
        // Belirli bir süre sonra bir sonraki renge geç
        Future.delayed(Duration(milliseconds: sequenceShowDuration), () {
          if (!isPlaying.value) return;
          
          highlightedColorId.value = 0;
          index++;
          
          // Kısa bir bekleme sonra bir sonraki rengi göster
          Future.delayed(const Duration(milliseconds: 500), () {
            if (isPlaying.value) {
              showNextColor();
            }
          });
        });
      } else {
        // Tüm renkler gösterildi, oyuncunun sırası
        isShowingSequence.value = false;
        
        // Kısa bir bekleme sonrası oyuncunun sırası
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (isPlaying.value) {
            isPlayerTurn.value = true;
            playerSequence.clear();
          }
        });
      }
    }
    
    // İlk rengi göster
    showNextColor();
  }
  
  // Oyuncu renk seçtiğinde
  void onColorTap(ColorModel color) {
    // Eğer oyuncu sırası değilse, hiçbir şey yapma
    if (!isPlayerTurn.value || gameOver.value) return;
    
    // Rengi vurgula
    highlightedColorId.value = color.id;
    
    // Ses çal
    // audioService.playSound('sounds/color_${color.id}.mp3');
    
    // Oyuncunun seçimini ekle
    playerSequence.add(color);
    
    // Kısa bir süre sonra vurgulamayı kaldır
    pauseTimer = Timer(const Duration(milliseconds: 300), () {
      highlightedColorId.value = 0;
      
      // Seçim kontrolü
      _checkPlayerSequence();
    });
  }
  
  // Oyuncu dizisini kontrol et
  void _checkPlayerSequence() {
    // Son seçilen rengi kontrol et
    int lastIndex = playerSequence.length - 1;
    
    if (playerSequence[lastIndex] != sequence[lastIndex]) {
      // Yanlış seçim, oyun bitti
      _endGame();
      return;
    }
    
    // Dizi tamamlandı mı kontrol et
    if (playerSequence.length == sequence.length) {
      // Seviye tamamlandı
      _levelComplete();
    }
  }
  
  // Seviye tamamlandı
  void _levelComplete() {
    isPlayerTurn.value = false;
    
    // Puanı artır
    score.value += level.value * 10;
    
    // Seviyeyi artır
    level.value++;
    
    // Highscore güncelle
    _saveHighScore();
    
    // Başarı sesi çal
    // audioService.playSound('sounds/success.mp3');
    
    // Kısa bir süre bekle ve sonraki seviyeye geç
    pauseTimer = Timer(const Duration(seconds: 1), () {
      startLevel();
    });
  }
  
  // Oyun sonu
  void _endGame() {
    isPlaying.value = false;
    isPlayerTurn.value = false;
    gameOver.value = true;
    
    // Başarısızlık sesi çal
    // audioService.playSound('sounds/fail.mp3');
    
    // Highscore güncelle
    _saveHighScore();
  }
  
  // Oyunu sıfırla
  void resetGame() {
    // Zamanlayıcıları temizle
    sequenceTimer?.cancel();
    pauseTimer?.cancel();
    
    // Değişkenleri sıfırla
    highlightedColorId.value = 0;
    isPlaying.value = false;
    isShowingSequence.value = false;
    isPlayerTurn.value = false;
    gameOver.value = false;
    sequence.clear();
    playerSequence.clear();
  }
  
  void endGame() {
    isPlaying.value = false;
    gameOver.value = true;
    
    // Yüksek skoru kaydet
    _saveHighScore();
  }
  
  @override
  void onClose() {
    sequenceTimer?.cancel();
    pauseTimer?.cancel();
    super.onClose();
  }
} 