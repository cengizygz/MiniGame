import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Nesne tipleri
enum ObjectType {
  bird,
  pig,
  wood,
  stone,
  glass
}

// Oyun nesnesi modeli
class GameObject {
  final ObjectType type;
  Offset position;
  Offset velocity = Offset.zero;
  double size;
  double rotation = 0.0;
  bool isDestroyed = false;
  double health;
  Color color;
  
  GameObject({
    required this.type,
    required this.position,
    required this.size,
    this.velocity = Offset.zero,
    required this.health,
    required this.color,
  });
  
  // Nesne ile çakışma tespiti
  bool intersects(GameObject other) {
    double distance = (position - other.position).distance;
    return distance < (size + other.size) / 2;
  }
  
  // Nesneye hasar uygulama
  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      isDestroyed = true;
    }
  }
}

// Oyun seviyesi modeli
class GameLevel {
  final String name;
  final List<GameObject> objects;
  final Offset slingPosition;
  
  GameLevel({
    required this.name,
    required this.objects,
    required this.slingPosition,
  });
}

class AngryBirdsController extends GetxController {
  // Oyun durumu
  bool isGameRunning = false;
  bool isAiming = false;
  bool isBirdFlying = false;
  int score = 0;
  int birdsRemaining = 3;
  int currentLevel = 1;
  bool isGameOver = false;
  bool levelCompleted = false;
  
  // Skor ve yüksek skor
  int highScore = 0;
  
  // Fizik parametreleri
  final double gravity = 0.2;
  final double dragFactor = 0.001;
  final double elasticity = 0.8;
  final double maxPullDistance = 100.0;
  
  // Oyun nesneleri
  List<GameObject> gameObjects = [];
  GameObject? currentBird;
  
  // Sapan pozisyonu
  Offset slingPosition = const Offset(100, 300);
  
  // Mevcut dokunma pozisyonu
  Offset? touchPosition;
  
  // Oyun döngüsü için timer
  Timer? gameTimer;
  
  // Kamera hareketi
  double cameraOffset = 0.0;
  
  // Oyunu başlat
  void startGame() {
    isGameRunning = true;
    isGameOver = false;
    levelCompleted = false;
    score = 0;
    birdsRemaining = 3;
    cameraOffset = 0.0;
    
    // Seviyeyi yükle
    loadLevel(currentLevel);
    
    // Oyun döngüsünü başlat
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (isGameRunning) {
        updatePhysics();
        update();
      }
    });
    
    update();
  }
  
  // Oyunu duraklat
  void pauseGame() {
    isGameRunning = false;
    update();
  }
  
  // Oyunu devam ettir
  void resumeGame() {
    isGameRunning = true;
    update();
  }
  
  // Oyunu sonlandır
  void endGame() {
    isGameRunning = false;
    gameTimer?.cancel();
    gameTimer = null;
    
    // Yüksek skoru kontrol et
    if (score > highScore) {
      highScore = score;
      // TODO: Skoru kaydet
    }
    
    isGameOver = true;
    update();
  }
  
  // Seviyeyi yükle
  void loadLevel(int level) {
    gameObjects.clear();
    
    switch (level) {
      case 1:
        _loadLevel1();
        break;
      case 2:
        _loadLevel2();
        break;
      case 3:
        _loadLevel3();
        break;
      default:
        _loadLevel1();
    }
    
    // İlk kuşu hazırla
    _prepareNextBird();
    
    update();
  }
  
  // Seviye 1'i yükle (Basit seviye)
  void _loadLevel1() {
    slingPosition = const Offset(100, 300);
    
    // Domuzlar
    gameObjects.add(GameObject(
      type: ObjectType.pig,
      position: const Offset(500, 350),
      size: 40,
      health: 50,
      color: Colors.green,
    ));
    
    // Tahta yapılar
    gameObjects.add(GameObject(
      type: ObjectType.wood,
      position: const Offset(450, 330),
      size: 25,
      health: 30,
      color: Colors.brown,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.wood,
      position: const Offset(550, 330),
      size: 25,
      health: 30,
      color: Colors.brown,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.wood,
      position: const Offset(500, 290),
      size: 80,
      health: 40,
      color: Colors.brown,
    ));
    
    // Cam yapılar
    gameObjects.add(GameObject(
      type: ObjectType.glass,
      position: const Offset(400, 350),
      size: 30,
      health: 20,
      color: Colors.lightBlueAccent.withOpacity(0.7),
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.glass,
      position: const Offset(600, 350),
      size: 30,
      health: 20,
      color: Colors.lightBlueAccent.withOpacity(0.7),
    ));
  }
  
  // Seviye 2'yi yükle (Orta zorluk)
  void _loadLevel2() {
    slingPosition = const Offset(100, 300);
    
    // Domuzlar
    gameObjects.add(GameObject(
      type: ObjectType.pig,
      position: const Offset(500, 350),
      size: 35,
      health: 50,
      color: Colors.green,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.pig,
      position: const Offset(600, 350),
      size: 35,
      health: 50,
      color: Colors.green,
    ));
    
    // Taş yapılar
    gameObjects.add(GameObject(
      type: ObjectType.stone,
      position: const Offset(550, 320),
      size: 80,
      health: 70,
      color: Colors.grey,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.stone,
      position: const Offset(480, 280),
      size: 30,
      health: 60,
      color: Colors.grey,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.stone,
      position: const Offset(620, 280),
      size: 30,
      health: 60,
      color: Colors.grey,
    ));
    
    // Tahta yapılar
    gameObjects.add(GameObject(
      type: ObjectType.wood,
      position: const Offset(550, 240),
      size: 120,
      health: 40,
      color: Colors.brown,
    ));
    
    // Cam yapılar
    gameObjects.add(GameObject(
      type: ObjectType.glass,
      position: const Offset(400, 350),
      size: 40,
      health: 20,
      color: Colors.lightBlueAccent.withOpacity(0.7),
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.glass,
      position: const Offset(700, 350),
      size: 40,
      health: 20,
      color: Colors.lightBlueAccent.withOpacity(0.7),
    ));
  }
  
  // Seviye 3'ü yükle (Zor seviye)
  void _loadLevel3() {
    slingPosition = const Offset(100, 300);
    
    // Domuzlar
    gameObjects.add(GameObject(
      type: ObjectType.pig,
      position: const Offset(450, 350),
      size: 30,
      health: 50,
      color: Colors.green,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.pig,
      position: const Offset(550, 350),
      size: 30,
      health: 50,
      color: Colors.green,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.pig,
      position: const Offset(650, 350),
      size: 30,
      health: 50,
      color: Colors.green,
    ));
    
    // Taş yapılar
    gameObjects.add(GameObject(
      type: ObjectType.stone,
      position: const Offset(500, 320),
      size: 100,
      health: 80,
      color: Colors.grey,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.stone,
      position: const Offset(600, 320),
      size: 100,
      health: 80,
      color: Colors.grey,
    ));
    
    // Tahta yapılar
    gameObjects.add(GameObject(
      type: ObjectType.wood,
      position: const Offset(450, 280),
      size: 30,
      health: 40,
      color: Colors.brown,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.wood,
      position: const Offset(550, 280),
      size: 30,
      health: 40,
      color: Colors.brown,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.wood,
      position: const Offset(650, 280),
      size: 30,
      health: 40,
      color: Colors.brown,
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.wood,
      position: const Offset(550, 240),
      size: 180,
      health: 40,
      color: Colors.brown,
    ));
    
    // Cam yapılar
    gameObjects.add(GameObject(
      type: ObjectType.glass,
      position: const Offset(400, 350),
      size: 40,
      health: 20,
      color: Colors.lightBlueAccent.withOpacity(0.7),
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.glass,
      position: const Offset(700, 350),
      size: 40,
      health: 20,
      color: Colors.lightBlueAccent.withOpacity(0.7),
    ));
    
    gameObjects.add(GameObject(
      type: ObjectType.glass,
      position: const Offset(550, 200),
      size: 30,
      health: 20,
      color: Colors.lightBlueAccent.withOpacity(0.7),
    ));
  }
  
  // Sonraki kuşu hazırla
  void _prepareNextBird() {
    if (birdsRemaining > 0) {
      birdsRemaining--;
      
      currentBird = GameObject(
        type: ObjectType.bird,
        position: slingPosition,
        size: 30,
        health: 100,
        color: Colors.red,
      );
      
      isBirdFlying = false;
      isAiming = false;
      touchPosition = null;
      
      update();
    } else {
      // Kuş kalmadı, oyunu kontrol et
      _checkGameState();
    }
  }
  
  // Kuşun nişan almaya başlaması
  void startAiming(Offset position) {
    if (!isGameRunning || isBirdFlying || currentBird == null) return;
    
    // Eğer kuşun yakınında bir yere dokunulduysa nişan almaya başla
    double distance = (position - slingPosition).distance;
    if (distance < 50) {
      isAiming = true;
      touchPosition = position;
      update();
    }
  }
  
  // Nişan alma sırasında güncelleme
  void updateAiming(Offset position) {
    if (!isAiming) return;
    
    touchPosition = position;
    
    // Maksimum çekme mesafesini sınırla
    double distance = (touchPosition! - slingPosition).distance;
    if (distance > maxPullDistance) {
      // Yönü koru ama mesafeyi sınırla
      double angle = atan2(
        touchPosition!.dy - slingPosition.dy,
        touchPosition!.dx - slingPosition.dx,
      );
      
      touchPosition = Offset(
        slingPosition.dx + maxPullDistance * cos(angle),
        slingPosition.dy + maxPullDistance * sin(angle),
      );
    }
    
    // Kuşun pozisyonunu güncelle
    if (currentBird != null) {
      currentBird!.position = touchPosition!;
    }
    
    update();
  }
  
  // Kuşu fırlat
  void launchBird() {
    if (!isAiming || currentBird == null) return;
    
    // Fırlatma hızını hesapla (sapanın gerilmesine bağlı olarak)
    Offset pullVector = slingPosition - touchPosition!;
    currentBird!.velocity = pullVector * 0.1; // Hız faktörü
    
    isAiming = false;
    isBirdFlying = true;
    touchPosition = null;
    
    update();
  }
  
  // Fizik güncellemesi
  void updatePhysics() {
    if (!isGameRunning) return;
    
    // Fırlatılan kuşun hareketi
    if (isBirdFlying && currentBird != null) {
      // Yerçekimi ve sürüklenme etkisi
      currentBird!.velocity += Offset(0, gravity);
      currentBird!.velocity *= (1 - dragFactor);
      
      // Pozisyonu güncelle
      currentBird!.position += currentBird!.velocity;
      
      // Rotasyonu güncelle (uçuş yönüne göre)
      double angle = atan2(
        currentBird!.velocity.dy,
        currentBird!.velocity.dx,
      );
      currentBird!.rotation = angle;
      
      // Çarpışma kontrolü
      _checkCollisions();
      
      // Ekran dışına çıkma kontrolü
      if (currentBird!.position.dy > 400 ||  // Zemin
          currentBird!.position.dx > 1500 || // Sağ kenar (çok uzağa gittiyse)
          currentBird!.position.dx < -500) { // Sol kenar (geri gelirse)
        _prepareBirdEnd();
      }
      
      // Kamera takibi
      if (currentBird!.position.dx > 300) {
        cameraOffset = max(0, currentBird!.position.dx - 300);
      }
    }
    
    // Diğer nesnelerin güncellenmesi
    for (var obj in gameObjects) {
      if (obj.isDestroyed) continue;
      
      // Yerçekimi etkisi (sadece hareketli nesneler için)
      if (obj.velocity.dx.abs() > 0.1 || obj.velocity.dy.abs() > 0.1) {
        obj.velocity += Offset(0, gravity);
        obj.velocity *= (1 - dragFactor * 2); // Daha fazla sürüklenme
        obj.position += obj.velocity;
        
        // Rotasyonu güncelle
        if (obj.velocity.distance > 0.5) {
          double angle = atan2(
            obj.velocity.dy,
            obj.velocity.dx,
          );
          obj.rotation = angle;
        }
        
        // Zemin kontrolü
        if (obj.position.dy > 400 - obj.size / 2) {
          obj.position = Offset(obj.position.dx, 400 - obj.size / 2);
          obj.velocity = Offset(obj.velocity.dx * 0.5, -obj.velocity.dy * elasticity);
          
          // Çok küçük hareket kaldıysa durdur
          if (obj.velocity.distance < 0.5) {
            obj.velocity = Offset.zero;
          }
        }
      }
    }
    
    // Eğer kuş uçuşunu tamamladıysa ve tüm hareketler durduysa
    if (!isBirdFlying && !isAiming && _isAllObjectsStable()) {
      _checkGameState();
    }
  }
  
  // Çarpışma kontrolü
  void _checkCollisions() {
    if (currentBird == null || !isBirdFlying) return;
    
    for (var obj in gameObjects) {
      if (obj.isDestroyed) continue;
      
      if (currentBird!.intersects(obj)) {
        // Hasar uygulaması ve etkileri
        switch (obj.type) {
          case ObjectType.pig:
            obj.takeDamage(50); // Domuzlara çok hasar
            score += 500;
            break;
          case ObjectType.wood:
            obj.takeDamage(40); // Tahtaya orta hasar
            score += 100;
            break;
          case ObjectType.stone:
            obj.takeDamage(20); // Taşa az hasar
            score += 200;
            break;
          case ObjectType.glass:
            obj.takeDamage(80); // Cama çok hasar
            score += 150;
            break;
          default:
            break;
        }
        
        // Fizik etkileşimi: nesneye hız transferi
        double forceMultiplier = 0.7;
        obj.velocity += currentBird!.velocity * forceMultiplier;
        
        // Kuşu yavaşlat
        currentBird!.velocity *= 0.7;
      }
    }
  }
  
  // Kuş uçuşunu sonlandır
  void _prepareBirdEnd() {
    isBirdFlying = false;
    currentBird = null;
    
    // Biraz bekle ve sonraki kuşu hazırla
    Future.delayed(const Duration(milliseconds: 1500), () {
      _prepareNextBird();
    });
  }
  
  // Tüm nesnelerin hareketsiz olup olmadığını kontrol et
  bool _isAllObjectsStable() {
    for (var obj in gameObjects) {
      if (!obj.isDestroyed && obj.velocity.distance > 0.2) {
        return false;
      }
    }
    return true;
  }
  
  // Oyun durumunu kontrol et
  void _checkGameState() {
    // Tüm domuzlar öldü mü kontrol et
    bool allPigsDead = true;
    for (var obj in gameObjects) {
      if (obj.type == ObjectType.pig && !obj.isDestroyed) {
        allPigsDead = false;
        break;
      }
    }
    
    if (allPigsDead) {
      // Seviye tamamlandı
      levelCompleted = true;
      
      // Kalan her kuş için bonus puan
      score += birdsRemaining * 1000;
      
      // Sonraki seviyeye geçmek için hazırlan
      Future.delayed(const Duration(seconds: 2), () {
        if (currentLevel < 3) {
          currentLevel++;
          startGame();
        } else {
          // Tüm seviyeler tamamlandı, oyun bitti
          endGame();
        }
      });
    } else if (birdsRemaining <= 0 && currentBird == null) {
      // Kuş kalmadı ama domuzlar hala hayatta, oyun bitti
      isGameOver = true;
      endGame();
    } else {
      // Oyun devam ediyor, bir sonraki kuşu hazırla
      _prepareNextBird();
    }
    
    update();
  }
  
  // Kontrolcü temizliği
  @override
  void onClose() {
    gameTimer?.cancel();
    gameTimer = null;
    super.onClose();
  }
} 