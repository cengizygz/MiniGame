import 'dart:math';

class MemoryCardsModel {
  // Kart listesi (çiftleri içerir)
  final List<MemoryCard> cards;
  
  // Mevcut skor
  int score;
  
  // En yüksek skor
  final int highScore;
  
  // Hamle sayısı
  int moves;
  
  // Açılan kart çiftleri sayısı
  int matchedPairs;
  
  // Toplam çift sayısı
  final int totalPairs;
  
  // Oyun durumu
  bool isGameOver;
  
  // Zorluk seviyesi (1-3)
  final int difficulty;
  
  // Seçili kartlar
  List<int> selectedCardIndices;
  
  // Eşleşen kartlar
  List<int> matchedCardIndices;

  // Rastgele sayı üreteci
  final Random _random = Random();
  
  // Kartlar için kullanılabilecek ikon sembolleri
  static const List<String> cardSymbols = [
    '🍎', '🍌', '🍇', '🍉', '🍋', '🍓', '🍒', '🥝', // Meyveler
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', // Hayvanlar
    '🚗', '✈️', '🚢', '🚂', '🚕', '🚁', '🚤', '🏍️', // Taşıtlar
    '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏉', '🎱', // Sporlar
  ];
  
  // Başlangıç değerleri ile constructor
  MemoryCardsModel({
    List<MemoryCard>? initialCards,
    this.score = 0,
    this.highScore = 0,
    this.moves = 0,
    this.matchedPairs = 0,
    int? initialTotalPairs,
    this.isGameOver = false,
    this.difficulty = 1,
    List<int>? initialSelectedCardIndices,
    List<int>? initialMatchedCardIndices,
  }) : cards = initialCards ?? [],
       totalPairs = initialTotalPairs ?? _getPairCountForDifficulty(difficulty),
       selectedCardIndices = initialSelectedCardIndices ?? [],
       matchedCardIndices = initialMatchedCardIndices ?? [];
  
  // Zorluk seviyesine göre çift sayısını belirle
  static int _getPairCountForDifficulty(int difficulty) {
    switch (difficulty) {
      case 1: // Easy
        return 4; // 8 kart
      case 2: // Medium
        return 10; // 20 kart
      case 3: // Hard
        return 24; // 48 kart
      default:
        return 4;
    }
  }
  
  // Oyun tahtasını oluştur
  void initializeGame() {
    // Kartları temizle
    cards.clear();
    selectedCardIndices.clear();
    matchedCardIndices.clear();
    
    // Skor ve hamle sayısını sıfırla
    score = 0;
    moves = 0;
    matchedPairs = 0;
    isGameOver = false;
    
    // Kartları oluştur
    _createCardPairs(totalPairs);
    
    // Kartları karıştır
    _shuffleCards();
  }
  
  // Kart çiftlerini oluştur
  void _createCardPairs(int pairCount) {
    // Kullanılacak sembolleri seç
    final selectedSymbols = _getRandomSymbols(pairCount);
    
    // Her sembol için ikişer kart oluştur
    for (int i = 0; i < pairCount; i++) {
      final symbol = selectedSymbols[i];
      
      // İlk kart
      cards.add(MemoryCard(
        id: i * 2,
        symbol: symbol,
        isFlipped: false,
        isMatched: false,
      ));
      
      // Eşleşen ikinci kart
      cards.add(MemoryCard(
        id: i * 2 + 1,
        symbol: symbol,
        isFlipped: false,
        isMatched: false,
      ));
    }
  }
  
  // Rastgele semboller seç
  List<String> _getRandomSymbols(int count) {
    final availableSymbols = List<String>.from(cardSymbols);
    final selectedSymbols = <String>[];
    
    // İstenen sayıda rastgele sembol seç
    for (int i = 0; i < count; i++) {
      if (availableSymbols.isEmpty) break;
      
      final randomIndex = _random.nextInt(availableSymbols.length);
      selectedSymbols.add(availableSymbols[randomIndex]);
      availableSymbols.removeAt(randomIndex);
    }
    
    return selectedSymbols;
  }
  
  // Kartları karıştır
  void _shuffleCards() {
    cards.shuffle(_random);
    
    // Kart ID'lerini güncelle
    for (int i = 0; i < cards.length; i++) {
      cards[i] = cards[i].copyWith(id: i);
    }
  }
  
  // Kart seçimi
  bool selectCard(int index) {
    // Geçersiz indeks, kart zaten açık veya eşleşmiş
    if (index < 0 || index >= cards.length || 
        cards[index].isFlipped || 
        cards[index].isMatched ||
        selectedCardIndices.contains(index)) {
      return false;
    }
    // Kartı aç
    cards[index] = cards[index].copyWith(isFlipped: true);
    selectedCardIndices.add(index);
    // İki kart açıldıysa kontrol et
    if (selectedCardIndices.length == 2) {
      moves++;
      final firstIndex = selectedCardIndices[0];
      final secondIndex = selectedCardIndices[1];
      // Eşleşme kontrolü
      if (cards[firstIndex].symbol == cards[secondIndex].symbol) {
        // Eşleşme var!
        cards[firstIndex] = cards[firstIndex].copyWith(isMatched: true);
        cards[secondIndex] = cards[secondIndex].copyWith(isMatched: true);
        matchedCardIndices.addAll(selectedCardIndices);
        matchedPairs++;
        // Skoru güncelle
        score += 10 + (difficulty * 5); // Zorluk seviyesine göre puan
        // Oyun bitti mi?
        if (matchedPairs >= totalPairs) {
          isGameOver = true;
          // Bonus puanlar
          final movesBonus = (totalPairs * 3) - moves;
          if (movesBonus > 0) {
            score += movesBonus * difficulty;
          }
        }
      }
    }
    return true;
  }
  
  // Açılan kartları kapat
  void resetSelectedCards() {
    for (final index in selectedCardIndices) {
      if (!cards[index].isMatched) {
        cards[index] = cards[index].copyWith(isFlipped: false);
      }
    }
    
    selectedCardIndices.clear();
  }
  
  // Eşleşme kontrolü
  bool checkForMatch() {
    if (selectedCardIndices.length != 2) return false;
    
    final firstIndex = selectedCardIndices[0];
    final secondIndex = selectedCardIndices[1];
    
    return cards[firstIndex].symbol == cards[secondIndex].symbol;
  }
  
  // Modelin kopyasını oluştur
  MemoryCardsModel copyWith({
    List<MemoryCard>? initialCards,
    int? score,
    int? highScore,
    int? moves,
    int? matchedPairs,
    int? initialTotalPairs,
    bool? isGameOver,
    int? difficulty,
    List<int>? initialSelectedCardIndices,
    List<int>? initialMatchedCardIndices,
  }) {
    return MemoryCardsModel(
      initialCards: initialCards ?? cards,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      moves: moves ?? this.moves,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      initialTotalPairs: initialTotalPairs ?? totalPairs,
      isGameOver: isGameOver ?? this.isGameOver,
      difficulty: difficulty ?? this.difficulty,
      initialSelectedCardIndices: initialSelectedCardIndices ?? selectedCardIndices,
      initialMatchedCardIndices: initialMatchedCardIndices ?? matchedCardIndices,
    );
  }
}

// Kart sınıfı
class MemoryCard {
  final int id;
  final String symbol;
  final bool isFlipped;
  final bool isMatched;
  
  const MemoryCard({
    required this.id,
    required this.symbol,
    required this.isFlipped,
    required this.isMatched,
  });
  
  // Immutable yapı için kopya oluşturucu
  MemoryCard copyWith({
    int? id,
    String? symbol,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
  
  // Kartın kopyasını oluştur
  MemoryCard copy() {
    return copyWith();
  }
} 