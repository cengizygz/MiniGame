import 'dart:math';

class WordHuntModel {
  // Oyun alanı (grid)
  final List<List<String>> grid;
  
  // Mevcut skor
  int score;
  
  // En yüksek skor
  final int highScore;
  
  // Bulunan kelimeler listesi
  final List<String> foundWords;
  
  // Oyun içindeki gizli kelimeler listesi
  final List<String> hiddenWords;
  
  // Oyun durumu
  bool isGameOver;
  bool isGameWon;
  
  // Kalan süre (saniye)
  int remainingTime;
  
  // Oyun zorluk seviyesi
  final int difficulty;
  
  // Rastgele sayı üreteci
  final Random _random = Random();
  
  // Harfler
  final List<String> turkishLetters = [
    'A', 'B', 'C', 'Ç', 'D', 'E', 'F', 'G', 'Ğ', 'H', 'I', 'İ', 
    'J', 'K', 'L', 'M', 'N', 'O', 'Ö', 'P', 'R', 'S', 'Ş', 'T', 
    'U', 'Ü', 'V', 'Y', 'Z'
  ];
  
  // Başlangıç değerleri ile constructor
  WordHuntModel({
    List<List<String>>? initialGrid,
    this.score = 0,
    this.highScore = 0,
    List<String>? initialHiddenWords,
    List<String>? initialFoundWords,
    this.isGameOver = false,
    this.isGameWon = false,
    this.remainingTime = 180, // 3 dakika
    this.difficulty = 1,
  }) : grid = initialGrid ?? List.generate(
          8, (_) => List.generate(8, (_) => '')
        ),
        hiddenWords = initialHiddenWords ?? [],
        foundWords = initialFoundWords ?? [];
  
  // Oyun tahtasını sıfırla
  void resetGame() {
    // Skoru sıfırla
    score = 0;
    
    // Bulunan kelimeleri temizle
    foundWords.clear();
    
    // Oyun durumunu sıfırla
    isGameOver = false;
    isGameWon = false;
    
    // Zorluk seviyesine göre süreyi ayarla
    remainingTime = 120 + difficulty * 60; // 2-5 dakika arası
    
    // Yeni kelimeler oluştur
    generateHiddenWords();
    
    // Yeni grid oluştur
    generateNewGrid();
  }
  
  // Gizli kelimeleri oluştur
  void generateHiddenWords() {
    // Türkçe kelime veritabanından rastgele kelimeler seç
    // Bu örnek için basit bir liste ile gösteriyoruz
    hiddenWords.clear();
    
    // Zorluk seviyesine göre 5-15 kelime
    int wordCount = 5 + difficulty * 5;
    final sampleWords = [
      'KALEM', 'DEFTER', 'KİTAP', 'OKUL', 'SINIF', 'ÖĞRETMEN', 
      'ÖĞRENCİ', 'KÜTÜPHANE', 'ÇANTA', 'TAHTA', 'SİLGİ', 'MASA', 
      'SANDALYE', 'BİLGİSAYAR', 'TELEFON', 'OYUN', 'PENCERE', 'KAPI', 
      'BARDAK', 'TABAK', 'ÇATAL', 'KAŞIK', 'BINA', 'BAHÇE', 'AĞAÇ', 
      'ÇİÇEK', 'GÜNEŞ', 'YILDIZ', 'AY', 'KÖPEK', 'KEDİ', 'FARE'
    ];
    
    // Rastgele kelimeler seç
    while (hiddenWords.length < wordCount && sampleWords.isNotEmpty) {
      final index = _random.nextInt(sampleWords.length);
      hiddenWords.add(sampleWords[index]);
      sampleWords.removeAt(index);
    }
  }
  
  // Tahta için yeni grid oluştur
  void generateNewGrid() {
    // Önce tüm grid'i temizle
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        grid[i][j] = '';
      }
    }
    
    // Gizli kelimeleri grid'e yerleştir
    for (String word in hiddenWords) {
      _placeWordInGrid(word);
    }
    
    // Boş kalan hücreleri rastgele harflerle doldur
    _fillEmptyCells();
  }
  
  // Grid'e kelime yerleştir
  bool _placeWordInGrid(String word) {
    // Kelimeyi yerleştirmek için 10 deneme yap
    for (int attempt = 0; attempt < 10; attempt++) {
      // Rastgele yön seç (0: yatay, 1: dikey, 2: çapraz aşağı, 3: çapraz yukarı)
      int direction = _random.nextInt(4);
      
      // Rastgele başlangıç pozisyonu seç
      int startRow, startCol;
      
      if (direction == 0) { // Yatay
        startRow = _random.nextInt(grid.length);
        startCol = _random.nextInt(grid[0].length - word.length + 1);
      } else if (direction == 1) { // Dikey
        startRow = _random.nextInt(grid.length - word.length + 1);
        startCol = _random.nextInt(grid[0].length);
      } else if (direction == 2) { // Çapraz aşağı
        startRow = _random.nextInt(grid.length - word.length + 1);
        startCol = _random.nextInt(grid[0].length - word.length + 1);
      } else { // Çapraz yukarı
        startRow = _random.nextInt(grid.length - word.length + 1) + word.length - 1;
        startCol = _random.nextInt(grid[0].length - word.length + 1);
      }
      
      // Kelimeyi yerleştirmeyi dene
      if (_tryPlaceWord(word, startRow, startCol, direction)) {
        return true;
      }
    }
    
    // 10 denemede de yerleştiremediyse başarısız
    return false;
  }
  
  // Kelimeyi belirtilen pozisyona yerleştirmeyi dene
  bool _tryPlaceWord(String word, int startRow, int startCol, int direction) {
    // Kelime karakterlerini yerleştirmeden önce kontrol et
    for (int i = 0; i < word.length; i++) {
      int row, col;
      
      if (direction == 0) { // Yatay
        row = startRow;
        col = startCol + i;
      } else if (direction == 1) { // Dikey
        row = startRow + i;
        col = startCol;
      } else if (direction == 2) { // Çapraz aşağı
        row = startRow + i;
        col = startCol + i;
      } else { // Çapraz yukarı
        row = startRow - i;
        col = startCol + i;
      }
      
      // Hücre boş değilse ve aynı harfi içermiyorsa, yerleştirilemez
      if (grid[row][col] != '' && grid[row][col] != word[i]) {
        return false;
      }
    }
    
    // Kontrol başarılıysa, kelimeyi yerleştir
    for (int i = 0; i < word.length; i++) {
      int row, col;
      
      if (direction == 0) { // Yatay
        row = startRow;
        col = startCol + i;
      } else if (direction == 1) { // Dikey
        row = startRow + i;
        col = startCol;
      } else if (direction == 2) { // Çapraz aşağı
        row = startRow + i;
        col = startCol + i;
      } else { // Çapraz yukarı
        row = startRow - i;
        col = startCol + i;
      }
      
      grid[row][col] = word[i];
    }
    
    return true;
  }
  
  // Boş hücreleri rastgele harflerle doldur
  void _fillEmptyCells() {
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] == '') {
          grid[i][j] = turkishLetters[_random.nextInt(turkishLetters.length)];
        }
      }
    }
  }
  
  // Kelime bulunduğunda çağrılır
  bool findWord(String word) {
    // Kelimenin geçerli olup olmadığını kontrol et
    if (!hiddenWords.contains(word) || foundWords.contains(word)) {
      return false;
    }
    
    // Kelimeyi bulunanlar listesine ekle
    foundWords.add(word);
    
    // Puanı güncelle (kelimenin uzunluğuna göre)
    score += word.length * 10;
    
    // Oyun tamamlandı mı kontrol et
    if (foundWords.length == hiddenWords.length) {
      isGameWon = true;
      isGameOver = true;
    }
    
    return true;
  }
  
  // Süreyi azalt (her saniye çağrılır)
  bool decrementTime() {
    if (remainingTime > 0) {
      remainingTime--;
      
      // Süre bittiyse oyun biter
      if (remainingTime == 0) {
        isGameOver = true;
      }
      
      return true;
    }
    return false;
  }
  
  // Model kopyası oluştur
  WordHuntModel copy() {
    List<List<String>> gridCopy = List.generate(
      grid.length,
      (i) => List.generate(grid[i].length, (j) => grid[i][j]),
    );
    
    return WordHuntModel(
      initialGrid: gridCopy,
      score: score,
      highScore: highScore,
      initialHiddenWords: List.from(hiddenWords),
      initialFoundWords: List.from(foundWords),
      isGameOver: isGameOver,
      isGameWon: isGameWon,
      remainingTime: remainingTime,
      difficulty: difficulty,
    );
  }
} 