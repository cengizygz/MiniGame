import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'mini_chess_controller.dart';
import 'models/chess_piece.dart';
import 'models/chess_position.dart';

class MiniChessScreen extends StatelessWidget {
  const MiniChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(MiniChessController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.strategyGames);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('mini_chess'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.strategyGames),
          ),
          actions: [
            // Settings/Info button
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showRulesDialog(context),
            ),
            // Difficulty selector
            GetBuilder<MiniChessController>(
              builder: (ctrl) => PopupMenuButton<int>(
                icon: const Icon(Icons.tune),
                tooltip: 'difficulty'.tr,
                onSelected: (int value) {
                  ctrl.setDifficulty(value);
                  ctrl.resetGame();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text('easy'.tr),
                    enabled: ctrl.difficulty != 1,
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text('medium'.tr),
                    enabled: ctrl.difficulty != 2,
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Text('hard'.tr),
                    enabled: ctrl.difficulty != 3,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Status bar
            _buildStatusBar(),
            
            // Chess board
            Expanded(
              child: _buildChessBoard(),
            ),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  
  // Build game status bar
  Widget _buildStatusBar() {
    return GetBuilder<MiniChessController>(
      builder: (ctrl) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.brown.shade100,
            border: Border(
              bottom: BorderSide(
                color: Colors.brown.shade300,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current player
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: ctrl.isWhiteTurn ? Colors.white : Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.brown.shade700,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ctrl.isWhiteTurn ? 'white_turn'.tr : 'black_turn'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ],
              ),
              
              // Game state
              Text(
                _getGameStateText(ctrl),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getGameStateColor(ctrl),
                ),
              ),
              
              // Captured pieces counter
              Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.brown.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${ctrl.capturedBlackPieces.length}:${ctrl.capturedWhitePieces.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper to get game state text
  String _getGameStateText(MiniChessController ctrl) {
    if (ctrl.isCheckmate) {
      return ctrl.isWhiteTurn ? 'black_wins'.tr : 'white_wins'.tr;
    } else if (ctrl.isCheck) {
      return 'check'.tr;
    } else if (ctrl.isStalemate) {
      return 'stalemate'.tr;
    } else {
      return ''; // Normal game state
    }
  }
  
  // Helper to get game state color
  Color _getGameStateColor(MiniChessController ctrl) {
    if (ctrl.isCheckmate) {
      return Colors.red;
    } else if (ctrl.isCheck) {
      return Colors.orange;
    } else if (ctrl.isStalemate) {
      return Colors.blue;
    } else {
      return Colors.brown.shade800;
    }
  }
  
  // Build chess board
  Widget _buildChessBoard() {
    return GetBuilder<MiniChessController>(
      builder: (ctrl) {
        return Center(
          child: AspectRatio(
            aspectRatio: 1.0, // Square board
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.brown.shade700,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // 6x6 board for Mini Chess
                ),
                itemCount: 36, // 6x6 = 36 squares
                itemBuilder: (context, index) {
                  final row = index ~/ 6;
                  final col = index % 6;
                  final position = ChessPosition(row, col);
                  final isLightSquare = (row + col) % 2 == 0;
                  final piece = ctrl.getPieceAt(position);
                  final isSelected = ctrl.selectedPosition == position;
                  final isValidMove = ctrl.validMoves.contains(position);
                  
                  return GestureDetector(
                    onTap: () => ctrl.handleSquareTap(position),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getSquareColor(isLightSquare, isSelected, isValidMove),
                      ),
                      child: piece != null
                          ? _buildChessPiece(piece)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Helper to get square color
  Color _getSquareColor(bool isLightSquare, bool isSelected, bool isValidMove) {
    if (isSelected) {
      return Colors.blue.withOpacity(0.5);
    } else if (isValidMove) {
      return Colors.green.withOpacity(0.3);
    } else {
      return isLightSquare ? Colors.brown.shade200 : Colors.brown.shade500;
    }
  }
  
  // Build chess piece
  Widget _buildChessPiece(ChessPiece piece) {
    return Center(
      child: Icon(
        _getPieceIcon(piece),
        color: piece.isWhite ? Colors.white : Colors.black,
        size: 28,
        shadows: [
          Shadow(
            color: piece.isWhite ? Colors.black54 : Colors.white54,
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
  
  // Helper to get piece icon
  IconData _getPieceIcon(ChessPiece piece) {
    switch (piece.type) {
      case ChessPieceType.king:
        return Icons.crisis_alert;
      case ChessPieceType.queen:
        return Icons.diamond;
      case ChessPieceType.rook:
        return Icons.castle;
      case ChessPieceType.bishop:
        return Icons.church;
      case ChessPieceType.knight:
        return Icons.directions_bike;
      case ChessPieceType.pawn:
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }
  
  // Build action buttons
  Widget _buildActionButtons() {
    return GetBuilder<MiniChessController>(
      builder: (ctrl) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.brown.shade100,
          child: Column(
            children: [
              // Kontrol butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: ctrl.canUndo ? ctrl.undo : null,
                    icon: const Icon(Icons.undo),
                    label: Text('undo_move'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: ctrl.resetGame,
                    icon: const Icon(Icons.refresh),
                    label: Text('new_game'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  Obx(() => ElevatedButton.icon(
                    onPressed: ctrl.useHint,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text('İpucu (${ctrl.hintCount.value})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  // Show rules dialog
  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('mini_chess_rules'.tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('mini_chess_rules_desc'.tr),
              const SizedBox(height: 16),
              Text('piece_moves'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildRuleItem(Icons.person, 'pawn_rule'.tr),
              _buildRuleItem(Icons.directions_bike, 'knight_rule'.tr),
              _buildRuleItem(Icons.church, 'bishop_rule'.tr),
              _buildRuleItem(Icons.castle, 'rook_rule'.tr),
              _buildRuleItem(Icons.diamond, 'queen_rule'.tr),
              _buildRuleItem(Icons.crisis_alert, 'king_rule'.tr),
              const SizedBox(height: 16),
              Text('win_condition'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('win_condition_desc'.tr),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }
  
  // Helper to build rule item
  Widget _buildRuleItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
} 