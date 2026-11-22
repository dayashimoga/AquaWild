# Changelog

All notable changes to the **AquaWild (HydroFauna)** Cross-Platform AI-Powered Hydration Ecosystem are documented in this file.

## [0.2.0-subphase-2.1.1] - 2026-11-22
### Added
- **Beverage Bioavailability Engine**: Added 16 handcrafted beverages with bioavailability factors, caffeine diuretic offsetting, electrolyte metrics, densities, viscosities, and signature color palettes.
- **Exotic Animal & Evolution System**: Registered 10 exotic companions (Ruby the Red Panda, Cappy the Capybara, Lottie the Axolotl, Ollie the Sea Otter, Luna the Andean Llama, Freya the Arctic Fox, Percy the Emperor Penguin, Echo the Dolphin, Octavia the Octopus, Kira the Snow Leopard) across 4 evolution stages (Hatchling, Explorer, Guardian, Mythic Spirit).
- **Hydration Biomes**: Modeled 6 living biomes with custom ambient colorways, sky gradients, water caustic tints, and native animal associations.
- **Offline-First Persistence**: Created `HydrationRepository` and `LocalHydrationRepository` backed by `SharedPreferences` and in-memory caches.
- **Riverpod 3 State Notifiers**: Implemented `HydrationNotifier`, `AnimalHabitatNotifier`, and `BiomeNotifier` with safe `ref.mounted` asynchronous guards and density-stratified fluid layer computation.
- **Functionally Wired Dashboard**: Connected `HomeScreen` to Riverpod providers, displaying live net hydration progress, stratified fluid bar, companion XP evolution, and quick-log beverage dock.
- **Automated Domain & Controller Test Suite**: Added 18 unit, widget, and integration tests passing 100% with 0 analyzer issues.

---

## [0.1.0-subphase-1.2.1] - 2026-11-22
### Added
- **Multi-Platform Flutter Scaffold**: Generated complete 6-platform codebase for Android, iOS, Web, Windows, macOS, and Linux with package name `com.aquawild.app`.
- **Git Branch Strategy**: Initialized Git repository with `main`, `develop`, and `feature/stage-1-bootstrap` branches.
- **Ecosystem Dependencies**: Added `flutter_riverpod`, `go_router`, `flutter_svg`, `google_fonts`, `shared_preferences`, `http`, `uuid`, and `collection`.
- **Strict Static Analysis**: Configured strict `analysis_options.yaml` (strict casts, strict inference, strict raw types, zero analyzer warnings/infos policy).
- **Containerization**: Added `Dockerfile` (multi-stage Web build & Nginx runtime), `docker-compose.yml`, and `.devcontainer/devcontainer.json`.
- **Automated Tests**: Created `test/smoke_test.dart` passing 100% (4/4 tests).

---

## [0.1.0-subphase-1.1.1] - 2026-11-22
### Added
- **Antigravity IDE Multi-Agent Ecosystem**: Configured 10 specialized subagents (`solution-architect`, `product-agent`, `ux-ui-agent`, `animation-agent`, `backend-agent`, `mobile-agent`, `desktop-web-agent`, `qa-agent`, `security-agent`, `release-devops-agent`).
- **Workspace Rules & Skills**: Added [AGENTS.md](./AGENTS.md), [GEMINI.md](./GEMINI.md), `.agents/skills/subphase-governance-gate`, `.agents/skills/fluid-shader-physics-validation`, `.agents/skills/accessibility-and-quality-audit`, and `.agents/workflows/multi_agent_subphase_audit.py`.
- **Architecture & Governance Blueprint**: Added complete Stage → Phase → Subphase execution plan, competitive gap analysis against reference images, system architecture specification, ADRs 001–005, risk & assumption registry, and decision log.
