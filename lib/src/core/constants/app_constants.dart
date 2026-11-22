// AquaWild Application Constants
class AppConstants {
  AppConstants._();

  static const String appName = 'AquaWild';
  static const String appTagline = 'AI-Powered Hydration & Animal Habitat Ecosystem';
  static const String appVersion = '1.0.0';

  // Hydration Defaults
  static const int defaultDailyGoalMl = 2500;
  static const int minDailyGoalMl = 1000;
  static const int maxDailyGoalMl = 6000;

  // Frame targets
  static const double targetFps = 120.0;
  static const double maxFrameBudgetMs = 8.33; // 120Hz frame budget
}
