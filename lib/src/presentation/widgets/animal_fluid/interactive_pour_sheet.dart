import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/core/theme/app_colors.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:flutter/material.dart';

/// Modern-futuristic vertical drag-to-pour vessel modal:
/// - Replaces static flat cup sliders with an interactive vertical fluid level gesture
/// - Real-time volume readout and net hydration preview
/// - Beverage category switcher
/// - Tactile haptic feedback ticks on volume changes
class InteractivePourSheet extends StatefulWidget {
  final BeverageType initialBeverage;
  final ValueChanged<double> onPourConfirmed;
  final void Function(BeverageType beverage, double volumeMl)? onBeveragePourConfirmed;

  const InteractivePourSheet({
    super.key,
    required this.initialBeverage,
    required this.onPourConfirmed,
    this.onBeveragePourConfirmed,
  });

  @override
  State<InteractivePourSheet> createState() => _InteractivePourSheetState();
}

class _InteractivePourSheetState extends State<InteractivePourSheet> {
  late BeverageType _selectedBeverage;
  double _volumeMl = 300.0;
  static const double _minMl = 50.0;
  static const double _maxMl = 1000.0;

  @override
  void initState() {
    super.initState();
    _selectedBeverage = widget.initialBeverage;
    _volumeMl = widget.initialBeverage.presetVolumesMl.isNotEmpty
        ? widget.initialBeverage.presetVolumesMl.first.toDouble()
        : 300.0;
  }

  void _updateVolume(double newVol) {
    final clamped = newVol.clamp(_minMl, _maxMl);
    // Snap to nearest 10ml
    final snapped = (clamped / 10).round() * 10.0;
    if (snapped != _volumeMl) {
      AudioHapticsService.instance.onSliderTick();
      setState(() {
        _volumeMl = snapped;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final netHydration = _selectedBeverage.calculateNetHydration(_volumeMl);
    final heightFraction = ((_volumeMl - _minMl) / (_maxMl - _minMl)).clamp(0.0, 1.0);

    return Container(
      height: 600,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.cardGlassBorderDark, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Drag handle pill
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBeverage.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Net Hydration: ${netHydration.toStringAsFixed(0)} ml',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedBeverage.primaryColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Beverage Selector Carousel (16 Handcrafted Beverages)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: BeverageType.allBeverages.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final bev = BeverageType.allBeverages[index];
                final isSelected = bev.id == _selectedBeverage.id;
                return FilterChip(
                  avatar: CircleAvatar(
                    backgroundColor: bev.primaryColor,
                    radius: 6,
                  ),
                  label: Text(
                    bev.name.split(' ').first,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: bev.primaryColor.withValues(alpha: 0.35),
                  backgroundColor: const Color(0xFF162947),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? bev.primaryColor : Colors.white12,
                  ),
                  onSelected: (val) {
                    if (val) {
                      AudioHapticsService.playTap();
                      setState(() {
                        _selectedBeverage = bev;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Interactive Drag-to-Pour Vessel
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                // Dragging upwards increases volume
                final deltaMl = -details.primaryDelta! * 3.0;
                _updateVolume(_volumeMl + deltaMl);
              },
              child: Center(
                child: Container(
                  width: 140,
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppColors.cardGlassDark,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _selectedBeverage.primaryColor.withValues(alpha: 0.6),
                      width: 2.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Animated liquid fill
                        FractionallySizedBox(
                          widthFactor: 1.0,
                          heightFactor: heightFraction,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  _selectedBeverage.secondaryColor,
                                  _selectedBeverage.primaryColor,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Center volume readout
                        Positioned.fill(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _volumeMl.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  'ml',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Vertical drag guide handle icon
                        const Positioned(
                          right: 12,
                          bottom: 12,
                          child: Icon(
                            Icons.unfold_more_rounded,
                            color: Colors.white38,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Preset Quick Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [150.0, 250.0, 350.0, 500.0].map((v) {
              final isSelected = (_volumeMl - v).abs() < 5;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text('${v.toInt()}ml'),
                  selected: isSelected,
                  onSelected: (_) => _updateVolume(v),
                  selectedColor: _selectedBeverage.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.surfaceAbyssal : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Confirm Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                AudioHapticsService.instance.onDrinkLogged();
                widget.onPourConfirmed(_volumeMl);
                widget.onBeveragePourConfirmed?.call(_selectedBeverage, _volumeMl);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedBeverage.primaryColor,
                foregroundColor: AppColors.surfaceAbyssal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(
                'Log +${_volumeMl.toStringAsFixed(0)} ml ${_selectedBeverage.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
