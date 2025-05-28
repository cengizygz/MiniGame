import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Game object types
enum ObjectType {
  rope,
  candy,
  creature,
  star,
  bubble,
  spikes,
  airCushion
}

// Rope segment class
class RopeSegment {
  Offset start;
  Offset end;
  bool isCut = false;
  
  RopeSegment({
    required this.start,
    required this.end,
  });
}

// Rope class
class Rope {
  final int id;
  Offset anchorPoint;
  List<RopeSegment> segments = [];
  bool isCut = false;
  double length;
  double angle = 0.0;
  double swingSpeed = 0.0;
  double damping = 0.98;
  
  Rope({
    required this.id,
    required this.anchorPoint,
    required this.length,
    this.swingSpeed = 0.0,
  });
  
  void update() {
    if (isCut) return;
    
    // Update swing physics
    angle += swingSpeed;
    swingSpeed *= damping;
  }
}

// Game object class
class GameObject {
  final ObjectType type;
  Offset position;
  Offset velocity = Offset.zero;
  double size;
  bool isCollected = false;
  
  GameObject({
    required this.type,
    required this.position,
    required this.size,
    this.velocity = Offset.zero,
  });
  
  // Check intersection with another object
  bool intersects(GameObject other) {
    double distance = (position - other.position).distance;
    return distance < (size + other.size) / 2;
  }
  
  // Check if point is inside this object
  bool containsPoint(Offset point) {
    double distance = (position - point).distance;
    return distance < size / 2;
  }
}

// Game level class
class GameLevel {
  final String name;
  final List<Rope> ropes;
  final List<GameObject> objects;
  final Offset creaturePosition;
  final int starsTotal;
  
  GameLevel({
    required this.name,
    required this.ropes,
    required this.objects,
    required this.creaturePosition,
    required this.starsTotal,
  });
}

class CutRopeController extends GetxController {
  // Game state
  bool isGameRunning = false;
  bool isGameOver = false;
  bool levelCompleted = false;
  int currentLevel = 1;
  int starsCollected = 0;
  int score = 0;
  
  // High score
  int highScore = 0;
  
  // Physics parameters
  final double gravity = 0.4;
  final double elasticity = 0.8;
  
  // Game objects
  List<Rope> ropes = [];
  GameObject? candy;
  GameObject? creature;
  List<GameObject> stars = [];
  List<GameObject> obstacles = [];
  
  // Timer for game loop
  Timer? gameTimer;
  
  // Current touch position
  Offset? touchPosition;
  List<Offset> cutPath = [];
  
  // Start the game
  void startGame() {
    isGameRunning = true;
    isGameOver = false;
    levelCompleted = false;
    starsCollected = 0;
    
    // Load level
    loadLevel(currentLevel);
    
    // Start game loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (isGameRunning) {
        updatePhysics();
        update();
      }
    });
    
    update();
  }
  
  // Pause the game
  void pauseGame() {
    isGameRunning = false;
    update();
  }
  
  // Resume the game
  void resumeGame() {
    isGameRunning = true;
    update();
  }
  
  // End the game
  void endGame() {
    isGameRunning = false;
    gameTimer?.cancel();
    gameTimer = null;
    
    // Check high score
    if (score > highScore) {
      highScore = score;
      // TODO: Save score
    }
    
    isGameOver = true;
    update();
  }
  
  // Load level
  void loadLevel(int level) {
    ropes.clear();
    stars.clear();
    obstacles.clear();
    candy = null;
    creature = null;
    
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
    
    update();
  }
  
  // Load level 1 (Simple level)
  void _loadLevel1() {
    // Create ropes
    ropes.add(Rope(
      id: 1,
      anchorPoint: const Offset(200, 100),
      length: 100,
      swingSpeed: 0.01,
    ));
    
    // Create candy (attached to rope)
    candy = GameObject(
      type: ObjectType.candy,
      position: const Offset(200, 200),
      size: 30,
    );
    
    // Create creature
    creature = GameObject(
      type: ObjectType.creature,
      position: const Offset(300, 350),
      size: 60,
    );
    
    // Create stars
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(150, 250),
      size: 25,
    ));
    
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(250, 300),
      size: 25,
    ));
    
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(350, 250),
      size: 25,
    ));
  }
  
  // Load level 2 (Medium level)
  void _loadLevel2() {
    // Create ropes
    ropes.add(Rope(
      id: 1,
      anchorPoint: const Offset(150, 100),
      length: 80,
      swingSpeed: 0.02,
    ));
    
    ropes.add(Rope(
      id: 2,
      anchorPoint: const Offset(250, 100),
      length: 80,
      swingSpeed: -0.01,
    ));
    
    // Create candy (attached to ropes)
    candy = GameObject(
      type: ObjectType.candy,
      position: const Offset(200, 180),
      size: 30,
    );
    
    // Create creature
    creature = GameObject(
      type: ObjectType.creature,
      position: const Offset(350, 350),
      size: 60,
    );
    
    // Create stars
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(150, 220),
      size: 25,
    ));
    
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(200, 270),
      size: 25,
    ));
    
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(300, 300),
      size: 25,
    ));
    
    // Add obstacles
    obstacles.add(GameObject(
      type: ObjectType.spikes,
      position: const Offset(100, 300),
      size: 40,
    ));
  }
  
  // Load level 3 (Hard level)
  void _loadLevel3() {
    // Create ropes
    ropes.add(Rope(
      id: 1,
      anchorPoint: const Offset(100, 100),
      length: 70,
      swingSpeed: 0.03,
    ));
    
    ropes.add(Rope(
      id: 2,
      anchorPoint: const Offset(200, 80),
      length: 90,
      swingSpeed: -0.02,
    ));
    
    ropes.add(Rope(
      id: 3,
      anchorPoint: const Offset(300, 120),
      length: 80,
      swingSpeed: 0.01,
    ));
    
    // Create candy (attached to ropes)
    candy = GameObject(
      type: ObjectType.candy,
      position: const Offset(200, 190),
      size: 30,
    );
    
    // Create creature
    creature = GameObject(
      type: ObjectType.creature,
      position: const Offset(350, 350),
      size: 60,
    );
    
    // Create stars
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(120, 180),
      size: 25,
    ));
    
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(220, 240),
      size: 25,
    ));
    
    stars.add(GameObject(
      type: ObjectType.star,
      position: const Offset(320, 280),
      size: 25,
    ));
    
    // Add obstacles
    obstacles.add(GameObject(
      type: ObjectType.spikes,
      position: const Offset(120, 280),
      size: 40,
    ));
    
    obstacles.add(GameObject(
      type: ObjectType.spikes,
      position: const Offset(280, 330),
      size: 40,
    ));
    
    // Add special objects
    obstacles.add(GameObject(
      type: ObjectType.bubble,
      position: const Offset(200, 300),
      size: 50,
    ));
    
    obstacles.add(GameObject(
      type: ObjectType.airCushion,
      position: const Offset(350, 250),
      size: 45,
    ));
  }
  
  // Update physics
  void updatePhysics() {
    if (!isGameRunning || candy == null) return;
    
    // Update ropes
    for (var rope in ropes) {
      rope.update();
    }
    
    // Calculate candy position based on ropes
    if (ropes.isNotEmpty && !ropes.every((rope) => rope.isCut)) {
      Offset totalForce = Offset.zero;
      int attachedRopes = 0;
      
      for (var rope in ropes) {
        if (!rope.isCut) {
          attachedRopes++;
          // Calculate rope end position
          double ropeEndX = rope.anchorPoint.dx + sin(rope.angle) * rope.length;
          double ropeEndY = rope.anchorPoint.dy + cos(rope.angle) * rope.length;
          
          // Add force towards the rope end
          totalForce += Offset(ropeEndX, ropeEndY) - candy!.position;
        }
      }
      
      // If there are attached ropes, update position based on them
      if (attachedRopes > 0) {
        totalForce = totalForce / attachedRopes.toDouble();
        candy!.position += totalForce * 0.1;
      } else {
        // No attached ropes, apply gravity
        candy!.velocity += Offset(0, gravity);
        candy!.position += candy!.velocity;
      }
    } else {
      // All ropes are cut, apply gravity
      candy!.velocity += Offset(0, gravity);
      candy!.position += candy!.velocity;
    }
    
    // Check collisions
    _checkCollisions();
    
    // Check if candy is out of bounds
    if (candy!.position.dy > 500) {
      isGameOver = true;
      endGame();
    }
  }
  
  // Check collisions
  void _checkCollisions() {
    if (candy == null) return;
    
    // Check collision with stars
    for (var star in stars) {
      if (!star.isCollected && candy!.intersects(star)) {
        star.isCollected = true;
        starsCollected++;
        score += 100;
      }
    }
    
    // Check collision with creature (goal)
    if (creature != null && candy!.intersects(creature!)) {
      levelCompleted = true;
      score += 500 + starsCollected * 100;
      
      // Prepare for next level
      Future.delayed(const Duration(seconds: 2), () {
        if (currentLevel < 3) {
          currentLevel++;
          startGame();
        } else {
          // All levels completed
          endGame();
        }
      });
    }
    
    // Check collision with obstacles
    for (var obstacle in obstacles) {
      if (candy!.intersects(obstacle)) {
        switch (obstacle.type) {
          case ObjectType.spikes:
            // Game over when hitting spikes
            isGameOver = true;
            endGame();
            break;
          case ObjectType.bubble:
            // Bubble makes candy float up
            candy!.velocity = const Offset(0, -3);
            break;
          case ObjectType.airCushion:
            // Air cushion pushes candy
            double angle = atan2(
              candy!.position.dy - obstacle.position.dy,
              candy!.position.dx - obstacle.position.dx,
            );
            candy!.velocity += Offset(cos(angle) * 2, sin(angle) * 2);
            break;
          default:
            break;
        }
      }
    }
  }
  
  // Handle touch start
  void onTouchStart(Offset position) {
    if (!isGameRunning) return;
    
    touchPosition = position;
    cutPath.clear();
    cutPath.add(position);
    update();
  }
  
  // Handle touch move (drag for rope cutting)
  void onTouchMove(Offset position) {
    if (!isGameRunning || touchPosition == null) return;
    
    cutPath.add(position);
    
    // Check if any rope is cut by this movement
    for (var rope in ropes) {
      if (rope.isCut) continue;
      
      for (int i = 0; i < cutPath.length - 1; i++) {
        Offset p1 = cutPath[i];
        Offset p2 = cutPath[i + 1];
        
        // Calculate rope position
        double ropeEndX = rope.anchorPoint.dx + sin(rope.angle) * rope.length;
        double ropeEndY = rope.anchorPoint.dy + cos(rope.angle) * rope.length;
        Offset ropeEnd = Offset(ropeEndX, ropeEndY);
        
        // Check if line segment (p1,p2) intersects with rope
        if (_lineIntersectsLine(p1, p2, rope.anchorPoint, ropeEnd)) {
          rope.isCut = true;
          
          // Add some random velocity when cut
          if (candy != null) {
            double randomX = Random().nextDouble() * 2 - 1;
            candy!.velocity += Offset(randomX, 0);
          }
        }
      }
    }
    
    update();
  }
  
  // Handle touch end
  void onTouchEnd() {
    touchPosition = null;
    cutPath.clear();
    update();
  }
  
  // Check if two line segments intersect
  bool _lineIntersectsLine(Offset a, Offset b, Offset c, Offset d) {
    // Line segment a-b to c-d intersection algorithm
    double denominator = ((b.dx - a.dx) * (d.dy - c.dy) - (b.dy - a.dy) * (d.dx - c.dx));
    
    if (denominator == 0) {
      return false; // Lines are parallel
    }
    
    double ua = ((c.dx - a.dx) * (d.dy - c.dy) - (c.dy - a.dy) * (d.dx - c.dx)) / denominator;
    double ub = ((a.dx - c.dx) * (a.dy - b.dy) - (a.dy - c.dy) * (a.dx - b.dx)) / -denominator;
    
    return ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1;
  }
  
  // Reset the current level
  void resetLevel() {
    loadLevel(currentLevel);
    isGameOver = false;
    levelCompleted = false;
    update();
  }
  
  // Controller cleanup
  @override
  void onClose() {
    gameTimer?.cancel();
    gameTimer = null;
    super.onClose();
  }
} 