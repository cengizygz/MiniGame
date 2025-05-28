import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Note type for music game
enum NoteType {
  single,
  long,
  double
}

// Track position (lane) for notes
enum TrackPosition {
  left,
  center,
  right
}

// Note timing accuracy
enum TimingAccuracy {
  miss,
  good,
  perfect
}

// Note class to represent a music note in the game
class MusicNote {
  final int id;
  final NoteType type;
  final TrackPosition track;
  final Color color;
  double position; // 0.0 to 1.0 where 1.0 is at the bottom
  bool isHit = false;
  bool isActive = true;
  
  MusicNote({
    required this.id,
    required this.type,
    required this.track,
    required this.color,
    this.position = 0.0,
  });
}

// Song class to represent a playable song
class Song {
  final String name;
  final String artist;
  final int bpm; // Beats per minute
  final int duration; // In seconds
  final String assetPath; // Path to audio file
  
  Song({
    required this.name,
    required this.artist,
    required this.bpm,
    required this.duration,
    required this.assetPath,
  });
}

class MusicNotesController extends GetxController {
  // Game state
  bool isGameStarted = false;
  bool isGamePaused = false;
  bool isGameOver = false;
  
  // Score tracking
  int currentScore = 0;
  int highScore = 0;
  int combo = 0;
  int maxCombo = 0;
  int perfectHits = 0;
  int goodHits = 0;
  int missedNotes = 0;
  
  // Game parameters
  final double hitAccuracy = 0.05; // ±5% for perfect timing
  final double goodAccuracy = 0.15; // ±15% for good timing
  
  // Game objects
  List<MusicNote> notes = [];
  int noteIdCounter = 0;
  
  // Timing feedback
  TimingAccuracy? lastAccuracy;
  Offset? lastHitPosition;
  Timer? feedbackTimer;
  
  // Song and difficulty
  Song? currentSong;
  String difficulty = 'medium'; // 'easy', 'medium', 'hard'
  double noteSpeed = 0.01; // How fast notes move (position units per frame)
  
  // Available songs
  final List<Song> availableSongs = [
    Song(
      name: 'Song 1',
      artist: 'Artist 1',
      bpm: 120,
      duration: 90,
      assetPath: 'assets/audio/song1.mp3',
    ),
    Song(
      name: 'Song 2',
      artist: 'Artist 2',
      bpm: 140,
      duration: 120,
      assetPath: 'assets/audio/song2.mp3',
    ),
    Song(
      name: 'Song 3',
      artist: 'Artist 3',
      bpm: 160,
      duration: 105,
      assetPath: 'assets/audio/song3.mp3',
    ),
  ];
  
  // Track positions for the three lanes
  Map<TrackPosition, double> trackPositions = {
    TrackPosition.left: 0.25,
    TrackPosition.center: 0.5,
    TrackPosition.right: 0.75,
  };
  
  // Random generator
  final Random random = Random();
  
  // Game timer
  Timer? gameTimer;
  
  // Game initialization
  void initGame() {
    resetGame();
  }
  
  // Reset game state
  void resetGame() {
    // Reset game state
    isGameStarted = false;
    isGamePaused = false;
    isGameOver = false;
    
    // Reset score
    currentScore = 0;
    combo = 0;
    maxCombo = 0;
    perfectHits = 0;
    goodHits = 0;
    missedNotes = 0;
    
    // Clear notes
    notes.clear();
    noteIdCounter = 0;
    
    // Reset timing feedback
    lastAccuracy = null;
    lastHitPosition = null;
    feedbackTimer?.cancel();
    feedbackTimer = null;
    
    // Stop game timer
    gameTimer?.cancel();
    gameTimer = null;
    
    update();
  }
  
  // Set difficulty
  void setDifficulty(String level) {
    difficulty = level;
    
    // Adjust note speed based on difficulty
    switch (level) {
      case 'easy':
        noteSpeed = 0.008;
        break;
      case 'medium':
        noteSpeed = 0.01;
        break;
      case 'hard':
        noteSpeed = 0.015;
        break;
    }
    
    update();
  }
  
  // Select song
  void selectSong(Song song) {
    currentSong = song;
    update();
  }
  
  // Start the game
  void startGame() {
    if (isGameStarted || currentSong == null) return;
    
    resetGame();
    isGameStarted = true;
    
    // Generate initial notes
    _generateNotes();
    
    // Start game loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!isGamePaused && !isGameOver) {
        _updateGame();
        update();
      }
    });
    
    // TODO: Start playing music
    
    update();
  }
  
  // Pause game
  void pauseGame() {
    isGamePaused = true;
    // TODO: Pause music
    update();
  }
  
  // Resume game
  void resumeGame() {
    isGamePaused = false;
    // TODO: Resume music
    update();
  }
  
  // End game
  void endGame() {
    isGameOver = true;
    gameTimer?.cancel();
    gameTimer = null;
    
    // Update high score
    if (currentScore > highScore) {
      highScore = currentScore;
      // TODO: Save high score
    }
    
    // TODO: Stop music
    
    update();
  }
  
  // Generate notes based on song BPM and difficulty
  void _generateNotes() {
    if (currentSong == null) return;
    
    // Clear existing notes
    notes.clear();
    
    // Calculate how many notes to generate based on song length and BPM
    final double beatsPerSecond = currentSong!.bpm / 60;
    
    // Factor to adjust note density based on difficulty
    double densityFactor;
    switch (difficulty) {
      case 'easy':
        densityFactor = 0.5; // 50% of beats have notes
        break;
      case 'medium':
        densityFactor = 0.7; // 70% of beats have notes
        break;
      case 'hard':
        densityFactor = 1.0; // 100% of beats have notes
        break;
      default:
        densityFactor = 0.7;
    }
    
    // Total beats in the song
    final int totalBeats = (currentSong!.duration * beatsPerSecond).round();
    
    // Generate notes
    for (int i = 0; i < totalBeats; i++) {
      // Determine if this beat should have a note
      if (random.nextDouble() < densityFactor) {
        // Choose random track
        final TrackPosition track = TrackPosition.values[random.nextInt(TrackPosition.values.length)];
        
        // Choose note type based on difficulty
        NoteType type;
        final typeRoll = random.nextDouble();
        
        if (difficulty == 'easy') {
          type = NoteType.single; // Only single notes on easy
        } else if (difficulty == 'medium') {
          type = typeRoll < 0.8 ? NoteType.single : NoteType.long;
        } else {
          // Hard difficulty
          if (typeRoll < 0.6) {
            type = NoteType.single;
          } else if (typeRoll < 0.9) {
            type = NoteType.long;
          } else {
            type = NoteType.double;
          }
        }
        
        // Choose note color
        final List<Color> noteColors = [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
        ];
        final Color color = noteColors[random.nextInt(noteColors.length)];
        
        // Calculate position based on beat timing
        // Position is negative to start off-screen and move into view
        // The higher the note speed, the more spaced out the notes need to be
        final double position = -1.0 - (i / beatsPerSecond) * noteSpeed * 60;
        
        // Create note
        final note = MusicNote(
          id: noteIdCounter++,
          type: type,
          track: track,
          color: color,
          position: position,
        );
        
        notes.add(note);
      }
    }
  }
  
  // Update game state
  void _updateGame() {
    // Update note positions
    for (final note in notes) {
      if (note.isActive) {
        note.position += noteSpeed;
        
        // Check if note was missed
        if (note.position > 1.0 + hitAccuracy && !note.isHit) {
          note.isActive = false;
          _handleMiss();
        }
      }
    }
    
    // Check if all notes are processed
    if (notes.where((note) => note.isActive).isEmpty && noteIdCounter > 0) {
      endGame();
    }
  }
  
  // Handle note tap for a track
  void tapTrack(TrackPosition track) {
    if (!isGameStarted || isGamePaused || isGameOver) return;
    
    // Find the closest active note on this track that's near the hit line
    MusicNote? hitNote;
    double closestDistance = 1.0;
    
    for (final note in notes) {
      if (note.isActive && !note.isHit && note.track == track) {
        final double distance = (note.position - 1.0).abs();
        
        if (distance < closestDistance) {
          hitNote = note;
          closestDistance = distance;
        }
      }
    }
    
    // Process hit if found a note
    if (hitNote != null) {
      // Determine hit accuracy
      if (closestDistance <= hitAccuracy) {
        // Perfect hit
        _handlePerfectHit(hitNote);
      } else if (closestDistance <= goodAccuracy) {
        // Good hit
        _handleGoodHit(hitNote);
      } else if (hitNote.position > 0.7) {
        // Note is on screen and was tapped, but timing was off
        _handleMiss();
      }
    } else {
      // Tapped with no valid notes
      _handleMiss();
    }
    
    update();
  }
  
  // Handle perfect hit
  void _handlePerfectHit(MusicNote note) {
    perfectHits++;
    combo++;
    currentScore += 100 * combo; // Score more with combos
    
    // Track max combo
    if (combo > maxCombo) {
      maxCombo = combo;
    }
    
    // Mark note as hit
    note.isHit = true;
    note.isActive = false;
    
    // Show perfect feedback
    lastAccuracy = TimingAccuracy.perfect;
    lastHitPosition = Offset(
      trackPositions[note.track]!,
      1.0,
    );
    
    _scheduleFeedbackClear();
  }
  
  // Handle good hit
  void _handleGoodHit(MusicNote note) {
    goodHits++;
    combo++;
    currentScore += 50 * combo; // Score more with combos
    
    // Track max combo
    if (combo > maxCombo) {
      maxCombo = combo;
    }
    
    // Mark note as hit
    note.isHit = true;
    note.isActive = false;
    
    // Show good feedback
    lastAccuracy = TimingAccuracy.good;
    lastHitPosition = Offset(
      trackPositions[note.track]!,
      1.0,
    );
    
    _scheduleFeedbackClear();
  }
  
  // Handle miss
  void _handleMiss() {
    missedNotes++;
    combo = 0; // Reset combo
    
    // Show miss feedback
    lastAccuracy = TimingAccuracy.miss;
    
    _scheduleFeedbackClear();
    
    // End game if too many misses
    if (missedNotes >= 10) {
      endGame();
    }
  }
  
  // Clear feedback after delay
  void _scheduleFeedbackClear() {
    feedbackTimer?.cancel();
    feedbackTimer = Timer(const Duration(milliseconds: 500), () {
      lastAccuracy = null;
      lastHitPosition = null;
      update();
    });
  }
  
  // Controller cleanup
  @override
  void onClose() {
    gameTimer?.cancel();
    feedbackTimer?.cancel();
    super.onClose();
  }
} 