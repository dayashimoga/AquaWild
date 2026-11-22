# AGENTS.md — AquaWild (HydroFauna) Global Engineering Contract & Multi-Agent Governance

## 1. Global Engineering Contract (Non-Negotiable)
1. **Never Skip Validation**: Every code change, shader, database migration, and CI workflow MUST pass automated analysis (`flutter analyze --fatal-infos`), unit tests, widget tests, integration checks, accessibility audits, and security checks before completion.
2. **Never Mark Incomplete Work as Complete**: Stubs, `TODO` placeholders, mock-only UI without functional domain wiring, or unverified shaders are strictly prohibited in completed subphases.
3. **Perform Gap Analysis Before Implementation**: Every subphase begins with a formal Requirements Validation & Competitive Gap Analysis against both the master specification and market benchmarks (Waterllama, Brownie Pool prototype, Apple Design Award standards).
4. **Continuously Compare Implementation with Requirements**: Detect and eliminate scope drift immediately via AI Course-Correction logs.
5. **Maintain Living Architecture & Governance Documentation**:
   - Architecture overview: `docs/architecture/ARCHITECTURE.md`
   - Architecture Decision Records: `docs/adr/ADR-*.md`
   - Risks & Assumptions Registry: `docs/governance/RISKS_AND_ASSUMPTIONS.md`
   - Decision Log & Course Corrections: `docs/governance/DECISION_LOG.md`
   - Execution Tracker: `docs/governance/EXECUTION_PLAN.md`
   - Changelog: `CHANGELOG.md`
6. **Production-Ready Standards**:
   - **Performance**: 60/120 FPS target (< 8.3ms frame budget on 120Hz displays); zero shader compilation jank; zero memory leaks in animation tickers.
   - **Accessibility**: WCAG 2.2 AA+ compliance, full screen-reader (`Semantics`) tree annotations, full keyboard navigation (`Shortcuts`/`Actions`/`FocusTraversalGroup`), reduced-motion physics mode, high-contrast theme mode, and scalable typography up to 200%.
   - **Security**: OWASP MASVS/ASVS compliance, zero hardcoded secrets, strict Row-Level Security (RLS) on all Supabase tables, sanitized AI prompt inputs.
   - **Reliability & Maintainability**: Offline-first deterministic state management with Riverpod, type-safe routing with GoRouter, immutable domain models, and >85% core test coverage.

---

## 2. Multi-Agent Architecture & Ownership Matrix

| Agent Role | Subagent Identifier | Core Responsibilities | Required Validations & Sign-Off | Handoff Artifact |
| :--- | :--- | :--- | :--- | :--- |
| **Solution Architect** | `solution-architect` | System topology, Clean Architecture layers, Riverpod state design, offline-first sync, ADRs | Layer boundary verification, cyclic dependency check, ADR review | `docs/adr/ADR-*.md`, Architecture Review section |
| **Product Agent** | `product-agent` | Competitive gap analysis, hydration coefficient science, gamification economy, animal/biome catalog | Requirements traceability matrix, user story acceptance verification | Requirements & Gap Analysis report |
| **UX/UI Agent** | `ux-ui-agent` | Modern-futuristic Hydro-Glass UI, Material 3 adaptive breakpoints, dynamic themes, typography | Responsive breakpoint check (320px to 4K), contrast ratio check, focus order | UI token specs & widget tree validation |
| **Animation Agent** | `animation-agent` | GLSL/Impeller fluid shaders, shallow-water wave simulation, Red Panda pool launch physics, SVG creatures, particles | Frame raster budget (< 8ms), reduced-motion fallback check, ticker disposal | Shader & physics verification report |
| **Backend Agent** | `backend-agent` | Supabase PostgreSQL schema, RLS policies, Edge Functions, Realtime sync, OpenAI-compatible AI engine | SQL lint, RLS policy simulation, AI fallback resilience check | `supabase/` migrations & API contract |
| **Mobile Agent** | `mobile-agent` | Android & iOS configs, HealthKit / Health Connect bridges, adaptive haptics, spatial audio synthesis, reminders | Platform permission manifest audit, haptic/audio graceful degradation | Mobile platform verification |
| **Desktop/Web Agent** | `desktop-web-agent` | Windows, macOS, Linux, Web/Wasm layouts, keyboard shortcuts, high-DPI mouse hover/scroll physics | Desktop & Web build verification, keyboard-only navigation walkthrough | Multi-platform adaptive verification |
| **QA Agent** | `qa-agent` | Unit, widget, golden, and integration test suites; coverage analysis; performance profiling | `flutter test --coverage`, zero analyzer warnings, 100% pass rate | QA & Coverage Report |
| **Security Agent** | `security-agent` | Secret scanning, dependency audit, RLS audit, input validation, OWASP MASVS checks | Zero exposed keys, secure storage check, dependency vulnerability scan | Security Audit Sign-off |
| **Release/DevOps Agent** | `release-devops-agent` | Git flow (`main`, `develop`, `feature/*`, `release/*`, `hotfix/*`), GitHub Actions CI/CD, Docker, DevContainers | Workflow YAML syntax validation, selective platform matrix verification | CI/CD & Release Readiness Report |

---

## 3. Mandatory 12-Step Subphase Execution Protocol
Only **ONE** subphase may be active at any time. Every subphase MUST execute and document all 12 steps in order:
1. **Requirements Validation**: Trace subphase deliverables directly to user requirements.
2. **Gap Analysis**: Identify missing nuances, edge cases, and competitive differentiators.
3. **Architecture Review**: Validate clean boundaries, state flow, and ADR alignment.
4. **Implementation**: Write production-grade, well-documented code with zero placeholders.
5. **Unit Testing**: Verify domain logic, state notifiers, physics math, and services.
6. **Integration Testing**: Verify end-to-end user flows and multi-component interactions.
7. **Performance Validation**: Verify frame budgets, memory allocation, and shader efficiency.
8. **Security Validation**: Verify input sanitization, secret hygiene, and data protection.
9. **Accessibility Validation**: Verify semantics, contrast, keyboard navigation, and reduced motion.
10. **Documentation Update**: Update ADRs, changelogs, risk registers, and execution status.
11. **Completion Report**: Produce verifiable evidence (test logs, analyzer outputs, build artifacts).
12. **Approval Gate**: **STOP** after completing the subphase report and wait for explicit user approval before starting the next subphase.
