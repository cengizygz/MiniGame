import 'dart:math';

class NumberPuzzleModel {
  // Oyun tahtası (4x4 matris)
  final List<List<int>> board;
  
  // Mevcut skor
  int score;
  
  // En yüksek skor
  final int highScore;
  
  // Oyun durumu
  bool isGameOver;
  bool hasWon;
  
  // Rastgele sayı üreteci
  final Random _random = Random();
  
  // Başlangıç değerleri ile constructor
  NumberPuzzleModel({
    List<List<int>>? initialBoard,
    this.score = 0,
    this.highScore = 0,
    this.isGameOver = false,
    this.hasWon = false,
  }) : board = initialBoard ?? List.generate(
          4, (_) => List.generate(4, (_) => 0)
        );
  
  // Boş bir tahta oluştur
  void resetBoard() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        board[i][j] = 0;
      }
    }
    
    score = 0;
    isGameOver = false;
    hasWon = false;
    
    // İki rasgele hücreye değer ekle
    addRandomTile();
    addRandomTile();
  }
  
  // Tahtadaki boş hücrelerin listesini al
  List<List<int>> getEmptyCells() {
    List<List<int>> emptyCells = [];
    
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) {
          emptyCells.add([i, j]);
        }
      }
    }
    
    return emptyCells;
  }
  
  // Rasgele bir boş hücreye 2 veya 4 ekle
  void addRandomTile() {
    List<List<int>> emptyCells = getEmptyCells();
    
    if (emptyCells.isEmpty) return;
    
    // Rasgele bir boş hücre seç
    List<int> cell = emptyCells[_random.nextInt(emptyCells.length)];
    
    // %90 ihtimalle 2, %10 ihtimalle 4 değeri ekle
    board[cell[0]][cell[1]] = _random.nextDouble() < 0.9 ? 2 : 4;
  }
  
  // Herhangi bir hamle yapılabilir mi kontrol et
  bool canMove() {
    // Boş hücre varsa hamle yapılabilir
    if (getEmptyCells().isNotEmpty) return true;
    
    // Satırlarda yan yana aynı değerli hücreler varsa hamle yapılabilir
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == board[i][j + 1]) return true;
      }
    }
    
    // Sütunlarda alt alta aynı değerli hücreler varsa hamle yapılabilir
    for (int j = 0; j < 4; j++) {
      for (int i = 0; i < 3; i++) {
        if (board[i][j] == board[i + 1][j]) return true;
      }
    }
    
    // Hiçbir hamle yapılamaz, oyun bitti
    return false;
  }
  
  // Hamle sonrası durumu kontrol et
  void checkGameState() {
    // 2048 değeri varsa oyun kazanıldı
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 2048) {
          hasWon = true;
          return;
        }
      }
    }
    
    // Hamle yapılamıyorsa oyun bitti
    if (!canMove()) {
      isGameOver = true;
    }
  }
  
  // Sola kaydırma hamlesi
  bool moveLeft() {
    bool moved = false;
    
    for (int i = 0; i < 4; i++) {
      // Önce sıfırları çıkart
      List<int> row = board[i].where((x) => x != 0).toList();
      
      // Aynı değerleri birleştir
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j] == row[j + 1]) {
          row[j] *= 2;
          score += row[j]; // Skoru arttır
          row.removeAt(j + 1);
          moved = true;
        }
      }
      
      // Eksik yerleri sıfırla doldur
      while (row.length < 4) {
        row.add(0);
      }
      
      // Herhangi bir değişiklik olduysa moved = true
      for (int j = 0; j < 4; j++) {
        if (board[i][j] != row[j]) {
          moved = true;
        }
      }
      
      // Satırı güncelle
      board[i] = row;
    }
    
    return moved;
  }
  
  // Sağa kaydırma hamlesi
  bool moveRight() {
    bool moved = false;
    
    for (int i = 0; i < 4; i++) {
      // Önce sıfırları çıkart
      List<int> row = board[i].where((x) => x != 0).toList();
      
      // Aynı değerleri sondan başlayarak birleştir
      for (int j = row.length - 1; j > 0; j--) {
        if (row[j] == row[j - 1]) {
          row[j] *= 2;
          score += row[j]; // Skoru arttır
          row.removeAt(j - 1);
          moved = true;
        }
      }
      
      // Eksik yerleri sıfırla doldur
      while (row.length < 4) {
        row.insert(0, 0); // Başa sıfır ekle
      }
      
      // Herhangi bir değişiklik olduysa moved = true
      for (int j = 0; j < 4; j++) {
        if (board[i][j] != row[j]) {
          moved = true;
        }
      }
      
      // Satırı güncelle
      board[i] = row;
    }
    
    return moved;
  }
  
  // Yukarı kaydırma hamlesi
  bool moveUp() {
    bool moved = false;
    
    for (int j = 0; j < 4; j++) {
      // Sütunu al
      List<int> col = [];
      for (int i = 0; i < 4; i++) {
        col.add(board[i][j]);
      }
      
      // Önce sıfırları çıkart
      col = col.where((x) => x != 0).toList();
      
      // Aynı değerleri birleştir
      for (int i = 0; i < col.length - 1; i++) {
        if (col[i] == col[i + 1]) {
          col[i] *= 2;
          score += col[i]; // Skoru arttır
          col.removeAt(i + 1);
          moved = true;
        }
      }
      
      // Eksik yerleri sıfırla doldur
      while (col.length < 4) {
        col.add(0);
      }
      
      // Herhangi bir değişiklik olduysa moved = true
      for (int i = 0; i < 4; i++) {
        if (board[i][j] != col[i]) {
          moved = true;
        }
      }
      
      // Sütunu güncelle
      for (int i = 0; i < 4; i++) {
        board[i][j] = col[i];
      }
    }
    
    return moved;
  }
  
  // Aşağı kaydırma hamlesi
  bool moveDown() {
    bool moved = false;
    
    for (int j = 0; j < 4; j++) {
      // Sütunu al
      List<int> col = [];
      for (int i = 0; i < 4; i++) {
        col.add(board[i][j]);
      }
      
      // Önce sıfırları çıkart
      col = col.where((x) => x != 0).toList();
      
      // Aynı değerleri sondan başlayarak birleştir
      for (int i = col.length - 1; i > 0; i--) {
        if (col[i] == col[i - 1]) {
          col[i] *= 2;
          score += col[i]; // Skoru arttır
          col.removeAt(i - 1);
          moved = true;
        }
      }
      
      // Eksik yerleri sıfırla doldur
      while (col.length < 4) {
        col.insert(0, 0); // Başa sıfır ekle
      }
      
      // Herhangi bir değişiklik olduysa moved = true
      for (int i = 0; i < 4; i++) {
        if (board[i][j] != col[i]) {
          moved = true;
        }
      }
      
      // Sütunu güncelle
      for (int i = 0; i < 4; i++) {
        board[i][j] = col[i];
      }
    }
    
    return moved;
  }
  
  // Yön koduna göre hamle yap
  bool move(int direction) {
    bool moved = false;
    
    switch (direction) {
      case 0: // Sol
        moved = moveLeft();
        break;
      case 1: // Sağ
        moved = moveRight();
        break;
      case 2: // Yukarı
        moved = moveUp();
        break;
      case 3: // Aşağı
        moved = moveDown();
        break;
    }
    
    // Eğer hamle yapıldıysa, yeni karo ekle
    if (moved) {
      addRandomTile();
      checkGameState();
    }
    
    return moved;
  }
  
  // Tahtanın kopyasını oluştur
  NumberPuzzleModel copy() {
    List<List<int>> boardCopy = List.generate(
      4,
      (i) => List.generate(4, (j) => board[i][j]),
    );
    
    return NumberPuzzleModel(
      initialBoard: boardCopy,
      score: score,
      highScore: highScore,
      isGameOver: isGameOver,
      hasWon: hasWon,
    );
  }
} 