import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_routes.dart';
import 'word_learning_controller.dart';

class WordLearningScreen extends StatelessWidget {
  const WordLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    final controller = Get.put(WordLearningController());
    
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.educationalGames);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('word_learning'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.toNamed(AppRoutes.educationalGames),
          ),
          actions: [
            // Zorluk seviyesi
            GetBuilder<WordLearningController>(
              builder: (ctrl) => PopupMenuButton<WordLearningDifficulty>(
                icon: const Icon(Icons.tune),
                tooltip: 'difficulty'.tr,
                onSelected: (WordLearningDifficulty value) {
                  ctrl.setDifficulty(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: WordLearningDifficulty.beginner,
                    child: Text('beginner'.tr),
                    enabled: ctrl.difficulty != WordLearningDifficulty.beginner,
                  ),
                  PopupMenuItem(
                    value: WordLearningDifficulty.intermediate,
                    child: Text('intermediate'.tr),
                    enabled: ctrl.difficulty != WordLearningDifficulty.intermediate,
                  ),
                  PopupMenuItem(
                    value: WordLearningDifficulty.advanced,
                    child: Text('advanced'.tr),
                    enabled: ctrl.difficulty != WordLearningDifficulty.advanced,
                  ),
                ],
              ),
            ),
            
            // Çalışma modu
            GetBuilder<WordLearningController>(
              builder: (ctrl) => PopupMenuButton<WordLearningMode>(
                icon: const Icon(Icons.view_module),
                tooltip: 'mode'.tr,
                onSelected: (WordLearningMode value) {
                  ctrl.setMode(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: WordLearningMode.flashcards,
                    child: Text('flashcards'.tr),
                    enabled: ctrl.mode != WordLearningMode.flashcards,
                  ),
                  PopupMenuItem(
                    value: WordLearningMode.quiz,
                    child: Text('quiz'.tr),
                    enabled: ctrl.mode != WordLearningMode.quiz,
                  ),
                  PopupMenuItem(
                    value: WordLearningMode.matching,
                    child: Text('matching'.tr),
                    enabled: ctrl.mode != WordLearningMode.matching,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Kategori seçimi
            _buildCategorySelector(),
            
            // Durum bilgisi
            _buildStatusBar(),
            
            // Mod durumuna göre ana içerik
            _buildMainContent(context),
            
            // Kontrol butonları
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }
  
  // Kategori seçimi
  Widget _buildCategorySelector() {
    return GetBuilder<WordLearningController>(
      builder: (ctrl) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'category'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 40,
                child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ctrl.categories.length,
                  itemBuilder: (context, index) {
                    final category = ctrl.categories[index];
                    final isSelected = category == ctrl.selectedCategory.value;
                    
                    return GestureDetector(
                      onTap: () => ctrl.setCategory(category),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Durum çubuğu
  Widget _buildStatusBar() {
    return GetBuilder<WordLearningController>(
      builder: (ctrl) {
        return Container(
          padding: const EdgeInsets.all(16),
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
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              
              // Öğrenilen kelime sayısı
              Column(
                children: [
                  Text(
                    'learned_words'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${ctrl.learnedWords}/${ctrl.totalWords}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              // İlerleme
              Column(
                children: [
                  Text(
                    'progress'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${ctrl.getProgressPercentage().toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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
  
  // Mod durumuna göre ana içerik
  Widget _buildMainContent(BuildContext context) {
    return GetBuilder<WordLearningController>(
      builder: (ctrl) {
        if (!ctrl.isStudyActive) {
          // Oyun başlamadan önce başlangıç ekranı
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.translate,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'word_learning'.tr,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'word_learning_desc'.tr,
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
        }
        
        // Moda göre içerik
        switch (ctrl.mode) {
          case WordLearningMode.flashcards:
            return _buildFlashcardsMode(context);
          case WordLearningMode.quiz:
            return _buildQuizMode(context);
          case WordLearningMode.matching:
            return _buildMatchingMode(context);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
  
  // Flashcards modu
  Widget _buildFlashcardsMode(BuildContext context) {
    return GetBuilder<WordLearningController>(
      builder: (ctrl) {
        if (ctrl.currentWord == null) {
          return const Expanded(
            child: Center(
              child: Text('No words available in this category'),
            ),
          );
        }
        
        return Expanded(
          child: Center(
            child: GestureDetector(
              onTap: ctrl.flipCard,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: ctrl.showingTranslation ? Colors.blue.shade100 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gösterilen kelime veya çeviri
                    Text(
                      ctrl.showingTranslation 
                          ? ctrl.currentWord!.turkish 
                          : ctrl.currentWord!.english,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Kelime kategorisi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ctrl.currentWord!.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Örnek cümle (varsa ve çeviri gösteriliyorsa)
                    if (ctrl.showingTranslation && ctrl.currentWord!.exampleSentence != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ctrl.currentWord!.exampleSentence!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Çevirme ipucu
                    Text(
                      'tap_to_flip'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Quiz modu
  Widget _buildQuizMode(BuildContext context) {
    return GetBuilder<WordLearningController>(
      builder: (ctrl) {
        if (ctrl.currentWord == null) {
          return const Expanded(
            child: Center(
              child: Text('No words available in this category'),
            ),
          );
        }
        
        return Expanded(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Animasyonlar
              if (ctrl.showCorrectAnimation)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'correct'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                )
              else if (ctrl.showWrongAnimation)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'wrong'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Sorulacak kelime
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'translate_word'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ctrl.currentWord!.english,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ctrl.currentWord!.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Seçenekler
              ...ctrl.currentOptions.map((option) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onPressed: () => ctrl.checkAnswer(option),
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
  
  // Eşleştirme modu (basit versiyon)
  Widget _buildMatchingMode(BuildContext context) {
    return GetBuilder<WordLearningController>(
      builder: (ctrl) {
        return Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.extension,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  'matching_mode_coming_soon'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'matching_mode_desc'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Kontrol butonları
  Widget _buildControlButtons() {
    return GetBuilder<WordLearningController>(
      builder: (ctrl) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Önceki kelime
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: ctrl.isStudyActive ? ctrl.previousWord : null,
                iconSize: 32,
                color: Colors.blue,
              ),
              
              // Başlat/Durdur
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: ctrl.isStudyActive ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (ctrl.isStudyActive) {
                    ctrl.stopStudy();
                  } else {
                    ctrl.startStudy();
                  }
                },
                child: Text(
                  ctrl.isStudyActive ? 'stop'.tr : 'start'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Rastgele kelime
              IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: ctrl.isStudyActive ? ctrl.getRandomWord : null,
                iconSize: 32,
                color: Colors.purple,
              ),
              
              // Sonraki kelime
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: ctrl.isStudyActive ? ctrl.nextWord : null,
                iconSize: 32,
                color: Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }
} 