import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/accessibility_announcement_service.dart';
import '../../data/repositories/hydration_repository.dart';
import '../../data/repositories/local_hydration_repository.dart';
import '../../domain/models/beverage_type.dart';
import '../../domain/models/daily_hydration_goal.dart';
import '../../domain/models/fluid_layer.dart';
import '../../domain/models/hydration_entry.dart';

final hydrationRepositoryProvider = Provider<HydrationRepository>((ref) {
  return LocalHydrationRepository();
});

class HydrationState {
  final List<HydrationEntry> entries;
  final List<FluidLayer> stratifiedLayers;
  final DailyHydrationGoal goal;
  final bool isLoading;
  final HydrationEntry? lastLoggedEntry;

  const HydrationState({
    required this.entries,
    required this.stratifiedLayers,
    required this.goal,
    this.isLoading = false,
    this.lastLoggedEntry,
  });

  HydrationState copyWith({
    List<HydrationEntry>? entries,
    List<FluidLayer>? stratifiedLayers,
    DailyHydrationGoal? goal,
    bool? isLoading,
    HydrationEntry? lastLoggedEntry,
  }) {
    return HydrationState(
      entries: entries ?? this.entries,
      stratifiedLayers: stratifiedLayers ?? this.stratifiedLayers,
      goal: goal ?? this.goal,
      isLoading: isLoading ?? this.isLoading,
      lastLoggedEntry: lastLoggedEntry ?? this.lastLoggedEntry,
    );
  }
}

class HydrationNotifier extends Notifier<HydrationState> {
  HydrationRepository get _repository => ref.read(hydrationRepositoryProvider);

  @override
  HydrationState build() {
    const initialState = HydrationState(
      entries: [],
      stratifiedLayers: [],
      goal: DailyHydrationGoal(
        baseGoalMl: 2500,
        totalConsumedMl: 0.0,
        netHydrationMl: 0.0,
        caffeineTotalMg: 0.0,
        electrolytesTotalMg: 0.0,
      ),
    );

    Future.microtask(() => loadToday());
    return initialState;
  }

  Future<void> loadToday() async {
    state = state.copyWith(isLoading: true);
    final entries = await _repository.getTodayEntries();
    if (!ref.mounted) return;
    final baseGoal = await _repository.getDailyBaseGoal();
    if (!ref.mounted) return;

    _recalculate(entries, baseGoal);
  }

  Future<void> logDrink({
    required BeverageType beverage,
    required double volumeMl,
    String? notes,
  }) async {
    if (volumeMl <= 0) return;
    final sanitizedVolume = volumeMl.clamp(1.0, 5000.0);

    final entry = HydrationEntry.create(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      beverage: beverage,
      volumeMl: sanitizedVolume,
      notes: notes,
    );

    await _repository.saveEntry(entry);
    if (!ref.mounted) return;
    final xpGained = (sanitizedVolume / 10).round();
    await _repository.addXp(xpGained);
    if (!ref.mounted) return;

    final updated = List<HydrationEntry>.from(state.entries)..add(entry);
    _recalculate(updated, state.goal.baseGoalMl, lastLogged: entry);
    AccessibilityAnnouncementService.announce(
      'Logged ${sanitizedVolume.toStringAsFixed(0)} ml of ${beverage.name}. Net hydration is now ${state.goal.netHydrationMl.toStringAsFixed(0)} of ${state.goal.effectiveGoalMl} ml (${state.goal.progressPercent}%).',
    );
  }

  Future<void> removeEntry(String id) async {
    await _repository.deleteEntry(id);
    if (!ref.mounted) return;
    final updated = state.entries.where((e) => e.id != id).toList();
    _recalculate(updated, state.goal.baseGoalMl);
    AccessibilityAnnouncementService.announce(
      'Removed hydration entry. Net hydration is now ${state.goal.netHydrationMl.toStringAsFixed(0)} of ${state.goal.effectiveGoalMl} ml (${state.goal.progressPercent}%).',
    );
  }

  Future<void> setBaseGoal(int goalMl) async {
    final clamped = goalMl.clamp(1000, 8000);
    await _repository.setDailyBaseGoal(clamped);
    if (!ref.mounted) return;
    _recalculate(state.entries, clamped);
    AccessibilityAnnouncementService.announce(
      'Daily hydration goal updated to $clamped ml.',
    );
  }

  Future<void> setWeatherBonus(int bonusMl) async {
    state = state.copyWith(
      goal: state.goal.copyWith(weatherBonusMl: bonusMl),
    );
  }

  Future<void> setWorkoutBonus(int bonusMl) async {
    state = state.copyWith(
      goal: state.goal.copyWith(workoutBonusMl: bonusMl),
    );
  }

  void _recalculate(
    List<HydrationEntry> entries,
    int baseGoal, {
    HydrationEntry? lastLogged,
  }) {
    if (!ref.mounted) return;

    double totalConsumed = 0.0;
    double netHydration = 0.0;
    double totalCaffeine = 0.0;
    double totalElectrolytes = 0.0;

    final Map<String, double> beverageVolumeMap = {};

    for (final e in entries) {
      totalConsumed += e.volumeMl;
      netHydration += e.netHydrationMl;
      totalCaffeine += e.caffeineMg;
      totalElectrolytes += e.electrolytesMg;
      beverageVolumeMap[e.beverageId] =
          (beverageVolumeMap[e.beverageId] ?? 0.0) + e.volumeMl;
    }

    final List<FluidLayer> layers = [];
    if (totalConsumed > 0) {
      final sortedBeverageEntries = beverageVolumeMap.entries.toList()
        ..sort((a, b) {
          final bevA = BeverageType.findById(a.key);
          final bevB = BeverageType.findById(b.key);
          return bevB.density.compareTo(bevA.density);
        });

      for (final item in sortedBeverageEntries) {
        final bev = BeverageType.findById(item.key);
        final vol = item.value;
        layers.add(
          FluidLayer(
            beverage: bev,
            volumeMl: vol,
            fractionOfTotal: vol / totalConsumed,
            relativeDensity: bev.density,
          ),
        );
      }
    }

    final updatedGoal = state.goal.copyWith(
      baseGoalMl: baseGoal,
      totalConsumedMl: totalConsumed,
      netHydrationMl: netHydration,
      caffeineTotalMg: totalCaffeine,
      electrolytesTotalMg: totalElectrolytes,
    );

    state = HydrationState(
      entries: entries,
      stratifiedLayers: layers,
      goal: updatedGoal,
      isLoading: false,
      lastLoggedEntry: lastLogged,
    );
  }
}

final hydrationProvider =
    NotifierProvider<HydrationNotifier, HydrationState>(
  HydrationNotifier.new,
);
