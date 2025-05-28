import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'connect_four_controller.dart';

class ConnectFourScreen extends StatelessWidget {
  const ConnectFourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    final controller = Get.put(ConnectFourController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.strategyGames);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('connect_four'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.strategyGames),
          ),
          actions: [
            // Zorluk seviyesi
            GetBuilder<ConnectFourController>(
              builder: (ctrl) => PopupMenuButton<ConnectFourAIDifficulty>(
                icon: const Icon(Icons.tune),
                tooltip: 'difficulty'.tr,
                onSelected: (ConnectFourAIDifficulty value) {
                  ctrl.setDifficulty(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ConnectFourAIDifficulty.easy,
                    child: Text('easy'.tr),
                    enabled: ctrl.aiDifficulty != ConnectFourAIDifficulty.easy,
                  ),
                  PopupMenuItem(
                    value: ConnectFourAIDifficulty.medium,
                    child: Text('medium'.tr),
                    enabled: ctrl.aiDifficulty != ConnectFourAIDifficulty.medium,
                  ),
                  PopupMenuItem(
                    value: ConnectFourAIDifficulty.hard,
                    child: Text('hard'.tr),
                    enabled: ctrl.aiDifficulty != ConnectFourAIDifficulty.hard,
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
          children: [
            // Skor göstergesi
            _buildScoreBoard(),
            
            // Durum mesajı
            _buildStatusMessage(),
            
            // Diskler için düşürme butonları
            _buildDropButtons(),
            
            // Oyun tahtası
            _buildGameBoard(),
            
            // Kontrol butonları
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }
  
  // Skor göstergesini oluştur
  Widget _buildScoreBoard() {
    return GetBuilder<ConnectFourController>(
      builder: (ctrl) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Oyuncu skoru (kırmızı)
            _buildScoreItem('player'.tr, ctrl.playerScore, Icons.person, Colors.red),
            
            // Berabere
            _buildScoreItem('draws'.tr, ctrl.draws, Icons.balance, Colors.grey),
            
            // AI skoru (sarı)
            _buildScoreItem('ai'.tr, ctrl.aiScore, Icons.computer, Colors.amber),
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
    return GetBuilder<ConnectFourController>(
      builder: (ctrl) {
        String message;
        Color color;
        
        if (ctrl.isAnimating) {
          message = 'dropping_disc'.tr;
          color = Colors.orange;
        } else {
          switch (ctrl.gameState) {
            case ConnectFourGameState.ongoing:
              message = ctrl.isPlayerTurn ? 'your_turn'.tr : 'ai_thinking'.tr;
              color = ctrl.isPlayerTurn ? Colors.red : Colors.amber;
              break;
            case ConnectFourGameState.redWins:
              message = 'you_win'.tr;
              color = Colors.green;
              break;
            case ConnectFourGameState.yellowWins:
              message = 'ai_wins'.tr;
              color = Colors.red;
              break;
            case ConnectFourGameState.draw:
              message = 'draw_game'.tr;
              color = Colors.blue;
              break;
          }
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
  
  // Disk düşürme butonlarını oluştur
  Widget _buildDropButtons() {
    return GetBuilder<ConnectFourController>(
      builder: (ctrl) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (column) {
            // Sütunun dolu olup olmadığını ve oyun durumunu kontrol et
            bool isColumnFull = !ctrl.isValidMove(column);
            bool isGameOver = ctrl.gameState != ConnectFourGameState.ongoing;
            bool isAnimating = ctrl.isAnimating;
            bool isPlayerTurn = ctrl.isPlayerTurn;
            
            return IconButton(
              icon: Icon(
                Icons.arrow_drop_down,
                size: 36,
                color: (isColumnFull || isGameOver || isAnimating || !isPlayerTurn)
                    ? Colors.grey.withOpacity(0.5)
                    : Colors.red,
              ),
              onPressed: (isColumnFull || isGameOver || isAnimating || !isPlayerTurn)
                  ? null
                  : () => ctrl.dropDisk(column),
            );
          }),
        ),
      ),
    );
  }
  
  // Oyun tahtasını oluştur
  Widget _buildGameBoard() {
    return GetBuilder<ConnectFourController>(
      builder: (ctrl) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 7/6, // 7 sütun, 6 satır
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: 6 * 7, // 6 satır x 7 sütun
              itemBuilder: (context, index) {
                final row = index ~/ 7;
                final col = index % 7;
                return _buildCell(ctrl, row, col);
              },
            ),
          ),
        ),
      ),
    );
  }
  
  // Hücreyi oluştur
  Widget _buildCell(ConnectFourController ctrl, int row, int col) {
    final isLastMove = ctrl.lastMoveRow == row && ctrl.lastMoveCol == col;
    final cellValue = ctrl.board[row][col];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        shape: BoxShape.circle,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _getCellColor(cellValue),
          shape: BoxShape.circle,
          border: isLastMove
              ? Border.all(color: Colors.white, width: 2)
              : null,
          boxShadow: isLastMove 
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 1,
                  )
                ] 
              : null,
        ),
      ),
    );
  }
  
  // Hücre rengini al
  Color _getCellColor(ConnectFourDisk disk) {
    switch (disk) {
      case ConnectFourDisk.red:
        return Colors.red;
      case ConnectFourDisk.yellow:
        return Colors.amber;
      case ConnectFourDisk.empty:
        return Colors.white;
    }
  }
  
  // Kontrol butonlarını oluştur
  Widget _buildControlButtons() {
    return GetBuilder<ConnectFourController>(
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
                backgroundColor: Colors.blue.shade600,
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
                backgroundColor: Colors.blue.shade800,
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
        title: Text('connect_four_rules'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('connect_four_desc'.tr),
              const SizedBox(height: 16),
              
              Text(
                'rules'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              _buildRuleItem(Icons.grid_on, 'connect_four_rule_1'.tr),
              _buildRuleItem(Icons.person, 'connect_four_rule_2'.tr),
              _buildRuleItem(Icons.computer, 'connect_four_rule_3'.tr),
              _buildRuleItem(Icons.emoji_events, 'connect_four_rule_4'.tr),
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
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
} 