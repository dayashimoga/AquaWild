import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hydration_repository.dart';
import '../../domain/models/hydration_biome.dart';
import 'hydration_controller.dart';

class BiomeState {
  final HydrationBiome activeBiome;
  final List<HydrationBiome> unlockedBiomes;

  const BiomeState({
    required this.activeBiome,
    required this.unlockedBiomes,
  });

  BiomeState copyWith({
    HydrationBiome? activeBiome,
    List<HydrationBiome>? unlockedBiomes,
  }) {
    return BiomeState(
      activeBiome: activeBiome ?? this.activeBiome,
      unlockedBiomes: unlockedBiomes ?? this.unlockedBiomes,
    );
  }
}

class BiomeNotifier extends Notifier<BiomeState> {
  HydrationRepository get _repository => ref.read(hydrationRepositoryProvider);

  @override
  BiomeState build() {
    final initialState = BiomeState(
      activeBiome: HydrationBiome.allBiomes.first,
      unlockedBiomes: [HydrationBiome.allBiomes.first],
    );

    Future.microtask(() => loadState());
    return initialState;
  }

  Future<void> loadState() async {
    final biomeId = await _repository.getSelectedBiomeId();
    if (!ref.mounted) return;
    final xp = await _repository.getUserXp();
    if (!ref.mounted) return;
    final biome = HydrationBiome.findById(biomeId);
    final unlocked =
        HydrationBiome.allBiomes.where((b) => b.unlockXp <= xp).toList();

    if (!ref.mounted) return;
    state = BiomeState(
      activeBiome: biome,
      unlockedBiomes: unlocked,
    );
  }

  Future<void> selectBiome(String biomeId) async {
    final biome = HydrationBiome.findById(biomeId);
    await _repository.setSelectedBiomeId(biomeId);
    if (!ref.mounted) return;
    state = state.copyWith(activeBiome: biome);
  }
}

final biomeProvider = NotifierProvider<BiomeNotifier, BiomeState>(
  BiomeNotifier.new,
);
