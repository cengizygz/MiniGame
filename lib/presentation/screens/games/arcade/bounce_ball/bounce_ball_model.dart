import 'package:flutter/material.dart';

/// Basit bir model sınıfı. Bu oyun için veri yapıları controller içinde tutulduğundan,
/// bu sınıf şu anda minimal bir yapıya sahiptir. Oyunun ilerleyen sürümlerinde
/// daha fazla işlevsellik eklenebilir.
class BounceBallModel {
  // Oyun nesneleri için özellikler buraya eklenebilir
  
  BounceBallModel();
  
  // Oyun durumunu kaydetmek için metot (ileride implementasyon eklenebilir)
  Map<String, dynamic> saveState() {
    return {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  // Kaydedilen durumdan oyunu yüklemek için metot (ileride implementasyon eklenebilir)
  void loadState(Map<String, dynamic> state) {
    // İleride gerçekleştirilecek
  }
} 