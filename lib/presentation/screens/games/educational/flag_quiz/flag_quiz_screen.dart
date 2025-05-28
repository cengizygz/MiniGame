import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'flag_quiz_controller.dart';

class FlagQuizScreen extends StatelessWidget {
  const FlagQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    final controller = Get.put(FlagQuizController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.educationalGames);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('flag_quiz'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.educationalGames),
          ),
          actions: [
            // Zorluk seviyesi
            GetBuilder<FlagQuizController>(
              builder: (ctrl) => PopupMenuButton<FlagQuizDifficulty>(
                icon: const Icon(Icons.tune),
                tooltip: 'difficulty'.tr,
                onSelected: (FlagQuizDifficulty value) {
                  ctrl.setDifficulty(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: FlagQuizDifficulty.easy,
                    child: Text('easy'.tr),
                    enabled: ctrl.difficulty != FlagQuizDifficulty.easy,
                  ),
                  PopupMenuItem(
                    value: FlagQuizDifficulty.medium,
                    child: Text('medium'.tr),
                    enabled: ctrl.difficulty != FlagQuizDifficulty.medium,
                  ),
                  PopupMenuItem(
                    value: FlagQuizDifficulty.hard,
                    child: Text('hard'.tr),
                    enabled: ctrl.difficulty != FlagQuizDifficulty.hard,
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
            
            // Kontrol butonları
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }
  
  // Skor ve zaman paneli
  Widget _buildScoreAndTimePanel() {
    return GetBuilder<FlagQuizController>(
      builder: (ctrl) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
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
                  '${ctrl.score}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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
    return GetBuilder<FlagQuizController>(
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
                  '${'final_score'.tr}: ${ctrl.score}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ctrl.score >= ctrl.highScore) 
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
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'which_country'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            );
          }
        }
      },
    );
  }
  
  // Oyun alanı
  Widget _buildGameArea() {
    return GetBuilder<FlagQuizController>(
      builder: (ctrl) {
        if (!ctrl.isGameRunning && !ctrl.isGameOver) {
          // Oyun başlamadan önce başlangıç ekranı
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.flag,
                    size: 100,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'flag_quiz'.tr,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'flag_quiz_desc'.tr,
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
                    '${'highscore'.tr}: ${ctrl.highScore}',
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
                  // Bayrak görüntüsü
                  if (ctrl.currentQuestion != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          ctrl.getFlagAssetPath(ctrl.currentQuestion!.countryCode),
                          width: 200,
                          height: 120,
                          fit: BoxFit.cover,
                          // Bayrak resmi yüklenmezse yedek görüntü göster
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 200,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.flag,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Ülke seçenekleri
                  if (ctrl.currentQuestion != null)
                    Expanded(
                      child: ListView.builder(
                        itemCount: ctrl.currentQuestion!.options.length,
                        itemBuilder: (context, index) => _buildOptionButton(
                          ctrl,
                          ctrl.currentQuestion!.options[index],
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
  
  // Ülke seçeneği butonu
  Widget _buildOptionButton(FlagQuizController ctrl, String countryName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.red.withOpacity(0.3),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        onPressed: () => ctrl.checkAnswer(countryName),
        child: Text(
          countryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  // Kontrol butonları
  Widget _buildControlButtons() {
    return GetBuilder<FlagQuizController>(
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
        title: Text('flag_quiz_rules'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('flag_quiz_desc'.tr),
              const SizedBox(height: 16),
              
              Text(
                'rules'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              _buildRuleItem(Icons.timer, 'flag_quiz_rule_1'.tr),
              _buildRuleItem(Icons.flag, 'flag_quiz_rule_2'.tr),
              _buildRuleItem(Icons.check_circle, 'flag_quiz_rule_3'.tr),
              _buildRuleItem(Icons.emoji_events, 'flag_quiz_rule_4'.tr),
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
          Icon(icon, size: 20, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
} 