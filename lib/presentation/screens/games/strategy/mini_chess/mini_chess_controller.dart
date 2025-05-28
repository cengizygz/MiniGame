import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/chess_piece.dart';
import 'models/chess_position.dart';
import 'models/chess_move.dart';
import 'dart:math' as math;
import '../../../../../infrastructure/services/ad/ad_service.dart';

class MiniChessController extends GetxController {
  // Oyun tahtası 6x6 boyutunda 
  // null -> boş kare, ChessPiece -> taş olan kare
  List<List<ChessPiece?>> board = List.generate(6, (_) => List.filled(6, null));
  
  // Oyun durumu
  bool isWhiteTurn = true; // true -> beyaz oynar, false -> siyah oynar
  bool isCheck = false; // Şah çekildi mi
  bool isCheckmate = false; // Mat oldu mu
  bool isStalemate = false; // Pat durumu var mı
  bool isGameOver = false; // Oyun bitti mi
  
  // Oyuncu seçimi ve hamle
  ChessPosition? selectedPosition;
  List<ChessPosition> validMoves = [];
  
  // Geçmiş hamleler (geri alma için)
  final List<Map<String, dynamic>> moveHistory = [];
  
  // Ele geçirilen taşlar
  final List<ChessPiece> capturedWhitePieces = [];
  final List<ChessPiece> capturedBlackPieces = [];
  
  // Zorluk seviyesi (1-kolay, 2-orta, 3-zor)
  int difficulty = 1;
  
  // İpucu gösterme modu
  bool showingHint = false;
  ChessPosition? hintFromPosition;
  ChessPosition? hintToPosition;
  
  // Reklam servisi
  late final AdService adService;
  
  // İpucu kullanım hakkı
  final hintCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Reklam servisini bul
    adService = Get.find<AdService>();
    
    setupBoard();
  }
  
  // Tahtayı başlangıç durumuna getirir
  void setupBoard() {
    // Tahtayı temizle
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        board[i][j] = null;
      }
    }
    
    // Beyaz taşları yerleştir (5. ve 4. satırlar)
    // 5. satır - ana taşlar
    board[5][0] = ChessPiece(type: ChessPieceType.rook, isWhite: true);
    board[5][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true);
    board[5][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true);
    board[5][3] = ChessPiece(type: ChessPieceType.queen, isWhite: true);
    board[5][4] = ChessPiece(type: ChessPieceType.king, isWhite: true);
    board[5][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true);
    
    // 4. satır - piyonlar
    for (int col = 0; col < 6; col++) {
      board[4][col] = ChessPiece(type: ChessPieceType.pawn, isWhite: true);
    }
    
    // Siyah taşları yerleştir (0. ve 1. satırlar)
    // 0. satır - ana taşlar
    board[0][0] = ChessPiece(type: ChessPieceType.rook, isWhite: false);
    board[0][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false);
    board[0][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false);
    board[0][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false);
    board[0][4] = ChessPiece(type: ChessPieceType.king, isWhite: false);
    board[0][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false);
    
    // 1. satır - piyonlar
    for (int col = 0; col < 6; col++) {
      board[1][col] = ChessPiece(type: ChessPieceType.pawn, isWhite: false);
    }
    
    // Oyun durumunu sıfırla
    isWhiteTurn = true;
    isCheck = false;
    isCheckmate = false;
    isStalemate = false;
    isGameOver = false;
    selectedPosition = null;
    validMoves.clear();
    moveHistory.clear();
    capturedWhitePieces.clear();
    capturedBlackPieces.clear();
    showingHint = false;
    hintFromPosition = null;
    hintToPosition = null;
    
    update();
  }
  
  // Belirli bir konumdaki taşı döndürür
  ChessPiece? getPieceAt(ChessPosition position) {
    if (!position.isValid()) return null;
    return board[position.row][position.col];
  }
  
  // Kare tıklamasını işler
  void handleSquareTap(ChessPosition position) {
    // İnsan oyuncunun sırası değilse veya oyun bittiyse işlem yapma
    if (!isHumanToPlay() || isGameOver) return;
    
    // İpucu modundaysa ipucu modunu kapat
    if (showingHint) {
      showingHint = false;
      hintFromPosition = null;
      hintToPosition = null;
      update();
    }
    
    final tappedPiece = getPieceAt(position);
    
    // Eğer önceden bir taş seçilmişse ve geçerli hamle yapıldıysa
    if (selectedPosition != null && validMoves.contains(position)) {
      // Hamleyi yap
      makeMove(ChessMove(selectedPosition!, position, capturedPiece: tappedPiece));
      
      // Seçimi temizle
      selectedPosition = null;
      validMoves.clear();
      
      // Oyun durumunu kontrol et
      checkGameState();
      
      // AI hareketi
      if (!isGameOver && !isHumanToPlay()) {
        Future.delayed(const Duration(milliseconds: 500), () {
          makeAIMove();
        });
      }
    } 
    // Yeni bir taş seçimi
    else if (tappedPiece != null && tappedPiece.isWhite == isWhiteTurn) {
      selectedPosition = position;
      validMoves = getValidMovesFor(position);
    } 
    // Boş kare veya rakip taş seçimi (seçimi temizle)
    else {
      selectedPosition = null;
      validMoves.clear();
    }
    
    update();
  }
  
  // Hamle yap
  void makeMove(ChessMove move) {
    final piece = getPieceAt(move.from);
    
    // Geçersiz hamle kontrolü
    if (piece == null) return;
    
    // Taşı hareket ettirmeden önce durumu kaydet (geri alma için)
    saveStateBeforeMove(move);
    
    // Ele geçirilen taş varsa ekle
    if (move.capturedPiece != null) {
      if (move.capturedPiece!.isWhite) {
        capturedWhitePieces.add(move.capturedPiece!);
      } else {
        capturedBlackPieces.add(move.capturedPiece!);
      }
    }
    
    // Taşı hareket ettir
    board[move.to.row][move.to.col] = piece;
    board[move.from.row][move.from.col] = null;
    
    // Taşın hareket ettiğini işaretle
    piece.hasMoved = true;
    
    // Sıra değiştir
    isWhiteTurn = !isWhiteTurn;
  }
  
  // Hamle öncesi durumu kaydet (geri alma için)
  void saveStateBeforeMove(ChessMove move) {
    // Derin kopyalama için mevcut tahtayı kaydet
    List<List<ChessPiece?>> boardCopy = List.generate(6, (i) => 
      List.generate(6, (j) => board[i][j]?.copy())
    );
    
    // Diğer durumları kaydet
    moveHistory.add({
      'move': move,
      'board': boardCopy,
      'isWhiteTurn': isWhiteTurn,
      'capturedWhitePieces': List<ChessPiece>.from(capturedWhitePieces),
      'capturedBlackPieces': List<ChessPiece>.from(capturedBlackPieces),
    });
  }
  
  // Hamleyi geri al
  void undo() {
    if (moveHistory.isEmpty) return;
    
    // Son durumu al
    final lastState = moveHistory.removeLast();
    
    // Tahtayı ve oyun durumunu geri yükle
    board = lastState['board'];
    isWhiteTurn = lastState['isWhiteTurn'];
    capturedWhitePieces.clear();
    capturedWhitePieces.addAll(lastState['capturedWhitePieces']);
    capturedBlackPieces.clear();
    capturedBlackPieces.addAll(lastState['capturedBlackPieces']);
    
    // Seçimi ve oyun durumunu temizle
    selectedPosition = null;
    validMoves.clear();
    isCheck = isKingInCheck(isWhiteTurn);
    isCheckmate = false;
    isStalemate = false;
    isGameOver = false;
    
    update();
  }
  
  // Geri alma yapılabilir mi
  bool get canUndo => moveHistory.isNotEmpty;
  
  // Belirli bir pozisyondaki taş için geçerli hamleleri döndürür
  List<ChessPosition> getValidMovesFor(ChessPosition position) {
    final piece = getPieceAt(position);
    if (piece == null) return [];
    
    // Tüm olası hamleleri al
    final allMoves = piece.generatePossibleMoves(position, getPieceAt);
    final validMoves = <ChessPosition>[];
    
    // Her hamleyi test et - şah çekildiyse geçersiz
    for (final move in allMoves) {
      if (isMoveLegal(move)) {
        validMoves.add(move.to);
      }
    }
    
    return validMoves;
  }
  
  // Hamlenin kurallara uygun olup olmadığını kontrol eder
  bool isMoveLegal(ChessMove move) {
    // Hamleyi simüle et
    simulateMove(move);
    
    // Kendi şahı tehdit altında mı kontrol et
    final isKingThreatened = isKingInCheck(board[move.to.row][move.to.col]!.isWhite);
    
    // Hamleyi geri al
    undoSimulatedMove(move);
    
    // Eğer kendi şahı tehdit altındaysa hamle geçersiz
    return !isKingThreatened;
  }
  
  // Bir hamleyi simüle et (kontrol için)
  void simulateMove(ChessMove move) {
    // Orijinal taşı hareket ettir
    final piece = board[move.from.row][move.from.col];
    move.capturedPiece = board[move.to.row][move.to.col]; // Hedefte bir taş varsa kaydet
    
    // Taşı hareket ettir
    board[move.to.row][move.to.col] = piece;
    board[move.from.row][move.from.col] = null;
  }
  
  // Simüle edilen hamleyi geri al
  void undoSimulatedMove(ChessMove move) {
    // Taşı eski konumuna geri getir
    final piece = board[move.to.row][move.to.col];
    board[move.from.row][move.from.col] = piece;
    
    // Ele geçirilen taşı geri koy veya hedefi temizle
    board[move.to.row][move.to.col] = move.capturedPiece;
  }
  
  // Şahın tehdit altında olup olmadığını kontrol et
  bool isKingInCheck(bool isWhiteKing) {
    // Şahın konumunu bul
    ChessPosition? kingPosition;
    
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 6; col++) {
        final piece = board[row][col];
        if (piece != null && 
            piece.type == ChessPieceType.king && 
            piece.isWhite == isWhiteKing) {
          kingPosition = ChessPosition(row, col);
          break;
        }
      }
      if (kingPosition != null) break;
    }
    
    if (kingPosition == null) return false; // Bu olmamalı ama güvenlik için
    
    // Tüm rakip taşları kontrol et
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 6; col++) {
        final piece = board[row][col];
        if (piece != null && piece.isWhite != isWhiteKing) {
          // Rakip taşın tüm hamlelerini al
          final position = ChessPosition(row, col);
          final moves = piece.generatePossibleMoves(position, getPieceAt);
          
          // Şahı tehdit eden bir hamle var mı
          for (final move in moves) {
            if (move.to == kingPosition) {
              return true; // Şah tehdit altında
            }
          }
        }
      }
    }
    
    return false; // Şah güvende
  }
  
  // Oyun durumunu kontrol et (şah, mat, pat)
  void checkGameState() {
    // Şah durumunu kontrol et
    isCheck = isKingInCheck(isWhiteTurn);
    
    // Olası hamle var mı kontrol et
    bool hasLegalMoves = false;
    
    // Tüm kendi taşları için hamle kontrolü
    for (int row = 0; row < 6 && !hasLegalMoves; row++) {
      for (int col = 0; col < 6 && !hasLegalMoves; col++) {
        final piece = board[row][col];
        if (piece != null && piece.isWhite == isWhiteTurn) {
          final position = ChessPosition(row, col);
          final moves = getValidMovesFor(position);
          if (moves.isNotEmpty) {
            hasLegalMoves = true;
            break;
          }
        }
      }
    }
    
    // Oyun durumunu güncelle
    if (!hasLegalMoves) {
      isGameOver = true;
      if (isCheck) {
        isCheckmate = true; // Şah mat
      } else {
        isStalemate = true; // Pat
      }
    }
    
    update();
  }
  
  // AI hamlesini yap
  void makeAIMove() {
    if (isGameOver || isHumanToPlay()) return;
    
    final aiMove = findBestMove();
    if (aiMove != null) {
      makeMove(aiMove);
      checkGameState();
    }
    
    update();
  }
  
  // AI için en iyi hamleyi bul (Minimax algoritması)
  ChessMove? findBestMove() {
    // Tüm olası hamleleri topla
    List<ChessMove> possibleMoves = [];
    
    // Tüm AI taşları için hamleleri topla
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 6; col++) {
        final piece = board[row][col];
        if (piece != null && piece.isWhite != isWhiteTurn) { // AI taşı
          final position = ChessPosition(row, col);
          final pieceMoves = piece.generatePossibleMoves(position, getPieceAt);
          
          // Sadece geçerli hamleleri ekle
          for (final move in pieceMoves) {
            if (isMoveLegal(move)) {
              possibleMoves.add(move);
            }
          }
        }
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    // Zorluk derecesine göre hamle seç
    if (difficulty == 1) {
      // Kolay mod: Rastgele hamle
      return possibleMoves[math.Random().nextInt(possibleMoves.length)];
    }
    
    // Orta/Zor mod: Minimax algoritması (basit)
    ChessMove? bestMove;
    int bestScore = -9999;
    final depth = difficulty == 2 ? 1 : 2; // Orta: 1 derinlik, Zor: 2 derinlik
    
    for (final move in possibleMoves) {
      // Hamleyi simüle et
      simulateMove(move);
      
      // Pozisyonu değerlendir
      final score = -minimax(depth - 1, -10000, 10000, !isWhiteTurn);
      
      // Hamleyi geri al
      undoSimulatedMove(move);
      
      // Daha iyi skor varsa güncelle
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove;
  }
  
  // Minimax algoritması (Alpha-Beta budama ile)
  int minimax(int depth, int alpha, int beta, bool maximizingPlayer) {
    if (depth == 0) {
      return evaluateBoard();
    }
    
    if (maximizingPlayer) {
      int maxEval = -9999;
      
      // Tüm olası hamleleri değerlendir
      for (int row = 0; row < 6; row++) {
        for (int col = 0; col < 6; col++) {
          final piece = board[row][col];
          if (piece != null && piece.isWhite == maximizingPlayer) {
            final position = ChessPosition(row, col);
            final moves = piece.generatePossibleMoves(position, getPieceAt);
            
            for (final move in moves) {
              if (isMoveLegal(move)) {
                simulateMove(move);
                final eval = minimax(depth - 1, alpha, beta, false);
                undoSimulatedMove(move);
                
                maxEval = math.max(maxEval, eval);
                alpha = math.max(alpha, eval);
                if (beta <= alpha) break;
              }
            }
          }
        }
      }
      
      return maxEval;
    } else {
      int minEval = 9999;
      
      // Tüm olası hamleleri değerlendir
      for (int row = 0; row < 6; row++) {
        for (int col = 0; col < 6; col++) {
          final piece = board[row][col];
          if (piece != null && piece.isWhite == maximizingPlayer) {
            final position = ChessPosition(row, col);
            final moves = piece.generatePossibleMoves(position, getPieceAt);
            
            for (final move in moves) {
              if (isMoveLegal(move)) {
                simulateMove(move);
                final eval = minimax(depth - 1, alpha, beta, true);
                undoSimulatedMove(move);
                
                minEval = math.min(minEval, eval);
                beta = math.min(beta, eval);
                if (beta <= alpha) break;
              }
            }
          }
        }
      }
      
      return minEval;
    }
  }
  
  // Mevcut tahta durumunu değerlendir (AI için)
  int evaluateBoard() {
    int score = 0;
    
    // Taş değerlerine göre skor hesapla
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 6; col++) {
        final piece = board[row][col];
        if (piece != null) {
          // Taş değeri (beyaz pozitif, siyah negatif)
          final value = piece.value * (piece.isWhite ? 1 : -1);
          score += value;
          
          // Taşın konumuna göre bonus değer (tahta merkezinde olma avantajı)
          final positionValue = _getPositionValue(piece, row, col);
          score += positionValue * (piece.isWhite ? 1 : -1);
        }
      }
    }
    
    // Siyah oyuncunun bakış açısından değerlendir
    return isWhiteTurn ? -score : score;
  }
  
  // Taşın konumuna göre değer atama (basit)
  int _getPositionValue(ChessPiece piece, int row, int col) {
    // Merkeze yakın taşlar daha değerli
    final centerDistanceRow = (row - 2.5).abs();
    final centerDistanceCol = (col - 2.5).abs();
    
    switch (piece.type) {
      case ChessPieceType.pawn:
        // Piyonlar ilerledikçe değer kazanır
        final advancement = piece.isWhite ? 5 - row : row;
        return advancement * 10 - (centerDistanceRow + centerDistanceCol).toInt() * 2;
        
      case ChessPieceType.knight:
        // Atlar merkeze yakın olmalı
        return 15 - ((centerDistanceRow + centerDistanceCol) * 4).toInt();
        
      case ChessPieceType.bishop:
        // Filler açık diyagonallerde daha iyi
        return 10 - ((centerDistanceRow + centerDistanceCol) * 3).toInt();
        
      case ChessPieceType.rook:
        // Kaleler açık sütunları tercih eder
        return 5 - (centerDistanceRow + centerDistanceCol).toInt();
        
      case ChessPieceType.queen:
        // Vezir merkeze yakın olmalı
        return 5 - ((centerDistanceRow + centerDistanceCol) * 2).toInt();
        
      case ChessPieceType.king:
        // Erken oyunda şah güvende olmalı, geç oyunda aktif olmalı
        final gameStage = _determineGameStage();
        
        if (gameStage < 0.5) { // Erken oyun
          // Şah kenarlar güvende olmalı
          return (centerDistanceRow + centerDistanceCol).toInt() * 2;
        } else { // Geç oyun
          // Şah aktif olmalı
          return 10 - ((centerDistanceRow + centerDistanceCol) * 2).toInt();
        }
    }
  }
  
  // Oyunun hangi aşamada olduğunu belirle (0-1)
  double _determineGameStage() {
    int totalPieces = 0;
    
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 6; col++) {
        if (board[row][col] != null) {
          totalPieces++;
        }
      }
    }
    
    // Başlangıçta 24 taş var, oyun ilerledikçe azalır
    return 1.0 - (totalPieces / 24.0);
  }
  
  // İnsan oyuncunun sırası mı?
  bool isHumanToPlay() {
    return isWhiteTurn; // İnsan oyuncu beyaz, AI siyah
  }
  
  // Oyunu sıfırla
  void resetGame() {
    setupBoard();
  }
  
  // Zorluk seviyesini ayarla
  void setDifficulty(int level) {
    if (level >= 1 && level <= 3) {
      difficulty = level;
    }
  }
  
  // İpucu iste
  void requestHint() {
    if (!isHumanToPlay() || isGameOver) return;
    
    final bestMove = findBestMove();
    
    if (bestMove != null) {
      // İpucu modunu aç
      showingHint = true;
      hintFromPosition = bestMove.from;
      hintToPosition = bestMove.to;
      
      // 3 saniye sonra ipucu modunu kapat
      Future.delayed(const Duration(seconds: 3), () {
        if (showingHint) {
          showingHint = false;
          hintFromPosition = null;
          hintToPosition = null;
          update();
        }
      });
      
      update();
    }
  }
  
  // İpucu reklamı gösterme
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
  
  // İpucu kullanma
  void useHint() {
    if (hintCount.value <= 0) {
      // İpucu hakkı yoksa reklam göster
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
    
    // En iyi hamleyi göster
    _showBestMove();
  }
  
  // En iyi hamleyi gösterme (örnek olarak basit bir şekilde)
  void _showBestMove() {
    // Burada gerçek bir satranç motoru kullanılabilir
    // Şimdilik rastgele geçerli bir hamle gösteriyoruz
    
    // TODO: Daha akıllı bir algoritma ekle
    // Şimdilik basit bir hamle gösterelim
    Get.snackbar(
      'İpucu',
      'En iyi hamle: Piyonu ileri sür',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.7),
      colorText: Colors.white,
    );
  }
} 