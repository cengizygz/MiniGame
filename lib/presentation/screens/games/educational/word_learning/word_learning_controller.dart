import 'package:get/get.dart';
import 'dart:math';
import 'dart:async';

// Zorluk seviyesi
enum WordLearningDifficulty {
  beginner,
  intermediate,
  advanced
}

// Kelime çalışma modu
enum WordLearningMode {
  flashcards,
  quiz,
  matching
}

// Kelime modeli
class Word {
  final String english;
  final String turkish;
  final String? exampleSentence;
  final String category;
  
  Word({
    required this.english,
    required this.turkish,
    this.exampleSentence,
    required this.category,
  });
}

// Öğrenme istatistikleri
class WordStats {
  int timesShown = 0;
  int timesCorrect = 0;
  double progress = 0.0; // 0.0 - 1.0 arası
  DateTime lastSeen = DateTime.now();
  
  WordStats();
  
  // İlerleme durumunu güncelle
  void updateProgress(bool wasCorrect) {
    timesShown++;
    if (wasCorrect) {
      timesCorrect++;
    }
    
    // Doğruluk oranına göre ilerleme durumunu güncelle
    progress = timesCorrect / timesShown;
    lastSeen = DateTime.now();
  }
}

class WordLearningController extends GetxController {
  // Temel değişkenler
  int score = 0;
  int totalWords = 0;
  int learnedWords = 0;
  
  // Mevcut kelime
  Word? currentWord;
  int currentWordIndex = 0;
  
  // Mevcut seçenekler (quiz modu için)
  List<String> currentOptions = [];
  
  // Kelime listeleri ve istatistikleri
  List<Word> allWords = [];
  Map<String, WordStats> wordStats = {};
  
  // Oyun ayarları
  WordLearningDifficulty difficulty = WordLearningDifficulty.beginner;
  WordLearningMode mode = WordLearningMode.flashcards;
  
  // Flashcards ayarları
  bool showingTranslation = false;
  
  // Çalışma durumu
  bool isStudyActive = false;
  
  // Random nesnesi
  final Random random = Random();
  
  // Animasyon durumu
  bool showCorrectAnimation = false;
  bool showWrongAnimation = false;
  
  // Kategoriler
  List<String> categories = [];
  RxString selectedCategory = 'Tümü'.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Kelime verilerini oluştur
    _initializeWords();
    // Kategorileri hazırla
    _initializeCategories();
    update();
  }
  
  // Kelimeleri oluştur
  void _initializeWords() {
    // Başlangıç seviyesi kelimeleri
    List<Word> beginnerWords = [
      Word(english: 'hello', turkish: 'merhaba', category: 'Temel', exampleSentence: 'Hello, how are you?'),
      Word(english: 'goodbye', turkish: 'hoşça kal', category: 'Temel', exampleSentence: 'Goodbye, see you tomorrow.'),
      Word(english: 'thank you', turkish: 'teşekkür ederim', category: 'Temel', exampleSentence: 'Thank you for your help.'),
      Word(english: 'yes', turkish: 'evet', category: 'Temel', exampleSentence: 'Yes, I agree with you.'),
      Word(english: 'no', turkish: 'hayır', category: 'Temel', exampleSentence: 'No, I don\'t want to go.'),
      Word(english: 'please', turkish: 'lütfen', category: 'Temel', exampleSentence: 'Please, help me with this.'),
      Word(english: 'sorry', turkish: 'özür dilerim', category: 'Temel', exampleSentence: 'I\'m sorry for being late.'),
      Word(english: 'water', turkish: 'su', category: 'Yiyecek', exampleSentence: 'I need some water.'),
      Word(english: 'food', turkish: 'yemek', category: 'Yiyecek', exampleSentence: 'The food is delicious.'),
      Word(english: 'house', turkish: 'ev', category: 'Ev', exampleSentence: 'My house is very big.'),
      Word(english: 'car', turkish: 'araba', category: 'Ulaşım', exampleSentence: 'I drive a red car.'),
      Word(english: 'book', turkish: 'kitap', category: 'Eğitim', exampleSentence: 'I\'m reading a good book.'),
      Word(english: 'friend', turkish: 'arkadaş', category: 'İnsan', exampleSentence: 'She is my best friend.'),
      Word(english: 'time', turkish: 'zaman', category: 'Zaman', exampleSentence: 'What time is it?'),
      Word(english: 'day', turkish: 'gün', category: 'Zaman', exampleSentence: 'Today is a beautiful day.'),
    ];
    
    // Orta seviye kelimeleri
    List<Word> intermediateWords = [
      Word(english: 'happiness', turkish: 'mutluluk', category: 'Duygular', exampleSentence: 'Happiness is important for mental health.'),
      Word(english: 'success', turkish: 'başarı', category: 'Başarı', exampleSentence: 'Hard work leads to success.'),
      Word(english: 'experience', turkish: 'deneyim', category: 'İş', exampleSentence: 'I have five years of experience.'),
      Word(english: 'opportunity', turkish: 'fırsat', category: 'İş', exampleSentence: 'This is a great opportunity for you.'),
      Word(english: 'challenge', turkish: 'zorluk', category: 'Başarı', exampleSentence: 'Life is full of challenges.'),
      Word(english: 'improve', turkish: 'geliştirmek', category: 'Eğitim', exampleSentence: 'I want to improve my English.'),
      Word(english: 'environment', turkish: 'çevre', category: 'Doğa', exampleSentence: 'We must protect the environment.'),
      Word(english: 'technology', turkish: 'teknoloji', category: 'Teknoloji', exampleSentence: 'Technology is changing rapidly.'),
      Word(english: 'responsibility', turkish: 'sorumluluk', category: 'İş', exampleSentence: 'With great power comes great responsibility.'),
      Word(english: 'communication', turkish: 'iletişim', category: 'İnsan', exampleSentence: 'Good communication is essential.'),
      Word(english: 'decision', turkish: 'karar', category: 'İş', exampleSentence: 'This is a difficult decision to make.'),
      Word(english: 'solution', turkish: 'çözüm', category: 'İş', exampleSentence: 'We need to find a solution to this problem.'),
      Word(english: 'culture', turkish: 'kültür', category: 'Kültür', exampleSentence: 'Every country has its own culture.'),
      Word(english: 'tradition', turkish: 'gelenek', category: 'Kültür', exampleSentence: 'This is an old family tradition.'),
      Word(english: 'education', turkish: 'eğitim', category: 'Eğitim', exampleSentence: 'Education is the key to success.'),
    ];
    
    // İleri seviye kelimeleri
    List<Word> advancedWords = [
      Word(english: 'comprehensive', turkish: 'kapsamlı', category: 'Akademik', exampleSentence: 'We need a comprehensive analysis of the situation.'),
      Word(english: 'collaborate', turkish: 'işbirliği yapmak', category: 'İş', exampleSentence: 'Let\'s collaborate on this project.'),
      Word(english: 'intriguing', turkish: 'ilgi çekici', category: 'Duygular', exampleSentence: 'That\'s an intriguing question.'),
      Word(english: 'ambiguous', turkish: 'belirsiz', category: 'Akademik', exampleSentence: 'The instructions were ambiguous.'),
      Word(english: 'scrutinize', turkish: 'dikkatle incelemek', category: 'İş', exampleSentence: 'We need to scrutinize these results.'),
      Word(english: 'perpetual', turkish: 'sürekli', category: 'Zaman', exampleSentence: 'It\'s a perpetual cycle of innovation.'),
      Word(english: 'meticulous', turkish: 'titiz', category: 'Karakter', exampleSentence: 'She is meticulous about details.'),
      Word(english: 'articulate', turkish: 'açıkça ifade etmek', category: 'İletişim', exampleSentence: 'He can articulate complex ideas easily.'),
      Word(english: 'pragmatic', turkish: 'pragmatik', category: 'Karakter', exampleSentence: 'We need a pragmatic approach to this problem.'),
      Word(english: 'resilient', turkish: 'dirençli', category: 'Karakter', exampleSentence: 'Children are remarkably resilient.'),
      Word(english: 'eloquent', turkish: 'belagatli', category: 'İletişim', exampleSentence: 'She gave an eloquent speech.'),
      Word(english: 'profound', turkish: 'derin', category: 'Akademik', exampleSentence: 'That\'s a profound insight.'),
      Word(english: 'indispensable', turkish: 'vazgeçilmez', category: 'İş', exampleSentence: 'She has become indispensable to the team.'),
      Word(english: 'innovative', turkish: 'yenilikçi', category: 'Teknoloji', exampleSentence: 'We need innovative solutions.'),
      Word(english: 'perspective', turkish: 'bakış açısı', category: 'Akademik', exampleSentence: 'I see it from a different perspective.'),
    ];
    
    // Zorluk seviyesine göre kelime listesini oluştur
    switch (difficulty) {
      case WordLearningDifficulty.beginner:
        allWords = beginnerWords;
        break;
      case WordLearningDifficulty.intermediate:
        allWords = [...beginnerWords, ...intermediateWords];
        break;
      case WordLearningDifficulty.advanced:
        allWords = [...beginnerWords, ...intermediateWords, ...advancedWords];
        break;
    }
    
    // Başlangıç istatistiklerini oluştur
    for (var word in allWords) {
      wordStats[word.english] = WordStats();
    }
    
    totalWords = allWords.length;
    // İlk kelimeyi hazırla
    if (allWords.isNotEmpty) {
      currentWord = allWords[0];
      currentWordIndex = 0;
    }
  }
  
  // Kategorileri hazırla
  void _initializeCategories() {
    // Benzersiz kategorileri topla
    Set<String> uniqueCategories = {};
    for (var word in allWords) {
      uniqueCategories.add(word.category);
    }
    
    // Kategori listesini oluştur (sıralı)
    categories = uniqueCategories.toList()..sort();
    // "Tümü" kategorisini ekle
    categories.insert(0, 'Tümü');
  }
  
  // Zorluk seviyesini değiştir
  void setDifficulty(WordLearningDifficulty newDifficulty) {
    difficulty = newDifficulty;
    // Kelimeleri yeniden oluştur
    _initializeWords();
    // Kategorileri güncelle
    _initializeCategories();
    update();
  }
  
  // Çalışma modunu değiştir
  void setMode(WordLearningMode newMode) {
    mode = newMode;
    // Moda göre ayarları sıfırla
    showingTranslation = false;
    
    // Quiz modu için seçenekleri hazırla
    if (mode == WordLearningMode.quiz) {
      _prepareQuizOptions();
    }
    
    update();
  }
  
  // Kategori değiştir
  void setCategory(String category) {
    selectedCategory.value = category;
    // İlk kelimeden başla
    _resetToFirstWordInCategory();
    update();
  }
  
  // Kategori için ilk kelimeye geç
  void _resetToFirstWordInCategory() {
    if (selectedCategory.value == 'Tümü') {
      currentWordIndex = 0;
      if (allWords.isNotEmpty) {
        currentWord = allWords[currentWordIndex];
      }
    } else {
      // Seçili kategorideki ilk kelimeyi bul
      for (int i = 0; i < allWords.length; i++) {
        if (allWords[i].category == selectedCategory.value) {
          currentWordIndex = i;
          currentWord = allWords[i];
          break;
        }
      }
    }
    
    // Quiz modu için seçenekleri hazırla
    if (mode == WordLearningMode.quiz) {
      _prepareQuizOptions();
    }
    
    showingTranslation = false;
  }
  
  // Çalışmayı başlat
  void startStudy() {
    isStudyActive = true;
    
    // Seçilen moda göre başlatma
    if (mode == WordLearningMode.quiz) {
      _prepareQuizOptions();
    } else if (mode == WordLearningMode.matching) {
      // Eşleştirme modunda yapılacak ek hazırlıklar
    }
    
    update();
  }
  
  // Çalışmayı durdur
  void stopStudy() {
    isStudyActive = false;
    update();
  }
  
  // Flashcard modunda çevirme
  void flipCard() {
    showingTranslation = !showingTranslation;
    update();
  }
  
  // Sonraki kelimeye geç
  void nextWord() {
    if (selectedCategory.value == 'Tümü') {
      currentWordIndex = (currentWordIndex + 1) % allWords.length;
      currentWord = allWords[currentWordIndex];
    } else {
      // Seçili kategorideki bir sonraki kelimeyi bul
      int startIndex = currentWordIndex;
      do {
        currentWordIndex = (currentWordIndex + 1) % allWords.length;
        // Bir tam tur attıysak başlangıç indeksine geri dön
        if (currentWordIndex == startIndex) break;
      } while (allWords[currentWordIndex].category != selectedCategory.value);
      
      currentWord = allWords[currentWordIndex];
    }
    
    showingTranslation = false;
    
    // Quiz modu için seçenekleri hazırla
    if (mode == WordLearningMode.quiz) {
      _prepareQuizOptions();
    }
    
    update();
  }
  
  // Önceki kelimeye geç
  void previousWord() {
    if (selectedCategory.value == 'Tümü') {
      currentWordIndex = (currentWordIndex - 1 + allWords.length) % allWords.length;
      currentWord = allWords[currentWordIndex];
    } else {
      // Seçili kategorideki bir önceki kelimeyi bul
      int startIndex = currentWordIndex;
      do {
        currentWordIndex = (currentWordIndex - 1 + allWords.length) % allWords.length;
        // Bir tam tur attıysak başlangıç indeksine geri dön
        if (currentWordIndex == startIndex) break;
      } while (allWords[currentWordIndex].category != selectedCategory.value);
      
      currentWord = allWords[currentWordIndex];
    }
    
    showingTranslation = false;
    
    // Quiz modu için seçenekleri hazırla
    if (mode == WordLearningMode.quiz) {
      _prepareQuizOptions();
    }
    
    update();
  }
  
  // Quiz için seçenekleri hazırla
  void _prepareQuizOptions() {
    if (currentWord == null) return;
    
    currentOptions = [currentWord!.turkish]; // Doğru cevap
    
    // 3 yanlış seçenek ekle
    while (currentOptions.length < 4) {
      int randomIndex = random.nextInt(allWords.length);
      String randomOption = allWords[randomIndex].turkish;
      
      // Aynı seçeneği tekrar ekleme
      if (!currentOptions.contains(randomOption)) {
        currentOptions.add(randomOption);
      }
    }
    
    // Seçenekleri karıştır
    currentOptions.shuffle();
  }
  
  // Quiz cevabını kontrol et
  void checkAnswer(String selectedAnswer) {
    if (currentWord == null) return;
    
    bool isCorrect = selectedAnswer == currentWord!.turkish;
    
    // Kelime istatistiklerini güncelle
    wordStats[currentWord!.english]?.updateProgress(isCorrect);
    
    // Animasyon göster
    if (isCorrect) {
      score += 10;
      showCorrectAnimation = true;
    } else {
      showWrongAnimation = true;
    }
    
    update();
    
    // Animasyonu kapat ve sonraki kelimeye geç
    Future.delayed(const Duration(milliseconds: 1000), () {
      showCorrectAnimation = false;
      showWrongAnimation = false;
      nextWord();
    });
  }
  
  // Öğrenilen kelime sayısını hesapla
  void calculateLearnedWords() {
    learnedWords = 0;
    for (var stats in wordStats.values) {
      if (stats.progress >= 0.7) { // %70 ve üzeri doğru yanıtlananlar
        learnedWords++;
      }
    }
    update();
  }
  
  // İlerleme yüzdesini hesapla
  double getProgressPercentage() {
    if (totalWords == 0) return 0;
    calculateLearnedWords();
    return learnedWords / totalWords * 100;
  }
  
  // Karışık kelime getir
  void getRandomWord() {
    if (allWords.isEmpty) return;
    
    if (selectedCategory.value == 'Tümü') {
      currentWordIndex = random.nextInt(allWords.length);
      currentWord = allWords[currentWordIndex];
    } else {
      // Seçili kategorideki kelimelerden rastgele birini seç
      List<int> categoryIndices = [];
      for (int i = 0; i < allWords.length; i++) {
        if (allWords[i].category == selectedCategory.value) {
          categoryIndices.add(i);
        }
      }
      
      if (categoryIndices.isNotEmpty) {
        int randomIndex = random.nextInt(categoryIndices.length);
        currentWordIndex = categoryIndices[randomIndex];
        currentWord = allWords[currentWordIndex];
      }
    }
    
    showingTranslation = false;
    
    // Quiz modu için seçenekleri hazırla
    if (mode == WordLearningMode.quiz) {
      _prepareQuizOptions();
    }
    
    update();
  }
} 