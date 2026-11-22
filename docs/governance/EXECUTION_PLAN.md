# AquaWild (HydroFauna) — Master Stage → Phase → Subphase Execution Plan

> **Execution Governance Rule**: Only **ONE** subphase may be active at any time. Every subphase follows the 12-Step Mandatory Execution Protocol and stops at the **Approval Gate** before advancing.

---

## Master Execution Hierarchy & Live Status Tracker

| Stage | Phase | Subphase | Capability / Component / Verifiable Increment | Complexity | Risk | Max Time | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Stage 1: Governance, Architecture & Foundation** | **Phase 1.1: Antigravity Multi-Agent & Architecture Blueprint** | **Subphase 1.1.1** | Antigravity IDE Multi-Agent Ecosystem, Global Engineering Contract, Competitive Gap Analysis, System Architecture, ADRs 001–005 & Governance Registry | Medium | Low | 25 min | ✅ **COMPLETED (Awaiting Approval Gate)** |
| Stage 1 | **Phase 1.2: Universal Cross-Platform Flutter Workspace & DevContainer Bootstrap** | **Subphase 1.2.1** | Git Repository Strategy (`main`, `develop`, `feature/*`, `release/*`, `hotfix/*`), Flutter 6-Platform Scaffold (Android, iOS, Web, Windows, macOS, Linux), Strict Linting, Docker & DevContainer Setup | Medium | Low | 30 min | ⏳ Pending |
| **Stage 2: Core Domain, Fluid Physics & Launch Experience** | **Phase 2.1: Hydration Science Domain, Exotic Animal Catalog & Biome Models** | **Subphase 2.1.1** | Beverage Bio-Availability Engine, 10 Exotic Animals (Red Panda, Capybara, Axolotl, Otter, Llama, Fox, Penguin, Dolphin, Octopus, Snow Leopard), Evolution Stages, Hydration Biomes & Riverpod Offline-First State | Medium | Low | 30 min | ⏳ Pending |
| Stage 2 | **Phase 2.2: Launch Screen — Animated SVG Red Panda Floating Pool Physics Engine** | **Subphase 2.2.1** | Interactive Top-View Pool Water Shader/Canvas (Caustics, Procedural Waves, Ripples, Parallax Shadows, Particles) + Detailed Animated SVG Red Panda on Floating Tube + Seamless Hero Transition | High | Medium | 35 min | ⏳ Pending |
| Stage 2 | **Phase 2.3: Animal Silhouette Fluid Simulation, Multi-Drink Stratification & Micro-Interactions** | **Subphase 2.3.1** | Real-Time 2D Shallow-Water Wave & Meniscus Solver Inside Exotic Animal Silhouettes, Multi-Beverage Colored Density Layers, Splash Particles, Pour Slider, Adaptive Haptics & Synthesized Audio | High | Medium | 40 min | ⏳ Pending |
| **Stage 3: AI Intelligence, Biometrics, Gamification & Backend** | **Phase 3.1: AI Hydration Coach, Weather/Activity Engine & Health Integrations** | **Subphase 3.1.1** | OpenAI-Compatible AI Hydration Advisor, Dynamic Weather/Activity/Altitude Goal Calculator, Smart Circadian Reminders, Apple HealthKit / Google Health Connect Bridges & Electrolyte Balance | High | Medium | 35 min | ⏳ Pending |
| Stage 3 | **Phase 3.2: Gamification, Habit Engine, Biomes, Evolution & Predictive Analytics** | **Subphase 3.2.1** | Habit-Building Engine, XP/Leveling, Streaks, Seasonal Challenges, Animal Evolution Unlock System, Interactive World Biomes & Predictive Analytics Reports | Medium | Low | 35 min | ⏳ Pending |
| Stage 3 | **Phase 3.3: Supabase Backend Schema, Row-Level Security, Realtime & Edge Functions** | **Subphase 3.3.1** | Production Supabase PostgreSQL Migrations, RLS Policies, Realtime Sync Queue, Edge Functions (`ai-hydration-coach`, `weather-hydration-goal`) & Security Audit | Medium | Medium | 30 min | ⏳ Pending |
| **Stage 4: Multi-Platform UX, Accessibility & CI/CD Release Automation** | **Phase 4.1: Responsive Cross-Platform Shell, Multimodal Accessibility & Dynamic Themes** | **Subphase 4.1.1** | Adaptive Mobile/Tablet/Desktop/Web Layouts, Light/Dark/Hydro-Glass/High-Contrast Themes, Voice Command Logging, Full Keyboard Navigation, Screen Reader Semantics & Reduced-Motion Mode | Medium | Low | 35 min | ⏳ Pending |
| Stage 4 | **Phase 4.2: Production GitHub Actions Multi-Platform CI/CD & Full Verification Suite** | **Subphase 4.2.1** | 7 GitHub Actions Workflows (`build-all.yml` with selective platform inputs + Android, iOS, Web, Windows, macOS, Linux workflows), Security/Coverage Gates & End-to-End Integration Suite | Medium | Low | 30 min | ⏳ Pending |

---

## Detailed Subphase Governance Specifications

### Subphase 1.1.1 — Antigravity Multi-Agent Ecosystem, Global Engineering Contract & Architecture Blueprint
- **Complexity**: Medium
- **Dependencies**: None (Root foundation)
- **Deliverables**:
  - `AGENTS.md` and `GEMINI.md` workspace rules
  - 10 specialized subagents registered (`solution-architect`, `product-agent`, `ux-ui-agent`, `animation-agent`, `backend-agent`, `mobile-agent`, `desktop-web-agent`, `qa-agent`, `security-agent`, `release-devops-agent`)
  - `.agents/skills/` (`subphase-governance-gate`, `fluid-shader-physics-validation`, `accessibility-and-quality-audit`)
  - `.agents/workflows/multi_agent_subphase_audit.py`
  - `docs/architecture/ARCHITECTURE.md` (Clean Architecture, Fluid Physics Engine, AI & Supabase topology)
  - `docs/adr/ADR-001` through `ADR-005`
  - `docs/governance/EXECUTION_PLAN.md`, `docs/governance/RISKS_AND_ASSUMPTIONS.md`, `docs/governance/DECISION_LOG.md`, `CHANGELOG.md`
- **Validation Criteria**: All 10 agents registered; all governance, architecture, ADR, and gap-analysis documents verified against `<USER_REQUEST>`.
- **Maximum Execution Time**: 25 minutes
- **Risk Level**: Low
- **Rollback Strategy**: Revert governance directory files via Git.
- **Success Metrics**: 100% requirements traceability across all requested features, platforms, and engineering rules.

### Subphase 1.2.1 — Universal Cross-Platform Flutter Workspace, Git Strategy & DevContainer Bootstrap
- **Complexity**: Medium
- **Dependencies**: Subphase 1.1.1
- **Deliverables**:
  - Git repository initialized with `main`, `develop`, and `feature/stage-1-bootstrap` branches
  - Flutter multi-platform project (`android`, `ios`, `web`, `windows`, `macos`, `linux`)
  - `pubspec.yaml` with Riverpod, GoRouter, Material 3, Flutter SVG, Google Fonts, SharedPreferences, HTTP/Supabase client abstractions
  - Strict `analysis_options.yaml`, `Dockerfile`, `docker-compose.yml`, `.devcontainer/devcontainer.json`
  - Smoke test suite passing `flutter analyze` and `flutter test`
- **Validation Criteria**: Zero analyzer warnings; `flutter test` passes 100%; Git branches verified.
- **Maximum Execution Time**: 30 minutes
- **Risk Level**: Low
- **Rollback Strategy**: `git reset --hard` to initial commit on `develop`.
- **Success Metrics**: Clean compilation across target platforms and 0 static analysis issues.

### Subphase 2.1.1 — Hydration Science Domain, Exotic Animal Catalog & Biome Models
- **Complexity**: Medium
- **Dependencies**: Subphase 1.2.1
- **Deliverables**:
  - Immutable domain entities: `BeverageType` (16+ drinks with hydration bioavailability index, electrolyte/caffeine/sugar impact, density, viscosity, layer color), `HydrationEntry`, `ExoticAnimal` (Red Panda, Capybara, Axolotl, Otter, Llama, Arctic Fox, Emperor Penguin, Bottlenose Dolphin, Blue-Ringed Octopus, Snow Leopard), `AnimalEvolutionStage` (Hatchling, Explorer, Guardian, Mythic Spirit), `HydrationBiome` (Bamboo Misty Springs, Thermal Yuzu Onsen, Bioluminescent Cenote, Kelp Forest Lagoon, Andean Cloud Oasis, Aurora Glacier)
  - Offline-first Riverpod state notifiers and local persistence repository
  - Comprehensive unit tests for hydration math, stratification ordering, and goal progress
- **Validation Criteria**: 100% unit test pass rate on domain models and hydration math.
- **Maximum Execution Time**: 30 minutes
- **Risk Level**: Low
- **Rollback Strategy**: Revert `lib/src/domain/` and `lib/src/data/`.
- **Success Metrics**: Deterministic calculation of net hydration, electrolyte balance, and multi-drink layer volumes.

### Subphase 2.2.1 — Launch Screen: Animated SVG Red Panda Floating Pool Physics Engine
- **Complexity**: High
- **Dependencies**: Subphase 2.1.1
- **Deliverables**:
  - Top-view procedural pool water renderer (`PoolWaterSimulationPainter` & GLSL shader pipeline) with caustic tile distortion, concentric expanding ripples on touch/hover/ambient intervals, sunlight specular reflections, floating depth shadow parallax, and rising micro-bubbles
  - High-detail multi-layered vector/SVG Red Panda relaxing on a striped tropical swim tube with sunglasses and refreshing citrus drink, animated with buoyancy spring-damper bobbing, gentle rotational drift, ear/tail micro-motion, and interactive splash physics when tapped or dragged
  - Seamless transition from the floating Red Panda launch experience into the main hydration dashboard
- **Validation Criteria**: Smooth 60/120 FPS animation loop, reduced-motion static tranquility mode, full screen-reader semantics, widget tests passing.
- **Maximum Execution Time**: 35 minutes
- **Risk Level**: Medium
- **Rollback Strategy**: Fallback to simplified procedural water canvas if GPU shader compilation fails on legacy devices.
- **Success Metrics**: < 4ms paint time per frame; interactive ripple response on click/tap/pointer move.

### Subphase 2.3.1 — Animal Silhouette Fluid Simulation, Multi-Drink Stratification & Micro-Interactions
- **Complexity**: High
- **Dependencies**: Subphase 2.2.1
- **Deliverables**:
  - Precision vector silhouette paths for all 10 exotic animals with internal anatomical detail overlays, blinking/idle breathing animations, and glowing hydro-glass outlines
  - 1D/2D coupled shallow-water wave solver inside the active animal silhouette supporting multi-beverage stratified layers (inspired by and vastly upgrading Waterllama's stacked colored bands with real sloshing waves, meniscus refraction, internal rising bubbles, and splash droplets on drink entry)
  - Interactive vertical drag-to-pour cup modal (upgrading the reference image cup fill gesture) + custom numeric keypad + quick-log dock
  - Multi-sensory feedback engine: procedural Web/Mobile audio synthesis (water pour, bubble pop, level-up chime) + adaptive haptic pulses
- **Validation Criteria**: Zero memory leaks, 60/120 FPS sloshing physics, verified reduced-motion mode, comprehensive widget & unit tests.
- **Maximum Execution Time**: 40 minutes
- **Risk Level**: Medium
- **Rollback Strategy**: Isolate wave solver to fixed column count (64 columns) if frame time exceeds 6ms.
- **Success Metrics**: Every drink entry triggers realistic wave impulse, stratified color layer update, haptic pulse, and audio feedback.

### Subphase 3.1.1 — AI Hydration Coach, Weather/Activity Engine & Health Integrations
- **Complexity**: High
- **Dependencies**: Subphase 2.3.1
- **Deliverables**:
  - OpenAI-compatible AI Hydration Advisor (`AiHydrationService`) with streaming/structured coaching, beverage metabolic analysis, circadian pacing advice, and deterministic local expert fallback when offline
  - Weather, temperature, humidity, altitude, and workout intensity goal adjustment engine
  - Smart adaptive reminders with circadian quiet hours and catch-up pacing
  - Health platform integration bridge (Apple HealthKit / Google Health Connect abstraction with bi-directional sync simulator & export)
- **Validation Criteria**: Unit and integration tests covering AI prompt sanitization, offline fallback, and dynamic goal calculation.
- **Maximum Execution Time**: 35 minutes
- **Risk Level**: Medium
- **Rollback Strategy**: Fallback to local heuristic AI engine when external API key is not configured.
- **Success Metrics**: Accurate dynamic daily hydration target (ml/oz) adapting in real time to weather, activity, and beverage choices.

### Subphase 3.2.1 — Gamification, Habit Engine, Biomes, Evolution & Predictive Analytics
- **Complexity**: Medium
- **Dependencies**: Subphase 3.1.1
- **Deliverables**:
  - Habit-building behavioral engine (streak freeze protection, hydration consistency score, morning/evening rituals)
  - XP, levels, 20+ achievements, seasonal events ("Monsoon Oasis", "Coral Reef Restoration"), and animal evolution unlocks
  - Interactive Hydration Worlds/Biomes explorer where unlocked animals inhabit animated ecosystems
  - Advanced analytics & predictive insights (7/30/90-day hydration curves, beverage breakdown radar, dehydration risk forecast, CSV/JSON report export)
- **Validation Criteria**: Unit and widget tests verifying XP progression, evolution triggers, achievement unlocks, and chart rendering.
- **Maximum Execution Time**: 35 minutes
- **Risk Level**: Low
- **Rollback Strategy**: Revert gamification state notifier changes independently of core logging.
- **Success Metrics**: Complete progression loop from drink log → XP gain → animal evolution → biome unlock.

### Subphase 3.3.1 — Supabase Backend Schema, Row-Level Security, Realtime & Edge Functions
- **Complexity**: Medium
- **Dependencies**: Subphase 3.2.1
- **Deliverables**:
  - `supabase/migrations/20261122000001_initial_aquawild_schema.sql` with tables: `profiles`, `hydration_entries`, `user_animals`, `user_achievements`, `biomes_progress`, `ai_coaching_logs`, `health_sync_events`
  - Strict PostgreSQL Row-Level Security (RLS) policies, indexes, and Realtime publication setup
  - Supabase Edge Functions (`supabase/functions/ai-hydration-coach/index.ts`, `supabase/functions/hydration-analytics/index.ts`)
  - Offline-first sync queue service in Flutter (`SupabaseSyncService`) with conflict resolution
- **Validation Criteria**: SQL syntax & RLS policy verification, offline queue unit tests, security audit check.
- **Maximum Execution Time**: 30 minutes
- **Risk Level**: Medium
- **Rollback Strategy**: Execute down-migration script and run client in standalone offline-first mode.
- **Success Metrics**: 100% RLS coverage on all user tables; seamless offline-to-online sync queue.

### Subphase 4.1.1 — Responsive Cross-Platform Shell, Multimodal Accessibility & Dynamic Themes
- **Complexity**: Medium
- **Dependencies**: Subphase 3.3.1
- **Deliverables**:
  - Responsive adaptive shell for Phones (<600px bottom glass bar), Tablets/Foldables (600–1024px navigation rail + two-column view), and Desktops/Laptops/Web (>1024px three-pane command center with live animal habitat, analytics, and AI coach side-by-side)
  - Multi-theme engine: Light Daylight Aqua, Dark Abyssal Bioluminescence, Dynamic Biome Theme, and WCAG AAA High-Contrast Mode
  - Multimodal accessibility: Voice command drink logging ("Log 250ml green tea"), full keyboard shortcut map (`1`-`9`, `Space`, `C`, `A`, `B`, `R`, `?`), high-visibility focus rings, screen reader announcements, reduced-motion toggle, and 200% text-scale resilience
- **Validation Criteria**: Widget tests across mobile/tablet/desktop viewports, accessibility semantics tests, contrast validation.
- **Maximum Execution Time**: 35 minutes
- **Risk Level**: Low
- **Rollback Strategy**: Revert adaptive shell wrapper while keeping core screens intact.
- **Success Metrics**: Zero layout overflows from 320×568 up to 3840×2160 at 2.0x text scale.

### Subphase 4.2.1 — Production GitHub Actions Multi-Platform CI/CD & Full Verification Suite
- **Complexity**: Medium
- **Dependencies**: Subphase 4.1.1
- **Deliverables**:
  - `.github/workflows/build-all.yml` supporting `workflow_dispatch` boolean/choice inputs to build selected platforms (`all`, `android`, `ios`, `web`, `windows`, `macos`, `linux`), scheduled nightly builds, quality/lint/test/security/coverage gates, and artifact uploads
  - Dedicated workflows: `android.yml`, `ios.yml`, `web.yml`, `windows.yml`, `macos.yml`, `linux.yml`
  - End-to-end integration tests, Windows/Web local release build verification, and final documentation audit
- **Validation Criteria**: All workflows valid; all unit, widget, and integration tests pass; local release build verified.
- **Maximum Execution Time**: 30 minutes
- **Risk Level**: Low
- **Rollback Strategy**: Fix workflow matrix definitions or build flags before tagging release.
- **Success Metrics**: 100% test pass rate, 0 analyzer warnings, verified build artifacts.
