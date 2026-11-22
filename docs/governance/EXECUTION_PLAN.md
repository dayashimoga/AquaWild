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
| **Stage 3: AI Intelligence, Biometrics, Gamification & Backend** | **Phase 3.1: AI Hydration Coach, Weather/Activity Engine & Health Integrations** | **Subphase 3.1.1** | OpenAI-Compatible AI Hydration Advisor, Dynamic Weather/Activity/Altitude Goal Calculator, Smart Circadian Reminders, Apple HealthKit / Google Health Connect Bridges & Electrolyte Balance | High | Medium | 35 min | ✅ **COMPLETED (Awaiting Approval Gate)** |
| Stage 3 | **Phase 3.2: Gamification, Habit Engine, Biomes, Evolution & Predictive Analytics** | **Subphase 3.2.1** | Habit-Building Engine, XP/Leveling, Streaks, Seasonal Challenges, Animal Evolution Unlock System, Interactive World Biomes & Predictive Analytics Reports | Medium | Low | 35 min | ⏳ Pending |
| Stage 3 | **Phase 3.3: Supabase Backend Schema, Row-Level Security, Realtime & Edge Functions** | **Subphase 3.3.1** | Production Supabase PostgreSQL Migrations, RLS Policies, Realtime Sync Queue, Edge Functions (`ai-hydration-coach`, `weather-hydration-goal`) & Security Audit | Medium | Medium | 30 min | ⏳ Pending |
| **Stage 4: Multi-Platform UX, Accessibility & CI/CD Release Automation** | **Phase 4.1: Responsive Cross-Platform Shell, Multimodal Accessibility & Dynamic Themes** | **Subphase 4.1.1** | Adaptive Mobile/Tablet/Desktop/Web Layouts, Light/Dark/Hydro-Glass/High-Contrast Themes, Voice Command Logging, Full Keyboard Navigation, Screen Reader Semantics & Reduced-Motion Mode | Medium | Low | 35 min | ⏳ Pending |
| Stage 4 | **Phase 4.2: Production GitHub Actions Multi-Platform CI/CD & Full Verification Suite** | **Subphase 4.2.1** | 7 GitHub Actions Workflows (`build-all.yml` with selective platform inputs + Android, iOS, Web, Windows, macOS, Linux workflows), Security/Coverage Gates & End-to-End Integration Suite | Medium | Low | 30 min | ⏳ Pending |

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
