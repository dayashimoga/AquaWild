import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/beverage_type.dart';
import '../../domain/models/exotic_animal.dart';
import '../../domain/models/hydration_biome.dart';
import '../../domain/models/monetization_models.dart';

/// Specification contract for AquaWild dynamic content expansion plugins.
/// Allows modular addition of companions, biomes, beverages, themes, and commercial SKUs
/// without modifying core sanctuary engines.
class ContentPlugin {
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final List<ExoticAnimal> companions;
  final List<HydrationBiome> biomes;
  final List<BeverageType> beverages;
  final List<ProductSKU> products;
  final Map<String, ThemeData> customThemes;
  final Map<String, dynamic> metadata;
  final void Function(ContentPluginRegistry registry)? onInstall;
  final void Function(ContentPluginRegistry registry)? onUninstall;

  const ContentPlugin({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    this.companions = const [],
    this.biomes = const [],
    this.beverages = const [],
    this.products = const [],
    this.customThemes = const {},
    this.metadata = const {},
    this.onInstall,
    this.onUninstall,
  });

  @override
  String toString() => 'ContentPlugin(id: $id, name: $name, v: $version)';
}

/// Central registry managing dynamic content plugins, catalog aggregation,
/// and runtime lifecycle hooks.
class ContentPluginRegistry {
  final Map<String, ContentPlugin> _plugins = {};

  ContentPluginRegistry();

  /// Standard factory initialized with AquaWild Core content
  factory ContentPluginRegistry.standard() {
    final registry = ContentPluginRegistry();
    registry.registerPlugin(
      ContentPlugin(
        id: 'aquawild.core',
        name: 'AquaWild Core Sanctuary',
        version: '2.0.0',
        author: 'AquaWild Engineering Team',
        description:
            'Flagship content pack providing 10 living companions, 4 hydration biomes, and standard science beverages.',
        companions: ExoticAnimal.allAnimals,
        biomes: HydrationBiome.allBiomes,
        beverages: BeverageType.allBeverages,
        products: ProductSKU.catalog,
      ),
    );
    return registry;
  }

  /// Registers a content expansion plugin.
  /// Throws ArgumentError if a plugin with the same ID is already registered.
  bool registerPlugin(ContentPlugin plugin) {
    if (_plugins.containsKey(plugin.id)) {
      throw ArgumentError(
        'ContentPlugin with id "${plugin.id}" is already registered.',
      );
    }
    _plugins[plugin.id] = plugin;
    plugin.onInstall?.call(this);
    return true;
  }

  /// Unregisters an active plugin and executes its teardown hook.
  bool unregisterPlugin(String pluginId) {
    final plugin = _plugins.remove(pluginId);
    if (plugin != null) {
      plugin.onUninstall?.call(this);
      return true;
    }
    return false;
  }

  /// Checks if a plugin ID is currently registered
  bool hasPlugin(String pluginId) => _plugins.containsKey(pluginId);

  /// Retrieves a registered plugin by ID
  ContentPlugin? getPlugin(String pluginId) => _plugins[pluginId];

  /// All currently registered plugins
  List<ContentPlugin> get plugins => List.unmodifiable(_plugins.values);

  /// Aggregated list of all companions across all active content plugins
  List<ExoticAnimal> get allCompanions {
    final List<ExoticAnimal> result = [];
    final Set<String> seenIds = {};
    for (final plugin in _plugins.values) {
      for (final companion in plugin.companions) {
        if (!seenIds.contains(companion.id)) {
          seenIds.add(companion.id);
          result.add(companion);
        }
      }
    }
    return List.unmodifiable(result);
  }

  /// Aggregated list of all biomes across all active content plugins
  List<HydrationBiome> get allBiomes {
    final List<HydrationBiome> result = [];
    final Set<String> seenIds = {};
    for (final plugin in _plugins.values) {
      for (final biome in plugin.biomes) {
        if (!seenIds.contains(biome.id)) {
          seenIds.add(biome.id);
          result.add(biome);
        }
      }
    }
    return List.unmodifiable(result);
  }

  /// Aggregated list of all beverages across all active content plugins
  List<BeverageType> get allBeverages {
    final List<BeverageType> result = [];
    final Set<String> seenIds = {};
    for (final plugin in _plugins.values) {
      for (final bev in plugin.beverages) {
        if (!seenIds.contains(bev.id)) {
          seenIds.add(bev.id);
          result.add(bev);
        }
      }
    }
    return List.unmodifiable(result);
  }

  /// Aggregated list of all commercial SKUs across all active content plugins
  List<ProductSKU> get allProducts {
    final List<ProductSKU> result = [];
    final Set<String> seenIds = {};
    for (final plugin in _plugins.values) {
      for (final sku in plugin.products) {
        if (!seenIds.contains(sku.id)) {
          seenIds.add(sku.id);
          result.add(sku);
        }
      }
    }
    return List.unmodifiable(result);
  }

  /// Aggregated map of all custom themes across all active content plugins
  Map<String, ThemeData> get allThemes {
    final Map<String, ThemeData> result = {};
    for (final plugin in _plugins.values) {
      result.addAll(plugin.customThemes);
    }
    return Map.unmodifiable(result);
  }

  /// Finds a companion by ID across all registered plugins
  ExoticAnimal? findCompanion(String id) {
    try {
      return allCompanions.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Finds a biome by ID across all registered plugins
  HydrationBiome? findBiome(String id) {
    try {
      return allBiomes.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Finds a beverage by ID across all registered plugins
  BeverageType? findBeverage(String id) {
    try {
      return allBeverages.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Finds a store product by ID across all registered plugins
  ProductSKU? findProduct(String id) {
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Riverpod provider delivering the global content expansion plugin registry
final contentPluginRegistryProvider = Provider<ContentPluginRegistry>((ref) {
  return ContentPluginRegistry.standard();
});
