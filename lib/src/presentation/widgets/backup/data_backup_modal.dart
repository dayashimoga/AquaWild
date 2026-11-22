import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../core/services/data_backup_service.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/biome_controller.dart';
import '../../controllers/gamification_controller.dart';
import '../../controllers/hydration_controller.dart';

/// Modal sheet for exporting and restoring personal hydration records,
/// streaks, achievements, and telemetry in JSON and CSV formats.
class DataBackupModal extends ConsumerStatefulWidget {
  const DataBackupModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DataBackupModal(),
    );
  }

  @override
  ConsumerState<DataBackupModal> createState() => _DataBackupModalState();
}

class _DataBackupModalState extends ConsumerState<DataBackupModal> {
  final TextEditingController _importController = TextEditingController();
  String? _statusMessage;
  bool _isSuccess = true;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  void _copyJsonBackup() {
    final hydration = ref.read(hydrationProvider);
    final habitat = ref.read(animalHabitatProvider);
    final gamification = ref.read(gamificationProvider);
    final biome = ref.read(biomeProvider);

    final jsonStr = DataBackupService.exportToJson(
      entries: hydration.entries,
      dailyGoalMl: hydration.goal.effectiveGoalMl.toDouble(),
      userXp: habitat.userXp,
      activeAnimalId: habitat.activeAnimal.id,
      activeBiomeId: biome.activeBiome.id,
      streakDays: gamification.streak.currentStreakDays,
      longestStreakDays: gamification.streak.longestStreakDays,
      streakFreezes: gamification.streak.streakFreezesAvailable,
      unlockedBadgeIds: gamification.badges
          .where((b) => b.isUnlocked)
          .map((b) => b.id)
          .toList(),
    );

    Clipboard.setData(ClipboardData(text: jsonStr));
    AudioHapticsService.playTap();
    setState(() {
      _statusMessage =
          'Complete JSON backup (${hydration.entries.length} entries) copied to clipboard!';
      _isSuccess = true;
    });
  }

  void _copyCsvExport() {
    final hydration = ref.read(hydrationProvider);
    final csvStr = DataBackupService.exportToCsv(hydration.entries);

    Clipboard.setData(ClipboardData(text: csvStr));
    AudioHapticsService.playTap();
    setState(() {
      _statusMessage =
          'Spreadsheet CSV (${hydration.entries.length} rows) copied to clipboard!';
      _isSuccess = true;
    });
  }

  void _importJson() {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _statusMessage = 'Please paste a valid JSON backup text.';
        _isSuccess = false;
      });
      return;
    }

    final parsed = DataBackupService.validateAndParseBackup(text);
    if (parsed == null) {
      setState(() {
        _statusMessage = 'Invalid AquaWild JSON format. Please verify content.';
        _isSuccess = false;
      });
      return;
    }

    final entries = DataBackupService.parseEntriesFromBackup(parsed);
    final profile = parsed['profile'] as Map<String, dynamic>?;
    final int xp = (profile?['user_xp'] as num?)?.toInt() ?? 0;

    // Restore entries and XP
    for (final e in entries) {
      ref.read(hydrationProvider.notifier).logDrink(
            beverage: e.beverage,
            volumeMl: e.volumeMl,
          );
    }
    if (xp > 0) {
      ref.read(animalHabitatProvider.notifier).addXp(xp);
    }

    AudioHapticsService.playGoalCelebration();
    setState(() {
      _statusMessage =
          'Successfully restored ${entries.length} entries and $xp XP!';
      _isSuccess = true;
      _importController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hydration = ref.watch(hydrationProvider);
    final habitat = ref.watch(animalHabitatProvider);
    final gamification = ref.watch(gamificationProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C192E).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
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

            // Modal Header
            const Row(
              children: [
                Icon(
                  Icons.backup_rounded,
                  color: Color(0xFF00E5FF),
                  size: 24,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Data Portability & Backup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Your hydration telemetry is 100% private and yours to keep. Export or restore your logs anytime.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Telemetry Overview Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF132238),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    'Entries',
                    '${hydration.entries.length}',
                    Icons.history,
                  ),
                  _buildMetric(
                    'Streak',
                    '${gamification.streak.currentStreakDays}d',
                    Icons.local_fire_department,
                  ),
                  _buildMetric(
                    'Total XP',
                    '${habitat.userXp}',
                    Icons.star_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status message pill
            if (_statusMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? const Color(0xFF1B5E20).withValues(alpha: 0.6)
                      : const Color(0xFFB71C1C).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSuccess
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFFEF5350),
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Export Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00E5FF),
                      side: const BorderSide(color: Color(0xFF00E5FF)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _copyJsonBackup,
                    icon: const Icon(Icons.code_rounded, size: 18),
                    label: const Text('Export JSON'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF69F0AE),
                      side: const BorderSide(color: Color(0xFF69F0AE)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _copyCsvExport,
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: const Text('Export CSV'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Restore from JSON Section
            const Text(
              'Restore from Backup JSON',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _importController,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Colors.white70,
              ),
              decoration: InputDecoration(
                hintText: 'Paste AquaWild backup JSON content here...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF162947),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _importJson,
              icon: const Icon(Icons.restore_rounded, size: 18),
              label: const Text('Validate & Restore Backup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
