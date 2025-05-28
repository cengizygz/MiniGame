import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'music_notes_controller.dart';

class MusicNotesScreen extends StatelessWidget {
  const MusicNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(MusicNotesController());
    controller.initGame();
    
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('music_notes'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Reset button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.resetGame();
              },
              tooltip: 'restart'.tr,
            ),
            
            // Pause/resume button (only visible during game)
            GetBuilder<MusicNotesController>(
              builder: (ctrl) => Visibility(
                visible: ctrl.isGameStarted && !ctrl.isGameOver,
                child: IconButton(
                  icon: Icon(ctrl.isGamePaused ? Icons.play_arrow : Icons.pause),
                  onPressed: () {
                    if (ctrl.isGamePaused) {
                      ctrl.resumeGame();
                    } else {
                      ctrl.pauseGame();
                    }
                  },
                  tooltip: ctrl.isGamePaused ? 'resume'.tr : 'pause'.tr,
                ),
              ),
            ),
          ],
        ),
        body: GetBuilder<MusicNotesController>(
          builder: (ctrl) {
            if (!ctrl.isGameStarted) {
              // Game setup screen
              return _buildSetupScreen(context);
            } else if (ctrl.isGameOver) {
              // Game over screen
              return _buildGameOverScreen(context);
            } else if (ctrl.isGamePaused) {
              // Paused game screen
              return _buildPausedScreen(context);
            } else {
              // Active game screen
              return _buildGameScreen(context);
            }
          },
        ),
      ),
    );
  }
  
  // Game setup screen
  Widget _buildSetupScreen(BuildContext context) {
    return GetBuilder<MusicNotesController>(
      builder: (ctrl) => Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title and description
                Text(
                  'music_notes'.tr,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'music_notes_desc'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Rules
                _buildRulesCard(context),
                const SizedBox(height: 30),
                
                // Song selection
                Text(
                  'song_select'.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Song list
                ..._buildSongList(ctrl),
                const SizedBox(height: 30),
                
                // Difficulty selection
                Text(
                  'difficulty'.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Difficulty buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDifficultyButton(ctrl, 'easy', Colors.green),
                    _buildDifficultyButton(ctrl, 'medium', Colors.orange),
                    _buildDifficultyButton(ctrl, 'hard', Colors.red),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Start button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ctrl.currentSong != null ? Colors.purple : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: ctrl.currentSong != null
                      ? () => ctrl.startGame()
                      : null,
                  child: Text(
                    'start'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Rules card
  Widget _buildRulesCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'music_notes_rules'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            const Divider(),
            _buildRuleItem('music_notes_rule_1'.tr),
            _buildRuleItem('music_notes_rule_2'.tr),
            _buildRuleItem('music_notes_rule_3'.tr),
            _buildRuleItem('music_notes_rule_4'.tr),
          ],
        ),
      ),
    );
  }
  
  // Rule item
  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.purple.shade400,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Song list
  List<Widget> _buildSongList(MusicNotesController ctrl) {
    return ctrl.availableSongs.map((song) {
      final bool isSelected = ctrl.currentSong?.name == song.name;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Colors.purple.shade100 : Colors.white,
          child: InkWell(
            onTap: () => ctrl.selectSong(song),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.music_note,
                    color: isSelected ? Colors.purple : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? Colors.purple.shade800 : Colors.black,
                          ),
                        ),
                        Text(
                          song.artist,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.purple.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.purple.shade700,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
  
  // Difficulty button
  Widget _buildDifficultyButton(MusicNotesController ctrl, String level, Color color) {
    final bool isSelected = ctrl.difficulty == level;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () => ctrl.setDifficulty(level),
      child: Text(
        level.tr,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // Paused game screen
  Widget _buildPausedScreen(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'game_paused'.tr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => Get.find<MusicNotesController>().resumeGame(),
                  child: Text(
                    'resume'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.rhythmGames),
                  child: Text(
                    'exit'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Active game screen
  Widget _buildGameScreen(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return GetBuilder<MusicNotesController>(
      builder: (ctrl) => Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.shade100,
                  Colors.purple.shade300,
                ],
              ),
            ),
          ),
          
          // Score and combo display
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('score'.tr, ctrl.currentScore.toString(), Colors.purple.shade800),
                _buildStatCard('combo'.tr, '${ctrl.combo}x', Colors.orange.shade800),
                _buildStatCard('miss'.tr, ctrl.missedNotes.toString(), Colors.red.shade800),
              ],
            ),
          ),
          
          // Hit line
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Colors.white,
            ),
          ),
          
          // Lane dividers
          Positioned(
            top: 0,
            bottom: 0,
            left: screenSize.width * 0.33,
            child: Container(
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: screenSize.width * 0.67,
            child: Container(
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          
          // Notes
          ...ctrl.notes.map((note) {
            if (!note.isActive || note.position < 0 || note.position > 1.2) {
              return const SizedBox.shrink(); // Don't show inactive notes
            }
            
            // Convert relative position to screen position
            final double x = screenSize.width * ctrl.trackPositions[note.track]!;
            final double y = screenSize.height * note.position;
            
            // Note size
            final double noteSize = 60.0;
            
            // Note widget based on type
            Widget noteWidget;
            
            switch (note.type) {
              case NoteType.single:
                noteWidget = Container(
                  width: noteSize,
                  height: noteSize,
                  decoration: BoxDecoration(
                    color: note.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: note.color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 30,
                  ),
                );
                break;
                
              case NoteType.long:
                noteWidget = Container(
                  width: noteSize,
                  height: noteSize * 2,
                  decoration: BoxDecoration(
                    color: note.color,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: note.color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(height: 20),
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                );
                break;
                
              case NoteType.double:
                noteWidget = Container(
                  width: noteSize * 1.5,
                  height: noteSize,
                  decoration: BoxDecoration(
                    color: note.color,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: note.color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 25,
                      ),
                    ],
                  ),
                );
                break;
            }
            
            return Positioned(
              left: x - noteSize / 2,
              top: y - noteSize / 2,
              child: noteWidget,
            );
          }).toList(),
          
          // Track tap areas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => ctrl.tapTrack(TrackPosition.left),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => ctrl.tapTrack(TrackPosition.center),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => ctrl.tapTrack(TrackPosition.right),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Feedback indicators
          if (ctrl.lastAccuracy != null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: ctrl.lastAccuracy != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getAccuracyText(ctrl.lastAccuracy!),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getAccuracyColor(ctrl.lastAccuracy!),
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: _getAccuracyColor(ctrl.lastAccuracy!).withOpacity(0.7),
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Helper for accuracy text
  String _getAccuracyText(TimingAccuracy accuracy) {
    switch (accuracy) {
      case TimingAccuracy.perfect:
        return 'perfect'.tr;
      case TimingAccuracy.good:
        return 'good'.tr;
      case TimingAccuracy.miss:
        return 'miss'.tr;
    }
  }
  
  // Helper for accuracy color
  Color _getAccuracyColor(TimingAccuracy accuracy) {
    switch (accuracy) {
      case TimingAccuracy.perfect:
        return Colors.purple;
      case TimingAccuracy.good:
        return Colors.blue;
      case TimingAccuracy.miss:
        return Colors.red;
    }
  }
  
  // Stat card
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  // Game over screen
  Widget _buildGameOverScreen(BuildContext context) {
    return GetBuilder<MusicNotesController>(
      builder: (ctrl) => Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.shade200,
                  Colors.purple.shade400,
                ],
              ),
            ),
          ),
          
          // Game over content
          Center(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'game_over'.tr,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats
                    _buildResultStat('score'.tr, ctrl.currentScore.toString(), Icons.score),
                    const Divider(height: 20),
                    _buildResultStat('combo'.tr, 'Max: ${ctrl.maxCombo}x', Icons.trending_up),
                    const Divider(height: 20),
                    _buildResultStat('perfect'.tr, ctrl.perfectHits.toString(), Icons.stars),
                    const Divider(height: 20),
                    _buildResultStat('good'.tr, ctrl.goodHits.toString(), Icons.thumb_up),
                    const Divider(height: 20),
                    _buildResultStat('miss'.tr, ctrl.missedNotes.toString(), Icons.thumb_down),
                    
                    // New high score indicator
                    if (ctrl.currentScore >= ctrl.highScore)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade400),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'new_highscore'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () {
                            ctrl.resetGame();
                            ctrl.startGame();
                          },
                          child: Text(
                            'play_again'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () {
                            ctrl.resetGame();
                          },
                          child: Text(
                            'back'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Result stat
  Widget _buildResultStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.purple.shade300,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
} 