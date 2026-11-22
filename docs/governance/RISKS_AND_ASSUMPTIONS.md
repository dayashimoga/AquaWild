# Risks, Assumptions & Mitigation Registry

## 1. Risk Register

| ID | Category | Description | Likelihood | Impact | Mitigation Strategy | Owner | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **R-001** | Performance | Complex multi-layered fluid waves, caustic grids, and particles could cause frame drops on low-end mobile or web browsers. | Medium | High | Cap wave solver columns to 64 (O(N) linear step < 0.05ms), pre-allocate paths/paints outside `paint()`, and provide automatic LOD + Reduced Motion toggle. | `animation-agent` | Mitigated |
| **R-002** | Cross-Platform Compatibility | `dart:io` or native platform plugins could break Flutter Web compilation or Linux/Windows desktop builds. | Medium | High | Enforce pure Dart / universal APIs in domain and presentation layers; isolate platform features behind clean interfaces with universal fallbacks. | `desktop-web-agent` | Mitigated |
| **R-003** | Security & Secrets | Supabase keys or OpenAI API keys could be accidentally committed to Git. | Low | Critical | Load all credentials via `--dart-define` or runtime user vault; enforce automated secret scanning in CI and Security Agent subphase checks. | `security-agent` | Mitigated |
| **R-004** | Accessibility | Custom fluid canvas widgets (`CustomPaint`) are invisible to screen readers by default. | High | High | Wrap every canvas in an explicit `Semantics` widget exposing animal name, hydration percentage, net ml/oz, and keyboard action handlers. | `ux-ui-agent` | Mitigated |
| **R-005** | Scope Drift | Large feature surface could lead to superficial stubs instead of deep functional code. | Medium | High | Enforce the 12-Step Subphase Protocol: zero `TODO`s, mandatory unit/widget tests per subphase, and explicit user approval gates. | `solution-architect` | Mitigated |

---

## 2. Key Architectural Assumptions
1. **A-001 (Offline-First Execution)**: The app must be 100% functional out-of-the-box without requiring the user to spin up a live Supabase instance or enter an OpenAI key first, while seamlessly upgrading to live cloud sync and LLM completions when credentials are configured.
2. **A-002 (60/120 FPS Target)**: All animations use Flutter's `SingleTickerProviderStateMixin` / `Ticker` delta-time stepping so physics behave identically on 60Hz, 90Hz, 120Hz ProMotion, and 144Hz desktop monitors.
3. **A-003 (CI/CD Runner Availability)**: GitHub Actions workflows use `ubuntu-latest` for Android, Web, and Linux builds, `windows-latest` for Windows desktop builds, and `macos-latest` for iOS and macOS builds.
