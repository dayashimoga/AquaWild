# Changelog

All notable changes to the **AquaWild (HydroFauna)** Cross-Platform AI-Powered Hydration Ecosystem are documented in this file.

## [1.24.0] - 2026-11-22 — Stage 6: Subphase 6.2.1 — Interactive Home Screen & Lock Screen Widget Preview Studio
### Added
- **Widget Preview Studio Modal (`WidgetPreviewStudioModal`)**:
  * Implemented in-app widget simulator modal in `lib/src/presentation/widgets/widgets_preview/widget_preview_studio_modal.dart`.
  * Interactive tabs for Compact (2x2), Medium (4x2), and Lock Screen Live Activity form factors.
  * Switchable phone wallpaper backdrops (Dark Abyssal Ocean, Minimal Midnight, Emerald Bamboo, Aurora Glacier).
  * Live reactive simulator connected to `telemetrySnapshotProvider` with instant state updates on tap.
- **High-Fidelity Widget Component Views**:
  * Compact 2x2 Home Widget (`CompactWidgetView`): 156x156dp with circular progress ring, companion avatar, streak badge, and +250ml action.
  * Medium 4x2 Home Widget (`MediumWidgetView`): 328x156dp with multi-nutrient chips (caffeine, electrolytes, sugar), circadian pace, and 4-volume quick dock.
  * Lock Screen Live Activity (`LockScreenLiveActivityView`): 340x140dp AMOLED glass card with companion evolution stage, linear progress bar, and quick actions.
- **Cross-Platform Native Widget Bridge (`WidgetBridgeSyncService`)**:
  * Implemented `WidgetBridgeSyncService` in `lib/src/core/services/widget_bridge_sync_service.dart` syncing snapshots to native iOS WidgetKit, Android Glance, and local storage.
- **Responsive Shell Widget Studio Navigation**:
  * Added quick launcher across mobile menu, tablet rail, and desktop command deck in `lib/src/presentation/screens/home/responsive_home_shell.dart`.
- **Automated Widget Studio Test Suite (`widget_preview_studio_test.dart`)**:
  * Added 7 tests covering models, component rendering, quick-logging, and studio modal lifecycle.
  * **208 / 208 passing tests**, **0 analyzer issues**, **zero warnings**.

---

## [1.23.0] - 2026-11-22 — Stage 6: Subphase 6.1.2 — Interactive Rich Notification Payload Generator & Actionable Quick-Log Notification Handlers
### Added
- **Interactive Rich Notification Payload Engine**:
  * Implemented `RichNotificationPayload` and `NotificationAction` in `lib/src/domain/models/notification_payload.dart`.
  * Dynamic titles and progress subtitles reflecting net hydration, circadian phase, and target status.
  * Multi-nutrient clinical safety warnings in notification body for caffeine limits (400mg), added sugar guidance (50g), and electrolyte depletion.
  * Companion personality quote engine tailored to lore and circadian pace (Red Panda, Capybara, Axolotl, Sea Otter, Dolphin, and companions).
- **Actionable Background Quick-Log & Snooze Handlers**:
  * Implemented `RichNotificationService.handleNotificationAction` in `lib/src/core/services/rich_notification_service.dart`.
  * Allows logging +250ml or +500ml Pure Water headlessly directly from system notifications without opening the app.
  * Automatically calculates XP earned (1 XP per 10ml) and synchronizes with local widget telemetry cache.
  * Supports 30-minute reminder snoozing and deep-link routing (`/home`).
- **Riverpod Notification Integration**:
  * Created `latestNotificationPayloadProvider` and `notificationActionDispatcherProvider` in `lib/src/presentation/controllers/notification_controller.dart`.
- **Automated Rich Notification Test Suite (`rich_notification_test.dart`)**:
  * Added 15 tests covering models, payload generator, nutrient alerts, companion quotes, background action handlers, and Riverpod dispatcher.
  * **201 / 201 passing tests**, **0 analyzer issues**, **zero warnings**.

---

## [1.22.0] - 2026-11-22 — Stage 6: Subphase 6.1.1 — Out-of-App Hydration & Budget Telemetry Service
### Added
- **Out-of-App Hydration & Multi-Nutrient Budget Engine**:
  * Implemented `OutOfAppTelemetrySnapshot` and `HydrationBudgetSummary` in `lib/src/domain/models/out_of_app_telemetry.dart`.
  * Multi-nutrient budgets: 400mg daily caffeine safety tiers (`safe`, `moderate`, `caution`, `exceeded`), electrolyte balance status (`depleted`, `optimal`, `surplus`), and 50g added sugar tracking.
- **Circadian Pacing & Dynamic Sip Scheduling**:
  * Added `CircadianContext` and `CircadianPaceStatus` computing real-time day pace (`aheadOfPace`, `onTrack`, `behindPace`, `criticalDeficit`).
  * Suggests tailored next sip volume and target time based on day fraction and deficit severity.
- **Next Companion Unlock Progression**:
  * Added `NextUnlockProgression` calculating remaining XP and fraction toward unlocking the next companion in the animal ecosystem.
- **Widget & Notification Telemetry Service (`WidgetNotificationTelemetryService`)**:
  * Built `lib/src/core/services/widget_notification_telemetry_service.dart` computing atomic telemetry snapshots and persisting to `aquawild_widget_telemetry_snapshot`.
  * Created `telemetrySnapshotProvider` in `lib/src/presentation/controllers/telemetry_controller.dart`.
- **Automated Telemetry Test Suite (`widget_notification_telemetry_test.dart`)**:
  * Added 12 tests covering nutrient limits, circadian pacing, unlock progression, and serialization.
  * **186 / 186 passing tests**, **0 analyzer issues**, **zero warnings**.

---

## [1.21.0] - 2026-11-22 — Stage 5: Subphase 5.2.2 — Monetization Entitlement Security, Offline Grace Period & Receipt Validation
### Added
- **Tamper-Evident Cryptographic Envelopes (`MonetizationSecurityService`)**:
  * Implemented HMAC-SHA256 signature stamping and sealed envelope serialization in `lib/src/core/security/monetization_security_service.dart`.
  * Protects local storage keys (`aquawild_user_subscription` and `aquawild_user_entitlements`) against unauthorized client-side modification.
  * Clock rollback defense flagging time shifts >2 hours into the future.
  * Automatic migration forward of unsealed legacy storage records.
- **In-App Purchase Receipt Validation (`ReceiptVerificationService`)**:
  * Implemented multi-store receipt verification in `lib/src/core/security/receipt_verification_service.dart` supporting Apple App Store, Google Play, Stripe, and Web/Desktop Sandboxes.
  * Cryptographic signature validation with bundle ID checks (`com.aquawild.app`, `com.aquawild.web`).
  * Replay attack defense tracking redeemed transaction IDs to prevent double-crediting.
- **72-Hour Offline Subscription Grace Period**:
  * Added `effectiveStatus`, `isInGracePeriod`, and `isPastGracePeriod` to `UserSubscription`.
  * Preserves full Pro access for 72 hours when subscriptions expire during offline usage.
- **Automated Security Test Suite (`monetization_security_test.dart`)**:
  * Added 16 tests covering tamper detection, signature verification, clock tampering, replay protection, offline grace period transitions, and repository auto-purge.
  * **174 / 174 passing tests**, **0 analyzer issues**, **zero warnings**.

---

## [1.20.0] - 2026-11-22 — Stage 5: Subphase 5.2.1 — Storefront UX, Instant Companion Unlocks & Dual-Path Triggers
### Added
- **Glassmorphic Premium Storefront Modal (`PremiumStorefrontModal`)**:
  * Implemented flagship store sheet in `lib/src/presentation/widgets/monetization/premium_storefront_modal.dart`.
  * Tab 1 (AquaWild Pro): Tier radio cards for Annual Pass (\$19.99/yr, 44% savings), Monthly Pass (\$2.99/mo), and Lifetime Access (\$49.99), plus 6-point Free vs Pro feature comparison matrix.
  * Tab 2 (Packs & Passes): 6 commercial SKUs (`pack_deep_sea`, `pack_alpine_glacier`, `pack_neon_bioluminescence`, `pack_minimal_zen`, `pack_cyber_ocean`, `pass_summer_splash`) with real-time 'OWNED' badges and instant purchase actions.
  * Bottom utility bar with Restore Purchases button and auto-renewal legal transparency.
- **Dual-Path Companion Unlock System (`BiomeCompanionSelectorSheet`)**:
  * Converted locked companion tiles into interactive triggers showing required XP alongside instant unlock buttons.
  * Dual-path dialog offering Path A (Earn via daily hydration habit XP) and Path B (Instant unlock with AquaWild Pro or matching one-time IAP pack).
  * Persistent top Pro upgrade banner with direct storefront launch button.
- **Responsive Shell Storefront Navigation (`ResponsiveHomeShell`)**:
  * Added storefront quick launcher across compact phone AppBar, medium tablet NavigationRail, and expanded desktop command deck.
  * Consolidated auxiliary actions into mobile overflow `PopupMenuButton` to guarantee zero RenderFlex horizontal overflows on screens down to 320px.
- **Automated Test Coverage**:
  * Added `test/presentation/storefront_modal_test.dart` (7 tests covering storefront tabs, plan selection, IAP purchases, restore purchases, and dual-path unlocks).
  * Updated `test/presentation/gamification_analytics_ui_test.dart` for updated companion selector counts.
  * **158 / 158 passing tests**, **0 analyzer issues**, **zero warnings**.

---

## [1.19.0] - 2026-11-22 — Stage 5: Subphase 5.1.2 — Premium Themes, Particle Visual Effects, Exclusive Achievements & Content Plugin Architecture
### Added
- **Flagship Premium Theme Engine & Mode Tokens**:
  * Added `neonBioluminescence`, `minimalZen`, and `cyberOcean` to `AppThemeMode` with `isPremium` and `themeId` metadata.
  * Implemented `AppTheme.neonBioluminescenceTheme`: electric midnight (`#050814`), high-voltage neon cyan (`#00F0FF`), and neon magenta (`#FF007F`) with glowing hydro-glass cards.
  * Implemented `AppTheme.minimalZenTheme`: warm Japanese washi paper (`#F9F7F1`), deep moss/matcha green (`#4A6B53`), and cedar/bamboo accents (`#C48B54`).
  * Implemented `AppTheme.cyberOceanTheme`: oceanic trench midnight (`#040B1A`), synthetic ultraviolet glows (`#9D4EDD`), and cyber aqua (`#00E5FF`).
  * Synchronized Flutter `ThemeMode` in `lib/main.dart` based on resolved `ThemeData.brightness`.
- **Monetization Theme Lock Integration (`ThemeSwitcherButton`)**:
  * Display amber padlock badges (`Icons.lock_rounded`) for locked premium themes.
  * Show non-blocking `SnackBar` explaining Pro requirement when Free users tap locked themes; enable instant switching for Pro and theme-pack owners.
- **Dynamic Multi-Style Particle Effects System (`PoolParticlesPainter`)**:
  * Added `ParticleEffectType` supporting `standardBubbles`, `bioluminescentPlankton`, `auroraDust`, and `onsenSteamBubbles`.
  * Pre-allocated cached paints to guarantee 60/120 FPS frame budget without GC pressure inside `paint()`.
  * Context-based theme particle auto-detection in `InteractivePoolView` with full reduced-motion accessibility support.
- **Exclusive Milestone & Premium Achievements**:
  * Added 4 exclusive achievements to `AchievementBadge.defaultAchievements`: `pro_pioneer` (Apex Guardian, 500 XP, 👑), `summer_splash_champion` (Summer Splash Legend, 750 XP, 🏖️), `master_of_ten` (Wild Menagerie, 2000 XP, 🐾), and `bioluminescence_diver` (Abyssal Glow, 300 XP, 🪼).
- **Dynamic Content Expansion Plugin Architecture (`ContentPluginRegistry`)**:
  * Created `ContentPlugin` and `ContentPluginRegistry` (`contentPluginRegistryProvider`) allowing dynamic registration/unregistration of future content drops, seasonal companions, and partner biomes.
  * Pre-registered `CoreAquaWildPlugin` (`aquawild.core`) bundling 10 living companions, 6 biomes, science beverages, and store SKUs.
- **Automated Test Coverage**:
  * Added `test/presentation/premium_themes_test.dart` (8 tests) and updated `test/presentation/theme_notifier_test.dart`.
  * 151 / 151 passing tests across all test suites, 0 analyzer issues.

---

## [1.18.0] - 2026-11-22 — Stage 5: Subphase 5.1.1 — Monetization Domain & State Engine
### Added
- **Monetization Domain & Repository (`MonetizationRepository`)**:
  * Added `MonetizationRepository` interface and `LocalMonetizationRepository` implementation with in-memory caching and offline-first `SharedPreferences` persistence.
- **Reactive Monetization State Engine (`MonetizationController`)**:
  * Implemented `MonetizationController` (`monetizationProvider`) supporting AquaWild Pro subscriptions (Monthly, Annual, Lifetime), one-time IAP unlock packs (Deep Sea Legends, Alpine Glacier, Neon Bioluminescence), and Summer Splash Seasonal Pass.
  * Added compound entitlement resolution (`isAnimalUnlocked`, `isThemeUnlocked`, `isSeasonalPassActive`) combining Pro overrides, purchased IAPs, and XP thresholds.
- **Reactive Companion Integration**:
  * Wired `AnimalHabitatNotifier` and `BiomeCompanionSelectorSheet` to `monetizationProvider`: IAP purchases or Pro subscriptions instantly unlock companions without requiring an app reload.
- **Automated Test Coverage**:
  * Added `test/domain/monetization_test.dart` verifying subscriptions, purchases, admin overrides, and reactive controller sync.
  * 143 / 143 passing tests across all test suites, 0 analyzer issues.

---

## [1.17.0] - 2026-11-22 — Stage 4: Subphase 4.2.2 — High-Detail Companion Avatar Renderer, Evolution Auras & Stage 4 Sign-Off
### Added
- **High-Detail Companion Avatar Renderer (`CompanionAvatarRenderer`)**:
  * Created reusable `CompanionAvatarRenderer` component rendering living vector companion vessels via `AnimalFluidVesselPainter` and `AnimalSilhouettePaths`.
  * Pre-allocated static 16-column wave solver for zero heap allocations during avatar rendering.
  * Added species emoji badge pill, frosted glass padlock overlay for locked companions, and full screen-reader semantics.
- **Dynamic 4-Stage Evolution Auras (`CompanionEvolutionAura`)**:
  * Hatchling (gentle ambient morning-dew glow halo), Explorer (concentric bioluminescent double-ring shimmer), Guardian (iridescent caustic sweep halo), and Mythic Spirit (cosmic celestial rainbow aurora sweep with continuous rotation and reduced-motion fallback).
- **Selector Sheet & Celebration Modal Integration**:
  * Integrated vector avatars into `BiomeCompanionSelectorSheet` active banner (`size: 64`) and companion list tiles (`size: 50`).
  * Integrated into `CompanionEvolutionModal` celebration pedestal (`size: 110`), replacing raw text emoji placeholders with animated vector artwork.
- **10-Animal Comprehensive Ecosystem Regression Suite (`companion_avatar_test.dart`)**:
  * Certified all 10 companions across multi-platform viewport sizes (`32x32`, `56x56`, `120x120`, `300x345`, `800x600`).
  * Verified unique IDs, names, biomes, non-zero capacity, 4 evolution stages, and authentic emoji mappings with zero `'🐾'` fallbacks.
  * 130 / 130 passing tests across all test suites, 0 analyzer issues.

---

## [1.16.0] - 2026-11-22 — Stage 4: Subphase 4.2.1 — Apex Exotic Companions Vector Silhouettes & Anatomical Details Upgrade
### Added
- **Continuous Anatomical Silhouette Vectorization (`AnimalSilhouettePaths`)**:
  * Upgraded all 5 Apex Exotic companions with authentic, organic continuous bezier paths: Arctic Fox (pointed ears, slender muzzle, bushy wrapped tail), Emperor Penguin (hydrodynamic dome, beak, tapered flippers), Bottlenose Dolphin (melon, rostrum beak, dorsal fin, flukes), Blue-Ringed Octopus (bulbous mantle, undulating curved arms), and Snow Leopard (cranial brow, muscular body, thick tail).
- **Expressive Facial & Interactive Feature Engine (`AnimalFluidVesselPainter`)**:
  * Cephalopod golden iris with horizontal slit pupils and blinking for Blue-Ringed Octopus.
  * Oceanic sapphire/turquoise catchlight eyes, rostrum smile, blowhole gleam, and acoustic sonar rings for Bottlenose Dolphin.
  * Glacial ice-blue almond eyes, velvet ear tips, button nose, whiskers, and Aurora Borealis shimmer veil for Arctic Fox.
  * Flame-to-amber auricular plumage, white tuxedo bib, ruby/amber eye, and yellow/pink mandible stripe for Emperor Penguin.
  * Sage jade eyes with vertical slit pupils, alpine rosettes, white whisker pads, and soft pink nose for Snow Leopard.
  * Zero heap allocations during paint loop via pre-allocated feature paints.
- **Automated Test Coverage**:
  * Added dedicated blinking, reaction, and reduced-motion widget tests for all 5 Apex companions.
  * 123 / 123 passing tests across all test suites, 0 analyzer issues.

---

## [1.15.0] - 2026-11-22 — Stage 4: Subphase 4.1.2 — Capybara, Axolotl, Sea Otter & Andean Llama Starter Vessels Upgrade
### Added
- **Continuous Anatomical Silhouette Vectorization (`AnimalSilhouettePaths`)**:
  * Replaced jagged/polygonal paths with continuous smooth beziers for Capybara (blunt snout, barrel back), Axolotl (6 branching plume arches), Sea Otter (floating posture, folded paws, paddle tail), and Andean Llama (scalloped wool puffs, banana ears).
- **Layered Facial, Eye, Fur & Micro-Interaction Engine (`AnimalFluidVesselPainter`)**:
  * Added natural involuntary blinking, radial gradient iris eyes, dual specular catchlights, muzzle patches, smiles, and species-specific accents.
  * Added folded paws clutching tummy shell for Sea Otter, glowing pink tongue and feathery gills for Axolotl, flat snout and zen squint for Capybara, and curled eyelashes and Aztec pompom collar for Andean Llama.
  * Pre-allocated all companion feature paints for 120 FPS jitter-free rendering.
- **Automated Test Coverage**:
  * Added companion-specific blinking, clutching, and reaction widget tests.
  * 121 / 121 passing tests across all test suites, 0 analyzer issues.

---

## [1.14.0] - 2026-11-22 — Stage 4: Subphase 4.1.1 — Red Panda Home Vessel Silhouette & Anatomical Facial Overlay Redesign
### Added
- **Anatomical Red Panda Vessel Silhouette (`AnimalSilhouettePaths`)**:
  * Replaced blocky polygonal cuts with authentic *Ailurus fulgens* continuous bezier curves: rounded ears, cheek fur ruffs, sweeping bushy tail, and paws.
- **Layered Facial, Eye, Fur & Tail Overlay (`AnimalFluidVesselPainter`)**:
  * Implemented expressive hazel/amber radial gradient eyes with dual catchlights and natural involuntary 200ms blinking.
  * Added white muzzle patch, eyebrow accents, cheek patches, dark auburn tear stripes, and high-contrast button nose with specular highlight.
  * Added reactive peach cheek blush on interaction and 4 signature alternating cream/gold tail rings across the bushy tail.
  * Pre-allocated all feature paints for zero GC pressure and 120 FPS rendering.
- **Exotic Animal Catalog & Emoji Consistency (`ExoticAnimal`)**:
  * Corrected `bottlenose_dolphin` (`🐬`) and `blue_ringed_octopus` (`🐙`) mapping to eliminate unintended `'🐾'` fallbacks across all 10 companions.
- **Automated Test Coverage**:
  * Added all-animal emoji parity tests and Red Panda blinking/interaction widget tests.
  * 119 / 119 passing tests across all test suites, 0 analyzer issues.

---

## [1.13.0] - 2026-11-22 — Stage 3: Subphase 3.2.2 — Fluid Solver Benchmark Profiling & Stage 3 Sign-Off
### Added
- **Wave Column Solver Performance Benchmark (`test/presentation/wave_solver_test.dart`)**:
  * Implemented automated 500-iteration performance benchmark for `WaveColumnSolver`.
  * Verified step computation time $< 0.05\text{ms}$ per step (well within $< 0.2\text{ms}$ frame raster budget on 120Hz displays).
  * Validated zero memory allocation / zero garbage collection pressure during physics simulation.
- **Automated Test Coverage**:
  * 116 / 116 passing tests across all test suites, 0 analyzer issues.

---

## [1.12.0] - 2026-11-22 — Stage 3: Subphase 3.2.1 — Smooth Fill-Level Spring-Damper Interpolation & Pour Stream Ripple Excitation
### Added
- **Critically-Damped Spring-Damper Fill Level Interpolation (`AnimalFluidHabitatView`)**:
  * Replaced instantaneous progress fraction jumps with a physical spring-damper solver ($k = 16.0$, $c = 8.5$), smoothly elevating the fluid level over ~500ms without overshoot.
- **Continuous Pour Stream Ripple Excitation**:
  * Active fluid rise dynamically injects splash impulses across central columns ($col \in [24, 40]$), simulating the physical disturbance of pouring liquid.
- **Reduced-Motion Mode**:
  * Immediate synchronization with target fill level when `MediaQuery.disableAnimationsOf(context)` is enabled.
- **Automated Test Coverage**:
  * Added smooth spring interpolation widget test upon logging drinks in `test/presentation/animal_fluid_vessel_painter_test.dart`.
  * 115 / 115 passing tests across all test suites, 0 analyzer issues.

---

## [1.11.0] - 2026-11-22 — Stage 3: Subphase 3.1.2 — Coupled Shallow-Water Sub-Step Stability & Carbonation Effervescence
### Added
- **Sub-Step Wave Integration & Pre-Allocated Scratch Buffers in `WaveColumnSolver`**:
  * Implemented multi-pass sub-stepping (`subSteps = 2`) ensuring guaranteed numerical stability and smooth dispersion across columns even under extreme splash impulses.
  * Pre-allocated scratch buffers `_leftDeltas` and `_rightDeltas`, achieving 0 per-frame heap allocations during physics updates for 120 FPS frame pacing.
  * Clamped column velocities and heights to prevent any numerical spikes.
- **Beverage-Aware Carbonation Effervescence**:
  * Integrated rising carbonation micro-bubbles for sparkling water, kombucha, and electrolyte drinks with dynamic sinusoidal horizontal wobble and specular highlights.
- **Dual-Pass Specular Meniscus Highlight**:
  * Free surface renders both a soft blurred surface tension glow and a luminous sharp core line.
- **Automated Test Coverage**:
  * Added extreme impulse stability and viscous damping dissipation test in `test/presentation/wave_solver_test.dart`.
  * 114 / 114 passing tests across all test suites, 0 analyzer issues.

---

## [1.10.0] - 2026-11-22 — Stage 3: Subphase 3.1.1 — Zero-Gap Stratified Fluid Wave Mesh Architecture
### Added
- **Continuous Interfacial Mesh Topology in `AnimalFluidVesselPainter`**:
  * Completely eliminated dark background gaps between adjacent beverage layers inside animal vessel silhouettes.
  * Layer $l$ traverses the shared internal interface curve $\text{Interface}_l(x)$ forward, while layer $l+1$ above it traverses the exact same curve in reverse order, ensuring mathematically zero gap ($0.0\text{px}$) between strata.
  * Edge damping ensures internal waves smoothly meet vessel perimeter walls without boundary artifacts.
- **Interfacial Meniscus Sheen**:
  * Rendered specular interfacial separation lines (`Color(0x66FFFFFF)`, 1.4px width) along every stratum boundary, highlighting beverage density separation while eliminating sub-pixel rasterization anti-aliasing artifacts.
- **Automated Test Coverage**:
  * Added 4-layer multi-beverage zero-gap rendering test and reduced-motion contiguous stratum test in `test/presentation/animal_fluid_vessel_painter_test.dart`.
  * 113 / 113 passing tests across all test suites, 0 analyzer issues.

---

## [1.9.0] - 2026-11-22 — Stage 2: Subphase 2.2.2 — Launch Screen Habitat Integration & 120 FPS Benchmark Profiling
### Added
- **Launch Screen Integration & Responsive Layout Hardening (`LaunchScreen`)**:
  * Bound `InteractivePoolView` navigation callback to route to the main habitat (`/home`).
  * Constrained bottom glassmorphic CTA card to 560px max-width, maintaining sleek presentation on 4K, ultrawide, and desktop displays.
  * Added `autofocus: true` on "Dive Into Habitat" action for instant keyboard activation (Enter / Space) and clean focus traversal.
  * Enhanced user onboarding hint copy: *"Tap pool to swim Ruby • Tap Ruby to pet • Move cursor to guide hazel gaze"*.
- **120 FPS Frame Budget Benchmark (< 8.3ms/frame)**:
  * Implemented automated frame-budget rasterization and physics benchmark test simulating 120 cycles in `test/presentation/pool_simulation_test.dart`.
  * Verified zero GC allocations per frame and rasterization well below the 8.3ms threshold (< 0.2ms/frame).
- **Automated Test Coverage**:
  * 111 / 111 passing tests across all test suites, 0 analyzer issues.

---

## [1.8.0] - 2026-11-22 — Stage 2: Subphase 2.2.1 — Tap/Click-to-Move Kinematic Locomotion Controller
### Added
- **Kinematic Mascot Locomotion Controller (`MascotKinematicController`)**:
  * Tap or click anywhere on the pool surface directs Ruby the Red Panda to swim to the destination with smooth pathfinding and boundary rect clamping.
  * 140ms pre-movement anticipation crouch with downward volume-preserving squash and heading orientation alignment.
  * Distance-scaled cubic eased trajectory (`Curves.easeInOutCubic`) cruising at ~380px/s with momentum tilt and hydrodynamic forward stretch.
  * Continuous trailing wake ripples emitted every 26px behind the tail along the inverse travel vector.
  * Damped harmonic landing bounce upon arrival with arrival splash before settling to idle floating.
  * Seamless in-flight retargeting preserving current instantaneous position and velocity.
- **Direct Petting vs Swim Differentiation**:
  * Taps within 65px of Ruby trigger affectionate petting reactions (squint, blush, smile).
  * Taps outside Ruby trigger tap-to-move swimming navigation with target beacon ripples.
- **Accessibility & 120 FPS Performance**:
  * Full WCAG 2.2 AA+ reduced-motion compliance (instant relocation with zero momentum or tilt).
  * Frame-rate independent physics simulation based on delta time.
- **Automated Test Coverage**:
  * Added `test/presentation/mascot_kinematic_controller_test.dart` and updated `test/presentation/pool_simulation_test.dart` (110/110 tests passing, 0 analyzer issues).

---

## [1.7.0] - 2026-11-22 — Stage 2: Subphase 2.1.2 — Natural Idle Animation Rig & Multi-Track Interactive Life-Cycle
### Added
- **Multi-Track Natural Idle Animation Rig (`FloatingRedPandaPainter`, `InteractivePoolView`)**:
  * **Involuntary Blinking**: Realistic 220ms asymmetric eyelid closure envelope running every 3.2 to 6.0 seconds with moist specular highlights.
  * **Spontaneous Ear Twitch**: Damped harmonic flick of the right ear base ($\pm 0.20\text{ rad}$) running every 4.0 to 7.5 seconds.
  * **Smooth Eye-Tracking & Gaze Fixation**: `MouseRegion` cursor-tracking gaze with smooth spherical interpolation (`Offset.lerp`) returning forward when pointer exits.
  * **Affectionate Touch Reaction Pulse**: Interactive tap/stroke response triggering a happy upward eye squint, soft rosy cheek blush, and flared smile curve with smooth exponential decay.
  * **Breathing & Tail Sway**: Continuous sinusoidal chest expansion coupled with multi-joint pendulum tail swaying.
- **Accessibility & 120 FPS Performance**:
  * Zero-allocation animation lifecycle ensuring no GC pressure at 120 FPS.
  * Full WCAG 2.2 AA+ reduced-motion adherence (`MediaQuery.disableAnimationsOf(context)`).
- **Automated Test Coverage**:
  * Added unit and widget tests in `test/presentation/pool_simulation_test.dart` for ear twitching, reaction pulse, eye tracking, mouse hover gestures, and reduced motion.
  * 102/102 test pass rate, 0 analyzer issues.

---

## [1.6.0] - 2026-11-22 — Dynamic Biome Atmospheric Background & Adaptive Ambient Ecosystem
### Added
- **Dynamic Biome Ambient Atmospheric Backdrop**: Integrated living atmospheric background gradients into `ResponsiveHomeShell` across all 3 responsive breakpoints (Compact Mobile, Medium Tablet, and Expanded Desktop Command Center).
- **Smooth 600ms Environmental Transitions**: Ambient gradients smoothly cross-fade when switching biomes or auto-pairing companions using cubic easing (`Curves.easeInOutCubic`), automatically disabling transitions when reduced motion is requested (`MediaQuery.disableAnimationsOf(context)`).
- **Physiological Color-Blending**: Created `_buildBiomeBackgroundDecoration` utilizing `Color.alphaBlend` to harmonize active biome sky gradients and ambient tones with system light/dark theme backgrounds for maximum legibility and contrast compliance.
- **Glassmorphic Surface Integration**: Translucent glass navigation decks, command rails, and floating cards allow the living biome backdrop to gently shine through without compromising WCAG 2.2 AA text contrast.
- **Automated Test Coverage**: Added dedicated test in `test/presentation/responsive_shell_test.dart` verifying dynamic background decoration presence and linear gradient stops, maintaining 100% test pass rate (90/90 tests) and 0 analyzer issues.

---

## [1.5.0] - 2026-11-22 — Custom Beverage Builder Studio & Dynamic Beverage Registry
### Added
- **Dynamic Beverage Registry**: Extended `BeverageType` with dynamic registration (`registerCustom`, `removeCustom`) and dynamic queryability via `allBeverages` and `findById`, enabling user-crafted beverages to seamlessly appear across the entire application (Quick Dock, Pour Studio, Voice Logger, Shortcuts).
- **Custom Beverage Studio (`BeverageCustomizerModal`)**: Built interactive glassmorphic modal studio allowing users to:
  * Name custom beverages with sanitized IDs.
  * Assign physiological categories (Water, Tea, Coffee, Juice, Electrolyte, Dairy, Wellness).
  * Adjust bioavailability hydration index sliders ($0.50 \to 1.50$) with real-time net hydration calculations.
  * Parameterize caffeine ($0 \to 120$ mg/100ml) and electrolyte ($0 \to 150$ mg/100ml) concentrations with automatic diuretic offsetting.
  * Pick fluid theme colors from an 8-color neon Hydro-Glass palette.
  * Instantly craft, register into catalog, and log customized volume with haptics.
- **Quick Dock Integration**: Added "Craft Custom Beverage" action button and dedicated "Custom" tile to the dashboard quick dock in `ResponsiveHomeShell`.
- **Automated Test Coverage**: Added `test/presentation/beverage_customizer_test.dart` bringing the project test suite to 89 passing tests (100% pass rate, 0 analyzer issues).

---

## [1.4.0] - 2026-11-22 — Universal Beverage Carousel in Pour Studio & Showcase Production Documentation
### Added
- **Multi-Beverage Carousel Selector in Interactive Pour Studio**: Integrated horizontal scrolling filter chip carousel in `InteractivePourSheet` allowing users to switch between all 16 handcrafted beverages in real-time while adjusting the drag-to-pour fluid level.
- **Beverage-Aware Pour Logging**: Added `onBeveragePourConfirmed` callback in `InteractivePourSheet` hooked into `AnimalFluidHabitatView` ensuring precise logging of the chosen beverage, its bioavailability index, and corresponding XP rewards.
- **Showcase Production Documentation (`README.md`)**: Authored comprehensive production-grade documentation detailing brand philosophy, architecture topology (Mermaid diagram), 16 beverage science indices, 10 exotic companion silhouettes and custom physics, desktop keyboard accelerators cheat-sheet, Supabase backend schema with strict RLS, and 6-platform CI/CD pipelines.

---

## [1.3.0] - 2026-11-22 — Privacy-First Data Portability, Backup/Restore Engine & Companion Evolution Celebration Modal
### Added
- **Lossless Data Backup & Export Engine**: Engineered `DataBackupService` supporting:
  * Lossless JSON backup archive containing complete profile state, daily goals, user XP, active companions, habit streaks, streak freeze counts, unlocked badges, and full hydration log history.
  * Spreadsheet-compatible RFC 4180 CSV export formatted with entry IDs, ISO timestamps, dates, times, beverage IDs, names, volumes, bioavailability hydration indices, net milliliters, caffeine, and electrolytes for health/clinical reviews.
  * Schema-validated JSON backup restoration with checksums, conflict guards, and instant state rehydration.
- **Data Portability & Backup Modal (`DataBackupModal`)**: Developed glassmorphic modal with instant one-tap copy-to-clipboard for JSON and CSV exports, text-field restore portal with real-time validation, and live telemetry summary (Total Entries, Current Streak, Total XP).
- **Interactive Companion Evolution Celebration Modal (`CompanionEvolutionModal`)**:
  * Rotating 12-second radiant sunburst aura and glowing energy halos behind the companion mascot avatar.
  * Stage mastery perk breakdown, level badge, and cosmetic title banner.
  * Jubilant audio/haptic celebration fanfare (`AudioHapticsService.playGoalCelebration()`).
  * Seamless interactive inspection directly from `HomeScreen` evolution card and `BiomeCompanionSelectorSheet`.
- **Keyboard Shortcut Accelerator**: Registered keybinding `X` to instantly invoke the Data Backup & Portability modal.
- **Automated Test Coverage**: Added `test/core/data_backup_test.dart` bringing the automated test suite to 87 tests (100% pass rate, 0 analyzer issues).

---

## [1.2.0] - 2026-11-22 — Complete 10-Companion Handcrafted Silhouette & Interactive Animation Ecosystem
### Added
- **Full 10-Companion Vector Silhouette Suite**: Handcrafted precise, anatomically tailored bezier vector clipping paths for all 10 companions in `AnimalSilhouettePaths`:
  * `arctic_fox`: Alert seated posture, pointed ears, sweeping curved bushy tail.
  * `emperor_penguin`: Regal standing profile, hydrodynamic flipper wings, webbed base.
  * `bottlenose_dolphin`: Dynamic leaping arch, dorsal fin, rostrum snout, tail flukes.
  * `blue_ringed_octopus`: Bulbous domed mantle with 8 undulating splayed tentacles.
  * `snow_leopard`: Muscular stalking feline spine, rounded alpine ears, iconic thick counterbalancing tail.
  * `sea_otter`, `andean_llama`, `axolotl`, `capybara`, `red_panda`.
- **Species-Specific Interactive Feature Overlays**:
  * **Ollie the Sea Otter**: Swaying emerald kelp forest strands drifting vertically in water, tilted iridescent scallop shell with glowing pearl on chest, button nose and whisker pads.
  * **Luna the Andean Llama**: Woven Aztec geometric collar with 4 dangling pompom tassels swaying in rhythm, fluffy ear tufts, long eyelashes.
  * **Octavia the Blue-Ringed Octopus**: 10 bioluminescent glowing blue rings with deep indigo centers that pulse and flare on tap (`interactionPulse`), horizontal slit pupils.
  * **Echo the Dolphin**: Concentric acoustic sonar rings expanding upward from melon forehead with fading opacity, catchlight eyes, rostrum smile.
  * **Freya the Arctic Fox**: Shimmering Aurora Borealis celestial gradient veil across chest, black ear tips and nose.
  * **Percy the Emperor Penguin**: Radiant golden-yellow auricular neck plumage patches, yellow mandible streak.
  * **Kira the Snow Leopard**: Scattered alpine charcoal rosettes along flank and tail, soft peach nose, ice-blue eyes.
- **Full Regression Test Coverage**: Expanded test suite to 82 tests covering all 10 companions and vector paths (100% pass rate, 0 analyzer issues).

---

## [1.1.0] - 2026-11-22 — Exotic Companions Interactive Animations & Biome Auto-Pairing
### Added
- **Capybara Thermal Onsen Dynamic Experience**: Handcrafted custom floating Yuzu citrus fruits that bob with physics along 64-column liquid surface waves, gentle rising hot spring steam wisps, cozy zen folded head towel with oscillation, and peaceful closed-eye zen expressions.
- **Axolotl Bioluminescent Cenote Interactive Magic**: Handcrafted 6 external feathery branching gills pulsing with electric cyan (`#00E5FF`) and neon magenta (`#FF4081`) glow, floating plankton spores suspended in fluid, glossy catchlight eyes, and rosy cheek blush.
- **Interactive Tap Excitation Physics**: Added decaying `interactionPulse` impulse that dynamically flares species features (e.g. amplifying axolotl gill spread and intensifying citrus wave bobbing) on tactile touch or drink logging.
- **Seamless Biome-Companion Auto Pairing**: Auto-selects native biomes (`thermal_yuzu_onsen` for Capybara, `bioluminescent_cenote` for Axolotl) upon switching companions in `BiomeCompanionSelectorSheet`.
- **Immediate Starter Access**: Unlocked Capybara and Axolotl as zero-XP starter companions alongside Red Panda.
- **Dedicated Interactive Animation Test Suite**: Added `test/presentation/animal_fluid_vessel_painter_test.dart` bringing the total test suite to 76 tests (100% pass rate, 0 analyzer issues).

---

## [1.0.0] - 2026-11-22 — Official Multi-Platform Production Release
### Added
- **Multi-Platform Master CI/CD Pipeline**: Added `.github/workflows/build-all.yml` with manual dispatch inputs (`platforms: all, android, ios, web, windows, macos, linux`), nightly scheduled cron (`0 2 * * *`), quality gates (linting + secret scanning + unit/widget test coverage), parallel matrix builds, and release packaging.
- **Dedicated Platform CI Workflows**: Created standalone targeted pipelines `.github/workflows/android.yml`, `ios.yml`, `web.yml`, `windows.yml`, `macos.yml`, and `linux.yml` with dependency installation and artifact publishing.
- **Automated Release Tag Packaging**: Implemented tag-triggered workflow packaging Android APK/AAB, iOS zipped payload, Windows executable zip, macOS .app archive, Linux tarball, and Web Wasm bundle into GitHub releases.
- **Security & Secret Scanning**: Integrated pre-build secret audits preventing hardcoded tokens or API credentials in repository commits.
- **Repository Collaboration & Governance Assets**: Added `.github/dependabot.yml` for automated dependency updates, `.github/PULL_REQUEST_TEMPLATE.md` enforcing the 12-step governance gate, and structured issue templates for bugs and features.
- **Git Flow Synchronization**: Full alignment of `main`, `develop`, `release/v1.0.0`, and release tag `v1.0.0`.

---

## [0.8.0-subphase-4.1.1] - 2026-11-22
### Added
- **Responsive 3-Breakpoint Adaptive Shell**: Engineered `ResponsiveHomeShell` delivering tailored layouts across Compact (<700px phone), Medium (700px-1100px tablet with `NavigationRail`), and Expanded (>=1100px desktop/web 3-pane command center).
- **Dynamic Theme Engine (4 Distinct Modes)**: Created `ThemeModeNotifier` managing `hydroGlassTheme` (neon cyan bioluminescence and glass borders), OLED `darkTheme`, Day `lightTheme`, and WCAG 2.2 AAA `highContrastTheme` with dynamic brightness and system integration.
- **In-App Theme Switcher**: Built `ThemeSwitcherButton` supporting one-tap cycle and popup menu dropdown theme selection.
- **Multimodal Keyboard Accelerators**: Implemented `AquaWildShortcutsWrapper` intercepting keybindings (`1-9` for instant beverage logging, `Space` for 250ml water, `A` for AI Coach, `R` for Reminders, `B` for Biomes, `P` for Analytics, `G` for Achievements, `T` for theme, `V` for voice, `?` for shortcuts modal).
- **Interactive Keyboard Shortcuts Guide**: Developed `KeyboardShortcutsModal` displaying stylish keycap badges and descriptions for desktop and web keyboard navigation.
- **Natural Language Speech-to-Intent Voice Logger**: Created `VoiceCommandService` parsing natural utterances with automatic unit conversion (oz, l to ml) and beverage alias mapping.
- **Pulsing Voice Logger UI**: Implemented `VoiceCommandModal` featuring an animated microphone visualizer, speech preset chips, real-time intent extraction preview, and instant logging.
- **Automated Responsive, Theme & NLP Test Suite**: Added `test/domain/voice_command_service_test.dart`, `test/presentation/theme_notifier_test.dart`, and `test/presentation/responsive_shell_test.dart` (70 total tests across the project passing, 0 analyzer issues).

---

## [0.7.0-subphase-3.3.1] - 2026-11-22
### Added
- **Production Supabase PostgreSQL Schema**: Created `20261122000000_create_aquawild_schema.sql` defining `profiles`, `hydration_entries`, `user_streaks`, `user_achievements`, and `activity_sessions` with indexing and constraints.
- **Strict Row-Level Security (RLS) Policies**: Enabled RLS and enforced `auth.uid() = user_id` for SELECT, INSERT, UPDATE, and DELETE operations across all 5 tables.
- **Automated Database Triggers**: Implemented `handle_updated_at()` and `handle_new_user()` on `auth.users` automatically provisioning starter companions and streak freezes.
- **TypeScript Deno Edge Functions**: Developed `ai-hydration-coach` (secure serverless OpenAI proxy with fallback) and `sync-health-telemetry` (batch wearable sync).
- **Client Offline-First Sync Queue**: Implemented `SyncQueueItem` and `SupabaseSyncService` managing persistent offline mutations, batch flushing, and conflict resolution.
- **Real-Time Cloud Sync UI**: Created `SyncStatusIndicator` displaying cloud status (`Cloud Synced`, `Syncing...`, `X Pending`) on `HomeScreen`.
- **Automated Sync Engine Test Suite**: Added `test/data/supabase_sync_service_test.dart` and `test/presentation/sync_status_ui_test.dart` (62 total tests passing, 0 analyzer issues).

---

## [0.6.0-subphase-3.2.1] - 2026-11-22
### Added
- **Habit Consistency & Streak Freeze Engine**: Implemented `HydrationStreak` and `GamificationService` supporting continuous daily streak calculation, longest streak records, and streak freeze shields to protect user momentum.
- **Tiered Achievement Badges (12 Badges)**: Created `AchievementBadge` catalog covering habits, circadian dawn intake, electrolyte science, animal bonds, and mythic spirit transcendence with dynamic progress fractions.
- **Limited-Time Seasonal Challenge Quests**: Built `SeasonalChallenge` with live countdown, XP goals, and claimable rewards ("Verdant Spring Rejuvenation").
- **Predictive Dehydration Analytics & Circadian Forecasting**: Developed `PredictiveAnalyticsService` computing 7-day rolling window bars, 24-hour hourly intake curves, predictive End-of-Day intake projections, and dynamic dehydration risk scores.
- **Companion Evolution & Biome Exploration Hub**: Built `BiomeCompanionSelectorSheet` showcasing all 10 companions across 4 evolution stages and allowing ambient travel between the 6 living world biomes.
- **Interactive Streak Pill & Achievements Gallery**: Created `StreakBadgeChip` on the dashboard header and `AchievementsGallerySheet` for habit inspection and badge claims.
- **Automated Gamification & Analytics Test Suite**: Added `test/domain/gamification_test.dart`, `test/domain/predictive_analytics_test.dart`, and `test/presentation/gamification_analytics_ui_test.dart` (57 total tests across the project passing, 0 analyzer issues).

---

## [0.5.0-subphase-3.1.1] - 2026-11-22
### Added
- **OpenAI-Compatible AI Hydration Coach Client**: Implemented `AiCoachService` connecting to any OpenAI-compatible API (`/chat/completions`) with configurable base URL, API key, model selection, prompt sanitization, and structured JSON schema enforcement.
- **Deterministic Offline Clinical Heuristic Fallback**: Added a comprehensive rule-based heuristic advisor generating personalized clinical recommendations tailored to companion personality, circadian time, hydration deficit, and environmental stressors without network dependencies.
- **Dynamic Weather, Heat Index & Altitude Goal Engine**: Built `WeatherCondition` and `WeatherActivityService` calculating perspiration offsets for ambient heat, Steadman heat index, high humidity, and high altitude (>1500m).
- **Physical Workout Sweat Replenishment**: Created `ActivitySession` and `ActivityLoggerModal` computing sweat loss across 8 activities and 4 intensities with automatic +125% target replenishment.
- **Universal Health Platform Bridge**: Added abstract `HealthPlatformService` and deterministic `LocalMockHealthPlatformService` enabling bi-directional health telemetry across Android, iOS, Web, Windows, macOS, and Linux.
- **Circadian Smart Reminder Scheduler**: Implemented `SmartReminderService` and `SmartRemindersSheet` distributing hydration targets into 5 metabolic circadian anchors.
- **Environmental & AI Status Bar**: Created `WeatherActivityBar` on `HomeScreen` offering one-tap access to weather simulation, workout logger, AI coach, and circadian schedule.
- **Automated AI & Environmental Test Suites**: Added `test/domain/weather_activity_test.dart`, `test/domain/ai_coach_service_test.dart`, `test/domain/smart_reminder_test.dart`, and `test/presentation/ai_coach_bar_test.dart` (47 total tests across the project passing, 0 analyzer issues).

---

## [0.4.0-subphase-2.3.1] - 2026-11-22
### Added
- **Real-Time 2D Shallow-Water Wave Column Physics**: Implemented `WaveColumnSolver` running a 64-column spring-damper wave simulation with Hooke restorative force, velocity damping, and Laplacian wave propagation across adjacent liquid columns.
- **Animal Silhouette Vector Paths**: Created `AnimalSilhouettePaths` containing high-precision vector clipping paths for Ruby the Red Panda, Capy the Capybara, Axel the Axolotl, Pip the Sea Otter, and Luna the Andean Llama.
- **Density-Stratified Fluid Vessel Canvas**: Developed `AnimalFluidVesselPainter` rendering dynamic beverage strata sorted by physical density, animated surface waves, specular meniscus highlights, effervescent rising bubbles, and hydro-glass container outlines with ambient glow.
- **Interactive Pour Studio & Custom Keypad**: Built `InteractivePourSheet` allowing fluid drag-to-adjust volume, quick preset pills (150ml, 250ml, 330ml, 500ml), and `CustomNumericKeypadModal` for precise numeric input.
- **Adaptive Audio & Haptics Engine**: Created `AudioHapticsService` delivering tactical haptics and synthesized sound feedback during pouring, splashing, and goal achievement with graceful cross-platform degradation.
- **Automated Fluid Physics & Interaction Test Suite**: Added `test/presentation/wave_solver_test.dart`, `test/presentation/interactive_pour_sheet_test.dart`, and `test/presentation/custom_numeric_keypad_test.dart` (36 total tests across the project passing, 0 analyzer issues).

---

## [0.3.0-subphase-2.2.1] - 2026-11-22
### Added
- **Interactive Top-View Pool Water Physics**: Implemented `PoolWaterSimulationPainter` rendering procedural ceramic pool floor tiles, dual-layer sinusoidal caustic lattices, specular sunlight glints, and interactive expanding ripple rings.
- **Buoyancy Spring-Damper Engine**: Added `WaterRipple` model and harmonic bobbing & rocking tilt physics with impulse response on user touch/tap.
- **Ambient Particles System**: Implemented `PoolParticlesPainter` rendering rising micro-bubbles with specular reflections and blinking starburst glints.
- **Detailed SVG Red Panda Mascot Assembly**: Created `FloatingRedPandaPainter` rendering Ruby the Red Panda reclining in a candy-striped swim ring tube (Coral Red `#FF5252` and Mint Teal `#26A69A`), S-curved ringed tail dipping into the pool, aviator sunglasses with animated specular shine sweep, paw holding a tropical citrus drink with lime wheel garnish, and underwater parallax shadow.
- **Accessible Interactive Pool View**: Created `InteractivePoolView` with screen-reader semantics and full reduced-motion support.
- **Modern-Futuristic Launch Screen**: Updated `LaunchScreen` with top status pill, glassmorphic CTA card, and seamless GoRouter navigation to `/home`.
- **Automated Pool Simulation Test Suite**: Added `test/presentation/pool_simulation_test.dart` and updated `test/smoke_test.dart` (22/22 tests passing, 0 analyzer issues).

---

## [0.2.0-subphase-2.1.1] - 2026-11-22
### Added
- **Beverage Bioavailability Engine**: Added 16 handcrafted beverages with bioavailability factors, caffeine diuretic offsetting, electrolyte metrics, densities, viscosities, and signature color palettes.
- **Exotic Animal & Evolution System**: Registered 10 exotic companions across 4 evolution stages (Hatchling, Explorer, Guardian, Mythic Spirit).
- **Hydration Biomes**: Modeled 6 living biomes with custom ambient colorways, sky gradients, water caustic tints, and native animal associations.
- **Offline-First Persistence**: Created `HydrationRepository` and `LocalHydrationRepository` backed by `SharedPreferences` and in-memory caches.
- **Riverpod 3 State Notifiers**: Implemented `HydrationNotifier`, `AnimalHabitatNotifier`, and `BiomeNotifier` with safe `ref.mounted` asynchronous guards.

---

## [0.1.0-subphase-1.2.1] - 2026-11-22
### Added
- **Multi-Platform Flutter Scaffold**: Generated complete 6-platform codebase for Android, iOS, Web, Windows, macOS, and Linux with package name `com.aquawild.app`.
- **Git Branch Strategy**: Initialized Git repository with `main`, `develop`, and `feature/stage-1-bootstrap` branches.
- **Strict Static Analysis**: Configured strict `analysis_options.yaml` (0 analyzer issues).

---

## [0.1.0-subphase-1.1.1] - 2026-11-22
### Added
- **Antigravity IDE Multi-Agent Ecosystem**: Configured 10 specialized subagents.
- **Workspace Rules & Skills**: Added `AGENTS.md`, `GEMINI.md`, and `.agents/skills/`.
- **Architecture & Governance Blueprint**: Added Stage → Phase → Subphase execution plan, ADRs 001–005, and decision log.
