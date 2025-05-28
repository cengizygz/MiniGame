import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/app_routes.dart';
import 'snake_controller.dart';
import 'snake_model.dart';

class SnakeScreen extends StatelessWidget {
  const SnakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(SnakeController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.arcadeGames);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('snake'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.arcadeGames),
          ),
          actions: [
            // Difficulty level selector
            GetBuilder<SnakeController>(
              builder: (ctrl) => PopupMenuButton<int>(
                icon: const Icon(Icons.tune),
                tooltip: 'difficulty'.tr,
                onSelected: (int value) {
                  ctrl.setDifficulty(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    enabled: ctrl.difficulty.value != 1,
                    child: Text('easy'.tr),
                  ),
                  PopupMenuItem(
                    value: 2,
                    enabled: ctrl.difficulty.value != 2,
                    child: Text('medium'.tr),
                  ),
                  PopupMenuItem(
                    value: 3,
                    enabled: ctrl.difficulty.value != 3,
                    child: Text('hard'.tr),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Score display
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GetBuilder<SnakeController>(
                        builder: (ctrl) => Text(
                          '${'score'.tr}: ${ctrl.getScore()}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      GetBuilder<SnakeController>(
                        builder: (ctrl) => Text(
                          '${'high_score'.tr}: ${ctrl.highScore}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Game board
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 0.75, // 3:4 aspect ratio for the board
                      child: _buildGameBoard(context),
                    ),
                  ),
                ),
                
                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: _buildControls(context),
                ),
              ],
            ),
            
            // Game over overlay
            GetBuilder<SnakeController>(
              builder: (ctrl) {
                if (ctrl.isGameOver.value) {
                  return _buildGameOverOverlay(context, ctrl);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            
            // Pause overlay
            GetBuilder<SnakeController>(
              builder: (ctrl) {
                if (ctrl.isPaused.value && !ctrl.isGameOver.value) {
                  return _buildPauseOverlay(context, ctrl);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            
            // Direction indicator
            Positioned(
              right: 16,
              top: 80,
              child: GetBuilder<SnakeController>(
                builder: (ctrl) => _buildDirectionIndicator(ctrl),
              ),
            ),
          ],
        ),
        floatingActionButton: GetBuilder<SnakeController>(
          builder: (ctrl) => FloatingActionButton(
            onPressed: () {
              if (ctrl.isGameOver.value) {
                ctrl.startNewGame();
              } else {
                ctrl.togglePause();
              }
            },
            child: Icon(
              ctrl.isGameOver.value
                  ? Icons.replay
                  : (ctrl.isPaused.value ? Icons.play_arrow : Icons.pause),
            ),
          ),
        ),
      ),
    );
  }
  
  // Build game board
  Widget _buildGameBoard(BuildContext context) {
    return GetBuilder<SnakeController>(
      builder: (ctrl) {
        return RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (event) {
            if (event is RawKeyDownEvent) {
              _handleKeyboardInput(event, ctrl);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: ctrl.boardColor,
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0) {
                  // Swipe down
                  ctrl.changeDirection(Direction.down);
                } else if (details.delta.dy < 0) {
                  // Swipe up
                  ctrl.changeDirection(Direction.up);
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  // Swipe right
                  ctrl.changeDirection(Direction.right);
                } else if (details.delta.dx < 0) {
                  // Swipe left
                  ctrl.changeDirection(Direction.left);
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ctrl.getBoardWidth(),
                ),
                itemCount: ctrl.getBoardWidth() * ctrl.getBoardHeight(),
                itemBuilder: (context, index) {
                  final x = index % ctrl.getBoardWidth();
                  final y = index ~/ ctrl.getBoardWidth();
                  return _buildGridCell(ctrl, x, y);
                },
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Build a single cell in the grid
  Widget _buildGridCell(SnakeController ctrl, int x, int y) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: ctrl.getCellColor(x, y),
        borderRadius: BorderRadius.circular(
          ctrl.isSnakeHead(x, y) ? 4 : 2,
        ),
      ),
      // Add eyes to snake head
      child: ctrl.isSnakeHead(x, y) 
          ? const Icon(Icons.remove_red_eye, size: 14, color: Colors.white)
          : null,
    );
  }
  
  // Build control buttons
  Widget _buildControls(BuildContext context) {
    return GetBuilder<SnakeController>(
      builder: (ctrl) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Up button
              Center(
                child: _buildDirectionButton(
                  icon: Icons.keyboard_arrow_up,
                  onPressed: () => ctrl.changeDirection(Direction.up),
                ),
              ),
              const SizedBox(height: 8),
              // Left, Pause/Play, Right buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDirectionButton(
                    icon: Icons.keyboard_arrow_left,
                    onPressed: () => ctrl.changeDirection(Direction.left),
                  ),
                  const SizedBox(width: 56),
                  _buildDirectionButton(
                    icon: Icons.keyboard_arrow_right,
                    onPressed: () => ctrl.changeDirection(Direction.right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Down button
              Center(
                child: _buildDirectionButton(
                  icon: Icons.keyboard_arrow_down,
                  onPressed: () => ctrl.changeDirection(Direction.down),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Build a direction control button
  Widget _buildDirectionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.grey.shade200,
      ),
      child: Icon(
        icon,
        size: 32,
        color: Colors.black87,
      ),
    );
  }
  
  // Handle keyboard input
  void _handleKeyboardInput(RawKeyEvent event, SnakeController ctrl) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      ctrl.changeDirection(Direction.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      ctrl.changeDirection(Direction.down);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      ctrl.changeDirection(Direction.left);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      ctrl.changeDirection(Direction.right);
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (ctrl.isGameOver.value) {
        ctrl.startNewGame();
      } else {
        ctrl.togglePause();
      }
    }
  }
  
  // Build game over overlay
  Widget _buildGameOverOverlay(BuildContext context, SnakeController ctrl) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_very_dissatisfied,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'game_over'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${'your_score'.tr}: ${ctrl.getScore()}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${'snake_length'.tr}: ${ctrl.getSnakeLength()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.arcadeGames),
                    icon: const Icon(Icons.arrow_back),
                    label: Text('exit'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => ctrl.startNewGame(),
                    icon: const Icon(Icons.replay),
                    label: Text('play_again'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build pause overlay
  Widget _buildPauseOverlay(BuildContext context, SnakeController ctrl) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause_circle_filled,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'game_paused'.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ctrl.togglePause(),
              icon: const Icon(Icons.play_arrow),
              label: Text('resume'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build direction indicator
  Widget _buildDirectionIndicator(SnakeController ctrl) {
    IconData directionIcon;
    
    switch (ctrl.gameModel.value.direction) {
      case Direction.up:
        directionIcon = Icons.arrow_upward;
        break;
      case Direction.right:
        directionIcon = Icons.arrow_forward;
        break;
      case Direction.down:
        directionIcon = Icons.arrow_downward;
        break;
      case Direction.left:
        directionIcon = Icons.arrow_back;
        break;
      default:
        directionIcon = Icons.arrow_forward;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: Icon(
        directionIcon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
} 