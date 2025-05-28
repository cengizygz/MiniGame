import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'math_race_controller.dart';

class MathRaceScreen extends StatelessWidget {
  const MathRaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    final controller = Get.put(MathRaceController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.educationalGames);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('math_race'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.educationalGames),
          ),
          actions: [
            // Zorluk seviyesi
            GetBuilder<MathRaceController>(
              builder: (ctrl) => PopupMenuButton<MathDifficulty>(
                icon: const Icon(Icons.tune),
                tooltip: 'difficulty'.tr,
                onSelected: (MathDifficulty value) {
                  ctrl.setDifficulty(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: MathDifficulty.easy,
                    child: Text('easy'.tr),
                    enabled: ctrl.difficulty != MathDifficulty.easy,
                  ),
                  PopupMenuItem(
                    value: MathDifficulty.medium,
                    child: Text('medium'.tr),
                    enabled: ctrl.difficulty != MathDifficulty.medium,
                  ),
                  PopupMenuItem(
                    value: MathDifficulty.hard,
                    child: Text('hard'.tr),
                    enabled: ctrl.difficulty != MathDifficulty.hard,
                  ),
                ],
              ),
            ),
            
            // İşlem türü
            GetBuilder<MathRaceController>(
              builder: (ctrl) => PopupMenuButton<OperationType>(
                icon: const Icon(Icons.calculate),
                tooltip: 'operation_type'.tr,
                onSelected: (OperationType value) {
                  ctrl.setOperationType(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: OperationType.addition,
                    child: Text('addition'.tr),
                    enabled: ctrl.operationType != OperationType.addition,
                  ),
                  PopupMenuItem(
                    value: OperationType.subtraction,
                    child: Text('subtraction'.tr),
                    enabled: ctrl.operationType != OperationType.subtraction,
                  ),
                  PopupMenuItem(
                    value: OperationType.multiplication,
                    child: Text('multiplication'.tr),
                    enabled: ctrl.operationType != OperationType.multiplication,
                  ),
                  PopupMenuItem(
                    value: OperationType.division,
                    child: Text('division'.tr),
                    enabled: ctrl.operationType != OperationType.division,
                  ),
                  PopupMenuItem(
                    value: OperationType.mixed,
                    child: Text('mixed'.tr),
                    enabled: ctrl.operationType != OperationType.mixed,
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
            // Skor ve zaman göstergesi
            _buildScoreAndTimePanel(),
            
            // Durum mesajı
            _buildStatusMessage(),
            
            // Oyun alanı
            _buildGameArea(),
            
            // İpucu butonu
            GetBuilder<MathRaceController>(
              builder: (ctrl) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => ElevatedButton.icon(
                      onPressed: ctrl.isPlaying.value && !ctrl.gameOver.value && !ctrl.isPaused.value
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
  
  // Skor ve zaman paneli
  Widget _buildScoreAndTimePanel() {
    return GetBuilder<MathRaceController>(
      builder: (ctrl) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skor
            Column(
              children: [
                Text(
                  'score'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${ctrl.score.value}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            // Doğruluk oranı
            Column(
              children: [
                Text(
                  'accuracy'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${ctrl.getAccuracy().toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            
            // Kalan süre
            Column(
              children: [
                Text(
                  'time'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${ctrl.timeLeft}s',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Durum mesajı
  Widget _buildStatusMessage() {
    return GetBuilder<MathRaceController>(
      builder: (ctrl) {
        if (ctrl.isGameOver) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  'game_over'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '${'final_score'.tr}: ${ctrl.score.value}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ctrl.score.value >= ctrl.highScore.value) 
                  Text(
                    'new_highscore'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          );
        } else if (!ctrl.isGameRunning) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'press_start'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          );
        } else {
          // Animasyon durumları
          if (ctrl.showCorrectAnimation) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'correct'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            );
          } else if (ctrl.showWrongAnimation) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'wrong'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            );
          } else {
            return const SizedBox(height: 40);
          }
        }
      },
    );
  }
  
  // Oyun alanı
  Widget _buildGameArea() {
    return GetBuilder<MathRaceController>(
      builder: (ctrl) {
        if (!ctrl.isGameRunning && !ctrl.isGameOver) {
          // Oyun başlamadan önce başlangıç ekranı
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calculate,
                    size: 100,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'math_race'.tr,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'math_race_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (ctrl.isGameOver) {
          // Oyun bittiğinde sonuç ekranı
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${'questions_answered'.tr}: ${ctrl.questionsAnswered}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${'correct_answers'.tr}: ${ctrl.correctAnswers}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${'accuracy'.tr}: ${ctrl.getAccuracy().toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${'highscore'.tr}: ${ctrl.highScore.value}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Aktif oyun ekranı
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Matematik problemi
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      ctrl.currentProblem?.question ?? '',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Cevap seçenekleri
                  if (ctrl.currentProblem != null)
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: List.generate(
                          ctrl.currentProblem!.options.length,
                          (index) => _buildOptionButton(index),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
  
  // Cevap seçeneği butonu
  Widget _buildOptionButton(int index) {
    return GetBuilder<MathRaceController>(
      builder: (ctrl) {
        if (ctrl.options.isEmpty || index >= ctrl.options.length) {
          return const SizedBox.shrink();
        }
        
        final option = ctrl.options[index];
        final isCorrect = option == ctrl.answer.value;
        final isHint = ctrl.showingHint.value && ctrl.correctOptionIndex.value == index;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => ctrl.selectOption(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: isHint ? Colors.green.shade200 : null,
                foregroundColor: isHint ? Colors.white : null,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                option.toString(),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Kontrol butonları
  Widget _buildControlButtons() {
    return GetBuilder<MathRaceController>(
      builder: (ctrl) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(
                ctrl.isGameRunning ? Icons.stop : Icons.play_arrow,
              ),
              label: Text(
                ctrl.isGameRunning ? 'stop'.tr : 'start'.tr,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ctrl.isGameRunning ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                if (ctrl.isGameRunning) {
                  ctrl.endGame();
                } else {
                  ctrl.startGame();
                }
              },
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
        title: Text('math_race_rules'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('math_race_desc'.tr),
              const SizedBox(height: 16),
              
              Text(
                'rules'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              _buildRuleItem(Icons.timer, 'math_race_rule_1'.tr),
              _buildRuleItem(Icons.calculate, 'math_race_rule_2'.tr),
              _buildRuleItem(Icons.check_circle, 'math_race_rule_3'.tr),
              _buildRuleItem(Icons.emoji_events, 'math_race_rule_4'.tr),
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
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
} 