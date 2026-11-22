import '../../domain/models/hydration_entry.dart';

/// Contract for persistent hydration storage and user progression
abstract class HydrationRepository {
  Future<List<HydrationEntry>> getTodayEntries();
  Future<void> saveEntry(HydrationEntry entry);
  Future<void> deleteEntry(String entryId);
  Future<void> clearTodayEntries();

  Future<int> getDailyBaseGoal();
  Future<void> setDailyBaseGoal(int goalMl);

  Future<String> getSelectedAnimalId();
  Future<void> setSelectedAnimalId(String animalId);

  Future<String> getSelectedBiomeId();
  Future<void> setSelectedBiomeId(String biomeId);

  Future<int> getUserXp();
  Future<void> addXp(int xp);
}
