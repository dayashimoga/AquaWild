import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../domain/models/beverage_type.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/hydration_controller.dart';

/// Interactive modal studio to craft, parameterize, and save personalized beverages.
class BeverageCustomizerModal extends ConsumerStatefulWidget {
  const BeverageCustomizerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BeverageCustomizerModal(),
    );
  }

  @override
  ConsumerState<BeverageCustomizerModal> createState() =>
      _BeverageCustomizerModalState();
}

class _BeverageCustomizerModalState
    extends ConsumerState<BeverageCustomizerModal> {
  final TextEditingController _nameController =
      TextEditingController(text: 'My Custom Elixir');
  BeverageCategory _category = BeverageCategory.wellness;
  double _hydrationIndex = 1.10;
  double _caffeineMg = 0.0;
  double _electrolytesMg = 45.0;
  int _presetVolume = 350;
  Color _selectedColor = const Color(0xFF00E5FF);

  static const List<Color> _palette = [
    Color(0xFF00E5FF), // Neon Cyan
    Color(0xFF69F0AE), // Mint Green
    Color(0xFFFFD54F), // Amber Gold
    Color(0xFFFF4081), // Neon Pink
    Color(0xFFB388FF), // Lavender Purple
    Color(0xFFFF7043), // Coral Orange
    Color(0xFF4FC3F7), // Sky Blue
    Color(0xFF8D6E63), // Roasted Mocha
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveAndLog() {
    final name = _nameController.text.trim().isEmpty
        ? 'Custom Elixir'
        : _nameController.text.trim();
    final id =
        'custom_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch % 10000}';

    final customBeverage = BeverageType(
      id: id,
      name: name,
      category: _category,
      hydrationIndex: _hydrationIndex,
      caffeineMgPer100ml: _caffeineMg,
      electrolytesMgPer100ml: _electrolytesMg,
      sugarGramsPer100ml: 3.0,
      density: 1.02,
      viscosity: 0.03,
      primaryColor: _selectedColor,
      secondaryColor: _selectedColor.withValues(alpha: 0.7),
      gradientColors: [_selectedColor, _selectedColor.withValues(alpha: 0.6)],
      presetVolumesMl: [_presetVolume, _presetVolume + 150, _presetVolume + 300],
      description: 'Handcrafted personal beverage tailored for optimal hydration.',
    );

    // Register into global catalog
    BeverageType.registerCustom(customBeverage);

    // Log the drink
    ref.read(hydrationProvider.notifier).logDrink(
          beverage: customBeverage,
          volumeMl: _presetVolume.toDouble(),
        );
    ref.read(animalHabitatProvider.notifier).addXp(
          (_presetVolume / 10).round(),
        );

    AudioHapticsService.instance.onDrinkLogged();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✨ Crafted & logged +${_presetVolume}ml of $name!',
        ),
        backgroundColor: _selectedColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final netMl =
        (_presetVolume * _hydrationIndex) - (_caffeineMg > 100 ? 20 : 0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C192E).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: _selectedColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Icon(Icons.science_rounded, color: _selectedColor, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Custom Beverage Studio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name Field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Beverage Name',
                labelStyle: TextStyle(color: _selectedColor),
                filled: true,
                fillColor: const Color(0xFF162947),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _selectedColor),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category Chips
            const Text(
              'Category',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: BeverageCategory.values.map((cat) {
                final isSelected = cat == _category;
                return ChoiceChip(
                  label: Text(
                    cat.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: _selectedColor,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _category = cat);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Bioavailability Hydration Index Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bioavailability Index',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${_hydrationIndex.toStringAsFixed(2)}x',
                  style: TextStyle(
                    color: _selectedColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Slider(
              value: _hydrationIndex,
              min: 0.50,
              max: 1.50,
              divisions: 20,
              activeColor: _selectedColor,
              onChanged: (val) => setState(() => _hydrationIndex = val),
            ),
            const SizedBox(height: 6),

            // Caffeine & Electrolyte Sliders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Caffeine per 100ml',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${_caffeineMg.toStringAsFixed(0)} mg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Slider(
              value: _caffeineMg,
              min: 0.0,
              max: 120.0,
              divisions: 12,
              activeColor: Colors.orangeAccent,
              onChanged: (val) => setState(() => _caffeineMg = val),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Electrolytes per 100ml',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${_electrolytesMg.toStringAsFixed(0)} mg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Slider(
              value: _electrolytesMg,
              min: 0.0,
              max: 150.0,
              divisions: 15,
              activeColor: Colors.greenAccent,
              onChanged: (val) => setState(() => _electrolytesMg = val),
            ),
            const SizedBox(height: 10),

            // Color Palette Selector
            const Text(
              'Fluid Theme Color',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _palette.map((c) {
                final isSelected = c.toARGB32() == _selectedColor.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: c.withValues(alpha: 0.6),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Preset Volume Choice
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [200, 350, 500, 750].map((v) {
                final isSelected = v == _presetVolume;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text('${v}ml'),
                    selected: isSelected,
                    selectedColor: _selectedColor,
                    onSelected: (val) {
                      if (val) setState(() => _presetVolume = v);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Action Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _saveAndLog,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                'Craft & Log +${_presetVolume}ml (~${netMl.toStringAsFixed(0)}ml Net)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
