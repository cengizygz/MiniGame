import 'package:get/get.dart';
import 'dart:math' as math;

enum ConnectFourDisk { empty, red, yellow }
enum ConnectFourGameState { ongoing, redWins, yellowWins, draw }
enum ConnectFourAIDifficulty { easy, medium, hard }

class ConnectFourController extends GetxController {
  // Oyun tahtası 7 sütun x 6 satır
  List<List<ConnectFourDisk>> board = List.generate(
    6, // 6 satır
    (_) => List.filled(7, ConnectFourDisk.empty) // 7 sütun
  );
  
  // Oyun durumu
  bool isPlayerTurn = true; // true -> oyuncu (kırmızı), false -> AI (sarı)
  ConnectFourGameState gameState = ConnectFourGameState.ongoing;
  
  // Skor
  int playerScore = 0;
  int aiScore = 0;
  int draws = 0;
  
  // AI zorluk seviyesi
  ConnectFourAIDifficulty aiDifficulty = ConnectFourAIDifficulty.medium;
  
  // Son hamle için animasyon
  int? lastMoveRow;
  int? lastMoveCol;
  
  // Animasyon durumu
  bool isAnimating = false;
  
  @override
  void onInit() {
    super.onInit();
    resetBoard();
  }
  
  // Tahtayı sıfırla
  void resetBoard() {
    // Tüm hücreleri boşalt
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 7; col++) {
        board[row][col] = ConnectFourDisk.empty;
      }
    }
    
    // Oyun durumunu sıfırla
    isPlayerTurn = true;
    gameState = ConnectFourGameState.ongoing;
    lastMoveRow = null;
    lastMoveCol = null;
    isAnimating = false;
    
    update();
  }
  
  // Oyunu yeniden başlat
  void resetGame() {
    resetBoard();
    playerScore = 0;
    aiScore = 0;
    draws = 0;
    
    update();
  }
  
  // Zorluk seviyesini ayarla
  void setDifficulty(ConnectFourAIDifficulty difficulty) {
    aiDifficulty = difficulty;
    resetBoard();
  }
  
  // Sütuna disk bırakma (kullanıcı hamlesi)
  void dropDisk(int column) {
    // Oyun bittiyse, AI sırası ise veya animasyon sürüyorsa işlem yapma
    if (gameState != ConnectFourGameState.ongoing || 
        !isPlayerTurn || 
        isAnimating) {
      return;
    }
    
    // Sütun doluysa işlem yapma
    if (board[0][column] != ConnectFourDisk.empty) {
      return;
    }
    
    // Disk için düşüş pozisyonunu bul (en alt boş hücre)
    int dropRow = _findLowestEmptyRow(column);
    
    // Eğer geçerli bir pozisyon bulunduysa diski yerleştir
    if (dropRow != -1) {
      _animateDropDisk(dropRow, column, ConnectFourDisk.red);
    }
  }
  
  // Disk düşürme animasyonu
  void _animateDropDisk(int row, int col, ConnectFourDisk disk) {
    isAnimating = true;
    update();
    
    // Animasyon tamamlandığında
    Future.delayed(const Duration(milliseconds: 500), () {
      // Diski yerleştir
      board[row][col] = disk;
      lastMoveRow = row;
      lastMoveCol = col;
      isAnimating = false;
      
      // Oyun durumunu kontrol et
      _checkGameState();
      
      // Eğer oyun bitmemişse ve AI sırası geldiyse AI hamle yap
      if (gameState == ConnectFourGameState.ongoing && !isPlayerTurn) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _makeAIMove();
        });
      }
      
      update();
    });
  }
  
  // En alttaki boş satırı bul
  int _findLowestEmptyRow(int column) {
    for (int row = 5; row >= 0; row--) {
      if (board[row][column] == ConnectFourDisk.empty) {
        return row;
      }
    }
    return -1; // Sütun dolu
  }
  
  // Oyun durumunu kontrol et
  void _checkGameState() {
    // Kazanan var mı kontrol et
    ConnectFourDisk winner = _checkWinner();
    
    if (winner != ConnectFourDisk.empty) {
      // Kazanan belirli
      if (winner == ConnectFourDisk.red) {
        gameState = ConnectFourGameState.redWins;
        playerScore++;
      } else {
        gameState = ConnectFourGameState.yellowWins;
        aiScore++;
      }
    } 
    // Tahta dolu mu kontrol et
    else if (_isBoardFull()) {
      gameState = ConnectFourGameState.draw;
      draws++;
    } 
    // Oyun devam ediyor
    else {
      // Sıra değiştir
      isPlayerTurn = !isPlayerTurn;
    }
    
    update();
  }
  
  // Kazanan var mı kontrol et
  ConnectFourDisk _checkWinner() {
    // Yatay kontrol
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] != ConnectFourDisk.empty &&
            board[row][col] == board[row][col + 1] &&
            board[row][col] == board[row][col + 2] &&
            board[row][col] == board[row][col + 3]) {
          return board[row][col];
        }
      }
    }
    
    // Dikey kontrol
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 7; col++) {
        if (board[row][col] != ConnectFourDisk.empty &&
            board[row][col] == board[row + 1][col] &&
            board[row][col] == board[row + 2][col] &&
            board[row][col] == board[row + 3][col]) {
          return board[row][col];
        }
      }
    }
    
    // Sağ aşağı çapraz kontrol
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] != ConnectFourDisk.empty &&
            board[row][col] == board[row + 1][col + 1] &&
            board[row][col] == board[row + 2][col + 2] &&
            board[row][col] == board[row + 3][col + 3]) {
          return board[row][col];
        }
      }
    }
    
    // Sol aşağı çapraz kontrol
    for (int row = 0; row < 3; row++) {
      for (int col = 3; col < 7; col++) {
        if (board[row][col] != ConnectFourDisk.empty &&
            board[row][col] == board[row + 1][col - 1] &&
            board[row][col] == board[row + 2][col - 2] &&
            board[row][col] == board[row + 3][col - 3]) {
          return board[row][col];
        }
      }
    }
    
    return ConnectFourDisk.empty; // Kazanan yok
  }
  
  // Tahta dolu mu kontrol et
  bool _isBoardFull() {
    for (int col = 0; col < 7; col++) {
      if (board[0][col] == ConnectFourDisk.empty) {
        return false;
      }
    }
    return true;
  }
  
  // AI hamlesi yap
  void _makeAIMove() {
    // Eğer oyun bittiyse işlem yapma
    if (gameState != ConnectFourGameState.ongoing) {
      return;
    }
    
    int col;
    
    // AI zorluk seviyesine göre hamle stratejisini belirle
    switch (aiDifficulty) {
      case ConnectFourAIDifficulty.easy:
        col = _getEasyAIMove();
        break;
      case ConnectFourAIDifficulty.medium:
        // %70 olasılıkla akıllı hamle, %30 olasılıkla rastgele
        col = math.Random().nextDouble() < 0.7
            ? _getMediumAIMove()
            : _getEasyAIMove();
        break;
      case ConnectFourAIDifficulty.hard:
        col = _getHardAIMove();
        break;
    }
    
    // Bulunan sütuna diski yerleştir
    int dropRow = _findLowestEmptyRow(col);
    if (dropRow != -1) {
      _animateDropDisk(dropRow, col, ConnectFourDisk.yellow);
    }
  }
  
  // Kolay AI hamlesi (rastgele)
  int _getEasyAIMove() {
    List<int> availableColumns = [];
    
    // Boş sütunları bul
    for (int col = 0; col < 7; col++) {
      if (board[0][col] == ConnectFourDisk.empty) {
        availableColumns.add(col);
      }
    }
    
    // Rastgele bir sütun seç
    if (availableColumns.isNotEmpty) {
      return availableColumns[math.Random().nextInt(availableColumns.length)];
    } else {
      return 0; // Bu olmamalı, güvenlik için
    }
  }
  
  // Orta seviye AI hamlesi
  int _getMediumAIMove() {
    // 1. Bir sonraki hamlede kazanabilecek mi kontrol et
    for (int col = 0; col < 7; col++) {
      int row = _findLowestEmptyRow(col);
      if (row != -1) {
        // Hamleyi simüle et
        board[row][col] = ConnectFourDisk.yellow;
        
        // Kazanabilir mi kontrol et
        bool canWin = _checkWinner() == ConnectFourDisk.yellow;
        
        // Hamleyi geri al
        board[row][col] = ConnectFourDisk.empty;
        
        if (canWin) {
          return col; // Kazandıracak hamle
        }
      }
    }
    
    // 2. Oyuncunun bir sonraki hamlede kazanmasını engelle
    for (int col = 0; col < 7; col++) {
      int row = _findLowestEmptyRow(col);
      if (row != -1) {
        // Oyuncu hamlesini simüle et
        board[row][col] = ConnectFourDisk.red;
        
        // Oyuncu kazanabilir mi kontrol et
        bool playerCanWin = _checkWinner() == ConnectFourDisk.red;
        
        // Hamleyi geri al
        board[row][col] = ConnectFourDisk.empty;
        
        if (playerCanWin) {
          return col; // Oyuncuyu engelleme hamlesi
        }
      }
    }
    
    // 3. Merkez sütunu tercih et
    int centerCol = 3;
    if (board[0][centerCol] == ConnectFourDisk.empty) {
      return centerCol;
    }
    
    // 4. Rastgele hamle yap
    return _getEasyAIMove();
  }
  
  // Zor seviye AI hamlesi (Minimax algoritması)
  int _getHardAIMove() {
    int bestScore = -1000;
    int bestCol = 0;
    
    // Tüm olası hamleleri değerlendir
    for (int col = 0; col < 7; col++) {
      int row = _findLowestEmptyRow(col);
      if (row != -1) {
        // Hamleyi simüle et
        board[row][col] = ConnectFourDisk.yellow;
        
        // Hamlenin skorunu hesapla (3 seviye derinlikte)
        int score = _minimax(3, false, -1000, 1000);
        
        // Hamleyi geri al
        board[row][col] = ConnectFourDisk.empty;
        
        // Daha iyi skor bulunduysa güncelle
        if (score > bestScore) {
          bestScore = score;
          bestCol = col;
        }
      }
    }
    
    return bestCol;
  }
  
  // Minimax algoritması (Alpha-Beta pruning ile)
  int _minimax(int depth, bool isMaximizing, int alpha, int beta) {
    // Terminal durumları kontrol et
    ConnectFourDisk winner = _checkWinner();
    
    if (winner == ConnectFourDisk.yellow) return 100 + depth; // AI kazandı
    if (winner == ConnectFourDisk.red) return -100 - depth; // Oyuncu kazandı
    if (_isBoardFull() || depth == 0) return _evaluateBoard(); // Beraberlik veya derinlik limiti
    
    if (isMaximizing) {
      // AI'ın sırası (sarı diskler) - maksimize etmeye çalış
      int maxEval = -1000;
      
      for (int col = 0; col < 7; col++) {
        int row = _findLowestEmptyRow(col);
        if (row != -1) {
          // Hamleyi simüle et
          board[row][col] = ConnectFourDisk.yellow;
          
          // Hamlenin değerini hesapla
          int eval = _minimax(depth - 1, false, alpha, beta);
          
          // Hamleyi geri al
          board[row][col] = ConnectFourDisk.empty;
          
          // En iyi değeri güncelle
          maxEval = math.max(maxEval, eval);
          alpha = math.max(alpha, eval);
          
          // Alpha-Beta budama
          if (beta <= alpha) break;
        }
      }
      
      return maxEval;
    } else {
      // Oyuncunun sırası (kırmızı diskler) - minimize etmeye çalış
      int minEval = 1000;
      
      for (int col = 0; col < 7; col++) {
        int row = _findLowestEmptyRow(col);
        if (row != -1) {
          // Hamleyi simüle et
          board[row][col] = ConnectFourDisk.red;
          
          // Hamlenin değerini hesapla
          int eval = _minimax(depth - 1, true, alpha, beta);
          
          // Hamleyi geri al
          board[row][col] = ConnectFourDisk.empty;
          
          // En iyi değeri güncelle
          minEval = math.min(minEval, eval);
          beta = math.min(beta, eval);
          
          // Alpha-Beta budama
          if (beta <= alpha) break;
        }
      }
      
      return minEval;
    }
  }
  
  // Tahtanın mevcut durumuna göre bir değerlendirme skoru döndür
  int _evaluateBoard() {
    int score = 0;
    
    // Yatay değerlendirme
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 4; col++) {
        score += _evaluateWindow(
          board[row][col],
          board[row][col + 1],
          board[row][col + 2],
          board[row][col + 3]
        );
      }
    }
    
    // Dikey değerlendirme
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 7; col++) {
        score += _evaluateWindow(
          board[row][col],
          board[row + 1][col],
          board[row + 2][col],
          board[row + 3][col]
        );
      }
    }
    
    // Sağ aşağı çapraz değerlendirme
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        score += _evaluateWindow(
          board[row][col],
          board[row + 1][col + 1],
          board[row + 2][col + 2],
          board[row + 3][col + 3]
        );
      }
    }
    
    // Sol aşağı çapraz değerlendirme
    for (int row = 0; row < 3; row++) {
      for (int col = 3; col < 7; col++) {
        score += _evaluateWindow(
          board[row][col],
          board[row + 1][col - 1],
          board[row + 2][col - 2],
          board[row + 3][col - 3]
        );
      }
    }
    
    // Merkez sütun bonusu (merkezdeki diskler daha değerlidir)
    for (int row = 0; row < 6; row++) {
      if (board[row][3] == ConnectFourDisk.yellow) {
        score += 3;
      } else if (board[row][3] == ConnectFourDisk.red) {
        score -= 3;
      }
    }
    
    return score;
  }
  
  // 4'lü bir pencereyi değerlendir
  int _evaluateWindow(ConnectFourDisk disk1, ConnectFourDisk disk2, 
                     ConnectFourDisk disk3, ConnectFourDisk disk4) {
    int score = 0;
    
    // Sarı diskler (AI)
    int yellowCount = 0;
    // Kırmızı diskler (oyuncu)
    int redCount = 0;
    // Boş hücreler
    int emptyCount = 0;
    
    // Disk sayılarını hesapla
    if (disk1 == ConnectFourDisk.yellow) yellowCount++;
    else if (disk1 == ConnectFourDisk.red) redCount++;
    else emptyCount++;
    
    if (disk2 == ConnectFourDisk.yellow) yellowCount++;
    else if (disk2 == ConnectFourDisk.red) redCount++;
    else emptyCount++;
    
    if (disk3 == ConnectFourDisk.yellow) yellowCount++;
    else if (disk3 == ConnectFourDisk.red) redCount++;
    else emptyCount++;
    
    if (disk4 == ConnectFourDisk.yellow) yellowCount++;
    else if (disk4 == ConnectFourDisk.red) redCount++;
    else emptyCount++;
    
    // Pencerenin değerini hesapla
    if (yellowCount == 4) score += 100; // AI 4'lü
    else if (yellowCount == 3 && emptyCount == 1) score += 5; // AI 3'lü (potansiyel 4'lü)
    else if (yellowCount == 2 && emptyCount == 2) score += 2; // AI 2'li (gelişebilir)
    
    if (redCount == 4) score -= 100; // Oyuncu 4'lü
    else if (redCount == 3 && emptyCount == 1) score -= 10; // Oyuncu 3'lü (tehlikeli)
    else if (redCount == 2 && emptyCount == 2) score -= 2; // Oyuncu 2'li
    
    return score;
  }
  
  // Hamle geçerli mi?
  bool isValidMove(int column) {
    return column >= 0 && column < 7 && board[0][column] == ConnectFourDisk.empty;
  }
  
  // İki oyunculu mod için rakibin rengi
  ConnectFourDisk getCurrentDiskColor() {
    return isPlayerTurn ? ConnectFourDisk.red : ConnectFourDisk.yellow;
  }
} 