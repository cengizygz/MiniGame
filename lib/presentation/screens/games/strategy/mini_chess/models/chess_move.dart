import 'chess_position.dart';
import 'chess_piece.dart';

/// Satranç hamlesini temsil eden sınıf
class ChessMove {
  /// Başlangıç pozisyonu
  final ChessPosition from;
  
  /// Hedef pozisyonu
  final ChessPosition to;
  
  /// Hamle ile ele geçirilen taş (varsa)
  ChessPiece? capturedPiece;
  
  ChessMove(this.from, this.to, {this.capturedPiece});
  
  /// Hamlenin cebirsel notasyonunu döndürür (örn. "a2-a4", "e5xf6")
  String get notation {
    if (capturedPiece != null) {
      return '${from.notation}x${to.notation}';
    } else {
      return '${from.notation}-${to.notation}';
    }
  }
  
  @override
  String toString() {
    return 'Move: $notation${capturedPiece != null ? ' (captured ${capturedPiece!.symbol})' : ''}';
  }
} 