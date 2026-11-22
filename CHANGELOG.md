# Changelog

All notable changes to the **AquaWild (HydroFauna)** Cross-Platform AI-Powered Hydration Ecosystem are documented in this file.

## [0.1.0-subphase-1.2.1] - 2026-11-22
### Added
- **Multi-Platform Flutter Scaffold**: Generated complete 6-platform codebase for Android, iOS, Web, Windows, macOS, and Linux with package name `com.aquawild.app`.
- **Git Branch Strategy**: Initialized Git repository with `main`, `develop`, and `feature/stage-1-bootstrap` branches.
- **Ecosystem Dependencies**: Added `flutter_riverpod`, `go_router`, `flutter_svg`, `google_fonts`, `shared_preferences`, `http`, `uuid`, and `collection`.
- **Strict Static Analysis**: Configured strict `analysis_options.yaml` (strict casts, strict inference, strict raw types, zero analyzer warnings/infos policy).
- **Core Architecture Scaffolding**:
  - `lib/src/core/constants/app_constants.dart`
  - `lib/src/core/theme/app_colors.dart` (Bioluminescent cyans, hydro-glass tokens, beverage layer colors)
  - `lib/src/core/theme/app_theme.dart` (Material 3 Dark, Light, High-Contrast themes)
  - `lib/src/core/router/app_router.dart` (GoRouter with `/launch` and `/home`)
  - `lib/src/presentation/screens/launch/launch_screen.dart`
  - `lib/src/presentation/screens/home/home_screen.dart`
  - `lib/main.dart` with Riverpod `ProviderScope`
- **Containerization**: Added `Dockerfile` (multi-stage Web build & Nginx runtime), `docker-compose.yml`, and `.devcontainer/devcontainer.json`.
- **Automated Tests**: Created `test/smoke_test.dart` passing 100% (4/4 tests).

---

## [0.1.0-subphase-1.1.1] - 2026-11-22
### Added
- **Antigravity IDE Multi-Agent Ecosystem**: Configured 10 specialized subagents (`solution-architect`, `product-agent`, `ux-ui-agent`, `animation-agent`, `backend-agent`, `mobile-agent`, `desktop-web-agent`, `qa-agent`, `security-agent`, `release-devops-agent`).
- **Workspace Rules & Skills**: Added [AGENTS.md](./AGENTS.md), [GEMINI.md](./GEMINI.md), `.agents/skills/subphase-governance-gate`, `.agents/skills/fluid-shader-physics-validation`, `.agents/skills/accessibility-and-quality-audit`, and `.agents/workflows/multi_agent_subphase_audit.py`.
- **Architecture & Governance Blueprint**: Added complete Stage → Phase → Subphase execution plan, competitive gap analysis against reference images, system architecture specification, ADRs 001–005, risk & assumption registry, and decision log.
