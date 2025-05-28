import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'piano_tiles_controller.dart';

class PianoTilesScreen extends StatelessWidget {
  const PianoTilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(PianoTilesController());
    controller.initGame();
    
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('piano_tiles'.tr),
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
            GetBuilder<PianoTilesController>(
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
        body: GetBuilder<PianoTilesController>(
          builder: (ctrl) {
            if (!ctrl.isGameStarted) {
              // Game selection screen
              return _buildStartScreen(context);
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
  
  // Game start screen
  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'piano_tiles'.tr,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'piano_tiles_desc'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Rules
              _buildRulesCard(context),
              
              const SizedBox(height: 40),
              
              // Game modes
              Text(
                'select_mode'.tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Game mode cards
              _buildGameModeCard(
                context,
                GameMode.classic,
                'classic_mode'.tr,
                'Tap the tiles in sequence without missing any.',
                Colors.indigo,
                Icons.music_note,
              ),
              
              const SizedBox(height: 16),
              
              _buildGameModeCard(
                context,
                GameMode.arcade,
                'arcade_mode'.tr,
                'Play for 60 seconds with increasing speed.',
                Colors.purple,
                Icons.speed,
              ),
              
              const SizedBox(height: 16),
              
              _buildGameModeCard(
                context,
                GameMode.zen,
                'zen_mode'.tr,
                'Relaxed mode with no penalties for missing tiles.',
                Colors.teal,
                Icons.spa,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Rules card
  Widget _buildRulesCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'piano_tiles_rules'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            const Divider(),
            _buildRuleItem('piano_tiles_rule_1'.tr),
            _buildRuleItem('piano_tiles_rule_2'.tr),
            _buildRuleItem('piano_tiles_rule_3'.tr),
            _buildRuleItem('piano_tiles_rule_4'.tr),
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
            color: Colors.indigo.shade400,
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
  
  // Game mode card
  Widget _buildGameModeCard(
    BuildContext context,
    GameMode mode,
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          final controller = Get.find<PianoTilesController>();
          controller.setGameMode(mode);
          controller.startGame();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Game screen
  Widget _buildGameScreen(BuildContext context) {
    return GetBuilder<PianoTilesController>(
      builder: (ctrl) {
        // Game stats display
        Widget gameStats;
        
        if (ctrl.gameMode == GameMode.arcade) {
          // Arcade mode: show time left
          gameStats = Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBox('tiles_tapped'.tr, '${ctrl.tilesTapped}', Icons.touch_app),
              _buildStatBox('time_left'.tr, '${ctrl.arcadeModeTimeLeft}s', Icons.timer),
              _buildStatBox('speed'.tr, '${(ctrl.speedMultiplier).toStringAsFixed(1)}x', Icons.speed),
            ],
          );
        } else {
          // Classic and Zen modes: show high score
          gameStats = Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBox('tiles_tapped'.tr, '${ctrl.tilesTapped}', Icons.touch_app),
              _buildStatBox('high_score'.tr, '${ctrl.highScore}', Icons.emoji_events),
              _buildStatBox('speed'.tr, '${(ctrl.speedMultiplier).toStringAsFixed(1)}x', Icons.speed),
            ],
          );
        }
        
        return Column(
          children: [
            // Stats area
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.grey.shade100,
              child: gameStats,
            ),
            
            // Game area
            Expanded(
              child: _buildGameArea(context),
            ),
          ],
        );
      },
    );
  }
  
  // Stat box widget
  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.indigo,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Game area with piano tiles
  Widget _buildGameArea(BuildContext context) {
    return GetBuilder<PianoTilesController>(
      builder: (ctrl) {
        // Calculate column width
        final double columnWidth = MediaQuery.of(context).size.width / ctrl.columnCount;
        
        return Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Container(
              color: Colors.white,
            ),
            
            // Column dividers
            ...List.generate(ctrl.columnCount - 1, (index) {
              return Positioned(
                left: columnWidth * (index + 1),
                top: 0,
                bottom: 0,
                width: 1,
                child: Container(
                  color: Colors.grey.shade300,
                ),
              );
            }),
            
            // Piano tiles
            ...ctrl.tiles.map((tile) {
              // Skip inactive tiles
              if (!tile.isActive || tile.isHit) return const SizedBox.shrink();
              
              // Calculate tile position
              final double left = tile.column * columnWidth;
              final double top = MediaQuery.of(context).size.height * (tile.position - ctrl.tileHeight);
              final double tileDisplayHeight = MediaQuery.of(context).size.height * ctrl.tileHeight;
              
              return Positioned(
                left: left,
                top: top,
                width: columnWidth,
                height: tileDisplayHeight,
                child: Container(
                  color: Colors.black,
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: columnWidth * 0.4,
                    ),
                  ),
                ),
              );
            }).toList(),
            
            // Touch areas
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Row(
                children: List.generate(ctrl.columnCount, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.tapColumn(index),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Game over screen
  Widget _buildGameOverScreen(BuildContext context) {
    return GetBuilder<PianoTilesController>(
      builder: (ctrl) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade200,
              Colors.indigo.shade400,
            ],
          ),
        ),
        child: Center(
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
                      color: Colors.indigo,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats
                  _buildResultStat('tiles_tapped'.tr, ctrl.tilesTapped.toString(), Icons.touch_app),
                  const Divider(height: 20),
                  _buildResultStat('max_combo'.tr, '${ctrl.maxCombo}x', Icons.trending_up),
                  const Divider(height: 20),
                  _buildResultStat('high_score'.tr, ctrl.highScore.toString(), Icons.emoji_events),
                  
                  // New high score indicator
                  if (ctrl.tilesTapped >= ctrl.highScore)
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
                          backgroundColor: Colors.indigo,
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
      ),
    );
  }
  
  // Result stat
  Widget _buildResultStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.indigo.shade300,
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
            color: Colors.indigo,
          ),
        ),
      ],
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
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => Get.find<PianoTilesController>().resumeGame(),
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
} 