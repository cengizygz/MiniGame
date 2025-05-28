import 'chess_position.dart';
import 'chess_move.dart';

/// Satranç taşı türleri
enum ChessPieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn,
}

/// Satranç taşını temsil eden sınıf
class ChessPiece {
  /// Taşın türü
  final ChessPieceType type;
  
  /// Taşın rengi (true = beyaz, false = siyah)
  final bool isWhite;
  
  /// Taş hareket edildi mi
  bool hasMoved;
  
  ChessPiece({
    required this.type,
    required this.isWhite,
    this.hasMoved = false,
  });
  
  /// Taşın sembolünü (notasyonunu) döndürür
  String get symbol {
    String letter;
    
    switch (type) {
      case ChessPieceType.king:
        letter = 'K';
        break;
      case ChessPieceType.queen:
        letter = 'Q';
        break;
      case ChessPieceType.rook:
        letter = 'R';
        break;
      case ChessPieceType.bishop:
        letter = 'B';
        break;
      case ChessPieceType.knight:
        letter = 'N';
        break;
      case ChessPieceType.pawn:
        letter = 'P';
        break;
    }
    
    return isWhite ? letter : letter.toLowerCase();
  }
  
  /// Taşın değerini döndürür (satranç yapay zekası için)
  int get value {
    switch (type) {
      case ChessPieceType.king:
        return 1000; // Şah için büyük değer
      case ChessPieceType.queen:
        return 9;
      case ChessPieceType.rook:
        return 5;
      case ChessPieceType.bishop:
        return 3;
      case ChessPieceType.knight:
        return 3;
      case ChessPieceType.pawn:
        return 1;
    }
  }
  
  /// Taşın geçerli hamleleri için yönleri döndürür
  List<List<int>> getDirections() {
    switch (type) {
      case ChessPieceType.king:
        // Tüm 8 yön, sadece 1 kare
        return [
          [1, 0], [1, 1], [0, 1], [-1, 1],
          [-1, 0], [-1, -1], [0, -1], [1, -1],
        ];
      case ChessPieceType.queen:
        // Vezir: Tüm 8 yön, sınırsız kare
        return [
          [1, 0], [1, 1], [0, 1], [-1, 1],
          [-1, 0], [-1, -1], [0, -1], [1, -1],
        ];
      case ChessPieceType.rook:
        // Kale: Düz hatlar, sınırsız kare
        return [
          [1, 0], [0, 1], [-1, 0], [0, -1],
        ];
      case ChessPieceType.bishop:
        // Fil: Çapraz hatlar, sınırsız kare
        return [
          [1, 1], [-1, 1], [-1, -1], [1, -1],
        ];
      case ChessPieceType.knight:
        // At: Özel L şeklinde hareket
        return [
          [2, 1], [1, 2], [-1, 2], [-2, 1],
          [-2, -1], [-1, -2], [1, -2], [2, -1],
        ];
      case ChessPieceType.pawn:
        // Piyon: Özel hareket kuralları - generatePossibleMoves yönteminde işlenir
        return [];
    }
  }
  
  /// Geçerli hamleleri döndürür
  List<ChessMove> generatePossibleMoves(ChessPosition position, Function getPieceAt) {
    List<ChessMove> moves = [];
    
    // Piyon özel kuralları
    if (type == ChessPieceType.pawn) {
      _addPawnMoves(position, getPieceAt, moves);
      return moves;
    }
    
    // At/Knight özel kuralları (tek adım, engelleri atlama)
    if (type == ChessPieceType.knight) {
      _addKnightMoves(position, getPieceAt, moves);
      return moves;
    }
    
    // Diğer taşlar için yön ve mesafe tabanlı hareketler
    final directions = getDirections();
    final maxDistance = (type == ChessPieceType.king) ? 1 : 7; // Şah 1 kare, diğerleri sınırsız (6x6 tahtada max 5)
    
    for (final direction in directions) {
      _addDirectionalMoves(position, direction[0], direction[1], maxDistance, getPieceAt, moves);
    }
    
    return moves;
  }
  
  // Yönlü hareketleri ekler (kale, fil, vezir, şah için)
  void _addDirectionalMoves(
    ChessPosition position, 
    int rowDelta, 
    int colDelta, 
    int maxDistance,
    Function getPieceAt,
    List<ChessMove> moves
  ) {
    for (int distance = 1; distance <= maxDistance; distance++) {
      final newRow = position.row + (rowDelta * distance);
      final newCol = position.col + (colDelta * distance);
      final newPos = ChessPosition(newRow, newCol);
      
      // Tahta dışına çıkıldı mı kontrol et
      if (!newPos.isValid()) break;
      
      final pieceAtNewPos = getPieceAt(newPos);
      
      // Boş kare
      if (pieceAtNewPos == null) {
        moves.add(ChessMove(position, newPos));
      }
      // Rakip taş
      else if (pieceAtNewPos.isWhite != isWhite) {
        moves.add(ChessMove(position, newPos, capturedPiece: pieceAtNewPos));
        break; // Taştan sonra devam edilmez
      }
      // Kendi taşı
      else {
        break; // Kendi taşından sonra devam edilmez
      }
    }
  }
  
  // At/Knight hareketlerini ekler
  void _addKnightMoves(
    ChessPosition position,
    Function getPieceAt,
    List<ChessMove> moves
  ) {
    final directions = getDirections();
    
    for (final direction in directions) {
      final newRow = position.row + direction[0];
      final newCol = position.col + direction[1];
      final newPos = ChessPosition(newRow, newCol);
      
      // Tahta dışına çıkıldı mı kontrol et
      if (!newPos.isValid()) continue;
      
      final pieceAtNewPos = getPieceAt(newPos);
      
      // Boş kare veya rakip taşı
      if (pieceAtNewPos == null || pieceAtNewPos.isWhite != isWhite) {
        moves.add(ChessMove(
          position, 
          newPos, 
          capturedPiece: pieceAtNewPos,
        ));
      }
    }
  }
  
  // Piyon hareketlerini ekler
  void _addPawnMoves(
    ChessPosition position,
    Function getPieceAt,
    List<ChessMove> moves
  ) {
    // Hareket yönü (beyaz aşağıdan, siyah yukarıdan başlar)
    final direction = isWhite ? -1 : 1;
    
    // İleri hareket
    final forwardPos = ChessPosition(position.row + direction, position.col);
    if (forwardPos.isValid() && getPieceAt(forwardPos) == null) {
      moves.add(ChessMove(position, forwardPos));
      
      // İlk harekette 2 kare ileri
      if (!hasMoved) {
        final doubleForwardPos = ChessPosition(position.row + 2 * direction, position.col);
        if (doubleForwardPos.isValid() && getPieceAt(doubleForwardPos) == null) {
          moves.add(ChessMove(position, doubleForwardPos));
        }
      }
    }
    
    // Çapraz yakalama
    final capturePositions = [
      ChessPosition(position.row + direction, position.col - 1),
      ChessPosition(position.row + direction, position.col + 1),
    ];
    
    for (final capturePos in capturePositions) {
      if (capturePos.isValid()) {
        final pieceAtCapturePos = getPieceAt(capturePos);
        if (pieceAtCapturePos != null && pieceAtCapturePos.isWhite != isWhite) {
          moves.add(ChessMove(
            position,
            capturePos,
            capturedPiece: pieceAtCapturePos,
          ));
        }
      }
    }
  }
  
  /// Taşın kopyasını oluşturur
  ChessPiece copy() {
    return ChessPiece(
      type: type,
      isWhite: isWhite,
      hasMoved: hasMoved,
    );
  }
  
  @override
  String toString() => '${isWhite ? "White" : "Black"} $type';
} 