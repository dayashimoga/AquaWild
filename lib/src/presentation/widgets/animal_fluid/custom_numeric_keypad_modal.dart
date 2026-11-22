import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/core/theme/app_colors.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:flutter/material.dart';

/// Tactile custom numeric keypad modal for precision hydration entry
class CustomNumericKeypadModal extends StatefulWidget {
  final BeverageType beverage;
  final ValueChanged<double> onAmountConfirmed;

  const CustomNumericKeypadModal({
    super.key,
    required this.beverage,
    required this.onAmountConfirmed,
  });

  @override
  State<CustomNumericKeypadModal> createState() =>
      _CustomNumericKeypadModalState();
}

class _CustomNumericKeypadModalState extends State<CustomNumericKeypadModal> {
  String _digits = '300';

  void _appendDigit(String d) {
    if (_digits.length >= 4) return; // Prevent excessive values (> 9999ml)
    AudioHapticsService.instance.onKeypadPress();
    setState(() {
      if (_digits == '0') {
        _digits = d;
      } else {
        _digits += d;
      }
    });
  }

  void _backspace() {
    AudioHapticsService.instance.onKeypadPress();
    setState(() {
      if (_digits.isNotEmpty) {
        _digits = _digits.substring(0, _digits.length - 1);
      }
      if (_digits.isEmpty) _digits = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    final double volume = double.tryParse(_digits) ?? 0.0;
    final double netHydration = widget.beverage.calculateNetHydration(volume);

    return Container(
      height: 520,
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
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.beverage.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Numeric Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _digits,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cyanPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ml',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
            ],
          ),
          Text(
            'Net Hydration: ${netHydration.toStringAsFixed(0)} ml',
            style: TextStyle(
              fontSize: 13,
              color: widget.beverage.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Responsive Keypad Rows
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildKey('1', onTap: () => _appendDigit('1'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildKey('2', onTap: () => _appendDigit('2'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildKey('3', onTap: () => _appendDigit('3'))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildKey('4', onTap: () => _appendDigit('4'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildKey('5', onTap: () => _appendDigit('5'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildKey('6', onTap: () => _appendDigit('6'))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildKey('7', onTap: () => _appendDigit('7'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildKey('8', onTap: () => _appendDigit('8'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildKey('9', onTap: () => _appendDigit('9'))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildKey(
                          'C',
                          onTap: () {
                            AudioHapticsService.instance.onKeypadPress();
                            setState(() => _digits = '0');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildKey('0', onTap: () => _appendDigit('0'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildKey('⌫', onTap: _backspace)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: volume > 0
                  ? () {
                      AudioHapticsService.instance.onDrinkLogged();
                      widget.onAmountConfirmed(volume);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.beverage.primaryColor,
                foregroundColor: AppColors.surfaceAbyssal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(
                'Log $volume ml',
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

  Widget _buildKey(String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardGlassDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
