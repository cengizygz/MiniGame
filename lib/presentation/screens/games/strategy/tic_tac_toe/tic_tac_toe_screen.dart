import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'tic_tac_toe_controller.dart';

class TicTacToeScreen extends StatelessWidget {
  const TicTacToeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    final controller = Get.put(TicTacToeController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.strategyGames);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('tic_tac_toe'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.strategyGames),
          ),
          actions: [
            // Zorluk seviyesi
            GetBuilder<TicTacToeController>(
              builder: (ctrl) => PopupMenuButton<AIDifficulty>(
                icon: const Icon(Icons.tune),
                tooltip: 'difficulty'.tr,
                onSelected: (AIDifficulty value) {
                  ctrl.setDifficulty(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: AIDifficulty.easy,
                    child: Text('easy'.tr),
                    enabled: ctrl.aiDifficulty != AIDifficulty.easy,
                  ),
                  PopupMenuItem(
                    value: AIDifficulty.medium,
                    child: Text('medium'.tr),
                    enabled: ctrl.aiDifficulty != AIDifficulty.medium,
                  ),
                  PopupMenuItem(
                    value: AIDifficulty.hard,
                    child: Text('hard'.tr),
                    enabled: ctrl.aiDifficulty != AIDifficulty.hard,
                  ),
                ],
              ),
            ),
            
            // Bilgi butonu
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showRulesDialog(context),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skor göstergesi
            _buildScoreBoard(),
            
            // Durum mesajı
            _buildStatusMessage(),
            
            // Oyun tahtası
            _buildGameBoard(),
            
            // İpucu butonu
            GetBuilder<TicTacToeController>(
              builder: (ctrl) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => ElevatedButton.icon(
                      onPressed: ctrl.isPlayerTurn && ctrl.gameResult == TicTacToeResult.ongoing
                          ? ctrl.requestHint
                          : null, 
                      icon: const Icon(Icons.lightbulb_outline),
                      label: Text('İpucu (${ctrl.hintCount.value})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            // Kontrol butonları
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }
  
  // Skor göstergesini oluştur
  Widget _buildScoreBoard() {
    return GetBuilder<TicTacToeController>(
      builder: (ctrl) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Oyuncu skoru
            _buildScoreItem('player'.tr, ctrl.playerScore, Icons.person, Colors.blue),
            
            // Berabere
            _buildScoreItem('draws'.tr, ctrl.draws, Icons.balance, Colors.grey),
            
            // AI skoru
            _buildScoreItem('ai'.tr, ctrl.aiScore, Icons.computer, Colors.red),
          ],
        ),
      ),
    );
  }
  
  // Skor öğesi oluştur
  Widget _buildScoreItem(String label, int score, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  // Durum mesajını oluştur
  Widget _buildStatusMessage() {
    return GetBuilder<TicTacToeController>(
      builder: (ctrl) {
        String message;
        Color color;
        
        switch (ctrl.gameResult) {
          case TicTacToeResult.ongoing:
            message = ctrl.isPlayerTurn ? 'your_turn'.tr : 'ai_thinking'.tr;
            color = ctrl.isPlayerTurn ? Colors.blue : Colors.orange;
            break;
          case TicTacToeResult.xWins:
            message = 'you_win'.tr;
            color = Colors.green;
            break;
          case TicTacToeResult.oWins:
            message = 'ai_wins'.tr;
            color = Colors.red;
            break;
          case TicTacToeResult.draw:
            message = 'draw_game'.tr;
            color = Colors.purple;
            break;
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        );
      },
    );
  }
  
  // Oyun tahtasını oluştur
  Widget _buildGameBoard() {
    return GetBuilder<TicTacToeController>(
      builder: (ctrl) {
        return Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemCount: 9,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final row = index ~/ 3;
                final col = index % 3;
                final mark = ctrl.board[row][col];
                final isLastMove = row == ctrl.lastMoveRow && col == ctrl.lastMoveCol;
                final isHintMove = ctrl.showingHint.value && 
                                   ctrl.hintMove != null && 
                                   ctrl.hintMove!.isNotEmpty &&
                                   ctrl.hintMove![0][0] == row && 
                                   ctrl.hintMove![0][1] == col;
                
                return GestureDetector(
                  onTap: () => ctrl.handleTap(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: row > 0 ? Colors.grey : Colors.transparent),
                        left: BorderSide(color: col > 0 ? Colors.grey : Colors.transparent),
                        right: BorderSide(color: col < 2 ? Colors.transparent : Colors.grey),
                        bottom: BorderSide(color: row < 2 ? Colors.transparent : Colors.grey),
                      ),
                      color: isLastMove 
                          ? (ctrl.isPlayerTurn ? Colors.blue.shade100 : Colors.orange.shade100)
                          : isHintMove 
                              ? Colors.green.withOpacity(0.3)
                              : Colors.transparent,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildMarkWidget(mark),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  // İşaretleri oluştur (X veya O)
  Widget _buildMarkWidget(TicTacToeMark mark) {
    switch (mark) {
      case TicTacToeMark.x:
        return const Icon(
          Icons.close,
          size: 50,
          color: Colors.blue,
          key: ValueKey('X'),
        );
      case TicTacToeMark.o:
        return const Icon(
          Icons.circle_outlined,
          size: 40,
          color: Colors.red,
          key: ValueKey('O'),
        );
      default:
        return const SizedBox(key: ValueKey('empty'));
    }
  }
  
  // Hücreyi oluştur
  Widget _buildCell(TicTacToeController ctrl, int row, int col) {
    final isLastMove = ctrl.lastMoveRow == row && ctrl.lastMoveCol == col;
    final cellValue = ctrl.board[row][col];
    
    return GestureDetector(
      onTap: () => ctrl.handleTap(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isLastMove 
              ? Colors.yellow.withOpacity(0.3) 
              : Colors.purple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLastMove 
                ? Colors.orange 
                : Colors.purple.withOpacity(0.3),
            width: isLastMove ? 2 : 1,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCellContent(cellValue),
          ),
        ),
      ),
    );
  }
  
  // Hücre içeriğini oluştur
  Widget _buildCellContent(TicTacToeMark mark) {
    switch (mark) {
      case TicTacToeMark.x:
        return const Icon(
          Icons.close,
          size: 50,
          color: Colors.blue,
          key: ValueKey('X'),
        );
      case TicTacToeMark.o:
        return const Icon(
          Icons.circle_outlined,
          size: 40,
          color: Colors.red,
          key: ValueKey('O'),
        );
      default:
        return const SizedBox(key: ValueKey('empty'));
    }
  }
  
  // Kontrol butonlarını oluştur
  Widget _buildControlButtons() {
    return GetBuilder<TicTacToeController>(
      builder: (ctrl) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Yeni Tur butonu
            ElevatedButton.icon(
              onPressed: () => ctrl.resetBoard(),
              icon: const Icon(Icons.refresh),
              label: Text('new_round'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            
            // Yeni Oyun butonu
            ElevatedButton.icon(
              onPressed: () => ctrl.resetGame(),
              icon: const Icon(Icons.restart_alt),
              label: Text('new_game'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Kurallar dialogu
  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('tic_tac_toe_rules'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('tic_tac_toe_desc'.tr),
              const SizedBox(height: 16),
              
              Text(
                'rules'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              _buildRuleItem(Icons.grid_3x3, 'tic_tac_toe_rule_1'.tr),
              _buildRuleItem(Icons.person, 'tic_tac_toe_rule_2'.tr),
              _buildRuleItem(Icons.computer, 'tic_tac_toe_rule_3'.tr),
              _buildRuleItem(Icons.emoji_events, 'tic_tac_toe_rule_4'.tr),
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
  
  // Kural öğesi
  Widget _buildRuleItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
} 