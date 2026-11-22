# AquaWild (HydroFauna) — Master Stage → Phase → Subphase Execution Plan

> **Execution Governance Rule**: Only **ONE** subphase may be active at any time. Every subphase follows the 12-Step Mandatory Execution Protocol and stops at the **Approval Gate** before advancing.

---

## Master Execution Hierarchy & Live Status Tracker

| Stage | Phase | Subphase | Capability / Component / Verifiable Increment | Complexity | Risk | Max Time | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Stage 1: Governance, Architecture & Foundation** | **Phase 1.1: Antigravity Multi-Agent & Architecture Blueprint** | **Subphase 1.1.1** | Antigravity IDE Multi-Agent Ecosystem, Global Engineering Contract, Competitive Gap Analysis, System Architecture, ADRs 001–005 & Governance Registry | Medium | Low | 25 min | ✅ **COMPLETED (Approved)** |
| Stage 1 | **Phase 1.2: Universal Cross-Platform Flutter Workspace & DevContainer Bootstrap** | **Subphase 1.2.1** | Git Repository Strategy (`main`, `develop`, `feature/stage-1-bootstrap`), Flutter 6-Platform Scaffold (Android, iOS, Web, Windows, macOS, Linux), Strict Linting, Docker & DevContainer Setup | Medium | Low | 30 min | ✅ **COMPLETED (Approved)** |
| **Stage 2: Core Domain, Fluid Physics & Launch Experience** | **Phase 2.1: Hydration Science Domain, Exotic Animal Catalog & Biome Models** | **Subphase 2.1.1** | Beverage Bio-Availability Engine (16+ Beverages), 10 Exotic Animals (Red Panda, Capybara, Axolotl, Otter, Llama, Fox, Penguin, Dolphin, Octopus, Snow Leopard), Evolution Stages, Hydration Biomes & Riverpod Offline-First State | Medium | Low | 30 min | ✅ **COMPLETED (Approved)** |
| Stage 2 | **Phase 2.2: Launch Screen — Animated SVG Red Panda Floating Pool Physics Engine** | **Subphase 2.2.1** | Interactive Top-View Pool Water Shader/Canvas (Caustics, Procedural Waves, Ripples, Parallax Shadows, Particles) + Detailed Animated SVG Red Panda on Floating Tube + Seamless Hero Transition | High | Medium | 35 min | ✅ **COMPLETED (Approved)** |
| Stage 2 | **Phase 2.3: Animal Silhouette Fluid Simulation, Multi-Drink Stratification & Micro-Interactions** | **Subphase 2.3.1** | Real-Time 2D Shallow-Water Wave & Meniscus Solver Inside Exotic Animal Silhouettes, Multi-Beverage Colored Density Layers, Splash Particles, Pour Slider, Adaptive Haptics & Synthesized Audio | High | Medium | 40 min | ✅ **COMPLETED (Approved)** |
| **Stage 3: AI Intelligence, Biometrics, Gamification & Backend** | **Phase 3.1: AI Hydration Coach, Weather/Activity Engine & Health Integrations** | **Subphase 3.1.1** | OpenAI-Compatible AI Hydration Advisor, Dynamic Weather/Activity/Altitude Goal Calculator, Smart Circadian Reminders, Apple HealthKit / Google Health Connect Bridges & Electrolyte Balance | High | Medium | 35 min | ✅ **COMPLETED (Approved)** |
| Stage 3 | **Phase 3.2: Gamification, Habit Engine, Biomes, Evolution & Predictive Analytics** | **Subphase 3.2.1** | Habit-Building Engine, XP/Leveling, Streaks, Seasonal Challenges, Animal Evolution Unlock System, Interactive World Biomes & Predictive Analytics Reports | Medium | Low | 35 min | ✅ **COMPLETED (Approved)** |
| Stage 3 | **Phase 3.3: Supabase Backend Schema, Row-Level Security, Realtime & Edge Functions** | **Subphase 3.3.1** | Production Supabase PostgreSQL Migrations, RLS Policies, Realtime Sync Queue, Edge Functions (`ai-hydration-coach`, `sync-health-telemetry`) & Security Audit | Medium | Medium | 30 min | ✅ **COMPLETED (Approved)** |
| **Stage 4: Multi-Platform UX, Accessibility & CI/CD Release Automation** | **Phase 4.1: Responsive Cross-Platform Shell, Multimodal Accessibility & Dynamic Themes** | **Subphase 4.1.1** | Adaptive Mobile/Tablet/Desktop/Web Layouts, Light/Dark/Hydro-Glass/High-Contrast Themes, Voice Command Logging, Full Keyboard Navigation, Screen Reader Semantics & Reduced-Motion Mode | Medium | Low | 35 min | ✅ **COMPLETED (Approved)** |
| Stage 4 | **Phase 4.2: Production GitHub Actions Multi-Platform CI/CD & Full Verification Suite** | **Subphase 4.2.1** | 7 GitHub Actions Workflows (`build-all.yml` with selective platform inputs + Android, iOS, Web, Windows, macOS, Linux workflows), Security/Coverage Gates & End-to-End Integration Suite | Medium | Low | 30 min | ✅ **COMPLETED (Approved)** |
| **Stage 5: Live Production Enhancements & Ecosystem Expansions** | **Releases v1.1.0 – v1.6.0** | **Continuous Post-Launch Polish** | Species-specific interactive physics (10 companions), Lossless data backup/export, Companion evolution celebration, Universal Pour carousel, Custom Beverage Studio, Dynamic Biome Ambient Backgrounds | High | Low | Ongoing | ✅ **COMPLETED (Release v1.6.0)** |

---

## Detailed Subphase Governance Specifications

### Subphase 2.2.1 — Launch Screen: Animated SVG Red Panda Floating Pool Physics Engine
- **Complexity**: High
- **Dependencies**: Subphase 2.1.1
- **Deliverables**:
  - `lib/src/presentation/widgets/pool/ripple_emitter.dart`: Decelerating propagation physics and amplitude attenuation calculations for water ripples.
  - `lib/src/presentation/widgets/pool/pool_water_simulation_painter.dart`: Hardware-accelerated top-view pool canvas rendering underwater ceramic tile grid with procedural wave distortion, dual-layer sinusoidal caustics, and dynamic interactive ripples.
  - `lib/src/presentation/widgets/pool/pool_particles_painter.dart`: Rising micro-bubbles with specular reflections and starburst glints.
  - `lib/src/presentation/widgets/pool/floating_red_panda_painter.dart`: Handcrafted multi-layered vector SVG assembly featuring Ruby the Red Panda reclining in an inflatable candy-striped swim ring (Coral Red `#FF5252` and Mint Teal `#26A69A`), ringed tail dipping in the pool, gold aviator sunglasses with animated light sweep, paw holding a tropical citrus drink, and underwater parallax shadow.
  - `lib/src/presentation/widgets/pool/interactive_pool_view.dart`: Gesture-driven interactive pool widget responding to tap/pan with splash impulses and ambient breathing ripples, with full reduced-motion accessibility.
  - `lib/src/presentation/screens/launch/launch_screen.dart`: Modern-futuristic glassmorphic launch screen with status pill, "Dive Into Habitat" button, and GoRouter transition to `/home`.
  - Automated test suites: `test/presentation/pool_simulation_test.dart` and updated `test/smoke_test.dart` (22/22 tests passing, 0 analyzer issues).
- **Validation Criteria**: Zero analyzer warnings (`No issues found`); 100% test pass rate (22/22 tests passed); 60/120 FPS paint efficiency; screen-reader semantics validated.
- **Maximum Execution Time**: 35 minutes
- **Risk Level**: Medium
- **Rollback Strategy**: `git reset --hard` to previous commit on `main`.
- **Success Metrics**: Interactive ripple response on click/tap/drag, 120 FPS fluid physics, and WCAG AA accessibility compliance.

---

### Subphase 2.3.1 — Animal Silhouette Fluid Simulation, Multi-Drink Stratification & Micro-Interactions
- **Complexity**: High
- **Dependencies**: Subphase 2.2.1, Subphase 2.1.1
- **Deliverables**:
  - `lib/src/presentation/widgets/animal_fluid/wave_column_solver.dart`: Real-time 1D/2D coupled shallow-water wave physics solver (64 columns, Hooke spring constant, damping, Laplacian neighbor spread).
  - `lib/src/presentation/widgets/animal_fluid/animal_silhouette_paths.dart`: Handcrafted multi-curve vector paths for Red Panda, Capybara, Axolotl, Sea Otter, and Andean Llama.
  - `lib/src/presentation/widgets/animal_fluid/animal_fluid_vessel_painter.dart`: Hardware-accelerated canvas painter rendering dynamic density-stratified beverage layers, real-time wave surface deformation, meniscus lighting highlights, rising bubbles, splash droplets, and hydro-glass container outline.
  - `lib/src/presentation/widgets/animal_fluid/animal_fluid_habitat_view.dart`: Gesture-driven fluid vessel container with drag/tap splash physics, status HUD, quick beverage dock, and full reduced-motion accessibility.
  - `lib/src/presentation/widgets/animal_fluid/interactive_pour_sheet.dart`: Premium modal pour studio featuring animated fluid cup drag-to-adjust, quick volume preset pills (150ml, 250ml, 330ml, 500ml), and numeric keypad trigger.
  - `lib/src/presentation/widgets/animal_fluid/custom_numeric_keypad_modal.dart`: Tactile glassmorphic keypad with instant volume preview and backspace handling.
  - `lib/src/core/services/audio_haptics_service.dart`: Adaptive haptic feedback and synthesized sound effects for pour, splash, and goal reach.
  - Automated test suites: `test/presentation/wave_solver_test.dart`, `test/presentation/interactive_pour_sheet_test.dart`, `test/presentation/custom_numeric_keypad_test.dart`, `test/presentation/hydration_controller_test.dart`, and `test/smoke_test.dart` (36 total tests across the suite passing, 0 analyzer issues).
- **Validation Criteria**: Zero analyzer warnings; 100% test pass rate; < 8.3ms per-frame budget; screen-reader semantics validated; reduced-motion fallback supported.
- **Maximum Execution Time**: 40 minutes
- **Risk Level**: Medium
- **Rollback Strategy**: `git reset --hard` to previous commit on `main`.
- **Success Metrics**: Realistic density-sorted sloshing fluids, tactile pour sheet interaction, and responsive multi-platform layout.

---

### Subphase 3.1.1 — AI Hydration Coach, Weather/Activity Engine & Health Integrations
- **Complexity**: High
- **Dependencies**: Subphase 2.3.1, Subphase 2.1.1
- **Deliverables**:
  - `lib/src/domain/models/weather_condition.dart`: Ambient heat, humidity, UV, altitude calculations, and Rothfusz heat index estimation.
  - `lib/src/domain/models/activity_session.dart`: Workout types (Running, Cycling, Swimming, HIIT, Walking, Strength, Yoga), duration, intensity, sweat loss rate, and replenishment factor.
  - `lib/src/domain/models/ai_recommendation.dart`: AI advice model with headline, companion message, suggested volume, beverage recommendation, urgency badge, and reasoning tags.
  - `lib/src/domain/models/smart_reminder.dart`: Circadian schedule anchor model with TimeOfDay, category, target volume, and status.
  - `lib/src/core/services/ai_coach_service.dart`: OpenAI-compatible `/chat/completions` client with JSON schema enforcement, prompt sanitization, custom endpoint configuration, and deterministic offline clinical heuristic fallback.
  - `lib/src/core/services/weather_activity_service.dart`: Comprehensive hydration target formula combining baseline requirement, heat/humidity/altitude offsets, and workout sweat compensation.
  - `lib/src/core/services/health_platform_service.dart`: Cross-platform abstract health interface (`HealthPlatformService`) with `LocalMockHealthPlatformService` for deterministic execution across all 6 platforms.
  - `lib/src/core/services/smart_reminder_service.dart`: Circadian schedule builder generating 5 metabolic anchor reminders aligned with waking hours.
  - `lib/src/presentation/controllers/ai_coach_controller.dart`: Riverpod 3 `Notifier<AiCoachState>` managing advice fetching, provider configuration, and state.
  - `lib/src/presentation/controllers/weather_activity_controller.dart`: Riverpod 3 `Notifier<WeatherActivityState>` managing environmental conditions and workout sessions.
  - `lib/src/presentation/widgets/ai/ai_coach_sheet.dart`: Modern-futuristic glassmorphic AI coach dialogue sheet with companion avatar, advice card, quick-log action, and provider settings.
  - `lib/src/presentation/widgets/environmental/weather_activity_bar.dart`: Status HUD bar displaying weather impact, workout status, AI coach trigger, and reminders.
  - `lib/src/presentation/widgets/environmental/activity_logger_modal.dart`: Tactile workout logger modal with activity chips, duration slider, and sweat preview.
  - `lib/src/presentation/widgets/reminders/smart_reminders_sheet.dart`: Circadian schedule timeline sheet with completion tracking and one-tap logging.
  - Automated test suites: `test/domain/weather_activity_test.dart`, `test/domain/ai_coach_service_test.dart`, `test/domain/smart_reminder_test.dart`, `test/presentation/ai_coach_bar_test.dart` (47 total tests across the project passing, 0 analyzer issues).
- **Validation Criteria**: Zero analyzer warnings; 100% test pass rate; resilient offline fallback; WCAG 2.2 AA+ contrast.
- **Maximum Execution Time**: 35 minutes
- **Risk Level**: Medium
- **Rollback Strategy**: `git reset --hard` to previous commit on `main`.
- **Success Metrics**: Personalized companion guidance, dynamic weather/workout target adjustments, circadian schedule generation, and 0 compiler warnings.

---

### Subphase 3.2.1 — Gamification, Habit Engine, Biomes, Evolution & Predictive Analytics
- **Complexity**: Medium
- **Dependencies**: Subphase 3.1.1, Subphase 2.1.1
- **Deliverables**:
  - `lib/src/domain/models/hydration_streak.dart`: Habit streak tracking, longevity records, and streak freeze protection.
  - `lib/src/domain/models/achievement_badge.dart`: 12 tiered badges with categories, XP rewards, and dynamic progress fraction.
  - `lib/src/domain/models/seasonal_challenge.dart`: Limited-time community quest with countdown, XP goal, and claimable reward.
  - `lib/src/domain/models/predictive_analytics.dart`: Daily summaries, 24h circadian hourly buckets, and dehydration risk metric.
  - `lib/src/core/services/gamification_service.dart`: Evaluates streaks, streak freeze deployment, and badge unlocking.
  - `lib/src/core/services/predictive_analytics_service.dart`: Aggregates 7-day rolling window, hourly circadian curves, and EOD predictive forecast.
  - `lib/src/presentation/controllers/gamification_controller.dart`: Riverpod 3 notifier managing streaks, achievements, and seasonal quests.
  - `lib/src/presentation/controllers/analytics_controller.dart`: Riverpod 3 notifier managing rolling analytics and risk reports.
  - `lib/src/presentation/widgets/gamification/streak_badge_chip.dart`: Interactive flame streak pill on dashboard header.
  - `lib/src/presentation/widgets/gamification/achievements_gallery_sheet.dart`: Modal showcase for streak stats, seasonal quest, and badge gallery.
  - `lib/src/presentation/widgets/biomes/biome_companion_selector_sheet.dart`: Interactive companion evolution viewer and living biome switcher.
  - `lib/src/presentation/widgets/analytics/predictive_analytics_sheet.dart`: Analytics command center with risk meter, 7-day bar chart, and hourly curve.
  - Automated test suites: `test/domain/gamification_test.dart`, `test/domain/predictive_analytics_test.dart`, `test/presentation/gamification_analytics_ui_test.dart` (57 total tests passing, 0 analyzer issues).
- **Validation Criteria**: Zero analyzer warnings; 100% test pass rate; WCAG 2.2 AA+ contrast.
- **Maximum Execution Time**: 35 minutes
- **Risk Level**: Low
- **Rollback Strategy**: `git reset --hard` to previous commit on `main`.
- **Success Metrics**: Multi-tier gamification motivation, streak freeze resilience, interactive biome exploration, and predictive dehydration forecasting.

---

### Subphase 3.3.1 — Supabase Backend Schema, Row-Level Security, Realtime & Edge Functions
- **Complexity**: Medium
- **Dependencies**: Subphase 3.2.1, Subphase 3.1.1
- **Deliverables**:
  - `supabase/migrations/20261122000000_create_aquawild_schema.sql`: Complete PostgreSQL schema defining `profiles`, `hydration_entries`, `user_streaks`, `user_achievements`, and `activity_sessions` with automated `updated_at` and `on_auth_user_created` provisioning triggers.
  - Strict Row-Level Security (RLS) policies on all tables enforcing `auth.uid() = user_id` for SELECT, INSERT, UPDATE, DELETE.
  - `supabase/functions/ai-hydration-coach/index.ts`: TypeScript Deno serverless edge function proxying OpenAI/LLM requests with prompt sanitization, rate limiting, and fallback.
  - `supabase/functions/sync-health-telemetry/index.ts`: TypeScript Deno edge function for batch ingestion of fitness tracker telemetry.
  - `supabase/config.toml`: Project and port settings.
  - `lib/src/domain/models/sync_queue_item.dart`: Offline mutation queue model with JSON serialization and retry tracking.
  - `lib/src/core/services/supabase_sync_service.dart`: Offline-first synchronization service with local queue management, batch flushing, and conflict resolution.
  - `lib/src/presentation/controllers/sync_controller.dart`: Riverpod 3 notifier coordinating sync states (`synced`, `syncing`, `offlinePending`, `error`).
  - `lib/src/presentation/widgets/sync/sync_status_indicator.dart`: Live cloud sync status pill embedded on `HomeScreen`.
  - Automated test suites: `test/data/supabase_sync_service_test.dart` and `test/presentation/sync_status_ui_test.dart` (62 total tests passing, 0 analyzer issues).
- **Validation Criteria**: Zero analyzer warnings; 100% test pass rate; strict RLS on all tables; offline queue persistence verified.
- **Maximum Execution Time**: 30 minutes
- **Risk Level**: Medium
- **Rollback Strategy**: `git reset --hard` to previous commit on `main`.
- **Success Metrics**: Verified PostgreSQL schema with zero exposed cross-user data, functional offline queue flushing, and seamless cloud indicator UX.


---

### Subphase 4.1.1 — Responsive Cross-Platform Shell, Multimodal Accessibility & Dynamic Themes
- **Complexity**: Medium
- **Dependencies**: Subphase 3.3.1, Subphase 2.3.1
- **Deliverables**:
  - `lib/src/core/theme/theme_mode_notifier.dart`: Riverpod 3 `Notifier<AppThemeMode>` supporting `hydroGlass`, `dark`, `light`, `highContrast`, and `system` modes with dynamic brightness resolution.
  - `lib/src/core/theme/app_theme.dart`: Flagship `hydroGlassTheme` with frosted borders, glass cards, and neon cyan bioluminescence alongside Dark, Light, and High Contrast WCAG AAA themes.
  - `lib/src/presentation/widgets/theme/theme_switcher_button.dart`: Quick-cycle and dropdown selection popup menu for seamless in-app theme switching.
  - `lib/src/core/services/voice_command_service.dart`: Speech-to-intent natural language regex/heuristic parser converting utterances (e.g. "Drank 350ml green tea", "16 oz water") into structured hydration entries.
  - `lib/src/presentation/widgets/voice/voice_command_modal.dart`: Glassmorphic bottom sheet with pulsing microphone visualizer, speech preset chips, auto-parse preview, and instant drink logging.
  - `lib/src/presentation/widgets/shortcuts/keyboard_shortcuts_modal.dart`: Stylized keycap reference dialog displaying desktop keyboard accelerators (`1-9`, `Space`, `A`, `R`, `B`, `P`, `G`, `T`, `V`, `?`).
  - `lib/src/presentation/widgets/shortcuts/aqua_wild_shortcuts_wrapper.dart`: Global `CallbackShortcuts` wrapper intercepting key events for rapid logging, navigation, and modal triggers.
  - `lib/src/presentation/screens/home/responsive_home_shell.dart`: Adaptive cross-platform shell rendering Compact Mobile (<700px), Medium Tablet (700px-1100px) with `NavigationRail`, and Expanded Desktop (>=1100px) 3-column command center.
  - Refactored `lib/src/presentation/screens/home/home_screen.dart` into `AquaWildShortcutsWrapper` + `ResponsiveHomeShell`.
  - Automated test suites: `test/domain/voice_command_service_test.dart`, `test/presentation/theme_notifier_test.dart`, `test/presentation/responsive_shell_test.dart` (70 total tests passing, 0 analyzer issues).
- **Validation Criteria**: Zero analyzer warnings; 100% test pass rate; WCAG 2.2 AAA contrast; fluid responsive resizing from 320px to 4K.
- **Maximum Execution Time**: 35 minutes
- **Risk Level**: Low
- **Rollback Strategy**: `git reset --hard` to previous commit on `main`.
- **Success Metrics**: Seamless 3-breakpoint adaptive layouts, instant theme transitions, natural language voice parsing, and fully keyboard-traversable navigation.


---

### Subphase 4.2.1 — Production GitHub Actions Multi-Platform CI/CD & Final Verification Suite
- **Complexity**: Medium
- **Dependencies**: Subphase 4.1.1, Subphase 1.2.1
- **Deliverables**:
  - `.github/workflows/build-all.yml`: Master CI/CD orchestrator with `workflow_dispatch` selective platform inputs (`all`, `android`, `ios`, `web`, `windows`, `macos`, `linux`), nightly scheduled cron (`0 2 * * *`), quality gates (linting + secret scanning + test coverage), parallel matrix platform builds, artifact uploads, and GitHub release packaging.
  - `.github/workflows/android.yml`: Targeted Android CI building APK and release AppBundle with automated testing.
  - `.github/workflows/ios.yml`: Targeted iOS CI running on macOS runner generating unsigned release payload.
  - `.github/workflows/web.yml`: Targeted Web CI building WebAssembly (Wasm) and HTML5 CanvasKit bundles.
  - `.github/workflows/windows.yml`: Targeted Windows CI running on `windows-latest` packaging release x64 zip archives.
  - `.github/workflows/macos.yml`: Targeted macOS CI running on `macos-latest` packaging `AquaWild.app` application archives.
  - `.github/workflows/linux.yml`: Targeted Linux CI on `ubuntu-latest` with GTK3 toolchain packaging release tarballs.
  - `.github/dependabot.yml`: Automated weekly dependency audits for GitHub Actions and Pub packages.
  - `.github/PULL_REQUEST_TEMPLATE.md`: Production pull request template enforcing multi-agent role ownership and the 12-step governance protocol.
  - `.github/ISSUE_TEMPLATE/bug_report.md` & `feature_request.md`: Structured issue templates for community engagement and bug triage.
  - Git flow branches (`main`, `develop`, `feature/*`, `release/*`, `hotfix/*`) and release tag `v1.0.0` synchronized.
  - Full project test suite passing with 100% success (70/70 tests) and zero static analysis warnings.
- **Validation Criteria**: Valid workflow YAML syntax; 100% test pass rate; zero analyzer warnings; comprehensive build matrix and packaging artifacts.
- **Maximum Execution Time**: 30 minutes
- **Risk Level**: Low
- **Rollback Strategy**: `git reset --hard` to previous commit on `main`.
- **Success Metrics**: Fully automated cross-platform CI/CD pipeline covering all 6 target platforms, automated artifact distribution, and zero manual deployment overhead.

---

### Post-Release Enhancement 5 — Custom Beverage Builder Studio & Dynamic Beverage Registry (v1.5.0)
- **Status**: Completed (100% tests passing, 89/89 tests, 0 analyzer issues)
- **Deliverables**:
  - `lib/src/domain/models/beverage_type.dart`: Dynamic custom beverage registration (`registerCustom`, `removeCustom`) and dynamic `allBeverages` getter.
  - `lib/src/presentation/widgets/beverages/beverage_customizer_modal.dart`: Interactive modal studio for parameterizing custom drink recipes (name, category, bioavailability, caffeine, electrolytes, color palette, volume).
  - `lib/src/presentation/screens/home/responsive_home_shell.dart`: Added "Craft Custom" icon and quick dock tile.
  - `test/presentation/beverage_customizer_test.dart`: Complete unit & widget test suite for custom beverage crafting and registration.

---

### Post-Release Enhancement 4 — Universal Beverage Carousel in Pour Studio & Showcase Production Documentation (v1.4.0)
- **Status**: Completed (100% tests passing, 87/87 tests, 0 analyzer issues)
- **Deliverables**:
  - `lib/src/presentation/widgets/animal_fluid/interactive_pour_sheet.dart`: Multi-beverage horizontal carousel selector and beverage-specific pour confirmation callback.
  - `lib/src/presentation/widgets/animal_fluid/animal_fluid_habitat_view.dart`: Wired `onBeveragePourConfirmed` to log the dynamically selected beverage.
  - `README.md`: Complete production documentation package with system topology, keyboard shortcuts, and platform matrix.

---

### Post-Release Enhancement 3 — Privacy-First Data Portability, Backup/Restore Engine & Companion Evolution Celebration Modal (v1.3.0)
- **Status**: Completed (100% tests passing, 87/87 tests, 0 analyzer issues)
- **Deliverables**:
  - `lib/src/core/services/data_backup_service.dart`: Lossless JSON archive generator, RFC 4180 CSV spreadsheet exporter, and backup restore validator.
  - `lib/src/presentation/widgets/backup/data_backup_modal.dart`: Glassmorphic export/restore UI with one-tap clipboard copy and telemetry summaries.
  - `lib/src/presentation/widgets/biomes/companion_evolution_modal.dart`: Interactive evolution celebration modal with rotating sunburst aura, perk showcase, and haptic fanfare.
  - `lib/src/presentation/widgets/shortcuts/aqua_wild_shortcuts_wrapper.dart` & `keyboard_shortcuts_modal.dart`: Keybinding `X` registered for backup.
  - `test/core/data_backup_test.dart`: Complete unit and widget test suite for data portability and evolution modals.

---

### Post-Release Enhancement 2 — Complete 10-Companion Handcrafted Silhouette & Interactive Animation Ecosystem (v1.2.0)
- **Status**: Completed (100% tests passing, 82/82 tests, 0 analyzer issues)
- **Deliverables**:
  - `lib/src/presentation/widgets/animal_fluid/animal_silhouette_paths.dart`: Handcrafted vector silhouette paths for all 10 companions (`red_panda`, `capybara`, `axolotl`, `sea_otter`, `andean_llama`, `arctic_fox`, `emperor_penguin`, `bottlenose_dolphin`, `blue_ringed_octopus`, `snow_leopard`).
  - `lib/src/presentation/widgets/animal_fluid/animal_fluid_vessel_painter.dart`: Handcrafted interactive species features and physics for all 10 companions (sea otter kelp & pearl shell, llama Aztec collar & tassels, octopus glowing rings, dolphin acoustic sonar, arctic fox aurora veil, penguin golden plumage, snow leopard rosettes).
  - `test/presentation/animal_fluid_vessel_painter_test.dart`: Complete test suite verifying rendering, reduced-motion accessibility, and vector path validity for all 10 companions.

---

### Post-Release Enhancement 1 — Exotic Companions Interactive Animations & Biome Auto-Pairing (v1.1.0)
- **Status**: Completed (100% tests passing, 76/76 tests, 0 analyzer issues)
- **Deliverables**:
  - `lib/src/presentation/widgets/animal_fluid/animal_fluid_vessel_painter.dart`: Custom species overlays for Cappy the Capybara (floating buoyant yuzu citrus fruits, thermal onsen steam wisps, oscillating head towel, zen eyes) and Lottie the Axolotl (6 feathery branching gills with electric cyan/magenta glow, drifting ocean spores, glossy eyes, blush).
  - `lib/src/presentation/widgets/animal_fluid/animal_fluid_habitat_view.dart`: Integrated tactile `_interactionPulse` decaying variable hooked into vessel tap gestures and painter.
  - `lib/src/presentation/widgets/biomes/biome_companion_selector_sheet.dart`: Biome auto-switching on companion selection.
  - `lib/src/domain/models/exotic_animal.dart`: Unlocked Capybara and Axolotl as zero-XP starter companions.
  - `test/presentation/animal_fluid_vessel_painter_test.dart`: Complete regression and unit test suite for interactive animal animations.
