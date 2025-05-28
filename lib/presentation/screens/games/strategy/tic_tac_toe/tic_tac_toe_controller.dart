import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../infrastructure/services/ad/ad_service.dart';

enum TicTacToeMark { empty, x, o }
enum TicTacToeResult { ongoing, xWins, oWins, draw }
enum AIDifficulty { easy, medium, hard }

class TicTacToeController extends GetxController {
  // Oyun tahtası 3x3
  List<List<TicTacToeMark>> board = List.generate(
    3, 
    (_) => List.filled(3, TicTacToeMark.empty)
  );
  
  // Oyun durumu
  bool isPlayerTurn = true; // true -> oyuncu (X), false -> AI (O)
  TicTacToeResult gameResult = TicTacToeResult.ongoing;
  
  // Oyuncu ve AI puanları
  int playerScore = 0;
  int aiScore = 0;
  int draws = 0;
  
  // AI zorluk seviyesi
  AIDifficulty aiDifficulty = AIDifficulty.medium;
  
  // Son hamle animasyonu
  int? lastMoveRow;
  int? lastMoveCol;
  
  // İpucu için değişkenler
  List<List<int>>? hintMove;
  final RxBool showingHint = false.obs;
  final RxInt hintCount = 0.obs;
  
  // Reklam servisi
  late final AdService adService;
  
  @override
  void onInit() {
    super.onInit();
    // Reklam servisini bul
    adService = Get.find<AdService>();
    resetBoard();
  }
  
  // Tahtayı sıfırla
  void resetBoard() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board[i][j] = TicTacToeMark.empty;
      }
    }
    
    isPlayerTurn = true;
    gameResult = TicTacToeResult.ongoing;
    lastMoveRow = null;
    lastMoveCol = null;
    hintMove = null;
    showingHint.value = false;
    
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
  void setDifficulty(AIDifficulty difficulty) {
    aiDifficulty = difficulty;
    resetBoard();
  }
  
  // İpucu isteme
  void requestHint() {
    if (!isPlayerTurn || gameResult != TicTacToeResult.ongoing) return;
    
    if (hintCount.value <= 0) {
      // İpucu hakkı yoksa reklam izlemeyi teklif et
      Get.dialog(
        AlertDialog(
          title: const Text('İpucu Yok'),
          content: const Text('İpucu kullanmak için reklam izlemek ister misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                showHintAdvert();
              },
              child: const Text('Reklam İzle'),
            ),
          ],
        ),
      );
      return;
    }
    
    // İpucu hakkını kullan
    hintCount.value--;
    
    // İpucu göster
    hintMove = _getBestMove();
    showingHint.value = true;
    update();
    
    // 3 saniye sonra ipucunu gizle
    Future.delayed(Duration(seconds: 3), () {
      showingHint.value = false;
      update();
    });
  }
  
  // Rewarded reklam gösterme
  void showHintAdvert() {
    if (adService.isRewardedAdReady.value) {
      adService.showRewardedAd(onUserEarnedReward: () {
        // Reklam izlendikten sonra ipucu hakkı ver
        hintCount.value += 3;
        Get.snackbar(
          'Ödül Kazandın!',
          '3 ipucu hakkı kazandın',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      });
    } else {
      Get.snackbar(
        'Reklam Hazır Değil',
        'Lütfen daha sonra tekrar deneyin',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // En iyi hamleyi bul (ipucu için)
  List<List<int>>? _getBestMove() {
    List<List<int>> emptyCells = [];
    
    // Boş kareleri bul
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == TicTacToeMark.empty) {
          emptyCells.add([i, j]);
        }
      }
    }
    
    if (emptyCells.isEmpty) return null;
    
    // Kazanabilecek hamle var mı?
    for (var cell in emptyCells) {
      // Hamleyi simüle et
      board[cell[0]][cell[1]] = TicTacToeMark.x;
      
      // Bu hamle kazandırıyor mu?
      if (_checkWinner() == TicTacToeMark.x) {
        // Hamleyi geri al
        board[cell[0]][cell[1]] = TicTacToeMark.empty;
        return [cell]; // Listeyi bir liste içinde döndür
      }
      
      // Hamleyi geri al
      board[cell[0]][cell[1]] = TicTacToeMark.empty;
    }
    
    // Kaybedecek durumda mı? Engelle
    for (var cell in emptyCells) {
      // Eğer AI buraya oynarsa
      board[cell[0]][cell[1]] = TicTacToeMark.o;
      
      // AI kazanır mı?
      if (_checkWinner() == TicTacToeMark.o) {
        // Hamleyi geri al
        board[cell[0]][cell[1]] = TicTacToeMark.empty;
        return [cell]; // Listeyi bir liste içinde döndür
      }
      
      // Hamleyi geri al
      board[cell[0]][cell[1]] = TicTacToeMark.empty;
    }
    
    // Merkez boşsa, merkezi öner
    if (board[1][1] == TicTacToeMark.empty) {
      return [[1, 1]]; // Listeyi bir liste içinde döndür
    }
    
    // Köşeler boşsa, köşe öner
    List<List<int>> corners = [[0, 0], [0, 2], [2, 0], [2, 2]];
    for (var corner in corners) {
      if (board[corner[0]][corner[1]] == TicTacToeMark.empty) {
        return [corner]; // Listeyi bir liste içinde döndür
      }
    }
    
    // Rastgele bir boş hücre öner
    return [emptyCells[math.Random().nextInt(emptyCells.length)]]; // Listeyi bir liste içinde döndür
  }
  
  // Kare tıklamasını işle
  void handleTap(int row, int col) {
    // Eğer kare boş değilse, oyun bittiyse veya oyuncunun sırası değilse işlem yapma
    if (board[row][col] != TicTacToeMark.empty || 
        gameResult != TicTacToeResult.ongoing ||
        !isPlayerTurn) {
      return;
    }
    
    // Oyuncu hamlesi (X)
    makeMove(row, col, TicTacToeMark.x);
    
    // Oyun durumunu kontrol et
    checkGameState();
    
    // Eğer oyun devam ediyorsa AI hamlesini yap
    if (gameResult == TicTacToeResult.ongoing) {
      // Oyun devam ediyor, sıra AI'da
      isPlayerTurn = false;
      update();
      
      // Kısa bir gecikme ile AI hamlesi yap
      Future.delayed(const Duration(milliseconds: 500), () {
        makeAIMove();
        checkGameState();
        isPlayerTurn = true;
        update();
      });
    }
  }
  
  // Hamle yap
  void makeMove(int row, int col, TicTacToeMark mark) {
    board[row][col] = mark;
    lastMoveRow = row;
    lastMoveCol = col;
    update();
  }
  
  // AI hamlesi yap
  void makeAIMove() {
    switch (aiDifficulty) {
      case AIDifficulty.easy:
        _makeRandomMove();
        break;
      case AIDifficulty.medium:
        // %70 olasılıkla akıllı hamle, %30 olasılıkla rastgele hamle
        math.Random().nextDouble() < 0.7
            ? _makeMediumMove()
            : _makeRandomMove();
        break;
      case AIDifficulty.hard:
        _makeBestMove();
        break;
    }
  }
  
  // Rastgele boş kareye hamle yap (kolay mod)
  void _makeRandomMove() {
    List<List<int>> emptyCells = [];
    
    // Boş kareleri bul
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == TicTacToeMark.empty) {
          emptyCells.add([i, j]);
        }
      }
    }
    
    if (emptyCells.isNotEmpty) {
      final randomIndex = math.Random().nextInt(emptyCells.length);
      final move = emptyCells[randomIndex];
      makeMove(move[0], move[1], TicTacToeMark.o);
    }
  }
  
  // Orta seviye AI hareketi
  void _makeMediumMove() {
    // Önce kazanabilecek hamleyi kontrol et
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == TicTacToeMark.empty) {
          // Hamleyi simüle et
          board[i][j] = TicTacToeMark.o;
          
          // Eğer bu hamle kazandırıyorsa, yap
          if (_checkWinner() == TicTacToeMark.o) {
            lastMoveRow = i;
            lastMoveCol = j;
            return;
          }
          
          // Hamleyi geri al
          board[i][j] = TicTacToeMark.empty;
        }
      }
    }
    
    // Sonra oyuncunun kazanmasını engelleyecek hamleyi kontrol et
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == TicTacToeMark.empty) {
          // Hamleyi simüle et
          board[i][j] = TicTacToeMark.x;
          
          // Eğer oyuncu bu hamle ile kazanacaksa, engelle
          if (_checkWinner() == TicTacToeMark.x) {
            board[i][j] = TicTacToeMark.o;
            lastMoveRow = i;
            lastMoveCol = j;
            return;
          }
          
          // Hamleyi geri al
          board[i][j] = TicTacToeMark.empty;
        }
      }
    }
    
    // Merkez boşsa, merkezi tercih et
    if (board[1][1] == TicTacToeMark.empty) {
      board[1][1] = TicTacToeMark.o;
      lastMoveRow = 1;
      lastMoveCol = 1;
      return;
    }
    
    // Köşeler boşsa, köşeleri tercih et
    List<List<int>> corners = [[0, 0], [0, 2], [2, 0], [2, 2]];
    List<List<int>> emptyCorners = [];
    
    for (var corner in corners) {
      if (board[corner[0]][corner[1]] == TicTacToeMark.empty) {
        emptyCorners.add(corner);
      }
    }
    
    if (emptyCorners.isNotEmpty) {
      final randomCorner = emptyCorners[math.Random().nextInt(emptyCorners.length)];
      board[randomCorner[0]][randomCorner[1]] = TicTacToeMark.o;
      lastMoveRow = randomCorner[0];
      lastMoveCol = randomCorner[1];
      return;
    }
    
    // Rastgele boş kare seç
    _makeRandomMove();
  }
  
  // Minimax algoritması ile en iyi hamleyi bul (zor mod)
  void _makeBestMove() {
    int bestScore = -1000;
    int bestRow = -1;
    int bestCol = -1;
    
    // Tüm boş kareleri dene
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == TicTacToeMark.empty) {
          // Hamleyi simüle et
          board[i][j] = TicTacToeMark.o;
          
          // Bu hamlenin skorunu hesapla
          int score = _minimax(0, false);
          
          // Hamleyi geri al
          board[i][j] = TicTacToeMark.empty;
          
          // Daha iyi skor bulunduysa güncelle
          if (score > bestScore) {
            bestScore = score;
            bestRow = i;
            bestCol = j;
          }
        }
      }
    }
    
    // En iyi hamleyi yap
    if (bestRow != -1 && bestCol != -1) {
      makeMove(bestRow, bestCol, TicTacToeMark.o);
    } else {
      // Bir şeyler ters gitti, rastgele hamle yap
      _makeRandomMove();
    }
  }
  
  // Minimax algoritması
  int _minimax(int depth, bool isMaximizing) {
    // Terminal durumları kontrol et
    final winner = _checkWinner();
    
    if (winner == TicTacToeMark.o) return 10 - depth; // AI kazandı
    if (winner == TicTacToeMark.x) return depth - 10; // Oyuncu kazandı
    if (_isBoardFull()) return 0; // Beraberlik
    
    if (isMaximizing) {
      // AI'ın sırası (maksimize et)
      int bestScore = -1000;
      
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == TicTacToeMark.empty) {
            board[i][j] = TicTacToeMark.o;
            int score = _minimax(depth + 1, false);
            board[i][j] = TicTacToeMark.empty;
            bestScore = math.max(score, bestScore);
          }
        }
      }
      
      return bestScore;
    } else {
      // Oyuncunun sırası (minimize et)
      int bestScore = 1000;
      
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == TicTacToeMark.empty) {
            board[i][j] = TicTacToeMark.x;
            int score = _minimax(depth + 1, true);
            board[i][j] = TicTacToeMark.empty;
            bestScore = math.min(score, bestScore);
          }
        }
      }
      
      return bestScore;
    }
  }
  
  // Oyun durumunu kontrol et
  void checkGameState() {
    final winner = _checkWinner();
    
    if (winner != TicTacToeMark.empty) {
      // Kazanan var
      if (winner == TicTacToeMark.x) {
        gameResult = TicTacToeResult.xWins;
        playerScore++;
      } else {
        gameResult = TicTacToeResult.oWins;
        aiScore++;
      }
    } else if (_isBoardFull()) {
      // Beraberlik
      gameResult = TicTacToeResult.draw;
      draws++;
    }
    
    update();
  }
  
  // Kazanan var mı kontrol et
  TicTacToeMark _checkWinner() {
    // Satırları kontrol et
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != TicTacToeMark.empty && 
          board[i][0] == board[i][1] && 
          board[i][1] == board[i][2]) {
        return board[i][0];
      }
    }
    
    // Sütunları kontrol et
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != TicTacToeMark.empty && 
          board[0][i] == board[1][i] && 
          board[1][i] == board[2][i]) {
        return board[0][i];
      }
    }
    
    // Çaprazları kontrol et
    if (board[0][0] != TicTacToeMark.empty && 
        board[0][0] == board[1][1] && 
        board[1][1] == board[2][2]) {
      return board[0][0];
    }
    
    if (board[0][2] != TicTacToeMark.empty && 
        board[0][2] == board[1][1] && 
        board[1][1] == board[2][0]) {
      return board[0][2];
    }
    
    return TicTacToeMark.empty;
  }
  
  // Tahta dolu mu kontrol et
  bool _isBoardFull() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == TicTacToeMark.empty) {
          return false;
        }
      }
    }
    return true;
  }
} 