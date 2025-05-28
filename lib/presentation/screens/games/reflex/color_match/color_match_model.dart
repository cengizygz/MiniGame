import 'package:flutter/material.dart';

class ColorModel {
  final Color color;
  final String name;
  final int id;
  
  const ColorModel({
    required this.color,
    required this.name,
    required this.id,
  });
  
  // Eşitlik kontrolü için
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

// Oyunda kullanılacak varsayılan renkler
class GameColors {
  static const ColorModel red = ColorModel(
    color: Colors.red,
    name: 'Kırmızı',
    id: 1,
  );
  
  static const ColorModel blue = ColorModel(
    color: Colors.blue,
    name: 'Mavi',
    id: 2,
  );
  
  static const ColorModel green = ColorModel(
    color: Colors.green,
    name: 'Yeşil',
    id: 3,
  );
  
  static const ColorModel yellow = ColorModel(
    color: Colors.yellow,
    name: 'Sarı',
    id: 4,
  );
  
  static const ColorModel purple = ColorModel(
    color: Colors.purple,
    name: 'Mor',
    id: 5,
  );
  
  static const ColorModel orange = ColorModel(
    color: Colors.orange,
    name: 'Turuncu',
    id: 6,
  );
  
  // Tüm renklerin listesi
  static const List<ColorModel> allColors = [
    red,
    blue,
    green,
    yellow,
    purple,
    orange,
  ];
} 