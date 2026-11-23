import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/beverage_type.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/hydration_controller.dart';
import 'beverage_customizer_modal.dart';

/// Interactive Quick-Log Beverage Dock featuring horizontal drag scrolling,
/// left/right desktop scroll controls, visible scrollbar indicator,
/// and instant one-touch beverage logging with XP awards.
class QuickLogDock extends ConsumerStatefulWidget {
  const QuickLogDock({super.key});

  @override
  ConsumerState<QuickLogDock> createState() => _QuickLogDockState();
}

class _QuickLogDockState extends ConsumerState<QuickLogDock> {
  late final ScrollController _scrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateScrollButtons();
  }

  void _updateScrollButtons() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final canLeft = currentScroll > 4.0;
    final canRight = currentScroll < maxScroll - 4.0;

    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset - 200.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + 200.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final beverages = BeverageType.allBeverages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row with Controls
        Row(
          children: [
            const Expanded(
              child: Text(
                'Quick Log Beverage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Keys [1-9]',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Semantics(
              button: true,
              label: 'Craft Custom Beverage',
              child: IconButton(
                style: IconButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                tooltip: 'Craft Custom Beverage',
                onPressed: () => BeverageCustomizerModal.show(context),
              ),
            ),
            // Desktop/Web Left & Right Scroll Controls
            Semantics(
              button: true,
              label: 'Scroll Beverages Left',
              child: IconButton(
                style: IconButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  Icons.chevron_left_rounded,
                  size: 22,
                  color: _canScrollLeft ? Colors.white : Colors.white24,
                ),
                tooltip: 'Scroll Left',
                onPressed: _canScrollLeft ? _scrollLeft : null,
              ),
            ),
            Semantics(
              button: true,
              label: 'Scroll Beverages Right',
              child: IconButton(
                style: IconButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: _canScrollRight ? Colors.white : Colors.white24,
                ),
                tooltip: 'Scroll Right',
                onPressed: _canScrollRight ? _scrollRight : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal Beverage Carousel with Scrollbar & Multi-Device Drag Support
        SizedBox(
          height: 114,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: RawScrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thumbColor: AppColors.cyanPrimary.withValues(alpha: 0.45),
              radius: const Radius.circular(8),
              thickness: 4.0,
              padding: const EdgeInsets.only(top: 106.0),
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 10),
                itemCount: beverages.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  // Last Card: Craft Custom Beverage
                  if (index == beverages.length) {
                    return _buildCraftCustomCard(context);
                  }

                  final bev = beverages[index];
                  final hasShortcut = index < 9;
                  return _buildBeverageCard(context, ref, bev, index, hasShortcut);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCraftCustomCard(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Craft custom beverage with personalized hydration parameters',
      child: InkWell(
        onTap: () => BeverageCustomizerModal.show(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardGlassDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white24,
              style: BorderStyle.solid,
            ),
          ),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white12,
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: AppColors.cyanPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Craft Drink',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeverageCard(
    BuildContext context,
    WidgetRef ref,
    BeverageType bev,
    int index,
    bool hasShortcut,
  ) {
    final defaultVol = bev.presetVolumesMl.first.toDouble();

    return Semantics(
      button: true,
      label: 'Quick log ${bev.presetVolumesMl.first} milliliters of ${bev.name}${hasShortcut ? ', shortcut key ${index + 1}' : ''}',
      child: InkWell(
        onTap: () {
          ref.read(hydrationProvider.notifier).logDrink(
                beverage: bev,
                volumeMl: defaultVol,
              );
          ref.read(animalHabitatProvider.notifier).addXp(
                (defaultVol / 10).round(),
              );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardGlassDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: bev.primaryColor.withValues(alpha: 0.4),
            ),
          ),
          child: Stack(
            children: [
              if (hasShortcut)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white12,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: bev.primaryColor.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.local_drink_rounded,
                        size: 16,
                        color: bev.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bev.name.split(' ').first,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '+${bev.presetVolumesMl.first}ml',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: bev.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
