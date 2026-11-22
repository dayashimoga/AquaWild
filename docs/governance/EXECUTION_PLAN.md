# AquaWild (HydroFauna) — Master Stage → Phase → Subphase Execution Plan

> **Execution Governance Rule**: Only **ONE** subphase may be active at any time. Every subphase follows the 12-Step Mandatory Execution Protocol and stops at the **Approval Gate** before advancing.

---

## Master Execution Hierarchy & Live Status Tracker

| Stage | Phase | Subphase | Capability / Component / Verifiable Increment | Complexity | Risk | Max Time | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Stage 1: Governance, Architecture & Foundation** | **Phase 1.1: Antigravity Multi-Agent & Architecture Blueprint** | **Subphase 1.1.1** | Antigravity IDE Multi-Agent Ecosystem, Global Engineering Contract, Competitive Gap Analysis, System Architecture, ADRs 001–005 & Governance Registry | Medium | Low | 25 min | ✅ **COMPLETED (Approved)** |
| Stage 1 | **Phase 1.2: Universal Cross-Platform Flutter Workspace & DevContainer Bootstrap** | **Subphase 1.2.1** | Git Repository Strategy (`main`, `develop`, `feature/stage-1-bootstrap`), Flutter 6-Platform Scaffold (Android, iOS, Web, Windows, macOS, Linux), Strict Linting, Docker & DevContainer Setup | Medium | Low | 30 min | ✅ **COMPLETED (Approved)** |
| **Stage 2: Core Domain, Fluid Physics & Launch Experience** | **Phase 2.1: Hydration Science Domain, Exotic Animal Catalog & Biome Models** | **Subphase 2.1.1** | Beverage Bio-Availability Engine (16+ Beverages), 10 Exotic Animals (Red Panda, Capybara, Axolotl, Otter, Llama, Fox, Penguin, Dolphin, Octopus, Snow Leopard), Evolution Stages, Hydration Biomes & Riverpod Offline-First State | Medium | Low | 30 min | ✅ **COMPLETED (Awaiting Approval Gate)** |
| Stage 2 | **Phase 2.2: Launch Screen — Animated SVG Red Panda Floating Pool Physics Engine** | **Subphase 2.2.1** | Interactive Top-View Pool Water Shader/Canvas (Caustics, Procedural Waves, Ripples, Parallax Shadows, Particles) + Detailed Animated SVG Red Panda on Floating Tube + Seamless Hero Transition | High | Medium | 35 min | ⏳ Pending (Next) |
| Stage 2 | **Phase 2.3: Animal Silhouette Fluid Simulation, Multi-Drink Stratification & Micro-Interactions** | **Subphase 2.3.1** | Real-Time 2D Shallow-Water Wave & Meniscus Solver Inside Exotic Animal Silhouettes, Multi-Beverage Colored Density Layers, Splash Particles, Pour Slider, Adaptive Haptics & Synthesized Audio | High | Medium | 40 min | ⏳ Pending |
| **Stage 3: AI Intelligence, Biometrics, Gamification & Backend** | **Phase 3.1: AI Hydration Coach, Weather/Activity Engine & Health Integrations** | **Subphase 3.1.1** | OpenAI-Compatible AI Hydration Advisor, Dynamic Weather/Activity/Altitude Goal Calculator, Smart Circadian Reminders, Apple HealthKit / Google Health Connect Bridges & Electrolyte Balance | High | Medium | 35 min | ⏳ Pending |
| Stage 3 | **Phase 3.2: Gamification, Habit Engine, Biomes, Evolution & Predictive Analytics** | **Subphase 3.2.1** | Habit-Building Engine, XP/Leveling, Streaks, Seasonal Challenges, Animal Evolution Unlock System, Interactive World Biomes & Predictive Analytics Reports | Medium | Low | 35 min | ⏳ Pending |
| Stage 3 | **Phase 3.3: Supabase Backend Schema, Row-Level Security, Realtime & Edge Functions** | **Subphase 3.3.1** | Production Supabase PostgreSQL Migrations, RLS Policies, Realtime Sync Queue, Edge Functions (`ai-hydration-coach`, `weather-hydration-goal`) & Security Audit | Medium | Medium | 30 min | ⏳ Pending |
| **Stage 4: Multi-Platform UX, Accessibility & CI/CD Release Automation** | **Phase 4.1: Responsive Cross-Platform Shell, Multimodal Accessibility & Dynamic Themes** | **Subphase 4.1.1** | Adaptive Mobile/Tablet/Desktop/Web Layouts, Light/Dark/Hydro-Glass/High-Contrast Themes, Voice Command Logging, Full Keyboard Navigation, Screen Reader Semantics & Reduced-Motion Mode | Medium | Low | 35 min | ⏳ Pending |
| Stage 4 | **Phase 4.2: Production GitHub Actions Multi-Platform CI/CD & Full Verification Suite** | **Subphase 4.2.1** | 7 GitHub Actions Workflows (`build-all.yml` with selective platform inputs + Android, iOS, Web, Windows, macOS, Linux workflows), Security/Coverage Gates & End-to-End Integration Suite | Medium | Low | 30 min | ⏳ Pending |

---

## Detailed Subphase Governance Specifications

### Subphase 2.1.1 — Hydration Science Domain, Exotic Animal Catalog & Biome Models
- **Complexity**: Medium
- **Dependencies**: Subphase 1.2.1
- **Deliverables**:
  - `lib/src/domain/models/beverage_type.dart`: 16 handcrafted drinks with hydration bioavailability indexes, density ($g/cm^3$), viscosity, and caffeine diuretic offset equations.
  - `lib/src/domain/models/hydration_entry.dart`: Immutable hydration event model with JSON serialization.
  - `lib/src/domain/models/fluid_layer.dart`: Stratified fluid layer representation with relative volume fractions.
  - `lib/src/domain/models/exotic_animal.dart`: 10 exotic companions (Ruby the Red Panda, Cappy the Capybara, Lottie the Axolotl, Ollie the Sea Otter, Luna the Andean Llama, Freya the Arctic Fox, Percy the Emperor Penguin, Echo the Dolphin, Octavia the Octopus, Kira the Snow Leopard).
  - `lib/src/domain/models/animal_evolution_stage.dart`: 4 evolution tiers (Hatchling, Explorer, Guardian, Mythic Spirit) with XP requirements and cosmetic auras.
  - `lib/src/domain/models/hydration_biome.dart`: 6 living biomes (Bamboo Misty Springs, Thermal Yuzu Onsen, Bioluminescent Cenote, Kelp Forest Lagoon, Andean Cloud Oasis, Aurora Glacier).
  - `lib/src/domain/models/daily_hydration_goal.dart`: Dynamic goal entity with weather/workout adjustments and progress fractions.
  - `lib/src/data/repositories/hydration_repository.dart` & `local_hydration_repository.dart`: Offline-first SharedPreferences and in-memory persistence.
  - `lib/src/presentation/controllers/`: Modern Riverpod 3 `Notifier` controllers (`HydrationNotifier`, `AnimalHabitatNotifier`, `BiomeNotifier`).
  - `lib/src/presentation/screens/home/home_screen.dart`: Functionally wired Material 3 dashboard displaying active companion, fluid stratification bar, and quick-log dock.
  - Automated test suites: `test/domain/beverage_science_test.dart`, `test/domain/exotic_animal_biome_test.dart`, `test/data/local_hydration_repository_test.dart`, `test/presentation/hydration_controller_test.dart`, `test/smoke_test.dart` (18/18 tests passing, 0 analyzer issues).
- **Validation Criteria**: Zero analyzer warnings (`No issues found`); 100% test pass rate (18/18 tests passed).
- **Maximum Execution Time**: 30 minutes
- **Risk Level**: Low
- **Rollback Strategy**: `git reset --hard` to previous commit on `main`.
- **Success Metrics**: Deterministic net hydration calculations and density-sorted liquid stratification.
