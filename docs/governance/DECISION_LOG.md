# Decision Log & AI Course-Correction Ledger

## Entry 001 — 2026-11-22 (Subphase 1.1.1)
- **Context**: Initial inspection of `h:\water` and the 4 user-uploaded reference screenshots (Waterllama Mobbin screens & Brownie Pool float prototype).
- **Gap Analysis Findings**:
  1. Competitor apps use flat horizontal color bands inside animal masks with no interfacial fluid wave physics or meniscus refraction.
  2. Competitor apps use aggressive dark-pattern paywall timers ("You'll lose access soon 23:57h") and lack desktop/web split-pane productivity views.
  3. The reference pool float screen depicts a capybara/bear on a static grid; the user explicitly requested a **highly detailed animated SVG Red Panda relaxing on a floating balloon/tube over top-view water with realistic floating physics, ripples, reflections, shadows, parallax, particles, procedural waves, depth effects, premium motion design, and seamless transitions**.
- **Course-Correction & Decision**:
  - Designed a dedicated top-view procedural water + SVG Red Panda floating physics engine for the launch screen with interactive ripples, caustic refraction, parallax shadows, and seamless Hero transition into the hydration studio.
  - Upgraded animal filling from static horizontal bands to a multi-stratum shallow-water wave solver with real-time sloshing, bubbles, splash particles, and beverage-specific hydration bioavailability calculation.
- **Sign-Off**: `solution-architect`, `product-agent`, `ux-ui-agent`, `animation-agent`, `qa-agent`, `security-agent`, `release-devops-agent`.

---

## Entry 002 — 2026-11-22 (Subphase 1.2.1)
- **Context**: Multi-platform workspace initialization and strict compiler validation.
- **Course-Correction & Observations**:
  1. Flutter 3.38+ / Dart 3.10+ updated `CardTheme` in `ThemeData` to expect `CardThemeData` and deprecated direct `.value` on `Color` in favor of `toARGB32()`. Updated `AppTheme` and test suites to modern Flutter 3.38+ contracts immediately to maintain zero warnings.
  2. Replaced relative directory navigation with package-qualified canonical imports (`package:aquawild/...`) across presentation screens to eliminate URI resolution ambiguities across platforms.
- **Sign-Off**: `solution-architect`, `desktop-web-agent`, `mobile-agent`, `qa-agent`, `release-devops-agent`.
