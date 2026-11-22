# Changelog

All notable changes to the **AquaWild (HydroFauna)** Cross-Platform AI-Powered Hydration Ecosystem are documented in this file.

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
