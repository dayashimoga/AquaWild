import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/hydration_entry.dart';
import 'hydration_repository.dart';

/// Production-ready local offline-first repository backed by SharedPreferences
class LocalHydrationRepository implements HydrationRepository {
  final SharedPreferences? _prefs;

  // In-memory fallback/cache for synchronous fast access and tests
  final List<HydrationEntry> _memoryEntries = [];
  int _cachedGoal = AppConstants.defaultDailyGoalMl;
  String _cachedAnimalId = 'red_panda';
  String _cachedBiomeId = 'bamboo_misty_springs';
  int _cachedXp = 0;

  static const String _entriesKeyPrefix = 'aquawild_entries_';
  static const String _goalKey = 'aquawild_daily_goal';
  static const String _animalKey = 'aquawild_active_animal';
  static const String _biomeKey = 'aquawild_active_biome';
  static const String _xpKey = 'aquawild_user_xp';

  LocalHydrationRepository([this._prefs]);

  String _getTodayKey() {
    final now = DateTime.now();
    return '$_entriesKeyPrefix${now.year}_${now.month}_${now.day}';
  }

  @override
  Future<List<HydrationEntry>> getTodayEntries() async {
    if (_prefs == null) {
      return List.unmodifiable(_memoryEntries);
    }
    final key = _getTodayKey();
    final jsonString = _prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return List.unmodifiable(_memoryEntries);
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final list = decoded
          .map((item) => HydrationEntry.fromMap(item as Map<String, dynamic>))
          .toList();
      _memoryEntries
        ..clear()
        ..addAll(list);
      return List.unmodifiable(list);
    } catch (_) {
      return List.unmodifiable(_memoryEntries);
    }
  }

  @override
  Future<void> saveEntry(HydrationEntry entry) async {
    _memoryEntries.removeWhere((e) => e.id == entry.id);
    _memoryEntries.add(entry);

    if (_prefs != null) {
      final key = _getTodayKey();
      final serialized = jsonEncode(
        _memoryEntries.map((e) => e.toMap()).toList(),
      );
      await _prefs.setString(key, serialized);
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    _memoryEntries.removeWhere((e) => e.id == entryId);

    if (_prefs != null) {
      final key = _getTodayKey();
      final serialized = jsonEncode(
        _memoryEntries.map((e) => e.toMap()).toList(),
      );
      await _prefs.setString(key, serialized);
    }
  }

  @override
  Future<void> clearTodayEntries() async {
    _memoryEntries.clear();
    if (_prefs != null) {
      final key = _getTodayKey();
      await _prefs.remove(key);
    }
  }

  @override
  Future<int> getDailyBaseGoal() async {
    if (_prefs != null) {
      _cachedGoal =
          _prefs.getInt(_goalKey) ?? AppConstants.defaultDailyGoalMl;
    }
    return _cachedGoal;
  }

  @override
  Future<void> setDailyBaseGoal(int goalMl) async {
    _cachedGoal = goalMl;
    if (_prefs != null) {
      await _prefs.setInt(_goalKey, goalMl);
    }
  }

  @override
  Future<String> getSelectedAnimalId() async {
    if (_prefs != null) {
      _cachedAnimalId = _prefs.getString(_animalKey) ?? 'red_panda';
    }
    return _cachedAnimalId;
  }

  @override
  Future<void> setSelectedAnimalId(String animalId) async {
    _cachedAnimalId = animalId;
    if (_prefs != null) {
      await _prefs.setString(_animalKey, animalId);
    }
  }

  @override
  Future<String> getSelectedBiomeId() async {
    if (_prefs != null) {
      _cachedBiomeId =
          _prefs.getString(_biomeKey) ?? 'bamboo_misty_springs';
    }
    return _cachedBiomeId;
  }

  @override
  Future<void> setSelectedBiomeId(String biomeId) async {
    _cachedBiomeId = biomeId;
    if (_prefs != null) {
      await _prefs.setString(_biomeKey, biomeId);
    }
  }

  @override
  Future<int> getUserXp() async {
    if (_prefs != null) {
      _cachedXp = _prefs.getInt(_xpKey) ?? 0;
    }
    return _cachedXp;
  }

  @override
  Future<void> addXp(int xp) async {
    _cachedXp += xp;
    if (_prefs != null) {
      await _prefs.setInt(_xpKey, _cachedXp);
    }
  }
}
