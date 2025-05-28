import 'package:get/get.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/games/reflex/reflex_games_screen.dart';
import '../../presentation/screens/games/reflex/reaction_test/reaction_test_game.dart';
import '../../presentation/screens/games/reflex/color_match/color_match_game.dart';
import '../../presentation/screens/games/reflex/rapid_tap/rapid_tap_game.dart';
import '../../presentation/screens/games/puzzle/puzzle_games_screen.dart';
import '../../presentation/screens/games/puzzle/number_puzzle/number_puzzle_screen.dart';
import '../../presentation/screens/games/puzzle/word_hunt/word_hunt_screen.dart';
import '../../presentation/screens/games/puzzle/memory_cards/memory_cards_screen.dart';
import '../../presentation/screens/games/arcade/arcade_games_screen.dart';
import '../../presentation/screens/games/arcade/snake/snake_screen.dart';
import '../../presentation/screens/games/arcade/space_shooter/space_shooter_screen.dart';
import '../../presentation/screens/games/arcade/bounce_ball/bounce_ball_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/leaderboard/leaderboard_screen.dart';
import '../../presentation/screens/games/strategy/strategy_games_screen.dart';
import '../../presentation/screens/games/strategy/mini_chess/mini_chess_screen.dart';
import '../../presentation/screens/games/strategy/tic_tac_toe/tic_tac_toe_screen.dart';
import '../../presentation/screens/games/strategy/connect_four/connect_four_screen.dart';
import '../../presentation/screens/games/educational/educational_games_screen.dart';
import '../../presentation/screens/games/educational/math_race/math_race_screen.dart';
import '../../presentation/screens/games/educational/flag_quiz/flag_quiz_screen.dart';
import '../../presentation/screens/games/educational/word_learning/word_learning_screen.dart';
import '../../presentation/screens/games/physics/physics_games_screen.dart';
import '../../presentation/screens/games/physics/angry_birds_clone/angry_birds_screen.dart';
import '../../presentation/screens/games/physics/cut_rope_clone/cut_rope_screen.dart';
import '../../presentation/screens/games/physics/doodle_jump_clone/doodle_jump_screen.dart';
import '../../presentation/screens/games/rhythm/rhythm_games_screen.dart';
import '../../presentation/screens/games/rhythm/music_notes/music_notes_screen.dart';
import '../../presentation/screens/games/rhythm/piano_tiles/piano_tiles_screen.dart';

class AppRoutes {
  // Ana rotalar
  static const String splash = '/splash';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';
  static const String gameCategories = '/game-categories';

  // Oyun kategorileri rotaları
  static const String reflexGames = '/reflex-games';
  static const String puzzleGames = '/puzzle-games';
  static const String arcadeGames = '/arcade-games';
  static const String strategyGames = '/strategy-games';
  static const String educationalGames = '/educational-games';
  static const String physicsGames = '/physics-games';
  static const String rhythmGames = '/rhythm-games';

  // Reflex oyunları
  static const String reactionTest = '/reaction-test';
  static const String colorMatch = '/color-match';
  static const String rapidTap = '/rapid-tap';
  
  // Bulmaca oyunları
  static const String numberPuzzle = '/number-puzzle';
  static const String wordHunt = '/word-hunt';
  static const String memoryCards = '/memory-cards';
  
  // Arcade oyunları
  static const String snake = '/snake';
  static const String spaceShooter = '/space-shooter';
  static const String bounceBall = '/bounce-ball';
  
  // Strateji oyunları
  static const String miniChess = '/mini-chess';
  static const String ticTacToe = '/tic-tac-toe';
  static const String connectFour = '/connect-four';
  
  // Eğitici oyunlar
  static const String mathRace = '/math-race';
  static const String flagQuiz = '/flag-quiz';
  static const String wordLearning = '/word-learning';
  
  // Fizik tabanlı oyunlar
  static const String angryBirdsClone = '/angry-birds-clone';
  static const String cutRopeClone = '/cut-rope-clone';
  static const String doodleJumpClone = '/doodle-jump-clone';
  
  // Ritim oyunları
  static const String musicNotes = '/music-notes';
  static const String pianoTiles = '/piano-tiles';
  
  // Uygulama başlangıç rotası
  static const String initial = splash;

  // Sayfa geçişleri için varsayılan animasyonlar
  static Transition defaultTransition = Transition.fade;
  static Duration defaultDuration = const Duration(milliseconds: 300);

  // GetX için rota listesi
  static final List<GetPage> routes = [
    // Splash Screen
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    
    // Ana rotalar
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: leaderboard,
      page: () => const LeaderboardScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    
    // Oyun kategorileri
    GetPage(
      name: reflexGames,
      page: () => const ReflexGamesScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: puzzleGames,
      page: () => const PuzzleGamesScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: arcadeGames,
      page: () => const ArcadeGamesScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: strategyGames,
      page: () => const StrategyGamesScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: educationalGames,
      page: () => const EducationalGamesScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: physicsGames,
      page: () => const PhysicsGamesScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    GetPage(
      name: rhythmGames,
      page: () => const RhythmGamesScreen(),
      transition: defaultTransition,
      transitionDuration: defaultDuration,
    ),
    
    // Bulmaca oyunları
    GetPage(
      name: numberPuzzle,
      page: () => const NumberPuzzleScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: wordHunt,
      page: () => const WordHuntScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: memoryCards,
      page: () => const MemoryCardsScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    // Arcade oyunları
    GetPage(
      name: snake,
      page: () => const SnakeScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: spaceShooter,
      page: () => const SpaceShooterScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: bounceBall,
      page: () => const BounceBallScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    // Strateji oyunları
    GetPage(
      name: miniChess,
      page: () => const MiniChessScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: ticTacToe,
      page: () => const TicTacToeScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: connectFour,
      page: () => const ConnectFourScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    // Eğitici oyunlar
    GetPage(
      name: mathRace,
      page: () => const MathRaceScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: flagQuiz,
      page: () => const FlagQuizScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: wordLearning,
      page: () => const WordLearningScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    // Fizik tabanlı oyunlar
    GetPage(
      name: angryBirdsClone,
      page: () => const AngryBirdsScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: cutRopeClone,
      page: () => const CutRopeScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: doodleJumpClone,
      page: () => const DoodleJumpScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    // Ritim oyunları
    GetPage(
      name: musicNotes,
      page: () => const MusicNotesScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: pianoTiles,
      page: () => const PianoTilesScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    // Reflex oyunları
    GetPage(
      name: reactionTest,
      page: () => const ReactionTestGame(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: colorMatch,
      page: () => const ColorMatchGame(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: rapidTap,
      page: () => const RapidTapGame(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    // Diğer ekranlar oluşturulduğunda eklenecek
  ];
} 