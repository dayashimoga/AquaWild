import 'package:aquawild/src/domain/models/activity_session.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';

/// Abstract bridge for bi-directional health platform synchronization
/// (Apple HealthKit on iOS/macOS, Google Health Connect on Android, and Local Mock on Web/Windows/Linux).
abstract class HealthPlatformService {
  /// Check and request user permissions for health telemetry.
  Future<bool> requestPermissions();

  /// Retrieve active calories burned today from connected health sensors.
  Future<int> fetchActiveEnergyBurnedKcal(DateTime date);

  /// Retrieve workout sessions recorded today by wearable fitness trackers.
  Future<List<ActivitySession>> fetchWorkouts(DateTime date);

  /// Export a logged hydration entry into the system health database.
  Future<bool> exportHydrationEntry(HydrationEntry entry);
}

/// Robust cross-platform implementation providing offline-first health sync
/// and deterministic testing across Web, Windows, macOS, Linux, and mobile simulators.
class LocalMockHealthPlatformService implements HealthPlatformService {
  bool _hasPermissions = false;
  final List<HydrationEntry> _exportedEntries = [];
  final List<ActivitySession> _mockWorkouts = [
    ActivitySession(
      activityType: ActivityType.running,
      durationMinutes: 30,
      intensity: ActivityIntensity.high,
      caloriesBurned: 280,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Future<bool> requestPermissions() async {
    _hasPermissions = true;
    return true;
  }

  bool get isAuthorized => _hasPermissions;

  @override
  Future<int> fetchActiveEnergyBurnedKcal(DateTime date) async {
    return _mockWorkouts.fold<int>(0, (sum, w) => sum + w.caloriesBurned);
  }

  @override
  Future<List<ActivitySession>> fetchWorkouts(DateTime date) async {
    return List.unmodifiable(_mockWorkouts);
  }

  void addSimulatedWorkout(ActivitySession session) {
    _mockWorkouts.add(session);
  }

  @override
  Future<bool> exportHydrationEntry(HydrationEntry entry) async {
    _exportedEntries.add(entry);
    return true;
  }

  List<HydrationEntry> get exportedEntries => List.unmodifiable(_exportedEntries);
}
