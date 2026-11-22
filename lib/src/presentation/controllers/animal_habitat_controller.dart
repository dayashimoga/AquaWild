import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hydration_repository.dart';
import '../../domain/models/animal_evolution_stage.dart';
import '../../domain/models/exotic_animal.dart';
import 'hydration_controller.dart';
import 'monetization_controller.dart';

class AnimalHabitatState {
  final ExoticAnimal activeAnimal;
  final int userXp;
  final AnimalEvolutionStage currentStage;
  final List<ExoticAnimal> unlockedAnimals;
  final double stageProgressFraction;
  final int xpUntilNextStage;

  const AnimalHabitatState({
    required this.activeAnimal,
    required this.userXp,
    required this.currentStage,
    required this.unlockedAnimals,
    required this.stageProgressFraction,
    required this.xpUntilNextStage,
  });

  AnimalHabitatState copyWith({
    ExoticAnimal? activeAnimal,
    int? userXp,
    AnimalEvolutionStage? currentStage,
    List<ExoticAnimal>? unlockedAnimals,
    double? stageProgressFraction,
    int? xpUntilNextStage,
  }) {
    return AnimalHabitatState(
      activeAnimal: activeAnimal ?? this.activeAnimal,
      userXp: userXp ?? this.userXp,
      currentStage: currentStage ?? this.currentStage,
      unlockedAnimals: unlockedAnimals ?? this.unlockedAnimals,
      stageProgressFraction:
          stageProgressFraction ?? this.stageProgressFraction,
      xpUntilNextStage: xpUntilNextStage ?? this.xpUntilNextStage,
    );
  }
}

class AnimalHabitatNotifier extends Notifier<AnimalHabitatState> {
  HydrationRepository get _repository => ref.read(hydrationRepositoryProvider);

  @override
  AnimalHabitatState build() {
    ref.listen(monetizationProvider, (previous, next) {
      if (previous?.isPro != next.isPro ||
          previous?.unlockedAnimalIds != next.unlockedAnimalIds) {
        _updateState(state.activeAnimal, state.userXp);
      }
    });

    final initialState = AnimalHabitatState(
      activeAnimal: ExoticAnimal.allAnimals.first,
      userXp: 0,
      currentStage: AnimalEvolutionStage.defaultStages.first,
      unlockedAnimals: [ExoticAnimal.allAnimals.first],
      stageProgressFraction: 0.0,
      xpUntilNextStage: AnimalEvolutionStage.defaultStages[1].requiredXp,
    );

    Future.microtask(() => loadState());
    return initialState;
  }

  Future<void> loadState() async {
    final animalId = await _repository.getSelectedAnimalId();
    if (!ref.mounted) return;
    final xp = await _repository.getUserXp();
    if (!ref.mounted) return;
    final animal = ExoticAnimal.findById(animalId);

    _updateState(animal, xp);
  }

  Future<void> selectAnimal(String animalId) async {
    final animal = ExoticAnimal.findById(animalId);
    await _repository.setSelectedAnimalId(animalId);
    if (!ref.mounted) return;
    _updateState(animal, state.userXp);
  }

  Future<void> addXp(int xp) async {
    await _repository.addXp(xp);
    if (!ref.mounted) return;
    final total = state.userXp + xp;
    _updateState(state.activeAnimal, total);
  }

  void _updateState(ExoticAnimal animal, int xp) {
    if (!ref.mounted) return;
    final monetization = ref.read(monetizationProvider);
    final unlocked = ExoticAnimal.allAnimals
        .where((a) => monetization.isAnimalUnlocked(a.id, xp))
        .toList();

    final stages = animal.evolutionStages;
    AnimalEvolutionStage current = stages.first;
    int nextReqXp = stages.length > 1 ? stages[1].requiredXp : 0;
    int prevReqXp = 0;

    for (int i = 0; i < stages.length; i++) {
      if (xp >= stages[i].requiredXp) {
        current = stages[i];
        prevReqXp = stages[i].requiredXp;
        nextReqXp = (i + 1 < stages.length) ? stages[i + 1].requiredXp : prevReqXp;
      }
    }

    final span = nextReqXp - prevReqXp;
    final double fraction;
    if (span <= 0) {
      fraction = 1.0;
    } else {
      fraction = ((xp - prevReqXp) / span).clamp(0.0, 1.0);
    }

    final diff = nextReqXp - xp;
    final int untilNext = diff > 0 ? diff : 0;

    state = AnimalHabitatState(
      activeAnimal: animal,
      userXp: xp,
      currentStage: current,
      unlockedAnimals: unlocked,
      stageProgressFraction: fraction,
      xpUntilNextStage: untilNext,
    );
  }
}

final animalHabitatProvider =
    NotifierProvider<AnimalHabitatNotifier, AnimalHabitatState>(
  AnimalHabitatNotifier.new,
);
