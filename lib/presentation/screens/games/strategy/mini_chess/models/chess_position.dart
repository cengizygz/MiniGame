/// Satranç tahtasındaki bir pozisyonu temsil eden sınıf
class ChessPosition {
  final int row;
  final int col;
  
  const ChessPosition(this.row, this.col);
  
  /// Pozisyonun satranç notasyonunu döndürür (örn. "a1", "b2" vb.)
  String get notation {
    const columns = ['a', 'b', 'c', 'd', 'e', 'f'];
    return '${columns[col]}${6 - row}';
  }
  
  /// String formatında notasyondan pozisyon oluşturur
  factory ChessPosition.fromNotation(String notation) {
    const columns = ['a', 'b', 'c', 'd', 'e', 'f'];
    
    if (notation.length != 2) {
      throw ArgumentError('Invalid notation format: $notation');
    }
    
    final col = columns.indexOf(notation[0].toLowerCase());
    final row = 6 - int.parse(notation[1]);
    
    if (col < 0 || row < 0 || row > 5 || col > 5) {
      throw ArgumentError('Invalid notation: $notation');
    }
    
    return ChessPosition(row, col);
  }
  
  /// Pozisyonun tahtada olup olmadığını kontrol eder
  bool isValid() {
    return row >= 0 && row < 6 && col >= 0 && col < 6;
  }
  
  /// Yeni offset eklenmiş pozisyon döndürür
  ChessPosition offset(int rowOffset, int colOffset) {
    return ChessPosition(row + rowOffset, col + colOffset);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChessPosition && other.row == row && other.col == col;
  }
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
  
  @override
  String toString() => 'Position($row, $col) [${notation}]';
} 