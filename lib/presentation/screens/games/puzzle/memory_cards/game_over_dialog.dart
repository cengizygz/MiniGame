import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int moves;
  final int highScore;
  final VoidCallback onRestart;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.moves,
    required this.highScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score > highScore;
    return AlertDialog(
      title: Text('game_complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text('all_pairs_found'),
          const SizedBox(height: 16),
          Text('Moves: $moves', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (isNewHighScore) ...[
            const SizedBox(height: 16),
            Text('New High Score!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
          const SizedBox(height: 8),
          Text('High Score: $highScore', style: const TextStyle(fontSize: 16, color: Colors.amber)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRestart,
          child: const Text('Play Again'),
        ),
      ],
    );
  }
} 